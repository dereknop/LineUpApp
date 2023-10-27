//
//  LoginManager.swift
//  Lineup
//
//  Created by Derek Nopp on 4/6/23.
//

import SwiftUI
import FirebaseAuth
final class LoginManager {
    static let sharedManager = LoginManager()
    
    private init() {
        
    }
    
    // removes error warnings if we don't use returned
    @discardableResult
    func newUser(email: String, pass: String) async throws -> AuthResultModel {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: pass)
        return AuthResultModel(user: authResult.user)
    }
    
    //email password login
    @discardableResult
    func loginUser(email: String, pass: String) async throws -> AuthResultModel {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: pass)
        return AuthResultModel(user: authResult.user)
    }
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthResultModel{
        let credentials = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credentials: credentials)
    }
    
    // sign in with credential (google, apple, etc.)
    func signIn(credentials: AuthCredential) async throws -> AuthResultModel{
        let result = try await Auth.auth().signIn(with: credentials)
        return AuthResultModel(user: result.user)
    }
    
    func retrieveUser() throws -> AuthResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthResultModel(user: user)
    }
    
    func logOut() throws{
        try Auth.auth().signOut()
    }
    
    func deleteUser() {
        let authUser = Auth.auth().currentUser

        authUser?.delete { error in
          if let error = error {
            print(error)
          } else {
            print("user deleted")
          }
        }
    }
}

struct AuthResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init (user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}


