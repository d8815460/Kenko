UIImage-AF-Additions
=============================

UIImage convenience additions in Swift and Objective-C


Native Swift
=============================

### Image from solid color
```Swift
UIImage(color:UIColor, size:CGSize)
```

### Image from gradient colors
```Swift
UIImage(gradientColors:[UIColor], size:CGSize) 
anImage.applyGradientColors(gradientColors: [UIColor], blendMode: CGBlendMode) -> UIImage 
```

### Image with Text
```Swift
UIImage(text: String, font: UIFont, color: UIColor, backgroundColor: UIColor, size:CGSize, offset: CGPoint) 
```

### Image from UIView
```Swift
UIImage(fromView view: UIView)
```

### Image with Radial Gradient
```Swift
UIImage(startColor: UIColor, endColor: UIColor, radialGradientCenter: CGPoint, radius:Float, size:CGSize)
```

### Padding and Alpha
```Swift
anImage.hasAlpha() -> Bool
anImage.applyAlpha() -> UIImage 
anImage.applyPadding(padding: CGFloat) -> UIImage 
anImage.imageRefWithPadding(padding: CGFloat, size:CGSize) -> CGImageRef 
```

### Crop and Resize
```Swift
func crop(bounds: CGRect) -> UIImage 
func resize(size:CGSize, contentMode: UIImageContentMode = .ScaleToFill) -> UIImage 
```

### Circle and Corner Radius
```Swift
func roundCorners(cornerRadius:CGFloat, stroke:CGFloat, color:UIColor, padding: CGFloat = 0) -> UIImage
func roundCornersToCircle(#stroke:CGFloat, color:UIColor, padding: CGFloat = 0) -> UIImage 
```

Objective-C
=============================

### CocoaPods
```
pod 'UIImage+AF+Additions', :git => 'https://github.com/teklabs/UIImageAFAdditions.git'
```

### Header
```
#import "UIImage+AF+Additions.h"
```

### Image from solid color
```Objective-C
+ (UIImage *) imageFromColor:(UIColor *)color;
+ (UIImage *) imageFromColor:(UIColor *)color size:(CGSize)size;
```

### Image from gradient colors
```Objective-C
+ (UIImage *) imageWithGradientColors:(NSArray *)colors;
+ (UIImage *) imageWithGradientColors:(NSArray *)colors size:(CGSize)size;
- (UIImage *) applyGradientColors:(NSArray *)colors;
- (UIImage *) applyGradientColors:(NSArray *)colors withBlendMode:(CGBlendMode)blendMode;
```

### Image with text
```Objective-C
- (UIImage*) drawText:(NSString*)text withFont:(UIFont *)font color:(UIColor *)color;
- (UIImage*) drawText:(NSString*)text withFont:(UIFont *)font color:(UIColor *)color align:(NSTextAlignment)align offset:(CGPoint)offset;
```

### Image from UIView
```Objective-C
+ (UIImage *) imageFromView:(UIView *)view;
```

### Image with Radial Gradient
```Objective-C
+ (UIImage *) imageWithRadialGradientSize:(CGSize)size start:(UIColor *)start end:( UIColor *)end centre:(CGPoint)centre radius:(float)radius;
```

### Alpha - From Trevor Harmon
```Objective-C
- (BOOL) hasAlpha;
- (UIImage *) imageWithAlpha;
- (UIImage *) transparentBorderImage:(NSUInteger)borderSize;
```

### Resize - From Trevor Harmon
```Objective-C
- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
```

### Corner Radius
```Objective-C
- (UIImage *) roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (UIImage *) circleImageWithBorderSize:(NSInteger)borderSize;
```

### Image Effects - From Apple
```Objective-C
- (UIImage *) applyLightEffect;
- (UIImage *) applyExtraLightEffect;
- (UIImage *) applyDarkEffect;
- (UIImage *) applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *) applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
```
