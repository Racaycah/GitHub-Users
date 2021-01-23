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
    @IBOutlet weak var avatarImageView: AsyncImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var extraIndicatorsStackView: UIStackView!
    
    var user: UserModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.secondaryLabel.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        for subview in extraIndicatorsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }

}

extension UserCollectionViewCell: BaseCell {
    typealias model = UserModel
    
    func configureCell(with model: UserModel, invertImage: Bool) {
        self.user = model
        
        usernameLabel.text = model.name
        
        for subview in extraIndicatorsStackView.arrangedSubviews {
            extraIndicatorsStackView.removeArrangedSubview(subview)
        }
        
        if let note = user.note, !note.isEmpty {
            let noteImageView = UIImageView(image: Badge.note.image?.withTintColor(.label))
            extraIndicatorsStackView.addArrangedSubview(noteImageView)
            
            NSLayoutConstraint.activate([
                noteImageView.widthAnchor.constraint(equalToConstant: 32),
                noteImageView.heightAnchor.constraint(equalToConstant: 32),
                noteImageView.centerYAnchor.constraint(equalTo: extraIndicatorsStackView.centerYAnchor)
            ])
        }
        
        guard let avatarUrl = URL(string: model.avatarUrl) else { return }
        
        if let imageData = model.image, let image = UIImage(data: imageData) {
            avatarImageView.image = image
            ImageCache.save(image: image, for: avatarUrl)
            return
        }
        
        if let image = ImageCache.image(for: avatarUrl) {
            if !invertImage {
                avatarImageView.image = image
            } else {
                let actualImage = CIImage(image: image)
                if let inversionFilter = CIFilter(name: "CIColorInvert") {
                    inversionFilter.setValue(actualImage, forKey: kCIInputImageKey)
                    let invertedImage = UIImage(ciImage: inversionFilter.outputImage!)
                    self.avatarImageView.image = invertedImage
                }
            }
        } else {
            avatarImageView.loadImage(from: avatarUrl)
        }
    }
}
