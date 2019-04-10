Getting started
=============================

The Gini library provides ways to interact with the Gini API and therefore, adds the possiblity to scan documents and retrieve the extractions from them.

## Initializing the library

To initialize the library, you just need to provide the API credentials:

```swift
    let sdk = GiniSDK
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```

Optionally if you want to use _Certificate pinning_, provide metadata for the upload process or use the [Accounting API](https://accounting-api.gini.net/documentation/), you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), the metadata information and the _API type_ (the [Gini API](http://developer.gini.net/gini-api/html/index.html) is used by default) as follows:

```swift
    let sdk = GiniSDK
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .accounting,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```
> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.

## Using the library
Now that the `GiniSDK` has been initialized, you can start using it. To do so, just get the _Document service_ from it. 

On one hand, if you chose to continue with the `default` _Document service_, you should use the `DefaultDocumentService`:

```swift
let documentService: DefaultDocumentService = sdk.documentService()
```

On the other hand, if you prefer to use the `accounting` _Document service_, just use the `AccountingDocumentService` as follows:

```swift
let documentService: AccountingDocumentService = sdk.documentService()
```

You are all set 🚀! You can start using the Gini API through the `documentService`.
