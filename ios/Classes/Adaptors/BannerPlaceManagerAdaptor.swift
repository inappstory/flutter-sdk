import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

struct LoadBannerPlace: EventKey {
    typealias Payload = String
}
struct ReloadBannerPlace: EventKey {
    typealias Payload = String
}
struct PreloadBannerPlace: EventKey {
    typealias Payload = String
}
struct ShowNext: EventKey {
    typealias Payload = String
}
struct ShowPrevious: EventKey {
    typealias Payload = String
}
struct ShowByIndex: EventKey {
    public struct Payload {
        public let placeId: String
        public let index: Int64

        public init(placeId: String, index: Int64) {
            self.placeId = placeId
            self.index = index
        }
        public typealias Payload = ShowByIndex.Payload
    }
}
struct PauseAutoscroll: EventKey {
    typealias Payload = String
}
struct ResumeAutoscroll: EventKey {
    typealias Payload = String
}

public protocol EventKey: Hashable {
    associatedtype Payload
}

class BannerPlaceManagerAdaptor: BannerPlaceManagerHostApi {
   
    
    typealias Token = UUID

    private var subscribers: [AnyHashable: [Token: (Any) -> Void]] = [:]

    private var tokenToKey: [Token: AnyHashable] = [:]

    private var binaryMessenger: FlutterBinaryMessenger

    private let queue = DispatchQueue(
        label: "eventsource.subs",
        attributes: .concurrent
    )

    init(
        binaryMessenger: FlutterBinaryMessenger
    ) {
        self.binaryMessenger = binaryMessenger

        BannerPlaceManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    @discardableResult
    public func subscribe<K: EventKey>(
        _ key: K,
        _ callback: @escaping (K.Payload) -> Void
    ) -> Token {
        let id = Token()
        let anyCallback: (Any) -> Void = { anyPayload in
            if let payload = anyPayload as? K.Payload {
                callback(payload)
            }
        }
        let anyKey = AnyHashable(key)
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            var dict = self.subscribers[AnyHashable(anyKey)] ?? [:]
            dict[id] = anyCallback
            self.subscribers[AnyHashable(anyKey)] = dict
            self.tokenToKey[id] = anyKey
        }
        return id
    }

    public func unsubscribe(_ token: Token) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            guard let anyKey = self.tokenToKey.removeValue(forKey: token) else {
                return
            }
            if var dict = self.subscribers[anyKey] {
                dict.removeValue(forKey: token)
                if dict.isEmpty {
                    self.subscribers.removeValue(forKey: anyKey)
                } else {
                    self.subscribers[anyKey] = dict
                }
            }
        }
    }

    private func emit<K: EventKey>(_ key: K, payload: K.Payload) {
        let anyKey = AnyHashable(key)
        var callbacks: [(Any) -> Void] = []
        queue.sync {
            if let dict = self.subscribers[anyKey] {
                callbacks = Array(dict.values)
            }
        }
        for cb in callbacks {
            DispatchQueue.main.async {
                cb(payload)
            }
        }
    }

    public func removeAll<K: EventKey>(for key: K) {
        let anyKey = AnyHashable(key)
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let dict = self.subscribers.removeValue(forKey: anyKey) {
                for token in dict.keys {
                    self.tokenToKey.removeValue(forKey: token)
                }
            }
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.subscribers.removeAll()
            self.tokenToKey.removeAll()
        }
    }

    func loadBannerPlace(placeId: String) throws {
        self.emit(LoadBannerPlace(), payload: placeId)
    }

    func reloadBannerPlace(placeId: String) throws {
        self.emit(ReloadBannerPlace(), payload: placeId)
    }
    
    func preloadBannerPlace(placeId: String) throws {
        self.emit(PreloadBannerPlace(), payload: placeId)
    }

    func showNext(placeId: String) throws {
        self.emit(ShowNext(), payload: placeId)
    }

    func showPrevious(placeId: String) throws {
        self.emit(ShowPrevious(), payload: placeId)
    }

    func showByIndex(placeId: String, index: Int64) throws {
        self.emit(
            ShowByIndex(),
            payload: ShowByIndex.Payload(placeId: placeId, index: index)
        )
    }

    func pauseAutoscroll(placeId: String) throws {
        self.emit(PauseAutoscroll(), payload: placeId)
    }

    func resumeAutoscroll(placeId: String) throws {
        self.emit(ResumeAutoscroll(), payload: placeId)
    }
}
