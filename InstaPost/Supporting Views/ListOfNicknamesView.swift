//
//  ListOfNicknamesView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/13/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct ListOfNicknamesView: View {
    
    @State var nicknames:[String] = [String]()
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    var body: some View {
        
        NavigationView {
            
            Group {
                
                if self.nicknames.isEmpty {
                    
                    Text("No Nicknames Found or taking too long to load.")
                        .font(.system(size: 18)).foregroundColor(.gray).bold()
                    
                } else {
                    
                    List {
//                        getTextListWithSearchBarView(of: nicknames, listType: .nicknames)
                        
                        getTextListWithSearchBarView(strings: nicknames, listType: .nicknames,
                                                     emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                    }
                }
            }
            .accentColor(.pink)
            .navigationBarTitle(Text("List of Nicknames"), displayMode: .automatic)
            .onAppear(perform: {
                DispatchQueue.main.async {
                    self.loadNicknames()
                }
            })
        }
    }
    
    func loadNicknames() {
        
        guard let validNicknamesURL:URL = URL(string: nicknamesURLString) else {
            return
        }
        
        let task = appSession.dataTask(with: validNicknamesURL, completionHandler: {
            (d, r, e) in
            
            self.nicknames = getStringsJSONData(d, r, e, key: "nicknames")
//            print(self.nicknames)
        })
        
        task.resume()
    }
}

struct ListOfNicknamesView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfNicknamesView(emailBind: .constant("bruce@waynce.corp"), passwordBind: .constant("123456"))
        .previewDevice("iPhone XS")
    }
}
