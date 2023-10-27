//
//  UserProfileView.swift
//  Lineup
//
//  Created by Devin Moon on 4/1/23.
//

import SwiftUI
import FirebaseStorage
struct OtherUserView: View {
    @Binding public var showUser: Bool
    @Binding var user: DBUser
    @State private var betSelection: String = "all"
    @State var isFriend: Bool
    @EnvironmentObject var userController: UserController
    @State private var userBets: [Bet] = []
    @State var userFavoriteBet: Bet? = nil
    @State var profilePic: UIImage?
    
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
                    
                    Button(action: { showUser = false }) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .padding([.leading, .trailing], 11)
                    .padding([.top, .bottom], 10)
                    .foregroundColor(.white)
                    .bold()
                    .position(x: 70, y: 25)
                    
                    Button(action: {
                        if (!isFriend) {
                            Task {
                                try await userController.followUser(followId: user.userId)
                                try await user = UserManager.shared.getUser(userId: user.userId)
                                try await userController.loadCurrentUser()
                            }
                        } else {
                            Task {
                                try await userController.unfollow(followId: user.userId)
                                try await user = UserManager.shared.getUser(userId: user.userId)
                                try await userController.loadCurrentUser()
                            }
                        }
                        isFriend = !isFriend
                    }) {
                        Text(isFriend ? "Remove" : "Add")
                        Image(systemName: isFriend ? "person.fill.badge.minus" : "person.fill.badge.plus")
                    }
                    .padding([.leading, .trailing], 11)
                    .padding([.top, .bottom], 10)
                    .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .bold()
                    .position(x: 310, y: 25)
                    
                    VStack(spacing: 0) {
                        if (profilePic != nil) {
                            Image(uiImage: profilePic!)
                                .resizable()
                                .cornerRadius(100)
                                .padding(5)
                                .frame(width: 100, height: 100)
                                .background(.white)
                                .cornerRadius(100)
                        }
                        
                        Text("\(user.username)")
                            .font(.title)
                            .bold()
                            .padding([.top], 5)
                        Text("\(user.firstName) \(user.lastName)")
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
                        ForEach(0..<userBets.count, id:\.self) {i in
                            SingleBetView(bet: userBets[i], liked: userBets[i].likes.contains(userController.user?.userId ?? ""))
                                .environmentObject(userController)
                        }
                    }
                    .offset(x: 0, y: -10)
                    .scaleEffect(x: 0.9, y: 0.9)
                } else if (betSelection == "favorite") {
                    VStack(spacing: 50) {
                        if let bet = userFavoriteBet {
                            SingleBetView(bet: bet, liked: bet.likes.contains(userController.user?.userId ?? ""))
                                .environmentObject(userController)
                        } else {
                            Text("No Favorite Bet")
                        }
                    }
                    .offset(x: 0, y: -10)
                    .scaleEffect(x: 0.9, y: 0.9)
                }
            }
        }
        .task {
            try? await userController.loadCurrentUser()
            try? await userBets = userController.selectUsersBets(userId: user.userId)
            try? await getProfilePic()
            if (user.favoriteBet != "") {
                try? await userFavoriteBet = userController.getUserBet(betId: user.favoriteBet)
            }
        }
    }
    
    
    func getProfilePic() async throws {
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(user.profilePic)
        
        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil && data != nil{
                self.profilePic = UIImage(data: data!)
            } else {
                self.profilePic = nil
            }
        }
    }
}
