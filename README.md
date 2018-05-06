# PassEncoder

Apple Wallet Pass encoding and signing in Swift.

## Features

- Modern Swift API
- Allows you to specify custom pass data
- Add other files (images, JSON, etc)
- Manifest generation
- Signing support
- File system managed seamlessly
- Get pass `Data` easily

## Requirements

- iOS 9.0+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Or Linux with zlib development package
- Xcode 9.0
- Swift 4.0

(as per [ZIPFoundation](https://github.com/weichsel/ZIPFoundation)'s requirements)

## Installation

### Swift Package Manager

Add the following line to your dependencies section of `Package.swift`:

    .package(url: "https://github.com/aydenp/PassEncoder.git", .upToNextMajor(from: 1.0.0))

and add "PassEncoder" to your target's dependencies.

## Usage

    // Create our encoder
    if let encoder = PassEncoder(passDataURL: directory.appendingPathComponent("pass.json")) {
        // Add a nice icon
        encoder.addFile(from: directory.appendingPathComponent("icon.png"))
        let passData = encoder.encode(signingInfo: (certificate: URL_TO_CERT.PEM, password: “Pass”))
        // Your archived .pkpass file is in passData as Data
    }

## Documentation

Coming soon

## Contributing

Feel free to contribute to the source code of PassEncoder to make it something even better! Just try to adhere to the general coding style throughout, to make it as readable as possible.

If you find an issue in the code or while using it, [create an issue](/issues/new). If you can, you're encouraged to contribute and make a [pull request](/pulls).

## License

This project is licensed under the [MIT license](/LICENSE). Please make sure you comply with its terms while using it in any way.

## Links

- [My website](https://www.madebyayden.co)
- [GitHub](https://www.github.com/aydenp/PassEncoder)
