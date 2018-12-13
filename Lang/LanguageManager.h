//
//  LanguageManager.h
//  exbell_ios
//
//  Created by hyp on 2018/12/3.
//  Copyright © 2018年 hyp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define singleH(name)  +(instancetype)shared##name
/******************** ARC ***********************/
#define singleM(name) \
static id _instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (instancetype)shared##name\
{\
return  _instance;\
}\
+ (void)initialize\
{\
_instance = [[self alloc] init];\
}\
\
- (id)copyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone;\
{\
return _instance;\
}


#define Lang [LanguageManager sharedInstance]



#define LanguageSet(indexStr , code) \
[Lang addAbser:indexStr obj:self block:^(NSString* text) code];\



#define LanguageTrans(indexString)\
[Lang getTextWithIndexString:indexString]



typedef enum : NSUInteger {
    Lang_zh_CN,
    Lang_en_US,
    
} LangType;

@interface LanguageManager : NSObject
{
    NSMutableArray* _targets;
    
    NSLock* _lock;
}


@property(nonatomic, copy)NSString* currentLang;

@property(nonatomic, strong)NSDictionary* langDic;

@property(nonatomic, strong)NSMutableArray* targetsBlock;



singleH(Instance);


-(NSString*)getTextWithIndexString:(NSString*)indexString;

-(void)addAbser:(NSString*)indexString obj:(NSObject*)obj block:(void(^)(NSString* text))block;
@end

NS_ASSUME_NONNULL_END
