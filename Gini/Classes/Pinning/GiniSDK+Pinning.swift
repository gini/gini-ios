//
//  GiniSDK.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit

extension GiniSDK.Builder {
    public init(client: Client,
                api: APIDomain = .default,
                pinningConfig: [String: Any],
                isLoggingEnabled: Bool = false) {
        self.client = client
        self.api = api
        self.isLoggingEnabled = isLoggingEnabled
        
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
}
