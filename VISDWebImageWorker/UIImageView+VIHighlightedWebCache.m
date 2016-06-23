//
//  UIImageView+VIHighlightedWebCache.m
//  VISDWebImageWorkerDemo
//
//  Created by Vito on 6/22/16.
//  Copyright © 2016 Meitu. All rights reserved.
//

#import "UIImageView+VIHighlightedWebCache.h"
#import "UIView+WebCacheOperation.h"
#import "UIImageView+VIWebCache.h"
#import "VIIdentifierProtocol.h"

#define UIImageViewHighlightedWebCacheOperationKey @"highlightedImage"

@implementation UIImageView (VIHighlightedWebCache)


- (void)vi_setHighlightedImageWithURL:(NSURL *)url {
    [self vi_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)vi_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options {
    [self vi_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)vi_setHighlightedImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)vi_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)vi_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_cancelCurrentHighlightedImageLoad];
    
    if (url) {
        __weak __typeof(self)wself = self;
        SDWebImageManager *imageManager = [[SDWebImageManager alloc] init];
        id<SDWebImageManagerDelegate> delegate = [self vi_webImageManagerDelegate];
        if (delegate) {
            imageManager.delegate = delegate;
            [imageManager setCacheKeyFilter:^(NSURL *url) {
                id<VIIdentifierProtocol> delegate = [wself vi_webImageManagerDelegate];
                NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", url.absoluteString, [delegate identifier]];
                return cacheKey;
            }];
        }
        id<SDWebImageOperation> operation = [imageManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe (^
                                     {
                                         if (!wself) return;
                                         if (image) {
                                             wself.highlightedImage = image;
                                             [wself setNeedsLayout];
                                         }
                                         if (completedBlock && finished) {
                                             completedBlock(image, error, cacheType, url);
                                         }
                                     });
        }];
        [self sd_setImageLoadOperation:operation forKey:UIImageViewHighlightedWebCacheOperationKey];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)vi_cancelCurrentHighlightedImageLoad {
    [self sd_cancelImageLoadOperationWithKey:UIImageViewHighlightedWebCacheOperationKey];
}


@end
