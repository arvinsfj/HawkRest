//
//  USURLConnection.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation

typealias AsyncHandler = (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void;

class HKConnection: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    //
    var request: NSURLRequest? = nil;
    private var completionHandler: AsyncHandler? = nil;
    
    //
    private var connection: NSURLConnection? = nil;
    private var response: NSURLResponse? = nil;
    private var responseData: NSMutableData? = nil;
    
    deinit{
        self.cancel();
    }
    
    //
    class func sendAsyncRequest(request: NSURLRequest, completionHandler: AsyncHandler) -> HKConnection
    {
        let result = HKConnection();
        result.request = request;
        result.completionHandler = completionHandler;
        result.start();
        return result;
    }
    
    private func start() -> Void
    {
        //
        connection = NSURLConnection(request: request!, delegate: self, startImmediately: false);
        connection?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode);
        if (connection != nil){
            connection?.start();
        }else{
            if (completionHandler != nil){
                completionHandler!(response: nil,data: nil,error: nil);
                completionHandler = nil;
            }
        }
    }
    private func cancel() -> Void
    {
        //
        connection?.cancel();
        connection = nil;
        completionHandler = nil;
    }
    
    //mark connection
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        self.response = response;
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        if let respData = responseData {
            respData.appendData(data);
        }else{
            responseData = NSMutableData(data: data);
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        self.connection = nil;
        if let handler = completionHandler {
            completionHandler = nil;
            dispatch_async(dispatch_get_global_queue(0, 0), {
                handler(response: self.response, data: self.responseData, error: nil);
            });
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.connection = nil;
        if let handler = completionHandler {
            completionHandler = nil;
            dispatch_async(dispatch_get_global_queue(0, 0), {
                handler(response: self.response, data: self.responseData, error: error);
            });
        }
    }
    
#if true
    //TARGET_IPHONE_SIMULATOR
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool
    {
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust;
    }
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge)
    {
        challenge.sender?.useCredential(NSURLCredential(trust: challenge.protectionSpace.serverTrust!), forAuthenticationChallenge: challenge);
    }
    //TARGET_IPHONE_SIMULATOR
#endif
    
}