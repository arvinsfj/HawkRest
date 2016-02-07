//
//  USHTTPClientHelper.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//
import Foundation

class HKHTTPHelper {
    //
    private static let BOUNDARY = "-------------------------1d3668e64798b0d2df075cc65cb37acd";
    
    private class func dictToStr(parameters: [String:AnyObject]) -> String
    {
        func encode(uri: String) -> String
        {
            return
                CFURLCreateStringByAddingPercentEscapes(
                kCFAllocatorDefault,
                uri,
                nil,
                "!*'();:@&=+$,/?%#[]",
                CFStringBuiltInEncodings.UTF8.rawValue) as String;
        }
        //
        var result = "";
        var firstParameter: Bool = true;
        for (key, value) in parameters {
            if (!(value.isKindOfClass(NSURL.self))) {
                let parameter = "\(encode(key))=\(encode(value as! String))";
                if (firstParameter) {
                    result = parameter;
                    firstParameter = false;
                } else {
                    result += "&\(parameter)";
                }
            }
        }
        return result;
    }
    
    private class func hasBinary(parameters: [String:AnyObject]) -> Bool
    {
        for (_, value) in parameters {
            if (value.isKindOfClass(NSURL.self)){
                return true;
            }
        }
        return false;
    }
    
    private class func prepareRequest(request: HKCore) -> NSMutableURLRequest
    {
        let httpMethod = request.httpMethod!;
        var headers = request.headers!;
        var url = request.url!;
        
        if (httpMethod == .GET || httpMethod == .HEAD){
            let simpleRequest = request;
            let parameters = simpleRequest.parameters;
            if (parameters?.count > 0){
                let finalUrl = NSMutableString(string: url);
                if(url.rangeOfString("?") == nil){
                    finalUrl.appendString("?");
                }else{
                    finalUrl.appendString("&");
                }
                finalUrl.appendString(dictToStr(parameters!));
                url = String(finalUrl);
            }
        }
        
        let requestObj = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: Double(HKRest.timeout()));
        
        if (httpMethod != .GET && httpMethod != .HEAD) {
            // Add body
            var body = NSMutableData();
            let requestWithBody = request;
            if (requestWithBody.body == nil) {
                // Has parameters
                let parameters = requestWithBody.parameters != nil ? requestWithBody.parameters! : [String:AnyObject]();
                if (hasBinary(parameters)) {
                    headers["content-type"] = "multipart/form-data; boundary=\(BOUNDARY)";
                    for (key, value) in parameters {
                        if (value.isKindOfClass(NSURL.self)){
                            let data = NSData(contentsOfFile: value.absoluteString);
                            if (data != nil && data?.length > 0){
                                body.appendData("\r\n--\(BOUNDARY)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                                let filename = value.lastPathComponent;
                                body.appendData("Content-Disposition: form-data; name='\(key)'; filename='\(filename)'\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                                body.appendData("Content-Length: \(data!.length)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                                body.appendData(data!);
                            }
                        } else {
                            body.appendData("\r\n--\(BOUNDARY)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                            body.appendData("Content-Disposition: form-data; name='\(key)'\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                            body.appendData("\(value)".dataUsingEncoding(NSUTF8StringEncoding)!);
                        }
                    }
                    // Close
                    body.appendData("\r\n--\(BOUNDARY)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
                } else {
                    headers["content-type"] = "application/x-www-form-urlencoded";
                    let querystring = dictToStr(parameters);
                    body = NSMutableData(data: querystring.dataUsingEncoding(NSUTF8StringEncoding)!);
                }
            } else {
                // Has a body
                body = NSMutableData(data: requestWithBody.body!);
            }
            requestObj.HTTPBody=body;
        }
        
        
        // Set method
        switch (httpMethod) {
        case .GET:
            requestObj.HTTPMethod = "GET";
            break;
        case .POST:
            requestObj.HTTPMethod = "POST";
            break;
        case .PUT:
            requestObj.HTTPMethod = "PUT";
            break;
        case .DELETE:
            requestObj.HTTPMethod = "DELETE";
            break;
        case .PATCH:
            requestObj.HTTPMethod = "PATCH";
            break;
        case .HEAD:
            requestObj.HTTPMethod = "HEAD";
            break;
        }
        
        // Add headers
        headers["user-agent"] = "hkrest-swift/1.0";
        headers["accept-encoding"] = "gzip";
        
        // Add cookies to the headers
        let cookies = NSHTTPCookie.requestHeaderFieldsWithCookies(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: url)!)!);
        for (key, value) in cookies
        {
            headers[key] = value;
        }
        
        // Basic Auth
        if (request.username != nil || request.password != nil) {
            let user = (request.username == nil) ? "" : request.username;
            let pass = (request.password == nil) ? "" : request.password;
            let credentials = "\(user):\(pass)";
            let credentialsData = credentials.dataUsingEncoding(NSUTF8StringEncoding)!;
            let basicStr = credentialsData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength);
            let header = "Basic \(basicStr)";
            headers["authorization"] = header;
        }
        
        // Default headers
        let defaultHeaders = HKRest.defaultHeader();
        for (key, value) in defaultHeaders {
            requestObj.addValue(value, forHTTPHeaderField:key);
        }
        
        for (key, value) in headers {
            requestObj.addValue(value, forHTTPHeaderField:key);
        }
        return requestObj;
    }
    
    private class func getResponse(response: NSURLResponse?, data: NSData?) -> HKHTTPResponse
    {
        let httpResponse =  response as? NSHTTPURLResponse;
        let resp = HKHTTPResponse();
        resp.code = httpResponse?.statusCode;
        resp.headers = httpResponse?.allHeaderFields;
        resp.rawBody = data;
        return resp;
    }
    
    class func requestSync(request: HKCore, inout error: NSError?) -> HKHTTPResponse
    {
        let requestObj: NSMutableURLRequest = prepareRequest(request);
        var response: NSURLResponse? = nil;
        do{
            let data = try NSURLConnection.sendSynchronousRequest(requestObj, returningResponse: &response);
            return getResponse(response, data: data);
        }catch let err as NSError{
            print("\n\nError: \(err)");
            error = err;
            return getResponse(response, data: nil);
        }
    }
    
    class func requestAsync(request: HKCore, handler: ((HKHTTPResponse, NSError?) -> Void)) -> HKConnection
    {
        let requestObj: NSMutableURLRequest = prepareRequest(request);
        let connection = HKConnection.sendAsyncRequest(requestObj, completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) in
            if let _ = error {
                print("\n\nError: \(error!)");
            }
            let resp = getResponse(response, data: data);
            handler(resp, error);
        });
        return connection;
    }
}