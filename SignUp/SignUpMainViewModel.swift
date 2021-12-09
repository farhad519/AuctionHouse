//
//  SignUpMainViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 3/12/21.
//

import Foundation

class SignUpMainViewModel {
    func validateFields(userName: String?, gmail: String?, password: String?) -> String? {
        let isAnyFieldEmpty = [
            userName?.trimmingCharacters(in: .whitespacesAndNewlines),
            gmail?.trimmingCharacters(in: .whitespacesAndNewlines),
            password?.trimmingCharacters(in: .whitespacesAndNewlines)
        ].contains("")
        
        if isAnyFieldEmpty {
            return "All field must be filled."
        }
        
        if isPasswordValid(password: password?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") == false {
            return "Password must be minimum 8 characters and must contain at least 1 uppercase alphabet, 1 lowercase alphabet and 1 Number."
        }
        
        return nil
    }
    
    private func isPasswordValid(password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$")
        return predicate.evaluate(with: password)
    }
}
