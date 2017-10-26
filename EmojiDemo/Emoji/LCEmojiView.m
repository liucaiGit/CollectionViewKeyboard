//
//  LCEmojiView.m
//  EmojiDemo
//
//  Created by liucai on 2017/10/24.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import "LCEmojiView.h"
#import "LCEmojiManager.h"
#import "PagingCollectionViewLayout.h"
#import "HexColorTool.h"
#import "Masonry.h"

static CGFloat minimumLineSpacing = 20.f;

static CGFloat minimumInteritemSpacing = 20.f;

static NSString *const pageControlNormalColor = @"#CCCCCC";

static NSString *const pageControlSelectColor = @"#666666";

static NSString *collectionCellReuseIdentifier = @"EmojiColllectionCell";

@interface LCEmojiView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger numOfPerRow;        //每行表情个数

@property (nonatomic, assign) NSInteger numOfRows;       //每页行数

@property (nonatomic, assign) NSInteger numOfPages;       //总共页数

@property (nonatomic, assign) NSInteger numOfPerPage;    //每页表情数量

@property (nonatomic, strong) NSMutableArray *allEmojis;



@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIView *segmentView;

@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UIButton *emojiBtn;

@end

@implementation LCEmojiView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //表情数据
        self.allEmojis = [[[LCEmojiManager defaultManager] emojiArray] mutableCopy];
        
        [self addSubview:self.emojiCollectionV];
        [self addSubview:self.pageControl];
        [self addSubview:self.sendBtn];
        [self addSubview:self.emojiBtn];
        [self addSubview:self.segmentView];
        
        [self layoutViews];
    }
    return self;
}

- (void)layoutViews {
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emojiCollectionV.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kScreen_width * 0.4, 20));
    }];
    
    [self.emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.offset(0);
        make.size.mas_equalTo(CGSizeMake(70, 40));
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.offset(0);
        make.size.mas_equalTo(CGSizeMake(70, 40));
    }];
    
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(1);
        make.bottom.equalTo(self.sendBtn.mas_top);
    }];
}

#pragma mark - <UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allEmojis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojiColllectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellReuseIdentifier forIndexPath:indexPath];
    NSDictionary *dic = self.allEmojis[indexPath.item];
    
    cell.emojiImageName = [LCEmojiManager emojiImageWithFace_id:dic[face_id]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.allEmojis[indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionCellDidSelected:)]) {
        [self.delegate emojiCollectionCellDidSelected:dic[face_name]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.pageControl.currentPage = offsetX / kScreen_width;
}

#pragma mark - 点击响应事件
- (void)sendBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionCellDidSelected:)]) {
        [self.delegate emojiCollectionCellDidSelected:@"发送"];
    }
}

#pragma mark - setter & getter
- (void)setAllEmojis:(NSMutableArray *)allEmojis {
    if (_allEmojis != allEmojis) {
        _allEmojis = allEmojis;
        
        float itemsPerPage = self.numOfPerRow * self.numOfRows - 1;
        self.numOfPages = ceilf(_allEmojis.count / itemsPerPage);
        
        //每页最后一个是 删除
        for (int i = 0; i < self.numOfPages; i++) {
            if (self.numOfPages - 1 == i) {
                [_allEmojis addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
            }else {
                [_allEmojis insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * itemsPerPage + i];
            }
        }
        [self.emojiCollectionV reloadData];
    }
}

- (NSInteger)numOfPerRow {
    if ([UIScreen mainScreen].bounds.size.width <= 320.f) {
        return 7;
    }else {
        return 8;
    }
}

- (NSInteger)numOfRows {
    return 3;
}

- (NSInteger)numOfPerPage {
    return self.numOfPerRow * self.numOfRows;
}

#pragma mark - lazy
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = HexColor(pageControlNormalColor);
        _pageControl.currentPageIndicatorTintColor = HexColor(pageControlSelectColor);
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = self.numOfPages;
    }
    return _pageControl;
}

- (UIView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[UIView alloc] init];
        _segmentView.backgroundColor = HexColor(@"#CCCCCC");
    }
    return _segmentView;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.backgroundColor = HexColor(@"#0064E6");
        _sendBtn.titleLabel.textColor = [UIColor whiteColor];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiBtn setImage:[UIImage imageNamed:@"chat_bar_emoji_normal"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateHighlighted];
    }
    return _emojiBtn;
}

- (UICollectionView *)emojiCollectionV {
    if (!_emojiCollectionV) {
        PagingCollectionViewLayout *pageLayout = [[PagingCollectionViewLayout alloc] init];
        pageLayout.minimumInteritemSpacing = minimumInteritemSpacing;
        pageLayout.minimumLineSpacing = minimumLineSpacing;
        pageLayout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
        CGFloat itemWidth = (kScreen_width - 40 - (self.numOfPerRow - 1) * minimumInteritemSpacing) / self.numOfPerRow;
        pageLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
        _emojiCollectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, (self.numOfRows - 1) * minimumLineSpacing + itemWidth * self.numOfRows + 20) collectionViewLayout:pageLayout];
        _emojiCollectionV.backgroundColor = [UIColor clearColor];
        _emojiCollectionV.pagingEnabled = YES;
        _emojiCollectionV.showsHorizontalScrollIndicator = NO;
        _emojiCollectionV.delegate = self;
        _emojiCollectionV.dataSource = self;
        [_emojiCollectionV registerClass:[EmojiColllectionCell class] forCellWithReuseIdentifier:collectionCellReuseIdentifier];
    }
    return _emojiCollectionV;
}

@end

@implementation EmojiColllectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.emojiImageV];
    }
    return self;
}

- (void)setEmojiImageName:(NSString *)emojiImageName {
    if (_emojiImageName != emojiImageName) {
        _emojiImageName = emojiImageName;
        
        self.emojiImageV.image = [UIImage imageNamed:_emojiImageName];
    }
}

- (UIImageView *)emojiImageV {
    if (!_emojiImageV) {
        _emojiImageV = [[UIImageView alloc] initWithFrame:self.bounds];
        _emojiImageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emojiImageV;
}
@end
