//
//  USURLConnection.swift
//  UnirestSwfit
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

import Foundation

typealias AsyncHandler = (_ response: URLResponse?, _ data: NSData?, _ error: NSError?) -> Void;

class HKConnection: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    //
    var request: NSURLRequest? = nil;
    private var completionHandler: AsyncHandler? = nil;
    
    //
    private var connection: NSURLConnection? = nil;
    private var response: URLResponse? = nil;
    private var responseData: NSMutableData? = nil;
    
    deinit{
        self.cancel();
    }
    
    //
    class func sendAsyncRequest(request: NSURLRequest, completionHandler: @escaping AsyncHandler) -> HKConnection
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
        connection = NSURLConnection(request: request! as URLRequest, delegate: self, startImmediately: false);
        connection?.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode);
        if (connection != nil){
            connection?.start();
        }else{
            if (completionHandler != nil){
                completionHandler!(nil,nil,nil);
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
    private func connection(connection: NSURLConnection, didReceiveResponse response: URLResponse){
        self.response = response;
    }
    
    private func connection(connection: NSURLConnection, didReceiveData data: NSData){
        if let respData = responseData {
            respData.append(data as Data);
        }else{
            responseData = NSMutableData(data: data as Data);
        }
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection){
        self.connection = nil;
        if let handler = completionHandler {
            completionHandler = nil;
            if #available(iOS 8.0, *) {
                DispatchQueue.global().async {
                    handler(self.response, self.responseData, nil);
                }
            } else {
                // Fallback on earlier versions
            };
        }
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.connection = nil;
        if let handler = completionHandler {
            completionHandler = nil;
            if #available(iOS 8.0, *) {
                DispatchQueue.global().async {
                    handler(self.response, self.responseData, error as NSError );
                }
            } else {
                // Fallback on earlier versions
            };
        }
    }
    
#if true
    //TARGET_IPHONE_SIMULATOR
    func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace) -> Bool
    {
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust;
    }
    private func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge)
    {
        challenge.sender?.use(URLCredential(trust: challenge.protectionSpace.serverTrust!), for: challenge);
    }
    //TARGET_IPHONE_SIMULATOR
#endif
    
}
