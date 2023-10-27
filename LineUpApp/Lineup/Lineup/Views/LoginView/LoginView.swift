//
//  LoginView.swift
//  Lineup
//
//  Created by Derek Nopp on 4/6/23.
//

import SwiftUI

@MainActor
final class LoginModel: ObservableObject {
    @Published var userEmail = ""
    @Published var password = ""
    @Published var username = ""
    @Published var firstName = ""
    @Published var lastName = ""
    
    func signUp() async throws {
        guard !password.isEmpty, !password.isEmpty else {
            print("Missing email or password")
            return
        }
        let result = try await LoginManager.sharedManager.newUser(email: userEmail, pass: password)
        var user: DBUser = DBUser(auth: result)
        user.username = username
        user.firstName = firstName
        user.lastName = lastName
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        guard !password.isEmpty, !password.isEmpty else {
            print("Missing email or password")
            return
        }
        try await LoginManager.sharedManager.loginUser(email: userEmail, pass: password)
    }
    
}

struct LoginView: View {
    @EnvironmentObject var userController: UserController
    @StateObject private var loginModel = LoginModel()
    @State var signInError: Bool = false
    @State var signInErrorDescription: String = ""
    @Binding var scene: Int
    var body: some View {
        VStack {
            TextField("Enter Email", text: $loginModel.userEmail)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            SecureField("Enter Password", text: $loginModel.password)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            Button {
                Task {
                    do {
                        // Try to register new user
                        try await loginModel.signIn()
                        scene = 3
                        return
                    } catch {
                        signInErrorDescription = error.localizedDescription
                        signInError = true
                    }
                }
            } label: {
                Text("SIGN IN")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                    .cornerRadius(5)
                    .padding([.top])
            }
            .alert(signInErrorDescription, isPresented: $signInError, actions: {})
            Spacer()
        }
        .padding()
        .navigationTitle("Email Sign In")
    }
}
