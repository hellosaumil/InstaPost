//
//  ListOfPostsView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/25/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct ListOfPostsView: View {
    
    @State var listsOfPostID: [Int] = []
    @Binding var postText: String
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    var body: some View {
        
        VStack {
            
            if self.listsOfPostID.isEmpty {
                
                Text("No Posts for \(self.postText)")
                
            } else {
                
                List {
                    
                    ForEach(self.listsOfPostID, id: \.self) { postID in
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("Post ID #\(postID)")
                                .font(.callout).bold()
                            
                            PostView(postID: postID,
                                     emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                                .padding(.horizontal, -16)
                        }
                    }
                }
            }
        }
            
        .onAppear {
            
            DispatchQueue.main.async {
                self.postText.first == "#" ?
                    self.loadHashtagPostIDs(of: self.postText) : self.loadNicknamePostIDs(of: self.postText)
            }
        }
        
    }
    
    
    func loadHashtagPostIDs(of hashtag: String) {
        
        print("\nIN loadHashtagPostIDs.... \(hashtag)")
        
        guard let validHashtagPostIDsURL:URL = URL(string: hashtagPostIDsURLString + hashtag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return
        }
        
        self.loadPostIDs(from: validHashtagPostIDsURL)
        
    }
    
    func loadNicknamePostIDs(of nickname: String) {
        
        print("\nIN loadNicknamePostIDs.... \(nickname)")
        
        guard let validNicknamePostIDsURL:URL = URL(string: nicknamePostIDsURLString + nickname) else {
            return
        }
        
        self.loadPostIDs(from: validNicknamePostIDsURL)
    }
    
    func loadPostIDs(from validPostIDsURL: URL) {
        
        print("\t.... \(validPostIDsURL)")
        
        let task = appSession.dataTask(with: validPostIDsURL, completionHandler: {
            (d, r, e) in
            
            self.listsOfPostID = getIntsJSONData(d, r, e, key: "ids")
        })
        
        task.resume()
    }
}

struct ListOfPostsView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfPostsView(postText: .constant("Batman"), emailBind: .constant("batman@wayne.corp"), passwordBind: .constant("123456"))
            .previewDevice("iPhone Xs")
    }
}
