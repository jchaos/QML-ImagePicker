# 用途&特性
* qml图库组件或叫做图片选择器
* 完全是qt做的没有调用系统Gallery,可以说是跨平台的
* 你可以方便的进行优化和扩展

***

# 使用
* 当需要集成到你的项目时你需要把gallerymanager.h放入头文件目录里
* gallerymanager.cpp放入源代码目录
* 在main函数中注册组件
``qmlRegisterType<GalleryManager>("DjangoX.Gallery", 1, 0, "GalleryManager");``
* 把Gallery.qml放进资源系统
* 在需要调用的地方使用组件
```
    ImagePicker{
        id:imagePicker
        anchors.fill:parent
        maxDepth:2//遍历深度
        onSelect:{//当点击图片时
            console.log(filePath)
        }
    }
```
