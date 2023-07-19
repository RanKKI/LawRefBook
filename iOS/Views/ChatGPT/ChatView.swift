//
//  ChatView.swift
//  RefBook
//
//  Created by Hugh Liu on 2/3/2023.
//

import Foundation
import SwiftUI

struct ChatView: View {

    @ObservedObject
    var vm: VM
    
    @State
    var getProToggle = false
    
    @Environment(\.dismiss)
    private var dismiss
    
    private let loadingID = UUID()
    
    @ObservedObject
    private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(vm.messages, id: \.id) { msg in
                        ChatBoxView(msg: msg) { content in
                            vm.submit(text: content)
                        }
                        .id(msg.id)
                    }
                    if vm.isLoading {
                        ChatBoxView(msg: .init(isBot: true, message: "", isLoading: true))
                            .id(loadingID)
                    }
                }
                .onChange(of: $vm.messages.count, perform: { newValue in
                    if !vm.isLoading {
                        withAnimation {
                            proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                        }
                    }
                })
                .onChange(of: vm.isLoading, perform: { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(loadingID, anchor: .bottom)
                        }
                    }
                })
                .onChange(of: keyboard.isKeyboardShown, perform: { newValue in
                    withAnimation {
                        proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                    }
                })
            }
            .padding([.bottom], 8)
            if IsProUnlocked {
                ChatInputView(isLoading: $vm.isLoading) { text in
                    vm.submit(text: text)
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded{
            UIApplication.shared.endEditing()
        })
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
        HStack(spacing: 16) {
            TextField("", text: $text, prompt: Text("输入一些问题吧～"))
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color("ChatInputBoxBackground2"))
                )
            if isLoading {
                ProgressView()
            } else {
                Button {
                    action(text)
                    text = ""
                } label: {
                    Image(systemName: "paperplane")
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .foregroundColor(Color("ChatInputBoxSendIcon"))
            }
        }
        .frame(height: 46)
//        .addBorder(.black, width: 0.6, cornerRadius: 8)
        .padding(18)
        .background(
            Rectangle()
                .foregroundColor(Color("ChatInputBoxBackground"))
                .ignoresSafeArea()
        )
        
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

