//
//  AddBetView.swift
//  Lineup
//
//  Created by Devin Moon on 4/2/23.
//

import SwiftUI
import CoreLocation
struct Bet : Identifiable, Codable, Equatable {
    var id: String
    let betTitle: String
    let description: String
    let sport: String
    let date: Date
    let eventLocation: String
    let geoTagLocation: String
    let wager: Double
    let odds: Int
    let userId: String
    // userId's of users who have liked the bet
    var likes: [String]
    let betCreated: Date
    
    static func ==(lhs: Bet, rhs: Bet) -> Bool {
        return lhs.id == rhs.id
    }
}

struct AddBetView: View {
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var userController: UserController
    @Binding public var showAddBet: Bool
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var sport: String = "Pick a sport"
    @State private var date = Date()
    @State private var eventLocation: String = ""
    @State private var geoTagLocation: String = ""
    @State private var wager: Double = 0.00
    @State private var odds: Int = 0
    @State private var showError = false
    @State private var alertString = ""
    
    func getLocation() {
        if let location = locationManager.location  {
            CLGeocoder().reverseGeocodeLocation(
                location,
                completionHandler: {
                    (placemarks, error) -> Void in
                    
                    var placemark: CLPlacemark!
                    placemark = placemarks?[0]
                    
                    if placemark.locality != nil && placemark.administrativeArea != nil {
                        geoTagLocation = "\(placemark.locality!), \(placemark.administrativeArea!)"
                    }
                })
        } else {
            geoTagLocation = "Canvas, MD"
        }
    }
    
    func addBet() {
        getLocation()
        getLocation()
        
        if (geoTagLocation == "") {
            showError = true
            alertString = "Select a location from Features -> Location in the simulator (Might need to do it multiple times)."
            return
        }
        
        if (title.isEmpty || desc.isEmpty || sport == "Pick a sport" || eventLocation.isEmpty) {
            showError = true
            alertString = "Error: Need to fill in all information."
            return
        }
        
        if (wager <= 0.00) {
            showError = true
            alertString = "Error: Wager needs to be above $0.00."
            return
        }
        
        if (odds > -101 && odds < 100) {
            showError = true
            alertString = "Error: Odds needs to be less than -100 or greater than 99."
            return
        }
        
        let bet = Bet(id: "", betTitle: title, description: desc, sport: sport, date: date, eventLocation: eventLocation, geoTagLocation: geoTagLocation, wager: wager, odds: odds, userId: userController.user?.userId ?? "", likes: [], betCreated: Date())
        Task {
            do {
                try await userController.addBet(bet: bet)
            } catch {
                print(error)
            }
        }
        
        showAddBet = false
    }
    
    var body: some View {
        ScrollView() {
            VStack() {
                Button(action: { showAddBet = false }) {
//                Button(action: {getLocation();showError = true}) {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .bold()
                .padding([.leading, .trailing], 11)
                .padding([.top, .bottom], 10)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
//                .alert("\(geoTagLocation)", isPresented: $showError) {}
                
                VStack(spacing: 5) {
                    Text("Add Bet")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white)
                    
                    
                    Text("Keep track of your betting.")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding([.top])
                .padding()
                
                VStack(spacing: 30) {
                    VStack() {
                        Text("Bet Title")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        TextField(
                            "Hint Text",
                            text: $title
                        )
                        .padding()
                        .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                        .cornerRadius(10)
                    }
                    
                    
                    VStack() {
                        Text("Bet Description")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        TextField(
                            "Hint Text",
                            text: $desc
                        )
                        .frame(minHeight: 150, alignment: .topLeading)
                        .padding()
                        .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                        .cornerRadius(10)
                    }
                    
                    VStack() {
                        Text("Event Date and Time")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        DatePicker(
                            "Start Date",
                            selection: $date
                        )
                        .tint(Color(red: 250/255, green: 100/255, blue: 20/255))
                        .colorScheme(.dark)
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    
                    VStack() {
                        Text("Event Location")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .bold()
                        
                        TextField(
                            "Hint Text",
                            text: $eventLocation
                        )
                        .padding()
                        .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                        .cornerRadius(10)
                    }
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Wager")
                                .bold()
                                .frame(width: 60)
                            
                            TextField(
                                "Hint Text",
                                value: $wager,
                                format: .currency(code: "USD")
                            )
                            .keyboardType(.numberPad)
                            .bold()
                            .padding()
                            .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Odds")
                                .bold()
                                .frame(width: 60)
                            
                            TextField(
                                "Hint Text",
                                value: $odds,
                                format: .number
                            )
                            .frame(width: 100)
                            .keyboardType(.numberPad)
                            .bold()
                            .padding()
                            .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                            .cornerRadius(10)
                        }
                    }
                    
                    VStack() {
                        Text("Sport")
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        ZStack() {
                            Menu {
                                Button("Football", action: { sport = "Football 🏈" })
                                Button("Basketball", action: { sport = "Basketball 🏀" })
                                Button("Soccer", action: {sport = "Soccer ⚽️" })
                                Button("Baseball", action: { sport = "Baseball ⚾️" })
                                Button("Hockey", action: { sport = "Hockey 🏒" })
                                Button("Tennis", action: { sport = "Tennis 🎾" })
                            } label: {
                                Text("\(sport)")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .pickerStyle(.menu)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(red: 50/255, green: 55/255, blue: 70/255))
                            .cornerRadius(10)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                
                Button(action: addBet) {
                    Text("Add")
                    Image(systemName: "plus")
                }
                .padding([.leading, .trailing], 11)
                .padding([.top, .bottom], 10)
                .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                .bold()
                .background(Rectangle()
                    .fill(.white)
                    .cornerRadius(20)
                    .shadow(
                        color: Color(red: 30/255, green: 35/255, blue: 50/255).opacity(0.5),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                )
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding([.top])
                .padding()
                
                
                Spacer()
            }
            .padding([.bottom], 350)
        }
        .alert("\(alertString)", isPresented: $showError) {}
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(red: 30/255, green: 35/255, blue: 50/255))
        .foregroundColor(.white)
        .task {
            try? await userController.loadCurrentUser()
        }
    }
}
