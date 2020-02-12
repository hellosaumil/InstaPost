//
//  StringObject.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/8/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import Foundation
import SwiftUI

struct StringObject:Hashable {
    
    private let text: String
    
    init(_ text:String) {
        self.text = text
    }
    
    func getText() -> String {
        return self.text
    }
    
    func toInt() -> Int? {
        return Int(self.text)
    }
    
    func getTextView(color: Color = .primary) -> some View {
        
        Text("\(self.text)")
            .lineLimit(2)
            .truncationMode(.middle)
            .foregroundColor(color)
            .frame(width: 100, alignment: .leading)
        //            .frame(minWidth: 80)
        //            .frame(idealWidth: 140)
        //            .frame(maxWidth: 300)
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.text)
    }
    
}

enum ListType: String {
    case hashtags, comments, nicknames, other
}


struct getTextListWithSearchBarView: View {
    
    @State var strings: [String]
    @State var color: Color = .primary
    @State var listType: ListType = .other
    
    @State private var searchText: String = ""
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
//    init(of strings:[String]) {
//        self.init(of: strings, color: .primary, listType: .other)
//    }
//
//    init(of strings:[String], listType: ListType) {
//        self.init(of: strings, color: .primary, listType: listType)
//    }
//
//    init(of strings:[String], color:Color, listType: ListType) {
//        self.strings = strings
//        self.color = color
//        self.listType = listType
//    }
    
    var body: some View {
        
        Group {
            
            self.userInput(keyboard: self.listType == .comments ? .twitter : .default, placeholder: "Search for \(self.listType.rawValue.capitalized)...", textfield: self.$searchText, fontDesign: .monospaced)
            
            ForEach(self.strings.filter{$0.hasPrefix(self.searchText) || self.searchText == ""}.map{StringObject($0)},
                    id: \.self) { stringObj in
                        
                        Group {
                            
                            if self.listType == .other {
                                
                                stringObj.getTextView(color: self.color)
                                
                            } else {
                                
                                NavigationLink(destination:
//                                    PostView(postText: stringObj.getText())
//                                    ListOfPostsView(postText: .constant(stringObj.getText()))
                                    ListOfPostsView(postText: .constant(stringObj.getText()),
                                                    emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                                        
                                    .accentColor(.pink)
                                    .navigationBarTitle(Text("Post for \(stringObj.getText())"))
                                ) { stringObj.getTextView(color: self.color) }
                            }
                        }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func userInput(keyboard keyboardDataType: UIKeyboardType = .default, placeholder tf_msg:String="Placeholder Message", textfield tfTextBinding:Binding<String>, lineLimit:Int = 1, fontDesign:Font.Design = .monospaced) -> some View {
        
        
        TextField(tf_msg, text: tfTextBinding, onEditingChanged: { _ in
            
            tfTextBinding.wrappedValue = tfTextBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
        })
            .frame(width: UIScreen.main.bounds.width * 0.88, height: 20*CGFloat(lineLimit))
            .lineLimit(lineLimit)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(.body, design: fontDesign))
            .keyboardType(keyboardDataType)
    }
}

struct getTextList: View {
    
    @State var strings: [String]
    @State var color: Color = .primary
    @State var listType: ListType = .other
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
//    init(of strings:[String]) {
//        self.init(of: strings, color: .primary, listType: .other)
//    }
//
//    init(of strings:[String], listType: ListType) {
//        self.init(of: strings, color: .primary, listType: listType)
//    }
//
//    init(of strings:[String], color:Color, listType: ListType) {
//        self.strings = strings
//        self.color = color
//        self.listType = listType
//    }
    
//    func getList() -> some View {
    
    var body: some View {
        
        Group {
            
            ForEach(self.strings.map{StringObject($0)}, id: \.self) { stringObj in
                
                Group {
                    
                    if self.listType == .other || self.listType == .comments {
                        
                        stringObj.getTextView(color: self.color)
                        
                    } else {
                        
                        NavigationLink(destination:
//                            PostView(postText: stringObj.getText())
//                            ListOfPostsView(postText: .constant(stringObj.getText()))

                            ListOfPostsView(postText: .constant(stringObj.getText()),
                            emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                                
                            .accentColor(.pink)
                            .navigationBarTitle(Text("Post for \(stringObj.getText())"))
                        ) { stringObj.getTextView(color: self.color) }
                    }   
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct displayTextList: View {
    
    @Binding var textList: [String]
    
    @State var isVertical: Bool = true
    @State var color: Color = .primary
    @State var listType: ListType
    @State var headline: String = ""
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    var body: some View {
        
        Group {
            
            if self.textList.isEmpty {
                
                Text("No \(self.headline.capitalized) or taking too long to load")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.vertical, 8)
                
            } else {
                
                if isVertical {
                    
                    VStack(alignment: .leading) {
                        
                        Text("\(self.headline.capitalized): ").font(.headline)
                        
                        ScrollView(.vertical, showsIndicators: true) {
                            
                            VStack(alignment: .leading) {
                                
//                                getTextList(of: self.textList, color: color, listType: listType).getList()
                                
                                getTextList(strings: self.textList, color: color, listType: listType,
                                            emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                                
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: UIScreen.main.bounds.width * 0.80)
                    
                    
                } else {
                    
                    HStack {
                        
                        Text("\(self.headline): ").font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            
                            HStack(spacing: 2) {
                                
//                                getTextList(of: self.textList, color: color, listType: listType).getList()
                                
                                getTextList(strings: self.textList, color: color, listType: listType,
                                emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    //                    .frame(width: UIScreen.main.bounds.width * 0.8)
                }
            }
        }
        .onAppear {
            self.headline = self.listType.rawValue.capitalized
        }
    }
}

