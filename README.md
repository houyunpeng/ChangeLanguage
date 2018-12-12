# ChangeLanguage

ios  objective-c 多语言，国际化

轻量级 手动切换语言，实时渲染，完美的内存引用


##如何使用
使用宏定义

LanguageSet(@"label_origin_text", {
        _label.text = text;
    });
    
##宏定义

#define LanguageSet(indexStr , code) \
[Lang addAbser:indexStr obj:self block:^(NSString* text) code];\


##功能

1、使用弱引用，保证所有加入_targets的对象能够正常释放

2、能够实时切换语言，并渲染页面

3、目前暂不支持多语言的本地图片切换
