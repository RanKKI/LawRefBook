import Foundation
import UIKit

class ImageUtils: NSObject {

    static let shared = ImageUtils()

    private var onSuccess: (() -> Void)?

    override init() {
        super.init()
    }

    func save(image: UIImage, onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(image:error:contextInfo:)), nil)
    }

    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer?) {
        if error == nil {
            self.onSuccess?()
        }
    }

}
