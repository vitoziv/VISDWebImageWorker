//
//  MPIWebImageManagerDelegateObject.h
//  MTImageWorkerDemo
//
//  Created by Vito on 4/18/16.
//  Copyright © 2016 Meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>
#import <VIImageWorker.h>

@interface VIWebImageManager : NSObject <SDWebImageManagerDelegate, VIIdentifierProtocol>

- (instancetype)initWithImageWorker:(VIImageWorker *)imageWorker;
@property (nonatomic, strong, readonly) VIImageWorker *imageWorker;

@end
