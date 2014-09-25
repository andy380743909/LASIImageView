#import "LASIImageView.h"
#import <objc/runtime.h>


@implementation LASIImageView


#pragma mark - init & dealloc


- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (void)initialize
{

}


- (void)dealloc
{
    [self freeAll];
}


#pragma mark - layoutSubviews


- (void)layoutSubviews
{
    _progressView.frame = CGRectMake(floorf(self.frame.size.width/2 - _progressView.frame.size.width/2), floorf(self.frame.size.height/2 - _progressView.frame.size.height/2), _progressView.frame.size.width, _progressView.frame.size.height);
}


#pragma mark - Progress view


- (void)loadProgressView
{
    [self freeProgressView];
    
    LProgressView *progressView = [[LProgressView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    
    if (_progressAppearance)
        progressView.progressAppearance = _progressAppearance;
    
    _progressView = progressView;
    
    [self addSubview:_progressView];
}


#pragma mark - downloadImage


- (void)downloadImage
{
    [self freeAll];
    
    NSURL *imageURL = [NSURL URLWithString:_imageUrl];
    
    if (!imageURL)
    {
        [self requestFailed:nil];
        return;
    }
    
    _request = [ASIHTTPRequest requestWithURL:imageURL usingCache:self.requestSettings.cacheDelegate andCachePolicy:self.requestSettings.cachePolicy];
    _request.cacheStoragePolicy = self.requestSettings.cacheStoragePolicy;
    _request.secondsToCache = self.requestSettings.secondsToCache;
    _request.timeOutSeconds = self.requestSettings.timeOutSeconds;
    _request.downloadProgressDelegate = self;

    __weak typeof(self) weakSelf = self;
    __weak ASIHTTPRequest *weakReq = _request;
    
    [_request setCompletionBlock:^{
        [weakSelf requestFinished:weakReq];
    }];
    
    [_request setFailedBlock:^{
        [weakSelf requestFailed:weakReq];
    }];
    
    if ([[ASIDownloadCache sharedCache] isCachedDataCurrentForRequest:_request])
    {
        [self loadCachedImage];
    }
    else
    {
        [self loadProgressView];
        [_request startAsynchronous];
    }
}


- (void)loadCachedImage
{
    NSString *filePath = [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:_request];
    
	if (filePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:filePath];
        
        if (cachedImage)
            super.image = cachedImage;
    }
}


- (void)loadPlaceholderImage
{
    if (!self.image)
    {
        if (self.asiImageViewAppearance.placeholderImage)
            self.image = self.asiImageViewAppearance.placeholderImage;
        else if (self.asiImageViewAppearance.placeholderImageName)
            self.image = [UIImage imageNamed:self.asiImageViewAppearance.placeholderImageName];
    }
}


- (void)loadDownloadFailedImage
{
    [self loadCachedImage];
    
    if (!self.image)
    {
        if (self.asiImageViewAppearance.downloadFailedImage)
            self.image = self.asiImageViewAppearance.downloadFailedImage;
        else if (self.asiImageViewAppearance.downloadFailedImageName)
            self.image = [UIImage imageNamed:self.asiImageViewAppearance.downloadFailedImageName];
    }
}


- (void)cancelImageDownload
{
    [self freeAll];
}


#pragma mark - ASIHTTPRequestDelegate


- (void)requestFinished:(ASIHTTPRequest *)request
{
    UIImage *downloadedImage = [UIImage imageWithData:request.responseData];
    
    if (downloadedImage)
    {
        self.image = downloadedImage;
        [self freeAll];
        
        if (_finishedBlock)
            _finishedBlock(self, request);
    }
    else
    {
        [self requestFailed:nil];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self loadDownloadFailedImage];
    [self freeAll];
    
    if (_failedBlock)
        _failedBlock(self, request);
}


#pragma mark - ASIProgressDelegate


- (void)setProgress:(float)newProgress
{
    _progressView.progress = newProgress;
}


#pragma mark - Free


- (void)freeRequest
{
    if (_request)
    {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
}


- (void)freeProgressView
{
    if (_progressView)
    {
        if (_progressView.superview)
            [_progressView removeFromSuperview];
     
        _progressView = nil;
    }
}


- (void)freeAll
{
    [self freeRequest];
    [self freeProgressView];
}


#pragma mark - Setters


- (void)setImage:(UIImage *)image
{
    [self cancelImageDownload];
    
    [super setImage:image];
}


- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;

    self.image = nil;
    
    [self downloadImage];
}


- (void)setProgressAppearance:(LProgressAppearance *)progressAppearance
{
    _progressAppearance = progressAppearance;
    
    if (_progressView)
        _progressView.progressAppearance = _progressAppearance;
}


#pragma mark - Getters


- (LProgressAppearance *)progressAppearance
{
    @synchronized(self)
    {
        if (_progressAppearance)
            return _progressAppearance;
        
        return [LProgressAppearance sharedProgressAppearance];
    }
}


- (LRequestSettings *)requestSettings
{
    @synchronized(self)
    {
        if (_requestSettings)
            return _requestSettings;
        
        return [LRequestSettings sharedRequestSettings];
    }
}


- (LASIImageViewAppearance *)asiImageViewAppearance
{
    @synchronized(self)
    {
        if (_asiImageViewAppearance)
            return _asiImageViewAppearance;
        
        return [LASIImageViewAppearance sharedASIImageViewAppearance];
    }
}


+ (LProgressAppearance *)sharedProgressAppearance
{
    return [LProgressAppearance sharedProgressAppearance];
}


+ (LRequestSettings *)sharedRequestSettings
{
    return [LRequestSettings sharedRequestSettings];
}


+ (LASIImageViewAppearance *)sharedASIImageViewAppearance
{
    return [LASIImageViewAppearance sharedASIImageViewAppearance];
}


#pragma mark -


@end


#pragma mark - LRoundProgressView


@implementation LRequestSettings


#pragma mark - LRequestSettings


static LRequestSettings *sharedRequestSettingsInstance = nil;


+ (LRequestSettings *)sharedRequestSettings
{
    @synchronized(self)
    {
        if (sharedRequestSettingsInstance)
            return sharedRequestSettingsInstance;
        
        return sharedRequestSettingsInstance = [LRequestSettings new];
    }
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _secondsToCache = 900;
        _timeOutSeconds = 8;
        _cacheDelegate = [ASIDownloadCache sharedCache];
        _cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        _cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
    }
    return self;
}


@end


@implementation LASIImageViewAppearance


#pragma mark - LASIImageViewAppearance


static LASIImageViewAppearance *sharedImageViewAppearanceInstance = nil;


+ (LASIImageViewAppearance *)sharedASIImageViewAppearance
{
    @synchronized(self)
    {
        if (sharedImageViewAppearanceInstance)
            return sharedImageViewAppearanceInstance;
        
        return sharedImageViewAppearanceInstance = [LASIImageViewAppearance new];
    }
}


@end