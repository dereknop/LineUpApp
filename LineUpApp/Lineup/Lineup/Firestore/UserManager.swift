//
//  UserManager.swift
//  Lineup
//
//  Created by Derek Nopp on 4/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine
struct DBUser: Codable {
    
    let userId: String
    let dateCreated: Date?
    let email: String?
    let photoUrl: String?
    var wins: Int
    var losses: Int
    var totalWagered: Double
    var totalPayouts: Double
    var netTotal: Double
    // array of betId's we can use to pull that users bets from the all-bets collection
    var userBets: [String]
    var following: [String]
    var followers: [String]
    var favoriteBet: String
    var isUserPublic: Bool
    var username: String
    var firstName: String
    var lastName: String
    var likes: [String]
    var profilePic: String
    
    // init just using auth model, initial state of a brand new user
    init(auth: AuthResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.wins = 0
        self.losses = 0
        self.totalWagered = 0
        self.totalPayouts = 0
        self.netTotal = 0
        self.userBets = []
        self.following = []
        self.followers = []
        self.favoriteBet = ""
        self.isUserPublic = true
        self.username = ""
        self.firstName = ""
        self.lastName = ""
        self.likes = []
        self.profilePic = "profile_pictures/default.png"
    }
}

final class UserManager {
    
    static let shared = UserManager()
    
    private init() {}
    
    let userCollection = Firestore.firestore().collection("users")
    
    let betCollection = Firestore.firestore().collection("all-bets")
    
    private func userDocument (userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func deleteUser(userId: String) {
        
        LoginManager.sharedManager.deleteUser()
        
        userDocument(userId: userId).delete() { err in
            if let err = err {
                print("error removing document \(err)")
            } else {
                print("Document successfully removed")
            }
            
        }
    }
    
    func removeUserLikes(userId: String) async throws {
        let user = try await getUser(userId: userId)
        for like in user.likes {
            try await toggleLikeToBet(betId: like, userId: userId)
        }
    }
    
    func removeFollowing(userId: String) async throws {
        let user = try await getUser(userId: userId)
        // remove all following
        for following in user.following {
            try await unfollowByUserId(userId: userId, followId: following)
        }
        // remove all followers
        for followers in user.followers {
            try await unfollowByUserId(userId: followers, followId: userId)
        }
    }
    
    func deleteAllUserBets(userId: String) async throws {
        let user = try await getUser(userId: userId)
        for bet in user.userBets {
            deleteBet(userId: userId, betId: bet)
        }
    }
    
    // swift says this does not need to be try await... idk
    func deleteBet(userId: String, betId: String) {
        betCollection.document(betId).delete() { err in
            if err != nil {
                print("Error deleting bet")
            }
        }
        /*
        try await userDocument(userId: userId).updateData([
            "userBets" : FieldValue.arrayRemove([betId])
        ])*/
    }
    
    func getUser(userId: String) async throws -> DBUser {
        return try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func getAllPublicUsers() async throws -> [DBUser] {
        return try await userCollection.whereField("isUserPublic", isEqualTo: true).getDocuments(as: DBUser.self)
    }
    
    func toggleUserPrivacy(user: DBUser) async throws {
        let toggled = !user.isUserPublic
        print(toggled)
        try await userDocument(userId: user.userId).updateData([
            "isUserPublic" : toggled
        ])
    }
    
    func setProfilePic(userId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "profilePic" : userId
        ])
    }
    
    func changeUsername(userId: String, username: String) async throws {
        try await userDocument(userId: userId).updateData([
            "username" : username
        ])
    }
    
    func followByUserId(userId: String, followId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "following": FieldValue.arrayUnion([followId])
        ])
        try await userDocument(userId: followId).updateData([
            "followers": FieldValue.arrayUnion([userId])
        ])
    }
    
    func unfollowByUserId(userId: String, followId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "following" : FieldValue.arrayRemove([followId])
        ])
        try await userDocument(userId: followId).updateData([
            "followers" : FieldValue.arrayRemove([userId])
        ])
    }
    
    func storeWins(userId: String, wins: Int) async throws {
        let data: [String:Any] = [
            "wins" : wins
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func storeLosses(userId: String, losses: Int) async throws {
        let data: [String:Any] = [
            "losses" : losses
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    // any time one is updated, all three should be so I put these together
    
    func storeFinancials(userId: String, wagered: Double, payouts: Double, net: Double) async throws {
        let data: [String:Any] = [
            "netTotal" : net,
            "totalPayouts" : payouts,
            "totalWagered" : wagered
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    // all-bets collection
    func storeBet(bet: Bet, user: DBUser) async throws {
        // generate new document
        let ref = betCollection.document()
        // grab id
        let id = ref.documentID
        var betCopy = bet
        betCopy.id = id
        
        // set data in all-bets collection
        try ref.setData(from: betCopy,  merge: false)
        try await storeBetToUser(betId: id, userId: user.userId)
    }
    
    // add to specific user document's user_bets array
    func storeBetToUser(betId: String, userId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "userBets": FieldValue.arrayUnion([betId])
        ])
    }
    
    // set favorite/bookmarked bet
    func setFavoriteBet(betId: String, userId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "favoriteBet" : betId
        ])
    }
    
    // If user has already liked bet, remove like. If no like, add user as a like to bet
    func toggleLikeToBet(betId: String, userId: String) async throws {
        let bet = try await retrieveBet(betId: betId)
        if bet.likes.contains(userId) {
            try await betCollection.document(betId).updateData([
                "likes" : FieldValue.arrayRemove([userId])
            ])
            try await removeLike(betId: betId, userId: userId)
        } else {
            try await betCollection.document(betId).updateData([
                "likes" : FieldValue.arrayUnion([userId])
            ])
            try await addLike(betId: betId, userId: userId)
        }
    }
    
    func removeLike(betId: String, userId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "likes" : FieldValue.arrayRemove([betId])
        ])
    }
    
    func addLike(betId: String, userId: String) async throws {
        try await userDocument(userId: userId).updateData([
            "likes" : FieldValue.arrayUnion([betId])
        ])
    }
    
    // get bet data by betId
    func retrieveBet(betId: String) async throws -> Bet {
        return try await betCollection.document(betId).getDocument(as: Bet.self)
    }
    
    func allBets() async throws -> [Bet] {
        return try await betCollection
            .order(by: "date")
            .getDocuments(as: Bet.self)
    }
    
    func allUserBets(userId: String) async throws -> [Bet] {
        return try await betCollection.whereField("userId", isEqualTo: userId).getDocuments(as: Bet.self)
    }
    
    func addListenerForUserBets(completion: @escaping (_ bets: [Bet]) -> Void) {
        betCollection.addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            let bets: [Bet] = document.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: Bet.self)
            }
            completion(bets)
            
            querySnapshot?.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            print("New Bet: \(diff.document.data())")
                        }
                        if (diff.type == .modified) {
                            print("Modified bet: \(diff.document.data())")
                        }
                        if (diff.type == .removed) {
                            print("Removed bet: \(diff.document.data())")
                        }
                    }
            
        }
    }
    
    func deactivateAccount(userId: String, completion: @escaping () -> Void) {
        userDocument(userId: userId).setData(["isActive" : false], merge: true) { error in
            if error == nil {
                completion()
            } else {
                
            }
        }
    }
    
}

/*
 * Quality of life extensions to make calls easier. Ultra condensed mega big brain getDocuments query
 */

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ document in
            return try document.data(as: T.self)
        })
        
    }
}
