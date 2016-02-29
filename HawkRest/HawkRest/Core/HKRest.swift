//
//  UKRest.swift
//  HawkRest
//
//  Created by cz on 1/28/16.
//  Copyright © 2016 cz. All rights reserved.
//

//const
public enum HKHTTPMethod: Int
{
    case HEAD           = 0;
    case GET            = 1;
    case POST           = 2;
    case PUT            = 3;
    case DELETE         = 4;
    case PATCH          = 5;
};

typealias ParameterRequest = (parameterRequest: HKParameterRequest) -> Void;
typealias BodyRequest = (entityRequest: HKBodyRequest) -> Void;

class HKRest {
    //
    private static var defaultHeaders: [String:String] = [String:String]();
    private static var defaultTimeout: Int = 60;
    
    class func timeout(seconds: Int) -> Void
    {
        //
        defaultTimeout = seconds;
    }
    class func timeout() -> Int
    {
        //
        return defaultTimeout;
    }
    class func defaultHeader(name: String, value: String) -> Void
    {
        //
        defaultHeaders[name]=value;
    }
    class func defaultHeader() -> [String:String]
    {
        return defaultHeaders;
    }
    
    private class func getConfig<T>(instance: T, config:((T) -> Void)) -> T
    {
        //
        config(instance);
        return instance;
    }
    
    class func head(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .HEAD, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func get(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .GET, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func post(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .POST, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func post(config: BodyRequest) -> HKCore
    {
        let _config = getConfig(HKBodyRequest(), config:config);
        return HKCore(httpMethod: .POST, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, body: _config.body);
    }
    class func put(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .PUT, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func put(config: BodyRequest) -> HKCore
    {
        let _config = getConfig(HKBodyRequest(), config:config);
        return HKCore(httpMethod: .PUT, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, body: _config.body);
    }
    class func patch(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .PATCH, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func patch(config: BodyRequest) -> HKCore
    {
        let _config = getConfig(HKBodyRequest(), config:config);
        return HKCore(httpMethod: .PATCH, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, body: _config.body);
    }
    class func delete(config: ParameterRequest) -> HKCore
    {
        let _config = getConfig(HKParameterRequest(), config:config);
        return HKCore(httpMethod: .DELETE, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, parameters: _config.parameters);
    }
    class func delete(config: BodyRequest) -> HKCore
    {
        let _config = getConfig(HKBodyRequest(), config:config);
        return HKCore(httpMethod: .DELETE, url: _config.url, headers: _config.headers, username: _config.username, password: _config.password, body: _config.body);
    }
}








