//
//  HexColorTool.h
//  EmojiDemo
//
//  Created by liucai on 2017/10/25.
//  Copyright © 2017年 liucai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HexColorTool : NSObject

/**
 *  十六进制代码 ---> RGB
 */
+(UIColor *)colorWithHexString:(NSString *)color;

@end
