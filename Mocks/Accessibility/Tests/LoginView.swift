import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to MyBank")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                // Perform login
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 32))
            }

            Button("Forgot Password?") {
                // Navigate to reset screen
            }
        }
        .padding()
    }
}
