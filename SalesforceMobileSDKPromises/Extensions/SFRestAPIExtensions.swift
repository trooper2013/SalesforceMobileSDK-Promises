/*
 SFRestAPIExtensions
 Created by Raj Rao on 11/27/17.
 
 Copyright (c) 2017-present, salesforce.com, inc. All rights reserved.
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import Foundation
import PromiseKit
import SalesforceSDKCore

/** SFRestResponse is  a struct representing the response for all SFRestAPI promise api(s).
 
 ```
 let restApi  = SFRestAPI.sharedInstance()
 restApi.Promises.query(soql: "SELECT Id,FirstName,LastName FROM User")
 .then { request in
    restApi.Promises.send(request: request)
 }
 .done { sfRestResponse in
    restResponse = sfRestResponse.asJsonDictionary()
    ...
 }
 .catch { error in
    //handle error
 }
 ```
 */
public struct SFRestResponse {
    
    private (set) var data : Data?
    private (set) var urlResponse : URLResponse?
    
    init(data: Data?,response: URLResponse?) {
        self.data = data
        self.urlResponse = response
    }
    
    /// Parse response as a Dictionary
    ///
    /// - Returns: Dictionary of Name/Values
    public func asJsonDictionary() -> [String: Any] {
        guard let rawData = data,data!.count > 0 else {
            return [String:Any]()
        }
        let jsonData = try! JSONSerialization.jsonObject(with: rawData, options: []) as! Dictionary<String, Any>
        return jsonData
    }
    
    
    /// Parse response as an Array of Dictionaries
    ///
    /// - Returns: response as an Array of Dictionaries
    public func asJsonArray() -> [[String: Any]] {
        guard let rawData = data,data!.count > 0 else {
            return [[String: Any]]()
        }
        let jsonData = try! JSONSerialization.jsonObject(with: rawData, options: []) as! [Dictionary<String, Any>]
        return jsonData
    }
    
    /// Return the raw data response
    ///
    /// - Returns: Raw Data
    public func asData() -> Data? {
       return self.data
    }
    
    /// Parse response as String
    ///
    /// - Returns: String
    public func asString() -> String {
        guard let rawData = data,data!.count > 0 else {
            return ""
        }
        let jsonData = String(data: rawData, encoding: String.Encoding.utf8)
        return jsonData!
    }
    
    /// Parse and unmarshall the response as a Decodable
    ///
    /// - Parameter type: type of Decodable
    /// - Returns: Decodable
    public func asDecodable<T:Decodable>(type: T.Type) -> Decodable? {
        guard let rawData = data,data!.count > 0 else {
            return nil
        }
        let decoder = JSONDecoder()
        return try! decoder.decode(type, from: rawData)
    }
}

/** Extension for SFRestAPI. Provides api(s) wrapped in promises.
 
 ```
 let restApi  = SFRestAPI.sharedInstance()
 restApi.Promises.query(soql: "SELECT Id,FirstName,LastName FROM User")
 .then { request in
    restApi.Promises.send(request: request)
 }
 .done { sfRestResponse in
    restResponse = sfRestResponse.asJsonDictionary()
    ...
 }
 .catch { error in
   //handle error
 }
 ```
 */
enum RestClientError : Error {
    case RestClientInvalidState
}

extension RestClient {
    
    public var promises: Promises {
        get{
            return Promises(api: self)
        }
    }
    /// SFRestAPI promise api(s)
     public struct Promises {
        
        weak var api: RestClient?
        
        init(api: RestClient) {
            self.api = api
        }
        
        
        /**
         Send api wrapped in a promise.
         
         ```
         let restApiPromises = RestClient.shared.promises
         let request = RestClient.shared.requestForDescribe(withObjectType: "Account")
       restApiPromises.then { request in
         restApi.send(request: request)
         }
         .done { sfRestResponse in
         var restResponse = sfRestResponse.asJsonDictionary()
         ...
         }
         .catch { error in
         restError = error
         }
         ```
         
         ```
         let restApiPromises = RestClient.shared.promises
         let request = RestClient.shared.request(forQuery: "")
         restApiPromises.send(request: request) {
         
         } .done { sfRestResponse in
         var restResponse = sfRestResponse.asDecodable(Account.Type)
         ...
         }
         .catch { error in
         restError = error
         }
         ```
         - parameters:
            - request: SFRestRequest to send.
         - Returns: The instance of Promise<SFRestResponse>.
         */
        public func send(request :RestRequest) -> Promise<SFRestResponse> {
            return Promise {  resolver in
                
                guard let api = self.api else {
                    resolver.reject(RestClientError.RestClientInvalidState)
                    return
                }
                
                request.parseResponse = false
                api.send(request: request, onFailure: { (error, urlResponse) in
                    resolver.reject(error!)
                }, onSuccess: { (data, urlResponse) in
                    resolver.fulfill(SFRestResponse(data: data as? Data,response: urlResponse))
                })
            }
        }
        
    }
    
}
