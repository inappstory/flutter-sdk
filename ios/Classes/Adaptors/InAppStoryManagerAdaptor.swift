import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

enum MyError: Error {
    case invalidInput(message: String)
}

class InAppStoryManagerAdaptor: InAppStoryManagerHostApi {

    private var skusCallback: SkusCallbackFlutterApi

    private var goodsItemSelectedCallback: GoodsItemSelectedCallbackFlutterApi

    private var checkoutManagerCallback: CheckoutManagerCallbackFlutterApi
    private var checkoutCallback: CheckoutCallbackFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.skusCallback = SkusCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.goodsItemSelectedCallback = GoodsItemSelectedCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.checkoutManagerCallback = CheckoutManagerCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.checkoutCallback = CheckoutCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        setUpGoodsCallback()
        setupCheckoutManager()
        InAppStoryManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )

    }

    private static func localeIdentifier(_ code: String, _ region: String)
        -> String
    {
        return "\(code)-\(region)"
    }

    func setPlaceholders(newPlaceholders: [String: String]) throws {
        InAppStory.shared.placeholders = newPlaceholders
    }

    func setTags(tags: [String]) throws {
        InAppStory.shared.setTags(tags)
    }

    func setUserSettings(
        anonymous: Bool?,
        userId: String?,
        userSign: String?,
        newLanguageCode: String?,
        newLanguageRegion: String?,
        newTags: [String]?,
        newPlaceholders: [String: String]?
    ) throws {
        var locale: String? = nil
        if let newLanguageCode, let newLanguageRegion {
            locale = Self.localeIdentifier(newLanguageCode, newLanguageRegion)
        }

        if anonymous == nil, locale == nil,
            var settings = InAppStory.shared.settings
        {
            if let userId { settings.userID = userId }
            if let userSign { settings.sign = userSign }
            if let newTags { settings.tags = newTags }
            InAppStory.shared.settings = settings
        } else {
            let current = InAppStory.shared.settings
            InAppStory.shared.settings = Settings(
                userID: userId ?? current?.userID ?? "",
                sign: userSign ?? current?.sign,
                anonymous: anonymous ?? false,
                tags: newTags ?? current?.tags ?? [],
                lang: locale
            )
        }

        if let newPlaceholders {
            InAppStory.shared.placeholders = newPlaceholders
        }
    }

    func changeUser(
        userId: String,
        userSign: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        InAppStory.shared.settings?.userID = userId
        InAppStory.shared.settings?.sign = userSign

        completion(.success(()))
    }

    func userLogout() throws {
        InAppStory.shared.logOut {}
    }

    func closeReaders(completion: @escaping (Result<Void, any Error>) -> Void) {
        InAppStory.shared.closeReader {
            completion(.success(()))
        }
    }

    func clearCache() throws {
        InAppStory.shared.clearCache()
    }

    func setTransparentStatusBar() throws {
        // runs only in Android
    }

    func setLang(languageCode: String, languageRegion: String) throws {
        let current = InAppStory.shared.settings
        InAppStory.shared.settings = Settings(
            userID: current?.userID ?? "",
            sign: current?.sign,
            tags: current?.tags ?? [],
            lang: Self.localeIdentifier(languageCode, languageRegion)
        )
    }

    func changeSound(value: Bool) throws {
        InAppStory.shared.muted = !value
    }

    private func setUpGoodsCallback() {
        InAppStory.shared.getGoodsObject = { skus, complete in
            self.skusCallback.getSkus(
                strings: skus,
                completion: { result in
                    switch result {
                    case .success(let goodsInfos):
                        var goodsArray: [GoodObject] = []

                        for item in goodsInfos {
                            let goodObject = GoodObject(
                                sku: item.sku!,
                                title: item.title,
                                subtitle: item.description,
                                imageURL: URL(string: item.image ?? ""),
                                price: item.price,
                                oldPrice: item.oldPrice
                            )
                            goodsArray.append(goodObject)
                        }
                        complete(.success(goodsArray))
                    case .failure(_):
                        complete(.failure(GoodsFailure.close))
                    }

                }
            )
        }
        InAppStory.shared.goodItemSelected = { item, storyType in
            let itemDto = GoodsItemDataDto(
                sku: item.sku
            )
            self.goodsItemSelectedCallback.goodsItemSelected(
                item: itemDto,
                completion: { _ in }
            )
        }
    }

    private func setupCheckoutManager() {
        InAppStoryAPI.shared.callbacksAPI.productCartUpdate = {
            [weak self] offer, complete in
            guard let self else { return }

            let offerDTO = offerToDTO(offer)
            print("The quantity is \(offer.quantity)")
            DispatchQueue.main.async { [self] in
                self.checkoutManagerCallback.onProductCartUpdate(
                    offer: offerDTO,
                    completion: { result in
                        switch result {
                        case .success(let cartFromFlutter):
                            let productCart: InAppStorySDK.ProductCart =
                                InAppStorySDK.ProductCart(
                                    offers: [],
                                    price: cartFromFlutter.price,
                                    oldPrice: cartFromFlutter.oldPrice,
                                    priceCurrency: cartFromFlutter.priceCurrency
                                )
                            complete(.success(productCart))
                        case .failure:
                            complete(
                                .failure(
                                    MyError.invalidInput(
                                        message:
                                            "Error while getting product cart"
                                    )
                                )
                            )
                        }
                    }
                )
            }
        }

        InAppStoryAPI.shared.callbacksAPI.productCartClicked = { [weak self] in
            guard let self else { return }

            DispatchQueue.main.async { [self] in
                self.checkoutCallback.onProductCartClicked(completion: { _ in })
            }
        }

        InAppStoryAPI.shared.callbacksAPI.productCartGetState = {
            [weak self] complete in
            guard let self else { return }

            DispatchQueue.main.async { [self] in
                self.checkoutManagerCallback.getProductCartState(completion: {
                    result in
                    switch result {
                    case .success(let productCartFromFlutter):
                        let productCart = self.productCartFromDTO(
                            productCartFromFlutter
                        )
                        complete(.success(productCart))
                    case .failure(_):
                        complete(
                            .failure(
                                MyError.invalidInput(
                                    message:
                                        "Error while getting product cart"
                                )
                            )
                        )
                    }
                })
            }
        }
    }

    func setOptionKeys(options: [String: String]) throws {
        InAppStory.shared.options = options
    }

    func offerToDTO(_ offer: InAppStorySDK.ProductCartOffer)
        -> inappstory_plugin.ProductCartOffer
    {
        let offerDTO = inappstory_plugin.ProductCartOffer(
            offerId: offer.offerId,
            groupId: offer.groupId,
            name: offer.name ?? "",
            description: offer.description,
            url: offer.url,
            coverUrl: offer.coverUrl,
            imageUrls: offer.imageUrls,
            currency: offer.currency,
            price: offer.price,
            oldPrice: offer.oldPrice,
            adult: offer.adult,
            availability: Int64(offer.availability),
            size: offer.size,
            color: offer.color,
            quantity: Int64(offer.quantity)
        )
        return offerDTO
    }

        func offerFromDTO(_ offer: inappstory_plugin.ProductCartOffer)
            -> InAppStorySDK.ProductCartOffer
        {
            return InAppStorySDK.ProductCartOffer(
                offerId: offer.offerId,
                groupId: offer.groupId,
                name: offer.name,
                description: offer.description,
                url: offer.url,
                coverUrl: offer.coverUrl,
                imageUrls: offer.imageUrls,
                currency: offer.currency,
                price: offer.price,
                oldPrice: offer.oldPrice,
                adult: offer.adult,
                availability: Int(offer.availability),
                size: offer.size,
                color: offer.color,
                quantity: Int(offer.quantity)
            )
        }

    func productCartFromDTO(_ productCart: inappstory_plugin.ProductCart)
        -> InAppStorySDK.ProductCart
    {
        let offers = productCart.offers.map { offer in offerFromDTO(offer) }
        let result = InAppStorySDK.ProductCart(
            offers: offers,
            price: productCart.price,
            oldPrice: productCart.oldPrice,
            priceCurrency: productCart.priceCurrency
        )
        return result
    }
}
