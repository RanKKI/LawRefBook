//
//  DLCView.swift
//  RefBook
//
//  Created by Hugh Liu on 22/6/2022.
//

import Foundation
import SwiftUI

struct DLCView: View {
    
    @ObservedObject
    var item: DLCListView.DLCItem
    
    var downloadAction: (() -> Void)?
    
    var deleteAction: (() -> Void)?
    
    @State
    private var downloadConfirm = false
    
    @State
    private var deleteConfirm = false
    
    @State
    private var deleteOrUpdateConfirm = false
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            DLCStateView(item: item)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switch(item.state) {
            case .upgradeable:
                deleteOrUpdateConfirm.toggle()
            case .ready, .delete:
                deleteConfirm.toggle()
            default:
                downloadConfirm.toggle()
            }
        }
        .alert("下载 DLC", isPresented: $downloadConfirm, actions: {
            Button("确认") {
                downloadAction?()
            }
            Button("取消") {

            }
        }) {
            Text(item.name)
        }
        .alert(item.state == .delete ? "取消删除" : "删除 DLC", isPresented: $deleteConfirm, actions: {
            Button(item.state == .delete ? "确定取消" : "删除") {
                deleteAction?()
            }
            Button("取消") {

            }
        }) {
            Text(item.name)
        }
        .alert("删除/更新 DLC", isPresented: $deleteOrUpdateConfirm, actions: {
            Button("更新") {
                downloadAction?()
            }
            Button("删除") {
                deleteAction?()
            }
            Button("取消") { }
        }) {
            Text(item.name)
        }
    }
    
}

struct DLCStateView: View {
    
    @ObservedObject
    var item: DLCListView.DLCItem
    
    var body: some View {
        Group {
            if let icon = item.state.icon {
                Image(systemName: icon)
                    .foregroundColor(item.state.iconColor)
            } else if item.state == .downloading {
                ProgressView()
            }
        }
    }

}
