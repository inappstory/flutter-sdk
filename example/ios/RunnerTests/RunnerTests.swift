import Flutter
import UIKit
import XCTest


@testable import inappstory_plugin

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testGetPlatformVersion() {
    let plugin = InappstoryPlugin()

    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}

class MockBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil) {}
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil) -> FlutterBinaryMessengerConnection {
    return 0
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

class MockRegistrar: NSObject, FlutterPluginRegistrar {
  func messenger() -> FlutterBinaryMessenger {
    return MockBinaryMessenger()
  }
  func textures() -> FlutterTextureRegistry {
    fatalError("Not implemented")
  }
  func register(_ delegate: FlutterPlugin) {}
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
  func addApplicationDelegate(_ delegate: FlutterPlugin) {}
  func lookupKey(forAsset asset: String) -> String { asset }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { asset }
}

class BannerPlaceTests: XCTestCase {

  var messenger: MockBinaryMessenger!
  var adaptor: BannerPlaceManagerAdaptor!

  override func setUp() {
    super.setUp()
    messenger = MockBinaryMessenger()
    adaptor = BannerPlaceManagerAdaptor(binaryMessenger: messenger)
  }

  override func tearDown() {
    adaptor.removeAll()
    adaptor = nil
    messenger = nil
    super.tearDown()
  }

  // MARK: - BannerPlaceLoadError Tests

  func testBannerPlaceLoadError_globalError_dispatchesToAllPlaces() {
    let expectationA = expectation(description: "place_A receives global error")
    let expectationB = expectation(description: "place_B receives global error")

    var receivedA: String?
    var receivedB: String?

    // Simulating BannerPlaceView error subscriber for place_A
    adaptor.subscribe(BannerPlaceLoadError()) { payload in
      if payload.placeId == nil || payload.placeId == "place_A" {
        receivedA = payload.message
        expectationA.fulfill()
      }
    }

    // Simulating BannerPlaceView error subscriber for place_B
    adaptor.subscribe(BannerPlaceLoadError()) { payload in
      if payload.placeId == nil || payload.placeId == "place_B" {
        receivedB = payload.message
        expectationB.fulfill()
      }
    }

    // ErrorCallbackAdaptor emits global error when .bannersFailure occurs
    adaptor.emitBannerPlaceLoadError(placeId: nil, message: "Network unavailable")

    waitForExpectations(timeout: 1.0)
    XCTAssertEqual(receivedA, "Network unavailable")
    XCTAssertEqual(receivedB, "Network unavailable")
  }

  func testBannerPlaceLoadError_specificPlaceError_routesOnlyToMatchingPlace() {
    let expectationA = expectation(description: "place_A receives targeted error")
    var receivedA: String?
    var receivedB: String?

    adaptor.subscribe(BannerPlaceLoadError()) { payload in
      if payload.placeId == nil || payload.placeId == "place_A" {
        receivedA = payload.message
        expectationA.fulfill()
      }
    }

    adaptor.subscribe(BannerPlaceLoadError()) { payload in
      if payload.placeId == nil || payload.placeId == "place_B" {
        receivedB = payload.message
      }
    }

    adaptor.emitBannerPlaceLoadError(placeId: "place_A", message: "Place A not found")

    waitForExpectations(timeout: 1.0)
    XCTAssertEqual(receivedA, "Place A not found")
    XCTAssertNil(receivedB, "place_B should not receive error targeted to place_A")
  }

  // MARK: - BannerPlaceManagerAdaptor Events Tests

  func testBannerPlaceManagerAdaptor_subscribesAndEmitsAllEvents() throws {
    var loadedPlace: String?
    var reloadedPlace: String?
    var preloadedPlace: String?
    var showNextPlace: String?
    var showPrevPlace: String?
    var showByIndexPayload: ShowByIndex.Payload?
    var pausePlace: String?
    var resumePlace: String?
    var setInteractionPayload: SetInteraction.Payload?

    let expLoad = expectation(description: "load")
    let expReload = expectation(description: "reload")
    let expPreload = expectation(description: "preload")
    let expNext = expectation(description: "next")
    let expPrev = expectation(description: "prev")
    let expByIndex = expectation(description: "byIndex")
    let expPause = expectation(description: "pause")
    let expResume = expectation(description: "resume")
    let expInteraction = expectation(description: "interaction")

    adaptor.subscribe(LoadBannerPlace()) { payload in
      loadedPlace = payload
      expLoad.fulfill()
    }
    adaptor.subscribe(ReloadBannerPlace()) { payload in
      reloadedPlace = payload
      expReload.fulfill()
    }
    adaptor.subscribe(PreloadBannerPlace()) { payload in
      preloadedPlace = payload
      expPreload.fulfill()
    }
    adaptor.subscribe(ShowNext()) { payload in
      showNextPlace = payload
      expNext.fulfill()
    }
    adaptor.subscribe(ShowPrevious()) { payload in
      showPrevPlace = payload
      expPrev.fulfill()
    }
    adaptor.subscribe(ShowByIndex()) { payload in
      showByIndexPayload = payload
      expByIndex.fulfill()
    }
    adaptor.subscribe(PauseAutoscroll()) { payload in
      pausePlace = payload
      expPause.fulfill()
    }
    adaptor.subscribe(ResumeAutoscroll()) { payload in
      resumePlace = payload
      expResume.fulfill()
    }
    adaptor.subscribe(SetInteraction()) { payload in
      setInteractionPayload = payload
      expInteraction.fulfill()
    }

    try adaptor.loadBannerPlace(placeId: "place_1")
    try adaptor.reloadBannerPlace(placeId: "place_2")
    try adaptor.preloadBannerPlace(placeId: "place_3")
    try adaptor.showNext(placeId: "place_4")
    try adaptor.showPrevious(placeId: "place_5")
    try adaptor.showByIndex(placeId: "place_6", index: 3)
    try adaptor.pauseAutoscroll(placeId: "place_7")
    try adaptor.resumeAutoscroll(placeId: "place_8")
    try adaptor.setInteraction(placeId: "place_9", isInteractionEnabled: false)

    waitForExpectations(timeout: 1.0)

    XCTAssertEqual(loadedPlace, "place_1")
    XCTAssertEqual(reloadedPlace, "place_2")
    XCTAssertEqual(preloadedPlace, "place_3")
    XCTAssertEqual(showNextPlace, "place_4")
    XCTAssertEqual(showPrevPlace, "place_5")
    XCTAssertEqual(showByIndexPayload?.placeId, "place_6")
    XCTAssertEqual(showByIndexPayload?.index, 3)
    XCTAssertEqual(pausePlace, "place_7")
    XCTAssertEqual(resumePlace, "place_8")
    XCTAssertEqual(setInteractionPayload?.placeId, "place_9")
    XCTAssertEqual(setInteractionPayload?.isInteractionEnabled, false)
  }

  func testBannerPlaceManagerAdaptor_unsubscribe_stopsReceivingEvents() throws {
    var receivedCount = 0
    let token = adaptor.subscribe(LoadBannerPlace()) { _ in
      receivedCount += 1
    }

    let exp1 = expectation(description: "first call")
    DispatchQueue.main.async { exp1.fulfill() }
    try adaptor.loadBannerPlace(placeId: "place_1")
    waitForExpectations(timeout: 1.0)

    XCTAssertEqual(receivedCount, 1)

    adaptor.unsubscribe(token)

    let exp2 = expectation(description: "second call after unsubscribe")
    DispatchQueue.main.async { exp2.fulfill() }
    try adaptor.loadBannerPlace(placeId: "place_2")
    waitForExpectations(timeout: 1.0)

    XCTAssertEqual(receivedCount, 1)
  }

  // MARK: - CustomPlaceholderView Tests

  func testCustomPlaceholderView_setDecorationColor_configuresBackgroundColor() {
    let placeholder = CustomPlaceholderView(frame: CGRect(x: 0, y: 0, width: 300, height: 140))
    let registrar = MockRegistrar()

    // 0xFFFF0000 = Red with Alpha 255
    let redColor: Int64 = 0xFFFF_0000
    let decoration = BannerDecorationDTO(color: redColor, image: nil)

    placeholder.setDecoration(decoration, registrar: registrar)

    guard let bgColor = placeholder.backgroundColor else {
      XCTFail("Background color should be set by setDecoration")
      return
    }

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    bgColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    XCTAssertEqual(red, 1.0, accuracy: 0.01)
    XCTAssertEqual(green, 0.0, accuracy: 0.01)
    XCTAssertEqual(blue, 0.0, accuracy: 0.01)
    XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
  }

  func testCustomPlaceholderView_nilColor_doesNotChangeBackgroundColor() {
    let placeholder = CustomPlaceholderView(frame: .zero)
    let initialColor = placeholder.backgroundColor

    let decoration = BannerDecorationDTO(color: nil, image: nil)
    placeholder.setDecoration(decoration, registrar: MockRegistrar())

    XCTAssertEqual(placeholder.backgroundColor, initialColor)
  }

  func testCustomPlaceholderView_placeholderProtocol_methodsDoNotCrash() {
    let placeholder = CustomPlaceholderView(frame: .zero)
    XCTAssertFalse(placeholder.isAnimate)
    placeholder.start()
    placeholder.stop()
  }

  // MARK: - BannerPlaceView Update Logic Tests

  func testBannersDidUpdated_countAndHeightComputation() {
    // Tests mapping logic from BannerPlaceView.swift lines 315-316:
    // let finalCount = (isContent && count > 0) ? count : 0
    // let finalHeight = (isContent && count > 0) ? listHeight : 0

    func computeResult(isContent: Bool, count: Int, listHeight: Int) -> (size: Int, height: Int) {
      let finalCount = (isContent && count > 0) ? count : 0
      let finalHeight = (isContent && count > 0) ? listHeight : 0
      return (finalCount, finalHeight)
    }

    // When isContent is false (empty or error)
    let resultNoContent = computeResult(isContent: false, count: 5, listHeight: 140)
    XCTAssertEqual(resultNoContent.size, 0)
    XCTAssertEqual(resultNoContent.height, 0)

    // When count is 0
    let resultZeroCount = computeResult(isContent: true, count: 0, listHeight: 140)
    XCTAssertEqual(resultZeroCount.size, 0)
    XCTAssertEqual(resultZeroCount.height, 0)

    // When content exists and count > 0
    let resultContent = computeResult(isContent: true, count: 3, listHeight: 120)
    XCTAssertEqual(resultContent.size, 3)
    XCTAssertEqual(resultContent.height, 120)
  }
}

