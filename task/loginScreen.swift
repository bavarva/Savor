//
//  loginScreen.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import SwiftUI

struct LoginScreen: View {

    @AppStorage("authToken") private var authToken: String?
    @AppStorage("loggedInUsername") private var loggedInUsername: String?
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @FocusState private var fieldInFocus: Field?
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    
    private enum Field { case username, password }
    

    private let bg = Color(red: 255/255, green: 242/255, blue: 224/255)
    private var isValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                
                VStack(spacing: 6) {
                    Text("Savor..")
                        .font(.custom("Always In My Heart", size: 64)) // keep your font
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("Cook Anything, Anytime")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.6))
                }
                .padding(.top, 12)
                
                VStack(spacing: 16) {
                    
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)
                        TextField("Username or Email", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($fieldInFocus, equals: .username)
                    }
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.gray)
                        Group {
                            if isSecure {
                                SecureField("Password (min 6 chars)", text: $password)
                                    .textContentType(.password)
                                    .focused($fieldInFocus, equals: .password)
                            } else {
                                TextField("Password (min 6 chars)", text: $password)
                                    .textContentType(.password)
                                    .focused($fieldInFocus, equals: .password)
                            }
                        }
                        Button {
                            isSecure.toggle()
                        } label: {
                            Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.gray)
                        }
                        .accessibilityLabel(isSecure ? "Show password" : "Hide password")
                    }
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    

                    Button("Forgot Password?") { }
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .tint(.black.opacity(0.7))
                    

                    Button {
                        Task { await login() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView() }
                            Text("Log In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .disabled(!isValid || isLoading)
                    .opacity(isValid ? 1 : 0.6)
                    
    
                    
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.06), radius: 20, y: 8)
                )
                .padding(.horizontal, 20)
                

                HStack(spacing: 6) {
                    Text("New here?, for Demo use id: emilys , password: emilyspass")
                        .foregroundStyle(.black.opacity(0.7))
                    Button("Create an account") { /* navigate to sign up */ }
                        .fontWeight(.semibold)
                }
                .font(.footnote)
                .padding(.bottom, 8)
            }
        }
        .onAppear { fieldInFocus = .username }
        .onTapGesture { hideKeyboard() }
        .alert("Login failed", isPresented: .constant(errorMessage != nil), actions: {
                    Button("OK") { errorMessage = nil }
                }, message: {
                    Text(errorMessage ?? "Unknown error")
                })
            }
    

    
    private func login() async {
        guard isValid else { return }
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "https://dummyjson.com/auth/login") else {
            errorMessage = "Bad URL"; return
        }

        let payload: [String: Any] = [
            "username": username,          // try: "emilys"
            "password": password,          // try: "emilyspass"
            "expiresInMins": 30
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Bad request body"; return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

            // Debug: see exactly what came back
            let raw = String(data: data, encoding: .utf8) ?? "<no body>"
            print("STATUS:", http.statusCode)
            print("BODY:", raw)

            if (200..<300).contains(http.statusCode) {
                // Success path
                
                let decoder = JSONDecoder()
                let result = try decoder.decode(LoginResponse.self, from: data)
                authToken = result.token
                loggedInUsername = result.username
                isLoggedIn = true

                print("✅ Logged in as \(result.username). Token: \(String(describing: result.token?.prefix(12)))…")
                
                
            } else {
                // Error path – try to decode the API's error format
                if let apiErr = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw NSError(domain: "Login", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: apiErr.message ?? apiErr.error ?? "Status \(http.statusCode)"])
                } else {
                    throw NSError(domain: "Login", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "Status \(http.statusCode): \(raw)"])
                }
            }
        } catch let decoding as DecodingError {
            // Show detailed decoding issues
            errorMessage = "Decoding error: \(decoding)"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func hideKeyboard() {

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
     
    }
}


#Preview {
    LoginScreen()
}
