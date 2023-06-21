//
//  DPOViewController.m
//  BaiduTranslate
//
//  Created by lax on 2023/4/4.
//

#import "DPOViewController.h"
#import "NSString+trim.h"

@interface DPOViewController ()

@end

@implementation DPOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DPO";
}

- (IBAction)iOSAction:(id)sender {
        [self runIOS];
}

- (IBAction)androidAction:(id)sender {
    [self runAndroid];
}

- (void)runAndroid {
    // 读取需要翻译的文件(英文)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"android" ofType:@"xls"];
    NSArray<NSString *> *dataArray = [self readFileFromPath:path];
    
    // 读取资源文件(英-越南)
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"xls"];
    NSArray<NSString *> *sourceDataArray = [self readFileFromPath:path2];
    
    // 匹配到的越南语
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *resultVi = [NSMutableArray array];
    // 未翻译的中文
    NSMutableArray *blankZh = [NSMutableArray array];
    // 未翻译的英文
    NSMutableArray *blankEn = [NSMutableArray array];
    for (NSString *current in dataArray) {
        
        if (current.length == 0 || ![current containsString:@"<string name="]) {
            continue;
        }
        
        NSString *str = [current stringByReplacingOccurrencesOfString:@"<string name=\"" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        
        NSString *key = [str componentsSeparatedByString:@"\">"].firstObject.trim;
        NSString *value = [str componentsSeparatedByString:@"\">"].lastObject.trim;
        
        // <string name="login"> Log in </string>
        NSString *formatStr = @"\"<string name=\"%@\">%@</string>";
        
        BOOL have = NO;
        for (int i = 0; i < sourceDataArray.count / 2; i+=2) {
            if ([value.lowercaseString isEqualToString:sourceDataArray[i].lowercaseString]) {
                [result addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                [resultVi addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                have = YES;
                break;
            }
        }
        
        if (!have) {
            [resultVi addObject:[NSString stringWithFormat:formatStr, key, value]];
            [blankZh addObject:key];
            [blankEn addObject:value];
        }
    }
    
    NSLog(@"\n 匹配到的越南语 = \n%@", result);
    NSLog(@"\n 未匹配的中文 = \n%@", blankZh);
    NSLog(@"\n 未匹配的英文 = \n%@", blankEn);
    NSLog(@"Android匹配完成");
    
}

- (void)runIOS {
    // 读取需要翻译的文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ios" ofType:@"xls"];
    NSArray<NSString *> *dataArray = [self readFileFromPath:path];
    
    // 读取资源文件
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"xls"];
    NSArray<NSString *> *sourceDataArray = [self readFileFromPath:path2];
    
    // 匹配到的越南语
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *resultVi = [NSMutableArray array];
    // 未翻译的中文
    NSMutableArray *blankZh = [NSMutableArray array];
    // 未翻译的英文
    NSMutableArray *blankEn = [NSMutableArray array];
    for (NSString *current in dataArray) {
        
        if (current.length == 0 || ![current containsString:@"="]) {
            continue;
        }
        
        NSString *key = [current componentsSeparatedByString:@"="].firstObject.trim;
        NSString *value = [current componentsSeparatedByString:@"="].lastObject.trim;
        
        //        NSLog(@"key = %@, value = %@", key, value);
        key = [key.trim stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        value = [value.trim stringByReplacingOccurrencesOfString:@";" withString:@""];
        value = [value.trim stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //        key = [key substringWithRange:NSMakeRange(2, key.length - 2)];
        //        value = [value substringWithRange:NSMakeRange(2, value.length - 3)];
        //        NSLog(@"key = %@, value = %@", key, value);
        
        // "login" = "Log in";
        NSString *formatStr = @"\"%@\" = \"%@\";";
        
        BOOL have = NO;
        for (int i = 0; i < sourceDataArray.count / 2; i+=2) {
            if ([value.lowercaseString isEqualToString:sourceDataArray[i].lowercaseString]) {
                [result addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                [resultVi addObject:[NSString stringWithFormat:formatStr, key, sourceDataArray[i + 1]]];
                have = YES;
                break;
            }
        }
        
        if (!have) {
            [resultVi addObject:[NSString stringWithFormat:formatStr, key, value]];
            [blankZh addObject:key];
            [blankEn addObject:value];
        }
    }
    
    NSLog(@"\n 匹配到的越南语 = \n%@", result);
    NSLog(@"\n 未匹配的中文 = \n%@", blankZh);
    NSLog(@"\n 未匹配的英文 = \n%@", blankEn);
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
- (NSArray<NSString *> *)readFileFromPath:(NSString *)path {
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


@end
