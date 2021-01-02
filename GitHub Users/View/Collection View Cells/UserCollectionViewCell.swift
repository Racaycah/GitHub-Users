//
//  UserCollectionViewCell.swift
//  GitHub Users
//
//  Created by Ata Doruk on 19.12.2020.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    enum Badge {
        case note
        
        var image: UIImage? {
            switch self {
            case .note: return UIImage(systemName: "note")
            default: return nil
            }
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var extraIndicatorsStackView: UIStackView!
    
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.secondaryLabel.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ImageCache.shared.cancelIfRunning(forURL: user.avatarUrl!)
        avatarImageView.image = nil
        for subview in extraIndicatorsStackView.arrangedSubviews {
            extraIndicatorsStackView.removeArrangedSubview(subview)
        }
    }

}

extension UserCollectionViewCell: BaseCell {
    typealias model = User
    
    func configureCell(with model: User, invertImage: Bool) {
        self.user = model
        
        usernameLabel.text = model.name
        
        for subview in extraIndicatorsStackView.arrangedSubviews {
            extraIndicatorsStackView.removeArrangedSubview(subview)
        }
        
        if user.note != nil {
            extraIndicatorsStackView.addArrangedSubview(UIImageView(image: Badge.note.image))
        }
        
        ImageCache.shared.fetch(from: model.avatarUrl!, completion: { [weak self] (image) in
            guard let self = self else { return }
            guard let image = image else { return }
            
            if !invertImage { self.avatarImageView.image = image } else {
                let actualImage = CIImage(image: image)
                if let inversionFilter = CIFilter(name: "CIColorInvert") {
                    inversionFilter.setValue(actualImage, forKey: kCIInputImageKey)
                    let invertedImage = UIImage(ciImage: inversionFilter.outputImage!)
                    self.avatarImageView.image = invertedImage
                }
            }
        })
    }
}
