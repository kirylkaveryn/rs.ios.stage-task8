//
//  RSColorViewController.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 16.07.21.
//

#import "ColorViewController.h"

@interface ColorViewController ()

@property (weak, nonatomic) IBOutlet RSButton *paletteSaveButton;
@property (strong, nonatomic) RSColorPickButton *colorPickButtonDefault;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton1;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton2;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton3;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton4;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton5;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton6;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton7;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton8;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton9;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton10;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton11;
@property (weak, nonatomic) IBOutlet RSColorPickButton *colorPickButton12;
@property (assign, nonatomic) NSInteger colorCounter;
@property (strong, nonatomic, readwrite) NSMutableArray <RSColorPickButton *> *colorSet;
@property (weak, nonatomic) NSTimer *timer;

@end

@implementation ColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureView];
    [self configureButtons];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

// configure VC for half-frame view
-(void)configureView {
    self.view.frame = CGRectMake(0.0, self.view.frame.size.height - 333.5, self.view.frame.size.width, 333.5 + 40);
    self.view.layer.cornerRadius = 40.0;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor rsColorBlack].CGColor;
    self.view.layer.shadowRadius = 4.0;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.view.layer.shadowOpacity = 0.25;
    self.view.backgroundColor = [UIColor rsColorWhite];

}

// configure all buttons and add targets
-(void)configureButtons {
    self.colorCounter = 0;
    
    // set colors to pick buttons
    self.colorPickButton1.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.89 green: 0.10 blue: 0.17 alpha: 1.00].CGColor;
    self.colorPickButton2.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.24 green: 0.09 blue: 0.80 alpha: 1.00].CGColor;
    self.colorPickButton3.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.00 green: 0.49 blue: 0.22 alpha: 1.00].CGColor;
    self.colorPickButton4.colorPickLayer.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor;
    self.colorPickButton5.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.62 green: 0.37 blue: 0.92 alpha: 1.00].CGColor;
    self.colorPickButton6.colorPickLayer.backgroundColor = [UIColor colorWithRed: 1.00 green: 0.48 blue: 0.41 alpha: 1.00].CGColor;
    self.colorPickButton7.colorPickLayer.backgroundColor = [UIColor colorWithRed: 1.00 green: 0.68 blue: 0.33 alpha: 1.00].CGColor;
    self.colorPickButton8.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.00 green: 0.68 blue: 0.93 alpha: 1.00].CGColor;
    self.colorPickButton9.colorPickLayer.backgroundColor = [UIColor colorWithRed: 1.00 green: 0.47 blue: 0.64 alpha: 1.00].CGColor;
    self.colorPickButton10.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.00 green: 0.18 blue: 0.24 alpha: 1.00].CGColor;
    self.colorPickButton11.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.05 green: 0.22 blue: 0.09 alpha: 1.00].CGColor;
    self.colorPickButton12.colorPickLayer.backgroundColor = [UIColor colorWithRed: 0.38 green: 0.06 blue: 0.06 alpha: 1.00].CGColor;
    
    NSArray *colorButtonsArray = [[NSArray alloc] initWithObjects:self.colorPickButton1, self.colorPickButton2,self.colorPickButton3, self.colorPickButton4, self.colorPickButton5, self.colorPickButton6, self.colorPickButton7, self.colorPickButton8, self.colorPickButton9, self.colorPickButton10, self.colorPickButton11, self.colorPickButton12, nil];
    
    
    // add targets to all buttons
    [self.paletteSaveButton addTarget:self action:@selector(paletteSaveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.paletteSaveButton addTarget:self.parentViewController action:@selector(paletteSaveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    for (int i = 0; i < colorButtonsArray.count; i++) {
        [colorButtonsArray[i] addTarget:self action:@selector(colorPickButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
 
    self.colorPickButtonDefault = [RSColorPickButton new];
//    [self.colorPickButtonDefault configureButton];
    self.colorSet = [[NSMutableArray alloc] init];
    [self.colorSet addObject:self.colorPickButtonDefault];
    [self.colorSet addObject:self.colorPickButtonDefault];
    [self.colorSet addObject:self.colorPickButtonDefault];

}

// hide color palette VC
- (void)paletteSaveButtonTapped: (RSButton *)sender {
    [self.view removeFromSuperview];
}

// set action to color pick button and add timer
-(void)colorPickButtonTapped: (RSColorPickButton *)button {
    if (button.colorPickButtonState == stateUnpick) {
        [self stopTimerForBackgroudColor];
        self.view.layer.backgroundColor = button.colorPickLayer.backgroundColor;
        [self addButtonToColorSet:button];
        [self startTimerForBackgroudColor];
    }
    else {
        [self changeCurrentButtonToDefault:button];
    }
}

// method for starting timer
-(void)startTimerForBackgroudColor {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            self.view.layer.backgroundColor = [UIColor rsColorWhite].CGColor;
        }];
    }
}

// method for canceling timer if previous in action
-(void)stopTimerForBackgroudColor {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

// create set of colors for palette
-(void)addButtonToColorSet:(RSColorPickButton*)button {
    // if array contains dufult color button, remove it one by one and replace by colored
    if ([self.colorSet containsObject:self.colorPickButtonDefault]) {
        [self.colorSet removeObjectAtIndex:[self.colorSet indexOfObject:self.colorPickButtonDefault]];
        [self.colorSet addObject:button];
        [button buttonPressDown:button];
    }
    // if array contains only colored buttons, remove first and add last - push/pop
    else {
        [self.colorSet.firstObject buttonPressDown:self.colorSet.firstObject];
        [self.colorSet removeObjectAtIndex:0];
        [button buttonPressDown:button];
        [self.colorSet addObject:button];
    }
}

// unpick colored buttons and set color in array to default
-(void)changeCurrentButtonToDefault:(RSColorPickButton*)button {
    [self.colorSet removeObject:button];
    [button buttonPressDown:button];
    [self.colorSet addObject:self.colorPickButtonDefault];
}

@end
