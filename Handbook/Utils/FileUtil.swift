import Foundation
import UIKit

extension Data {
    func asUTF8String() -> String {
        return String(decoding: self, as: UTF8.self)
    }
    
    func decodeJSON<T>(_ type: T.Type) -> T? where T : Decodable {
        do {
            return try JSONDecoder().decode(type, from: self)
        } catch {
            return nil
        }
    }
}

func readLocalFile(bundlePath: String?) -> Data? {
    do {
        if let bundlePath = bundlePath,
           let ret = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return ret
        }
    } catch {
        print(error)
    }
    
    return nil
}

func readLocalFile(forName name: String, type: String, inDirectory: String? = nil) -> Data? {
    return readLocalFile(bundlePath: Bundle.main.path(forResource: name, ofType: type, inDirectory: inDirectory))
}

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
