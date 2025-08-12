//
//  Models.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import Foundation

struct RecipesResponse: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let rating: Double?
    let cuisine: String?
    let tags: [String]?
    let mealType: [String]?
}

