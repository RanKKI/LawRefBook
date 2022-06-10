import Foundation
import SwiftUI
import SPAlert

struct SharingViewController: UIViewControllerRepresentable {
    
    @Binding
    var isPresenting: Bool
    
    var completion: () -> Void
    
    var content: () -> UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: completion)
        }
    }
}

struct ShareContent: Hashable {
    var name: String
    var contents: [String]
}

struct ShareByPhotoView: View {
    
    var shareContents: [ShareContent]

    @Environment(\.dismiss)
    var dismiss

    @State
    private var shareing = false

    var shareView: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(shareContents, id: \.self) { law in
                Text(law.name)
                    .font(.title2)
                    .padding([.bottom, .top], 8)
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(law.contents, id: \.self) {
                        Text($0)
                            .padding([.trailing, .leading], 4)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            HStack {
                Spacer()
                Image(uiImage: generateQRCode(from: "https://apps.apple.com/app/apple-store/id1612953870"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
        }
        .padding()
        .snapView()
    }
    
    var body: some View {
        ScrollView {
            VStack {
                shareView
                HStack(alignment: .center, spacing: 8) {
                    Button {
//                        UIImageWriteToSavedPhotosAlbum(shareView.asImage(), nil, nil, nil)
                        ImageUtils.shared.save(image: shareView.asImage()) {
                            let alertView = SPAlertView(title: "保存成功", preset: .done)
                            alertView.present(haptic: .success)
                        }
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("保存")
                                .font(.caption2)
                        }
                    }
                    .padding(.leading, 8)
                    Spacer()
                    Button {
                        shareing.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("分享")
                        }
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding([.leading, .trailing], 16)
            }
            .padding()
        }
        .background(SharingViewController(isPresenting: $shareing, completion: {
            shareing = false
        }, content: {
            let av = UIActivityViewController(activityItems: [shareView.asImage()], applicationActivities: nil)
            av.completionWithItemsHandler = { _, _, _, _ in
//                dismiss()
            }
            return av
        }))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseSheetItem {
                    dismiss()
                }
            }
        }
    }
    
}


struct ShareByPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        let content = ShareContent(name: "民法典合同编很长很差很功能很差很难过", contents: ["点放假啊看了计分卡家乐福看见啊离开家","第四百一十条 一二打卡减肥看来大家快点放假啊快点放假啊看了计分卡家乐福看见啊离开家"])
        ShareByPhotoView(shareContents: [content]);
    }
}
