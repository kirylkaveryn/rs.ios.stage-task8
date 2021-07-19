//
//  RSColorPickButton.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 16.07.21.
//

#import "RSColorPickButton.h"
#import "RSColor.h"

@interface RSColorPickButton ()

@property (nonatomic, readwrite) ColorPickButtonEnum colorPickButtonState;

@end

@implementation RSColorPickButton

-(void)awakeFromNib {
    [super awakeFromNib];
    [self configureButton];
}

// configure button
-(void)configureButton {
    self.layer.cornerRadius = 10.0;
    self.layer.backgroundColor = [UIColor rsColorWhite].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor rsColorBlack].CGColor;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.25;
    [self clipsToBounds];
    
    self.colorPickLayer = [CALayer layer];
    self.colorPickLayer.frame = CGRectInset(self.bounds, 8, 8);
    self.colorPickLayer.cornerRadius = 6.0;
    self.colorPickLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:self.colorPickLayer];
    
    // set default state to button
    self.colorPickButtonState = stateUnpick;

}

// change button view and statement
-(void)buttonPressDown:(RSColorPickButton*)button {
    if (button.colorPickButtonState == stateUnpick) {
        button.colorPickLayer.frame = CGRectInset(self.bounds, 2, 2);
        button.colorPickLayer.cornerRadius = 8.0;
        button.colorPickButtonState = statePick;
    }
    else {
        button.colorPickLayer.frame = CGRectInset(self.bounds, 8, 8);
        button.colorPickLayer.cornerRadius = 6.0;
        button.colorPickButtonState = stateUnpick;
    }
}

@end
