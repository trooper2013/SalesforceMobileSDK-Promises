# SalesforceMobileSDK-Promises

This SDK is a wrpper around SalesforceMobileSDK with PromiseKit adaptations. You can now use promises for these SDK components:

Promises make coding asynchronous APIs simple and readable. Instead of jumping back into Objective-C to use nested block handlers, you simply define the callbacks as inline extensions of the main call. For example, to make a REST API call:

```swift
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

Or, to perform a SmartSync `syncDown()` operation:

```swift
firstly {
let syncDownTarget = SoqlSyncDownTarget.newSyncTarget(soqlQuery)
let syncOptions    = SyncOptions.newSyncOptions(forSyncDown: SyncStateMergeMode.overwrite)
syncManager.promises.syncDown(target: syncDownTarget, options: syncOptions, soupName: CONTACTS_SOUP)
}
.then { syncState -> Promise<UInt> in
let querySpec =  QuerySpec.Builder(soupName: CONTACTS_SOUP)
.queryType(value: "range")
.build()
return (store.promises.count(querySpec: querySpec))!
}
.then { count -> Promise<Void>  in
return new Promise(())
}
.done { syncStateStatus in
}
.catch { error in
}
```

To learn more about promises and the PromiseKit SDK, see the [PromiseKit Readme](https://github.com/mxcl/PromiseKit/blob/master/README.md).

