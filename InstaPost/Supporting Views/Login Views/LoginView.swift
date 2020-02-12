//
//  LoginView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/22/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @State var emailField: String = ""
    @State var passwordField: String = ""
    
    @Binding var userValidated: Bool
    @Binding var loggedInUserCredentials: UserCredentials
    
    @State var showingModal: Bool = false
    @State var showingAlert: Bool = false
    @State var alertMessage: String = ""
    
    var body: some View {
        
        NavigationView {
            
            Background {
                
                VStack {
                    
                    VStack {
                        
                        Divider()
                        
                        ScrollView{
                            
                            VStack(alignment: .center, spacing: 10) {
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    Text("Email").font(.title).bold()
                                        .padding(.horizontal, 15)
                                    
                                    self.userInput(keyboard: .emailAddress, message: "", placeholder: "username@email.com", textfield: self.$emailField, lineLimit: 1, fontDesign: .monospaced)
                                    
                                }.padding()
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    Text("Password:").font(.title).bold()
                                        .padding(.horizontal, 15)
                                    
                                    self.userInput(keyboard: .default, message: "", placeholder: "**********", textfield: self.$passwordField, lineLimit: 1, fontDesign: .monospaced, isSecure: true)
                                    
                                }.padding()
                            }
                        }
                        Spacer()
                        Divider()
                        
                        VStack(spacing: 16) {
                            
                            Button(action: {
                                print("Register Button Tapped!")
                                
                                // MARK: Register New User
                                self.showingModal.toggle()
                                
                            })
                            { RoundedButton(text: "New User? Register Here", color: Color(white: 0.96), foregroundColor: .accentColor) }
                            
                            
                            Button(action: {
                                print("Login Button Tapped!")
                                
                                // MARK: Authentic and Login
                                self.authenticateUser()
                                
                            }) { RoundedButton(text: "Login") }
                            
                        }
                        .padding(16)
                        
                    }
                    
                }
                .navigationBarTitle("Login")
                    
                .alert(isPresented: self.$showingAlert, content: { self.invalidDataEntryAlert })
                .sheet(isPresented: self.$showingModal) {
                    SignUpView(showModal: self.$showingModal,
                               emailField: self.emailField,
                               passwordField: self.passwordField)
                        .accentColor(.pink)
                        .navigationBarTitle("Register")
                }
                    
                .accentColor(.pink)
                .navigationViewStyle(DefaultNavigationViewStyle())
                
            }
            .onTapGesture { self.endEditing(true) }
            .onAppear {
                
                self.emailField = self.loggedInUserCredentials.email
                self.passwordField = self.loggedInUserCredentials.password
            }
            
        }
    }
    
    var invalidDataEntryAlert: Alert {
        
        return Alert(
            title: Text("Invalid Entry"),
            message: Text("\(self.alertMessage)"),
            dismissButton: .cancel(
                Text("Dismiss").foregroundColor(.red),
                action: {self.showingAlert.toggle()}
            ))
    }
    
    func raiseAlert(_ message: String) {
        
        self.alertMessage = message
        self.showingAlert = true
    }
    
    func authenticateUser() {
        
        self.alertMessage = ""
        if self.emailField.isEmpty || self.passwordField.isEmpty { self.raiseAlert("Email or Password can't be empty!"); return }
        
        let checkUserURLString = authenticateURLString + getCredentialURL(email: self.emailField, password: self.passwordField)
        
        guard let validCheckUserURL:URL = URL(string: checkUserURLString) else { return }
        
        let task = appSession.dataTask(with: validCheckUserURL, completionHandler: {
            (d, r, e) in
            
            self.userValidated = getBoolJSONData(d, r, e, key: "result")
            
            if self.userValidated { self.loggedInUserCredentials = UserCredentials(email: self.emailField, password: self.passwordField) } else { self.raiseAlert("Email or Password incorrect!"); }
        })
        
        task.resume()
    }
    
    private func endEditing(_ force: Bool) {
        UIApplication.shared.endEditing()
    }
    
    private func userInput(keyboard keyboardDataType: UIKeyboardType = .default, message txt_msg:String="Text Message:", placeholder tf_msg:String="Placeholder Message", textfield tfTextBinding:Binding<String>, lineLimit:Int = 1, fontDesign:Font.Design = .monospaced, isSecure: Bool = false) -> some View {
        
        
        HStack(spacing: 0) {
            
            if txt_msg != "" {
                Text(txt_msg)
                    .font(.body).bold()
                
                Spacer()
            }
            
            Group {
                
                if isSecure {
                    
                    SecureField(tf_msg, text: tfTextBinding) {
                        self.endEditing(true)
                        tfTextBinding.wrappedValue = tfTextBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 20*CGFloat(lineLimit))
                    .lineLimit(lineLimit)
                    .textContentType(.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 15, design: fontDesign))
                    .keyboardType(keyboardDataType)
                    
                } else {
                    
                    TextField(tf_msg, text: tfTextBinding, onEditingChanged: { _ in
                        
                        tfTextBinding.wrappedValue = tfTextBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                    }) { self.endEditing(true) }
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 20*CGFloat(lineLimit))
                        .lineLimit(lineLimit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 15, design: fontDesign))
                        .keyboardType(keyboardDataType)
                }
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userValidated: .constant(false), loggedInUserCredentials: .constant(UserCredentials()))
            .previewDevice("iPhone Xs")
    }
}
