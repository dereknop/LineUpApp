//
//  ContentView.swift
//  Lineup
//
//  Created by Devin Moon on 4/2/23.
//

import SwiftUI

struct ContentView: View {
    @State private var scene: Int = 0
    @StateObject var userController: UserController = UserController()
    var body: some View {
        NavigationView {
            VStack() {
                if scene == 0 { AuthView(scene: $scene)}
                
                if scene == 1 {
                    UserProfileView(
                        scene: $scene,
                        isPublic: userController.user?.isUserPublic ?? true
                    ).environmentObject(userController)
                }
                
                if scene == 2 { ProfileExploreView(scene: $scene).environmentObject(userController)}
                
                if scene == 3 {
                    BettingLogView(
                        scene: $scene,
                        focusList: [Bool](repeating: true, count: 100)
                    ).environmentObject(userController)
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
