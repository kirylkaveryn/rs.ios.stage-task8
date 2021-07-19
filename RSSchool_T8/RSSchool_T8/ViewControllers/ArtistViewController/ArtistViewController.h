//
//  ArtistViewController.h
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 15.07.21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArtistViewController : UIViewController

typedef NS_ENUM(NSInteger, ArtistViewControllerState) {
    stateArtistIdle,
    stateArtistDraw,
    stateArtistDone,
};

@property (nonatomic, readonly) ArtistViewControllerState currentState;

-(void)setStateForArtistViewController: (ArtistViewControllerState) statement;

@end

NS_ASSUME_NONNULL_END
