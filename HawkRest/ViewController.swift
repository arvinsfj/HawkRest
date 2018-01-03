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
        testSyncGETRequest();/*
        testAsyncGETRequest();
        testSyncPOSTRequest();
        testAsyncPOSTRequest();
        testSyncPOSTEntityRequest();*/
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
        let resp = HKRest.head(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/headers";
            request.headers = headers;
            request.parameters = parameters as [String : AnyObject];
        }).asString(error: &error);
        print(resp.code ?? "");
        print(resp.headers ?? "");
        print(resp.rawBody ?? "");
        print(resp.body ?? "");
        print(error ?? "");
        self.testShowLabel.text = "\(String(describing: resp.code))";
    }
    
    func testAsyncHEADRequest(){
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        HKRest.head(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/headers";
            request.headers = headers;
            request.parameters = parameters as [String : AnyObject];
        }).asStringAsync{ (resp: HKStringResponse, error: NSError?) in
            print(resp.code ?? "");
            print(resp.headers ?? "");
            print(resp.rawBody ?? "");
            print(resp.body ?? "");
            print(error ?? "");
            DispatchQueue.main.async {
                self.testShowLabel.text = "\(resp.code ?? -1000)";
            }
        };
    }
    
    //GET
    func testSyncGETRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        let resp = HKRest.get(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/get";
            request.headers = headers;
            request.parameters = parameters as [String : AnyObject];
        }).asString(error: &error);
        print(resp.code ?? "");
        print(resp.headers ?? "");
        print(resp.rawBody ?? "");
        print(resp.body ?? "");
        print(error ?? "");
        self.testShowLabel.text = "\(resp.code ?? -1000)";
    }
    
    func testAsyncGETRequest(){
        HKRest.get(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/get";
            request.username = "";
            request.password = "";
        }).asStringAsync(response: { (resp: HKStringResponse, error: NSError?) in
            print(resp.code);
            print(resp.headers);
            print(resp.rawBody);
            print(resp.body);
            print(error);
            DispatchQueue.main.sync {
                self.testShowLabel.text = "\(resp.code)";
            }
        });
    }
    
    //POST
    func testSyncPOSTRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let file = NSURL(string: Bundle.main.path(forResource: "asd", ofType: "png")!)!;
        let parameters = ["parameter": "value", "file": file] as [String : Any];
        
        let resp = HKRest.post(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            request.parameters = parameters as [String : AnyObject];
        }).asJson(error: &error);
        
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
        
        HKRest.post(config: { (request: HKParameterRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            request.parameters = parameters as [String : AnyObject];
            request.username = "";
            request.password = "";
            
        }).asJsonAsync(response: { (resp: HKJsonResponse, error: NSError?) in
            print(resp.code);
            print(resp.headers);
            print(resp.rawBody);
            print(resp.body);
            print(error);
            DispatchQueue.main.sync {
                self.testShowLabel.text = "\(resp.code)";
            }
        });
    }
    
    func testSyncPOSTEntityRequest(){
        var error: NSError? = nil;
        let headers = ["accept": "application/json"];
        let parameters = ["parameter": "value", "foo": "bar"];
        
        let resp = HKRest.post(config: { (request: HKBodyRequest) in
            request.url = "http://httpbin.org/post";
            request.headers = headers;
            do {
                request.body = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0)) as NSData;
            } catch {}
            
        }).asJson(error: &error);
        
        print(resp.code);
        print(resp.headers);
        print(resp.rawBody);
        print(resp.body);
        print(error ?? "");
        self.testShowLabel.text = "\(resp.code)";
    }
    
    //
    
}

