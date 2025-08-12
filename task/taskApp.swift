//
//  taskApp.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import SwiftUI

@main
struct taskApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough: Bool = false
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if isLoggedIn {
                    DashboardView()
                } else {
                    if !hasSeenWalkthrough {
                        OnboardView()
                    } else {
                        LoginScreen()
                    }
                }
            }
        }
    }
}
