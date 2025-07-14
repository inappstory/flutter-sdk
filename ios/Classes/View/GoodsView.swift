import InAppStorySDK

class GoodsView: CustomGoodsView {
    override func setSKUItems(_ items: [String]) {
        super.setSKUItems(items)

        //setting the SKU list received from the library components
    }

    override func setReaderFrame(_ frame: CGRect) {
        super.setReaderFrame(frame)

        //setting the size and position of the reader from which the widget was shown
    }

    func selectGoodsItem() {
        // send selected item SKU for statistics
        //super.goodsItemClick(with: <String>)
    }
}
