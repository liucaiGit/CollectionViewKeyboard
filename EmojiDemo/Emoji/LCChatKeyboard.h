//
//  LCChatKeyboard.h
//  EmojiDemo
//
//  Created by liucai on 2017/10/25.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat inputViewHeight = 44;

static CGFloat emojiViewHeight = 220;           //表情键盘高度

@class LCEmojiView;

@protocol chatKeyboardDelegate <NSObject>

- (void)textViewShouldReturn:(NSString *)text;

@end

@interface LCChatKeyboard : UIView

@property (nonatomic, strong) LCEmojiView *emojiView;       //表情视图

@property (nonatomic, strong) UITextView *textView;       //输入框

@property (nonatomic, strong) UIButton *switchBtn;       //切换键盘

@property (nonatomic, assign) id<chatKeyboardDelegate> delegate;

@end
