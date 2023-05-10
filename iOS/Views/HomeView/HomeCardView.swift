//
//  HomeCardView.swift
//  RefBook
//
//  Created by Hugh Liu on 19/3/2023.
//

import Foundation
import SwiftUI

private var WIDTH = UIScreen.screenWidth
private var FULL_HEIGHT: CGFloat = (WIDTH - 24 * 2) / 2
private var HALF_HEIGHT: CGFloat = (FULL_HEIGHT - 8) / 2

struct HomeCardView: View {

    var body: some View {
        HStack(spacing: 16) {
            NavigationLink {
                LawListView(showFavorite: false, cateogry: "劳动人事")
            } label: {
                HomeCardFullView(title: "打工人须知", subtitle: "勤劳的社畜保护法", icon: "icon_2")
            }
            .buttonStyle(PlainButtonStyle())
            VStack(spacing: 8) {
                NavigationLink {
                    LawListView(showFavorite: true)
                } label: {
                    HomeHalfCardView(title: "法律法规", subtitle: "快查手册", icon: "icon_1")
                }
                .buttonStyle(PlainButtonStyle())
                NavigationLink {
                    FavoriteView()
                        .navigationBarTitle("书签", displayMode: .inline)
                } label: {
                    HomeHalfCardView(title: "收藏夹", subtitle: "某些内容", icon: "icon_1")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

}


struct HomeCardFullView: View {
    
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                VStack(spacing: 4) {
                    Text(title)
                        .bold()
                        .font(.system(size: 14))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
        }
        .frame(width: FULL_HEIGHT, height: FULL_HEIGHT)
        .modifier(HomeCardEffect())
    }

}

struct HomeHalfCardView: View {

    var title: String
    var subtitle: String
    var icon: String
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.7, anchor: .center)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .bold()
                        .font(.system(size: 14))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .frame(width: FULL_HEIGHT, height: HALF_HEIGHT)
        .modifier(HomeCardEffect())
    }
}

struct HomeCardEffect: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 2)

            }
    }
}

#if DEBUG
struct HomeCardPreview: PreviewProvider {
    static var previews: some View {
        HomeCardView()
    }
}
#endif
