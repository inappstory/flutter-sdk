import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class InAppStoryManagerAdaptor: InAppStoryManagerHostApi {

    private var skusCallback: SkusCallbackFlutterApi

    private var goodsItemSelectedCallback: GoodsItemSelectedCallbackFlutterApi

    private var checkoutCallback: CheckoutManagerCallbackFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.skusCallback = SkusCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.goodsItemSelectedCallback = GoodsItemSelectedCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.checkoutCallback = CheckoutManagerCallbackFlutterApi(
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
        InAppStory.shared.productCartUpdate = { [weak self] offer, complete in
            guard let self else { return }

            let offerDTO = inappstory_plugin.ProductCartOffer(
                offerId: offer.offerId,
                name: offer.name ?? "",
                imageUrls: offer.imageUrls,
                availability: Int64(offer.availability),
                quantity: Int64(offer.quantity)
            )
            self.checkoutCallback.addProductToCart(
                offer: offerDTO,
                completion: { result in
                    switch result {
                    case .success:
                        let cartFromFlutter = result.get()
                        let productCart: InAppStorySDK.ProductCart =
                            InAppStorySDK.ProductCart(
                                offers: <#T##[ProductCartOffer]#>,
                                price: cartFromFlutter.price,
                                oldPrice: cartFromFlutter.oldPrice,
                                priceCurrency: cartFromFlutter.priceCurrency
                            )
                        complete(.success(productCart))
                        break
                    case .failure:
                        complete(.failure())
                        break
                    }
                }
            )

        }
    }

    func setOptionKeys(options: [String: String]) throws {
        InAppStory.shared.options = options
    }
}
