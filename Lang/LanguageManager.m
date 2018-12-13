//
//  LanguageManager.m
//  exbell_ios
//
//  Created by hyp on 2018/12/3.
//  Copyright © 2018年 hyp. All rights reserved.
//

#import "LanguageManager.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <objc/message.h>
@implementation LanguageManager


typedef id (^WeakReference)(void);

static LanguageManager *_instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LanguageManager alloc] init];

    });
    return _instance;
}

-(instancetype)init
{
    if (self = [super init]) {
        
        _lock = [[NSLock alloc] init];
        
        _targets = [[NSMutableArray alloc] initWithCapacity:0];
        _currentLang = @"zh-CN";//设置默认语言，可根据所需缓存用户选择的语言
        
        
    }
    return self;
}

-(NSDictionary*)langDic
{
    if (!_langDic) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"lang" ofType:@"plist"];//在这里我的语言文件使用的是plist
        _langDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    }
    
    return _langDic;
}

-(void)setCurrentLang:(NSString *)currentLang
{
    _currentLang = currentLang;
    
    [self performAll];
 
}

-(void)performAll
{
    [_lock lock];
    @onExit{
        [_lock unlock];
    };
    
    for (NSDictionary* dic in self.targetsBlock) {
        
        for (NSString* indexString in dic.allKeys) {
            void(^block)(NSString* text) = dic[indexString];
            
            if (block) {
                block([self getTextWithIndexString:[indexString componentsSeparatedByString:@"__Lang__"].firstObject]);
            }
        }
    }
}


-(LangType)langType
{
    if ([self.currentLang isEqualToString:@"zh-CN"]) {
        return Lang_zh_CN;
    }
    if ([self.currentLang isEqualToString:@"en-US"]) {
        return Lang_en_US;
    }
    
    
    return Lang_zh_CN;
}


-(NSMutableArray*)targetsBlock
{
    if (!_targetsBlock) {
        _targetsBlock = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _targetsBlock;
}

-(NSString*)getTextWithIndexString:(NSString*)indexString
{
    NSString* langType = @"";//默认值
    switch ([self langType]) {
        case Lang_zh_CN:
        {
            langType = @"zh-CN";
        }
            break;
        case Lang_en_US:
        {
            langType = @"en-US";
        }
            break;
            
        default:
            langType = @"zh-CN";
            break;
    }
    
    //从语言文件取出对应翻译值
    return [(NSDictionary*)[self.langDic objectForKey:indexString] objectForKey:langType];
    
}

-(void)addAbser:(NSString*)indexString obj:(NSObject*)obj block:(void(^)(NSString* text))block
{
    NSAssert(block != nil, @"block 不能为空！！");
    
    NSString* text = [self getTextWithIndexString:indexString];
    block(text);
    NSString* key = [NSString stringWithFormat:@"%@__Lang__%lld",indexString,obj.hash];
    
    [self.targetsBlock addObject:@{key:block}];
    
    [self resetDeallocMethodWithInstance:obj];
}



-(void)resetDeallocMethodWithInstance:(NSObject*)obj
{
    
    
    if ([self containValueOfObject:obj]) {
        return;
    }
//    [_targets addObject:[NSValue valueWithNonretainedObject:obj]];
    [_targets addObject:makeWeakReference(obj)];
    
    
        SEL deallocSel = sel_registerName("dealloc");
        Method deallocMethod = class_getInstanceMethod(obj.class, deallocSel);
    
        
        __block void (*deallocBlock)(id , SEL) = NULL;
        id block = NULL;
        block = ^(NSObject* objc,SEL selector){
           
            [self removeAllTargetWitSuffixKey:[NSString stringWithFormat:@"%lld",objc.hash]];
            
            [self removeObjectValueWithObj:objc];
            
           
            
            if (deallocBlock) {
                deallocBlock(objc,selector);
            }else{
                
                void (*my_objc_msgSend)(id ,SEL) = (void *)objc_msgSend;
                
                my_objc_msgSend(objc,selector);
                
            }
        };
        IMP blockImp = imp_implementationWithBlock(block);
    
    if (!class_addMethod(obj.class, deallocSel, blockImp, "v@:")) {
        deallocBlock = (__typeof__(deallocBlock))method_setImplementation(deallocMethod, blockImp);
    }

    
}



WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
    return ref ? ref() : nil;
}



