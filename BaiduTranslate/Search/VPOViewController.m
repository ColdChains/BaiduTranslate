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

- (void)transFormFile {
    // 读取资源文件(中-英-韩)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"vpo-bank-new" ofType:@"xls"];
    NSData *fileData = [NSFileManager.defaultManager contentsAtPath:path];
    // 使用UTF16才能显示汉字
    NSString *dataStr = [[NSString alloc] initWithData:fileData encoding:NSUTF16StringEncoding];
    //转数组
    NSArray<NSString *> *fileArr = [dataStr componentsSeparatedByString:@"\r\n"];
    
    NSMutableArray<NSString *> *resultArr = [NSMutableArray arrayWithCapacity:0];
    
    NSString *item = fileArr.firstObject;
    int i = 0;
    while (item != nil) {
        NSArray *arr = [item componentsSeparatedByString:@"\t"];
        NSString *key = arr.firstObject;
        NSString *value = arr.count > 1 ? arr[1] : @"";
        if (fileArr[i + 1]) {
            
        }
    }
    
    
}

- (IBAction)iOSAction:(id)sender {
    [self runIOS];
}

- (IBAction)androidAction:(id)sender {
    [self runAndroid];
}

- (void)runAndroid {
    // 读取需要翻译的文件(中文)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"vpo-android" ofType:@"xls"];
    NSArray<NSString *> *dataArray = [self readFileFirstColumnFromPath:path];
    
    // 读取资源文件(中-英-韩)
    NSString *bankPath = [[NSBundle mainBundle] pathForResource:@"vpo-bank" ofType:@"xls"];
    NSArray<NSString *> *sourceDataArray = [self readFileFirstColumnFromPath:bankPath];
    
    // 读取更新后的文件(中-韩)
    NSString *bankPathNew = [[NSBundle mainBundle] pathForResource:@"vpo-bank-new" ofType:@"xls"];
    NSArray *fileArr = [self readFileFromPath:bankPathNew];
    NSMutableDictionary *enSourceData = [NSMutableDictionary dictionary];
    NSMutableDictionary *koSourceData = [NSMutableDictionary dictionary];
    for (NSString *item in fileArr) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        NSString *key = @"";
        if (arr.count > 1 && arr[1].length > 0) {
            key = arr[1];
            NSString *value = arr.count > 2 ? arr[2] : @"";
            [enSourceData setValue:value forKey:key];
            value = arr.count > 3 ? arr[3] : @"";
            [koSourceData setValue:value forKey:key];
        }
    }
    
    // 匹配到的英文
    NSMutableArray *resultEn = [NSMutableArray array];
    // 匹配到的韩语
    NSMutableArray *resultKo = [NSMutableArray array];
    // 未翻译的中文
    NSMutableArray *blankZh = [NSMutableArray array];
    
    for (NSString *current in dataArray) {
        
        if (current.length == 0 ||
            ![current containsString:@"<string name="] ||
            [current containsString:@"<!--"]) {
            continue;
        }
        
        // <string name="shouye">首页</string>
        NSString *formatStr = @"<string name=\"%@\">%@</string>";
        
        NSArray *arr = [current componentsSeparatedByString:@"\">"];
        NSString *key = [arr.firstObject componentsSeparatedByString:@"<string name=\""].lastObject;
        NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
        
        BOOL have = NO;
        
        // 匹配新的
        if (!have) {
            if ([enSourceData objectForKey:value] != nil && [koSourceData objectForKey:value] != nil) {
                [resultEn addObject:[NSString stringWithFormat:formatStr, key, [enSourceData objectForKey:value]]];
                [resultKo addObject:[NSString stringWithFormat:formatStr, key, [koSourceData objectForKey:value]]];
                have = YES;
            }
        }
        
        // 匹配旧的
        if (!have) {
            for (int i = 0; i < sourceDataArray.count; i++) {
                if ([value isEqualToString:sourceDataArray[i]]) {
                    [resultEn addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                    [resultKo addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 2]]];
                    have = YES;
                    break;
                }
            }
        }
        
        if (!have) {
            [blankZh addObject:value];
        }
    }
    
    NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
    NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
    NSLog(@"\n 未匹配的中文 = \n%@", blankZh);
    NSLog(@"Android匹配完成");
    
}

- (void)runIOS {
    // 读取需要翻译的文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"vpo-ios" ofType:@"xls"];
    NSArray<NSString *> *dataArray = [self readFileFirstColumnFromPath:path];
    
    // 读取资源文件
    NSString *bankPath = [[NSBundle mainBundle] pathForResource:@"vpo-bank" ofType:@"xls"];
    NSArray<NSString *> *sourceDataArray = [self readFileFirstColumnFromPath:bankPath];
    
    // 读取更新后的文件(中-韩)
    NSString *bankPathNew = [[NSBundle mainBundle] pathForResource:@"vpo-bank-new" ofType:@"xls"];
    NSArray *fileArr = [self readFileFromPath:bankPathNew];
    NSMutableDictionary *enSourceData = [NSMutableDictionary dictionary];
    NSMutableDictionary *koSourceData = [NSMutableDictionary dictionary];
    for (NSString *item in fileArr) {
        NSArray<NSString *> *arr = [item componentsSeparatedByString:@"\t"];
        NSString *key = @"";
        if (arr.count > 1 && arr[1].length > 0) {
            key = arr[1];
            NSString *value = arr.count > 2 ? arr[2] : @"";
            [enSourceData setValue:value forKey:key];
            value = arr.count > 3 ? arr[3] : @"";
            [koSourceData setValue:value forKey:key];
        }
    }
    
    // 匹配到的英文
    NSMutableArray *resultEn = [NSMutableArray array];
    // 匹配到的韩语
    NSMutableArray *resultKo = [NSMutableArray array];
    // 未翻译的中文
    NSMutableArray *blankZh = [NSMutableArray array];
    
    for (NSString *current in dataArray) {
        
        if (current.length == 0 || ![current containsString:@"<key>"]) {
            continue;
        }
        
        // <key>第1次</key><string>第1次</string>
        NSString *formatStr = @"<key>%@</key><string>%@</string>";
        
        NSArray *arr = [current componentsSeparatedByString:@"</key><string>"];
        NSString *key = [arr.firstObject componentsSeparatedByString:@"<key>"].lastObject;
        NSString *value = [arr.lastObject componentsSeparatedByString:@"</string>"].firstObject;
        
        BOOL have = NO;
        
        // 匹配新的
        if (!have) {
            if ([enSourceData objectForKey:value] != nil && [koSourceData objectForKey:value] != nil) {
                [resultEn addObject:[NSString stringWithFormat:formatStr, key, [enSourceData objectForKey:value]]];
                [resultKo addObject:[NSString stringWithFormat:formatStr, key, [koSourceData objectForKey:value]]];
                have = YES;
            }
        }
        
        // 匹配旧的
        if (!have) {
            for (int i = 0; i < sourceDataArray.count; i++) {
                if ([value isEqualToString:sourceDataArray[i]]) {
                    [resultEn addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                    [resultKo addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 2]]];
                    have = YES;
                    break;
                }
            }
        }
        
        if (!have) {
            [blankZh addObject:value];
        }
    }
    
    NSLog(@"\n 匹配到的英文 = \n%@", resultEn);
    NSLog(@"\n 匹配到的韩语 = \n%@", resultKo);
    NSLog(@"\n 未匹配的中文 = \n%@", blankZh);
    NSLog(@"iOS匹配完成");
    
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
