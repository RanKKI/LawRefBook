import Foundation
import SwiftUI
import SPAlert


struct ShareLawView: View {

    @ObservedObject
    var vm: VM

    @Environment(\.dismiss)
    var dismiss
    
    @State
    private var shareing = false
    
    @AppStorage("ShareByPhotoViewReviewReq")
    private var reviewReq = false

    var shareView: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(vm.rendererContents, id: \.self) { contents in
                Text(contents.first?.name ?? "")
                    .font(.title2)
                    .padding([.bottom, .top], 8)
                    .multilineTextAlignment(.center)
                ForEach(contents, id: \.self) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.content)
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
        .foregroundColor(.black)
        .snapView()
    }
    
    var contentView: some View {
        ScrollView {
            VStack {
                shareView
                HStack(alignment: .center, spacing: 8) {
                    Button {
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
                if !reviewReq {
                    reviewReq = true
                    AppStoreReviewManager.requestReviewIfAppropriate()
                }
            }
            return av
        }))
    }

    var body: some View {
        NavigationView {
            ShareLawLightConfirmView {
                Group {
                    if vm.isEditing {
                        ShareLawEditView(contents: $vm.selectedContents)
                            .environment(\.editMode, .constant(.active))
                    } else {
                        contentView
                            .preferredColorScheme(.light)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CloseSheetItem {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        if vm.canEdit {
                            Button {
                                vm.isEditing.toggle()
                            } label: {
                                Text(vm.isEditing ? "完成" : "编辑")
                            }
                        }
                    }
                }
            }
            .navigationTitle("分享")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}
