//
//  UserProfileView.swift
//  Lineup
//
//  Created by Devin Moon on 4/1/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
struct UserProfileView: View {
    @Binding public var scene: Int
    @State private var betSelection: String = "all"
    @EnvironmentObject var userController: UserController
    @State var isPublic: Bool
    @State var showSettings = false
    @State var showImagePicker = false
    @State var selectedImage: UIImage?
    
    var body: some View {
        ScrollView() {
            VStack() {
                ZStack() {
                    Rectangle()
                        .fill(Color(red: 30/255, green: 35/255, blue: 50/255))
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                        .frame(height: 225)
                        .offset(x:0, y: -60)
                    
                    Button(action: { scene = 3 }) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .padding([.leading, .trailing], 11)
                    .padding([.top, .bottom], 10)
                    .foregroundColor(.white)
                    .bold()
                    .position(x: 70, y: 25)
                    
                    Button(action: { showSettings = true }) {
                        Text("Settings")
                        Image(systemName: "gearshape")
                    }
                    .fullScreenCover(
                        isPresented: $showSettings,
                        content: { SettingsView(showSettings: $showSettings, scene: $scene, isPublic: userController.user?.isUserPublic ?? true).environmentObject(userController) }
                    )
                    .padding([.leading, .trailing], 11)
                    .padding([.top, .bottom], 10)
                    .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .bold()
                    .position(x: 310, y: 25)
                    
                    VStack(spacing: 0) {
                        Button(action: { showImagePicker = true}) {
                            VStack() {
                                if (userController.user != nil && userController.profilePic != nil && selectedImage == nil) {
                                    Image(uiImage: userController.profilePic!)
                                        .resizable()
                                        .cornerRadius(100)
                                        .padding(5)
                                        .frame(width: 100, height: 100)
                                        .background(.white)
                                        .cornerRadius(100)
                                } else {
                                    // need an extra check because it was crashing on logout
                                    if (selectedImage != nil) {
                                        Image(uiImage: selectedImage!)
                                            .resizable()
                                            .cornerRadius(100)
                                            .padding(5)
                                            .frame(width: 100, height: 100)
                                            .background(.white)
                                            .cornerRadius(100)
                                    }
                                }
        
                                HStack() {
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .background(
                                            Rectangle()
                                                .fill(Color(red: 30/255, green: 35/255, blue: 50/255))
                                                .cornerRadius(100)
                                                .frame(width: 10, height: 10)
                                        )
                                        .shadow(
                                            color: .black.opacity(0.2),
                                            radius: 1,
                                            x: 1,
                                            y: 1
                                        )
                                }
                                .frame(width: 100)
                                .foregroundColor(.white)
                                .offset(x: -10, y: -30)
                            }
                        }.sheet(isPresented: $showImagePicker, onDismiss: {
                            if selectedImage != nil {
                                userController.uploadProfilePic(selectedImage: selectedImage)
                                Task {
                                    try await userController.retrieveProfilePic()
                                }
                            }
                        }) {
                            ImagePicker(selectedImage: $selectedImage, showImagePicker: $showImagePicker)
                        }
                        
                        if let user = userController.user {
                            Text("\(user.username)")
                                .font(.title)
                                .bold()
                                .padding([.top], 5)
                            Text("\(user.firstName) \(String(user.lastName))")
                                .font(.subheadline)
                                .italic()
                            HStack {
                                Text("Followers: \(user.followers.count)")
                                    .font(.subheadline)
                                    .italic()
                                Text("Following: \(user.following.count)")
                                    .font(.subheadline)
                                    .italic()
                            }
                        }
                    }
                    .frame(width: 300, height: 200)
                    .offset(x: 0, y: 75)
                }
                
                Picker("Select: ", selection: $betSelection) {
                    Text("All").tag("all")
                    Text("Favorite").tag("favorite")
                }
                .padding([.top], 45)
                .padding()
                .pickerStyle(.segmented)
                
                if (betSelection == "all") {
                    VStack(spacing: 50) {
                        ForEach(userController.allUserBets) {bet in
                            SingleBetView(bet: bet, liked: bet.likes.contains(userController.user?.userId ?? ""))
                                .environmentObject(userController)
                        }
                    }
                    .offset(x: 0, y: -10)
                    .scaleEffect(x: 0.9, y: 0.9)
                } else if (betSelection == "favorite") {
                    VStack(spacing: 50) {
                        if let bet = userController.favoriteBet {
                            SingleBetView(bet: bet, liked: bet.likes.contains(userController.user?.userId ?? ""))
                                .environmentObject(userController)
                        } else if userController.user?.favoriteBet != "" {
                            Text("Loading...")
                        } else {
                            Text("No Favorite Bet")
                        }
                    }
                    .offset(x: 0, y: -10)
                    .scaleEffect(x: 0.9, y: 0.9)
                    .task {
                        try? await userController.loadFavoriteBet()
                    }
                }
            }
        }
        .task {
            selectedImage = nil
            try? await userController.loadCurrentUser()
            try? await userController.retrieveProfilePic()
            try? await userController.getAllUserBets()
            try? await userController.loadFavoriteBet()
            try? await userController.getAllBets()
        }
    }
}
