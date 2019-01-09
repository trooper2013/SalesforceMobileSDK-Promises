/*
 SFUserAccountManagerExtensions
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

/** An Extension of SFUserAccountManager. Provides SFUserAccountMnager api(s) wrapped in Promises.
 ```
 var userManager = SFUserAccountManager.sharedInstance()
 userManager.Promises.login()
 .then { account in
    //account represents the logged in user
    // SFUserAccountManager.sharedInstance().currentUser = account
 }
 .then {
    userManager.Promises.logout()
 }
 ```
 */
extension UserAccountManager {
    
    public var promises : Promises {
        return Promises()
    }
    
    /// SFUserAccountManagerPromises Available api(s) wrapped in promises
    public struct Promises {
       
        init() {
        }
        /**
         Login API wrapped in a promise.
        
         ```
         SFUserAccountManager.sharedInstance().Promises.login()
         .then { account in
             ...
         }
         
         ```
         - Returns: A Promise with SFUserAccount
         */
        public func login() -> Promise<UserAccount> {
            return Promise {  resolver in
                UserAccountManager.shared.login(onSuccess: { (oauthInfo, userAccount) in
                    resolver.fulfill(userAccount)
                }, onFailure: { (oauthInfo, error) in
                        resolver.reject(error)
                })
            }
        }
        
        /**
         Refresh Credentials API wrapped in a promise.
         
         ```
         SFUserAccountManager.sharedInstance().Promises.refresh(credentials)
         .then { account in
         ...
         }
         
         ```
         - Parameter credentials: The Credentials to refresh.
         - Returns: A Promise with SFUserAccount
         */
        public func refresh(credentials: OAuthCredentials) -> Promise<UserAccount>  {
            return Promise {  resolver in
                UserAccountManager.shared.refresh(using: credentials, onSuccess: { (authInfo, userAccount) in
                    resolver.fulfill(userAccount)
                }, onFailure: { (authInfo, error) in
                    resolver.reject(error)
                })
            }
        }
        
        /**
         Logout wrapped in a promise.
         
         ```
         SFUserAccountManager.sharedInstance().Promises.logout()
         .then {
            // cleanup
         }
         
         ```
         - Returns: A Promise in order to allow further chaining
         */
        public func logout() -> Promise<Void> {
            return Promise { resolver in
                UserAccountManager.shared.logout()
                resolver.fulfill(())
            }
        }
        
        /**
         LogoutAllusers wrapped in a promise.
         
         ```
         SFUserAccountManager.sharedInstance().Promises.logoutAllUsers()
         .then {
            // cleanup
         }
         
         ```
         - Returns: A Promise in order to allow further chaining
         */
        public func logoutAllUsers() -> Promise<Void> {
            return Promise { resolver in
                UserAccountManager.shared.logoutAllUsers()
                resolver.fulfill(())
            }
        }
        
        /**
         LogoutUser API wrapped in a promise.
         
         ```
         SFUserAccountManager.sharedInstance().Promises.logoutUser(user)
         .then {
             // cleanup
         }
         
         ```
         - Parameter userAccount: The user to logout.
         - Returns: A Promise in order to allow further chaining
         */
        public func logoutUser(userAccount: UserAccount) -> Promise<Void> {
            return Promise { resolver in
                UserAccountManager.shared.logout(userAccount)
                resolver.fulfill(())
            }
        }
        
        /**
         SwitchToUser API wrapped in a promise.
         
         ```
         SFUserAccountManager.sharedInstance().Promises.switchToUser(user)
         .then { switchedUser in
            ...
         }
         
         ```
         - Parameter userAccount: The user to logout.
         - Returns: A Promise with the newly switched current user
         */
        public func switchToUser(userAccount: UserAccount) -> Promise<UserAccount> {
            return Promise { resolver in
                UserAccountManager.shared.switchToUserAccount(userAccount)
                resolver.fulfill(userAccount)
            }
        }
        
        /**
         SwitchToNewUser API wrapped in a promise. Clears current user if the switch
         
         ```
         SFUserAccountManager.sharedInstance().Promises.switchToNewUser()
         .then { newUser in
         ...
         }
         
         ```
         - Returns: A Promise with the newly logged-in current user
         */
        public func switchToNewUser() -> Promise<UserAccount> {
            return Promise<UserAccount> { resolver in
                self.login().then { newUser -> Promise<UserAccount>  in
                    UserAccountManager.shared.switchToUserAccount(newUser)
                    return Promise { resolver in
                        resolver.fulfill(newUser)
                    }
                }.catch { error in
                    return resolver.reject(error)
                }
            }
        }
    }
}
