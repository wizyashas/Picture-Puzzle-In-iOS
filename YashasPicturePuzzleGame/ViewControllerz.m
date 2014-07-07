//
//  ViewControllerz.m
//  yashasPicturePuzzle
//
//  Created by yashask on 7/2/14.
//  Copyright (c) 2014 spaneos. All rights reserved.
//

#import "ViewControllerz.h"

@implementation ViewControllerz

@synthesize  imageArray , timerLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    emptyTag = square*square;
    [self loadMyView];
    
    UIImageView *newView = (UIImageView *)[self.view viewWithTag:emptyTag];
    newView.image = nil;
    
    [self randomMoveGenerator];
    [self startCounter];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//image size convertor
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}




- (void)loadMyView {
    //initialize image Array
    imageArray = [[NSMutableArray alloc]init];
    
    UIView* root = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
//    NSURL *url = [NSURL URLWithString:@"http://i4.mirror.co.uk/incoming/article199563.ece/alternates/s1023/emma-watson-for-people-tree-image-2-274150077.jpg"];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    UIImage *i = [[UIImage alloc] initWithData:data];
    
    UIImage *i = [UIImage imageNamed:@"FLW.jpg"];
    UIImage* whole = [self imageWithImage:i convertToSize:CGSizeMake(300, 300)] ; //I know this image is 300x300
    
    int partId = 1;
    for (int x=0; x<300; x+=300/square) {
        for(int y=0; y<300; y+=300/square) {
            CGImageRef cgImg = CGImageCreateWithImageInRect(whole.CGImage, CGRectMake(x, y, 300/square, 300/square));
            UIImage* part = [UIImage imageWithCGImage:cgImg];
            
            //adding to image array to test for win afterwards
            [imageArray addObject:part];
            
            UIImageView* iv = [[UIImageView alloc] initWithImage:part];
            [iv setFrame:CGRectMake(x+10, y+10, 300/square, 300/square)];
            [iv.layer setBorderColor: [[UIColor blackColor] CGColor]];
            [iv.layer setBorderWidth: 1.0];
            
            iv.userInteractionEnabled = YES;
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tap:)];
            tap.numberOfTapsRequired = 1;
            [iv addGestureRecognizer:tap];
            
            iv.tag = partId;

            [root addSubview:iv];
            partId++;
            CGImageRelease(cgImg);
            
        }
    }
    
    UIButton *restartButton = [[UIButton alloc]initWithFrame:CGRectMake(125, 400, 50, 50)];
    [restartButton setBackgroundImage:[UIImage imageNamed:@"restart-button.png"] forState:UIControlStateNormal];
    [restartButton addTarget:self action:@selector(myrestartButtonAction:)  forControlEvents:UIControlEventTouchUpInside];
    
    //adding timer
    UILabel *localTimerLabel = [[UILabel alloc]initWithFrame:CGRectMake(125, 350, 50, 50)];
    localTimerLabel.layer.borderColor = [UIColor greenColor].CGColor;
    localTimerLabel.layer.borderWidth = 1.0;
    [localTimerLabel setText:@"0"];
    [localTimerLabel setTextAlignment:NSTextAlignmentCenter];
    [localTimerLabel setFont:[UIFont systemFontOfSize:24.0f]];
    timerLabel = localTimerLabel;
    
    [root addSubview:restartButton];
    [root addSubview:timerLabel];
    
     
    
    self.view = root;
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    NSLog(@"tag no is %i",gesture.view.tag);
    
    if(gesture.view.tag == emptyTag){
        return;
    }
    
    if([self fourNearestCornerChecker:gesture.view.tag]){
        [self swapImageWithTag:gesture.view.tag];
    } 

    if([self checkVictory]){
        [self stopCounter];
        if([self checkForTheFastest]){
            [[[UIAlertView alloc]initWithTitle:@"--Victory--" message:[NSString stringWithFormat:@"You win \n You have solved it in the fastest time, \n Your time is %d secs",[timerLabel.text intValue]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            fastestTime = [timerLabel.text intValue];
        }else{
             [[[UIAlertView alloc]initWithTitle:@"--Victory--" message:[NSString stringWithFormat:@"You win \n But you are not the fastest, \n The fastest time is %d secs \n and your time is %d secs" ,fastestTime , [timerLabel.text intValue]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
        [self resetButton];
    }
    
}


-(void) swapImageWithTag:(NSInteger)tag{
    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:tag];//image to move in the place of empty space
    UIImageView *newView = (UIImageView *)[self.view viewWithTag:emptyTag];//empty space to move in the place of image
    
    CGRect imageOldSpace = [imgView frame];
    CGRect imageNewSpcae = [newView frame];
    
    
    [imgView setFrame:imageNewSpcae];
    imgView.tag = emptyTag;
    [newView setFrame:imageOldSpace];
    newView.tag = tag;
    
    emptyTag = tag;
    
}

//dynamic checking for valid move for all 4 corners checkers
-(BOOL)fourNearestCornerChecker:(NSInteger)tag{
    BOOL result = NO;
    NSInteger left = emptyTag - square;
    NSInteger right = emptyTag + square;
    NSInteger top = emptyTag - 1;
    NSInteger bottom = emptyTag + 1;
    
    
    
    if(!([self.view viewWithTag:top] == nil)){
        if(!(top%square == 0)){
        if(tag == top) result = YES;
        }
    }
    
    if(!([self.view viewWithTag:bottom] == nil)){
        if(!((bottom-1)%square == 0)){
        if(tag == bottom) result = YES;
        }
    }
    
    
    if(!([self.view viewWithTag:left] == nil)){
        if(tag == left) result = YES;
    }
    
    if(!([self.view viewWithTag:right] == nil)){
         if(tag == right) result = YES;
    }
    
    return  result;
}


-(BOOL)checkVictory
    {
    BOOL result = YES;
    int count = (square*square)-1;
    for(int i =1; i<=count ; i++){
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:i];
       
        if(!(imageView.image == [imageArray objectAtIndex:(i-1)])){
             NSLog(@"images in array %@",[imageArray objectAtIndex:(i-1)] );
            result = NO;
            break;
        }
    }
    
    return result;
}

//animation
-(void)flipUpSideDownEffectAnimation:(UIImageView*)webView
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setDuration:2.0f];
    [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
    [animation setType:@"oglFlip" ];
    [webView.layer addAnimation:animation forKey:NULL];
    
}


-(NSInteger)randomNumberGeneratorz{
    
    NSInteger randomNumber = arc4random()%(square*square);
    if (randomNumber == 0) {
        randomNumber = [self randomNumberGeneratorz];
    }
    
    return randomNumber;
}


-(void)randomMoveGenerator{
    int numberOfMoves = 500;
    
    for(int i = 0 ; i <= numberOfMoves ; i++){
        
        int randomNumberGenerated =[self randomNumberGeneratorz];
        
        if(randomNumberGenerated == emptyTag){
            return;
        }
        
        if([self fourNearestCornerChecker:randomNumberGenerated]){
            [self swapImageWithTag:randomNumberGenerated];
        }else{  i--;
        }
    }
    
}


//restart button
-(IBAction)myrestartButtonAction:(id)sender{
    [self viewDidLoad];
}


//count up timer code

- (void)startCounter  {
    if(timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
    }
    
}

- (void)stopCounter  {
    
    [timer invalidate];
    timer = nil;
}

- (void)resetButton  {
    timerLabel.text = @"0";
}

-(void)aTime
{
    int currentTime = [timerLabel.text intValue];
    int newTime = currentTime + 1;
    
    timerLabel.text = [NSString stringWithFormat:@"%d",newTime];
}

//code to check the fastest time of completing puzzle

-(BOOL)checkForTheFastest{
    int currentTimeScored = [timerLabel.text intValue];
    
    if(fastestTime < currentTimeScored){
        return NO;
    }
    
    return YES;
}


@end
