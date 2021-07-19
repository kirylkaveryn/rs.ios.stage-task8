//
//  RSButton.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 15.07.21.
//

#import "RSButton.h"
#import "RSColor.h"


@interface RSButton ()

@end


@implementation RSButton

-(void)awakeFromNib {
    [super awakeFromNib];
    [self configureButton];
}

-(void)configureButton {
    self.layer.cornerRadius = 10.0;
    self.layer.backgroundColor = [UIColor rsColorWhite].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor rsColorBlack].CGColor;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.25;
    [self clipsToBounds];
    self.selectedMode = false;
    
    [self.titleLabel setFont: [UIFont fontWithName:@"Montserrat-Medium" size:18.0]];
    [self setTitleColor:[UIColor rsColorLightGreenSea] forState:UIControlStateNormal];
    [self setTitleColor:[self.currentTitleColor colorWithAlphaComponent:1.0] forState:UIControlStateHighlighted];
}

-(void)setHighlighted:(BOOL)highlighted {
    if (self.selectedMode == false) {
        if (highlighted) {
            self.layer.shadowColor = [UIColor rsColorLightGreenSea].CGColor;
            self.layer.shadowRadius = 2.0;
            self.layer.shadowOpacity = 1.0;
        }
        else {
            self.layer.shadowColor = [UIColor rsColorBlack].CGColor;
            self.layer.shadowRadius = 1.0;
            self.layer.shadowOpacity = 0.25;
        }
    }
}

-(void)setSelected:(BOOL)selected {
    if (self.selectedMode == true) {
        if (selected) {
            self.layer.shadowColor = [UIColor rsColorLightGreenSea].CGColor;
            self.layer.shadowRadius = 2.0;
            self.layer.shadowOpacity = 1.0;
        }
        else {
            self.layer.shadowColor = [UIColor rsColorBlack].CGColor;
            self.layer.shadowRadius = 1.0;
            self.layer.shadowOpacity = 0.25;
        }
    }
}

@end
