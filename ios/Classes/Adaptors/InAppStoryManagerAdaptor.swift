import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class InAppStoryManagerAdaptor: InAppStoryManagerHostApi {

    private var skusCallback: SkusCallbackFlutterApi

    private var goodsItemSelectedCallback: GoodsItemSelectedCallbackFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.skusCallback = SkusCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        self.goodsItemSelectedCallback = GoodsItemSelectedCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        setUpGoodsCallback()
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

    func changeUser(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        InAppStory.shared.settings = Settings(userID: userId)

        completion(.success(()))
    }

    func closeReaders() throws {
        InAppStory.shared.closeReader {}
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
}
