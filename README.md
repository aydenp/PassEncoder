# PassEncoder

Apple Wallet (formerly Passbook) pass encoding and signing in Swift.

## Features

- Modern Swift API
- Allows you to specify custom pass data
- Add other files (images, JSON, etc)
- Manifest generation
- Signing support
- File system managed seamlessly
- Get pass `Data` easily

## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Or Linux with zlib development package
- Xcode 9.0
- Swift 4.0
- OpenSSL

## Installation

### Swift Package Manager

Add the following line to your dependencies section of `Package.swift`:

    .package(url: "https://github.com/aydenp/PassEncoder.git", .upToNextMajor(from: 1.0.0))

and add "PassEncoder" to your target's dependencies.

> **Heads up!** Because this package requires macOS 10.12+, and as of writing this, SPM does not support setting minimum deployment targets, you will have to manually specify building with that target, or set it in your Xcode project (if applicable).
>     swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"

## Usage

    // Create our encoder
    if let encoder = PassEncoder(passDataURL: directory.appendingPathComponent("pass.json")) {
        // Add a nice icon
        encoder.addFile(from: directory.appendingPathComponent("icon.png"))
        let passData = encoder.encode(signingInfo: (certificate: URL_TO_CERT.PEM, password: CERT_PASSWORD))
        // Your archived .pkpass file is in passData as Data
    }
    
Before using the library, you'll also need to set the Apple WWDR certificate URL, which you can [read about below](#creating-and-preparing-your-certificate).
    
> **Heads up!** Operations in this library are all synchronous, so it is advisable to run them on a separate `OperationQueue` so that they do not block your thread.

### Creating and preparing your certificate

You need to repeat this step for each different `passTypeId` you have in your `pass.json`.

1. Go to the [Apple Developer Pass Type IDs page](https://developer.apple.com/account/ios/identifier/passTypeId) and create your pass type.
2. Go to the [certificate section](https://developer.apple.com/account/ios/certificate/) and follow the instructions to create a certificate for your pass.
3. Download the certificate, and ensure it is named `Certificates.p12`.
4. Run the following command: `openssl pkcs12 -in Certificates.p12 -out PassCert.pem`.
5. Your pass certificate is now stored in `PassCert.pem`!

You'll also need to download the Apple Worldwide Developer Relations Root Certificate Authority file to sign passes.

1. Download the [certificate from here](https://developer.apple.com/certificationauthority/AppleWWDRCA.cer).
2. Import it into Keychain Access (double click it).
3. Find it in Keychain Access, and export it as a .pem file.
4. Set the `PassSigner`'s WWDR URL to it in your code.

        PassSigner.shared.appleWWDRCertURL = URL(fileURLWithPath: PATH_TO_WWDR_CERT.PEM)

## Documentation

To take full advantage of the package, check out the [documentation](https://aydenp.github.io/PassEncoder/) and see all of the methods and variables that are made available to you.

## Contributing

Feel free to contribute to the source code of PassEncoder to make it something even better! Just try to adhere to the general coding style throughout, to make it as readable as possible.

If you find an issue in the code or while using it, [create an issue](/issues/new). If you can, you're encouraged to contribute and make a [pull request](/pulls).

## License

This project is licensed under the [MIT license](/LICENSE). Please make sure you comply with its terms while using it in any way.

## Links

- [My website](https://www.madebyayden.co)
- [GitHub](https://www.github.com/aydenp/PassEncoder)
- [Documentation](https://aydenp.github.io/PassEncoder/)
