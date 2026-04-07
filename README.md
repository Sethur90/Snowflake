# Snowflake

SVG rendering in Swift using native `CALayer` and `UIBezierPath`.

![](Screenshots/Banner.png)

## Requirements

- iOS 16+
- Swift 6

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/onmyway133/Snowflake", from: "3.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["Snowflake"]
    )
]
```

Or in Xcode: **File → Add Package Dependencies** and enter the repository URL.

## Usage

### Document

Create a `Document` from SVG data:

```swift
guard let path = Bundle.main.path(forResource: "xmas", ofType: "svg"),
      let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
      let document = Document(data: data) else { return }

let view = document.svg.view(size: CGSize(width: 100, height: 100))
```

<div align="center">
<img src="Screenshots/xmas.png" width="425" height="197" />
</div>

The rendering pipeline is: **SVG element → Shape → UIBezierPath → CALayer**

### Shapes

Each SVG element maps to a typed `Item` subclass:

| SVG element | Swift type |
|---|---|
| `path` | `Path` |
| `circle` | `Circle` |
| `line` | `Line` |
| `polygon` | `Polygon` |
| `polyline` | `Polyline` |
| `rect` | `Rectangle` |
| `ellipse` | `Ellipse` |
| `text` | `Text` |
| `image` | `Image` |

### Style

Style attributes are read from both inline attributes and the `style` attribute:

```xml
<!-- Inline attributes -->
<polygon points="100,10 40,198 190,78 10,78 160,198"
         fill="lime" stroke="purple" stroke-width="5" fill-rule="evenodd" />

<!-- style attribute -->
<polygon points="100,10 40,198 190,78 10,78 160,198"
         style="fill:lime;stroke:purple;stroke-width:5;fill-rule:evenodd;" />
```

<div align="center">
<img src="Screenshots/style.png" />
</div>

### Animation

Because Snowflake renders to `CAShapeLayer`, all layer properties are animatable:

```swift
let animator = Animator()

(svgView.layer.sublayers as? [CAShapeLayer])?.forEach { layer in
    animator.animate(layer: layer)
}
```

Or build your own:

```swift
(svgView.layer.sublayers as? [CAShapeLayer])?.forEach { layer in
    let stroke = CABasicAnimation(keyPath: "strokeEnd")
    stroke.fromValue = 0
    stroke.toValue = 1
    stroke.duration = 3
    layer.add(stroke, forKey: nil)
}
```

<div align="center">
<img src="Screenshots/animation.gif" />
</div>

### Layers and Scaling

Get scaled `CALayer` objects directly:

```swift
let layers = document.svg.layers(size: CGSize(width: 200, height: 100))
```

Get a `UIView` scaled to a given size:

```swift
let view = document.svg.view(size: CGSize(width: 100, height: 100))
```

<div align="center">
<img src="Screenshots/scale.png" />
</div>

### Image

Supports base64 [Data URI](https://en.wikipedia.org/wiki/Data_URI_scheme) embedded images:

```xml
<image x="0" y="0" width="100" height="100" href="data:image/png;base64,..."/>
```

## Author

Khoa Pham, onmyway133@gmail.com

## License

**Snowflake** is available under the MIT license. See the [LICENSE](LICENSE.md) file for more info.
