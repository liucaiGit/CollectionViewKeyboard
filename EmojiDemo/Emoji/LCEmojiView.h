//
//  LCEmojiView.h
//  EmojiDemo
//
//  Created by liucai on 2017/10/24.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreen_width [UIScreen mainScreen].bounds.size.width

#define kScreen_height [UIScreen mainScreen].bounds.size.height

#define HexColor(colorString) [HexColorTool colorWithHexString:colorString]

@class EmojiColllectionCell;

@protocol emojiViewDelegate <NSObject>

- (void)emojiCollectionCellDidSelected:(NSString *)emojiName;


@end

@interface LCEmojiView : UIView

@property (nonatomic, assign) id<emojiViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *emojiCollectionV;

@property (nonatomic, copy) NSArray *emojiArray;

@end


@interface EmojiColllectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *emojiImageV;

@property (nonatomic, copy) NSString *emojiImageName;

@end
