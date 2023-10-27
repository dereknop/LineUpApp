//
//  AllBetsView.swift
//  Lineup
//
//  Created by Devin Moon on 3/31/23.
//

import SwiftUI

struct BettingLogView: View {
    @Environment(\.displayScale) var displayScale
    @Binding public var scene: Int
    @EnvironmentObject var userController: UserController
    @State private var isFocused: Bool = false
    @State private var showAddBet: Bool = false
    @State public var focusList: [Bool]
    @State private var didAppear: Bool = false
    
    
    @MainActor func getImage() {
        for i in 0...focusList.count - 1 {
            if focusList[i] {
                let renderer = ImageRenderer(content: SingleBetView(bet: userController.allBets[i], liked: userController.allBets[i].likes.contains(userController.user?.userId ?? "")))
                renderer.scale = displayScale

                UIImageWriteToSavedPhotosAlbum(renderer.uiImage!, nil, nil, nil)
            }
        }
    }
    
    private func setFocus(_ focusedElement: Int) {
        isFocused = !isFocused
        
        for i in 0...focusList.count - 1 {
            focusList[i] = i == focusedElement || !isFocused
        }
    }
    
    private func resetFocus() {
        isFocused = false
        focusList = [Bool](repeating: true, count: userController.allBets.count)
    }
    
    var body: some View {
        ZStack() {
            ScrollView() {
                ZStack() {
                    HStack {
                        Button(action: { scene = 1 }) {
                            if (userController.user != nil && userController.profilePic != nil) {
                                Image(uiImage: userController.profilePic!)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(100)
                            }
                        }
                        .padding([.top], 40)
                        .padding([.leading], 20)
                        .disabled(isFocused)
                        .foregroundColor(.white)
                        .bold()
                        
                        Button(action: { scene = 2 }) {
                            Text("Explore")
                            Image(systemName: "circle.hexagongrid.fill")
                        }
                        .padding([.leading, .trailing], 11)
                        .padding([.top, .bottom], 10)
                        .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                        .cornerRadius(20)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 40)
                        .padding([.leading], 10)
                        .disabled(isFocused)
                        .foregroundColor(.white)
                        .bold()
                    }
                    .zIndex(2)
                    .frame(height: 150)
                    .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                    .brightness(isFocused ? -0.5 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                    .position(x: 200, y: 10)
                    
                    VStack(spacing: 5) {
                        Text("Lineup")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                        Text("Let's see what bets are hot.")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding([.leading, .trailing])
                    .background(
                        Rectangle()
                            .fill(Color(red: 30/255, green: 35/255, blue: 50/255))
                            .cornerRadius(10)
                            .shadow(
                                color: .black.opacity(0.3),
                                radius: 6,
                                x: 0,
                                y: 3
                            )
                            .frame(width: 395, height: 450)
                    )
                    .zIndex(1)
                    .brightness(isFocused ? -0.5 : 0)
                    .position(x: 196, y: 150)
                    
                    VStack(spacing: 50) {
                        ForEach(userController.allBets) {bet in
                            SingleBetView(bet: bet, liked: bet.likes.contains(userController.user?.userId ?? ""))
                                .brightness(focusList[userController.allBets.firstIndex(of: bet)!] ? 0 : -0.5)
                                .animation(.easeInOut(duration: 0.2), value: isFocused)
                                .onTapGesture(perform: { setFocus(userController.allBets.firstIndex(of: bet)!) })
                                .environmentObject(userController)
                        }
                    }
                    .zIndex(3)
                    .padding([.top], 210)
                    .padding()
                }
                .background(isFocused ? Color(red: 150/255, green: 150/255, blue: 150/255) : .white)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .onTapGesture(perform: resetFocus)
            }
            
            Button(action: { showAddBet = true }) {
                Text("Add Bet")
                Image(systemName: "plus.circle.fill")
            }
            .fullScreenCover(isPresented: $showAddBet, onDismiss: {Task {userController.getAllBets}}, content: {
                AddBetView(showAddBet: $showAddBet).environmentObject(userController)
            })
            .padding([.leading, .trailing], 11)
            .padding([.top, .bottom], 10)
            .background(
                Rectangle()
                    .fill(Color(red: 50/255, green: 55/255, blue: 70/255))
                    .cornerRadius(20)
                    .shadow(
                        color: Color(red: 30/255, green: 35/255, blue: 50/255).opacity(0.5),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
            )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 700, alignment: .topTrailing)
            .offset(x: 0, y: -20)
            .padding()
            .disabled(isFocused)
            .opacity(isFocused ? 0 : 1)
            .foregroundColor(.white)
            .bold()
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            Button(action: { getImage() }) {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .frame(width: 25, height: 30)
                    .foregroundColor(.white)
                
            }
            .padding([.top, .bottom], 20)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color(red: 30/255, green: 35/255, blue: 50/255))
            .offset(x: 0, y: isFocused ? 350 : 450)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .task {
            try? await userController.loadCurrentUser()
            try? await userController.getAllBets()
            try? await userController.retrieveProfilePic()
        }
    }
}
