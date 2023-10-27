//
//  ProfileResultView.swift
//  Lineup
//
//  Created by Devin Moon on 4/1/23.
//

import SwiftUI
import FirebaseStorage
struct ProfileResultView: View {
    @Binding var user: DBUser
    @EnvironmentObject var userController: UserController
    @State var profilePic: UIImage?
    @State var showUser = false
    @State var isFriend = false
    
    var body: some View {
        Button(action: { showUser = true}) {
            HStack(spacing: 20) {
                if profilePic != nil {
                    Image(uiImage: profilePic!)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(100)
                }
                
                VStack() {
                    Text("\(user.username)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .bold()
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .italic()
                }
                .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 8, height: 15)
                    .foregroundColor(Color(red: 30/255, green: 35/255, blue: 50/255))
            }
            .padding()
            .padding([.leading, .trailing], 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Rectangle()
                    .fill(.white)
                    .cornerRadius(15)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 3,
                        x: 0,
                        y: 1
                    )
            )
        }.task {
            try? await getProfilePic()
        }
        .onAppear() {
            guard userController.user != nil else { return }
            isFriend = userController.user!.following.contains(user.userId)
        }
        .fullScreenCover(isPresented: $showUser, onDismiss: {
            isFriend = userController.user!.following.contains(user.userId)
            Task {
                try await userController.getFriends()
            }
        }, content: {
            OtherUserView(showUser: $showUser, user: $user, isFriend: isFriend)
        })
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

/*
struct ProfileResultView_Preview: PreviewProvider {
    static var previews: some View {
        ProfileResultView().padding(10)
    }
}
*/
