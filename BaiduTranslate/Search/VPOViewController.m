//
//  VPOViewController.m
//  BaiduTranslate
//
//  Created by lax on 2023/6/21.
//

#import "VPOViewController.h"
#import "NSString+trim.h"

typedef NS_ENUM(NSUInteger, PlatForm) {
    PlatFormIos,
    PlatFormAndroid,
    PlatFormFlutter,
    PlatFormPC,
};

@interface VPOViewController ()
{
    NSArray<NSString *> *resourceArray;
}
@end

@implementation VPOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"VPO";
    resourceArray = @[@"vpo-ios", @"vpo-android", @"vpo-flutter", @"vpo-pc"];
}

- (IBAction)iOSAction:(id)sender {
    [self startSearchInBank:YES oldBank:NO platform:PlatFormIos];
}

- (IBAction)androidAction:(id)sender {
    [self startSearchInBank:YES oldBank:NO platform:PlatFormAndroid];
}

- (IBAction)flutterAction:(id)sender {
    [self startSearchInBank:YES oldBank:NO platform:PlatFormFlutter];
}

- (IBAction)pcAction:(id)sender {
    [self startSearchInBank:YES oldBank:NO platform:PlatFormPC];
}

- (NSString *)getKeyFromIOSString:(NSString *)current {
    NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
    NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
    NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
    return key;
}
- (NSString *)getValueFromIOSString:(NSString *)current {
    NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
    NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
    NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
    return value;
}

- (NSString *)getKeyFromAndroidString:(NSString *)current {
    NSArray *arr = [current componentsSeparatedByString:@"\">"];
    NSString *key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
    NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
    key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return  key;
}
- (NSString *)getValueFromAndroidString:(NSString *)current {
    NSArray *arr = [current componentsSeparatedByString:@"\">"];
    NSString *key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
    NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
    key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return value;
}

