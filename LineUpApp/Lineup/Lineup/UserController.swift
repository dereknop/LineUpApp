//
//  UserController.swift
//  Lineup
//
//  Created by Derek Nopp on 4/27/23.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
@MainActor
final class UserController: ObservableObject {
    
    @Published var user: DBUser? = nil
    @Published var allBets: [Bet] = []
    @Published var allUserBets: [Bet] = []
    @Published var allPublicUsers: [DBUser] = []
    @Published var following: [DBUser] = []
    @Published var favoriteBet: Bet? = nil
    @Published var likes: [String] = []
    @Published var profilePic: UIImage?
    
    func clearAll() {
        self.user = nil
        self.allBets = []
        self.allUserBets = []
        self.following = []
        self.favoriteBet = nil
        self.likes = []
        self.profilePic = nil
    }
    
    func getPublicUsers() async throws {
        guard user != nil else { return }
        self.allPublicUsers = try await UserManager.shared.getAllPublicUsers()
    }
    
    func getFriends() async throws {
        guard let user else { return }
        self.following = []
        for follow in user.following {
            try await self.following.append(UserManager.shared.getUser(userId: follow))
        }
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try LoginManager.sharedManager.retrieveUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func getAllBets() async throws {
        guard user != nil else { return }
        
        self.allBets = try await UserManager.shared.allBets().sorted(by: { $0.betCreated > $1.betCreated })
    }
    
    func logOut() throws {
        try LoginManager.sharedManager.logOut()
    }
    
    func addBet(bet: Bet) async throws {
        guard let user else { return }
        
        try await UserManager.shared.storeBet(bet: bet, user: user)
        try await getAllBets()
    }
    
    func addBetsListener() {
        UserManager.shared.addListenerForUserBets { bets in
            self.allBets = bets
        }
    }
    
    func getAllUserBets() async throws {
        guard let user else { return }
        
        self.allUserBets = try await UserManager.shared.allUserBets(userId: user.userId)
    }
    
    func selectUsersBets(userId: String) async throws -> [Bet] {
        return try await UserManager.shared.allUserBets(userId: userId)
    }
    
    func getUserBet(betId: String) async throws -> Bet {
        return try await UserManager.shared.retrieveBet(betId: betId)
    }
    
    func toggleLikeToBet(betId: String) async throws {
        guard let user else { return }
        return try await UserManager.shared.toggleLikeToBet(betId: betId, userId: user.userId)
    }
    
    func toggleUserPrivacy() async throws {
        guard let user else { return }
        try await UserManager.shared.toggleUserPrivacy(user: user)
        try await loadCurrentUser()
    }
    
    func changeUsername(username: String) async throws {
        guard let user else { return }
        try await UserManager.shared.changeUsername(userId: user.userId, username: username)
        try await loadCurrentUser()
    }
    
    func deleteUser(userId: String) {
        UserManager.shared.deleteUser(userId: userId)
    }
    
    func deleteAllUserBets(userId: String) async throws {
        try await UserManager.shared.deleteAllUserBets(userId: userId)
    }
    
    func removeFollowing(userId: String) async throws {
        try await UserManager.shared.removeFollowing(userId: userId)
    }
    
    func removeUserLikes(userId: String) async throws {
        try await UserManager.shared.removeUserLikes(userId: userId)
    }
    
    func followUser(followId: String) async throws {
        guard let user else { return }
        try await UserManager.shared.followByUserId(userId: user.userId, followId: followId)
    }
    
    func unfollow(followId: String) async throws {
        guard let user else { return }
        try await UserManager.shared.unfollowByUserId(userId: user.userId, followId: followId)
    }
    
    func setFavoriteBet(betId: String) async throws {
        guard let user else { return }
        try await UserManager.shared.setFavoriteBet(betId: betId, userId: user.userId)
        try await loadFavoriteBet()
    }
    
    func loadFavoriteBet() async throws {
        guard let user else { return }
        if (user.favoriteBet != "") {
            favoriteBet = try await getUserBet(betId: user.favoriteBet)
        } else {
            favoriteBet = nil
        }
    }
    
    func setProfilePic() async throws {
        guard let user else { return }
        try await UserManager.shared.setProfilePic(userId: user.userId)
    }
    
    func uploadProfilePic(selectedImage: UIImage?) {
        // image selected check
        guard (selectedImage != nil && user != nil) else { return }
        
        // reference to firebast storage
        let storageRef = Storage.storage().reference()
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // selected image converts to jpeg successfully
        guard imageData != nil else { return }
        
        // directory of profile pictures
        let path = "profile_pictures/\(user!.userId).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!) { metaData, error in
            if error == nil && metaData != nil {
                let db = Firestore.firestore()
                db.collection("users").document(self.user!.userId).updateData(["profilePic":path])
            }
        }
    }
    
    func retrieveProfilePic() async throws {
        guard user != nil else { return }
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(user!.profilePic)
        
        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil && data != nil{
                self.profilePic = UIImage(data: data!)
            } else {
                self.profilePic = nil
            }
        }
    }
}
