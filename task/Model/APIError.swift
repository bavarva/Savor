//
//  APIError.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import Foundation

struct APIError: Codable{
    let message: String?
    let error: String?
}
