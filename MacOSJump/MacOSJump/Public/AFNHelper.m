//
//  AFNHelper.m
//  Jump
//
//  Created by jumpapp1 on 2018/12/13.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "AFNHelper.h"

@implementation AFNHelper

//
//+ (AFNHelper *)sharedManager {
//
//    static AFNHelper *handle = nil;
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        handle = [AFNHelper manager];
//        handle.responseSerializer = [AFHTTPResponseSerializer serializer];
//        handle.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
//
//
//    });
//
//    return handle;
//
//}
//
//
////get请求
//+ (NSURLSessionDataTask *)get:(NSString *)url ipAddress:(NSString *)ipAddress port:(NSString *)port parameter:(id )parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure
//{
//
//    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,url];
//
//    JumpLog(@"url=====%@",urlStr);
//
//    JumpLog(@"parameters======%@",parameters);
//
//
//    NSURLSessionDataTask *dataTask = [[AFNHelper sharedManager] GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
//
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//
//        JumpLog(@"%@",responseObject);
//
//        NSData *data = responseObject;
//
//        NSString *str = [data mj_JSONString];
//
//        NSDictionary *dict = [str mj_JSONObject];
//
//        success(dict);
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        JumpLog(@"%@",error);
//
//        failure(error);
//
//    }];
//
//    return dataTask;
//}
//
////post请求
//+ (NSURLSessionDataTask *)post:(NSString *)url ipAddress:(NSString *)ipAddress port:(NSString *)port parameters:(id)parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure
//{
//    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@%@",ipAddress,port,url];
//
//    JumpLog(@"url=====%@",urlStr);
//
//    JumpLog(@"parameters======%@",parameters);
//
//
//    NSURLSessionDataTask *dataTask = [[AFNHelper sharedManager] POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//
//
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//
//        NSData *data = responseObject;
//
//        NSString *str = [data mj_JSONString];
//
//        NSDictionary *dict = [str mj_JSONObject];
//
//        JumpLog(@"%@",dict);
//
//        success(dict);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        JumpLog(@"%@",error);
//
//        failure(error);
//
//    }];
//
//    return dataTask;
//
//}
//
//
//
////文件上传
//+ (NSURLSessionDataTask *)post:(NSString *)url parameters:(id)parameters  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(id responseObject))success faliure:(void (^)(id error))failure{
//
//    NSURLSessionDataTask *dataTask = [[AFNHelper sharedManager] POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        block(formData);
//
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//
//        success(responseObject);
//
//        JumpLog(@"%@",responseObject);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        failure(error);
//        JumpLog(@"%@",error);
//
//    }];
//
//    return dataTask;
//
//}
//
////文件上传(不需要拼接基地址)
//+ (NSURLSessionDataTask *)postWithNoBaseUrl:(NSString *)url parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block progress:(void (^)(NSProgress *))progress success:(void (^)(id))success faliure:(void (^)(id))failure {
//
//    NSURLSessionDataTask *dataTask = [[AFNHelper sharedManager] POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        block(formData);
//
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//
//        if (uploadProgress) {
//
//            progress(uploadProgress);
//        }
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//
//        success(responseObject);
//
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        failure(error);
//
//    }];
//
//    return dataTask;
//
//}
//
//
////文件下载
//+ (void)downloadTaskWithUrl:(NSString *)url progress:(void (^)(id downloadProgress))ProgressBlock savePath:(NSString *)savePath  completionHandler:(void (^)(NSURLResponse *response ,NSURL *filePath))completion  error:(void (^)(id error))failure{
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//
//
//    NSURLSessionDownloadTask *download =  [[AFNHelper sharedManager]  downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//
//        if (downloadProgress) {
//            ProgressBlock(downloadProgress);
//        }
//
//
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//
//        return  [NSURL fileURLWithPath:savePath];
//
//    }completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//
//        if (!error) {
//            completion(response,filePath);
//        }
//        else {
//
//            failure(error);
//
//        }
//
//
//    }];
//    [download resume];
//
//
//}



#pragma mark ---- Mac 封装网络请求


//GET请求
+(void)macGet:(NSString *)url parameters:(NSDictionary *)parameters success:(SuccessBlock)success andFailed:(FailedBlock)failed{
    
    NSString *str = [self parameterStringByDict:parameters];
    
    url = [url stringByAppendingFormat:@"?%@",str];
    
    NSURL *urlStr = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlStr cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if(!error){
                
                NSString *str = [data mj_JSONString];
                
                NSDictionary *dict = [str mj_JSONObject];
                
                JumpLog(@"%@",dict);
                
                success(dict);
                
            }else{
                
                failed(error);
            }
            
        });
  
    }];
    
    [dataTask resume];
}


//POST请求
+(void)macPost:(NSString *)url parameters:(NSDictionary *)parameters success:(SuccessBlock)success andFailed:(FailedBlock)failed{
    
    NSURL *urlStr = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlStr cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    request.HTTPMethod = @"POST";
    
    NSString *body = [self parameterStringByDict:parameters];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            
            if(!error){
                
                NSString *str = [data mj_JSONString];
                
                NSDictionary *dict = [str mj_JSONObject];
                
                JumpLog(@"%@",dict);
                
                success(dict);
                
            }else{
                
                failed(error);
            }
            
        });

    }];
    
    [dataTask resume];
}



+(NSString *)parameterStringByDict:(NSDictionary *)dict{
    
    NSMutableString *muString = [[NSMutableString alloc]init];
    NSString *str = @"";
    
    if(dict){
        
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            [muString appendFormat:@"%@=%@&",key,obj];
        }];
        
        str = [muString substringToIndex:muString.length-1];
    }
    
    return str;
}




@end
