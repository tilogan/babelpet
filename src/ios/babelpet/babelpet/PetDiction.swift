//
//  PetDiction.swift
//  babelpet
//
//  Created by Timothy Logan on 8/15/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import Foundation

enum Animal: Int, CustomStringConvertible
{
    case WesternDog = 0
    case 日本Dog = 1
    
    static var count: Int { return Language.日本語.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .WesternDog: return "Western Dog"
        case .日本Dog   : return "日本 (Japanese) Dog"
        }
    }
}

enum Gender: Int, CustomStringConvertible
{
    case Male = 0
    case Female = 1
    
    static var count: Int { return Language.日本語.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .Male: return "Male"
        case .Female   : return "Female"
        }
    }
}

class PetDiction: NSObject
{
    
    

}