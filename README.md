# GZZDatePicker

> 因为苹果自带的 `UIDatePicker` 只能选择 `年月日` ，还不能自定义，所以就使用 `UIPickerView` 自定义了日期选择框。

## 有这几种类型

```
// MARK: - 日期选择类型
enum GZZDatePickerType: Int {

    case year // 年
    case month // 年月
    case day // 年月日
    case time // 年月日时分
}
```

## 效果图

![年.png](http://upload-images.jianshu.io/upload_images/1930874-8ebfff49b1678735.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![年月.png](http://upload-images.jianshu.io/upload_images/1930874-7156a99d0e176a19.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![年月日.png](http://upload-images.jianshu.io/upload_images/1930874-45aa166cdbac9153.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![日期小时分钟.png](http://upload-images.jianshu.io/upload_images/1930874-62d78cad159755c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
