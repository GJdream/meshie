//
//  BTXCommon.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/24/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BTXCommon : NSObject

+(UIColor*) primaryThemeColor;

@end
