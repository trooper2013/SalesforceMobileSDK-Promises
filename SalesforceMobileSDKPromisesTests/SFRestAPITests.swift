/*
 SFRestAPITests
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
import XCTest
import SalesforceSDKCore
import PromiseKit
@testable import SalesforceMobileSDKPromises

class SFRestAPITests: SalesforceSwiftSDKBaseTest {
  
    override class func setUp() {
        super.setUp()
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }
    
    override class func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQuery() {
        
        var restResonse : Dictionary<String, Any>?
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        let exp = expectation(description: "restApi")
        let request = restApi.request(forQuery: "SELECT Id,FirstName,LastName FROM User")
            //.promises.query(soql: "SELECT Id,FirstName,LastName FROM User")
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asJsonDictionary()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
        
    }
    
    func testQueryAll() {
        
        var restResonse : Dictionary<String, Any>?
        var restError : Error?
        
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let request = restApi.request(forQueryAll: "SELECT Id,FirstName,LastName FROM User")
        let exp = expectation(description: "restApi")
        
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asJsonDictionary()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
        
    }
    
    func testDescribeGlobal() {
        
        var restResonse : Dictionary<String, Any>?
        var restError : Error?
        
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let request = restApi.requestForDescribeGlobal()
        let exp = expectation(description: "restApi")
        
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asJsonDictionary()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
        
    }
    
    func testDescribeObject() {
        
        var restResonse : Dictionary<String, Any>?
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let request = restApi.requestForDescribe(withObjectType: "Account")
        let exp = expectation(description: "restApi")
        
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asJsonDictionary()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
    }
    
    func testDescribeObjectAsString() {
        
        var restResonse : String?
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let request = restApi.requestForDescribe(withObjectType: "Account")
        let exp = expectation(description: "restApi")
       
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asString()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
    }
    
    func testCreateUpdateQueryDelete() {
        
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let request = restApi.requestForCreate(withObjectType:"Contact", fields:["FirstName": "John",
                                                                                 "LastName": "Petrucci"])
        let exp = expectation(description: "restApi")
        let restApiPromises = restApi.promises
        restApi.promises.send(request: request)
            .then { sfRestResponse -> Promise<SFRestResponse> in
            let restResonse = sfRestResponse.asJsonDictionary()
            XCTAssertNotNil(restResonse)
            XCTAssertNotNil(restResonse["id"])
           let nextRequest = restApi.requestForRetrieve(withObjectType: "Contact", objectId: restResonse["id"] as! String, fieldList: "FirstName,LastName")
            return restApiPromises.send(request: nextRequest)
        }
        .then {  (restResonse) -> Promise<SFRestResponse> in
            XCTAssertNotNil(restResonse)
            let restResonse = restResonse.asJsonDictionary()
            let nextRequest = restApi.requestForUpdate(withObjectType: "Contact", objectId: restResonse["Id"] as! String, fields: ["FirstName" : "Steve","LastName" : "Morse"])
            return restApiPromises.send(request: nextRequest)
        }
        .then { data -> Promise<SFRestResponse> in
            XCTAssertNotNil(data)
            let nextRequest = restApi.request(forQuery: "Select Id,FirstName,LastName from Contact where LastName='Morse'")
            return restApiPromises.send(request: nextRequest)
        }
        .then { (sfRestResponse) -> Promise<SFRestResponse> in
            let restResonse = sfRestResponse.asJsonDictionary()
            XCTAssertNotNil(restResonse)
            XCTAssertNotNil(restResonse["records"])
            var records: [Any] = restResonse["records"] as! [Any]
            var record: [String:Any] = records[0] as! [String:Any]
            let nextRequest =  restApi.requestForDelete(withObjectType: "Contact", objectId: record["Id"] as! String)
            return restApiPromises.send(request: nextRequest)
        }.done { sfRestResponse in
            let strResp = sfRestResponse.asJsonDictionary()
            XCTAssertNotNil(strResp)
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30)
        XCTAssertNil(restError)
    }
    
    func testSearch() {
        var restResonse : Dictionary<String, Any>?
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let exp = expectation(description: "restApi")
        let request = restApi.request(forSearch: "FIND {blah} IN NAME FIELDS RETURNING User")
       
        restApi.promises.send(request: request)
        .done { sfRestResponse in
            restResonse = sfRestResponse.asJsonDictionary()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
    }
    
    func testSearchScopeAndOrder() {
        var restResonse : [Dictionary<String, Any>]?
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        
        let exp = expectation(description: "restApi")
        let request = restApi.requestForSearchScopeAndOrder()
        
        restApi.promises.send(request: request)
        .done { (sfRestResponse) in
            restResonse = sfRestResponse.asJsonArray()
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        XCTAssertNil(restError)
        XCTAssertNotNil(restResonse)
    }
    
    func testQueryDecodable() {
        
        var restError : Error?
        let restApi  = RestClient.shared
        XCTAssertNotNil(restApi)
        let exp = expectation(description: "restApi")
        let request = restApi.requestForCreate(withObjectType: "Contact",fields:["FirstName": "John",
            "LastName": "Petrucci"])
        // create, uodate ,query delete chain
       
        restApi.promises.send(request: request)
        .then { (sfRestResponse) -> Promise<SFRestResponse> in
            let restResonse = sfRestResponse.asJsonDictionary()
            XCTAssertNotNil(restResonse)
            XCTAssertNotNil(restResonse["id"])
            let nextRequest =  restApi.request(forQuery: "Select Id,FirstName,LastName from Contact where LastName='Petrucci'")
            return restApi.promises.send(request: request)
        }
        .then { (sfRestResponse) -> Promise<QueryResponse<SampleRecord>> in
            let restResonse = sfRestResponse.asDecodable(type: QueryResponse<SampleRecord>.self) as!  QueryResponse<SampleRecord>
            XCTAssertNotNil(restResonse)
            return .value(restResonse)
            // update
        }
        .done { response in
            XCTAssertNotNil(response)
            exp.fulfill()
        }
        .catch { error in
            restError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 30)
        XCTAssertNil(restError)
    }
    
    
    func generateRecordName() -> String {
        let timecode: TimeInterval = Date.timeIntervalSinceReferenceDate
        return "RestClientSwiftTestsiOS\(timecode)"
    }
    
}
