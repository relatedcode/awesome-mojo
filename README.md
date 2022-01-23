# iOS SDK

## What is this?

GQLite iOS SDK is a toolkit to work with GraphQL servers easily. It also provides several other features to make life easier during iOS application development.

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

### CocoaPods

To use GraphQLite with [CocoaPods](https://cocoapods.org) specify in your `Podfile`:

```sh
pod 'GraphQLite'
```

## Local Database

The Local Database manager runs on top of [SQLite](https://sqlite.org/faq.html). GraphQLite provides a lightweight Swift wrapper around SQLite.

### Connect to a Database

```swift
import GraphQLite

let db = GQLDatabase()
```

You can also specify the database filename or the complete path. The default filename `database.sqlite`, and the default path is `Library/Application Support`.

```swift
let db = GQLDatabase(file: "db.sqlite")
```

```swift
let db = GQLDatabase(path: "yourpath/db.sqlite")
```

### Define Object

GraphQLite provides a protocol that helps to manipulate database rows as regular objects.

```swift
class User: NSObject, GQLObject {

  @objc var userId = 0
  @objc var name = ""
  @objc var age = 0
  @objc var approved = false

  class func primaryKey() -> String {
    return "userId"
  }
}
```

By creating the User class above, GraphQLite will automatically create the following SQLite Table for you:

```sql
CREATE TABLE IF NOT EXISTS User (userId INTEGER PRIMARY KEY NOT NULL, name TEXT, age INTEGER, approved INTEGER);
```

> **Note**: Since all the GQLObject class property names will be used in SQLite commands, try to avoid using [SQLite keywords](https://sqlite.org/lang_keywords.html) in your class definition.

### Insert Object

Using the User class above, creating an object would look like this:

```swift
let user = User()

user.userId = 1001
user.name = "John Smith"
user.age = 42
user.approved = false

user.insert(db)
```

### Update Object

An existing object can be updated:

```swift
user.age = 43

user.update(db)
```

### Insert vs. Update

If you are not 100% sure if an object already exists in the database or not, then you can use the following methods as well:

```swift
user.insertUpdate(db)
```

It will try to execute the INSERT command first and if it fails (silently), then executes the UPDATE command.

Also, you can use

```swift
user.updateInsert(db)
```

which will try to execute the UPDATE command first and if it fails (silently), then executes the INSERT command.

### Delete Object

An existing object can be deleted:

```swift
user.delete(db)
```

### Fetch Object(s)

Fetching one object would look like:

```swift
let user = User.fetchOne(db, key: 1001)
```

Fetching multiple objects can be done in the following ways:

```swift
let users = User.fetchAll(db)

let users = User.fetchAll(db, "age > 40")

let users = User.fetchAll(db, "age = ?", [42])

let users = User.fetchAll(db, "age >= :min AND age <= :max", [":min": 18, ":max": 99])
```

You can also use the `limit` and `offset` parameters.

```swift
let users = User.fetchAll(db, limit: 10)

let users = User.fetchAll(db, "age > 40", limit: 5, offset: 10)
```

### Serial Execution, Thread Safety

The database write actions are serialized. This means, the Insert, Update and Delete actions will be executed one after the other (managed by GraphQLite) automatically.

The Fetch methods are thread-safe. This means you will have back the results in the same thread you have initiated the request from.

> **Note**: You can initiate both read and write actions from any thread you like.

### Data Types

GraphQLite can manage the following data types: `Bool`, `Int8`, `Int16`, `Int32`, `Int64`, `Int`, `Float`, `Double`, `String`, `Date`, `Data`.

### Date Format

The `Date` values will be stored in the database as ISO formatted `String`. The default format is ISO 8601 ("1970-01-01T01:01:01.000Z"), produced by the `ISO8601DateFormatter` class.

You can also specify your own date format by using:

```swift
let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.timeZone = TimeZone(secondsFromGMT: 0)
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

GQLDate.custom(formatter)
```

> **Note**: You only need to specify the date format once in your codebase. Practically before doing any database action.

### Values Dictionary

Although managing the database rows as objects is an easy and elegant way, you might want to manage the data as `Dictionary` instead.

**Insert** *(using Dictionary)*

Insert a new object as Disctionary:

```swift
let values: [String: Any] = ["userId": 1001, "name": "John Smith", "age": 42, "approved": false]

db.insert("User", values)
```

**Update** *(using Dictionary)*

Update an existing object as Dictionary:

```swift
let values: [String: Any] = ["userId": 1001, "age": 43]

db.update("User", values)
```

The primary key must be included in the values Dictionary. Otherwise, nothing will happen.

**Fetch Result(s)** *(as Dictionary)*

Fetching one object as Dictionary:

```swift
let user = db.fetchOne("User", key: 1001)
```

In this case, the result type will be a `[String: Any]`.

Fetching multiple objects as Dictionary:

```swift
let users = db.fetchAll("User")

let users = db.fetchAll("User", "age > 40")

let users = db.fetchAll("User", "age = ?", [42])

let users = db.fetchAll("User", "age >= :min AND age <= :max", [":min": 18, ":max": 99])
```

In the cases above, the result types will be a `[[String: Any]]`.

**Convert Object** *(to Dictionary)*

Convert an existing object to Dictionary:

```swift
let values = user.values()
```

**Date Values** (in Dictionary)

When using a values dictionary (to insert or update data), the Date values can be placed into the Dictionary as both `Date` or ISO formatted `String`.

When fetching data (as dictionary), the Date values will always be represented in the Dictionary as ISO formatted `String`.

### Batch Update

You can update multiple objects by specifying a condition.

```swift
let values = ["approved": true]

User.updateAll(db, values, "age >= ? AND age <= ?", [30, 35])
```

Alternatively, update one object by specifying the primary key value.

```swift
let values = ["approved": true]

User.updateOne(db, values, key: 1001)
```

### Batch Delete

You can delete multiple objects by specifying a condition.

```swift
User.deleteAll(db, "age >= ? AND age <= ?", [30, 35])
```

Alternatively delete one object by specifying the primary key value.

```swift
User.deleteOne(db, key: 1001)
```

### Count Objects

You can get the number of objects by specifying a condition.

```swift
let count = User.count(db)

let count = User.count(db, "age > 40")

let count = User.count(db, "age >= ? AND age <= ?", [30, 35])
```

### Check Objects

You can check whether an object exists or not (by specifying the primary key value).

```swift
if (User.check(db, key: 1001)) {
  // do something	
}
```

Or you check whether a set of objects exist or not (by specifying a condition).

```swift
if (User.check(db, "age >= ? AND age <= ?", [30, 35])) {
  // do something	
}
```

### Create Observer

For refreshing the user interface upon database changes, you can use the Database Observers.

Checking all the possible changes for the User class would be:

```swift
let types: [GQLObserverType] = [.insert, .update, .delete]

let observerId = User.createObserver(db, types) { method, objectId in
  // do something
}
```

However you can narrow down the number of changes by using a condition:

```swift
let observerId = User.createObserver(db, types, "OBJ.age > 40") { method, objectId in
  // do something
}
```

Also you can check only specific database changes (separated or combined) by using the following Observer types: `.insert`, `.update`, `.delete`.

To get notified about new users, but not the updated and/or deletes ones:

```swift
let observerId = User.createObserver(db, .insert) { method, objectId in
  // do something
}
```

Or to get notified about deleted users dedicated would look like this:

```swift
let observerId = User.createObserver(db, .delete) { method, objectId in
  // do something
}
```

### Remove Observer

Once a Database Observer no longer required, you can remove it by using:

```swift
User.removeObserver(db, observerId)
```

### Execute Plain SQL

If you would ever need it, you can execute plain SQL commands.

```swift
db.execute("DELETE FROM User WHERE age = 42;")
```

### Drop Table, Create Table

Although the SQLite tables are created automatically, you can also DROP and/or CREATE tables manually.

```swift
db.dropTable("User")

db.createTable("User")
```

In these cases, the `User` class also needs to be defined first.

### Cleanup Database

If you would ever need, all the tables can be destroyed and recreated by using:

```swift
db.cleanupDatabase()
```

### Error Handling

The crucial issues will cause a `fatalError`, every other situation will be reported in the Xcode output window.

You can alter the debug level by using:

```swift
GQLDebug.level(.none)

GQLDebug.level(.error)

GQLDebug.level(.all)
```

## GraphQL Interface

You can connect to single or multiple GraphQL servers with GraphQLite easily. These server connections can be used for Queries, Mutations, and Subscriptions.

### Connect to a Server

You can connect to an HTTP or a WebSocket GraphQL endpoint separated.

```swift
import GraphQLite

let server = GQLServer(HTTP: "https://yourserver.com/graphql")
```

```swift
let server = GQLServer(WebSocket: "wss://yourserver.com/graphql")
```

If your server supports both HTTP and WebSocket protocols, then you can use the following method:

```swift
let server = GQLServer(HTTP: "https://yourserver.com/graphql", WebSocket: "wss://yourserver.com/graphql")
```

If you need extra headers for the setup, then you can connect like:

```swift
let link = "https://yourserver.com/graphql"
let headers = ["authorization": "Basic PXzpEZW1vOnNlcnZlB1VGJjMF8zRHM3UWVvSExMcHV"]
let server = GQLServer(HTTP: link, headers: headers)
```

In some cases (like Amazon AppSync) the server connection requires special implementation. To make life easier you can connect to AppSync like this:

```swift
let key = "da2-12345678901234567890123456"
let link = "https://example1234567890000.appsync-api.us-east-2.amazonaws.com/graphql"
let server = GQLServer(AppSync: link, key: key)
```

An other example connecting to a Hasura server:

```swift
let link = "https://your-server-name.hasura.app/v1/graphql"
let secret = "EENWfDvVem9y9urmvyoLRK1YDYENISVnTskZOpcfv6"
let server = GQLServer(Hasura: link, secret: secret)
```

### WebSocket Connection

If you are using a WebSocket connection, you need to call the `connect()` method before initiating a subscription.

```swift
server.connect() { error in
  if (error == nil) {
    // do something
  }
}
```

The WebSocket connection can be closed by using the `disconnect()` method.

```swift
server.disconnect()
```

### Mutation

Once you have a live server connection, you can initiate a mutation like:

```swift
server.mutation(query, variables) { result, error in
  if (error == nil) {
    // do something
  }
}
```

The `query` parameter type should be a `String`, containing a valid mutation for your server.

```swift
let query = """
mutation CreateObject($objectId: String, $text: String, $number: Int) {
  createObject(data: {objectId: $objectId, text: $text, number: $number}) {
    objectId, text, number
  }
}
"""
```

The `variables` parameter type should be `[String: Any]`, containing all the necessary variables for the mutation.

```swift
let variables: [String: Any] = ["objectId": "id111", "text": "abcdabcdabcd", "number": 123]
```

### Query

Initiating a query is also pretty straight forward:

```swift
server.query(query, variables) { result, error in
  if (error == nil) {
    // do something
  }
}
```

Where the `query` parameter is something like this:

```swift
let query = """
query ObjectQuery($number: Int) {
  listObjects(filter: {number: {gt: $number}}) {
    items {
      objectId, text, number
    }
  }
}
"""
```

And the `variables` parameter somethig like:

```swift
let variables: [String: Any] = ["number": 123]
```

### Subscription

Setting up a subscription is very similar to the previous implementations:

```swift
let subscriptionId = server.subscription(query, variables) { result, error in
  if (error == nil) {
    // do something
  }
}
```

Where the `query` parameter would look like:

```swift
let query = """
subscription ObjectSubscription($number: Int) {
  subscribeObjects(filter: {number: {gt: $number}}) {
    items {
      objectId, text, number
    }
  }
}
"""
```

And the `variables` parameter somethig like:

```swift
let variables: [String: Any] = ["number": 123]
```

When you no longer need a subscription, you can unsubscribe from it by using:

```swift
server.subscription(cancel: subscriptionId) { error in
  if (error == nil) {
    // do something
  }
}
```

### Query Library

If you prefer to keep all your mutations, queries and subscriptions in a common library, then you shall add one (or multiple) `*.graphql` file(s) into your Xcode project. The content of these files should be something like this:

```graphql
mutation CreateObject($object: CreateObjectsInput!) {
  createObjects(input: $object) {
    objectId, text, number, double, boolean, createdAt, updatedAt
  }
}

mutation UpdateObject($object: UpdateObjectsInput!) {
  updateObjects(input: $object) {
    objectId, text, number, double, boolean, createdAt, updatedAt
  }
}

query ObjectQuery($updatedAt: String) {
  listObjects(filter: {updatedAt: {gt: $updatedAt}}) {
    items {
      objectId, text, number, double, boolean, createdAt, updatedAt
    }
  }
}

subscription ObjectSubscription {
  onUpdateObjects {
    objectId, text, number, double, boolean, createdAt, updatedAt
  }
}
```

These `*.graphql` files will be managed automatically by GraphQLite, so whenever you need a query, mutation, or subscription in your codebase, you can have it like this:

```swift
let query = GQLQuery["CreateObject"]
```

```swift
let query = GQLQuery["ObjectQuery"]
```

```swift
let query = GQLQuery["ObjectSubscription"]
```

## Sync Engine

GraphQLite supports the offline-first application development approach. You can make all the database changes locally, and these changes will be synced automatically to the server whenever the network connection is live.

### Setup a Sync Engine

```swift
let server = GQLServer(HTTP: "https://yourserver.com/graphql")

let sync = GQLSync(server)
```

If you work with multiple servers, then you can set up multiple, separated Sync Engines for them.

> **Note**: Sync Engine manages only the server-side actions. You are responsible to make the local database changes.

### Lazy Sync

Let's assume you have a User object in the local database, and you have the same User data structure on the server. Also, the `GQLDatabase`, the `GQLServer`, and the `GQLSync` are ready to use, and all the User related mutations are saved in the `scheme.graphql` file.

In this case a User update (both local and remote) would look like this:

```swift
let values = ["userId": 1001, "age": 43]

sync.lazy("UpdateUser", values, 1001)

db.update("User", values)
```

The code above will update the User object in the local database, and schedule a UpdateUser mutation using the values dictionary as variables for the mutation.

If the device is online, then the server action will happen immediately. If the device is offline, then the server action will be scheduled for later.

The previously scheduled server actions will be executed one after the other once the device is back online.

If the same object mutation is scheduled multiple times in offline mode, then Sync Engine will only send the **latest version** to the server (once the device is back online).

> **Note**: By using Lazy Sync, the server actions will be executed one after the other even if the device is online.

### Steady Sync

The Steady sync works pretty much the same as the Lazy sync, but it sends all the changes to the server, regardless.

This means, if the same object mutation is scheduled multiple times in offline mode, then Sync Engine will send **all the changes** to the server (once the device is back online).

```swift
let values = ["userId": 1001, "age": 43]

sync.steady("UpdateUser", values, 1001)
```

```swift
let values = ["userId": 1001, "age": 44]

sync.steady("UpdateUser", values, 1001)
```

The above UpdateUser mutation will be sent to the server twice (with age 43 and with age 44).

> **Note**: By using Steady Sync, the server actions will be executed one after the other even if the device is online.

### Force Sync

The Force sync **does not** schedule the server action, but initiates the sever call immediately (if the network connection is live). No matter how many server actions you already have scheduled, the force sync will happen before all of them.

```swift
let values = ["userId": 1001, "age": 44]

sync.force("UpdateUser", values) { result, error in
  if (error == nil) {
    // do something
  }
}
```

## User Authentication

GraphQLite provides an integrated Auth0 implementation for user authentication.

### Connect to Auth0

After setting up your Auth0 server properly, you can connect to the server like this:

```swift
let domain = "yourserver.us.auth0.com"
let clientId = "JsRudIbFyau5LvWggWXagTRt5E6ktOK"
let clientSecret = "Rn8X261tbAH22x7-htFDpuR5HsrYYKgfzkcXh__TR0yU0V8vrzu7bvh1HdnTqQQl"
GQLAuth.setup(domain, clientId, clientSecret)
```

### Sign Up

You can sign up new users with email and password in the following way:

```swift
GQLAuth.signUp(email: email, password: password) { error in
  if (error == nil) {
    // do something
  }
}
```

### Sign In

A simple email and password sign-in would be:

```swift
GQLAuth.signIn(email: email, password: password) { error in
  if (error == nil) {
    // do something
  }
}
```

### Sign Out

And the sign out:

```swift
GQLAuth.signOut()
```

### Check Password

Before updating the password it's safe to check if the existing password is still valid:

```swift
GQLAuth.checkPassword(password: password) { error in
  if (error == nil) {
    // do something
  }
}
```

### Update Password

Updating the password can be initiated in the following way:

```swift
GQLAuth.updatePassword(password: password) { error in
  if (error == nil) {
    // do something
  }
}
```

## File Storage

GraphQLite provides an integrated Amazon S3 implementation for file storage.

### Connect to Amazon S3

After setting up your Amazon S3 server properly, you can connect to the server like this:

```swift
let secretKey = "AKRMO2I2ZDIA3DPPI2IS"
let accessKey = "G6HQk49TIEOxXNDVaXBBbI0LMAcpUstvjo+mQU6S"
let storage = GQLStorage(AmazonS3: "us-east-2", secretKey, accessKey)
```

You can have the `secretKey` and `accessKey` values by setting up an IAM user (using Programmatic access).

### File Upload

You can upload a file to Amazon S3:

```swift
let bucket = "yourbucket"
let key = "folder/filename.ext"

storage.upload(bucket, key, data) { error in
  if (error == nil) {
    // do something
  }
}
```

### File Download

You can download a file from Amazon S3:

```swift
let bucket = "yourbucket"
let key = "folder/filename.ext"

storage.download(bucket, key) { data, error in
  if (error == nil) {
    // do something
  }
}
```

### File Delete

You can delete a file at Amazon S3:

```swift
let bucket = "yourbucket"
let key = "folder/filename.ext"

storage.delete(bucket, key) { error in
  if (error == nil) {
    // do something
  }
}
```

## Push Notification

GraphQLite provides an integrated OneSignal implementation for sending push notifications.

### Connect to OneSignal

After setting up your OneSignal server properly, you can connect to the server like this:

```swift
let appId = "288d0aab-5925-985f-ba99-4be140556911"
let keyAPI = "LWEyNjgtYTdlNzYzNTk4NTM5MWQxZGZmNzMtMTc0ZS00N2U5"
GQLPush.setup(appId, keyAPI)
```

### Device Token

For the device token setup, please use the following in your AppDelegate:

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  GQLPush.token(deviceToken)
}
```

### Register User

After the user logged in successfully, the userId must be sent to OneSignal:

```swift
let userId = GQLAuth.userId()

GQLPush.register(userId)
```

### Unregister User

After logout, the user must be unregistered from OneSignal:

```swift
GQLPush.unregister()
```

### Send Push Notification

Push notification can be sent to multiple users by using the following method:

```swift
let chatId = "id98765"

let userIds = ["id1001", "id1002", "id1003"]

let text = "Text for sending out to users."

GQLPush.send(chatId, userIds, text)
```

### Receiving Notification

The `chatId` value is attached to the notification as data, so it can be used to open the related conversation when the user is receiving the notification.

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
  if let custom = userInfo["custom"] as? [String: Any] {
    if let dict = custom["a"] as? [String: Any] {
      if let chatId = dict["chatId"] as? String {
        // do something
      }
    }
  }
}
```

## Limitations

The GraphQLite toolkit is in its initial release. It is functional and can handle most workloads. However, there are some features that are currently not supported:

- Database migration
- Database encryption
- Combine framework integration

© Related Code 2022 - All Rights Reserved