-(BOOL)containValueOfObject:(NSObject*)obj
{
    [_lock lock];
    @onExit{
        [_lock unlock];
    };
    
    for (WeakReference reference in _targets) {
        
        NSObject* object = weakReferenceNonretainedObjectValue(reference);
        
        
        if (object == obj) {
            return YES;
        }
        
    }
    
    
    return NO;
}

-(void)removeObjectValueWithObj:(NSObject*)tempObj
{
    [_lock lock];
    @onExit{
        [_lock unlock];
    };
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:_targets];
    
    [_targets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WeakReference reference = (WeakReference)obj;
        NSObject* object = (NSObject*)weakReferenceNonretainedObjectValue(reference);
        if (object == tempObj || object == nil) {
            [tempArray removeObject:reference];
        }
    }];
    _targets = [NSMutableArray arrayWithArray:tempArray];
    
}

-(void)removeAllTargetWitSuffixKey:(NSString*)tempKey
{
    
    [_lock lock];
    @onExit{
        [_lock unlock];
    };
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.targetsBlock];
    [self.targetsBlock enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary* dic = (NSDictionary*)obj;
        for (NSString* indexString in dic.allKeys) {
            if ([indexString containsString:tempKey]) {
                [tempArray removeObject:dic];
            }
        }
    }];
    self.targetsBlock = [NSMutableArray arrayWithArray:tempArray];
    
    
}

/*
 -(RACSubject*)addLanguageObserver:(RACTuple*)tuple
 {
 
 
 RACSignal* signal = [[RACSignal
 createSignal:^(id<RACSubscriber> subscriber) {
 //          @strongify(self);
 
 [self addTupleValues:tuple];
 //          NSString* targetKey = @"target";
 //          objc_setAssociatedObject(subscriber, &targetKey,NSStringFromSelector(selector), OBJC_ASSOCIATION_RETAIN);
 
 [subscriber sendNext:tuple];
 
 RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
 [subscriber sendCompleted];
 }];
 [self.rac_deallocDisposable addDisposable:disposable];
 
 return [RACDisposable disposableWithBlock:^{
 //              @strongify(self);
 [self.rac_deallocDisposable removeDisposable:disposable];
 //              [self removeTarget:subscriber action:@selector(sendNext:) forControlEvents:controlEvents];
 }];
 }]
 setNameWithFormat:@"aaa"];
 
 [signal subscribeNext:^(RACTuple*  _Nullable x) {
 
 RACTupleUnpack(id targetObj,NSObject* values,NSString* sel) = x;
 
 
 
 NSMethodSignature* signature = [NSMethodSignature methodSignatureForSelector:NSSelectorFromString(sel)];
 NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
 invocation.target = targetObj;
 invocation.selector = NSSelectorFromString(sel);
 
 NSString* textValue = nil;
 if ([values isKindOfClass:[NSArray class]]) {
 NSArray* arr = (NSArray*)values;
 //            textValue = [(NSArray*)values firstObject];
 
 NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
 paramsCount = MIN(paramsCount, arr.count);
 for (NSInteger i = 0; i<paramsCount; i++) {
 id object = i == 0 ? [self getTextWithIndexString:arr[i]] : arr[i];
 [invocation setArgument:&object atIndex:i];
 }
 
 }else{
 
 NSString* text = [self getTextWithIndexString:(NSString*)values];
 [invocation setArgument:&text atIndex:2];
 
 }
 
 [invocation invoke];
 
 
 }];
 
 
 RACSubject* sub = [RACSubject subject];
 
 //    [self.signal subscribeNext:^(id  _Nullable x) {
 //        NSString* text = [self getTextWithIndexString:x];
 //
 //    }];
 
 return sub;
 
 }
 
 -(void)addTupleValues:(RACTuple*)tuple
 {
 
 //    NSDictionary* subDic = @{
 //                             @"target":target,
 //                             @"SEL":NSStringFromSelector(selector),
 //                             @"tupleValue":tuple
 //                             };
 
 [_targets addObject:tuple];
 
 }
 */


@end
