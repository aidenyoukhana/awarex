import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var authViewModel: AuthViewModel
    @State private var agreedToTerms = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                    
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Display Name
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)
                        
                        TextField("Display Name", text: $authViewModel.displayName)
                            .textContentType(.name)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Email
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundStyle(.secondary)
                        
                        TextField("Email", text: $authViewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Phone
                    HStack(spacing: 12) {
                        Image(systemName: "phone")
                            .foregroundStyle(.secondary)
                        
                        TextField("Phone Number (Optional)", text: $authViewModel.phoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)
                            
                            SecureField("Password", text: $authViewModel.password)
                                .textContentType(.newPassword)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !authViewModel.password.isEmpty && authViewModel.password.count < 6 {
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)
                            
                            SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                                .textContentType(.newPassword)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !authViewModel.confirmPassword.isEmpty && authViewModel.password != authViewModel.confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Terms
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service and Privacy Policy")
                            .font(.caption)
                    }
                    .toggleStyle(.checkbox)
                }
                .padding(.horizontal)
                
                // Sign Up Button
                Button {
                    Task {
                        await authViewModel.signUp(modelContext: modelContext)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    } else {
                        Text("Create Account")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .disabled(!authViewModel.isSignUpValid || !agreedToTerms || authViewModel.isLoading)
                .opacity((authViewModel.isSignUpValid && agreedToTerms) ? 1 : 0.5)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Already have account
                Button {
                    authViewModel.clearFields()
                    dismiss()
                } label: {
                    HStack {
                        Text("Already have an account?")
                            .foregroundStyle(.secondary)
                        Text("Sign In")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Custom checkbox toggle style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(configuration.isOn ? Color.accentColor : Color.secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview {
    NavigationStack {
        SignUpView(authViewModel: AuthViewModel())
            .modelContainer(for: User.self, inMemory: true)
    }
}
