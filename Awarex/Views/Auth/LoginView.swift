import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var authViewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and Title
                        VStack(spacing: 16) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 80))
                                .foregroundStyle(.tint)
                            
                            Text("Awarex")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        // Login Form
                        VStack(spacing: 16) {
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
                            
                            // Password Field
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundStyle(.secondary)
                                
                                SecureField("Password", text: $authViewModel.password)
                                    .textContentType(.password)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            NavigationLink {
                                ForgotPasswordView(authViewModel: authViewModel)
                            } label: {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal)
                        
                        // Login Button
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await authViewModel.login(modelContext: modelContext)
                                }
                            } label: {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Color.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .disabled(!authViewModel.isLoginValid || authViewModel.isLoading)
                            .opacity(authViewModel.isLoginValid ? 1 : 0.5)
                            
                            Button {
                                showSignUp = true
                            } label: {
                                Text("Create Account")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
        .modelContainer(for: User.self, inMemory: true)
}
