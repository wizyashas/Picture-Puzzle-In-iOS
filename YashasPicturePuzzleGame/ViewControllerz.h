//
//  ViewControllerz.h
//  yashasPicturePuzzle
//
//  Created by yashask on 7/2/14.
//  Copyright (c) 2014 spaneos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerz : UIViewController
{
    NSTimer *timer;
}

@property NSMutableArray *imageArray;
@property UILabel *timerLabel;
@end

static NSInteger emptyTag;
static NSInteger fastestTime = 40;
static NSInteger square = 5;