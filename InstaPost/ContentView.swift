//
//  ContentView.swift
//  InstaPost
//
//  Created by Saumil Shah on 2/11/20.
//  Copyright © 2020 Saumil Shah. All rights reserved.
//

///
/// iOS Assignment 04 - InstaPost
///
/// InstaPost allows Android users to make and view posts. A post contains an optional photo, text and one or more hashtags.
///
/// A user can create an account by providing an email address, their name and a nick name.
///
/// Besides making posts a user can see a list of user's nicknames and a list of hashtags.
///
/// From either list the user can select another user (or hashtag) and see all the posts from that user (or all the posts with that hashtag).
///
/// One can the rate and/or comment not the post.
///
///

import SwiftUI
struct ContentView: View {
    
    @State var userLoggedIn: Bool
    @State var selectedView: Int = 1
    @State var currentUser: UserCredentials
    
    var body: some View {
        
        VStack {
            
            if !userLoggedIn {
                
                LoginView(userValidated: self.$userLoggedIn,
                          loggedInUserCredentials: self.$currentUser)
                    .onAppear {
                        //                        self.currentUser = UserCredentials()
                        self.currentUser = UserCredentials(email: "bruce@wayne.corp", password: "123456")
                }
                
            } else {
                
                TabView(selection: self.$selectedView) {
                    
                    NewPostView(loggedInUserCredentials: self.$currentUser,
                                userLoggedIn: self.$userLoggedIn)
                        .tabItem {
                            tabItemGroup(itemText: "New Post", systemName: self.selectedView == 1 ? "photo.fill" : "photo" )
                    }.tag(1)
                    
                    ListOfNicknamesView(emailBind: .constant(self.currentUser.email), passwordBind: .constant(self.currentUser.password))
                        .tabItem {
                            tabItemGroup(itemText: "Nicknames", systemName: self.selectedView == 2 ? "person.fill" : "person")
                    }.tag(2)
                    
                    ListOfTagsView(emailBind: .constant(self.currentUser.email), passwordBind: .constant(self.currentUser.password))
                        .tabItem {
                            tabItemGroup(itemText: "Hashtags", systemName: self.selectedView == 3 ? "tag.fill" : "tag")
                    }.tag(3)
                    
//                    ListOfPostsView(postText: .constant("Batman"), emailBind: .constant(self.currentUser.email), passwordBind: .constant(self.currentUser.password))
//                        .tabItem {
//                            tabItemGroup(itemText: "Post View", systemName: self.selectedView == 4 ? "play.rectangle.fill" : "play.rectangle")
//                    }.tag(4)
                    
                }
            }
        }
        .animation(.spring(dampingFraction: 0.8))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userLoggedIn: false, currentUser: UserCredentials())
            .previewDevice("iPhone XS")
    }
}

func tabItemGroup(itemText: String, systemName: String) -> some View {
    
    VStack {
        Text(itemText)
        getSystemImage(systemName, font: .body)
    }
    
}

func getSystemImage(_ systemName: String = "photo", color:Color = .primary) -> some View {
    
    getSystemImage(systemName, color, .body)
}


func getSystemImage(_ systemName: String = "photo", font:Font = .body) -> some View {
    
    getSystemImage(systemName, .primary, font)
}

func getSystemImage(_ systemName: String = "photo", _ color:Color = .primary, _ font:Font = .title) -> some View {
    Image(systemName: systemName)
        .foregroundColor(color)
        .font(font)
        .imageScale(.large)
        .padding()
}

struct Background<Content: View>: View {
    private var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

