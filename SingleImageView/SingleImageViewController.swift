import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {

    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image = image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
            centerImageView()
        }
    }
    
    var imageURL: String?
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .stubForSingle))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self 
        scrollView.minimumZoomScale = .minZoomScale
        scrollView.maximumZoomScale = .maxZoomScale
        
        if image == nil {
            setupPlaceholderConstraints()
        }
        if let image = image {
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        } else {
            loadImage()
        }
    }
    
    private func setupPlaceholderConstraints() {
        imageView.addSubview(placeholderImageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: 83),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 75),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func removePlaceholder() {
        placeholderImageView.removeFromSuperview()
    }
    
    private func loadImage() {
        guard let imageURLString = imageURL,
              let url = URL(string: imageURLString) else {
            print("[SingleImageViewController|loadImage]: Некорректный URL изображения")
            return
        }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ]) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.imageView.image = imageResult.image
                    self.removePlaceholder() // Удаляем заглушку после успешной загрузки
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure(let error):
                    print("[SingleImageViewController|loadImage]: Ошибка загрузки изображения: \(error.localizedDescription)")
                    self.imageView.image = nil
                    self.setupPlaceholderConstraints() // Показываем заглушку в случае ошибки
                    self.showSingleImageLoadError()
                }
            }
    }
    
    private func showSingleImageLoadError() {
        let alert = UIAlertController(title: "Ошибка!", message: "Что-то пошло не так, попробовать еще раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
            self.loadImage()
        })
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        centerImageView()
    }
    
    private func centerImageView() {
        guard let imageView = imageView else { return }
        
        let horizontalInset = max(0, (scrollView.bounds.width - imageView.frame.width) / 2)
        let verticalInset = max(0, (scrollView.bounds.height - imageView.frame.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset
        )
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

private extension CGFloat {
    static let minZoomScale: CGFloat = 0.1
    static let maxZoomScale: CGFloat = 1.25
}
