import UIKit

//this class handles drawing a light version of a previous image
// I take advantage of CGBlendMode to only draw the black portion of the image, since the white background of the image should not be overlayed over images beneath
public class WatermarkView: UIView {
    public var image: UIImage? {
        didSet { setNeedsDisplay() }
    }
    public override func draw(_ rect: CGRect) {
        image?.draw(in: rect, blendMode: CGBlendMode.colorBurn, alpha: 0.2)
    }
}
