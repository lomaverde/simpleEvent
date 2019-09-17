//
//  Log.swift
//  MeiEvents
//
//  Created by Mei Yu on 9/1/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

struct Log {

    /// a simple error log method
    static func error(_ error: Error?,
                      _ message: @autoclosure () -> Any,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        print("[ERROR] \(file).\(function).\(line): \(message()), \(error?.localizedDescription ?? "")")
    }
}
