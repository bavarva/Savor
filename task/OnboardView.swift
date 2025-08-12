//
//  ContentView.swift
//  task
//
//  Created by Arnav on 11/08/25.
//
//
import SwiftUI

struct OnboardView: View {
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough: Bool = false

    @State private var currentIndex: Int = 0
    private let display : [Titles] = [Titles(subheading2: "", heading: "Savor..", description: "Discover, cook, and savor recipes made just for you"), Titles(subheading2: "Cook Anything, Anytime",  heading: "", description: "Thousands of recipes for every craving From quick snacks to gourmet meals in minutes."), Titles(subheading2: "Your Personal Kitchen Buddy",  heading: "", description: "Save favorites, plan meals, shop smarter. Turn ingredients to delicious dishes.")]
    
    func buildButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .fontWeight(.semibold)
                .frame(width: 300, height: 50)
                .background(Color.black)
                .foregroundColor(Color(red: 255/255, green: 242/255, blue: 224/255))
                .cornerRadius(30)
                .shadow(radius: 4)
        }
    }
    
    func slideView(for content: Titles, at index: Int) -> some View {
        VStack(){
            Spacer()
            if(index == 1){
                Image("slideOne")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }
            if(index == 2){
                Image("slideTwo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }
            
            Text(content.heading)
                .font(.custom("Always In My Heart", size: 162))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            
            if index != 0 {
                Spacer().frame(height: 40)
            }
            Text(content.subheading2)
                .font(.system(size: 38, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
                .padding(index == 0 ? .init() : .all)
            
            Text(content.description)
                .font(.title)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            if index == 0 {
                Spacer()
            } else {
                Spacer().frame(height: 42)
            }
            
            if index != 2 {
                buildButton(label: "Continue") {
                    if currentIndex < display.count - 1 {
                        withAnimation {
                            currentIndex += 1
                        }
                    }
                }
            } else {
                buildButton(label: "Get Started") {
                    hasSeenWalkthrough = true
                }
            }
            Spacer().frame(height: 24)
        }
        .padding()
    }
    
    var body: some View {
        ZStack{
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(display.indices, id: \.self) { index in
                        let content = display[index]
                        slideView(for: content, at: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .padding()
        }.background(Color(red: 255/255, green: 242/255, blue: 224/255))
    }
}

#Preview {
    OnboardView()
}
