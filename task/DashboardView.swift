//
//  DashboardView.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import SwiftUI

// MARK: - Dashboard Root
struct DashboardView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("loggedInUsername") private var username: String = ""

    @State private var showSidebar = false
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
                                .font(.custom("Always In My Heart", size: 36))
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

// MARK: - Content
struct DashboardContent: View {
    let username: String
    private let bgColor = Color(red: 255/255, green: 242/255, blue: 224/255)

    // Data
    @State private var featured: [Recipe] = []
    @State private var popular: [Recipe] = []
    @State private var tags: [String] = []
    @State private var errorText: String?

    // Search
    @State private var searchText = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Greeting
                Text("Hi, \(username) 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

                // SEARCH BAR
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)

                    TextField("Search recipes", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                        .onSubmit { Task { await runSearch(searchText) } }
                        .onChange(of: searchText) { newValue in
                            // Debounce
                            searchTask?.cancel()
                            let q = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if q.isEmpty {
                                searchResults = []
                                searchError = nil
                                return
                            }
                            searchTask = Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                guard !Task.isCancelled else { return }
                                await runSearch(q)
                            }
                        }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)

                // RESULTS or MAIN SECTIONS
                if isSearching {
                    HStack { ProgressView("Searching…"); Spacer() }
                } else if !searchResults.isEmpty {
                    Text("Results")
                        .font(.headline)
                        .foregroundColor(.black)

                    LazyVStack(spacing: 16) {
                        ForEach(searchResults) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                PopularRow(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let e = searchError {
                        Text(e).foregroundColor(.red).font(.footnote)
                    }

                    Button("Clear search") {
                        searchText = ""
                        searchResults = []
                    }
                    .font(.footnote.weight(.semibold))
                    .tint(.black)

                } else {
                    // Featured
                    Text("Featured Recipes")
                        .font(.headline)
                        .foregroundColor(.black)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(featured) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                    RecipeHeroCard(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    // Categories
                    Text("Categories").font(.headline).foregroundColor(.black)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
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

                    // Popular
                    Text("Popular Recipes")
                        .font(.headline)
                        .foregroundColor(.black)

                    LazyVStack(spacing: 16) {
                        ForEach(popular) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                PopularRow(recipe: recipe)
                            }
                            .buttonStyle(.plain)
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

    // Networking
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

    private func runSearch(_ query: String) async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else {
            await MainActor.run { searchResults = [] }
            return
        }
        await MainActor.run { isSearching = true }
        defer { Task { @MainActor in isSearching = false } }

        do {
            let results = try await RecipeAPI.search(q)
            await MainActor.run {
                searchResults = results
                searchError = nil
            }
        } catch {
            await MainActor.run {
                searchResults = []
                searchError = error.localizedDescription
            }
        }
    }
}


// MARK: - Reusable Views
struct RecipeHeroCard: View {
    let recipe: Recipe
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .frame(width: 280, height: 200)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                .overlay(
                    AsyncImage(url: URL(string: recipe.image), transaction: .init(animation: .easeIn)) { phase in
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

struct PopularRow: View {
    let recipe: Recipe
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                .overlay(
                    AsyncImage(url: URL(string: recipe.image), transaction: .init(animation: .easeIn)) { phase in
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
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.black)
                Text(recipe.cuisine ?? (recipe.mealType?.first ?? ""))
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

// MARK: - Drawer
struct DrawerView: View {
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
