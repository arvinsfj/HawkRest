//
//  ViewController.swift
//  HawkRest
//
//  Created by cz on 2/3/16.
//  Copyright © 2016 arvin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var testShowLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        testSyncHEADRequest();
        testAsyncHEADRequest();
        testSyncGETRequest();
        testAsyncGETRequest();
        testSyncPOSTRequest();
        testAsyncPOSTRequest();
        testSyncPOSTEntityRequest();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //HEAD
    func testSyncHEADRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        let resp = HKRest.head({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/headers";
            request.headers = headers;
            request.parameters = parameters;
        }).asString(&error);
        print(resp.code);
        print(resp.headers);
        print(resp.rawBody);
        print(resp.body);
        print(error);
        self.testShowLabel.text = "\(resp.code)";
    }
    
    func testAsyncHEADRequest(){
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        HKRest.head({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/headers";
            request.headers = headers;
            request.parameters = parameters;
        }).asStringAsync({ (resp: HKStringResponse, error: NSError?) in
            print(resp.code);
            print(resp.headers);
            print(resp.rawBody);
            print(resp.body);
            print(error);
            dispatch_sync(dispatch_get_main_queue(), {
                self.testShowLabel.text = "\(resp.code)";
            });
        });
    }
    
    //GET
    func testSyncGETRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        let resp = HKRest.get({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/get";
            request.headers = headers;
            request.parameters = parameters;
        }).asString(&error);
        print(resp.code);
        print(resp.headers);
        print(resp.rawBody);
        print(resp.body);
        print(error);
        self.testShowLabel.text = "\(resp.code)";
    }
    
    func testAsyncGETRequest(){
        HKRest.get({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/get";
            request.username = "";
            request.password = "";
        }).asStringAsync({ (resp: HKStringResponse, error: NSError?) in
            print(resp.code);
            print(resp.headers);
            print(resp.rawBody);
            print(resp.body);
            print(error);
            dispatch_sync(dispatch_get_main_queue(), {
                self.testShowLabel.text = "\(resp.code)";
            });
        });
    }
    
    //POST
    func testSyncPOSTRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let file = NSURL(string: NSBundle.mainBundle().pathForResource("asd", ofType: "png")!)!;
        let parameters = ["parameter": "value", "file": file];
        
        let resp = HKRest.post({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            request.parameters = parameters;
        }).asJson(&error);
        
        print(resp.code);
        print(resp.headers);
        print(resp.rawBody);
        print(resp.body);
        print(error);
        self.testShowLabel.text = "\(resp.code)";
    }
    
    func testAsyncPOSTRequest(){
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        
        HKRest.post({ (request: HKParameterRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            request.parameters = parameters;
            request.username = "";
            request.password = "";
            
        }).asJsonAsync({ (resp: HKJsonResponse, error: NSError?) in
            print(resp.code);
            print(resp.headers);
            print(resp.rawBody);
            print(resp.body);
            print(error);
            dispatch_sync(dispatch_get_main_queue(), {
                self.testShowLabel.text = "\(resp.code)";
            });
        });
    }
    
    func testSyncPOSTEntityRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        
        let resp = HKRest.post({ (request: HKBodyRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            do {
                request.body = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0));
            } catch {}
            
        }).asJson(&error);
        
        print(resp.code);
        print(resp.headers);
        print(resp.rawBody);
        print(resp.body);
        print(error);
        self.testShowLabel.text = "\(resp.code)";
    }
    
    //
    
}

