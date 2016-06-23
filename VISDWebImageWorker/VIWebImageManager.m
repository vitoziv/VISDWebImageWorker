//
//  MPIWebImageManagerDelegateObject.m
//  MTImageWorkerDemo
//
//  Created by Vito on 4/18/16.
//  Copyright © 2016 Meitu. All rights reserved.
//

#import "VIWebImageManager.h"

@interface VIWebImageManager ()

@property (nonatomic, strong) VIImageWorker *imageWorker;

@end

@implementation VIWebImageManager

- (instancetype)initWithImageWorker:(VIImageWorker *)imageWorker {
    self = [super init];
    if (self) {
        _imageWorker = imageWorker;
    }
    return self;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    return [self.imageWorker appleyEffectsToImage:image];
}

#pragma mark - VIIdentifierProtocol

- (NSString *)identifier {
    return [self.imageWorker identifier];
}

@end

