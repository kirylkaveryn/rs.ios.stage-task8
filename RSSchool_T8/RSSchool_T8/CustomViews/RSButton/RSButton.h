//
//  RSButton.h
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 15.07.21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSButton : UIButton

@property (assign, nonatomic) BOOL selectedMode;

-(void)setHighlighted:(BOOL)highlighted;
-(void)setSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
