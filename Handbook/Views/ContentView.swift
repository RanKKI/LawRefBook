import SwiftUI
import CoreData

struct LawList: View {
    
    @State var searchText = ""
    @State var laws = LawProvider.shared.lawList
    
    var body: some View {
        List(laws, id: \.self) { ids  in
            Section(header: Text(LawProvider.shared.getCategoryName(ids[0]))) {
                ForEach(ids, id: \.self) { uuid in
                    NavigationLink(destination: LawContentView(lawID: uuid).onAppear {
                        LawProvider.shared.getLawContent(uuid).load()
                    }){
                        Text( LawProvider.shared.getLawNameByUUID(uuid))
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "宪法修正案")
        .onChange(of: searchText){ text in
            if text.isEmpty {
                laws = LawProvider.shared.lawList
            } else {
                var ret: [[UUID]] = []
                LawProvider.shared.lawList.forEach {
                    let arr = $0.filter {
                        LawProvider.shared.getLawNameByUUID($0).contains(searchText)
                    }
                    if !arr.isEmpty {
                        ret.append(arr)
                    }
                }
                laws = ret
            }
        }
    }
}

struct ContentView: View {
    
    class SheetMananger: ObservableObject{
        
        enum SheetState {
            case none
            case favorite
            case setting
        }
        
        @Published var isShowingSheet = false
        @Published var sheetState: SheetState = .none {
            didSet {
                isShowingSheet = sheetState != .none
            }
        }
    }
    
    @StateObject var sheetManager = SheetMananger()
    
    var body: some View {
        NavigationView{
            LawList()
                .navigationTitle("中国法律")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        IconButton(icon: "heart") {
                            sheetManager.sheetState = .favorite
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        IconButton(icon: "gear") {
                            sheetManager.sheetState = .setting
                        }
                    }
                }
                .sheet(isPresented: $sheetManager.isShowingSheet, onDismiss: {
                    sheetManager.sheetState = .none
                }) {
                    NavigationView {
                        if sheetManager.sheetState == .setting {
                            SettingView()
                                .navigationBarTitle("关于", displayMode: .inline)
                        } else if sheetManager.sheetState == .favorite {
                            FavoriteView()
                                .navigationBarTitle("收藏", displayMode: .inline)
                        }
                    }
                }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
}
