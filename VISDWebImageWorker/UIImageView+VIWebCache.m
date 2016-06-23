//
//  UIImageView+MPIWebCache.m
//  MTImageWorkerDemo
//
//  Created by Vito on 4/18/16.
//  Copyright © 2016 Meitu. All rights reserved.
//

#import "UIImageView+VIWebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import <VIIdentifierProtocol.h>

static char imageURLKey;
static char kWebImageManagerDelegateKey;

@implementation UIImageView (VIWebCache)

- (void)vi_setImageWithURL:(NSURL *)url {
    [self vi_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)vi_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self vi_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)vi_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self vi_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)vi_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)vi_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)vi_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)vi_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self vi_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
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
        id <SDWebImageOperation> operation = [imageManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)vi_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self vi_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];
}

- (NSURL *)vi_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)vi_setWebImageManagerDelegate:(id<SDWebImageManagerDelegate, VIIdentifierProtocol>)delegate {
    objc_setAssociatedObject(self, &kWebImageManagerDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SDWebImageManagerDelegate, VIIdentifierProtocol>)vi_webImageManagerDelegate {
    return objc_getAssociatedObject(self, &kWebImageManagerDelegateKey);
}

- (void)vi_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self vi_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self)wself = self;
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    
    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];
                    
                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }
    
    [self sd_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)vi_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)vi_cancelCurrentAnimationImagesLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

@end
