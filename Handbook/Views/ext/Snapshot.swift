import SwiftUI

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


extension View {
    
    func snapView() -> some View {
        self
            .ignoresSafeArea()
            .background(Color.white // any non-transparent background
              .shadow(radius: 4)
            )
            .padding(8)
            .frame(width: UIScreen.screenWidth)
            .fixedSize(horizontal: true, vertical: true)
    }
    
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        // locate far out of screen
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)

        let size = controller.view.intrinsicContentSize //controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        controller.view.sizeToFit()

        //let image = controller.view.asImage()
        let image = UIImage(view: controller.view)
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions((view.frame.size), false, 0.0)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
