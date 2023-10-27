//
//  AuthView.swift
//  Lineup
//
//  Created by Derek Nopp on 4/6/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

@MainActor
final class AuthViewModel: ObservableObject {
    func signInGoogle() async throws {
        guard let topViewController = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let id = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: id, accessToken: accessToken)
        
        // auth result model
        let result = try await LoginManager.sharedManager.signInWithGoogle(tokens: tokens)
        
        // Beware of spooky spaghetti code below!!! Creates new user if not already in database, signs in normal otherwise
        let docRef = UserManager.shared.userCollection.document(result.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // user already exists
                return
            } else {
                // user does not already exist. make them an account
                Task {
                    do {
                        var user: DBUser = DBUser(auth: result)
                        user.username = user.email ?? ""
                        try await UserManager.shared.createNewUser(user: user)
                    } catch {
                        print("Error creating new account for google user")
                    }
                }
            }
        }
    }
}

struct AuthView: View {
    @StateObject private var authModel = AuthViewModel()
    @EnvironmentObject var userController: UserController
    @Binding var scene: Int
    
    var body: some View {
        VStack() {
            Spacer()
            
            Image("graphic")
                .resizable()
                .frame(width: 400, height: 400)
                .offset(x: 0, y: 20)
            
            Text("Welcome to")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 40, weight: .light))
                .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
            
            Text("Lineup")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
            
            NavigationLink {
                LoginView(scene: $scene)
            } label: {
                HStack() {
                    Image(systemName: "envelope.fill")
                    Text("Sign in with Email")
                        .padding([.leading], 10)
                }
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading], 10)
                .frame(height: 40)
                .background(
                    Rectangle()
                        .fill(Color(red: 30/255, green: 35/255, blue: 50/255))
                        .cornerRadius(2)
                        .shadow(
                            color: .black.opacity(1),
                            radius: 2,
                            x: 0,
                            y: 2
                        )
                )
                .padding([.bottom], 8)
            }
            
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .light,
                    style: .wide,
                    state: .normal
                )
            ) {
                Task {
                    do {
                        try await authModel.signInGoogle()
                        scene = 3
                    }
                    catch {
                        print(error)
                    }
                }
            }
            
            HStack() {
                Text("Don't have an account?")
                    .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                
                NavigationLink {
                    RegisterView(scene: $scene)
                } label: {
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                }
            }
            .padding([.top, .bottom], 50)
        }
        .padding()
        
    }
}

struct AuthViewContainer: View {
    @State private var scene: Int = 0

    var body: some View {
        AuthView(scene: $scene)
    }
}

struct AuthViewPreview: PreviewProvider {
    static var previews: some View {
        AuthViewContainer()
    }
}
