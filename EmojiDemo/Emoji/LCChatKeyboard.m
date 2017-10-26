//
//  LCChatKeyboard.m
//  EmojiDemo
//
//  Created by liucai on 2017/10/25.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import "LCChatKeyboard.h"
#import "LCEmojiView.h"
#import "HexColorTool.h"
#import "Masonry.h"
#import "UIView+SetRect.h"
#import "LCEmojiManager.h"

static NSString *chat_bar_face_normal = @"chat_bar_face_normal";

static NSString *textKeyboard = @"textKeyboard";

@interface LCChatKeyboard ()<UITextViewDelegate,emojiViewDelegate>

@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation LCChatKeyboard
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HexColor(@"#E6E6E6");
        
        [self addSubview:self.textView];
        [self addSubview:self.switchBtn];
        
        [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(10);
            make.right.equalTo(self.switchBtn.mas_left).offset(-10);
            make.top.offset(4);
            make.bottom.offset(-4);
        }];
        
        //监听键盘的出现/隐藏
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNitification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNitification:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)keyboardNitification:(NSNotification *)notification {
    CGRect boardRect = ((NSValue *)notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    self.keyboardHeight = boardRect.size.height;
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        //键盘弹出
        self.switchBtn.selected = NO;
        [UIView animateWithDuration:.3 animations:^{
            self.y = kScreen_height - inputViewHeight - self.keyboardHeight;
        }completion:^(BOOL finished) {
            //表情键盘消失
            self.emojiView.y = kScreen_height;
        }];
    }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.switchBtn.selected = YES;
    }
}

#pragma mark - <emojiViewDelegate>
- (void)emojiCollectionCellDidSelected:(NSString *)emojiName {
    if ([emojiName isEqualToString:@"删除"]) {
        //手动调用系统的删除
        [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    }else if ([emojiName isEqualToString:@"发送"]) {
        NSString *text = self.textView.text;
        if (!text || text.length == 0) {
            return;
        }else {
            //键盘隐藏  发送文字
            [self keyboardDimiss];
            [self delegateAction:text];
        }
    }else {
        self.textView.text = [self.textView.text stringByAppendingString:emojiName];
        [self textViewDidChange:self.textView];
        
        //将光标置在最后
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    }
}

#pragma mark - <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //禁止输入苹果自带的表情
    if ([self stringContainsEmoji:text]) {
        return NO;
    }
    if ([[[[UIApplication sharedApplication] textInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        //换行 ==>  键盘都隐藏  发送文字
        [self keyboardDimiss];
        [self delegateAction:self.textView.text];
    }else if (text.length == 0) {
        //判断删除的文字是否符合表情文字规则
        NSString *deleteText = [textView.text substringWithRange:range];
        if ([deleteText isEqualToString:@"]"]) {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            NSString *subText;
            while (YES) {
                if (location == 0) {
                    return YES;
                }
                location -- ;
                length ++ ;
                if (length == 5) {
                    return YES;//FIXME:这里还是有点问题：当[12]这样的会被删除
                }
                subText = [textView.text substringWithRange:NSMakeRange(location, length)];
                if (([subText hasPrefix:@"["] && [subText hasSuffix:@"]"])) {
                    //判断此时的subText是否为表情字符
                    if (![LCEmojiManager isEmoji:subText]) {
                        location = range.location;
                        length = range.length;
                    }
                    break;
                }
            }
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
            [textView setSelectedRange:NSMakeRange(location, 0)];
            [self textViewDidChange:self.textView];
            return NO;//FIXME:这个方法里面 删除表情 也调用了  主要仔细研究下
        } else {
            if (textView.text.length > 0) {
                textView.text = [textView.text stringByReplacingCharactersInRange:range withString:@""];
                [self textViewDidChange:self.textView];
                return NO;//注意这里是NO；
            }
            
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

}

#pragma mark - 点击响应事件
- (void)switchBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.textView resignFirstResponder];
        //弹出键盘
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.emojiView];
        [UIView animateWithDuration:0.3 animations:^{
            self.emojiView.y = kScreen_height - emojiViewHeight;
            self.y = kScreen_height - emojiViewHeight - inputViewHeight;
        }];
    }else {
        [self.textView becomeFirstResponder];
        //表情消失
        [UIView animateWithDuration:.3 animations:^{
            self.emojiView.y = kScreen_height;
            self.y = kScreen_height - inputViewHeight - self.keyboardHeight;
        }];
    }
}

#pragma mark - private method
/**
 *  判断是否为表情字符串
 */
- (BOOL)isEmoji:(NSString *)string {
    //使用正则表达式  筛选表情字符
    NSString *regex = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        return NO;
    }
    return YES;
}

/**
 *  键盘都隐藏
 */
- (void)keyboardDimiss{
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        self.emojiView.y = kScreen_height;
        self.y = kScreen_height - inputViewHeight;
    }];
}

/**
 *  代理
 */
- (void)delegateAction:(NSString *)text {
    if (text.length <= 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewShouldReturn:)]) {
        [self.delegate textViewShouldReturn:text];
        self.textView.text = @"";
    }
}

/**
 *  禁止输入自带emoji表情 由于后台数据库原因
 */
- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

#pragma mark - lazy
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius = 3.f;
        _textView.layer.masksToBounds = YES;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIButton *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_switchBtn setImage:[UIImage imageNamed:chat_bar_face_normal] forState:UIControlStateNormal];
        [_switchBtn setImage:[UIImage imageNamed:textKeyboard] forState:UIControlStateSelected];
        [_switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (LCEmojiView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[LCEmojiView alloc] initWithFrame:CGRectMake(0, kScreen_height, self.frame.size.width, emojiViewHeight)];
        _emojiView.delegate = self;
    }
    return _emojiView;
}

@end
