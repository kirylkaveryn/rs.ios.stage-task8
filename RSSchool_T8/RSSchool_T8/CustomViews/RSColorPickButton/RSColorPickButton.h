//
//  RSColorPickButton.h
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 16.07.21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSColorPickButton : UIButton

typedef NS_ENUM(NSInteger, ColorPickButtonEnum) {
    statePick,
    stateUnpick,
};

@property (strong, nonatomic) CALayer* colorPickLayer;
@property (nonatomic, readonly) ColorPickButtonEnum colorPickButtonState;

-(void)buttonPressDown:(id)button;
-(void)configureButton;

@end

NS_ASSUME_NONNULL_END
