//
//  NewPostView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/8/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

// A post contains an optional photo, text and one or more hashtags.

import SwiftUI
import Foundation
import Combine

struct NewPostView: View {
    
    @State var HashTags: [String] = []
    @State var newTagInput: String = ""
    @State var postTextInput: String = ""
    
    @State var postImage: Image?
    @State var postBase64ImageData: Data?
    
    @State var displayPostText: Bool = true
    @State var showingAlert:Bool = false
    @State var alertMessage: String = ""
    
    @Binding var loggedInUserCredentials: UserCredentials
    @Binding var userLoggedIn: Bool
    
    var body: some View {
        
        NavigationView {
            
            Background {
                
                ScrollView(.vertical, showsIndicators: true) {
                    
                    VStack {
                        
                        Divider()
                        VStack(alignment: .center, spacing: 10) {
                            
                            ImagePickerView(image: self.$postImage, base64ImageData: self.$postBase64ImageData)
                            
                            if self.displayPostText == true {
                                
                                HStack(alignment: .center) {
                                    
                                    Text( self.postTextInput == "" ? "Tap here to enter text" : "" + "\(self.postTextInput)")
                                        .font(.system(size: 18))
                                        .padding()
                                        .frame(width: UIScreen.main.bounds.width * 0.93, height: 100)
                                        .foregroundColor(.primary)
                                        .background(Color.clear)
                                        .cornerRadius(14)
                                    
                                }
                                .padding(16)
                                .frame(height: 100)
                                .onLongPressGesture(minimumDuration: 0) { self.displayPostText = false }
                                
                            } else {
                                
                                TextField("Write your text here...", text: self.$postTextInput, onEditingChanged: { (_) in
                                    self.displayPostText = false
                                    
                                }, onCommit: {
                                    self.endEditing(true)
                                    self.displayPostText = true
                                })
                                    .padding(.vertical, 12)
                                    .frame(width: UIScreen.main.bounds.width * 0.93)
                                    .lineLimit(3)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 18, design: .rounded))
                                    .keyboardType(.default)
                            }
                        }
                        
                        Spacer()
                        Divider()
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .center) {
                                
                                self.userInput(keyboard: .default,
                                               message: "",
                                               placeholder: "Write tag here without #...",
                                               textfield:  self.$newTagInput)
                                    .frame(width: UIScreen.main.bounds.width * 0.80)
                                
                                Button(action: {
                                    print("Add Hashtag Button Tapped!")
                                    self.endEditing(true)
                                    
                                    // MARK: Add Hashtag to the list
                                    //                                    self.addNewTag(existingTags: &self.HashTags, newTag: "#"+self.newTagInput)
                                    self.addNewTag(newTag: "#"+self.newTagInput)
                                    
                                    self.newTagInput = ""
                                    
                                }) { getSystemImage("plus.circle.fill", .accentColor, .headline)
                                    .padding(.leading, -8)
                                }
                                
                            }
                            .padding()
                            
                            //                            displayTextList(textList: self.$HashTags, isVertical: false, color: .accentColor, listType: .hashtags, headline: ListType.hashtags.rawValue)
                            
                            displayTextList(textList: self.$HashTags, isVertical: false, color: .accentColor, listType: .hashtags, headline: ListType.hashtags.rawValue,
                                            emailBind: .constant(self.loggedInUserCredentials.email), passwordBind: .constant(self.loggedInUserCredentials.password))
                                
                                .padding(.horizontal, 16)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            print("Post Button Tapped!")
                            
                            // MARK: Post the Entire Post to Server
                            self.postToCloud()
                            
                        }) { RoundedButton(text: "Post") }
                            .padding()
                    }
                }
                .accentColor(.pink)
            }    
            .navigationBarTitle(Text("New Post"), displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: { self.$userLoggedIn.wrappedValue = false })
            { Text("Logout").foregroundColor(.pink) })
        }
        .alert(isPresented: self.$showingAlert, content: { self.invalidDataEntryAlert })
        .onTapGesture {
            self.endEditing(true)
            self.displayPostText = true
        }
    }
    
    var invalidDataEntryAlert: Alert {
        
        return Alert(
            title: Text("Alert"),
            message: Text("\(self.alertMessage)"),
            dismissButton: .cancel(
                Text("Dismiss").foregroundColor(.red),
                action: {self.showingAlert.toggle(); self.alertMessage = ""}
            ))
    }
    
    func raiseAlert(_ message: String) {
        
        self.alertMessage = message
        self.showingAlert = true
    }
    
    func reInitStates() {
        self.HashTags = []
        self.newTagInput = ""
        self.postTextInput = ""
        
        self.postImage = nil
        self.postBase64ImageData = nil
        
        self.displayPostText = true
        self.showingAlert = false
        self.alertMessage = ""
    }
    
    func postImageToCloud(of postID: Int, email: String, password: String) {
        
        guard let validPostBase64ImageData = self.postBase64ImageData else { self.raiseAlert("No image was selected."); return }
        
        guard let validPostBase64ImageString = String(data: validPostBase64ImageData, encoding: .utf8)
            else { self.raiseAlert("Base64ImageString failed."); return }
        
        //        guard let validcreateNewImageURL:URL = URL(string: "http://192.168.0.9:5000/check") else { return }
        guard let validcreateNewImageURL:URL = URL(string: createNewImageURLString) else { print("validcreateNewImageURL failed."); return }
        
        guard let uploadNewImageData = ImageToServer(email: email, password: password, image: validPostBase64ImageString, post_id: postID).encodeToJSON() else { self.alertMessage = "Can't encode image data to JSON"; return }
        
        let validcreateNewImageURLRequest = getPostRequest(from: validcreateNewImageURL, of: uploadNewImageData)
        
        let task = appSession.dataTask(with: validcreateNewImageURLRequest, completionHandler: {
            (d, r, e) in
            
            guard let queryResult: String = getStringJSONData(d, r, e, key: "result") else { self.raiseAlert("Can't connect to server!"); return }
            
            if queryResult == "success" {
                
                self.raiseAlert("Success.")
                
            } else if queryResult == "fail" {
                
                self.alertMessage = "Can't create user, because "
                
                guard let queryError: String = getStringJSONData(d, r, e, key: "errors") else { self.alertMessage += "queryError: invalid..."; return }
                
                self.alertMessage += "\(queryError)."
                self.raiseAlert(self.alertMessage)
            }
            
            self.reInitStates()
        })
        
        task.resume()
    }
    
    func postToCloud() {
        
        self.alertMessage = ""
        
        if self.loggedInUserCredentials.isEmpty { self.alertMessage += "Login Credentials Invalid! " }
        
        if self.HashTags.isEmpty { self.alertMessage += "Hashtags can't be empty! " }
        
        if self.postTextInput.isEmpty { self.alertMessage += "Text can't be empty! " }
        
        if self.HashTags.isEmpty || self.postTextInput.isEmpty || self.loggedInUserCredentials.isEmpty { self.raiseAlert(self.alertMessage); return }
        
        
        guard let validCreateNewPostURL:URL = URL(string: createNewPostURLString) else { return }
        
        guard let uploadNewPostData = PostToServer(email: self.loggedInUserCredentials.email, password: self.loggedInUserCredentials.password, text: self.postTextInput, hashtags: self.HashTags).encodeToJSON() else { self.alertMessage = "Can't encode post data to JSON"; return }
        
        let validCreateNewPostURLRequest = getPostRequest(from: validCreateNewPostURL, of: uploadNewPostData)
        
        let task = appSession.dataTask(with: validCreateNewPostURLRequest, completionHandler: {
            (d, r, e) in
            
            guard let queryResult: String = getStringJSONData(d, r, e, key: "result") else { self.raiseAlert("Can't connect to server!"); return }
            
            if queryResult == "success" {
                
                guard let queryPostID: Int = getIntJSONData(d, r, e, key: "id") else { self.raiseAlert("Can't connect to server!"); return }
                
                self.raiseAlert("Success. Post Created with Post ID:\(queryPostID)!")
                
                if self.postImage != nil {
                    
                    self.postImageToCloud(of: queryPostID, email: self.loggedInUserCredentials.email, password: self.loggedInUserCredentials.password)
                    
                } else {
                    
                    self.reInitStates()
                    return
                }
                
            } else if queryResult == "fail" {
                
                self.alertMessage = "Can't create post, because "
                
                guard let queryError: String = getStringJSONData(d, r, e, key: "errors") else { self.alertMessage += "queryError: invalid..."; return }
                
                self.alertMessage += "\(queryError)."
                self.raiseAlert(self.alertMessage)
                
            }
        })
        
        task.resume()
    }
    
    private func endEditing(_ force: Bool) {
        UIApplication.shared.endEditing()
    }
    
    //    func addNewTag(existingTags: inout [String], newTag: String) {
    func addNewTag(newTag: String) {
        
        if !self.HashTags.contains(newTag) && newTag.trimmingCharacters(in: .whitespacesAndNewlines) != "#" {
            self.HashTags.append(newTag)
        }
    }
    
    private func userInput(keyboard keyboardDataType: UIKeyboardType = .default, message txt_msg:String="Text Message:", placeholder tf_msg:String="Placeholder Message", textfield tfTextBinding:Binding<String>, lineLimit:Int = 1, fontDesign:Font.Design = .monospaced) -> some View {
        
        
        HStack(spacing: 2) {
            
            if txt_msg != "" {
                Text(txt_msg)
                    .font(.headline)
            }
            
            TextField(tf_msg, text: tfTextBinding, onEditingChanged: { _ in
                
                tfTextBinding.wrappedValue = tfTextBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
            }) {
                self.endEditing(true)
            }
                
                
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 20*CGFloat(lineLimit))
            .fixedSize(horizontal: true, vertical: false)
                
            .lineLimit(lineLimit)
            .lineSpacing(0.5)
                //            .truncationMode(.middle)
                
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: fontDesign))
                .keyboardType(keyboardDataType)
            
        }
    }
    
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(loggedInUserCredentials: .constant(UserCredentials()), userLoggedIn: .constant(true))
            .previewDevice("iPhone XS")
    }
}

struct RoundedButton: View {
    
    @State var text: String
    @State var color: Color = .accentColor
    @State var foregroundColor: Color = .white
    
    var body: some View {
        Text(self.text)
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.88)
            .foregroundColor(foregroundColor)
            .background(self.color)
            .cornerRadius(14)
    }
}
