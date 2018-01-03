//
//  USHTTPRequest.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation


typealias StringResponse = (_ stringResponse: HKStringResponse, _ error: NSError?) -> Void;
typealias BinaryResponse = (_ binaryResponse: HKBinaryResponse, _ error: NSError?) -> Void;
typealias JsonResponse = (_ jsonResponse: HKJsonResponse, _ error: NSError?) -> Void;

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
                lowerCaseHeaders[key.lowercased()] = value;
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
        return self.asString(error: &error);
    }
    func asString( error: inout NSError?) -> HKStringResponse
    {
        let response = HKHTTPHelper.requestSync(request: self, error: &error);
        return HKStringResponse(httpResponse: response);
    }
    func asStringAsync(response: @escaping StringResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(request: self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(HKStringResponse(httpResponse: resp), error);
        });
    }
    //
    func asBinary() -> HKBinaryResponse
    {
        var error: NSError? = nil;
        return self.asBinary(error: &error);
    }
    func asBinary( error: inout NSError?) -> HKBinaryResponse
    {
        let response = HKHTTPHelper.requestSync(request: self, error: &error);
        return HKBinaryResponse(httpResponse: response);
    }
    func asBinaryAsync(response: @escaping BinaryResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(request: self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(HKBinaryResponse(httpResponse: resp), error);
        });
    }
    //
    func asJson() -> HKJsonResponse
    {
        var error: NSError? = nil;
        return self.asJson(error: &error);
    }
    func asJson( error: inout NSError?) -> HKJsonResponse
    {
        let response = HKHTTPHelper.requestSync(request: self, error: &error);
        return HKJsonResponse(httpResponse: response);
    }
    func asJsonAsync(response: @escaping JsonResponse) -> HKConnection
    {
        return HKHTTPHelper.requestAsync(request: self, handler: {(resp: HKHTTPResponse, error: NSError?) in
            response(HKJsonResponse(httpResponse: resp), error);
        });
    }
}
