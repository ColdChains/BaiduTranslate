//
//  NetWork.m
//  BaiduTranslate
//
//  Created by lax on 2023/4/4.
//

#import "NetWork.h"

@implementation NetWork

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return _sessionManager;
}

#pragma mark - init
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static NetWork *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [NetWork.alloc init];
    });
    return manager;
}

#pragma mark - method
- (void)showActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    });
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    });
}

- (NSURLSessionDataTask *)getRequest:(NSString *)urlString parameters:(id)parameters success:(RequestSuccess)success failure:(Requestfailure)failure {
    [self showActivityIndicator];
    NSURLSessionDataTask *task =  [self.sessionManager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideActivityIndicator];
        NSLog(@"url = %@\nparam = %@", urlString, parameters);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideActivityIndicator];
        NSLog(@"url = %@\nparam = %@", urlString, parameters);
    }];
    return  task;
}

- (NSURLSessionDataTask *)postRequest:(NSString *)urlString parameters:(id)parameters success:(RequestSuccess)success failure:(Requestfailure)failure {
    NSURLSessionDataTask *task = [self.sessionManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideActivityIndicator];
        NSLog(@"url = %@\nparam = %@", urlString, parameters);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideActivityIndicator];
        NSLog(@"url = %@\nparam = %@", urlString, parameters);
    }];
    return task;
}

@end
