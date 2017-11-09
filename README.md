DWAplatform iOS SDK
=================================================
DWAplatform is an iOS client library to work with DWAplatform.

Installation
-------------------------------------------------
We recommend that you install the DWAplatform iOS SDK using Cocoapods.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate DWAplatform into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
    pod 'DWAplatform', '~> 1.1.1'
```

Then, run the following command:

```bash
$ pod install
```



License
-------------------------------------------------
DWAplatform SDK is distributed under MIT license, see LICENSE file.


Contacts
-------------------------------------------------
Report bugs or suggest features using
[issue tracker at GitHub](https://github.com/DWAplatform/dwaplatform-sdk-ios).


Sample usage in Swift
-------------------------------------------------
```swift
    import DWAplatform

    //....

    // Configure DWAplatform
    let dwaplatform = DWAplatform.sharedInstance
    let config = DWAplatformConfiguration(hostName: "DWAPLATFORM_SANDBOX_HOSTNAME", sandbox: true)
    dwaplatform.initialize(config: config)

    // Get card API
    let cardAPI = dwaplatform.getCardAPI()

    // Register card
    // get token from POST call: .../rest/v1/:clientId/users/:userId/accounts/:accountId/cards
    let token = "XXXXXXXXYYYYZZZZKKKKWWWWWWWWWWWWTTTTTTTFFFFFFF...."
    let cardNumber = "1234567812345678"
    let expiration = "1122"
    let cxv = "123"

    do {
        try cardAPI.registerCard(token: token, cardNumber: cardNumber, expiration: expiration, cxv: cxv) {(card, e) in
            if let error = e {
                // error handler
                print(error)
                return
            }

            guard let card = card else { fatalError() }
            print(card.id ?? "nil id")
        }
    }
    catch let error {
        // error handler
        print(error)
    }

```
