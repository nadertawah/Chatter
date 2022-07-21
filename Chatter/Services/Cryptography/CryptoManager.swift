//
//  CryptoManager.swift
//  Chatter
//
//  Created by nader said on 18/07/2022.
//

import Foundation
import CryptoKit

class CryptoManager
{
    private(set) var privateKey : P256.KeyAgreement.PrivateKey
    var publicKey : P256.KeyAgreement.PublicKey
    {
        return privateKey.publicKey
    }
    
    init()
    {
        privateKey = P256.KeyAgreement.PrivateKey()
    }
    
    init(privateKey : P256.KeyAgreement.PrivateKey)
    {
        self.privateKey = privateKey
    }
    
    private func getSymmetricKey(_ ExternalPublicKeyStr: String) -> SymmetricKey?
    {
        do
        {
            guard let ExternalPublicKey = getPublicKeyFromString(ExternalPublicKeyStr) else {return nil}
            let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: ExternalPublicKey)
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: "My Key Agreement Salt".data(using: .utf8)!,
                sharedInfo: Data(),
                outputByteCount: 32
            )
            return symmetricKey
        }
        catch
        {
            return nil
        }
    }
    
    static func getPrivateKeyFromString(privateKeyStr: String)  -> P256.KeyAgreement.PrivateKey?
    {
        do
        {
            let privateKeyBase64 = privateKeyStr.removingPercentEncoding!
            let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
            return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
        }
        catch
        {
            return nil
        }
        
    }
    
    func getPublicKeyFromString(_ publicKeyStr: String) -> P256.KeyAgreement.PublicKey?
    {
        do
        {
            let base64PublicKey = publicKeyStr.removingPercentEncoding!
            let rawPublicKey = Data(base64Encoded: base64PublicKey)!
            let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
            return publicKey
        }
        catch
        {
            return nil
        }
    }
    
    func privateKeyToString() -> String
    {
        return privateKey.rawRepresentation.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    }
    
    func publicKeyToString() -> String
    {
        return publicKey.rawRepresentation.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    }
    
    func encrypt(text: String, ExternalPublicKeyStr: String) -> String
    {
        do
        {
            guard let textData = text.toBase64EncoedData(), let symmetricKey = getSymmetricKey(ExternalPublicKeyStr) else {return ""}
            let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
            return encrypted.combined!.base64EncodedString()
        }
        catch
        {
            return ""
        }
    }
    
    func decrypt(text: String, ExternalPublicKeyStr: String) -> String
    {
        do
        {
            guard let data = Data(base64Encoded: text) , let symmetricKey = getSymmetricKey(ExternalPublicKeyStr) else {return ""}
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8) ?? ""
        }
        catch let ee
        {
            print(ee)
            return ""
        }
    }
}
