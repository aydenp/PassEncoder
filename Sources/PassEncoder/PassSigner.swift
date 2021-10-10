//
//  PassSigner.swift
//  PassEncoder
//
//  Created by Ayden Panhuyzen on 2018-05-06.
//  Copyright © 2018 Ayden Panhuyzen. Licensed under the MIT license.
//  Read /LICENSE in the repository where this file originated for more information.
//

import Foundation

/// A singleton class used to sign PassKit passes.
public class PassSigner {
    /// The shared instance of `PassSigner`.
    public static let shared = PassSigner()

    // MARK: - Options
    /// The local URL of the Apple Worldwide Developer Relations Root Certificate Authority (required to sign passes).
    public var appleWWDRCertURL: URL?
    /// The URL to your OpenSSL binary. Set it if yours is in a different location than /usr/bin/openssl.
    public var openSSLURL = URL(fileURLWithPath: "/usr/bin/openssl")

    private init() {}

    // MARK: - Signing

    /**
     Sign the provided pass manifest data.
     - Note: This method will fail and crash your program if you haven't set `appleWWDRCertURL`.
     - parameter url: The URL of the pass's manifest.json file.
     - parameter signatureURL: The signature URL to write to.
     - parameter info: The signing info to sign this pass manifest with.
     - returns: Whether or not the operation was successful.
     */
    public func signPassManifest(at url: URL, toSignatureAt signatureURL: URL, info: SigningInfo) -> Bool {
        guard let caURL = appleWWDRCertURL else { fatalError("You must specify the location of your Apple WWDR CA certificate (PassSigner.shared.appleWWDRCertURL).") }

        let task = Process()
        task.launchPath = openSSLURL.path
        task.arguments = ["smime", "-sign", "-signer", info.certificate.path, "-inkey", info.certificate.path, "-certfile", caURL.path, "-in", url.path, "-out", signatureURL.path, "-outform", "der", "-binary", "-passin", "pass:\(info.password)"]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }
}

/// MARK: - Types
extension PassSigner {
    /// A tuple representing a certificate URL (expected .pem) and password.
    public typealias SigningInfo = (certificate: URL, password: String)
}
