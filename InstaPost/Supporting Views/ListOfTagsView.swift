//
//  ListOfTagsView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/9/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct ListOfTagsView: View {
    
    @State var hcounts:Int = 0
    @State var htags:[String] = [String]()
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    var body: some View {
        
        NavigationView {
            
            Group {
                
                VStack {
                    
                    if self.htags.isEmpty {
                        Spacer()
                        Text("No Tags Found or taking too long to load.").font(.system(size: 18)).foregroundColor(.gray).bold()
                        Spacer()
                        
                    } else {
                        
                        List {
//                            getTextListWithSearchBarView(of: htags, color: .accentColor, listType: .hashtags)
                            getTextListWithSearchBarView(strings: htags, color: .accentColor, listType: .hashtags,
                                                         emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                        }
                    }
                    
                    Divider().padding(.top, 2)
                    
                    Text("Total Hashtags: \(self.hcounts)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Divider().padding(.bottom, 2)
                    
                }
            }
            .navigationBarTitle(Text("List of Hashtags"), displayMode: .automatic)
            .onAppear(perform: {
                DispatchQueue.main.async {
                    self.loadTags()
                }
            })
        }
        .accentColor(.pink)
    }
    
    
    func checkIfAnyTagsAvailable() -> Bool {
        
        guard let validHashtagCountURL:URL = URL(string: hashtagsCountURLString) else {
            return false
        }
        
        let task = appSession.dataTask(with: validHashtagCountURL, completionHandler: {
            (d, r, e) in
            
            guard let totalCounts = getIntJSONData(d, r, e, key: "hashtag-count") else { return }
            
            self.hcounts = totalCounts
        })
        
        task.resume()
        
        return true
    }
    
    func loadTags() {
        
        guard self.checkIfAnyTagsAvailable() else {
            return
        }
        
        guard let validHashtagsURL:URL = URL(string: hashtagsURLString) else {
            return
        }
        
        let task = appSession.dataTask(with: validHashtagsURL, completionHandler: {
            (d, r, e) in
            
            self.htags = getStringsJSONData(d, r, e, key: "hashtags")
//            print(self.htags)
        })
        
        task.resume()
    }
}

struct ListOfTagsView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfTagsView(emailBind: .constant("bruce@waynce.corp"), passwordBind: .constant("123456"))
            .previewDevice("iPhone XS")
    }
}

