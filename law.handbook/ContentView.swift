//
//  ContentView.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI

struct TextContent : Hashable {
    var text: String
    var children: [String]
}

class Model: ObservableObject {
    @Published var Name: String = ""
    @Published var Desc: [String] = []
    @Published var Body: [TextContent] = []
    
    init(filename:String, folder: String?) {
        var dir = "laws"
        if folder != nil {
            dir += "/" + folder!
        }
        if let filepath = Bundle.main.path(forResource: filename, ofType: "md", inDirectory: dir) {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    let arr = contents.components(separatedBy: "\n").map{text in
                        return text.trimmingCharacters(in: [" ", "\n"])
                    }.filter{ line in
                        return !line.isEmpty
                    }
                    
                    var isDesc = true
                    
                    for (index, text) in arr.enumerated() {
                        let out = text.split(separator: " ", maxSplits: 2)
                        if out.isEmpty {
                            continue
                        }
                        if(index == 0){
                            // 标题
                            self.Name = String(out[1])
                            continue
                        }
                        
                        if(out[0].hasPrefix("#")){
                            isDesc = false
                        }
                        
                        if isDesc {
                            self.Desc.append(text)
                            continue
                        }
                        
                        if out[0].hasPrefix("#") {
                            self.Body.append(TextContent(text: String(out[1]), children: []))
                        } else {
                            let lastChildren = self.Body[self.Body.count - 1].children
                            let result = text.range(of: "第.+条", options: .regularExpression)
                            if lastChildren.isEmpty || result != nil {
                                self.Body[self.Body.count - 1].children.append(contentsOf: [text])
                            }else{
                                let len = self.Body[self.Body.count - 1].children.count
                                self.Body[self.Body.count - 1].children[len - 1] += "\n    "
                                self.Body[self.Body.count - 1].children[len - 1] += text
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}

struct ContributeView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            Section(header: Text("测试1")) {
                Text("12321“")
            }
            Section(header: Text("测试1")) {
                Text("12321“")
            }
            Section(header: Text("测试1")) {
                Text("12321“")
            }
        }
    }
}

struct ContentView: View {
    
    @State var showModal = false
    
    var body: some View {
        NavigationView{
            List {
                ForEach(laws, id: \.name) { g in
                    Section(header: Text(g.name)) {
                        ForEach(g.laws, id: \.name) { law in
                            NavigationLink(destination: LicenseView(model: Model(filename:law.name, folder: law.folder))){
                                Text(law.name)
                            }
                        }
                    }
                }
            }.navigationBarTitle("中国法律")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showModal.toggle()
                        }, label: {
                            HStack {
                                Image(systemName: "gear")
                            }
                        })
                            .foregroundColor(.red) // You can apply colors and other modifiers too
                            .sheet(isPresented: $showModal) {
                                ContributeView()
                            }
                    }
                }
        }
    }
}

struct LicenseView: View {
    @ObservedObject var model: Model
    
    var body: some View{
        List {
            Text(model.Name)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .font(.title2)
            ForEach(model.Desc, id: \.self) { desc in
                Text(desc)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            ForEach(Array(model.Body.enumerated()), id: \.offset){ i, body in
                Section(header: Text(body.text)){
                    ForEach(Array(body.children.enumerated()), id: \.offset){ j, text in
                        Text(text)
                    }
                }
                
            }
        }.listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}

struct LicenseView_Previews:PreviewProvider {
    static var previews: some View {
        Group {
            LicenseView(model: Model(filename: "消费者权益保护法", folder: nil))
        }.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}
