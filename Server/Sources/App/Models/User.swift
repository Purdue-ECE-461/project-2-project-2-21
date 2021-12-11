//
//  User.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct User: Authenticatable {
    var name: String
}
