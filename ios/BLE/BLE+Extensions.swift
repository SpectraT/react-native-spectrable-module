//
//  BLE+Extensions.swift
//  MyFirstFrameworkApp
//
//  Created by sft_mac on 24/02/22.
//

import Foundation

extension String {
    
    var isValidURL: Bool {
        
//        guard let url = URL(string: self) else {
//            return false
//        }
//
//        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
//        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
//        let result = urlTest.evaluate(with: url)
//
//        return result
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: self)
    }
  
    var trim:String {
          return self.trimmingCharacters(in: .whitespaces)
    }
      
    var isBlank:Bool {
          return self.trim.isEmpty
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
