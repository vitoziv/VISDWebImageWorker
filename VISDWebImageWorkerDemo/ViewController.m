//
//  ViewController.m
//  VISDWebImageWorkerDemo
//
//  Created by Vito on 6/23/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "ViewController.h"
#import "VISDWebImageWorker.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation ViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.imageView vi_cancelCurrentImageLoad];
    [self.indicatorView startAnimating];
    
    NSArray *effects;
    switch (indexPath.row) {
        case 0: {
            VIImageEffect *roundEffect = [VIImageEffect roundEffect];
            effects = @[roundEffect];
        }
            break;
        case 1: {
            VIImageEffect *blurEffect = [VIImageEffect blurEffectWithType:VIBlurImageEffectTypeDarkEffect];
            effects = @[blurEffect];
        }
            break;
        case 2: {
            VIImageEffect *cornerEffect = [VIImageEffect cornerEffectWithRadius:30];
            effects = @[cornerEffect];
        }
            break;
        case 3: {
            VIImageEffect *resizeEffect = [VIImageEffect resizeEffectWithUISize:CGSizeMake(120, 120) contentMode:self.imageView.contentMode];
            effects = @[resizeEffect];
        }
            
        default:
            break;
    }
    
    
    VIImageWorker *imageWorker = [[VIImageWorker alloc] initWithEffects:effects];
    VIWebImageManager *imageManager = [[VIWebImageManager alloc] initWithImageWorker:imageWorker];
    [self.imageView vi_setWebImageManagerDelegate:imageManager];
    
    NSURL *imageURL = [NSURL URLWithString:@"https://dvif77labeimb.cloudfront.net/640x400_ec9a079daed3a72452d50d905fdc788e201510111911102.jpeg"];
    __weak typeof(self)weakSelf = self;
    [self.imageView vi_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf.indicatorView stopAnimating];
        if (error) {
            NSLog(@"load image error %@", error);
            return;
        }
        if (cacheType != SDImageCacheTypeNone) {
            NSLog(@"来自缓存");
        } else {
            NSLog(@"来自网络");
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
