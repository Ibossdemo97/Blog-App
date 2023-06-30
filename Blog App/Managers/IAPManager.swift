//
//  APIManager.swift
//  Blog App
//
//  Created by Luyện Hà Luyện on 14/06/2023.
//

import Foundation
import Purchases
import StoreKit

//Tạo quyền ảo
let isPremium = true

final class IAPManager {
    
    static let shared = IAPManager()
    // Khi nào có IAP
//    static let formatter = ISO8601DateFormatter()
//    private var postEligibleViewDate: Date? {
//        get {
//            guard let string = UserDefaults.standard.string(forKey: "postEligibleViewDate") else {
//                return nil
//            }
//            return IAPManager.formatter.date(from: string)
//        } set {
//            guard let date = newValue else {
//                return
//            }
//            let string = IAPManager.formatter.string(from: date)
//            UserDefaults.standard.set(string, forKey: "postEligibleViewDate")
//        }
//    }
    
    private init () {}
    
//    func isPremium() -> Bool {
//        return UserDefaults.standard.bool(forKey: "premium")
//    }
    public func getSubscriptionStatus(completion: ((Bool) -> Void)?) {
        Purchases.shared.purchaserInfo { info, error in
            // Truy xuất thông tin người mua và xử lý các lỗi tiềm ẩn
            guard let entitlements = info?.entitlements,
                  error == nil else {
            // Nếu có lỗi hoặc không có quyền, hãy quay lại
                    return
            }
            // Kiểm tra xem có quyền "Premium" không
            if entitlements.all["Premium"]?.isActive == true {
                //Nếu CÓ thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(true)
                print("Đã cập nhật trạng thái của subcribed")
                UserDefaults.standard.set(true, forKey: "premium")
                completion?(true)
            } else {
                //Nếu KHÔNG thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(false)
                print("Got update status of subcribed")
                UserDefaults.standard.set(false, forKey: "premium")
                completion?(false)
            }
        }
    }
    public func fetechPackage(completion: @escaping (Purchases.Package?) -> Void) {
        Purchases.shared.offerings { offering, error in
            guard let package = offering?.offering(identifier: "default")?.availablePackages.first,
                  error == nil else {
                    completion(nil)
                    return
            }
            completion(package)
        }
    }
    public func subscribe(package: Purchases.Package, completion: @escaping (Bool) -> Void) {
//        guard !isPremium() else {
//            print("Ngừơi dùng đã đăng ký")
//            completion(true)
//            return
//        }
        UserDefaults.standard.set(isPremium, forKey: "premium")
        
        Purchases.shared.purchasePackage(package) { transaction, info, error, userCancelled in
            guard let transaction = transaction,
                  let entitlements = info?.entitlements,
                  error == nil,
                  !userCancelled else {
                return
            }
            switch transaction.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                // Kiểm tra xem có quyền "Premium" không
                if entitlements.all["Premium"]?.isActive == true {
                    //Nếu CÓ thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(true)
                    print("purchased")
                    UserDefaults.standard.set(true, forKey: "premium")
                    completion(true)
                } else {
                    //Nếu KHÔNG thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(false)
                    print("purchas failed")
                    UserDefaults.standard.set(false, forKey: "premium")
                    completion(false)
                }
            case .failed:
                print("failed")
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("dèault case")
            }
        }
    }
    public func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restoreTransactions {info, error in
            guard let entitlements = info?.entitlements,
                  error == nil else {
                return
            }
            // Kiểm tra xem có quyền "Premium" không
            if entitlements.all["Premium"]?.isActive == true {
                //Nếu CÓ thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(true)
                print("purchased")
                UserDefaults.standard.set(true, forKey: "premium")
                completion(true)
            } else {
                //Nếu KHÔNG thì đặt biểu tượng "premium" trong UserDefaults và gọi completion(false)
                print("purchas failed")
                UserDefaults.standard.set(false, forKey: "premium")
                completion(false)
            }
        }
    }
}
// Khi nào có IAP
//extension IAPManager {
//    var canViewPost: Bool {
//        if isPremium() {
//            return true
//        }
//        guard let date = postEligibleViewDate else {
//            return true
//        }
//        UserDefaults.standard.set(0, forKey: "post_view")
//        return Date() >= date
//    }
//    public func logPostViewed() {
//        let total = UserDefaults.standard.integer(forKey: "post_view")
//        UserDefaults.standard.set(total + 1, forKey: "post_view")
//
//        if total == 2 {
//            let hour: TimeInterval = 60 * 60
//            postEligibleViewDate = Date().addingTimeInterval(hour * 24)
//        }
//    }
//}

