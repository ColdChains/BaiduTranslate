//
//  TranslateViewController.m
//  BaiduTranslate
//
//  Created by lax on 2023/4/4.
//

#import "TranslateViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "NetWork.h"
#import "DPOViewController.h"
#import "VPOViewController.h"

@interface TranslateViewController ()

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)translateAction:(id)sender {
    // flutter文件格式翻译
    // 在此设置需要翻译的文字 在"翻译完成"处查看打印结果
    NSArray *arr = @[
        @"上传反馈照片/视频",
        @"上传照片/视频",
        @"请上传反馈照片/视频",
        @"请确认签阅",
        @"委派责任人",
    ];
    [self translate:arr];
}

- (IBAction)dpoAction:(id)sender {
    [self.navigationController pushViewController:[[DPOViewController alloc] init] animated:YES];
}

- (IBAction)vpoAction:(id)sender {
    [self.navigationController pushViewController:[[VPOViewController alloc] init] animated:YES];
}

// 翻译英文
- (void)translate:(NSArray *)arr {
    // @"http://api.fanyi.baidu.com/api/trans/vip/translate?q=apple&from=en&to=zh&appid=2015063000000001&salt=1435660288&sign=f89f9594663708c1605f3d736d01d2d4";
    
    NSString *url = @"https://fanyi-api.baidu.com/api/trans/vip/translate";
    NSString *appid = @"20230220001568788";
    NSString *salt = [self uuid];
    NSString *q = [arr componentsJoinedByString:@"\n"];
    NSString *to = @"en"; // 英语
    NSString *sign = [self md5String:[NSString stringWithFormat:@"%@%@%@3pekYKmo0zWuefeZwPnv", appid, q, salt]];
    sign = [sign lowercaseString];
    
    NSDictionary *para = @{
        @"q" : q, //    TEXT    Y    请求翻译query    UTF-8编码
        @"from" : @"auto", //    TEXT    Y    翻译源语言    语言列表(可设置为auto)
        @"to" : to, //    TEXT    Y    译文语言    语言列表(不可设置为auto)
        @"appid" : appid, //    TEXT    Y    APP ID    可在管理控制台查看
        @"salt" : salt, //    TEXT    Y    随机数
        @"sign" : sign //    TEXT    Y    签名    appid+q+salt+密钥 的MD5值
    };

    [NetWork.shared getRequest:url parameters:para success:^(id  _Nullable obj) {
        NSLog(@"\n%@", obj);
        NSArray *trans = obj[@"trans_result"];
        
        NSMutableArray *zhArr = [NSMutableArray array];
        NSMutableArray *enArr = [NSMutableArray array];
        NSMutableArray *keyArr = [NSMutableArray array];
        
        for (NSDictionary *dic in trans) {
            NSString *src = dic[@"src"]; // 中
            NSString *dst = dic[@"dst"]; // 英
            
            // key：小驼峰 英文：首字母大写
            NSString *key = [dst.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
            key = [[key substringToIndex:1].lowercaseString stringByAppendingString: [key substringFromIndex:1]];
            // 处理特殊字符
            key = [key stringByReplacingOccurrencesOfString:@"," withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"." withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"?" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@":" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"(" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@")" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"&" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"'" withString:@""];
            key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"Or"];
            [keyArr addObject:key];
            
            [zhArr addObject:[NSString stringWithFormat:@"\"%@\" : \"%@\"", key, src]];
            [enArr addObject:[NSString stringWithFormat:@"\"%@\" : \"%@\"", key, dst.capitalizedString]];
        }
        
        NSString *zhStr = [zhArr componentsJoinedByString:@",\n"];
        NSString *enStr = [enArr componentsJoinedByString:@",\n"];
        
        NSString *result = [NSString stringWithFormat:@"\n================zh====================\n%@\n================en====================\n%@", zhStr, enStr];
        
        [self translateToKor:arr keyArr:keyArr result:result];
        
    } failure:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

// 翻译韩语
- (void)translateToKor:(NSArray *)arr keyArr:(NSArray *)keyArr result:(NSString *)result {
    if (arr.count != keyArr.count) {
        return;
    }
    
    NSString *url = @"https://fanyi-api.baidu.com/api/trans/vip/translate";
    NSString *appid = @"20230220001568788";
    NSString *salt = [self uuid];
    NSString *q = [arr componentsJoinedByString:@"\n"];
    NSString *to = @"kor"; // 韩语
    NSString *sign = [self md5String:[NSString stringWithFormat:@"%@%@%@3pekYKmo0zWuefeZwPnv", appid, q, salt]];
    sign = [sign lowercaseString];
    
    NSDictionary *para = @{
        @"q" : q, //    TEXT    Y    请求翻译query    UTF-8编码
        @"from" : @"auto", //    TEXT    Y    翻译源语言    语言列表(可设置为auto)
        @"to" : to, //    TEXT    Y    译文语言    语言列表(不可设置为auto)
        @"appid" : appid, //    TEXT    Y    APP ID    可在管理控制台查看
        @"salt" : salt, //    TEXT    Y    随机数
        @"sign" : sign //    TEXT    Y    签名    appid+q+salt+密钥 的MD5值
    };

    [NetWork.shared getRequest:url parameters:para success:^(id  _Nullable obj) {
        NSLog(@"%@", obj);
        NSArray *trans = obj[@"trans_result"];
        
        NSMutableArray *koArr = [NSMutableArray array];
        
        for (NSDictionary *dic in trans) {
            NSString *dst = dic[@"dst"]; // 韩
            [koArr addObject:[NSString stringWithFormat:@"\"%@\" : \"%@\"", keyArr[[trans indexOfObject:dic]], dst]];
        }
        
        NSString *koStr = [koArr componentsJoinedByString:@",\n"];
        NSString *str = [NSString stringWithFormat:@"%@\n================ko====================\n%@\n================end====================\n", result, koStr];
        NSLog(@"%@", str);
        NSLog(@"翻译完成\n");
        
    } failure:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

-(NSString*)uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (NSString *)md5String:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

@end
