//
//  HTTPTask.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case download
    
    case upload
}
