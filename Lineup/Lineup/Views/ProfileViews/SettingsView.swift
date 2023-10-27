//
//  SettingsView.swift
//  Lineup
//
//  Created by Devin Moon on 5/4/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @Binding var scene: Int
    @EnvironmentObject var userController: UserController
    @State var showChangeUsername = false
    @State var isPublic: Bool
    @State var showDeleteAlert = false
    @State var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { showSettings = false }) {
                Image(systemName: "arrow.left")
                Text("Back")
            }
            .padding([.leading])
            .bold()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding([.top, .bottom])
            
            Text("Settings")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.white)
                .padding([.top])
            
            VStack(spacing: 25) {
                Text("Account Info")
                    .font(.title2)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Button(action: { showChangeUsername = true}) {
                    Image(systemName: "person.fill")
                    Text("Change Username")
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 8, height: 15)
                }
                .fullScreenCover(
                    isPresented: $showChangeUsername,
                    content: { ChangeUsernameView(showChangeUsername: $showChangeUsername).environmentObject(userController) }
                )
                
                Button(action: { showDeleteAlert = true }) {
                    HStack() {
                        Image(systemName: "minus.circle.fill")
                        Text("Delete Account")
                        Spacer()
                    }
                }
                .alert(
                    isPresented: $showDeleteAlert,
                    content: {
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("Do you really want to delete your account and all of your data? (Action cannot be undone.)"),
                            primaryButton: .destructive(Text("Yes"), action: {
                                Task {
                                    if let user = userController.user {
                                        try await userController.removeUserLikes(userId: user.userId)
                                        try await userController.removeFollowing(userId: user.userId)
                                        try await userController.deleteAllUserBets(userId: user.userId)
                                        userController.deleteUser(userId: user.userId)
                                        userController.clearAll()
                                        scene = 0
                                    }
                                }
                            }),
                            secondaryButton: .default(Text("No"))
                        )
                    }
                )
            }
            .padding()
            .padding([.bottom])
            .background(Color(red: 50/255, green: 55/255, blue: 70/255))
            .cornerRadius(10)
            
            VStack(spacing: 25) {
                Text("Privacy Settings")
                    .font(.title2)
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                HStack() {
                    Image(systemName: "person.2.fill")
                    
                    Toggle("Public Account", isOn: $isPublic)
                        .onChange(of: isPublic) { newValue in
                            Task {
                                try await userController.toggleUserPrivacy()
                                try await userController.loadCurrentUser()
                            }
                        }
                        .frame(height: 15)
                    
                }
                
                Button(action: { showLogoutAlert = true }) {
                    HStack() {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        Text(" Logout")
                        Spacer()
                    }
                }
                .alert(
                    isPresented: $showLogoutAlert,
                    content: {
                        Alert(
                            title: Text("Logout?"),
                            message: Text("Do you want to logout?"),
                            primaryButton: .destructive(Text("Yes"), action: {
                                Task {
                                    try userController.logOut()
                                    userController.clearAll()
                                    scene = 0
                                }
                            }),
                            secondaryButton: .default(Text("No"))
                        )
                    }
                )
                
            }
            .padding()
            .padding([.bottom])
            .background(Color(red: 50/255, green: 55/255, blue: 70/255))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .background(Color(red: 30/255, green: 35/255, blue: 50/255))
    }
}
/*
 struct SettingsViewContainer: View {
 @State private var showSettings = true
 
 var body: some View {
 SettingsView(showSettings: $showSettings)
 }
 }
 
 struct SettingsViewPreview: PreviewProvider {
 static var previews: some View {
 SettingsViewContainer()
 }
 }
 */
