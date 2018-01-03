//
//  USHTTPJsonResponse.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation

class HKJsonResponse: HKHTTPResponse {
    //
    var body: AnyObject? = nil;
    
    init(httpResponse: HKHTTPResponse) {
        //
        super.init();
        self.code = httpResponse.code;
        self.headers = httpResponse.headers;
        self.rawBody = httpResponse.rawBody;
        
        var json: AnyObject? = nil;
        if let data = httpResponse.rawBody {
            do {
                json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableLeaves) as AnyObject;
            }catch{}
        }
        self.body = json;
    }
}
