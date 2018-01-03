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
    
    private class func dict2str(parameters: [String:AnyObject]) -> String
    {
        func encode(uri: String) -> String
        {
            return
                CFURLCreateStringByAddingPercentEscapes(
                kCFAllocatorDefault,
                uri as CFString,
                nil,
                "!*'();:@&=+$,/?%#[]" as CFString,
                CFStringBuiltInEncodings.UTF8.rawValue) as String;
        }
        //
        var result = "";
        var firstParameter: Bool = true;
        for (key, value) in parameters {
            if (!(value.isKind(of: NSURL.self))) {
                let parameter = "\(encode(uri: key))=\(encode(uri: value as! String))";
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
            if (value.isKind(of: NSURL.self)){
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
            if let parameters = simpleRequest.parameters {
                if (parameters.count > 0){
                    let finalUrl = NSMutableString(string: url);
                    if(url.range(of: "?") == nil){
                        finalUrl.append("?");
                    }else{
                        finalUrl.append("&");
                    }
                    finalUrl.append(dict2str(parameters: parameters));
                    url = String(finalUrl);
                }
            }
        }
        
        let requestObj = NSMutableURLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: Double(HKRest.timeout()));
        
        if (httpMethod != .GET && httpMethod != .HEAD) {
            // Add body
            var body = NSMutableData();
            let requestWithBody = request;
            if (requestWithBody.body == nil) {
                // Has parameters
                let parameters = requestWithBody.parameters != nil ? requestWithBody.parameters! : [String:AnyObject]();
                if (hasBinary(parameters: parameters)) {
                    headers["content-type"] = "multipart/form-data; boundary=\(BOUNDARY)";
                    for (key, value) in parameters {
                        if (value.isKind(of: NSURL.self)){
                            let data = NSData(contentsOfFile: (value as! NSURL).absoluteString!);
                            if (data != nil && data!.length > 0){
                                body.append("\r\n--\(BOUNDARY)--\r\n".data(using: String.Encoding.utf8)!);
                                let filename = (value.lastPathComponent)!;
                                body.append("Content-Disposition: form-data; name='\(key)'; filename='\(filename)'\r\n".data(using: String.Encoding.utf8)!);
                                body.append("Content-Length: \(data!.length)\r\n\r\n".data(using: String.Encoding.utf8)!);
                                body.append(data! as Data);
                            }
                        } else {
                            body.append("\r\n--\(BOUNDARY)--\r\n".data(using: String.Encoding.utf8)!);
                            body.append("Content-Disposition: form-data; name='\(key)'\r\n\r\n".data(using: String.Encoding.utf8)!);
                            body.append("\(value)".data(using: String.Encoding.utf8)!);
                        }
                    }
                    // Close
                    body.append("\r\n--\(BOUNDARY)--\r\n".data(using: String.Encoding.utf8)!);
                } else {
                    headers["content-type"] = "application/x-www-form-urlencoded";
                    let querystring = dict2str(parameters: parameters);
                    body = NSMutableData(data: querystring.data(using: String.Encoding.utf8)!);
                }
            } else {
                // Has a body
                body = NSMutableData(data: requestWithBody.body! as Data);
            }
            requestObj.httpBody=body as Data;
        }
        
        
        // Set method
        switch (httpMethod) {
        case .GET:
            requestObj.httpMethod = "GET";
            break;
        case .POST:
            requestObj.httpMethod = "POST";
            break;
        case .PUT:
            requestObj.httpMethod = "PUT";
            break;
        case .DELETE:
            requestObj.httpMethod = "DELETE";
            break;
        case .PATCH:
            requestObj.httpMethod = "PATCH";
            break;
        case .HEAD:
            requestObj.httpMethod = "HEAD";
            break;
        }
        
        // Add headers
        headers["user-agent"] = "hkrest-swift/1.0";
        headers["accept-encoding"] = "gzip";
        
        // Add cookies to the headers
        let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: NSURL(string: url)! as URL)!);
        for (key, value) in cookies
        {
            headers[key] = value;
        }
        
        // Basic Auth
        if (request.username != nil || request.password != nil) {
            let credentials = "\(request.username ?? "")):\(request.password ?? "")";
            let credentialsData = credentials.data(using: String.Encoding.utf8)!;
            let basicStr = (credentialsData as NSData).base64EncodedData(options: NSData.Base64EncodingOptions.lineLength64Characters);
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
    
    private class func getResponse(response: URLResponse?, data: NSData?) -> HKHTTPResponse
    {
        let httpResponse =  response as? HTTPURLResponse;
        let resp = HKHTTPResponse();
        resp.code = httpResponse?.statusCode;
        resp.headers = httpResponse?.allHeaderFields;
        resp.rawBody = data;
        return resp;
    }
    
    class func requestSync(request: HKCore, error: inout NSError?) -> HKHTTPResponse
    {
        let requestObj: NSMutableURLRequest = prepareRequest(request: request);
        var response: URLResponse? = nil;
        do{
            let data = try NSURLConnection.sendSynchronousRequest(requestObj as URLRequest, returning: &response);
            return getResponse(response: response, data: data as NSData);
        }catch let err as NSError{
            print("\n\nError: \(err)");
            error = err;
            return getResponse(response: response, data: nil);
        }
    }
    
    class func requestAsync(request: HKCore, handler: @escaping ((HKHTTPResponse, NSError?) -> Void)) -> HKConnection
    {
        let requestObj: NSMutableURLRequest = prepareRequest(request: request);
        let connection = HKConnection.sendAsyncRequest(request: requestObj, completionHandler: {(response: URLResponse?, data: NSData?, error: NSError?) in
            if let _ = error {
                print("\n\nError: \(error!)");
            }
            let resp = getResponse(response: response, data: data);
            handler(resp, error);
        });
        return connection;
    }
}