- (NSString *)getKeyFromFlutterString:(NSString *)current {
    current = [current stringByReplacingOccurrencesOfString:@"\"\"\"" withString:@"\"\""];
    current = [current stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
    current = [current stringByReplacingOccurrencesOfString:@",\"" withString:@""];
    NSArray *arr = [current componentsSeparatedByString:@":"];
    NSString *key = [arr.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    while ([key hasPrefix:@"\""]) {
        key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    while ([key hasSuffix:@"\""]) {
        key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    return key;
}
- (NSString *)getValueFromFlutterString:(NSString *)current {
    current = [current stringByReplacingOccurrencesOfString:@"\"\"\"" withString:@"\"\""];
    current = [current stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
    current = [current stringByReplacingOccurrencesOfString:@",\"" withString:@""];
    NSArray *arr = [current componentsSeparatedByString:@": "];
    NSString *value = [arr.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    while ([value hasPrefix:@"\""]) {
        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    while ([value hasSuffix:@"\""]) {
        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }
    return value;
}

/// - Parameters:
///   - isInBank: true:在bank-new文件里匹配 false:在源文件里匹配
///   - oldBank: 在bank-new、bank-old文件里匹配
///   - platform: 0 ios 1 android 2 flutter 3 PC
- (void)startSearchInBank:(BOOL)isInBank oldBank:(BOOL)oldBank platform:(NSInteger)platform {
    NSMutableArray *resultZh = [NSMutableArray array];
    // 匹配到的英文
    NSMutableArray *resultEn = [NSMutableArray array];
    // 匹配到的韩语
    NSMutableArray *resultKo = [NSMutableArray array];
    // 未匹配到的
    NSMutableArray *blankZh = [NSMutableArray array];
    NSMutableArray *blankEn = [NSMutableArray array];
    NSMutableArray *blankKo = [NSMutableArray array];
    
    // 读取源文件
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceArray[platform] ofType:@"xls"];
    NSArray *dataArray = [self readFileFromPath:path];
    NSMutableArray *keyArr = [NSMutableArray array];
    NSMutableArray *valueArr = [NSMutableArray array];
    NSMutableDictionary *oriSourceDataZh = [NSMutableDictionary dictionary];
    NSMutableDictionary *oriSourceDataEn = [NSMutableDictionary dictionary];
    NSMutableDictionary *oriSourceDataKo = [NSMutableDictionary dictionary];
    // <key>第1次</key><string>第1次</string>
    NSString *formatStr;
    if (platform == PlatFormIos) {
        formatStr = @"<key>%@</key><string>%@</string>";
    } else if (platform == PlatFormAndroid) {
        // <string name="shouye">首页</string>
        formatStr = @"<string name=\"%@\">%@</string>";
    } else {
        // fiveCheckList: "5S检查表"
        formatStr = @"\"%@\": \"%@\"";
    }
    
    ///===========解析源文件===============
    
    for (NSString *item in dataArray) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        
        if (arr.count > 0 && arr[0].length > 0) {
            NSString *current = arr[0];
            NSString *key;
            NSString *value;
            if (platform == PlatFormIos) {
                key = [self getKeyFromIOSString:current];
                value = [self getValueFromIOSString:current];
            } else if (platform == PlatFormAndroid) {
                key = [self getKeyFromAndroidString:current];
                value = [self getValueFromAndroidString:current];
            } else {
                key = [self getKeyFromFlutterString:current];
                value = [self getValueFromFlutterString:current];
            }
            if (key != nil && value != nil) {
                [keyArr addObject:key];
                [valueArr addObject:value];
                [oriSourceDataZh setValue:value forKey:key];
                // 去重
                //                if ([oriSourceDataZh objectForKey:key] == nil) {
                //                    [resultZh addObject: [NSString stringWithFormat:formatStr, key, value]];
                //                    [oriSourceDataZh setValue:@"" forKey:key];
                //                }
            }
        }
        
        if (arr.count > 1 && arr[1].length > 0) {
            NSString *current = arr[1];
            NSString *key;
            NSString *value;
            if (platform == PlatFormIos) {
                key = [self getKeyFromIOSString:current];
                value = [self getValueFromIOSString:current];
            } else if (platform == PlatFormAndroid) {
                key = [self getKeyFromAndroidString:current];
                value = [self getValueFromAndroidString:current];
            } else {
                key = [self getKeyFromFlutterString:current];
                value = [self getValueFromFlutterString:current];
            }
            if (key != nil && value != nil) {
                [oriSourceDataEn setValue:value forKey:key];
                // 去重
                //                if ([oriSourceDataZh objectForKey:key] == nil) {
                //                    [resultZh addObject: [NSString stringWithFormat:formatStr, key, value]];
                //                    [oriSourceDataZh setValue:@"" forKey:key];
                //                }
            }
        }
        
        if (arr.count > 2 && arr[2].length > 0) {
            NSString *current = arr[2];
            NSString *key;
            NSString *value;
            if (platform == PlatFormIos) {
                key = [self getKeyFromIOSString:current];
                value = [self getValueFromIOSString:current];
            } else if (platform == PlatFormAndroid) {
                key = [self getKeyFromAndroidString:current];
                value = [self getValueFromAndroidString:current];
            } else {
                key = [self getKeyFromFlutterString:current];
                value = [self getValueFromFlutterString:current];
            }
            if (key != nil && value != nil) {
                [oriSourceDataKo setValue:value forKey:key];
                // 去重
                //                if ([oriSourceDataZh objectForKey:key] == nil) {
                //                    [resultZh addObject: [NSString stringWithFormat:formatStr, key, value]];
                //                    [oriSourceDataZh setValue:@"" forKey:key];
                //                }
            }
        }
    }
    
    ///==========读取旧翻译库================
    
    NSMutableDictionary *enSourceData = [NSMutableDictionary dictionary];
    NSMutableDictionary *koSourceData = [NSMutableDictionary dictionary];
    
    // 读取旧翻译库
    if (oldBank) {
        NSString *bankPath = [[NSBundle mainBundle] pathForResource:@"vpo-bank-old" ofType:@"xls"];
        NSArray *fileArr = [self readFileFromPath:bankPath];
        int i = 0;
        while (i < fileArr.count) {
            NSArray<NSString *> *arr = [fileArr[i] componentsSeparatedByString:@"\t"];
            if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"CHN"]) {
                NSString *key = arr[1];
                
                if (i + 1 < fileArr.count) {
                    NSArray<NSString *> *arr = [fileArr[i + 1] componentsSeparatedByString:@"\t"];
                    if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"ENG"]) {
                        [enSourceData setValue:arr[1] forKey:key];
                    }
                    if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"KR"]) {
                        [koSourceData setValue:arr[1] forKey:key];
                    }
                }
                
                if (i + 2 < fileArr.count) {
                    NSArray<NSString *> *arr = [fileArr[i + 2] componentsSeparatedByString:@"\t"];
                    if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"KR"]) {
                        [koSourceData setValue:arr[1] forKey:key];
                    }
                }
            }
            i++;
        }
    }
    
    ///==========读取新翻译库================
    
    NSString *bankPathNew = [[NSBundle mainBundle] pathForResource:@"vpo-bank-new" ofType:@"xls"];
    NSArray *fileArrNew = [self readFileFromPath:bankPathNew];
    for (NSString *item in fileArrNew) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        if (arr.count > 0 && arr[0].length > 0) {
            NSString *key = arr[0];
            NSString *value = arr.count > 1 ? arr[1] : @"";
            [enSourceData setValue:value forKey:key];
            value = arr.count > 2 ? arr[2] : @"";
            [koSourceData setValue:value forKey:key];
        }
        
        //        NSString *kk;
        //        NSString *vv;
        //        if (arr.count > 0 && arr[0].length > 0) {
        //            NSString *key = [self getKeyFromIOSString:arr[0]];
        //            NSString *value = [self getValueFromIOSString:arr[0]];
        //            kk = value;
        //        }
        //        if (arr.count > 1 && arr[1].length > 0) {
        //            NSString *key = [self getKeyFromIOSString:arr[1]];
        //            NSString *value = [self getValueFromIOSString:arr[1]];
        //            vv = value;
        //        }
        //        if (vv && kk) {
        //            [koSourceData setValue:vv forKey:kk];
        //        }
    }
    
    ///==========1.匹配源文件的英文和韩语有没有缺失================
    if (!isInBank) {
        for (NSString *key in keyArr) {
            NSString *value = [oriSourceDataEn objectForKey:key];
            if (value.length == 0) {
                value = [valueArr objectAtIndex:[keyArr indexOfObject:key]];
            } else {
                [oriSourceDataEn removeObjectForKey:key];
            }
            [resultEn addObject:[NSString stringWithFormat:formatStr, key, value]];
            value = [oriSourceDataKo objectForKey:key];
            if (value.length == 0) {
                value = [valueArr objectAtIndex:[keyArr indexOfObject:key]];
            } else {
                [oriSourceDataKo removeObjectForKey:key];
            }
            [resultKo addObject:[NSString stringWithFormat:formatStr, key, value]];
        }
        
        // 筛选只有英文没有中文的数据
        for (NSString *key in oriSourceDataEn.allKeys) {
            NSString *value = [oriSourceDataEn objectForKey:key];
            [blankEn addObject:[NSString stringWithFormat:formatStr, key, value]];
            
            [blankZh addObject:[NSString stringWithFormat:formatStr, key, key]];
        }
        for (NSString *key in oriSourceDataKo.allKeys) {
            NSString *value = [oriSourceDataKo objectForKey:key];
            [blankKo addObject:[NSString stringWithFormat:formatStr, key, value]];
        }
        
        NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
        NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
        return;
    }
    
    
    ///==========2.匹配翻译库================
    for (int i = 0; i < keyArr.count; i++) {
        NSString *key = keyArr[i];
        NSString *value = valueArr[i];
        
        BOOL haveEn = NO;
        BOOL haveKo = NO;
        NSString *str = [enSourceData objectForKey:value];
        if (str != nil && ![str isEqualToString:@""]) {
            NSString *item = [NSString stringWithFormat:formatStr, key, str];
            if ([item containsString:@"\"\""]) {
                item = [item stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
            }
            [resultEn addObject:item];
            haveEn = YES;
        }
        str = [koSourceData objectForKey:value];
        if (str != nil && ![str isEqualToString:@""]) {
            NSString *item = [NSString stringWithFormat:formatStr, key, str];
            if ([item containsString:@"\"\""]) {
                item = [item stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
            }
            [resultKo addObject:item];
            haveKo = YES;
        }
        
        // 匹配不到的用源数据
        if (!haveEn) {
            [resultEn addObject:[NSString stringWithFormat:formatStr, key, [oriSourceDataEn objectForKey:key] ?: value]];
            [blankEn addObject:[NSString stringWithFormat:formatStr, key, value]];
        }
        if (!haveKo) {
            [resultKo addObject:[NSString stringWithFormat:formatStr, key, [oriSourceDataKo objectForKey:key] ?: value]];
            [blankKo addObject:[NSString stringWithFormat:formatStr, key, value]];
        }
        [resultZh addObject:[NSString stringWithFormat:formatStr, key, [oriSourceDataZh objectForKey:key]]];
    }
    
    NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
    NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
    NSLog(@"\n 未匹配到的英文 = \n%@", blankEn);
    NSLog(@"\n 未匹配到的韩语 = \n%@", blankKo);
    NSLog(@"%@匹配完成", resourceArray[platform]);
    
}


// 编码转换
- (NSString *)transform:(id)obj {
    if ([obj isKindOfClass:NSString.class]) {
        return [self transformString:obj];
    }
    if ([obj isKindOfClass:NSArray.class]) {
        NSMutableString *result = [NSMutableString string];
        for (NSString *str in (NSArray *)obj) {
            [str stringByAppendingString:[self transformString:str]];
            [str stringByAppendingString:@"\n"];
        }
        return result;
    }
    return @"error";
}

- (NSString *)transformString:(NSString *)str {
    if (str.length == 0) {
        return @"";
    }
    
    NSString *tempStr1 =
    [str stringByReplacingOccurrencesOfString:@"\\u"
                                   withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSString *result = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        NSLog(@"transformCode error = %@", error);
        return @"error";
    }
    return result;
}

// 读取文件内容
- (NSArray<NSString *> *)readFileFirstColumnFromPath:(NSString *)path {
    NSData *fileData = [NSFileManager.defaultManager contentsAtPath:path];
    // 使用UTF16才能显示汉字
    NSString *dataStr = [[NSString alloc] initWithData:fileData encoding:NSUTF16StringEncoding];
    //转数组
    NSArray<NSString *> *fileArr = [dataStr componentsSeparatedByString:@"\r\n"];
    
    NSMutableArray<NSString *> *muArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *item in fileArr) {
        // 只取第一个单元格
        NSString *str = [item componentsSeparatedByString:@"\t"].firstObject;
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (str.length > 0) {
            [muArr addObject:str];
        }
    }
    return muArr;
}

// 读取文件内容
- (NSArray<NSString *> *)readFileFromPath:(NSString *)path {
    NSData *fileData = [NSFileManager.defaultManager contentsAtPath:path];
    // 使用UTF16才能显示汉字
    NSString *dataStr = [[NSString alloc] initWithData:fileData encoding:NSUTF16StringEncoding];
    //转数组
    NSArray<NSString *> *fileArr = [dataStr componentsSeparatedByString:@"\r\n"];
    return fileArr;
}


@end
