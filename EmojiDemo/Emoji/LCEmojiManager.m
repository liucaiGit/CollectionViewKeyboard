//
//  LCEmojiManager.m
//  EmojiDemo
//
//  Created by liucai on 2017/10/24.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import "LCEmojiManager.h"

static LCEmojiManager *manager = nil;

@interface LCEmojiManager ()

@property (nonatomic, strong) NSMutableArray *allEmojiArray;

@end

@implementation LCEmojiManager
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:nil] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[LCEmojiManager defaultEmojiPath]];
        _allEmojiArray = [NSMutableArray arrayWithArray:array];
    }
    return self;
}

+ (NSString *)defaultEmojiPath {
    return [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
}

- (NSArray *)emojiArray {
    return [[LCEmojiManager defaultManager] allEmojiArray];
}

#pragma mark - 表情处理
+ (NSString *)emojiImageWithFace_id:(NSString *)faceID {
    if (faceID.length <= 0) {
        return nil;
    }
    NSString *emojiName;
    if ([faceID isEqualToString:@"999"]) {
        //删除
        emojiName = @"[删除]";
    }else {
        for (NSDictionary *dic in [[LCEmojiManager defaultManager] emojiArray]) {
            if ([faceID isEqualToString:dic[face_id]]) {
                emojiName = dic[face_name];
                break;
            }
        }
    }
    return emojiName;
}

+ (BOOL)isEmoji:(NSString *)string {
    for (NSDictionary *dic in [[LCEmojiManager defaultManager] emojiArray]) {
        if ([string isEqualToString:dic[face_name]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string {
    return [self emojiAttributeStrWithString:string size:CGSizeMake(25, 25)];
}

+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string size:(CGSize)size {
    return [self emojiAttributeStrWithString:string rect:CGRectMake(0, 0, size.width, size.height)];
}


+ (NSMutableAttributedString *)emojiAttributeStrWithString:(NSString *)string rect:(CGRect)rect {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    //使用正则表达式筛选表情字符
    NSString *regexStr = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
    NSError *error;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
//    if (!expression) {
//        return attributeString;     //无表情输入  直接返回
//    }
    NSArray *resultArray = [expression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    //获取表情字符串与它在文字中的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSTextCheckingResult *result in resultArray) {
        NSRange range = result.range;
        NSString *emojiStr = [string substringWithRange:range];
        for (NSDictionary *dic in [[LCEmojiManager defaultManager] emojiArray]) {
            if ([emojiStr isEqualToString:dic[face_name]]) {
                //新建文件属性  存放表情
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:emojiStr];
                //调整图片位置
                attachment.bounds = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
                NSAttributedString *imageAttributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
                //把图片位置和图片字符串保留下来
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                [imageDic setObject:imageAttributeStr forKey:@"emoji"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                [imageArray addObject:imageDic];
                break;
            }
        }
    }
    //从后往前替换
    for (int i = (int)imageArray.count - 1; i >= 0; i-- ) {
        NSRange emojiRange;
        [imageArray[i][@"range"] getValue:&emojiRange];
        [attributeString replaceCharactersInRange:emojiRange withAttributedString:imageArray[i][@"emoji"]];
    }
    return attributeString;
}

@end
