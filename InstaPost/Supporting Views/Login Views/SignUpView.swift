//
//  SignUpView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/22/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    
    @Binding var showModal: Bool
    
    @State var fnameField: String = ""
    @State var lnameField: String = ""
    @State var nicknameField: String = ""
    @State var emailField: String = ""
    @State var passwordField: String = ""
    
    @State var debugText: String = ""
    @State var showingAlert: Bool = false
    
    var body: some View {
        
        Background {
            
            VStack(spacing: 0) {
                
                HStack {
                    
                    Text("Register").font(.largeTitle).bold()
                    
                    Spacer()
                    
                    Button(action: { self.showModal.toggle() }) {
                        getSystemImage("xmark.circle.fill", .accentColor, .body).padding(.vertical, 16)
                    }
                    
                }.padding(.horizontal, 16)
                
                Divider()
                
                VStack(alignment: .center, spacing: 0) {
                    
                    
                    self.userInput(keyboard: .namePhonePad, message: "First Name: ", placeholder: "Enter First Name", textfield: self.$fnameField, lineLimit: 1, fontDesign: .serif)
                    
                    self.userInput(keyboard: .namePhonePad, message: "Last Name: ", placeholder: "Enter Last Name", textfield: self.$lnameField, lineLimit: 1, fontDesign: .serif)
                    
                    self.userInput(keyboard: .namePhonePad, message: "Nickname: ", placeholder: "Enter Nickname", textfield: self.$nicknameField, lineLimit: 1, fontDesign: .rounded)
                    
                    Divider().padding(.vertical, 8)
                    
                    self.userInput(keyboard: .emailAddress, message: "Email: ", placeholder: "username@email.com", textfield: self.$emailField, lineLimit: 1, fontDesign: .monospaced)
                    
                    self.userInput(keyboard: .default, message: "Password: ", placeholder: "**********", textfield: self.$passwordField, lineLimit: 1, fontDesign: .monospaced)
                    
                }.padding(2)
                
                Divider().padding(.vertical, 8)
                Spacer()
                
                
                VStack(alignment: .center, spacing: 0) {
                    
                    Text( (self.fnameField.isEmpty || self.lnameField.isEmpty ||
                        self.emailField.isEmpty || self.passwordField.isEmpty) ? "Please provide all the information" : "\(self.debugText)")
                        .font(.headline)
                        .foregroundColor( (self.fnameField.isEmpty || self.lnameField.isEmpty ||
                            self.emailField.isEmpty || self.passwordField.isEmpty) ? .secondary : .accentColor)
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .padding()
                    
                    Divider()
                    
                    Button(action: {
                        print("Signup Button Tapped!")
                        
                        // MARK: Sign up new user info to cloud
                        self.uploadUser()
                        
                    }) { RoundedButton(text: "Create Profile") }
                        .padding()
                        .disabled( (self.fnameField.isEmpty || self.lnameField.isEmpty ||
                            self.emailField.isEmpty || self.passwordField.isEmpty) )
                    
                }
            }
            
        }
        .alert(isPresented: self.$showingAlert, content: { self.invalidDataEntryAlert })
        .onTapGesture { self.endEditing(true) }
    }
    
    var invalidDataEntryAlert: Alert {
        
        return Alert(
            title: Text("Profile Created"),
            message: Text("Account created for email: \(self.emailField) and password: \(self.passwordField)"),
            dismissButton: .cancel(
                Text("Dismiss").foregroundColor(.red),
                action: {self.showingAlert.toggle(); self.showModal.toggle()}
            ))
    }
    
    private func uploadUser() {
        
        self.debugText = ""
        
        guard let validCreateNewUserURL:URL = URL(string: createNewUserURLString) else { return }
        
        guard let uploadUserData = User(firstname: self.fnameField, lastname: self.lnameField, nickname:
            self.nicknameField, email: self.emailField, password: self.passwordField).encodeToJSON() else { self.debugText = "Can't encode data to JSON"; return }
        
        let validCreateNewUserURLRequest = getPostRequest(from: validCreateNewUserURL, of: uploadUserData)
        
        let task = appSession.dataTask(with: validCreateNewUserURLRequest, completionHandler: {
            (d, r, e) in
            
            guard let queryResult: String = getStringJSONData(d, r, e, key: "result") else { self.debugText = "Can't connect to server!"; return }
            
            if queryResult == "success" {
                self.debugText = "Success."
                self.showingAlert.toggle()
                
            } else if queryResult == "fail" {
                
                self.debugText = "Can't create user, because "
                
                guard let queryError: String = getStringJSONData(d, r, e, key: "errors") else { self.debugText += "queryError: invalid..."; return }
                
                self.debugText += "\(queryError)."
                
            }
        })
        
        task.resume()
    }
    
    private func endEditing(_ force: Bool) {
        UIApplication.shared.endEditing()
    }
    
    private func userInput(keyboard keyboardDataType: UIKeyboardType = .default, message txt_msg:String="Text Message:", placeholder tf_msg:String="Placeholder Message", textfield tfTextBinding:Binding<String>, lineLimit:Int = 1, fontDesign:Font.Design = .monospaced, padding: CGFloat = 14.0) -> some View {
        
        
        HStack(spacing: 0) {
            
            if txt_msg != "" {
                Text(txt_msg)
                    .font(.system(size: 15))
                    .bold()
                    .lineLimit(1)
                
                Spacer()
            }
            
            TextField(tf_msg, text: tfTextBinding, onEditingChanged: { _ in
                
                tfTextBinding.wrappedValue = tfTextBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
            }) {
                self.endEditing(true)
            }
            .frame(width: UIScreen.main.bounds.width * 0.65, height: 20*CGFloat(lineLimit))
            .lineLimit(lineLimit)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(size: 15, design: fontDesign))
            .keyboardType(keyboardDataType)
            
        }
        .padding(padding)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showModal: .constant(true))
            .previewDevice("iPhone XS")
    }
}
