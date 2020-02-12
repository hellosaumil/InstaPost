//
//  PostView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/21/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct PostView: View {
    
    @State var postObject: Post?
    @State var postID: Int?
    @State var postText: String = ""
    
    @State var postImage: Image?
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if postObject == nil {
                
                Spacer().padding(4)
                
                HStack {
                    
                    if self.postID == nil {
                        
                        getSystemImage("wifi.exclamationmark").padding(-4)
                        Text("Connection Weak or Loading the Post...").font(.headline)
                        
                    } else {
                        
                        getSystemImage("exclamationmark.square.fill").padding(-4)
                        //                            Text("Post not found for \( self.postText.first == "#" ? self.postText : "nickname "+self.postText).").font(.headline)
                        Text("Loading Post for post id \( self.postID ?? -1)").font(.headline)
                    }
                }
                
                Spacer().padding(4)
                
            } else {
                
                VStack(spacing: 10) {
                    
                    CustomImageView(image: self.$postImage)
                        //                        .frame(width: UIScreen.main.bounds.width*0.95)
                        .onTapGesture { self.loadRemoteImage(of: self.postObject?.getImageId(), session: appSession) }
                    
                    RenderPostView(PostObj: self.$postObject, accentColor: .accentColor, emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                        .onAppear { self.loadRemoteImage(of: self.postObject?.getImageId(), session: appSession) }
                    
                }
                //                self.postObject?.renderPostView(accentColor: .accentColor)
                //                    .onAppear { self.loadRemoteImage(of: self.postObject?.getImageId(), session: appSession) }
            }
        }
            //            .frame(width: UIScreen.main.bounds.width)
            
            .onAppear(perform: {
                
                self.postObject = nil
//                self.resetImage()
                
                //                DispatchQueue.main.async {
                
                if let validPostID: Int = self.postID {
                    
                    self.loadPost(of: validPostID)
                }
                //                }
            })
    }
    
    func loadPost(of postID: Int, key: String = "post") {
        
        guard let validPostURL:URL = URL(string: postURLString + String(postID)) else { return }
        
        print("\t validPostURL: \(validPostURL)")
        
        let task = appSession.dataTask(with: validPostURL, completionHandler: {
            (d, r, e) in
            
            guard let validJSONObject = parseHTTPResponse(data: d, response: r, error: e) as? [String:Any] else { return }
            
            do {
                let postDataJSON = try JSONSerialization.data(withJSONObject: validJSONObject[key]!)
                
                print("postDataJSON: \(postDataJSON)")
                
                self.postObject = try JSONDecoder().decode(Post.self, from: postDataJSON)
                print("\nPost Found for ID: \(postID)")
                
            } catch {
                print("\n***Invalid Post for ID: \(postID)")
                return
            }
        })
        
        task.resume()
    }
    
    func resetImage(_ resetImageName: String = "xmark.rectangle") { self.postImage = Image(systemName: resetImageName) }
    
    func loadRemoteImage(of postImageID: Int?, session:URLSession = .shared) {
        
        guard self.postObject != nil else { self.resetImage("rectangle.on.rectangle.angled"); return }
        
        guard let imageID:Int = postImageID else { self.resetImage(); return }
        
        guard let validImageURL:URL = URL(string: imageURLString + String(imageID)) else { self.resetImage(); return }
        
        let task = session.dataTask(with: validImageURL, completionHandler: {
            (d, r, e) in
            
            guard let remoteImage = getStringJSONData(d, r, e, key: "image") else { self.resetImage(); return }
            
            guard remoteImage != "none" else { self.resetImage(); return }
            
            guard let validUIImage = UIImage(data: Data(base64Encoded: remoteImage, options: .ignoreUnknownCharacters)!) else { print("***Invalid UIImage.");  self.resetImage() ; return }
            
            
            self.postImage = Image(uiImage: validUIImage)
            print("Updated")
            
        })
        
        task.resume()
    }
}


struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(emailBind: .constant("batman@wayne.corp"), passwordBind: .constant("123456"))
            .previewDevice("iPhone Xs")
    }
}

