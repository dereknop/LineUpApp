//
//  ChangeUsernameView.swift
//  Lineup
//
//  Created by Devin Moon on 5/4/23.
//

import SwiftUI

struct ChangeUsernameView: View {
    @Binding var showChangeUsername: Bool
    @EnvironmentObject var userController: UserController
    @State var newUsername = ""
    
    var body: some View {
        VStack {
            Button(action: { showChangeUsername = false }) {
                Image(systemName: "arrow.left")
                Text("Back")
            }
            .padding([.leading])
            .bold()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding([.top, .bottom])
    
            
            Text("Change Your Username")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.white)
                .padding([.top], 40)

            Text("New Username")
                .padding([.top])
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .bold()
            
            TextField("", text: $newUsername)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
            
            Button(action: {
                showChangeUsername = false
                Task {
                    try await userController.changeUsername(username: newUsername)
                }
            }) {
                Text("Submit")
            }
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing])
            .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
            .bold()
            .background(.white)
            .cornerRadius(20)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .padding([.top])
            
            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .background(Color(red: 30/255, green: 35/255, blue: 50/255))
    }
}

struct ChangeUsernamePreviewContainer: View {
    @State private var showChangeUsername = true

    var body: some View {
        ChangeUsernameView(showChangeUsername: $showChangeUsername)
    }
}

struct ChangeUsernamePreview: PreviewProvider {
    static var previews: some View {
        ChangeUsernamePreviewContainer()
    }
}
