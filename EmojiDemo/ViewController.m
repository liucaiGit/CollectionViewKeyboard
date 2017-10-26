//
//  ViewController.m
//  EmojiDemo
//
//  Created by liucai on 2017/10/24.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import "ViewController.h"
#import "LCEmojiView.h"
#import "LCEmojiManager.h"
#import "PagingCollectionViewLayout.h"
#import "LCChatKeyboard.h"

#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height

@interface CustomCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) NSString *title;

@end

@implementation CustomCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor greenColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        self.titleLabel.frame = self.bounds;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = title;
        
        self.titleLabel.text = _title;
    }
}

@end


@interface ViewController ()<chatKeyboardDelegate>

@property (nonatomic, strong) LCEmojiView *emojiView;

@property (nonatomic, strong) LCChatKeyboard *keyboardView;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializationUI];
    [self initializationTextLabel];
    
}

- (void) initializationTextLabel {
    self.textLabel = [UILabel new];
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.backgroundColor = [UIColor greenColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.frame = CGRectMake(0, 0, kScreen_width, 40);
    self.textLabel.center = self.view.center;
    [self.view addSubview:self.textLabel];
}

- (void)initializationUI {
    self.keyboardView = [[LCChatKeyboard alloc] initWithFrame:CGRectMake(0, kScreen_height - 44, kScreen_width, 44)];
    self.keyboardView.delegate = self;
    [self.view addSubview:self.keyboardView];
}

- (void)textViewShouldReturn:(NSString *)text {
    self.textLabel.attributedText = [LCEmojiManager emojiAttributeStrWithString:text];
}

@end
