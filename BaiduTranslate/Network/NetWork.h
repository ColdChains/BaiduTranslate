//
//  NetWork.h
//  BaiduTranslate
//
//  Created by lax on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^RequestSuccess) (id _Nullable obj);
typedef void (^Requestfailure) (NSError * _Nullable error);


@interface NetWork : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

+ (instancetype)shared;

- (NSURLSessionDataTask *)getRequest:(NSString *)urlString
                          parameters:(nullable id)parameters
                             success:(nullable RequestSuccess)success
                             failure:(nullable Requestfailure)failure;        

- (NSURLSessionDataTask *)postRequest:(NSString *)urlString
                           parameters:(nullable id)parameters
                              success:(nullable RequestSuccess)success
                              failure:(nullable Requestfailure)failure;

@end

NS_ASSUME_NONNULL_END
