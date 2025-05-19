import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    private var currentImageURL: String?
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
            cellImage.image = nil
    }
    
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
    
    func configure(with photo: Photo) {
        currentImageURL = photo.thumbImageURL
        let placeholder = UIImage(resource: .stubForImageCell)
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: placeholder)
        if let createdAt = photo.createdAt {
            let dateString = DateFormatter.ruLong.string(from: createdAt)
            dateLabel.text = dateString
        } else {
            dateLabel.text = "Дата неизвестна"
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
          likeButton.setImage(likeImage, for: .normal)
      }
}

