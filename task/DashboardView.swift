//
//  DashboardView.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import SwiftUI


struct DashboardView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("authToken") private var authToken: String = ""
   

    @State private var showSidebar = false
    @AppStorage("loggedInUsername") private var username: String = ""

    private let bgColor = Color(red: 255/255, green: 242/255, blue: 224/255)

    
    var body: some View {
        ZStack {
           
            NavigationStack {
                DashboardContent(username: username)
                    .background(bgColor)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button { withAnimation(.easeInOut) { showSidebar.toggle() } } label: {
                                Image(systemName: "line.horizontal.3")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text("Savor..")
                                .font(.custom("Always In My Heart", size: 42))
                                .foregroundColor(.black)
                        }
                    }
            }

           
            if showSidebar {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut) { showSidebar = false } }
            }

           
            HStack(spacing: 0) {
                if showSidebar {
                    DrawerView(
                        onClose: { withAnimation(.easeInOut) { showSidebar = false } },
                            onLogout: {
                                
                                authToken = ""
                                username = ""
                                isLoggedIn = false
                                withAnimation(.easeInOut) { showSidebar = false }
                            }
                    )
                    .frame(width: min(UIScreen.main.bounds.width * 0.78, 320))
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                }
                Spacer()
            }
        }
    }
}

private struct DashboardContent: View {
    let username: String
    private let bgColor = Color(red: 255/255, green: 242/255, blue: 224/255)
    
    @State private var featured: [Recipe] = []
    @State private var popular: [Recipe] = []
    @State private var tags: [String] = []
    @State private var errorText: String?
    @State private var searchText = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    @State private var searchError: String?


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hi, \(username) 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

              
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    TextField("Search recipes", text: $searchText)
                        .textInputAutocapitalization(.never)
                               .disableAutocorrection(true)
                               .submitLabel(.search)                 // return key says “Search”
                               .onSubmit { Task { await runSearch() } }
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    
                 
                }
                .padding()
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                
                if isSearching {
                    ProgressView("Searching…")
                        .padding(.vertical, 8)
                } else if !searchResults.isEmpty {
                    Text("Results")
                        .font(.headline)
                        .foregroundColor(.black)

                    VStack(spacing: 16) {
                        ForEach(searchResults) { recipe in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                    .overlay(
                                        AsyncImage(url: URL(string: recipe.image)) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            case .empty: ProgressView()
                                            default: Image(systemName: "photo").resizable().scaledToFit().padding()
                                            }
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recipe.name).font(.subheadline).fontWeight(.semibold).foregroundColor(.black)
                                    Text(recipe.cuisine ?? (recipe.mealType?.first ?? ""))
                                        .font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }

                    if let e = searchError {
                        Text(e).foregroundColor(.red).font(.footnote)
                    }

                    // Optionally a "Clear" button
                    Button("Clear search") {
                        searchText = ""
                        searchResults = []
                    }
                    .font(.footnote.weight(.semibold))
                    .tint(.black)
                } else {
                    Text("Featured Recipes")
                     .font(.headline)
                     .foregroundColor(.black)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(featured) { r in
                                RecipeHeroCard(recipe: r)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Text("Categories").font(.headline).foregroundColor(.black)

                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(tags.prefix(12), id: \.self) { tag in
                                                Text(tag.capitalized)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(Color.white)
                                                    .cornerRadius(20)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                    Text("Popular Recipes")
                        .font(.headline)
                        .foregroundColor(.black)

                    VStack(spacing: 16) {
                        ForEach(popular) { recipe in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                    .overlay(
                                        AsyncImage(url: URL(string: recipe.image)) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            case .empty: ProgressView()
                                            default: Image(systemName: "photo").resizable().scaledToFit().padding()
                                            }
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recipe.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Text(recipe.cuisine ?? (recipe.mealType?.first ?? ""))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }

                    
                    
                    
                    
                    
                }
                

      


                


                
                if let err = errorText {
                                   Text(err).foregroundColor(.red).font(.footnote)
                               }
            }
            .padding()
        }
        .task { await loadData() }
        .background(bgColor)
    }
    private func loadData() async {
            do {
                async let f = RecipeAPI.featured(limit: 10)
                async let t = RecipeAPI.tags()
                async let p = RecipeAPI.popular(limit: 10)
                let (fv, tv, pv) = try await (f, t, p)
                featured = fv
                tags = tv
                popular = pv
            } catch {
                errorText = error.localizedDescription
            }
        }
    private func runSearch() async {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        isSearching = true
        defer { isSearching = false }
        do {
            searchResults = try await RecipeAPI.search(q)
            searchError = nil
        } catch {
            searchError = error.localizedDescription
            searchResults = []
        }
    }

}

private struct RecipeHeroCard: View {
    let recipe: Recipe
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .frame(width: 280, height: 200)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                .overlay(
                    AsyncImage(url: URL(string: recipe.image)) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        case .empty: ProgressView()
                        default: Image(systemName: "photo").resizable().scaledToFit().padding()
                        }
                    }
                    .frame(width: 280, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                )

            LinearGradient(colors: [.clear, .black.opacity(0.4)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.headline).foregroundColor(.white)
                if let rating = recipe.rating {
                    Text("★ \(String(format: "%.1f", rating))")
                        .font(.caption).foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
        }
    }
}


private struct DrawerView: View {
    let onClose: () -> Void
    let onLogout: () -> Void
    
    

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Menu").font(.title2.bold())
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            .padding(.top, 50)

            Divider()

            Button { } label: { labelRow("person.fill", "Profile") }
            Button { } label: { labelRow("bookmark.fill", "Saved Recipes") }
            Button { } label: { labelRow("gearshape.fill", "Settings") }

            Button(role: .destructive, action: onLogout) {
                labelRow("rectangle.portrait.and.arrow.right", "Log Out")
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 10)
    }

    private func labelRow(_ system: String, _ title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: system)
            Text(title)
            Spacer()
        }
        .foregroundColor(.black)
        .font(.body)
    }
}

#Preview {
    DashboardView()
}
