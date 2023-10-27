//
//  RegisterView.swift
//  Lineup
//
//  Created by Derek Nopp on 5/1/23.
//

import SwiftUI
struct RegisterView: View {
    @StateObject private var loginModel = LoginModel()
    @EnvironmentObject var userController: UserController
    @Binding var scene: Int
    @State private var registerErrorDescription: String = ""
    @State private var confirmPass: String = ""
    @State private var passwordError: Bool = false
    @State private var registerError: Bool = false
    
    func validateInput() -> Bool {
        if confirmPass == loginModel.password {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack {
            TextField("Enter Email", text: $loginModel.userEmail)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            TextField("Enter First Name", text: $loginModel.firstName)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            TextField("Enter Last Name", text: $loginModel.lastName)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            TextField("Enter Username", text: $loginModel.username)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            SecureField("Enter Password", text: $loginModel.password)
                .textContentType(nil)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            SecureField("Confirm Password", text: $confirmPass)
                .textContentType(nil)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            Button {
                Task {
                    if (validateInput()) {
                        do {
                            // Try to register new user
                            try await loginModel.signUp()
                            scene = 3
                            return
                        } catch {
                            registerError = true
                            registerErrorDescription = error.localizedDescription
                        }
                    } else {
                        passwordError = true
                    }
                }
            } label: {
                Text("SIGN UP")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                    .cornerRadius(5)
                    .padding([.top])
            }
            .alert("Passwords don't match", isPresented: $passwordError, actions: {})
            .alert(registerErrorDescription, isPresented: $registerError, actions: {})
            Spacer()
        }
        .padding()
        .navigationTitle("Email Sign Up")
    }
}
