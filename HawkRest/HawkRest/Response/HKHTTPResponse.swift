//
//  USHTTPResponse.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation

class HKHTTPResponse {
    //
    var code: Int? = 0;
    var headers: [AnyHashable : Any]? = nil;
    var rawBody: NSData? = nil;
}
