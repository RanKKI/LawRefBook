import Foundation
import SwiftUI

enum LightConfirmCode {
    case confirm
    case always
}

struct ShareLawLightConfirmView<Content: View>: View {

    var content: () -> Content

    @AppStorage("rememberlightconfirm")
    private var alwaysConfirm = false

    @State
    private var isConfirmedLight = false

    @Environment(\.colorScheme)
    private var colorScheme

    private var showConfirmView: Bool {
        colorScheme == .dark && !isConfirmedLight && !alwaysConfirm
    }

    var body: some View {
        Group {
            if showConfirmView {
                VStack(spacing: 16) {
                    Spacer()
                    Text("您目前使用的是*深色模式*，分享图因为设计原因没法做适配，因此该界面将强制使用亮色模式。注意保护您的眼睛")
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                isConfirmedLight.toggle()
                            }
                        } label: {
                            Text("确认")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                alwaysConfirm.toggle()
                            }
                        } label: {
                            Text("不用再问了")
                                .underline()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .multilineTextAlignment(.center)
                .padding(32)
            } else {
                content()
            }
        }
    }

}
