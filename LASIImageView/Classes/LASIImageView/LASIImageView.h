#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "ASICacheDelegate.h"

#import "LProgressView.h"

@class LASIImageView;


typedef void(^LASIImageViewDownloadFinishedBlock)(LASIImageView *, ASIHTTPRequest *);
typedef void(^LASIImageViewDownloadFailedBlock)(LASIImageView *, ASIHTTPRequest *);


@class LProgressView, LProgressAppearance, LRequestSettings, LASIImageViewAppearance;


@interface LASIImageView : UIImageView <ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    ASIHTTPRequest *_request;
    __weak LProgressView *_progressView;
    
    LProgressAppearance *_progressAppearance;
    LRequestSettings *_requestSettings;
    LASIImageViewAppearance *_asiImageViewAppearance;
}


@property (strong, nonatomic) NSString *imageUrl;

@property (copy, nonatomic) LASIImageViewDownloadFinishedBlock finishedBlock;
@property (copy, nonatomic) LASIImageViewDownloadFailedBlock failedBlock;

@property (strong, nonatomic) LProgressAppearance *progressAppearance;
@property (strong, nonatomic) LRequestSettings *requestSettings;
@property (strong, nonatomic) LASIImageViewAppearance *asiImageViewAppearance;


+ (LProgressAppearance *)sharedProgressAppearance;
+ (LRequestSettings *)sharedRequestSettings;
+ (LASIImageViewAppearance *)sharedASIImageViewAppearance;


@end


@interface LRequestSettings : NSObject


@property (assign, nonatomic) ASICachePolicy cachePolicy;
@property (assign, nonatomic) ASICacheStoragePolicy cacheStoragePolicy;
@property (weak, nonatomic) id <ASICacheDelegate> cacheDelegate;
@property (assign, nonatomic) NSUInteger secondsToCache;
@property (assign, nonatomic) NSUInteger timeOutSeconds;


+ (LRequestSettings *)sharedRequestSettings;


@end


@interface LASIImageViewAppearance : NSObject


@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) NSString *placeholderImageName;
@property (strong, nonatomic) UIImage *downloadFailedImage;
@property (strong, nonatomic) NSString *downloadFailedImageName;


+ (LASIImageViewAppearance *)sharedASIImageViewAppearance;


@end