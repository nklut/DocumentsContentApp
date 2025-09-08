import UIKit

class ContentViewController: UIViewController {
    
    private let pictureSaver = PictureSaver.shared
    private let imagePicker = UIImagePickerController()
    
    private var savedImages: [SavedImage] = [] {
        didSet {
            contentTableView.reloadData()
        }
    }
    
    private lazy var contentTableView: UITableView = {
        let view  = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .systemBackground
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = pictureSaver.docsDirPath.lastPathComponent
    
        setupButtons()
        setupPicker()
        setupTable()
    }
    
    private func setupButtons() {
        
        let addPictureButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddPicture)
        )
        
        let deleteAllButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.minus"),
            style: .plain,
            target: self,
            action: #selector(didTapDeleteAll)
        )
        
        navigationItem.rightBarButtonItems = [addPictureButton, deleteAllButton]
    }
    
    private func setupPicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }
    
    private func setupTable() {
        
        contentTableView.dataSource = self
        contentTableView.delegate = self
        contentTableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentTableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "ImageTableViewCell")
        contentTableView.separatorStyle = .none
        contentTableView.rowHeight = 200
        
        view.addSubview(contentTableView)
        
        NSLayoutConstraint.activate([
            contentTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            contentTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func loadImages() {
        
        let images = pictureSaver.getAllImageFiles()
        savedImages = images.compactMap { imageName in
            guard let image = pictureSaver.loadImage(named: imageName) else {
                return SavedImage(imageName: "", image: UIImage())
            }
            return SavedImage(imageName: imageName, image: image)
        }
        
        //Debug
        print("\(savedImages.count) images loaded")
    }
    
    @objc func didTapDeleteAll(){
        // Debug mostly
        
        let imageNames = pictureSaver.getAllImageFiles()
        imageNames.forEach { imageName in
             pictureSaver.deleteImage(named: imageName)
         }
         
         savedImages.removeAll()
         print("All Images deleted")
    }
    
    @objc func didTapAddPicture(){
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
    }
}

extension ContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contentTableView.dequeueReusableCell(
            withIdentifier: "ImageTableViewCell",
            for: indexPath
        ) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        let savedImage = savedImages[indexPath.row]
        cell.configure(with: savedImage.image)
        
        return cell
    }
}

extension ContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let imageToDelete = savedImages[indexPath.row]
            pictureSaver.deleteImage(named: imageToDelete.imageName)
            savedImages.remove(at: indexPath.row)
        }
    }
}

extension ContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            if let imageName = pictureSaver.saveImage(image) {
                let savedImage = SavedImage(imageName: imageName, image: image)
                savedImages.append(savedImage)
                print("Image \(imageName) saved")
            }
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


