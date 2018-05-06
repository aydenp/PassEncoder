import Foundation

struct PassSigner {
    static let shared = PassSigner()
    var appleWWDRCertURL: URL?, openSSLURL = URL(fileURLWithPath: "/usr/bin/openssl")
    
    /// A tuple representing a certificate URL (expected .pem) and password.
    typealias SigningInfo = (certificate: URL, password: String)
    
    /**
     Sign the provided pass manifest data.
     - parameter url: The URL of the pass's manifest.json file.
     - parameter signatureURL: The signature URL to write to.
     - parameter info: The signing info to sign this pass manifest with.
     - returns: Whether or not the operation was successful.
     */
    func signPassManifest(at url: URL, toSignatureAt signatureURL: URL, info: SigningInfo) -> Bool {
        guard let caURL = appleWWDRCertURL else { fatalError("You must specify the location of your Apple WWDR CA certificate (PassSigner.shared.appleWWDRCertURL).") }
        
        let task = Process()
        task.launchPath = openSSLURL.path
        task.arguments = ["smime", "-sign", "-signer", info.certificate.path, "-inkey", info.certificate.path, "-certfile", caURL.path, "-in", url.path, "-out", signatureURL.path, "-outform", "der", "-binary", "-passin", "pass:\(info.password)"]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }
}
