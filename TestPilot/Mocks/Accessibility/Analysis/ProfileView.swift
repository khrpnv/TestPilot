import SwiftUI

struct ProfileView: View {
    @State private var username: String = "John Doe"
    @State private var email: String = "john@example.com"

    var body: some View {
        VStack(spacing: 20) {
            Text("User Profile")
                .font(.largeTitle)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Name:")
                        .font(.headline)
                    Text(username)
                        .accessibilityLabel("User name \(username)")
                }

                HStack {
                    Text("Email:")
                        .font(.headline)
                    Text(email)
                        .accessibilityLabel("Email address \(email)")
                }
            }

            SecureField("Password", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Password")

            Button(action: {
                // Perform settings action
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
            }

            Spacer()
        }
        .padding()
    }
}
