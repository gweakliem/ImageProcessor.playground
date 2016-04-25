// 1. Be able to apply a filter formula to each pixel of the image.
// 2.The formula should have parameters that can be modified so that the filter can have a small or large effect on the image.
// 3. Be able to apply several different filters to the image, in a specific order (e.g. a ‘pipeline of filters’). These could be different formulas (e.g. brightness vs. contrast) or could be the same formula with different parameters.
// 4. Have some method or interface to apply default filter formulas and parameters that can be accessed by name.


// Does the playground code apply a filter to each pixel of the image? Maximum of 2 pts
// Are there parameters for each filter formula that can change the intensity of the effect of the filter? Maximum of 3 pts
// Is there an interface to specify the order and parameters for an arbitrary number of filter calculations that should be applied to an image? Maximum of 2 pts
// Is there an interface to apply specific default filter formulas/parameters to an image, by specifying each configuration’s name as a String? Maximum of 2 pts

import UIKit

func limitPixelValue(val: Int) -> UInt8 {
    return UInt8(max(0, min(255, Int(val))))
}

class FilterDefinition {
    func pixelsMatching (pixel: Pixel) -> Bool {
        return true
    }
    func transform (inout pixel: Pixel) -> Pixel {
        return pixel
    }
}

class EnhancedRedFilter: FilterDefinition {
    var shift: Int
    init(shift: Int) {
        self.shift = shift
    }
    override func transform(inout pixel: Pixel) -> Pixel {
        pixel.red = limitPixelValue(Int(pixel.red) + shift)
        return pixel
    }
}

class BlackAndWhiteFilter: FilterDefinition {
    override func transform(inout pixel: Pixel) -> Pixel {
        let averageColor = (Double(pixel.red) + Double(pixel.green) + Double(pixel.blue)) / 3.0
        pixel.red = limitPixelValue(Int(averageColor))
        pixel.green = pixel.red
        pixel.blue = pixel.red
        return pixel
    }
}

class HalfBrightnessFilter: FilterDefinition {
    override func transform(inout pixel: Pixel) -> Pixel {
        pixel.red = pixel.red / 2
        pixel.green = pixel.green / 2
        pixel.blue = pixel.blue / 2
        return pixel
    }
}

class HalfBrighterFilter: FilterDefinition {
    override func transform(inout pixel: Pixel) -> Pixel {
        pixel.red = limitPixelValue(Int(Double(pixel.red) * 1.5))
        pixel.green = limitPixelValue(Int(Double(pixel.green) * 1.5))
        pixel.blue = limitPixelValue(Int(Double(pixel.blue) * 1.5))
        return pixel
    }
}

class BalanceFilter: FilterDefinition {
    func balancePixelColor(colorComponent: UInt8,  balancePoint: Double)-> UInt8 {
        let delta = Double(colorComponent) - balancePoint
        let value = Double(colorComponent) + (delta * 0.5)
        return limitPixelValue(Int(value))
    }
    
    override func transform(inout pixel: Pixel) -> Pixel {
        let averageColor = (Double(pixel.red) + Double(pixel.green) + Double(pixel.blue)) / 3.0
        pixel.red = balancePixelColor(pixel.red, balancePoint: averageColor)
        pixel.green = balancePixelColor(pixel.green, balancePoint: averageColor)
        pixel.blue = balancePixelColor(pixel.blue, balancePoint: averageColor)
        return pixel
    }
}



var filterDict: [String:FilterDefinition] = [
    "BW" : BlackAndWhiteFilter(),
    "More Red" : EnhancedRedFilter(shift:10),
    "50% Brightness" : HalfBrightnessFilter(),
    "50% Brighter": HalfBrighterFilter(),
    "Balance": BalanceFilter()
]

func processImage(image: UIImage, usingFilterNamed: String) -> UIImage {
    let filter = filterDict[usingFilterNamed]!
    var rgbaImage = RGBAImage(image: image)!
    for y in 0..<rgbaImage.height {
        for x in 0..<rgbaImage.width {
            let index = y * rgbaImage.width + x
            var pixel = rgbaImage.pixels[index]
            if (filter.pixelsMatching(pixel)) {
                pixel = filter.transform(&pixel)
                rgbaImage.pixels[index] = pixel
            }
        }
    }
    return rgbaImage.toUIImage()!
}

let image = UIImage(named: "sample")

let enhancedRedImage = processImage(image!, usingFilterNamed: "More Red")

let bwImage = processImage(image!, usingFilterNamed: "BW" )

let lessBright = processImage(image!, usingFilterNamed: "50% Brightness")
let moreBright = processImage(image!, usingFilterNamed: "50% Brighter")

let balanced = processImage(image!, usingFilterNamed: "Balance")


