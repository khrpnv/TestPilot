struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username)
                .accessibilityIdentifier("usernameField")
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .accessibilityIdentifier("passwordField")
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("errorMessage")
            }

            Button("Login") {
                if username.isEmpty || password.isEmpty {
                    errorMessage = "Please fill all fields"
                } else {
                    errorMessage = nil
                }
            }
            .accessibilityIdentifier("loginButton")
        }
        .padding()
    }
}
