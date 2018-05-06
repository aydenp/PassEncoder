import Foundation
import ZIPFoundation
import CryptoSwift

/// A class used to encode PassKit passes.
/// - NOTE: This class can **only be used once**. After running `encode(signingInfo:, completion:)` once, it will throw a fatal error.
class PassEncoder {
    private let directory = FileManager.default.temporaryDirectory.appendingPathComponent("PassEncoder-\(UUID().uuidString)-\(Date().timeIntervalSince1970)")
    private var isUsed = false, hashes = [String: String](), archive: Archive!
    
    /**
     Intiialize the encoder with the provided pass.json data. Will return nil if an error occurs.
     - parameter passData: The data to use for pass.json
     */
    init?(passData: [String: Any]) {
        // Create our temporary directory
        guard (try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)) != nil else { return nil }
        
        // Create our ZIP archive
        guard let archive = Archive(url: temporaryURL(for: "Pass.pkpass"), accessMode: .create) else { return nil }
        self.archive = archive
        
        // Write our pass.json data to a file
        guard addJSONFile(named: "pass.json", data: passData) else { return nil }
    }
    
    deinit {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        _ = try? FileManager.default.removeItem(at: directory)
    }
    
    // MARK: - File Management
    
    /**
     Add the file at the provided URL to the pass.
     - parameter url: The URL of the file to add to the pass.
     - parameter customName: A custom name to add the file with.
     - returns: Whether or not the operation was successful.
     */
    func addFile(from url: URL, customName: String? = nil) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return addFile(named: customName ?? url.lastPathComponent, from: data)
    }
    
    /**
     Add a file with the provided data to the pass with the provided name.
     - parameter name: The name of the file to add in the pass's directory.
     - parameter data: The data to create the file with.
     - returns: Whether or not the operation was successful.
     */
    func addFile(named name: String, from data: Data) -> Bool {
        guard writeTemporaryFile(to: name, data: data), addFileToArchive(with: name) else { return false }
        hashes[name.lowercased()] = data.sha1().toHexString()
        return true
    }
    
    private func addJSONFile(named name: String, data: [String: Any]) -> Bool {
        guard let json = json(for: data) else { return false }
        return addFile(named: name, from: json)
    }
    
    private func addFileToArchive(with name: String) -> Bool {
        return (try? self.archive.addEntry(with: name, relativeTo: directory)) != nil
    }
    
    // MARK: - Temporary File Writing & Utilities
    
    private func temporaryURL(for relativePath: String) -> URL {
        return directory.appendingPathComponent(relativePath)
    }
    
    private func writeTemporaryFile(to relativePath: String, data: Data) -> Bool {
        return (try? data.write(to: temporaryURL(for: relativePath))) != nil
    }
    
    private func writeTemporaryJSONFile(to relativePath: String, data: [String: Any]) -> Bool {
        guard let json = json(for: data) else { return false }
        return writeTemporaryFile(to: relativePath, data: json)
    }
    
    private func json(for data: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    // MARK: - Final Encoding
    
    /**
     Perform the encoding process and return the signed and archived pass as `Data`.
     - parameter signingInfo: The certificate and password to sign the pass with.
     - parameter completion: A callback to receive the optional `Data` at.
     */
    func encode(signingInfo: PassSigner.SigningInfo, completion: (Data?) -> Void) {
        guard !isUsed else { fatalError("This PassEncoder has already been used, and may not be used again.") }
        isUsed = true
        
        // Write our manifest
        guard addJSONFile(named: "manifest.json", data: hashes) else { completion(nil); return }
        
        // Sign our manifest and add the signature to the archive
        guard PassSigner.shared.signPassManifest(at: temporaryURL(for: "manifest.json"), toSignatureAt: temporaryURL(for: "signature"), info: signingInfo), addFileToArchive(with: "signature") else { completion(nil); return }
        
        completion(try? Data(contentsOf: archive.url))
    }
}
