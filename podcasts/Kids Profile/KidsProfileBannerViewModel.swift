import Foundation

class KidsProfileBannerViewModel {
    var onCloseButtonTap: (() -> Void)? = nil
    var onRequestEarlyAccessTap: (() -> Void)? = nil

    func closeButtonTap() {
        Settings.shouldHideBanner = true
        Analytics.track(.kidsProfileEarlyAccessRequested)
        onCloseButtonTap?()
    }

    func requestEarlyAccessTap() {
        Analytics.track(.kidsProfileEarlyAccessRequested)
        onRequestEarlyAccessTap?()
    }
}
