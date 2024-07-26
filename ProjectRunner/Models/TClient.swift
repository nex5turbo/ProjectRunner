//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation
import SwiftUI
import Contacts

struct TClient: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var familyName: String
    var givenName: String
    var email: String
    var phoneNumber: String
    var imagePath: String?
    var label: TLabel?
    var instagramId: String
    var markColor: MarkColor = .noColor
    
    var imageURL: URL? {
        if let imagePath {
            return URL(string: "file://" + imagePath)
        }
        return nil
    }
    var createdAt: Date
    
    var fullName: String {
        "\(givenName) \(familyName)"
    }
    
    var validPhoneNumber: CNPhoneNumber {
        return CNPhoneNumber(stringValue: phoneNumber)
    }
    
    static func empty() -> Self {
        return TClient(
            familyName: "",
            givenName: "",
            createdAt: Date.now)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case familyName
        case givenName
        case email
        case phoneNumber
        case imagePath
        case createdAt
        case instagramId
        case label
        case markColor
    }
    
    init(familyName: String, givenName: String, createdAt: Date) {
        self.familyName = familyName
        self.givenName = givenName
        self.createdAt = createdAt
        self.email = ""
        self.phoneNumber = ""
        self.instagramId = ""
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.familyName = try container.decode(String.self, forKey: .familyName)
        self.givenName = try container.decode(String.self, forKey: .givenName)
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        self.imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        self.label = try container.decodeIfPresent(TLabel.self, forKey: .label)
        self.instagramId = try container.decodeIfPresent(String.self, forKey: .instagramId) ?? ""
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.markColor = try container.decodeIfPresent(MarkColor.self, forKey: .markColor) ?? .noColor
    }
    
    public func openInstagram() {
        let url = URL(string: "instagram://user?username=\(instagramId)")!
        UIApplication.shared.open(url)
    }
    
    public func openEmail() {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    public func openMessage() {
        let sms = "sms:\(phoneNumber)&body=Hello. I have something to discuss about our Project!"
        let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: strURL)!
        UIApplication.shared.open(url)
    }
    
    public func openCall() {
        let sms = "tel:\(phoneNumber)"
        let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: strURL)!
        UIApplication.shared.open(url)
    }
    
    var clientsCountry: String? {
        return validPhoneNumber.value(forKey: "countryCode") as? String
    }
    
    internal func getFlag() -> String {
        if let clientsCountry {
            return clientsCountry.uppercased()
                .unicodeScalars
                .map({ 127397 + $0.value })
                .compactMap(UnicodeScalar.init)
                .map(String.init)
                .joined()
        }
        return ""
    }
}
