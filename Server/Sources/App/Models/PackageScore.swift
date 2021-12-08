//
//  PackageScore.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct PackageScore: Content {
    @Firestore.DoubleValue
    private(set) var rampUp: Double
    
    @Firestore.DoubleValue
    private(set) var correctness: Double
    
    @Firestore.DoubleValue
    private(set) var busFactor: Double
    
    @Firestore.DoubleValue
    private(set) var responsiveMaintainer: Double
    
    @Firestore.DoubleValue
    private(set) var licenseScore: Double // TODO: Should this be an integer?
    
    @Firestore.DoubleValue // TODO: In database as "UpdateScore"
    private(set) var goodPinningPractice: Double
    
    init(rampUp: Double,
         correctness: Double,
         busFactor: Double,
         responsiveMaintainer: Double,
         licenseScore: Double,
         goodPinningPractice: Double) {
        
        assert(rampUp >= 0)
        assert(rampUp <= 1)
        
        assert(correctness >= 0)
        assert(correctness <= 1)
        
        assert(busFactor >= 0)
        assert(busFactor <= 1)
        
        assert(responsiveMaintainer >= 0)
        assert(responsiveMaintainer <= 1)
        
        assert(licenseScore >= 0)
        assert(licenseScore <= 1)
        
        assert(goodPinningPractice >= 0)
        assert(goodPinningPractice <= 1)
        
        self.rampUp = rampUp
        self.correctness = correctness
        self.busFactor = busFactor
        self.responsiveMaintainer = responsiveMaintainer
        self.licenseScore = licenseScore
        self.goodPinningPractice = goodPinningPractice
    }
    
}

extension PackageScore: Codable {
    enum CodingKeys: String, CodingKey {
        case rampUp = "RampUp"
        case correctness = "Correctness"
        case busFactor = "BusFactor"
        case responsiveMaintainer = "ResponsiveMaintainer"
        case licenseScore = "LicenseScore"
        case goodPinningPractice = "GoodPinningPractice"
    }
}

// TODO: Remove this mock object
extension PackageScore {
    static let mock = PackageScore(
        rampUp: 0.89,
        correctness: 0.77,
        busFactor: 0.85,
        responsiveMaintainer: 0.43,
        licenseScore: 1,
        goodPinningPractice: 0.65
    )
}
