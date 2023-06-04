//
//  ChatView.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation
import SwiftUI


let COUNT_EACH_PURCHASE = 250

let WARNING = """
您应知晓您发送的内容将发送至开发者 的服务器，您的内容可能会被加入进模型进行训练，因此，请勿输入任何涉密、私人信息。

任何回复不构成法律建议，如您真的需要法律帮助，找律师。
"""


struct EmptyBackground: View {
 
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    ChatMessageView(msg: .init(isBot: true, message: WARNING))
                    Divider()
                    ChatMessageView(msg: .init(isBot: true, message: "您可以问：虚假宣传相关的法律法规有哪些"))
                    Divider()
                }
                .padding([.leading, .trailing], 16)
                .listStyle(.plain)
            }
        }
        .opacity(0.5)
    }
    
}
struct ChatView: View {

    @ObservedObject
    var vm: VM
    
    @State
    var getProToggle = false
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.messages.isEmpty {
                EmptyBackground()
            } else {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            ForEach(vm.messages) { msg in
                                ChatMessageView(msg: msg)
                                    .id(msg.id)
                                Divider()
                            }
                        }
                        .padding([.leading, .trailing], 16)
                        .listStyle(.plain)
                        .onChange(of: vm.messages, perform: { newValue in
                            proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                        })
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
            }
            if IsProUnlocked {
                ChatInputView(isLoading: $vm.isLoading) { text in
                    vm.submit(text: text)
                }
            }
        }
        .onAppear {
            if !IsProUnlocked {
                getProToggle.toggle()
            }
        }
        .sheet(isPresented: $getProToggle) {
            GetProView() { val in
                if !val {
                    dismiss()
                }
            }
        }
    }
}

struct ChatInputView: View {
    
    @State
    private var text = ""

    @Binding
    var isLoading: Bool
    
    var action: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $text, prompt: Text("输入一些问题吧～"))
                .padding(10)
            if isLoading {
                ProgressView()
                    .padding(10)
            } else {
                Button {
                    action(text)
                    text = ""
                } label: {
                    Image(systemName: "paperplane")
                }
                .padding(10)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .frame(height: 46)
        .addBorder(.black, width: 0.6, cornerRadius: 8)
        .padding([.leading, .trailing], 10)
    }
}

struct ChatMessageView: View {
    
    let msg: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack {
                if msg.isBot {
                    Image("chatgpt_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            .frame(width: 24, height: 24)
            VStack(alignment: .leading) {
                Text(msg.message)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .frame(minHeight: 36)
    }
    
}

extension View {
     public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
         let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
         return clipShape(roundedRect)
              .overlay(roundedRect.strokeBorder(content, lineWidth: width))
     }
 }



struct ChatViewPreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(vm: .init())
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

