struct User {
    let username: String
    let email: String
    let age: Int
}

struct UserValidator {
    static func isValid(_ user: User) -> Bool {
        guard !user.username.isEmpty else { return false }
        guard user.email.contains("@") else { return false }
        guard user.age >= 18 else { return false }
        return true
    }
}
