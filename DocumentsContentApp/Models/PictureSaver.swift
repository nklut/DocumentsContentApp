import Foundation
import UIKit

struct SavedImage {
    let imageName: String
    let image: UIImage
}

final class PictureSaver {
    
    static let shared = PictureSaver()
    
    private let docsDirContent = (try? FileManager.default.contentsOfDirectory(at: .documentsDirectory, includingPropertiesForKeys: nil)) ?? []
    let docsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func saveImage(_ image: UIImage) -> String? {
        let imageName = "\(UUID().uuidString).jpg"
        let imageURL = docsDirPath.appendingPathComponent(imageName)
            
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Image conversion error")
            return nil
        }
            
        do {
            try imageData.write(to: imageURL)
            return imageName
        } catch {
            print("Image saving error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage(named imageName: String) -> UIImage? {
        let imageURL = docsDirPath.appendingPathComponent(imageName)
        
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            return nil
        }
        return UIImage(contentsOfFile: imageURL.path)
    }
    
    func deleteImage(named imageName: String) {
        let imageURL = docsDirPath.appendingPathComponent(imageName)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                print("Image deletion error: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllImageFiles() -> [String] {
        do {
            let images = try FileManager.default.contentsOfDirectory(atPath: docsDirPath.path)
            return images.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".png") }
        } catch {
            print("Error reading images from Documents dir: \(error.localizedDescription)")
            return []
        }
    }
}
