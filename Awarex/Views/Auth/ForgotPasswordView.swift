import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var authViewModel: AuthViewModel
    @State private var emailSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: emailSent ? "envelope.badge.fill" : "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundStyle(emailSent ? Color.green : Color.accentColor)
                    .padding(.top, 40)
                
                if emailSent {
                    // Success State
                    VStack(spacing: 12) {
                        Text("Check Your Email")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authViewModel.email)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to Login")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                } else {
                    // Input State
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Email Field
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
                    .padding(.horizontal)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await authViewModel.resetPassword()
                            emailSent = true
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .disabled(!authViewModel.isEmailValid || authViewModel.isLoading)
                    .opacity(authViewModel.isEmailValid ? 1 : 0.5)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ForgotPasswordView(authViewModel: AuthViewModel())
}
