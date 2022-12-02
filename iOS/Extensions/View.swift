//
//  View.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

extension View {

    @ViewBuilder
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }

}

// 生成图片
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

        let size = controller.view.intrinsicContentSize // controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        controller.view.sizeToFit()

        // let image = controller.view.asImage()
        let image = UIImage(view: controller.view)
        controller.view.removeFromSuperview()
        return image
    }
}
