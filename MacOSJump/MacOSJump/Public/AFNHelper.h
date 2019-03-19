//
//  AFNHelper.h
//  Jump
//
//  Created by jumpapp1 on 2018/12/13.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^SuccessBlock)(id responseObject);
typedef void (^FailedBlock)(id error);

@interface AFNHelper : AFHTTPSessionManager
//
//
//+ (AFNHelper *)sharedManager;
//
//
///**
// *  get请求
// *
// *  @param ipAddress        接口ip地址
// *  @param parameters 参数
// *  @param success    请求成功的block
// *  @param failure    请求失败的block
// */
//+ (NSURLSessionDataTask *)get:(NSString *)url ipAddress:(NSString *)ipAddress port:(NSString *)port parameter:(id )parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure;
//
///**
// *  post请求
// *
// *  @param url        接口地址
// *  @param ipAddress        接口ip基地址
// *  @param parameters 参数
// *  @param success    请求成功的block
// *  @param failure    请求失败的block
// */
//+ (NSURLSessionDataTask *)post:(NSString *)url ipAddress:(NSString *)ipAddress port:(NSString *)port parameters:(id)parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure;
//
//
///**
// *  文件上传
// *
// *  @param url        接口url
// *  @param parameters 参数
// *  @param block      图片data
// *  @param success    请求成功的block
// *  @param failure    请求失败的block
// */
//+ (NSURLSessionDataTask *)post:(NSString *)url parameters:(id)parameters  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(id responseObject))success faliure:(void (^)(id error))failure;
//
//
///**
// *  文件上传(不需要基地址)
// *
// *  @param url        接口url
// *  @param parameters 参数
// *  @param block      图片data
// *  @param success    请求成功的block
// *  @param failure    请求失败的block
// */
//+ (NSURLSessionDataTask *)postWithNoBaseUrl:(NSString *)url parameters:(id)parameters  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress *pg))progress success:(void (^)(id responseObject))success faliure:(void (^)(id error))failure;
//
///**
// *  文件下载
// *
// *  @param url       下载请求url
// *  @param ProgressBlock 下载进度block
// *  @param savePath      储存路径
// *  @param failure       下载失败block
// */
//+ (void)downloadTaskWithUrl:(NSString *)url progress:(void (^)(id downloadProgress))ProgressBlock savePath:(NSString *)savePath  completionHandler:(void (^)(NSURLResponse *response ,NSURL *filePath))completion  error:(void (^)(id error))failure;
//
//



/**
 get 网络请求
 @param url 连接地址
 @param parameters 参数
 @param success 成功回调
 @param failed 失败回调
 */
+(void)macGet:(NSString *)url parameters:(NSDictionary *)parameters success:(SuccessBlock)success andFailed:(FailedBlock)failed;



/**
 post 网络请求
 @param url 连接地址
 @param parameters 参数
 @param success 成功回调
 @param failed 失败回调
 */
+(void)macPost:(NSString *)url parameters:(NSDictionary *)parameters success:(SuccessBlock)success andFailed:(FailedBlock)failed;







@end
