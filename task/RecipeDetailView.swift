//
//  RecipeDetailView.swift
//  Savor
//
//  Created by Arnav on 13/08/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipeID: Int

    @State private var recipe: RecipeDetail?
    @State private var isLoading = true
    @State private var errorText: String?

    var body: some View {
        ZStack{
            Color(red: 255/255, green: 242/255, blue: 224/255).ignoresSafeArea()
            ScrollView {
                if isLoading {
                    ProgressView("Loading…")
                        .padding()
                } else if let recipe = recipe {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        AsyncImage(url: URL(string: recipe.image)) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill()
                            case .empty:
                                ProgressView()
                            default:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let rating = recipe.rating {
                            Text("★ \(String(format: "%.1f", rating))")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        if let cuisine = recipe.cuisine {
                            Text("Cuisine: \(cuisine)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        Text("Ingredients")
                            .font(.headline)
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                        }
                        
                        Divider()
                        
                        Text("Instructions")
                            .font(.headline)
                        ForEach(recipe.instructions, id: \.self) { step in
                            Text(step)
                        }
                    }
                    .padding()
                } else if let errorText = errorText {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadRecipe()
            }
        }
    }

    private func loadRecipe() async {
        isLoading = true
        errorText = nil
        do {
            let url = URL(string: "https://dummyjson.com/recipes/\(recipeID)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(RecipeDetail.self, from: data)
            await MainActor.run {
                self.recipe = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorText = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    RecipeDetailView(recipeID: 1)
}
