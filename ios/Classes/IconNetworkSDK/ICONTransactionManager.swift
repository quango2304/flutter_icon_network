//  Created by Leo Ngo on 25/03/2021.
import Foundation
import ICONKit
import BigInt

class ICONTransactionManager {
    static func getInstance(host: String, networkId: String) -> ICONTransactionManager {
        if(instance == nil) {
            instance = ICONTransactionManager(host: host, networkId: networkId)
        }
        return instance!
    }
    static var instance: ICONTransactionManager?
    let iconService: ICONService
    
    private init(host: String, networkId: String){
        iconService = ICONService(provider: host, nid: networkId)
    }
    
    func sendICX(from: String, to: String, value: String) -> String {
        let wallet = ICONWalletManager.getInstance(host: iconService.provider, networkId: iconService.nid).getWalletFromPrivateKey(privateKey: from)
        
        let coinTransfer = Transaction()
            .from(wallet.address)
            .to(to)
            .value(BigUInt(Int(value)!*1000000000000000000))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
        
        do {
            let signed = try SignedTransaction(transaction: coinTransfer, privateKey: wallet.key.privateKey)
            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            
            switch response {
            case .success(let txHash):
                return txHash
            case .failure(let error):
                print("FAIL: \(String(describing: error.errorDescription))")
                return ""
            }
        } catch {
            return ""
        }
    }
    
    func sendToken(from: String, to: String, value: String, scoreAddress: String) -> String {
        let wallet = ICONWalletManager.getInstance(host: iconService.provider, networkId: iconService.nid).getWalletFromPrivateKey(privateKey: from)
        
        let call = CallTransaction()
            .from(wallet.address)
            .to(scoreAddress)
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
            .method("transfer")
            .params(["_to": to, "_value": ICONIcxUtil.stringToHexString(value: value)])
        
        do {
            let signed = try SignedTransaction(transaction: call, privateKey: wallet.key.privateKey)
            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            
            switch response {
            case .success(let txHash):
                return txHash
            case .failure(let error):
                print("FAIL: \(String(describing: error.errorDescription))")
                return ""
            }
        } catch {
            return ""
        }
    }
    
    
    func getTransactionResult(txHash: String) -> Response.TransactionResult? {
        let request: Request<Response.TransactionResult> = iconService.getTransactionResult(hash: txHash)
        let response = request.execute()
        
        switch response {
        case .success(let transactionResult):
            return transactionResult
        case .failure(let error):
            print("FAIL: \(String(describing: error.errorDescription))")
            return nil
        }
    }
    
    
    
    func getTransaction(txHash: String) -> Response.TransactionByHashResult? {
        let request: Request<Response.TransactionByHashResult> = iconService.getTransaction(hash: txHash)
        let response = request.execute()
        
        switch response {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            print("FAIL: \(String(describing: error.errorDescription))")
            return nil
        }
    }
    
}
