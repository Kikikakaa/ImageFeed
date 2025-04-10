//
//  ViewController.swift
//  ImageFeed
//
//  Created by user on 28.02.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }

        let image = UIImage(named: photosName[indexPath.row])
        viewController.image = image
    }

   private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let currentDate = Date()
       let dateString = DateFormatter.ruLong.string(from: currentDate)
        cell.dateLabel.text = dateString
        let imageName = photosName[indexPath.row]
        cell.cellImage.image = UIImage(named: imageName)
        
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            cell.likeButton.setImage(likeImage, for: .normal)
    }

}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else {
            return 200 // Дефолтная высота, если изображение не найдено
        }
        
        // Ширина изображения в ячейке (с учетом отступов таблицы)
        let imageViewWidth = tableView.bounds.width - tableView.contentInset.left - tableView.contentInset.right
        
        // Соотношение сторон изображения
        let aspectRatio = image.size.width / image.size.height
        
        // Высота ImageView
        let imageViewHeight = imageViewWidth / aspectRatio
        
        // Общая высота ячейки = высота ImageView + верхний/нижний отступы ячейки
        let verticalSpacing: CGFloat = 16 // Пример: 8pt сверху и 8pt снизу
        return imageViewHeight + verticalSpacing
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
