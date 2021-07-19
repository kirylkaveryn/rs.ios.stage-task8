//
//  RSColorViewController.h
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 16.07.21.
//

#import <UIKit/UIKit.h>
#import "RSColorPickButton.h"
#import "RSColor.h"
#import "RSButton.h"
#import <GameplayKit/GameplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorViewController : UIViewController
@property (strong, nonatomic, readonly) NSMutableArray <RSColorPickButton *> *colorSet;
@end

NS_ASSUME_NONNULL_END
