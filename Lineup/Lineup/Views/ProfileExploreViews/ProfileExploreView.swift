//
//  ProfileSearchView.swift
//  Lineup
//
//  Created by Devin Moon on 4/1/23.
//

import SwiftUI
struct ProfileExploreView: View {
    @Binding public var scene: Int
    @State var selection: String = "everyone"
    @EnvironmentObject var userController: UserController
    var body: some View {
        ScrollView () {
            Button(action: { scene = 3 }) {
                Image(systemName: "arrow.left")
                Text("Back")
            }
            .padding([.leading, .trailing], 11)
            .padding([.top], 10)
            .cornerRadius(20)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(Color(red: 50/255, green: 55/255, blue: 70/255))
            .bold()
            
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    Text("Explore")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 40, weight: .heavy))
                    
                    Text("See what people are betting on.")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                }
                .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                .padding()
                
                Picker("Select: ", selection: $selection) {
                    Text("Everyone").tag("everyone")
                    Text("My Friends").tag("friends")
                }
                .padding(.horizontal)
                .pickerStyle(.segmented)
                
                
                if (selection == "everyone") {
                    VStack(spacing: 20) {
                        ForEach(0..<userController.allPublicUsers.count, id:\.self) {i in
                            if (userController.user?.userId != userController.allPublicUsers[i].userId) {
                                ProfileResultView(user: $userController.allPublicUsers[i]).environmentObject(userController)
                            }
                        }
                    }
                    .padding()
                } else if (selection == "friends") {
                    VStack(spacing: 20) {
                        ForEach(0..<userController.following.count, id: \.self) { i in
                            ProfileResultView(user: $userController.following[i]).environmentObject(userController)
                        }
                    }
                    .padding()
                }
            }
        }.task {
            try? await userController.getPublicUsers()
            try? await userController.getFriends()
            try? await userController.getAllBets()
        }
    }
}

struct ProfileExploreView_PreviewContainer: View {
    @State private var scene: Int = 1
    
    var body: some View {
        ProfileExploreView(scene: $scene)
    }
}

struct ProfileExploreView_Preview: PreviewProvider {
    static var previews: some View {
        ProfileExploreView_PreviewContainer()
    }
}
