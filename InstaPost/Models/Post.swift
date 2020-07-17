//
//  Post.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/8/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import Foundation
import SwiftUI

struct PostToServer: Codable {
    
    private let email: String
    private let password: String
    private let text: String
    private let hashtags: [String]
    
    init(email: String, password: String, text: String, hashtags: [String]) {
        
        self.email = email
        self.password = password
        self.text = text
        self.hashtags = hashtags
        
    }
    
    func encodeToJSON() -> Data? {
        
        return try? JSONEncoder().encode(self)
    }
}

struct ImageToServer: Codable {
    
    private var email: String
    private var password: String
    private var image: String // Base 64 String
    private var post_id: Int
    
    init(email: String, password: String, image: String, post_id: Int) {
        self.email = email
        self.password = password
        self.image = image
        self.post_id = post_id
    }
    
    enum CodingKeys: String, CodingKey {
        case email, password, image
        case post_id = "post-id"
    }
    
    func encodeToJSON() -> Data? {
        
        return try? JSONEncoder().encode(self)
    }    
}

struct RatingToServer: Codable {
    
    private var email: String
    private var password: String
    private var rating: Int
    private var post_id: Int
    
    init(email: String, password: String, rating: Int, post_id: Int) {
        self.email = email
        self.password = password
        self.rating = rating
        self.post_id = post_id
    }
    
    enum CodingKeys: String, CodingKey {
        case email, password, rating
        case post_id = "post-id"
    }
    
    func encodeToJSON() -> Data? {
        
        return try? JSONEncoder().encode(self)
    }
    
}


struct CommentToServer: Codable {
    
    private var email: String
    private var password: String
    private var comment: String
    private var post_id: Int
    
    init(email: String, password: String, comment: String, post_id: Int) {
        self.email = email
        self.password = password
        self.comment = comment
        self.post_id = post_id
    }
    
    enum CodingKeys: String, CodingKey {
        case email, password, comment
        case post_id = "post-id"
    }
    
    func encodeToJSON() -> Data? {
        
        return try? JSONEncoder().encode(self)
    }
    
}


struct Post: Codable, Equatable {
    
    var id: Int
    var image: Int
    var text: String
    var hashtags: [String]
    
    var comments: [String]
    var ratings_count: Int
    var ratings_average: Int
    
    enum CodingKeys: String, CodingKey {
        case id, image, text, hashtags, comments
        case ratings_count = "ratings-count"
        case ratings_average = "ratings-average"
    }
    
    init(id: Int, image: Int, text: String, hashtags: [String], comments: [String], ratings_count: Int, ratings_average: Int) {
        self.id = id
        self.image = image
        self.text = text
        self.hashtags = hashtags
        self.comments = comments
        self.ratings_count = ratings_count
        self.ratings_average = ratings_average
    }
    
    func getId() -> Int {
        return self.id
    }
    
    func getImageId() -> Int {
        return self.image
    }
    
    func getText() -> String {
        return self.text
    }
    
    func getHashtags() -> [String] {
        return self.hashtags
    }
    
    func getComments() -> [String] {
        return self.comments
    }
    
    func getRatingsCount() -> Int {
        return self.ratings_count
    }
    
    func getRatingsAverage() -> Int {
        return self.ratings_average
    }
}

struct RenderPostView: View {
    
    @Binding var PostObj: Post?
    @State var accentColor: Color
    
    @Binding var emailBind: String
    @Binding var passwordBind: String
    
    @State var newCommentInput: String = ""
    
    @State var commentToPost: String = ""
    
