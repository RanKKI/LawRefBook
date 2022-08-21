//
//  TableView.swift
//  RefBook
//
//  Created by Hugh Liu on 21/8/2022.
//

import Foundation
import SwiftUI

typealias TableData = [[String]]

struct TableView: View {
    
    /* 每行的数据应该一样长 */
    var data: TableData

    var width: CGFloat = UIScreen.screenWidth
    
    private var padWidth: CGFloat {
        width - 32
    }
    
    var body: some View {
        VStack {
            ForEach(data, id: \.self) { row in
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        ForEach(Array(row.enumerated()), id: \.offset) { (idx, val) in
                            Text(val)
                                .frame(width: padWidth / CGFloat(row.count) - 16)
                                .multilineTextAlignment(.center)
                            Spacer()
                            if idx < row.count - 1 {
                                Divider()
                                Spacer()
                            }
                        }
                    }
                    Divider()
                }
                .padding([.leading, .trailing], 8)
            }
        }
        .background(Rectangle().foregroundColor(.clear).border(.black))
    }
    
}


struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView(data: [["名字", "选项"], ["Afjdaklfjdlakjfdajfkjdalkfjlkdjlflkadjlfkladjlkfdja", "B"], ["A", "B"], ["A", "B"], ["A", "B"]])
    }
}
