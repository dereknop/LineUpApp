//
//  SingleBet.swift
//  Lineup
//
//  Created by Devin Moon on 3/30/23.
//

import SwiftUI

struct SingleBetView: View {
    @EnvironmentObject var userController: UserController
    @State var bet: Bet
    @State var liked: Bool
    @State var likeCounter = 0
    
    func calcPayout(wager: Double, odds: Int) -> Double {
        var winnings: Double
        if (odds > 0) {
            // if positive odds (e.g +120)
            winnings = (Double(odds) / 100.0) * wager
        } else {
            // negative odds (e.g -180)
            winnings = 100.0 / (-1.0 * Double(odds)) * wager
        }
        // total payout is winngings plus principle wager
        return winnings + wager
    }
    
    func calcProbability(odds: Int) -> Double {
        var impliedProb: Double
        if (odds > 0) {
            impliedProb = (100.0 / (Double(odds) + 100.0)) * 100.0
        } else {
            impliedProb = (-1.0 * Double(odds) / (-1.0 * Double(odds) + 100)) * 100.0
        }
        return impliedProb
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            if (userController.user != nil) {
            HStack() {
                if (bet.userId == userController.user?.userId) {
                    Button(action: {
                        Task {
                            guard userController.user != nil else { return }
                            if (userController.user!.favoriteBet == bet.id) {
                                try await userController.setFavoriteBet(betId: "")
                                try await userController.loadCurrentUser()
                                userController.favoriteBet = nil
                            } else {
                                try await userController.setFavoriteBet(betId: bet.id)
                                try await userController.loadCurrentUser()
                                try await userController.loadFavoriteBet()
                            }
                        }
                    }) {
                        if (bet.id == userController.user?.favoriteBet) {
                            Image(systemName: "star.fill")
                                .renderingMode(.template)
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "star")
                        }
                    }
                    .padding([.leading], 10)
                    .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                }
                
                Spacer()
                
                if bet.geoTagLocation != "" {
                    Text("\(bet.geoTagLocation)")
                        .frame(maxHeight: 20)
                        .padding(5)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                        .cornerRadius(10)
                }
                
                Text("\(bet.sport)")
                    .padding(5)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                    .cornerRadius(10)
                
                
                Button(action: {
                    if (userController.user!.likes.contains(bet.id)) {
                        likeCounter -= 1
                    } else {
                        likeCounter += 1
                    }
                    Task {
                        try await userController.toggleLikeToBet(betId: bet.id)
                        try await userController.loadCurrentUser()
                        try await userController.getAllUserBets()
                    }
                }) {
                    if (userController.user!.likes.contains(bet.id)) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                    }
                    Text("\(likeCounter)")
                }
                .padding([.top, .bottom], 5)
                .frame(minWidth: 50, maxWidth: 50)
                .font(.subheadline)
                .foregroundColor(.white)
                .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                .cornerRadius(10)
            }
            .padding([.top, .trailing], 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack() {
                HStack() {
                    Text("\(bet.betTitle)")
                    Spacer()
                    if bet.odds > 0 {
                        Text("+\(bet.odds)")
                    } else {
                        Text("\(bet.odds)")
                    }
                }
                .bold()
                .font(.title2)
                
                HStack() {
                    Text("\(bet.eventLocation)")
                    Spacer()
                    Text("\(bet.date.formatted(date: .abbreviated, time: .shortened))")
                }
                .font(.subheadline)
                .foregroundColor(Color.secondary)
                
                VStack() {
                    Text("\(bet.description)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 1)
                }
                .padding(10)
                .padding([.leading], 5)
                .background(Color(red: 245/255, green: 245/255, blue: 245/255))
                .cornerRadius(10)
                
                HStack() {
                    VStack() {
                        Text("Wager: ").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Payout: ").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Probability: ").frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    VStack() {
                        Text("$" + String(format: "%.2f", bet.wager))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("$" + String(format: "%.2f", calcPayout(wager: bet.wager, odds: bet.odds)))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color(red: 0/255, green: 175/255, blue: 0/255))
                        Text(String(format: "%.2f", calcProbability(odds: bet.odds)) + "%")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                }
                .padding()
                .bold()
                .foregroundColor(.black)
                .background(Color(red: 245/255, green: 245/255, blue: 245/255))
                .cornerRadius(10)
            }.padding([.top, .trailing, .leading])
            
            ZStack() {
                Rectangle()
                    .fill(.white)
                    .frame(height: 12)
                    .offset(x: 0, y: -12)
                    .zIndex(1)
                
                HStack() {
                    Text("OPEN")
                        .foregroundColor(.white)
                        .bold()
                        .font(.subheadline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding([.bottom], 2)
                .padding([.top], 12)
                .background(Color(red: 30/255, green: 35/255, blue: 50/255))
                .cornerRadius(10)
            }
        }
        }.background(Rectangle()
            .fill(Color.white)
            .cornerRadius(10)
            .shadow(
                color: .black.opacity(0.3),
                radius: 6,
                x: 0,
                y: 0
            )
        )
        .onAppear() {
            Task {
                bet = try await userController.getUserBet(betId: bet.id)
                likeCounter = bet.likes.count
            }
        }
    }
}
