/*
 SalesforceTestExtensions
 Created by Raj Rao on 11/30/17.
 
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
import SalesforceMobileSDKPromises
import XCTest

protocol ProtocolStoredProperty {
    associatedtype T
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
}

public extension Decodable {
    public static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

public extension Encodable {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}

extension ProtocolStoredProperty {
    public func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
    
    public func setAssociatedObject(storedProperty: UnsafeRawPointer!, newValue: T) {
        objc_setAssociatedObject(self, storedProperty, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

protocol Defaultable {
    static var defaultValue: Self { get }
}

extension Optional where Wrapped: Defaultable {
    var unwrappedValue: Wrapped { return self ?? Wrapped.defaultValue }
}

extension String: Defaultable {
    static var defaultValue: String { return "test_credentials" }
}

struct State  {
    var appConfig: BootConfig?
    var currentUser: UserAccount?
}

struct TestConfig: Codable {
    
    var accessToken: String
    var testClientId: String
    var testLoginDomain: String
    var testRedirectUri: String
    var refreshToken: String
    var instanceUrl: String
    var identityUrl: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case testClientId = "test_client_id"
        case testLoginDomain = "test_login_domain"
        case testRedirectUri = "test_redirect_uri"
        case refreshToken = "refresh_token"
        case instanceUrl = "instance_url"
        case identityUrl = "identity_url"
    }
    
    init(accessToken: String, testClientId: String,
         testLoginDomain: String, testRedirectUri: String,
         refreshToken: String, instanceUrl: String,
         identityUrl: String) {
        self.accessToken = accessToken
        self.testClientId = testClientId
        self.testLoginDomain = testLoginDomain
        self.testRedirectUri = testRedirectUri
        self.refreshToken = refreshToken
        self.instanceUrl = instanceUrl
        self.identityUrl = identityUrl
    }
}
extension String {
    
    func toBool() -> Bool {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
}

extension SalesforceManager : ProtocolStoredProperty  {
    
    typealias T = State
    
    private struct DefaultProperties {
        static var state:State?
    }
    
    var state: State {
        get {
            return getAssociatedObject(&DefaultProperties.state, defaultValue: State())
        }
        set {
            return setAssociatedObject(storedProperty: &DefaultProperties.state, newValue: newValue)
        }
    }
    
    func saveState() -> Void {
        var oldState = State()
        oldState.appConfig = self.bootConfig
        oldState.currentUser = UserAccountManager.shared.currentUserAccount
        self.state = oldState
    }
    
    func restoreState() -> Void {
        self.bootConfig = state.appConfig
        UserAccountManager.shared.currentUserAccount =  state.currentUser
        state = State()
    }
}

struct  TestContext {
    var credential: OAuthCredentials?
    var testConfig: TestConfig?
}

extension XCTestCase  : ProtocolStoredProperty {
    
    typealias T = TestContext
    
    private struct BackedProperties {
        static var testContext: TestContext?
    }
    
    var testContext: TestContext {
        get {
            return getAssociatedObject(&BackedProperties.testContext, defaultValue: TestContext())
        }
        set {
            return setAssociatedObject(storedProperty: &BackedProperties.testContext, newValue: newValue)
        }
    }
    
    class func readConfigFromFile(configFile: String?) -> Promise<TestConfig> {
        return Promise {  seal in
            
            let config: TestConfig = TestConfig(accessToken: "", testClientId: "", testLoginDomain: "", testRedirectUri: "", refreshToken: "", instanceUrl: "", identityUrl: "")
            if let url = Bundle.main.url(forResource: configFile.unwrappedValue, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let jsonData = try TestConfig.decode(data: data)
                    return seal.fulfill(jsonData)
                } catch{
                    return seal.reject(error)
                }
            }
            return seal.fulfill(config)
        }
    }
    
    class func refreshCredentials(credentials: OAuthCredentials) -> Promise<UserAccount> {
        return UserAccountManager
            .shared.promises
            .refresh(credentials: credentials)
    }
    
    class func waitForCompletion(maxWaitTime: TimeInterval, evaluate: @escaping () -> Bool) -> Void {
        let startTime = Date()
        while (evaluate()==false) {
            let elapsed: TimeInterval = Date().timeIntervalSince(startTime)
            if elapsed > maxWaitTime {
                SalesforceSwiftLogger.d(SalesforceSwiftSDKTests.self, message: "Request took too long to complete.")
                return
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
//    func createNewUser(indx: Int) -> UserAccount {
//        let kUserIdFormatString = "005R0000000Dsl"
//        let kOrgIdFormatString =  "00D000000000062EA"
//        let credentials = OAuthCredentials(identifier: "identifier-\(UInt(indx))", clientId: "fakeClientIdForTesting", encrypted: true)
//        let user = UserAccount(credentials: credentials!)
//        let userId = String(format: kUserIdFormatString, UInt(indx))
//        let orgId = String(format: kOrgIdFormatString, UInt(indx))
//        user.credentials.identityUrl = URL(string: "https://test.salesforce.com/id/\(orgId)/\(userId)")
//        try! UserAccountManager.shared..saveAccount(forUser: user)
//        return user
//    }
    
}
