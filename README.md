# VISDWebImageWorker

VISDWebImageWorker 基于 SDWebImage 和 VIImageWorker。

SDWebImage 用来缓存网络中的图片，VIImageWorker 是一个图片处理的工具类库。

在项目中我们经常会遇到这样的需求，将网络中的图片取到后再进行圆角处理（如用户头像）、模糊处理（如封面图片），然后才显示到界面上。有的时候网络中下载下来的图片尺寸和 UI 的尺寸不是完美匹配的，过大的图片会浪费内存和渲染开销。

上面遇到的问题，大部分人的做法是每次显示的时候都去处理一次图片，或者用圆角遮罩去处理圆形或圆角的图片，性能最差的使用 `layer.cornerRadius` 去实时渲染。这些都不是最好的解决方案，所以为了达到最优解，应该是图片从网络下载下来后，在缓存前，对图片进行加工，然后再保存到缓存中，之后再从缓存里面取图片就是已经加工好的图片了。

注意，要实现上面说的最优解的功能，我们还会遇到一个问题，通常都是用 image 的 URL 地址作为缓存的 key，但现实的需求中一个 URL 地址的图片可能会有不同的处理。比如：用户个人主页，头像显示圆角，背后的背景封面是头像的正方形原图模糊后的效果。好在 VISDWebImageWorker 做了处理，只要是不同的效果，都会缓存到不同的 key 值里面。

VISDWebImageWorker 还支持图片应用多种效果，比如：resize -> 模糊 -> 圆角。然后不同的处理顺序会缓存到不同的key里。

## 引入项目

使用 Pod 引入：`pod 'VISDWebImageWorker'`

## 如何使用

实现一个缓存圆角图片。

    // 设置要缓存的图片，这里设置成处理成圆角再缓存
    VIImageEffect *roundEffect = [VIImageEffect roundEffect];
    VIImageWorker *imageWorker = [[VIImageWorker alloc] initWithEffects:@[roundEffect]];
    VIWebImageManager *imageManager = [[VIWebImageManager alloc] initWithImageWorker:imageWorker];
    [self.imageView vi_setWebImageManagerDelegate:imageManager];
    
    // 请求图片
    [self.imageView vi_setImageWithURL:<#IMAGE URL#>];


## 扩展 Effect

如果已有的 Effect 不能满足需求，可以自己写 Effect 类。
继承 `VIImageEffect` 类，实现 `applyEffect:` 方法就可以。

也欢迎将你发现的 effect 提交 pr 到 [VIImageWorker](https://github.com/vitoziv/VIImageWorker)

