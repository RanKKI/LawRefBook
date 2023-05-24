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
    
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                Text(item.dlc.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            DLCStateView(item: item)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
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
                HStack(spacing: 8) {
                    Text("30%")
                        .foregroundColor(.gray)
                    ProgressView()
                }
            }
        }
    }

}

struct DLCProgressView: View {
    
    @ObservedObject
    var item: DLCListView.DLCItem
    
    var body: some View {
        ProgressView(value: 40, total: 100)
            .progressViewStyle(.linear)
    }

}

#if DEBUG
struct DLCView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                DLCView(item: .init(dlc: DLCManager.DLCs[0], state: .downloaded)) {
                    
                }
                DLCView(item: .init(dlc: DLCManager.DLCs[0], state: .downloading)) {
                    
                }
                DLCView(item: .init(dlc: DLCManager.DLCs[0], state: .failed)) {
                    
                }
                DLCView(item: .init(dlc: DLCManager.DLCs[0], state: .ready)) {
                    
                }
            } header: {
                Text("DLC")
            }
        }
    }
}
#endif
