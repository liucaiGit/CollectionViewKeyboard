//
//  LCEmojiManager.h
//  EmojiDemo
//
//  Created by liucai on 2017/10/24.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *face_id = @"face_id";

static NSString *face_image_name = @"face_image_name";

static NSString *face_name = @"face_name";

static NSString *face_rank = @"face_rank";

@interface LCEmojiManager : NSObject

/**
 *  单例实现
 */
+ (instancetype)defaultManager;

/**
 *  获取所有的表情
 */
- (NSArray *)emojiArray;

/**
 *  判断是否表情字符串
 */
+ (BOOL)isEmoji:(NSString *)string;

/**
 *  通过faceID获取对应的表情名
 * @param faceID  表情id
 * @return 表情名称
 */
+ (NSString *)emojiImageWithFace_id:(NSString *)faceID;

/**
 *  将文字中含有表情的文字处理成表情图片显示
 *  @param string 待处理的文字
 *  @return  处理后的文字
 */
+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string;

+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string size:(CGSize)size;

+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string rect:(CGRect)rect;

@end
