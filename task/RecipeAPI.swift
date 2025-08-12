//
//  RecipeAPI.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import Foundation

enum RecipeAPI {
    private static let base = "https://dummyjson.com"

    static func featured(limit: Int = 10) async throws -> [Recipe] {
        try await fetch("\(base)/recipes?limit=\(limit)")
    }

    static func tags() async throws -> [String] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "\(base)/recipes/tags")!)
        return try JSONDecoder().decode([String].self, from: data)
    }

    static func popular(limit: Int = 10) async throws -> [Recipe] {
        try await fetch("\(base)/recipes?sortBy=rating&order=desc&limit=\(limit)")
    }

    private static func fetch(_ urlStr: String) async throws -> [Recipe] {
        let url = URL(string: urlStr)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RecipesResponse.self, from: data).recipes
    }

    static func search(_ q: String) async throws -> [Recipe] {
        let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q
        let url = URL(string: "\(base)/recipes/search?q=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RecipesResponse.self, from: data).recipes
    }
}

