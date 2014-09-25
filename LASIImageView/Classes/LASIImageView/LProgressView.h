//
//  LProgressView.h
//  LASIImageView
//
//  Created by CuiPanJun on 14-9-24.
//  Copyright (c) 2014年 Luka Gabric. All rights reserved.
//
//  https://github.com/andy380743909/LASIImageView


#import <UIKit/UIKit.h>

typedef enum tagLProgressType
{
    LProgressTypeAnnular,
    LProgressTypeCircle = 1,
    LProgressTypePie = 2
}
LProgressType;

@class LProgressAppearance;

@interface LProgressView : UIView


@property (assign, nonatomic) float progress;
@property (strong, nonatomic) LProgressAppearance *progressAppearance;


@end


@interface LProgressAppearance : NSObject


@property (assign, nonatomic) LProgressType type;
//percentage supported for LProgressTypeAnnular and LProgressTypeCircle
@property (assign, nonatomic) BOOL showPercentage;

//setting schemeColor will set progressTintColor, backgroundTintColor and percentageTextColor
@property (strong, nonatomic) UIColor *schemeColor;
@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *backgroundTintColor;
@property (strong, nonatomic) UIColor *percentageTextColor;

@property (strong, nonatomic) UIFont *percentageTextFont;
@property (assign, nonatomic) CGPoint percentageTextOffset;


+ (LProgressAppearance *)sharedProgressAppearance;


@end
