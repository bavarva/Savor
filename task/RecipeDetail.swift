//
//  RecipeDetail.swift
//  Savor
//
//  Created by Arnav on 13/08/25.
//

import Foundation

struct RecipeDetail: Identifiable, Codable {
    let id: Int
    let name: String
    let image: String
    let rating: Double?
    let cuisine: String?
    let ingredients: [String]
    let instructions: [String]
}
