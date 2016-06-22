//
//  ViewController.m
//  SoundsMixDemo
//
//  Created by WeiCheng—iOS_1 on 16/6/21.
//  Copyright © 2016年 com.weicheng. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self composition:@"d1.mp3" and:@"d2.mp3" to:@"someMusic"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)composition:(NSString *)music1 and:(NSString *)music2 to:(NSString *)fileName {
    NSURL *url1 = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:music1 ofType:nil]];
    NSURL *url2 = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:music2 ofType:nil]];
    AVURLAsset *urlAsset1 = [AVURLAsset URLAssetWithURL:url1 options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    AVURLAsset *urlAsset2 = [AVURLAsset URLAssetWithURL:url2 options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    
    [urlAsset1 loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        [urlAsset2 loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            AVMutableComposition *comp = [[AVMutableComposition alloc] init];
            AVMutableCompositionTrack *track1 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [track1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, urlAsset1.duration) ofTrack:urlAsset1.tracks.lastObject atTime:kCMTimeZero error:NULL];
            AVMutableCompositionTrack *track2 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [track2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, urlAsset2.duration) ofTrack:urlAsset2.tracks.lastObject atTime:kCMTimeZero error:NULL];
            [comp loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
                AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:comp presetName:AVAssetExportPresetAppleM4A];
                NSLog(@"%@",[exporter supportedFileTypes]);
                exporter.outputFileType = @"com.apple.m4a-audio";
                NSString *exportFile = [NSHomeDirectory() stringByAppendingFormat: @"/%@.m4a", fileName];
                NSLog(@"%@",exportFile);
                // set up export
                if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
                    [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
                }
                NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
                exporter.outputURL = exportURL;
                [exporter exportAsynchronouslyWithCompletionHandler:^{
                    int exportStatus = exporter.status;
                    switch (exportStatus) {
                        case AVAssetExportSessionStatusFailed:{
                            NSError *exportError = exporter.error;
                            NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                            break;
                        }
                            
                        case AVAssetExportSessionStatusCompleted: NSLog (@"AVAssetExportSessionStatusCompleted"); break;
                        case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
                        case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
                        case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
                        case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
                        default:  NSLog (@"didn't get export status"); break;
                    }
                }];
            }];
        }];
    }];
}



@end
