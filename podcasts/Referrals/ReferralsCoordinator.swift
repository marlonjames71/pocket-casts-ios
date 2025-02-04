import Foundation
import PocketCastsServer
import PocketCastsUtils
import StoreKit

extension NSNotification.Name {
    static let referralURLChanged = NSNotification.Name("referralURLChanged")
}

class ReferralsCoordinator {

    var referralsOfferInfo: ReferralsOfferInfo? {
        guard IAPHelper.shared.getProduct(for: .yearlyReferral) != nil else {
            return nil
        }
        return ReferralsOfferInfoIAP(productID: .yearlyReferral)
    }

    var areReferralsAvailableToSend: Bool {
        return FeatureFlag.referrals.enabled && FeatureFlag.referralsSend.enabled && SubscriptionHelper.hasActiveSubscription()
    }

    var isReferralAvailableToClaim: Bool {
        return FeatureFlag.referrals.enabled && FeatureFlag.referralsClaim.enabled &&
        !SubscriptionHelper.hasActiveSubscription() &&
        Settings.referralURL != nil
    }

    static var shared: ReferralsCoordinator = {
        ReferralsCoordinator()
    }()

    func cleanReferalURL() {
        Settings.referralURL = nil
        NotificationCenter.default.post(name: .referralURLChanged, object: nil)
    }

    func setReferralURL(_ url: URL) {
        Settings.referralURL = url.absoluteString
        NotificationCenter.default.post(name: .referralURLChanged, object: nil)
    }

    func startClaimFlow(from viewController: UIViewController) {
        var referralURL: URL?
        if let storedReferralURL = Settings.referralURL {
            referralURL = URL(string: storedReferralURL)
        }
        startClaimFlow(from: viewController, referralURL: referralURL)
    }

    func startClaimFlow(from viewController: UIViewController, referralURL: URL? = nil, onComplete: (() -> ())? = nil) {
        guard FeatureFlag.referrals.enabled && FeatureFlag.referralsClaim.enabled else {
            onComplete?()
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var url: URL?
            if let referralURL {
                url = referralURL
                setReferralURL(referralURL)
            } else {
                if let urlString = Settings.referralURL {
                    url = URL(string: urlString)
                }
            }

            let viewModel = ReferralClaimPassModel(referralURL: url,
                                                   coordinator: self,
                                                   canClaimPass: true,
                                                   onComplete: nil,
                                                   onCloseTap: {
                viewController.dismiss(animated: true)
                onComplete?()
            })
            viewModel.onComplete = {
                viewController.dismiss(animated: true) {
                    if viewModel.accountCreated {
                        let welcomeVC = WelcomeViewModel.make(in: nil, displayType: .newAccount)
                        viewController.present(welcomeVC, animated: true)
                    }
                }
                onComplete?()
            }
            let referralClaimPassVC = ReferralClaimPassVC(viewModel: viewModel)
            viewController.present(referralClaimPassVC, animated: true)
        }
    }

    private func translateToProduct(offer: ReferralValidate) -> IAPProductID? {
        guard let iap = offer.details?.iap else {
            return nil
        }
        return IAPProductID(rawValue: iap)
    }

    func purchase(offer: ReferralValidate) -> Bool {
        guard let productID = translateToProduct(offer: offer) else {
            return false
        }

        let purchaseHandler = IAPHelper.shared

        let discountInfo = makeDiscountInfo(from: offer)

        guard purchaseHandler.buyProduct(identifier: productID, discount: discountInfo) else {
            return false
        }

        return true
    }

    func makeDiscountInfo(from offer: ReferralValidate) -> IAPDiscountInfo? {
        guard let details = offer.details,
              details.type == "offer",
              let offerID = details.offerId,
              let uuidString = details.nonce,
              let uuid = UUID(uuidString: uuidString),
              let timestamp = details.timestampMs,
              let key = details.keyIdentifier,
              let signature = details.signature
        else {
            return nil
        }

        return IAPDiscountInfo(identifier: offerID, uuid: uuid, timestamp: timestamp, key: key, signature: signature)
    }
}
