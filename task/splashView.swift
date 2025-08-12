//
//  splashView.swift
//  task
//
//  Created by Arnav on 11/08/25.

import SwiftUI


struct SplashView: View {
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
  
    var body: some View {
 
            ZStack {
        
                    Color(red: 255/255, green: 242/255, blue: 224/255)
                        .ignoresSafeArea()
                    
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                
            }
            
        
    }

#Preview {
    SplashView()
}

