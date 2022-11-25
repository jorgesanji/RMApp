//
//  Date+Formating.swift
//  RMApp
//
//  Created by jorge Sanmartin on 24/11/22.
//

import Foundation

extension Date {
    
    
    //“September 7, 2017”
    //“7 de septiembre de 2017”
    
    
    var mediun: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = .current
        return dateFormatter.string(from: self)
    }
    
}
