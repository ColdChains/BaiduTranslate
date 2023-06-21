//
//  NSString+trim.m
//  BaiduTranslate
//
//  Created by lax on 2023/5/18.
//

#import "NSString+trim.h"

@implementation NSString (trim)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
