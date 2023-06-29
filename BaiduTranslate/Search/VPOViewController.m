//
//  VPOViewController.m
//  BaiduTranslate
//
//  Created by lax on 2023/6/21.
//

#import "VPOViewController.h"
#import "NSString+trim.h"

@interface VPOViewController ()

@end

@implementation VPOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"VPO";
}

- (IBAction)iOSAction:(id)sender {
//    [self startSearchInBank:NO isAndroid:NO isFlutter:NO];
    [self startSearchInBank:YES isAndroid:NO isFlutter:NO];
}

- (IBAction)androidAction:(id)sender {
//    [self startSearchInBank:NO isAndroid:YES isFlutter:NO];
    [self startSearchInBank:YES isAndroid:YES isFlutter:NO];
}

- (IBAction)flutterAction:(id)sender {
    [self startSearchInBank:YES isAndroid:NO isFlutter:YES];
//    [self startSearchInBank:NO isAndroid:NO isFlutter:YES];
}

/// - Parameters:
///   - inBank: 在bank文件里匹配
///   - isAndroid:
///   - isFlutter:
- (void)startSearchInBank:(BOOL)inBank isAndroid:(BOOL)isAndroid isFlutter:(BOOL)isFlutter {
    NSMutableArray *resultZh = [NSMutableArray array];
    // 匹配到的英文
    NSMutableArray *resultEn = [NSMutableArray array];
    // 匹配到的韩语
    NSMutableArray *resultKo = [NSMutableArray array];
    // 未翻译的
    NSMutableArray *blankZh = [NSMutableArray array];
    NSMutableArray *blankEn = [NSMutableArray array];
    NSMutableArray *blankKo = [NSMutableArray array];
    
    // 读取源文件
    NSString *path = [[NSBundle mainBundle] pathForResource:isAndroid ? @"vpo-android" : isFlutter ? @"vpo-flutter" : @"vpo-ios" ofType:@"xls"];
    NSArray *dataArray = [self readFileFromPath:path];
    NSMutableArray *keyArr = [NSMutableArray array];
    NSMutableArray *valueArr = [NSMutableArray array];
    NSMutableDictionary *oriSourceDataZh = [NSMutableDictionary dictionary];
    NSMutableDictionary *oriSourceDataEn = [NSMutableDictionary dictionary];
    NSMutableDictionary *oriSourceDataKo = [NSMutableDictionary dictionary];
    // <key>第1次</key><string>第1次</string>
    NSString *formatStr = @"<key>%@</key><string>%@</string>";
    if (isAndroid) {
        // <string name="shouye">首页</string>
        formatStr = @"<string name=\"%@\">%@</string>";
    }
    if (isFlutter) {
        // fiveCheckList: "5S检查表"
        formatStr = @"\"%@\": \"%@\"";
    }
    
    ///===========解析源文件===============
    
    for (NSString *item in dataArray) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        
        if (arr.count > 0 && arr[0].length > 0) {
            NSString *current = arr[0];
            NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
            NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
            NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
            if (isAndroid) {
                arr = [current componentsSeparatedByString:@"\">"];
                key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
                value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
                key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            if (isFlutter) {
                arr = [current componentsSeparatedByString:@":"];
                key = [arr.firstObject trim];
                value = [arr.lastObject trim];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            if (key != nil && value != nil) {
                [keyArr addObject:key];
                [valueArr addObject:value];
                // 去重
//                if ([oriSourceDataZh objectForKey:key] == nil) {
//                    [resultZh addObject: [NSString stringWithFormat:formatStr, key, value]];
//                    [oriSourceDataZh setValue:@"" forKey:key];
//                }
            }
        }
        
        if (arr.count > 1 && arr[1].length > 0) {
            NSString *current = arr[1];
            NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
            NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
            NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
            if (isAndroid) {
                arr = [current componentsSeparatedByString:@"\">"];
                key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
                value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
                key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            if (isFlutter) {
                arr = [current componentsSeparatedByString:@":"];
                key = [arr.firstObject trim];
                value = [arr.lastObject trim];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
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
            NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
            NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
            NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
            if (isAndroid) {
                arr = [current componentsSeparatedByString:@"\">"];
                key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
                value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
                key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            if (isFlutter) {
                arr = [current componentsSeparatedByString:@":"];
                key = [arr.firstObject trim];
                value = [arr.lastObject trim];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
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
    
    ///==========读取翻译库================
    
    // 读取旧翻译库
//    NSString *bankPath = [[NSBundle mainBundle] pathForResource:@"vpo-bank" ofType:@"xls"];
//    NSArray *fileArr = [self readFileFromPath:bankPath];
//    NSMutableDictionary *enSourceData = [NSMutableDictionary dictionary];
//    NSMutableDictionary *koSourceData = [NSMutableDictionary dictionary];
//    int i = 0;
//    while (i < fileArr.count) {
//        NSArray<NSString *> *arr = [fileArr[i] componentsSeparatedByString:@"\t"];
//        if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"CHN"]) {
//            NSString *key = arr[1];
//
//            if (i + 1 < fileArr.count) {
//                NSArray<NSString *> *arr = [fileArr[i + 1] componentsSeparatedByString:@"\t"];
//                if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"ENG"]) {
//                    [enSourceData setValue:arr[1] forKey:key];
//                }
//                if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"KR"]) {
//                    [koSourceData setValue:arr[1] forKey:key];
//                }
//            }
//
//            if (i + 2 < fileArr.count) {
//                NSArray<NSString *> *arr = [fileArr[i + 2] componentsSeparatedByString:@"\t"];
//                if (arr.count > 1 && arr[0].length > 0 && arr[1].length > 0 && [arr[0] isEqualToString:@"KR"]) {
//                    [koSourceData setValue:arr[1] forKey:key];
//                }
//            }
//        }
//        i++;
//    }
    
    // 读取新翻译库
    NSString *bankPathNew = [[NSBundle mainBundle] pathForResource:@"vpo-bank-new" ofType:@"xls"];
    NSArray *fileArrNew = [self readFileFromPath:bankPathNew];
    NSMutableDictionary *enSourceDataNew = [NSMutableDictionary dictionary];
    NSMutableDictionary *koSourceDataNew = [NSMutableDictionary dictionary];
    for (NSString *item in fileArrNew) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        if (arr.count > 1 && arr[1].length > 0) {
            NSString *key = arr[1];
            NSString *value = arr.count > 2 ? arr[2] : @"";
            [enSourceDataNew setValue:value forKey:key];
            value = arr.count > 3 ? arr[3] : @"";
            [koSourceDataNew setValue:value forKey:key];
        }
    }
    
    ///==========匹配源文件================
    if (!inBank) {
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
    
    
    ///==========匹配翻译库================
    for (int i = 0; i < keyArr.count; i++) {
        NSString *key = keyArr[i];
        NSString *value = valueArr[i];
        
        BOOL have = NO;
        
        // 匹配新的翻译库
        if (!have) {
            if ([enSourceDataNew objectForKey:value] != nil && [koSourceDataNew objectForKey:value] != nil) {
                [resultEn addObject:[NSString stringWithFormat:formatStr, key, [enSourceDataNew objectForKey:value]]];
                [resultKo addObject:[NSString stringWithFormat:formatStr, key, [koSourceDataNew objectForKey:value]]];
                have = YES;
            }
        }
        
        // 匹配旧的翻译库
//        if (!have) {
//            if ([enSourceData objectForKey:value] != nil && [koSourceData objectForKey:value] != nil) {
//                [resultEn addObject:[NSString stringWithFormat:formatStr, key, [enSourceData objectForKey:value]]];
//                [resultKo addObject:[NSString stringWithFormat:formatStr, key, [koSourceData objectForKey:value]]];
//                have = YES;
//            }
//        }
        
        if (!have) {
            [blankZh addObject:value];
            // 匹配不到的用源数据
            [resultEn addObject:[NSString stringWithFormat:formatStr, key, [oriSourceDataEn objectForKey:key]]];
            [resultKo addObject:[NSString stringWithFormat:formatStr, key, [oriSourceDataKo objectForKey:key]]];
        }
    }
    
    NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
    NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
    NSLog(@"\n 未匹配的中文 = \n%@", blankZh);
    NSLog(isAndroid ? @"Android匹配完成" : @"iOS匹配完成");
    
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
