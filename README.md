# GZZDatePicker

A simple custom DatePicker (一个简单的自定义日期选择控件)

# Description

* 支持年数滑到底部自动加载更多
* 支持循环滑动选择

# Type

```
// MARK: - 日期选择类型
enum GZZDatePickerType: Int {
    case year   // 年
    case month  // 年月
    case day    // 年月日
    case time   // 年月日时分
}
```

# Usage

```
let datePicker = GZZDatePicker(.year)
datePicker.show()
```

# Methods

```
/// 设置日期选择类型（默认 .month）
public func setType(_ type: GZZDatePickerType)
    
/// 设置最小日期（默认不限制）
public func setMinDate(_ date: Date?)
    
/// 设置最大日期（默认不限制）
public func setMaxDate(_ date: Date?)
    
/// 获取最小日期
public func getMinDate() -> Date?
    
/// 获取最大日期
public func getMaxDate() -> Date?
    
/// 设置选中日期（默认当前时间）
public func setSelectedDate(_ date: Date)
    
/// 获取选中日期
public func getSelectedDate() -> Date
```

# Screenshots

![](https://ws2.sinaimg.cn/large/006tNc79gy1fr78wxgzz4j30yi1pcn2s.jpg)

![](https://ws1.sinaimg.cn/large/006tNc79gy1fr78x1um3vj30yi1pcwkn.jpg)

![](https://ws3.sinaimg.cn/large/006tNc79gy1fr78x60scoj30yi1pcjxu.jpg)

![](https://ws2.sinaimg.cn/large/006tNc79gy1fr78x9hxdfj30yi1pcq9x.jpg)


