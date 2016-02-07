//
//  USHTTPBinaryResponse.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation

class HKBinaryResponse: HKHTTPResponse {
    //
    var body: NSData? = nil;
    
    init(httpResponse: HKHTTPResponse) {
        //
        super.init();
        self.code = httpResponse.code;
        self.headers = httpResponse.headers;
        self.rawBody = httpResponse.rawBody;
        self.body = httpResponse.rawBody;
    }
}