    var body: some View {
        
        VStack {
            
            if self.PostObj == nil {
                
                Text("Post not available yet.")
                    .font(.headline)
                    .foregroundColor(self.accentColor)
                
            } else {
                
                VStack{
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack(spacing: 0) {
                            
                            ForEach(Range<Int>(1...5)) { starIDx in
                                getSystemImage( starIDx <= self.PostObj!.ratings_count ? "star.fill" : "star", .yellow, .body)
                                    .padding(-10)
                                    
                                    .onTapGesture {
                                        
                                        self.PostObj!.ratings_count = starIDx
                                        
                                        self.updateRating()
                                }
                            }
                            
                        }.padding(8)
                        
                        Text("Ratings Average: \(String(self.PostObj!.ratings_average))")
                            .font(.caption)
                    }
                    
                    VStack {
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("\(self.PostObj!.text)").font(.body).lineLimit(5)
                                .padding(.vertical, 8)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                //                            displayTextList(textList: .constant(self.PostObj!.hashtags),
                                //                                            isVertical: false, color: accentColor, listType: .hashtags)
                                displayTextList(textList: .constant(self.PostObj!.hashtags),
                                                isVertical: false, color: accentColor, listType: .hashtags,
                                                emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                                
                                //                            displayTextList(textList: .constant(self.PostObj!.comments),
                                //                                            isVertical: false, listType: .comments)
                                displayTextList(textList: .constant(self.PostObj!.comments),
                                                isVertical: true, listType: .comments,
                                                emailBind: self.$emailBind, passwordBind: self.$passwordBind)
                            }
                            
                        }.padding(.horizontal)
                        
                        HStack(alignment: .center) {
                            
                            self.userInput(keyboard: .default,
                                           message: "",
                                           placeholder: "Comment here...",
                                           textfield:  self.$newCommentInput)
                                .frame(width: UIScreen.main.bounds.width * 0.80)
                            
                            Button(action: {
                                self.endEditing(true)
                                print("Add Comment Button Tapped!")
                                
                                self.commentToPost = self.newCommentInput
                                self.updateComment(newComment: self.commentToPost)
                                
                                // MARK: Add New Comment to the list
                                self.newCommentInput = ""
                                
                            }) { getSystemImage("plus.circle.fill", .accentColor, .headline).padding(.leading, -8) }
                        }
                        .padding()
                    }
                    
                }
                
            }
            
        }
    }
    
    private func endEditing(_ force: Bool) {
        UIApplication.shared.endEditing()
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
    
    private func updateComment(newComment: String) {
        
        guard let validUpdateCommentURLString:URL = URL(string: updateCommentURLString) else { return }
        
        guard let validPostObj = self.PostObj else { print("PostObj nil"); return }
        
        print("email: \(self.$emailBind.wrappedValue), password: \(self.$passwordBind.wrappedValue)")
        
        guard let uploadCommentData = CommentToServer(email: self.$emailBind.wrappedValue, password: self.$passwordBind.wrappedValue, comment: self.commentToPost, post_id: validPostObj.getId()).encodeToJSON() else { print("Can't encode comment data to JSON"); return }
        
        let validUpdateCommentURLRequest = getPostRequest(from: validUpdateCommentURLString, of: uploadCommentData)
        
        let task = appSession.dataTask(with: validUpdateCommentURLRequest, completionHandler: {
            (d, r, e) in
            
            guard let queryResult: String = getStringJSONData(d, r, e, key: "result") else { print("Can't connect to server! - ratings_count"); return }
            
            if queryResult == "success" {
                print("Success. - comment updated online")
                self.commentToPost = ""
                
            } else if queryResult == "fail" {
                
                self.commentToPost = ""
                
                var debugText = "Can't update comment, because "
                
                guard let queryError: String = getStringJSONData(d, r, e, key: "errors") else { debugText += "queryError: invalid..."; return }
                
                debugText += "\(queryError)."
                
                print("debugText - comment: \(debugText)")
            }
        })
        
        task.resume()
    }
    
    
    private func updateRating() {
        
        guard let validUpdateRatingURLString:URL = URL(string: updateRatingURLString) else { return }
        
        guard let validPostObj = self.PostObj else { print("PostObj nil"); return }
        
        print("email: \(self.$emailBind.wrappedValue), password: \(self.$passwordBind.wrappedValue)")
        
        guard let uploadRatingsData =  RatingToServer(email: self.$emailBind.wrappedValue, password: self.$passwordBind.wrappedValue, rating: validPostObj.getRatingsCount(), post_id: validPostObj.getId()).encodeToJSON() else { print("Can't encode ratings data to JSON"); return }
        
        let validUpdateRatingURLRequest = getPostRequest(from: validUpdateRatingURLString, of: uploadRatingsData)
        
        let task = appSession.dataTask(with: validUpdateRatingURLRequest, completionHandler: {
            (d, r, e) in
            
            guard let queryResult: String = getStringJSONData(d, r, e, key: "result") else { print("Can't connect to server! - ratings_count"); return }
            
            if queryResult == "success" {
                print("Success. - ratings_count updated online")
                
            } else if queryResult == "fail" {
                
                var debugText = "Can't update ratings_count, because "
                
                guard let queryError: String = getStringJSONData(d, r, e, key: "errors") else { debugText += "queryError: invalid..."; return }
                
                debugText += "\(queryError)."
                
                print("debugText - ratings_count: \(debugText)")
            }
        })
        
        task.resume()
    }
}
