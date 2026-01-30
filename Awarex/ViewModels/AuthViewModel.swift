import Foundation
import SwiftUI
import SwiftData

@Observable
final class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var displayName: String = ""
    var phoneNumber: String = ""
    
    var isLoading: Bool = false
    var errorMessage: String?
    var isAuthenticated: Bool = false
    var currentUser: User?
    
    var isLoginValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    var isSignUpValid: Bool {
        !email.isEmpty && email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        !displayName.isEmpty
    }
    
    var isEmailValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    func login(modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Check for existing user
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email }
        )
        
        if let users = try? modelContext.fetch(descriptor), let user = users.first {
            currentUser = user
            user.lastLoginAt = Date()
            isAuthenticated = true
        } else {
            errorMessage = "Invalid email or password"
        }
        
        isLoading = false
    }
    
    func signUp(modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Check if user already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email }
        )
        
        if let users = try? modelContext.fetch(descriptor), !users.isEmpty {
            errorMessage = "An account with this email already exists"
            isLoading = false
            return
        }
        
        // Create new user
        let newUser = User(
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            lastLoginAt: Date()
        )
        
        modelContext.insert(newUser)
        currentUser = newUser
        isAuthenticated = true
        isLoading = false
    }
    
    func resetPassword() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearFields()
    }
    
    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        phoneNumber = ""
        errorMessage = nil
    }
}
