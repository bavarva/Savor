//
//  LoginResponse.swift
//  task
//
//  Created by Arnav on 11/08/25.
//

import Foundation

struct LoginResponse: Codable{
    let id: Int?
    let username: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let gender: String?
    let image: String?
    let token: String?
}
