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
    [self startSearchInBank:NO];
}

- (IBAction)androidAction:(id)sender {
    [self startSearchInBank:YES];
}

- (void)startSearchInBank:(BOOL)isAndroid {
    // 读取源文件
    NSString *path = [[NSBundle mainBundle] pathForResource:isAndroid ? @"vpo-android" : @"vpo-ios" ofType:@"xls"];
    NSArray *dataArray = [self readFileFromPath:path];
    NSMutableArray *keyArr = [NSMutableArray array];
    NSMutableArray *valueArr = [NSMutableArray array];
    NSMutableDictionary *oriSourceDataEn = [NSMutableDictionary dictionary];
    NSMutableDictionary *oriSourceDataKo = [NSMutableDictionary dictionary];
    // <key>第1次</key><string>第1次</string>
    NSString *formatStr = @"<key>%@</key><string>%@</string>";
    if (isAndroid) {
        // <string name="shouye">首页</string>
        formatStr = @"<string name=\"%@\">%@</string>";
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
            }
            if (key != nil && value != nil) {
                [keyArr addObject:key];
                [valueArr addObject:value];
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
            }
            if (key != nil && value != nil) {
                [oriSourceDataEn setValue:value forKey:key];
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
            }
            if (key != nil && value != nil) {
                [oriSourceDataKo setValue:value forKey:key];
            }
        }
    }
    
    ///==========读取翻译库================
    
    // 读取资源文件(中-英-韩)
    NSString *bankPath = [[NSBundle mainBundle] pathForResource:@"vpo-bank" ofType:@"xls"];
    NSArray *fileArr = [self readFileFromPath:bankPath];
    NSMutableDictionary *enSourceData = [NSMutableDictionary dictionary];
    NSMutableDictionary *koSourceData = [NSMutableDictionary dictionary];
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
    
    // 读取更新后的文件(中-英-韩)
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
    
    // 匹配到的英文
    NSMutableArray *resultEn = [NSMutableArray array];
    // 匹配到的韩语
    NSMutableArray *resultKo = [NSMutableArray array];
    // 未翻译的中文
    NSMutableArray *blankZh = [NSMutableArray array];
    
    ///==========匹配源文件================
    
//    for (NSString *key in keyArr) {
//        NSString *value = [oriSourceDataEn objectForKey:key];
//        if (value.length == 0) {
//            value = [valueArr objectAtIndex:[keyArr indexOfObject:key]];
//        }
//        [resultEn addObject:[NSString stringWithFormat:formatStr, key, value]];
//        value = [oriSourceDataKo objectForKey:key];
//        if (value.length == 0) {
//            value = [valueArr objectAtIndex:[keyArr indexOfObject:key]];
//        }
//        [resultKo addObject:[NSString stringWithFormat:formatStr, key, value]];
//    }
//
//    NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
//    NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
    
    ///==========匹配翻译库================
    
    for (NSString *item in dataArray) {
        
        NSArray<NSString *> *array = [item componentsSeparatedByString:@"\t"];
        NSString *current = array.firstObject;
        
        if (isAndroid) {
            if (current.length == 0 ||
                ![current containsString:@"<string name="] ||
                [current containsString:@"<!--"]) {
                continue;
            }
        } else {
            if (current.length == 0 ||
                ![current containsString:@"<key>"]) {
                continue;
            }
        }
        
        // <key>第1次</key><string>第1次</string>
        NSString *formatStr = @"<key>%@</key><string>%@</string>";
        NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
        NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
        NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
        
        if (isAndroid) {
            // <string name="shouye">首页</string>
            formatStr = @"<string name=\"%@\">%@</string>";
            arr = [current componentsSeparatedByString:@"\">"];
            key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
            value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
        }
        
        BOOL have = NO;
        
        // 匹配新的
        if (!have) {
            if ([enSourceDataNew objectForKey:value] != nil && [koSourceDataNew objectForKey:value] != nil) {
                [resultEn addObject:[NSString stringWithFormat:formatStr, key, [enSourceDataNew objectForKey:value]]];
                [resultKo addObject:[NSString stringWithFormat:formatStr, key, [koSourceDataNew objectForKey:value]]];
                have = YES;
            }
        }
        
        // 匹配旧的
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
