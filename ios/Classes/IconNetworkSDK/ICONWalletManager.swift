//  Created by Leo Ngo on 25/03/2021.
import Foundation
import ICONKit
import BigInt

class ICONWalletManager {
    static func getInstance(host: String, networkId: String) -> ICONWalletManager {
        if(instance == nil) {
            instance = ICONWalletManager(host: host, networkId: networkId)
        }
        return instance!
    }
    static var instance: ICONWalletManager?
    let iconService: ICONService

    private init(host: String, networkId: String){
        iconService = ICONService(provider: host, nid: networkId)
    }
    
    func createWallet() -> Wallet {
        let wallet = Wallet(privateKey: nil)
        return wallet
    }
    
    func getIcxBalance(privateKey: String) -> String {
        let wallet = getWalletFromPrivateKey(privateKey: privateKey)
        let result:Result<BigUInt, ICError> = iconService.getBalance(address: wallet.address).execute()
        switch result {
        case .success(let balance):
            return "\(balance)"
        case .failure( _):
            return "0"
        }
    }
    
    func getTokenBalance(privateKey: String, scoreAddress: String) -> String {
        let wallet = getWalletFromPrivateKey(privateKey: privateKey)
        let call = Call<BigUInt>(from: wallet.address, to: scoreAddress, method: "balanceOf", params: ["_owner":wallet.address])
        let request: Request<BigUInt> = iconService.call(call)
        let result: Result<BigUInt, ICError> = request.execute()
        switch result {
        case .success(let balance):
            return "\(balance)"
        case .failure( _):
            return "0"
        }
    }
    
    func getWalletFromPrivateKey(privateKey: String) -> Wallet {
        let privateKey = PrivateKey(hex: Data(hex: privateKey))
        return Wallet(privateKey: privateKey)
    }
}
