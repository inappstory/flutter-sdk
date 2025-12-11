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

    func setPlaceholders(newPlaceholders: [String: String]) throws {
        InAppStory.shared.placeholders = newPlaceholders
    }

    func setTags(tags: [String]) throws {
        InAppStory.shared.settings?.tags = tags
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

        if newLanguageCode != nil && newLanguageRegion != nil {
            let str2: String = "_"
            locale = "\(newLanguageCode)\(str2)\(newLanguageRegion)"
        }

        if anonymous != nil {
            InAppStory.shared.settings = Settings(
                userID: userId ?? "",
                sign: userSign,
                tags: newTags ?? [""],
                lang: locale
            )
        } else {
            InAppStory.shared.settings = Settings(
                userID: userId ?? "",
                sign: userSign,
                anonymous: anonymous!,
                tags: newTags ?? [""],
                lang: locale
            )
        }

        if newPlaceholders != nil {
            InAppStory.shared.placeholders = newPlaceholders!
        }
    }

    func changeUser(
        userId: String,
        userSign: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        InAppStory.shared.settings = Settings(userID: userId, sign: userSign)

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
        let settings = InAppStory.shared.settings
        let str2: String = "_"
        let locale = "\(languageCode)\(str2)\(languageRegion)"
        InAppStory.shared.settings = Settings(
            userID: settings?.userID ?? "",
            lang: locale
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
        InAppStoryAPI.shared.callbacksAPI.productCartUpdate = { [weak self] offer, complete in
            guard let self else { return }

            let offerDTO = offerToDTO(offer)
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

        InAppStoryAPI.shared.callbacksAPI.productCartClicked = { [weak self] in
            guard let self else { return }

            DispatchQueue.main.async { [self] in
                self.checkoutCallback.onProductCartClicked(completion: { _ in })
            }
        }

        InAppStoryAPI.shared.callbacksAPI.productCartGetState = { [weak self] complete in
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
            quantity: Int64(offer.quantity),
        )
        return offerDTO
    }

//    func offerFromDTO(_ offer: inappstory_plugin.ProductCartOffer)
//        -> InAppStorySDK.ProductCartOffer
//    {
//        return InAppStorySDK.ProductCartOffer(
//            offerId: offer.offerId,
//            groupId: offer.groupId,
//            name: offer.name,
//            description: offer.description,
//            url: offer.url,
//            coverUrl: offer.coverUrl,
//            imageUrls: offer.imageUrls,
//            currency: offer.currency,
//            price: offer.price,
//            oldPrice: offer.oldPrice,
//            adult: offer.adult,
//            availability: Int(offer.availability),
//            size: offer.size,
//            color: offer.color,
//            quantity: Int(offer.quantity)
//        )
//    }

    func productCartFromDTO(_ productCart: inappstory_plugin.ProductCart)
        -> InAppStorySDK.ProductCart
    {
        //let offers = productCart.offers.map { offer in offerFromDTO(offer) }
        let result = InAppStorySDK.ProductCart(
            //offers: offers,
            offers: [],
            price: productCart.price,
            oldPrice: productCart.oldPrice,
            priceCurrency: productCart.priceCurrency
        )
        return result
    }
}
