/*
 SalesforceSwiftSDKManager
Created by Raj Rao on 11/29/17.
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
import SmartSync

/** Subclass of SalesforceSDKManager. Initialize and launch the SDK using the Builder. The Builder provides a fluent api to configure and launch the SalesforceSwiftSDKManager
 ```
     SalesforceSwiftSDKManager.initSDK().Builder.configure { (appconfig: SFSDKAppConfig) -> Void in
         appconfig.oauthScopes = ["web", "api"]
         appconfig.remoteAccessConsumerKey = "Your Apps Remote Access Consumer Key"
         appconfig.oauthRedirectURI = "yourapp://redirect"
     }.postInit {
        // code to execute after init
     }.postLaunch { (launchActionList: SFSDKLaunchAction) in
        //some post launch code
     }.postLogout {
        // code to handle user logout
     }.switchUser { (fromUser: SFUserAccount?, toUser: SFUserAccount?) -> () in
        // code to handle user switching
     }.launchError { (error: Error, launchActionList: SFSDKLaunchAction) in
        // code to handle errors during launch
     }.done()
 ```
*/
public class SalesforceSwiftSDKManager: SmartSyncSDKManager {
    
    /// App type is set to native swift
    override public var appType: AppType {
        return AppType.nativeSwift;
    }
    
    /// Initialize the SDK Manager.
    public class func initializeSDK() -> SalesforceSwiftSDKManager.Type {
        self.initializeSDK(manager: SalesforceSwiftSDKManager.self)
        return SalesforceSwiftSDKManager.self
    }
    
}

