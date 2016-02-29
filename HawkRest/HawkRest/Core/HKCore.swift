//
//  USHTTPRequest.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation


typealias StringResponse = (stringResponse: HKStringResponse, error: NSError?) -> Void;
typealias BinaryResponse = (binaryResponse: HKBinaryResponse, error: NSError?) -> Void;
typealias JsonResponse = (jsonResponse: HKJsonResponse, error: NSError?) -> Void;

class HKCoreBase {
    //base properties
    var headers: [String:String]? = nil;
    var url: String? = nil;
    var httpMethod: HKHTTPMethod? = nil;
    var username: String? = nil;
    var password: String? = nil;
    
    //extend properties
    var body: NSData? = nil;
    var parameters: [String:AnyObject]? = nil;
    
    //init method
    init(httpMethod: HKHTTPMethod?, url: String?, headers: [String:String]?, username: String?, password: String?) {
        //
        self.httpMethod = httpMethod;
        self.url = url != nil ? url : "";
        self.username = username;
        self.password = password;
        
        var lowerCaseHeaders = [String:String]();
        if let headersTmp = headers {
            for (key, value) in headersTmp {
                lowerCaseHeaders[key.lowercaseString] = value;
            }
        }
        self.headers = lowerCaseHeaders;
    }
}

class HKCore : HKCoreBase {
    
    init(httpMethod: HKHTTPMethod?, url: String?, headers: [String:String]?, username: String?, password: String?, parameters: [String:AnyObject]?)
    {
        //
        super.init(httpMethod: httpMethod, url: url, headers: headers, username: username, password: password);
        self.parameters = parameters;
    }
    
    init(httpMethod: HKHTTPMethod?, url: String?, headers: [String:String]?, username: String?, password: String?, body: NSData?)
    {
        //
        super.init(httpMethod: httpMethod, url: url, headers: headers, username: username, password: password);
        self.body = body;
    }
    
    
    //resp method
    func asString() -> HKStringResponse
    {
        var error: NSError? = nil;
        return self.asString(&error);
    }
    func asString(inout error: NSError?) -> HKStringResponse
    {
        let response = HKHTTPHelper.requestSync(self, error: &error);
        return HKStringResponse(httpResponse: response);
    }
    func asStringAsync(response: StringResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(stringResponse: HKStringResponse(httpResponse: resp), error: error);
        });
    }
    //
    func asBinary() -> HKBinaryResponse
    {
        var error: NSError? = nil;
        return self.asBinary(&error);
    }
    func asBinary(inout error: NSError?) -> HKBinaryResponse
    {
        let response = HKHTTPHelper.requestSync(self, error: &error);
        return HKBinaryResponse(httpResponse: response);
    }
    func asBinaryAsync(response: BinaryResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(binaryResponse: HKBinaryResponse(httpResponse: resp), error: error);
        });
    }
    //
    func asJson() -> HKJsonResponse
    {
        var error: NSError? = nil;
        return self.asJson(&error);
    }
    func asJson(inout error: NSError?) -> HKJsonResponse
    {
        let response = HKHTTPHelper.requestSync(self, error: &error);
        return HKJsonResponse(httpResponse: response);
    }
    func asJsonAsync(response: JsonResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(jsonResponse: HKJsonResponse(httpResponse: resp), error: error);
        });
    }
}