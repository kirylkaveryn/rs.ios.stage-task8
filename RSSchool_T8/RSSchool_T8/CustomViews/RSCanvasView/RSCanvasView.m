//
//  RSCanvasView.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 16.07.21.
//

#import "RSCanvasView.h"
#import "RSColor.h"

@implementation RSCanvasView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureCanvasView];
}

- (void)configureCanvasView {
    [self.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowColor = [UIColor rsColorChillSky].CGColor;
    self.layer.shadowRadius = 4.0;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.25;
}

@end
