//
//  ArtistViewController.m
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 15.07.21.
//

#import "ArtistViewController.h"
#import "ColorViewController.h"
#import "RSColor.h"
#import "RSButton.h"
#import "RSCanvasView.h"
#import "RSSchool_T8-Swift.h"
#import <GameplayKit/GameplayKit.h>

@interface ArtistViewController () <TimerButtonsActions>

@property (weak, nonatomic) IBOutlet RSCanvasView *canvasView;
@property (strong, nonnull) DrawingsVC *drawingsVC;
@property (strong, nonnull) TimerViewController *timerVC;
@property (strong, nonnull) ColorViewController *colorPickVC;
@property (nonatomic, readwrite) ArtistViewControllerState currentState;
@property (weak, nonatomic) IBOutlet RSButton *openPaletteButton;
@property (weak, nonatomic) IBOutlet RSButton *openTimerButton;
@property (weak, nonatomic) IBOutlet RSButton *drawButton;
@property (weak, nonatomic) IBOutlet RSButton *shareButton;
@property (weak, nonatomic) IBOutlet RSButton *resetButton;
@property (strong, nonnull) NSString *drawingPicture;
@property (strong, nonatomic) CABasicAnimation *drawAnimation;
@property (strong, nonatomic) CABasicAnimation *eraseAnimation;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) NSMutableArray <RSColorPickButton *> *colorSet;
@property (assign, nonatomic) CFTimeInterval timerInterval;
@property (assign, nonatomic) CFTimeInterval eraseTimerInterval;
@property (assign, nonatomic) NSTimer *timer;


@end

@implementation ArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.drawingsVC = [[DrawingsVC alloc] initWithNibName:@"DrawingsVC" bundle:nil];
    self.colorPickVC = [[ColorViewController alloc] initWithNibName:@"ColorViewController" bundle:nil];
    self.timerVC = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
    [self setDefaultColorSet];
    self.timerInterval = 1.0;
    
    [self.drawButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.openPaletteButton addTarget:self action:@selector(paletteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.openTimerButton addTarget:self action:@selector(timerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];
    [self clearCanvasView];
    [self setStateForArtistViewController:stateArtistIdle];
//    [self configureAnimationProperty];
    
    [self addChildViewController:self.colorPickVC];
    [self addChildViewController:self.timerVC];
}

- (void)setupNavigationItems {
    self.navigationItem.title = @"Artist";
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor rsColorBlack],
        NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],};
    
    self.drawingsVC.navigationItem.title = @"Drawings";
    self.drawingsVC.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor rsColorBlack],
        NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],};
    
    UIBarButtonItem *drawings = [[UIBarButtonItem alloc] initWithTitle:@"Drawings"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(drawingsTapped:)];
    [drawings setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor rsColorLightGreenSea],
            NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],} forState:UIControlStateHighlighted];
    [drawings setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor rsColorLightGreenSea],
            NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],} forState:UIControlStateNormal];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Artist"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(artistTapped:)];
    [backButton setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor rsColorLightGreenSea],
            NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],} forState:UIControlStateHighlighted];
    [backButton setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor rsColorLightGreenSea],
            NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:18.0],} forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor rsColorLightGreenSea]];
    
    self.navigationItem.rightBarButtonItem = drawings;
    self.navigationItem.backBarButtonItem = backButton;
    
    
}


// MARK: buttons actions
- (void)drawingsTapped:(id)sender {
    [self.navigationController pushViewController:self.drawingsVC animated:YES];
}

- (void)artistTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)paletteButtonTapped:(RSButton *)sender {
    [self.view addSubview:self.colorPickVC.view];
}

- (void)paletteSaveButtonTapped:(RSButton *)sender {
    self.colorSet = self.colorPickVC.colorSet;
}

- (void)drawButtonTapped:(RSButton *)sender {
    [self setStateForArtistViewController:stateArtistDraw];
    [self clearCanvasView];
    if ([self.drawingsVC.drawing isEqual: @"Tree"]) {
        [self drawTree];
    }
    if ([self.drawingsVC.drawing isEqual: @"Head"]) {
        [self drawHead];
    }
    if ([self.drawingsVC.drawing isEqual: @"Planet"]) {
        [self drawPlanet];
    }
    if ([self.drawingsVC.drawing isEqual: @"Landscape"]) {
        [self drawLandscape];
    }
    [NSTimer scheduledTimerWithTimeInterval:self.timerInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self setStateForArtistViewController:stateArtistDone];
    }];
}

- (void)resetButtonTapped:(RSButton *)sender {
    self.eraseTimerInterval = 0.1;
    [self setStateForArtistViewController:stateArtistDraw];
    [self eraseShape:self.canvasView.layer.sublayers.firstObject];
//    [NSTimer scheduledTimerWithTimeInterval:self.eraseTimerInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
    [self setStateForArtistViewController:stateArtistIdle];
//    }];
}

-(void)shareButtonTapped:(RSButton *)sender {
    if (self.canvasView.layer != nil) {
        UIGraphicsBeginImageContext(self.canvasView.layer.bounds.size);
        [self.canvasView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:^{}];
    }

}

- (void)timerButtonTapped:(RSButton *)sender {
    [self.view addSubview:self.timerVC.view];
}

- (void)timerSaveButtonTapped:(RSButton *)sender {
    self.timerInterval = [self.timerVC.currentTimerValue.text doubleValue];
}

- (void)disableButton:(RSButton *) button {
    [button setAlpha:0.5];
    button.enabled = NO;
}

- (void)enableButton:(RSButton *) button {
    [button setAlpha:1.0];
    button.enabled = YES;
}

// MARK: configerate props and statements
-(void)setStateForArtistViewController: (ArtistViewControllerState) statement {
    
    switch (statement) {
        case stateArtistIdle:
            [self enableButton:self.openPaletteButton];
            [self enableButton:self.openTimerButton];
            [self enableButton:self.drawButton];
            [self disableButton:self.shareButton];
            [self.drawButton setHidden:NO];
            [self.resetButton setHidden:YES];
            self.currentState = stateArtistIdle;
            break;
        case stateArtistDraw:
            [self disableButton:self.openPaletteButton];
            [self disableButton:self.openTimerButton];
            [self disableButton:self.drawButton];
            [self disableButton:self.shareButton];
            self.currentState = stateArtistDraw;
            break;
        case stateArtistDone:
            [self disableButton:self.openPaletteButton];
            [self disableButton:self.openTimerButton];
            [self enableButton:self.drawButton];
            [self enableButton:self.shareButton];
            [self.drawButton setHidden:YES];
            [self.resetButton setHidden:NO];
            self.currentState = stateArtistDone;
            break;
    }
}

// метод устонавливает дефолтную цветовоую палитру (три черных цвета)
-(void)setDefaultColorSet {
    self.colorSet = [NSMutableArray new];
    RSColorPickButton *defaultButton = [RSColorPickButton new];
    [defaultButton configureButton];
    defaultButton.colorPickLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.colorSet addObject:defaultButton];
    [self.colorSet addObject:defaultButton];
    [self.colorSet addObject:defaultButton];
}

// MARK: метод для анимации через CAAnimation задает параметры анимации на рисование и удаление
//-(void)configureAnimationProperty {
//    CABasicAnimation *draw =[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    draw.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    if (self.timer == 0) {
//        draw.duration = 1.0;
//    }
//    else {
//        draw.duration = self.timerInterval;
//    }
//
//    draw.fromValue = @(0.0);
//    draw.toValue = @(1.0);
//    self.drawAnimation = draw;
//
//    CABasicAnimation *erase =[CABasicAnimation animationWithKeyPath:@"strokeStart"];
//    erase.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    erase.duration = 0.5;
//    erase.fromValue = @(0.0);
//    erase.toValue = @(1.0);
//    self.eraseAnimation = erase;
//}

-(void)drawShape:(CAShapeLayer *)shapeLayer {
    CGFloat delta = 1 / (self.timerInterval * 60);
    NSTimeInterval interval = 1 / 60.0;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 0.0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
        shapeLayer.strokeEnd = shapeLayer.strokeEnd + delta;
        for (CAShapeLayer* layer in shapeLayer.sublayers) {
            layer.strokeEnd = layer.strokeEnd + delta;
        }
        [self.canvasView setNeedsDisplay];

        if (shapeLayer.strokeEnd > 1.0) {
            shapeLayer.strokeEnd = 1.0;
            [self.timer invalidate];
            self.timer = nil;
        }
    }];

    [self.timer fire];

}

-(void)eraseShape:(CAShapeLayer *)shapeLayer {
    CGFloat delta = 1 / (self.eraseTimerInterval * 60.0);
    NSTimeInterval interval = 1 / 60.0;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 1.0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
        shapeLayer.strokeStart = shapeLayer.strokeStart + delta;
        for (CAShapeLayer* layer in shapeLayer.sublayers) {
            layer.strokeStart = layer.strokeStart + delta;
        }
        [self.canvasView setNeedsDisplay];

        if (shapeLayer.strokeStart > 1.0) {
            shapeLayer.strokeStart = 1.0;
            [self.timer invalidate];
            self.timer = nil;
        }
    }];

    [self.timer fire];
//    [self clearCanvasView];
}

-(CAShapeLayer *)setShapeLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 1;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.miterLimit = 4;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 0.0;
    return shapeLayer;
}

-(NSArray*)shuffleArray:(NSMutableArray*)array {
    if (array.count == 1) {
        return array;
    }
    else {
        NSMutableArray *unshuffledArray = [NSMutableArray arrayWithArray:array];
        NSMutableArray *shuffledArray = [NSMutableArray new];
        for (NSUInteger i = 0; i < array.count - 1; i++) {
            int randomNumber = arc4random_uniform((int)(unshuffledArray.count - i));
            [shuffledArray addObject:unshuffledArray[randomNumber]];
            [unshuffledArray removeObjectAtIndex:randomNumber];
        }
        [shuffledArray addObject:unshuffledArray.firstObject];
        return [shuffledArray copy];
    }
}

// MARK: метод для анимации через CAAnimation
// метод назначает всем бизье линиям анимацию на рисование и создает из них общий CAShapeLayer
//-(NSMutableArray*)createShapeLayerWithBezierPathArray:(NSArray<UIBezierPath*>*) bezierPathArray {
////    [self configureAnimationProperty];
//    NSMutableArray<RSColorPickButton *> *shuffledColorSetArray = [[NSMutableArray alloc] init];
//    [shuffledColorSetArray addObjectsFromArray:[self shuffleArray:self.colorSet]];
//    NSMutableArray *masterLayer = [NSMutableArray new];
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//
//    for (int i = 0; i < bezierPathArray.count; i++) {
//        shapeLayer = [self setShapeLayer];
//        shapeLayer.path = bezierPathArray[i].CGPath;
//        shapeLayer.strokeEnd = 0.0;
//        shapeLayer.strokeColor = shuffledColorSetArray[i].colorPickLayer.backgroundColor;
////        [shapeLayer addAnimation:self.drawAnimation forKey:nil];
//        [masterLayer addObject:shapeLayer];
//    }
//    return masterLayer;
//}

-(CAShapeLayer*)createShapeLayerWithBezierPathArray:(NSArray<UIBezierPath*>*) bezierPathArray {
    NSMutableArray<RSColorPickButton *> *shuffledColorSetArray = [[NSMutableArray alloc] init];
    [shuffledColorSetArray addObjectsFromArray:[self shuffleArray:self.colorSet]];
    CAShapeLayer *masterLayer = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    for (int i = 0; i < bezierPathArray.count; i++) {
        shapeLayer = [self setShapeLayer];
        shapeLayer.path = bezierPathArray[i].CGPath;
        shapeLayer.strokeColor = shuffledColorSetArray[i].colorPickLayer.backgroundColor;
        [masterLayer addSublayer:shapeLayer];
    }
    return masterLayer;
}


// MARK: метод для анимации через CAAnimation
// метод получет первый саблэер рутового лэйера у canvasView и переназначает всем бизье линиям анимацию на удаление
//-(void)eraseDrawingFromLayer:(CAShapeLayer*) shapeLayer {
//    for (CAShapeLayer *layer in shapeLayer.sublayers) {
//        layer.strokeStart = 0.0;
//        [layer addAnimation:self.eraseAnimation forKey:nil];
//    }
//    [NSTimer scheduledTimerWithTimeInterval:self.eraseAnimation.duration target:self selector:@selector(clearCanvasView) userInfo:nil repeats:NO];
//}


// метод удаляет все саблэеры с лэера canvasView
-(void)clearCanvasView {
    for (CALayer *layer in self.canvasView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}


// MARK: drawing methods
// метод рисования Head
- (void)drawHead {
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(61.5, 28.04)];
    [bezierPath addLineToPoint: CGPointMake(77, 86.86)];
    [bezierPath addLineToPoint: CGPointMake(89, 109.41)];
    [bezierPath addLineToPoint: CGPointMake(106.5, 128.52)];
    [bezierPath addLineToPoint: CGPointMake(133.5, 150.58)];
    [bezierPath addLineToPoint: CGPointMake(157, 155.97)];
    [bezierPath addLineToPoint: CGPointMake(193, 138.82)];
    [bezierPath addLineToPoint: CGPointMake(220, 109.41)];
    [bezierPath addLineToPoint: CGPointMake(228.5, 97.64)];
    [bezierPath addLineToPoint: CGPointMake(228.5, 75.59)];
    [bezierPath addLineToPoint: CGPointMake(230.5, 49.12)];
    [bezierPath addLineToPoint: CGPointMake(218.5, 39.31)];
    [bezierPath addLineToPoint: CGPointMake(202, 42.25)];
    [bezierPath addLineToPoint: CGPointMake(191, 58.92)];
    [bezierPath addLineToPoint: CGPointMake(189, 81.47)];
    [bezierPath addLineToPoint: CGPointMake(193, 93.72)];

    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(184, 97.64)];
    [bezier2Path addLineToPoint: CGPointMake(175.5, 96.17)];
    [bezier2Path addLineToPoint: CGPointMake(166, 98.13)];
    [bezier2Path addLineToPoint: CGPointMake(158, 99.11)];
    [bezier2Path addLineToPoint: CGPointMake(148.5, 98.13)];
    [bezier2Path addLineToPoint: CGPointMake(140, 96.66)];
    [bezier2Path addLineToPoint: CGPointMake(133.5, 96.17)];
    [bezier2Path addLineToPoint: CGPointMake(126, 97.64)];
    [bezier2Path addLineToPoint: CGPointMake(121.5, 99.6)];
    [bezier2Path addLineToPoint: CGPointMake(127.5, 102.05)];
    [bezier2Path addLineToPoint: CGPointMake(132, 105.49)];
    [bezier2Path addLineToPoint: CGPointMake(136.5, 110.39)];
    [bezier2Path addLineToPoint: CGPointMake(142.5, 112.84)];
    [bezier2Path addLineToPoint: CGPointMake(150, 113.82)];
    [bezier2Path addLineToPoint: CGPointMake(157, 112.84)];
    [bezier2Path addLineToPoint: CGPointMake(164.5, 113.82)];
    [bezier2Path addLineToPoint: CGPointMake(170.5, 112.84)];
    [bezier2Path addLineToPoint: CGPointMake(177, 108.92)];
    [bezier2Path addLineToPoint: CGPointMake(184, 101.07)];
    [bezier2Path addLineToPoint: CGPointMake(188.5, 95.19)];
    [bezier2Path addLineToPoint: CGPointMake(180.5, 94.21)];
    [bezier2Path addLineToPoint: CGPointMake(171.5, 93.23)];
    [bezier2Path addLineToPoint: CGPointMake(162.5, 91.27)];
    [bezier2Path addLineToPoint: CGPointMake(154, 90.78)];
    [bezier2Path addLineToPoint: CGPointMake(144, 92.25)];
    [bezier2Path addLineToPoint: CGPointMake(135, 94.21)];
    [bezier2Path addLineToPoint: CGPointMake(125, 95.19)];
    [bezier2Path addLineToPoint: CGPointMake(118, 94.7)];
    [bezier2Path addLineToPoint: CGPointMake(127.5, 88.82)];
    [bezier2Path addLineToPoint: CGPointMake(136.5, 82.45)];
    [bezier2Path addLineToPoint: CGPointMake(142.5, 79.02)];
    [bezier2Path addLineToPoint: CGPointMake(147.5, 80.49)];
    [bezier2Path addLineToPoint: CGPointMake(153, 82.45)];
    [bezier2Path addLineToPoint: CGPointMake(159.5, 81.47)];
    [bezier2Path addLineToPoint: CGPointMake(166, 80.49)];
    [bezier2Path addLineToPoint: CGPointMake(171.5, 80.49)];
    [bezier2Path addLineToPoint: CGPointMake(174.5, 82.45)];
    [bezier2Path addLineToPoint: CGPointMake(179.5, 87.35)];
    [bezier2Path addLineToPoint: CGPointMake(187, 91.76)];

    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(189.5, 100.09)];
    [bezier3Path addLineToPoint: CGPointMake(194, 105.98)];
    [bezier3Path addLineToPoint: CGPointMake(196.5, 112.35)];
    [bezier3Path addLineToPoint: CGPointMake(193, 121.17)];
    [bezier3Path addLineToPoint: CGPointMake(186, 129.5)];
    [bezier3Path addLineToPoint: CGPointMake(177, 136.37)];
    [bezier3Path addLineToPoint: CGPointMake(167.5, 129.5)];
    [bezier3Path addLineToPoint: CGPointMake(157, 125.58)];
    [bezier3Path addLineToPoint: CGPointMake(147.5, 125.58)];
    [bezier3Path addLineToPoint: CGPointMake(135.5, 129.5)];
    [bezier3Path addLineToPoint: CGPointMake(127.5, 138.82)];
    [bezier3Path addLineToPoint: CGPointMake(121, 151.07)];
    [bezier3Path addLineToPoint: CGPointMake(109.5, 144.21)];
    [bezier3Path addLineToPoint: CGPointMake(101.5, 134.41)];
    [bezier3Path addLineToPoint: CGPointMake(93, 125.58)];
    [bezier3Path addLineToPoint: CGPointMake(93, 138.82)];
    [bezier3Path addLineToPoint: CGPointMake(93, 166.76)];
    [bezier3Path addLineToPoint: CGPointMake(93, 183.42)];
    [bezier3Path addLineToPoint: CGPointMake(86, 194.7)];
    [bezier3Path addLineToPoint: CGPointMake(74.5, 203.03)];
    [bezier3Path addLineToPoint: CGPointMake(63.5, 209.89)];
    [bezier3Path addLineToPoint: CGPointMake(81, 216.27)];
    [bezier3Path addLineToPoint: CGPointMake(94.5, 224.6)];
    [bezier3Path addLineToPoint: CGPointMake(105, 238.32)];
    [bezier3Path addLineToPoint: CGPointMake(119, 255.48)];
    [bezier3Path addLineToPoint: CGPointMake(138, 273.13)];
    [bezier3Path addLineToPoint: CGPointMake(157, 279.5)];
    [bezier3Path addLineToPoint: CGPointMake(171, 279.5)];
    [bezier3Path addLineToPoint: CGPointMake(186, 271.66)];
    [bezier3Path addLineToPoint: CGPointMake(199.5, 255.48)];
    [bezier3Path addLineToPoint: CGPointMake(209.5, 234.4)];
    [bezier3Path addLineToPoint: CGPointMake(219, 218.72)];
    [bezier3Path addLineToPoint: CGPointMake(233.5, 212.35)];
    [bezier3Path addLineToPoint: CGPointMake(237, 212.35)];
    [bezier3Path addLineToPoint: CGPointMake(230.5, 197.15)];
    [bezier3Path addLineToPoint: CGPointMake(221, 169.21)];
    [bezier3Path addLineToPoint: CGPointMake(219, 146.66)];
    [bezier3Path addLineToPoint: CGPointMake(219, 123.62)];
    [bezier3Path addLineToPoint: CGPointMake(212, 134.41)];
    [bezier3Path addLineToPoint: CGPointMake(204, 142.25)];
    [bezier3Path addLineToPoint: CGPointMake(196.5, 151.07)];
    [bezier3Path addLineToPoint: CGPointMake(180, 166.76)];
    [bezier3Path addLineToPoint: CGPointMake(170, 180.97)];
    [bezier3Path addLineToPoint: CGPointMake(161.5, 202.05)];
    [bezier3Path addLineToPoint: CGPointMake(158.5, 227.54)];
    [bezier3Path addLineToPoint: CGPointMake(158.5, 255.48)];
    [bezier3Path addLineToPoint: CGPointMake(158.5, 273.13)];
    
    NSArray<UIBezierPath*> *bezierPathArray = [[NSArray alloc] initWithObjects:bezierPath, bezier2Path, bezier3Path, nil];
    CAShapeLayer *masterLayer = [self createShapeLayerWithBezierPathArray:bezierPathArray];

    [self.canvasView.layer addSublayer:masterLayer];
    [self drawShape:masterLayer];

}


-(void)drawTree {
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(213.19, 71.56)];
    [bezierPath addCurveToPoint: CGPointMake(217, 62.51) controlPoint1: CGPointMake(215.57, 69.11) controlPoint2: CGPointMake(217, 65.95)];
    [bezierPath addCurveToPoint: CGPointMake(200.5, 48.34) controlPoint1: CGPointMake(217, 54.68) controlPoint2: CGPointMake(209.61, 48.34)];
    [bezierPath addCurveToPoint: CGPointMake(195.97, 48.88) controlPoint1: CGPointMake(198.93, 48.34) controlPoint2: CGPointMake(197.41, 48.53)];
    [bezierPath addCurveToPoint: CGPointMake(179.5, 35.64) controlPoint1: CGPointMake(195.41, 41.49) controlPoint2: CGPointMake(188.25, 35.64)];
    [bezierPath addCurveToPoint: CGPointMake(171.6, 37.36) controlPoint1: CGPointMake(176.64, 35.64) controlPoint2: CGPointMake(173.94, 36.26)];
    [bezierPath addCurveToPoint: CGPointMake(160.5, 33.68) controlPoint1: CGPointMake(168.67, 35.08) controlPoint2: CGPointMake(164.77, 33.68)];
    [bezierPath addCurveToPoint: CGPointMake(155.97, 34.22) controlPoint1: CGPointMake(158.93, 33.68) controlPoint2: CGPointMake(157.41, 33.87)];
    [bezierPath addCurveToPoint: CGPointMake(139.5, 20.98) controlPoint1: CGPointMake(155.41, 26.83) controlPoint2: CGPointMake(148.25, 20.98)];
    [bezierPath addCurveToPoint: CGPointMake(125.59, 27.53) controlPoint1: CGPointMake(133.65, 20.98) controlPoint2: CGPointMake(128.52, 23.59)];
    [bezierPath addCurveToPoint: CGPointMake(120.5, 26.84) controlPoint1: CGPointMake(123.98, 27.08) controlPoint2: CGPointMake(122.28, 26.84)];
    [bezierPath addCurveToPoint: CGPointMake(110.81, 29.54) controlPoint1: CGPointMake(116.88, 26.84) controlPoint2: CGPointMake(113.53, 27.84)];
    [bezierPath addCurveToPoint: CGPointMake(105.5, 28.79) controlPoint1: CGPointMake(109.14, 29.06) controlPoint2: CGPointMake(107.36, 28.79)];
    [bezierPath addCurveToPoint: CGPointMake(91.59, 35.34) controlPoint1: CGPointMake(99.65, 28.79) controlPoint2: CGPointMake(94.52, 31.41)];
    [bezierPath addCurveToPoint: CGPointMake(86.5, 34.66) controlPoint1: CGPointMake(89.98, 34.9) controlPoint2: CGPointMake(88.28, 34.66)];
    [bezierPath addCurveToPoint: CGPointMake(70, 48.83) controlPoint1: CGPointMake(77.39, 34.66) controlPoint2: CGPointMake(70, 41)];
    [bezierPath addCurveToPoint: CGPointMake(70.01, 49.34) controlPoint1: CGPointMake(70, 49) controlPoint2: CGPointMake(70, 49.17)];
    [bezierPath addCurveToPoint: CGPointMake(68.59, 50.98) controlPoint1: CGPointMake(69.49, 49.85) controlPoint2: CGPointMake(69.02, 50.4)];
    [bezierPath addCurveToPoint: CGPointMake(63.5, 50.29) controlPoint1: CGPointMake(66.98, 50.53) controlPoint2: CGPointMake(65.28, 50.29)];
    [bezierPath addCurveToPoint: CGPointMake(47, 64.46) controlPoint1: CGPointMake(54.39, 50.29) controlPoint2: CGPointMake(47, 56.64)];
    [bezierPath addCurveToPoint: CGPointMake(48.58, 70.53) controlPoint1: CGPointMake(47, 66.63) controlPoint2: CGPointMake(47.57, 68.69)];
    [bezierPath addCurveToPoint: CGPointMake(46, 78.14) controlPoint1: CGPointMake(46.95, 72.73) controlPoint2: CGPointMake(46, 75.34)];
    [bezierPath addCurveToPoint: CGPointMake(47.19, 83.44) controlPoint1: CGPointMake(46, 80.02) controlPoint2: CGPointMake(46.42, 81.81)];
    [bezierPath addCurveToPoint: CGPointMake(44, 91.82) controlPoint1: CGPointMake(45.19, 85.79) controlPoint2: CGPointMake(44, 88.69)];
    [bezierPath addCurveToPoint: CGPointMake(45.58, 97.89) controlPoint1: CGPointMake(44, 93.99) controlPoint2: CGPointMake(44.57, 96.05)];
    [bezierPath addCurveToPoint: CGPointMake(43, 105.5) controlPoint1: CGPointMake(43.95, 100.09) controlPoint2: CGPointMake(43, 102.7)];
    [bezierPath addCurveToPoint: CGPointMake(59.5, 119.67) controlPoint1: CGPointMake(43, 113.33) controlPoint2: CGPointMake(50.39, 119.67)];
    [bezierPath addCurveToPoint: CGPointMake(61.68, 119.55) controlPoint1: CGPointMake(60.24, 119.67) controlPoint2: CGPointMake(60.96, 119.63)];
    [bezierPath addCurveToPoint: CGPointMake(76.5, 127.49) controlPoint1: CGPointMake(64.36, 124.25) controlPoint2: CGPointMake(69.99, 127.49)];
    [bezierPath addCurveToPoint: CGPointMake(84.35, 125.79) controlPoint1: CGPointMake(79.34, 127.49) controlPoint2: CGPointMake(82.02, 126.87)];
    [bezierPath addCurveToPoint: CGPointMake(99.5, 134.33) controlPoint1: CGPointMake(86.89, 130.82) controlPoint2: CGPointMake(92.72, 134.33)];
    [bezierPath addCurveToPoint: CGPointMake(101.68, 134.21) controlPoint1: CGPointMake(100.24, 134.33) controlPoint2: CGPointMake(100.96, 134.29)];
    [bezierPath addCurveToPoint: CGPointMake(116.5, 142.15) controlPoint1: CGPointMake(104.36, 138.91) controlPoint2: CGPointMake(109.99, 142.15)];
    [bezierPath addCurveToPoint: CGPointMake(125, 140.13) controlPoint1: CGPointMake(119.61, 142.15) controlPoint2: CGPointMake(122.52, 141.41)];
    [bezierPath addCurveToPoint: CGPointMake(129.66, 141.76) controlPoint1: CGPointMake(126.43, 140.86) controlPoint2: CGPointMake(127.99, 141.42)];
    [bezierPath addCurveToPoint: CGPointMake(142.5, 147.04) controlPoint1: CGPointMake(132.68, 144.98) controlPoint2: CGPointMake(137.31, 147.04)];
    [bezierPath addCurveToPoint: CGPointMake(150.35, 145.33) controlPoint1: CGPointMake(145.34, 147.04) controlPoint2: CGPointMake(148.02, 146.42)];
    [bezierPath addCurveToPoint: CGPointMake(165.5, 153.88) controlPoint1: CGPointMake(152.89, 150.36) controlPoint2: CGPointMake(158.72, 153.88)];
    [bezierPath addCurveToPoint: CGPointMake(167.68, 153.75) controlPoint1: CGPointMake(166.24, 153.88) controlPoint2: CGPointMake(166.96, 153.83)];
    [bezierPath addCurveToPoint: CGPointMake(182.5, 161.69) controlPoint1: CGPointMake(170.36, 158.46) controlPoint2: CGPointMake(175.99, 161.69)];
    [bezierPath addCurveToPoint: CGPointMake(191, 159.67) controlPoint1: CGPointMake(185.61, 161.69) controlPoint2: CGPointMake(188.52, 160.96)];
    [bezierPath addCurveToPoint: CGPointMake(199.5, 161.69) controlPoint1: CGPointMake(193.48, 160.96) controlPoint2: CGPointMake(196.39, 161.69)];
    [bezierPath addCurveToPoint: CGPointMake(216, 147.52) controlPoint1: CGPointMake(208.61, 161.69) controlPoint2: CGPointMake(216, 155.35)];
    [bezierPath addCurveToPoint: CGPointMake(215.99, 147.03) controlPoint1: CGPointMake(216, 147.36) controlPoint2: CGPointMake(216, 147.19)];
    [bezierPath addCurveToPoint: CGPointMake(216.5, 147.04) controlPoint1: CGPointMake(216.16, 147.03) controlPoint2: CGPointMake(216.33, 147.04)];
    [bezierPath addCurveToPoint: CGPointMake(225, 145.01) controlPoint1: CGPointMake(219.61, 147.04) controlPoint2: CGPointMake(222.52, 146.3)];
    [bezierPath addCurveToPoint: CGPointMake(233.5, 147.04) controlPoint1: CGPointMake(227.48, 146.3) controlPoint2: CGPointMake(230.39, 147.04)];
    [bezierPath addCurveToPoint: CGPointMake(250, 132.87) controlPoint1: CGPointMake(242.61, 147.04) controlPoint2: CGPointMake(250, 140.69)];
    [bezierPath addCurveToPoint: CGPointMake(249.66, 130) controlPoint1: CGPointMake(250, 131.88) controlPoint2: CGPointMake(249.88, 130.92)];
    [bezierPath addCurveToPoint: CGPointMake(257, 118.21) controlPoint1: CGPointMake(254.09, 127.45) controlPoint2: CGPointMake(257, 123.12)];
    [bezierPath addCurveToPoint: CGPointMake(253.19, 109.15) controlPoint1: CGPointMake(257, 114.77) controlPoint2: CGPointMake(255.57, 111.61)];
    [bezierPath addCurveToPoint: CGPointMake(260, 97.69) controlPoint1: CGPointMake(257.32, 106.58) controlPoint2: CGPointMake(260, 102.4)];
    [bezierPath addCurveToPoint: CGPointMake(243.5, 83.52) controlPoint1: CGPointMake(260, 89.86) controlPoint2: CGPointMake(252.61, 83.52)];
    [bezierPath addCurveToPoint: CGPointMake(238.96, 84.06) controlPoint1: CGPointMake(241.93, 83.52) controlPoint2: CGPointMake(240.41, 83.71)];
    [bezierPath addCurveToPoint: CGPointMake(222.5, 70.81) controlPoint1: CGPointMake(238.41, 76.66) controlPoint2: CGPointMake(231.25, 70.81)];
    [bezierPath addCurveToPoint: CGPointMake(214.6, 72.54) controlPoint1: CGPointMake(219.64, 70.81) controlPoint2: CGPointMake(216.94, 71.44)];
    [bezierPath addCurveToPoint: CGPointMake(213.19, 71.56) controlPoint1: CGPointMake(214.15, 72.19) controlPoint2: CGPointMake(213.68, 71.87)];
    [bezierPath closePath];

    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(82, 252.08)];
    [bezier2Path addCurveToPoint: CGPointMake(143.5, 190.52) controlPoint1: CGPointMake(101.83, 246.38) controlPoint2: CGPointMake(141.9, 226.09)];
    [bezier2Path addCurveToPoint: CGPointMake(133.5, 144.59) controlPoint1: CGPointMake(145.1, 154.95) controlPoint2: CGPointMake(137.5, 145.08)];
    [bezier2Path moveToPoint: CGPointMake(225.5, 257.46)];
    [bezier2Path addCurveToPoint: CGPointMake(172, 229.12) controlPoint1: CGPointMake(207.17, 256.48) controlPoint2: CGPointMake(170.8, 249.45)];
    [bezier2Path addCurveToPoint: CGPointMake(183, 171.95) controlPoint1: CGPointMake(173.2, 208.79) controlPoint2: CGPointMake(179.83, 182.54)];
    [bezier2Path addCurveToPoint: CGPointMake(192.5, 160.23) controlPoint1: CGPointMake(185.17, 167.72) controlPoint2: CGPointMake(190.1, 159.45)];
    [bezier2Path moveToPoint: CGPointMake(158.5, 168.53)];
    [bezier2Path addCurveToPoint: CGPointMake(151, 216.42) controlPoint1: CGPointMake(157, 183.36) controlPoint2: CGPointMake(153.4, 213.68)];
    [bezier2Path moveToPoint: CGPointMake(163.5, 241.34)];
    [bezier2Path addCurveToPoint: CGPointMake(168.5, 171.95) controlPoint1: CGPointMake(163.5, 233.52) controlPoint2: CGPointMake(162.5, 186.12)];
    [bezier2Path moveToPoint: CGPointMake(145, 210.07)];
    [bezier2Path addCurveToPoint: CGPointMake(124.5, 238.4) controlPoint1: CGPointMake(132, 228.63) controlPoint2: CGPointMake(130.5, 233.03)];

    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(99.5, 245.24)];
    [bezier3Path addCurveToPoint: CGPointMake(66, 250.43) controlPoint1: CGPointMake(91.5, 236.94) controlPoint2: CGPointMake(76.4, 237.54)];
    [bezier3Path moveToPoint: CGPointMake(39.5, 256.48)];
    [bezier3Path addCurveToPoint: CGPointMake(63.5, 249.64) controlPoint1: CGPointMake(42.83, 252.74) controlPoint2: CGPointMake(52.3, 246.12)];
    [bezier3Path addCurveToPoint: CGPointMake(74, 253.55) controlPoint1: CGPointMake(74.7, 253.16) controlPoint2: CGPointMake(75.17, 253.71)];
    [bezier3Path moveToPoint: CGPointMake(178, 242.31)];
    [bezier3Path addCurveToPoint: CGPointMake(201.5, 242.31) controlPoint1: CGPointMake(183, 239.61) controlPoint2: CGPointMake(194.7, 235.82)];
    [bezier3Path addCurveToPoint: CGPointMake(206.74, 248.18) controlPoint1: CGPointMake(203.78, 244.49) controlPoint2: CGPointMake(205.48, 246.46)];
    [bezier3Path moveToPoint: CGPointMake(210, 255.02)];
    [bezier3Path addCurveToPoint: CGPointMake(206.74, 248.18) controlPoint1: CGPointMake(210, 254) controlPoint2: CGPointMake(209.25, 251.59)];
    [bezier3Path moveToPoint: CGPointMake(206.74, 248.18)];
    [bezier2Path addCurveToPoint: CGPointMake(241.5, 249.64) controlPoint1: CGPointMake(218.33, 245.08) controlPoint2: CGPointMake(241.5, 241.04)];
    [bezier3Path addCurveToPoint: CGPointMake(224.5, 257.46) controlPoint1: CGPointMake(241.5, 258.24) controlPoint2: CGPointMake(225.83, 256.65)];

    NSArray<UIBezierPath*> *bezierPathArray = [[NSArray alloc] initWithObjects:bezierPath, bezier2Path, bezier3Path, nil];
    CAShapeLayer *masterLayer = [self createShapeLayerWithBezierPathArray:bezierPathArray];
    [self.canvasView.layer addSublayer:masterLayer];
    [self drawShape:masterLayer];
}


-(void)drawPlanet {
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(61, 155)];
    [bezierPath addLineToPoint: CGPointMake(52, 159)];
    [bezierPath addLineToPoint: CGPointMake(43, 166)];
    [bezierPath addLineToPoint: CGPointMake(34.5, 174)];
    [bezierPath addLineToPoint: CGPointMake(28.5, 182)];
    [bezierPath addLineToPoint: CGPointMake(26.5, 190)];
    [bezierPath addLineToPoint: CGPointMake(27.5, 198)];
    [bezierPath addLineToPoint: CGPointMake(31.5, 204.5)];
    [bezierPath addLineToPoint: CGPointMake(38.5, 210)];
    [bezierPath addLineToPoint: CGPointMake(49, 214.5)];
    [bezierPath addLineToPoint: CGPointMake(60, 217)];
    [bezierPath addLineToPoint: CGPointMake(71.5, 218)];
    [bezierPath addLineToPoint: CGPointMake(82.5, 218.5)];
    [bezierPath addLineToPoint: CGPointMake(89, 218.3)];
    [bezierPath moveToPoint: CGPointMake(61, 155)];
    [bezierPath addLineToPoint: CGPointMake(61.5, 148)];
    [bezierPath addLineToPoint: CGPointMake(64, 135.5)];
    [bezierPath addLineToPoint: CGPointMake(67.5, 125)];
    [bezierPath addLineToPoint: CGPointMake(72, 113.5)];
    [bezierPath addLineToPoint: CGPointMake(77.5, 105)];
    [bezierPath addLineToPoint: CGPointMake(84.5, 95.5)];
    [bezierPath addLineToPoint: CGPointMake(92.5, 88)];
    [bezierPath addLineToPoint: CGPointMake(100.5, 82.5)];
    [bezierPath addLineToPoint: CGPointMake(109, 77.5)];
    [bezierPath addCurveToPoint: CGPointMake(120.5, 72.5) controlPoint1: CGPointMake(112.67, 76) controlPoint2: CGPointMake(120.1, 72.9)];
    [bezierPath addCurveToPoint: CGPointMake(131.5, 69) controlPoint1: CGPointMake(120.9, 72.1) controlPoint2: CGPointMake(128, 70)];
    [bezierPath addLineToPoint: CGPointMake(148, 67.5)];
    [bezierPath addLineToPoint: CGPointMake(162, 68.5)];
    [bezierPath addLineToPoint: CGPointMake(176, 71)];
    [bezierPath addLineToPoint: CGPointMake(188.5, 76)];
    [bezierPath addLineToPoint: CGPointMake(200.5, 83.5)];
    [bezierPath addLineToPoint: CGPointMake(209, 90.5)];
    [bezierPath addLineToPoint: CGPointMake(216, 97.5)];
    [bezierPath addLineToPoint: CGPointMake(222, 104.5)];
    [bezierPath moveToPoint: CGPointMake(61, 155)];
    [bezierPath addLineToPoint: CGPointMake(61, 161.5)];
    [bezierPath addLineToPoint: CGPointMake(62, 169)];
    [bezierPath moveToPoint: CGPointMake(222, 104.5)];
    [bezierPath addLineToPoint: CGPointMake(231, 103)];
    [bezierPath addLineToPoint: CGPointMake(243, 102.5)];
    [bezierPath addLineToPoint: CGPointMake(254.5, 104)];
    [bezierPath addLineToPoint: CGPointMake(265, 108)];
    [bezierPath addLineToPoint: CGPointMake(272, 113.5)];
    [bezierPath addLineToPoint: CGPointMake(274.5, 121)];
    [bezierPath addLineToPoint: CGPointMake(274, 130)];
    [bezierPath addLineToPoint: CGPointMake(270.5, 138.5)];
    [bezierPath addLineToPoint: CGPointMake(260, 152)];
    [bezierPath addLineToPoint: CGPointMake(251.5, 160.5)];
    [bezierPath addLineToPoint: CGPointMake(238.5, 170.5)];
    [bezierPath addLineToPoint: CGPointMake(235.17, 172.5)];
    [bezierPath moveToPoint: CGPointMake(222, 104.5)];
    [bezierPath addLineToPoint: CGPointMake(225.5, 109.5)];
    [bezierPath addLineToPoint: CGPointMake(228.5, 116)];
    [bezierPath moveToPoint: CGPointMake(62, 169)];
    [bezierPath addLineToPoint: CGPointMake(58, 171.5)];
    [bezierPath addLineToPoint: CGPointMake(54.5, 176)];
    [bezierPath addLineToPoint: CGPointMake(53, 181)];
    [bezierPath addLineToPoint: CGPointMake(53.5, 186)];
    [bezierPath addLineToPoint: CGPointMake(56, 190)];
    [bezierPath addLineToPoint: CGPointMake(61, 193)];
    [bezierPath addLineToPoint: CGPointMake(68.5, 196)];
    [bezierPath addLineToPoint: CGPointMake(71, 196.47)];
    [bezierPath moveToPoint: CGPointMake(62, 169)];
    [bezierPath addLineToPoint: CGPointMake(64.5, 177.5)];
    [bezierPath addLineToPoint: CGPointMake(67, 186)];
    [bezierPath addLineToPoint: CGPointMake(71, 196.47)];
    [bezierPath moveToPoint: CGPointMake(228.5, 116)];
    [bezierPath addLineToPoint: CGPointMake(235, 116)];
    [bezierPath addLineToPoint: CGPointMake(243, 119)];
    [bezierPath addLineToPoint: CGPointMake(246, 123)];
    [bezierPath addLineToPoint: CGPointMake(246.5, 129)];
    [bezierPath addLineToPoint: CGPointMake(245, 134.5)];
    [bezierPath addLineToPoint: CGPointMake(241, 140)];
    [bezierPath addLineToPoint: CGPointMake(237.33, 144)];
    [bezierPath moveToPoint: CGPointMake(228.5, 116)];
    [bezierPath addLineToPoint: CGPointMake(231.5, 123)];
    [bezierPath addLineToPoint: CGPointMake(235.17, 134.5)];
    [bezierPath addLineToPoint: CGPointMake(237.33, 144)];
    [bezierPath moveToPoint: CGPointMake(89, 218.3)];
    [bezierPath addLineToPoint: CGPointMake(99, 218)];
    [bezierPath addLineToPoint: CGPointMake(120, 215.5)];
    [bezierPath addLineToPoint: CGPointMake(137.5, 212)];
    [bezierPath addLineToPoint: CGPointMake(153, 208)];
    [bezierPath addLineToPoint: CGPointMake(172.5, 202)];
    [bezierPath addLineToPoint: CGPointMake(192, 194.5)];
    [bezierPath addLineToPoint: CGPointMake(207.5, 187.5)];
    [bezierPath addLineToPoint: CGPointMake(223.5, 179.5)];
    [bezierPath addLineToPoint: CGPointMake(235.17, 172.5)];
    [bezierPath moveToPoint: CGPointMake(89, 218.3)];
    [bezierPath addLineToPoint: CGPointMake(94, 224)];
    [bezierPath addLineToPoint: CGPointMake(102, 230)];
    [bezierPath addLineToPoint: CGPointMake(111, 234.5)];
    [bezierPath addLineToPoint: CGPointMake(120, 238)];
    [bezierPath addLineToPoint: CGPointMake(131, 241.5)];
    [bezierPath addLineToPoint: CGPointMake(143.5, 243.5)];
    [bezierPath addLineToPoint: CGPointMake(155.5, 243.5)];
    [bezierPath addLineToPoint: CGPointMake(166.5, 242.5)];
    [bezierPath addLineToPoint: CGPointMake(176, 240)];
    [bezierPath addLineToPoint: CGPointMake(183.5, 237)];
    [bezierPath addLineToPoint: CGPointMake(193, 232.5)];
    [bezierPath addLineToPoint: CGPointMake(200.5, 227.5)];
    [bezierPath addLineToPoint: CGPointMake(206.5, 223)];
    [bezierPath addLineToPoint: CGPointMake(214.5, 214.5)];
    [bezierPath addLineToPoint: CGPointMake(222.5, 204.5)];
    [bezierPath addLineToPoint: CGPointMake(228, 195)];
    [bezierPath addLineToPoint: CGPointMake(233, 183)];
    [bezierPath addLineToPoint: CGPointMake(235.17, 172.5)];
    [bezierPath moveToPoint: CGPointMake(237.33, 144)];
    [bezierPath addLineToPoint: CGPointMake(235.5, 146)];
    [bezierPath addLineToPoint: CGPointMake(230.5, 151)];
    [bezierPath addLineToPoint: CGPointMake(224.5, 155.5)];
    [bezierPath addLineToPoint: CGPointMake(217, 160.5)];
    [bezierPath addLineToPoint: CGPointMake(210, 165)];
    [bezierPath addLineToPoint: CGPointMake(203, 169)];
    [bezierPath addLineToPoint: CGPointMake(196, 172.5)];
    [bezierPath addLineToPoint: CGPointMake(187, 177)];
    [bezierPath addLineToPoint: CGPointMake(175.5, 182)];
    [bezierPath addLineToPoint: CGPointMake(164, 186)];
    [bezierPath addLineToPoint: CGPointMake(152, 189.5)];
    [bezierPath addLineToPoint: CGPointMake(140.5, 192.5)];
    [bezierPath addLineToPoint: CGPointMake(128.5, 195)];
    [bezierPath addLineToPoint: CGPointMake(116.5, 197)];
    [bezierPath addLineToPoint: CGPointMake(104.5, 198)];
    [bezierPath addLineToPoint: CGPointMake(93, 198.5)];
    [bezierPath addLineToPoint: CGPointMake(84, 198)];
    [bezierPath addLineToPoint: CGPointMake(76.5, 197.5)];
    [bezierPath addLineToPoint: CGPointMake(71, 196.47)];


    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(156, 114.5)];
    [bezier2Path addLineToPoint: CGPointMake(162, 111.5)];
    [bezier2Path addLineToPoint: CGPointMake(171.5, 106)];
    [bezier2Path addLineToPoint: CGPointMake(181, 99)];
    [bezier2Path addLineToPoint: CGPointMake(187.5, 92)];
    [bezier2Path addLineToPoint: CGPointMake(191.5, 85)];
    [bezier2Path addLineToPoint: CGPointMake(194, 79)];
    [bezier2Path moveToPoint: CGPointMake(109.5, 93)];
    [bezier2Path addLineToPoint: CGPointMake(102.5, 92.5)];
    [bezier2Path addLineToPoint: CGPointMake(96.5, 90.5)];
    [bezier2Path addLineToPoint: CGPointMake(91.5, 87.5)];
    [bezier2Path moveToPoint: CGPointMake(120, 91.5)];
    [bezier2Path addLineToPoint: CGPointMake(127.5, 89.5)];
    [bezier2Path addLineToPoint: CGPointMake(135.5, 87)];
    [bezier2Path addLineToPoint: CGPointMake(143.5, 82.5)];
    [bezier2Path addCurveToPoint: CGPointMake(151, 77) controlPoint1: CGPointMake(145.83, 80.83) controlPoint2: CGPointMake(150.6, 77.4)];
    [bezier2Path addCurveToPoint: CGPointMake(155.5, 72) controlPoint1: CGPointMake(151.4, 76.6) controlPoint2: CGPointMake(154.17, 73.5)];
    [bezier2Path addLineToPoint: CGPointMake(157.5, 67.5)];
    [bezier2Path moveToPoint: CGPointMake(97.5, 108.5)];
    [bezier2Path addLineToPoint: CGPointMake(102, 109.5)];
    [bezier2Path addLineToPoint: CGPointMake(109.5, 109.5)];
    [bezier2Path addLineToPoint: CGPointMake(117.5, 108.5)];
    [bezier2Path addLineToPoint: CGPointMake(124.5, 107)];
    [bezier2Path addLineToPoint: CGPointMake(133, 105)];
    [bezier2Path moveToPoint: CGPointMake(103, 128)];
    [bezier2Path addCurveToPoint: CGPointMake(107, 127.5) controlPoint1: CGPointMake(103.4, 128) controlPoint2: CGPointMake(105.83, 127.67)];
    [bezier2Path addLineToPoint: CGPointMake(111.5, 127)];
    [bezier2Path addLineToPoint: CGPointMake(115.5, 126)];
    [bezier2Path moveToPoint: CGPointMake(94.5, 127.5)];
    [bezier2Path addLineToPoint: CGPointMake(87, 127)];
    [bezier2Path addLineToPoint: CGPointMake(80, 124.5)];
    [bezier2Path addCurveToPoint: CGPointMake(73.5, 121.5) controlPoint1: CGPointMake(78, 123.5) controlPoint2: CGPointMake(73.9, 121.5)];
    [bezier2Path addCurveToPoint: CGPointMake(69, 119) controlPoint1: CGPointMake(73.1, 121.5) controlPoint2: CGPointMake(70.33, 119.83)];
    [bezier2Path moveToPoint: CGPointMake(86.5, 166.5)];
    [bezier2Path addLineToPoint: CGPointMake(78.5, 165)];
    [bezier2Path addLineToPoint: CGPointMake(69.5, 161.5)];
    [bezier2Path addLineToPoint: CGPointMake(60.5, 156)];
    [bezier2Path moveToPoint: CGPointMake(106.5, 166.5)];
    [bezier2Path addLineToPoint: CGPointMake(112, 166.5)];
    [bezier2Path addLineToPoint: CGPointMake(116.5, 166)];
    [bezier2Path addLineToPoint: CGPointMake(125.5, 164.5)];
    [bezier2Path addLineToPoint: CGPointMake(136, 162)];
    [bezier2Path addLineToPoint: CGPointMake(145.5, 159.5)];
    [bezier2Path addLineToPoint: CGPointMake(155, 156.5)];
    [bezier2Path addLineToPoint: CGPointMake(164.5, 153.5)];
    [bezier2Path addLineToPoint: CGPointMake(174.5, 149)];
    [bezier2Path addLineToPoint: CGPointMake(184, 144.5)];
    [bezier2Path addLineToPoint: CGPointMake(192, 139.5)];
    [bezier2Path addLineToPoint: CGPointMake(198, 135.5)];
    [bezier2Path addLineToPoint: CGPointMake(203.5, 132)];
    [bezier2Path moveToPoint: CGPointMake(212, 124)];
    [bezier2Path addLineToPoint: CGPointMake(216, 119)];
    [bezier2Path addLineToPoint: CGPointMake(219.5, 113)];
    [bezier2Path addLineToPoint: CGPointMake(222.5, 105.5)];
    [bezier2Path moveToPoint: CGPointMake(125.5, 145)];
    [bezier2Path addLineToPoint: CGPointMake(133.5, 143)];
    [bezier2Path addLineToPoint: CGPointMake(146.5, 139)];
    [bezier2Path addLineToPoint: CGPointMake(155, 136)];
    [bezier2Path addLineToPoint: CGPointMake(164, 132)];
    [bezier2Path addLineToPoint: CGPointMake(171.5, 128.5)];
    [bezier2Path addLineToPoint: CGPointMake(178, 125)];
    [bezier2Path moveToPoint: CGPointMake(86.5, 184)];
    [bezier2Path addLineToPoint: CGPointMake(93.5, 184.5)];
    [bezier2Path addLineToPoint: CGPointMake(101, 184.5)];
    [bezier2Path addLineToPoint: CGPointMake(109, 183.5)];
    [bezier2Path moveToPoint: CGPointMake(190.5, 159.5)];
    [bezier2Path addLineToPoint: CGPointMake(196.5, 157.5)];
    [bezier2Path addLineToPoint: CGPointMake(204, 153)];
    [bezier2Path addLineToPoint: CGPointMake(213, 146)];
    [bezier2Path addLineToPoint: CGPointMake(219, 141.5)];
    [bezier2Path addLineToPoint: CGPointMake(223, 137)];
    [bezier2Path moveToPoint: CGPointMake(167, 213.5)];
    [bezier2Path addLineToPoint: CGPointMake(171.5, 212.5)];
    [bezier2Path addLineToPoint: CGPointMake(180.5, 209)];
    [bezier2Path addLineToPoint: CGPointMake(188.5, 205.5)];
    [bezier2Path addLineToPoint: CGPointMake(195, 202.5)];
    [bezier2Path addLineToPoint: CGPointMake(201, 199.5)];
    [bezier2Path addLineToPoint: CGPointMake(203.5, 196.5)];
    [bezier2Path moveToPoint: CGPointMake(208.5, 209)];
    [bezier2Path addLineToPoint: CGPointMake(214.5, 205.5)];
    [bezier2Path addLineToPoint: CGPointMake(220, 201.5)];
    [bezier2Path addLineToPoint: CGPointMake(227.5, 194)];
    [bezier2Path moveToPoint: CGPointMake(198, 215)];
    [bezier2Path addLineToPoint: CGPointMake(190.5, 218.5)];
    [bezier2Path addLineToPoint: CGPointMake(180, 222.5)];
    [bezier2Path addLineToPoint: CGPointMake(170, 226)];
    [bezier2Path addLineToPoint: CGPointMake(159, 229)];
    [bezier2Path addLineToPoint: CGPointMake(148.5, 231.5)];
    [bezier2Path addLineToPoint: CGPointMake(134.5, 233)];
    [bezier2Path addLineToPoint: CGPointMake(121, 233.5)];
    [bezier2Path addLineToPoint: CGPointMake(109.5, 233)];



    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(252.5, 181)];
    [bezier3Path addLineToPoint: CGPointMake(257.5, 177.5)];
    [bezier3Path addLineToPoint: CGPointMake(264.5, 178)];
    [bezier3Path addLineToPoint: CGPointMake(269, 181.5)];
    [bezier3Path addLineToPoint: CGPointMake(270.5, 186.5)];
    [bezier3Path addLineToPoint: CGPointMake(269.5, 191)];
    [bezier3Path addLineToPoint: CGPointMake(266.5, 195.5)];
    [bezier3Path addLineToPoint: CGPointMake(261.5, 197)];
    [bezier3Path addLineToPoint: CGPointMake(255.5, 196)];
    [bezier3Path addLineToPoint: CGPointMake(251.5, 192)];
    [bezier3Path addLineToPoint: CGPointMake(250, 187)];
    [bezier3Path addLineToPoint: CGPointMake(252.5, 181)];
    [bezier3Path closePath];
    
    [bezier3Path moveToPoint: CGPointMake(240, 211)];
    [bezier3Path addLineToPoint: CGPointMake(242, 209)];
    [bezier3Path addLineToPoint: CGPointMake(244.5, 209)];
    [bezier3Path addLineToPoint: CGPointMake(246.5, 210.5)];
    [bezier3Path addLineToPoint: CGPointMake(247, 213)];
    [bezier3Path addLineToPoint: CGPointMake(246, 215)];
    [bezier3Path addLineToPoint: CGPointMake(243.5, 216)];
    [bezier3Path addLineToPoint: CGPointMake(241, 215.5)];
    [bezier3Path addLineToPoint: CGPointMake(239.5, 213.5)];
    [bezier3Path addLineToPoint: CGPointMake(240, 211)];
    [bezier3Path closePath];

    [bezier3Path moveToPoint: CGPointMake(74.5, 242)];
    [bezier3Path addLineToPoint: CGPointMake(76.5, 241)];
    [bezier3Path addLineToPoint: CGPointMake(79.5, 242)];
    [bezier3Path addCurveToPoint: CGPointMake(81, 244.5) controlPoint1: CGPointMake(80, 242.67) controlPoint2: CGPointMake(81, 244.1)];
    [bezier3Path addCurveToPoint: CGPointMake(81, 247.5) controlPoint1: CGPointMake(81, 244.9) controlPoint2: CGPointMake(81.17, 246.83)];
    [bezier3Path addLineToPoint: CGPointMake(78.5, 249)];
    [bezier3Path addLineToPoint: CGPointMake(75, 249)];
    [bezier3Path addLineToPoint: CGPointMake(73.5, 247)];
    [bezier3Path addLineToPoint: CGPointMake(73, 244.5)];
    [bezier3Path addLineToPoint: CGPointMake(74.5, 242)];
    [bezier3Path closePath];

    [bezier3Path moveToPoint: CGPointMake(35.5, 76.5)];
    [bezier3Path addCurveToPoint: CGPointMake(41.5, 72) controlPoint1: CGPointMake(37.33, 75) controlPoint2: CGPointMake(41.1, 72)];
    [bezier3Path addLineToPoint: CGPointMake(48, 71)];
    [bezier3Path addLineToPoint: CGPointMake(54.5, 73)];
    [bezier3Path addLineToPoint: CGPointMake(60.5, 80)];
    [bezier3Path addLineToPoint: CGPointMake(61, 89.5)];
    [bezier3Path addLineToPoint: CGPointMake(57, 97)];
    [bezier3Path addLineToPoint: CGPointMake(48.5, 101)];
    [bezier3Path addLineToPoint: CGPointMake(39.5, 99)];
    [bezier3Path addLineToPoint: CGPointMake(33.5, 94.5)];
    [bezier3Path addLineToPoint: CGPointMake(31.5, 85.5)];
    [bezier3Path addLineToPoint: CGPointMake(35.5, 76.5)];
    [bezier3Path closePath];

    [bezier3Path moveToPoint: CGPointMake(217, 51)];
    [bezier3Path addCurveToPoint: CGPointMake(222.5, 50) controlPoint1: CGPointMake(218, 50.67) controlPoint2: CGPointMake(222.1, 50)];
    [bezier3Path addLineToPoint: CGPointMake(227, 53)];
    [bezier3Path addLineToPoint: CGPointMake(227.5, 58)];
    [bezier3Path addLineToPoint: CGPointMake(225.5, 62)];
    [bezier3Path addLineToPoint: CGPointMake(220.5, 63.5)];
    [bezier3Path addLineToPoint: CGPointMake(215.5, 61)];
    [bezier3Path addLineToPoint: CGPointMake(214, 55.5)];
    [bezier3Path addLineToPoint: CGPointMake(217, 51)];
    [bezier3Path closePath];

    NSArray<UIBezierPath*> *bezierPathArray = [[NSArray alloc] initWithObjects:bezierPath, bezier2Path, bezier3Path, nil];
    CAShapeLayer *masterLayer = [self createShapeLayerWithBezierPathArray:bezierPathArray];
    [self.canvasView.layer addSublayer:masterLayer];
    [self drawShape:masterLayer];
}



-(void)drawLandscape {
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(237.35, 135.88)];
    [bezierPath addLineToPoint: CGPointMake(243.09, 144.26)];
    [bezierPath addLineToPoint: CGPointMake(254.12, 155.29)];
    [bezierPath addLineToPoint: CGPointMake(253.24, 140.74)];
    [bezierPath addLineToPoint: CGPointMake(251.03, 127.06)];
    [bezierPath addLineToPoint: CGPointMake(246.62, 115.15)];
    [bezierPath addLineToPoint: CGPointMake(243.09, 107.65)];
    [bezierPath addLineToPoint: CGPointMake(239.56, 101.03)];
    [bezierPath addLineToPoint: CGPointMake(234.26, 93.53)];
    [bezierPath addLineToPoint: CGPointMake(229.85, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(227.65, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(224.12, 93.53)];
    [bezierPath addLineToPoint: CGPointMake(220.59, 94.85)];
    [bezierPath addLineToPoint: CGPointMake(217.5, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(214.85, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(211.32, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(206.91, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(202.94, 94.85)];
    [bezierPath addLineToPoint: CGPointMake(200.29, 93.53)];
    [bezierPath addLineToPoint: CGPointMake(196.76, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(193.24, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(187.06, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(181.32, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(178.68, 93.53)];
    [bezierPath addLineToPoint: CGPointMake(172.94, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(167.65, 92.21)];
    [bezierPath addLineToPoint: CGPointMake(164.12, 91.32)];
    [bezierPath addLineToPoint: CGPointMake(159.26, 93.09)];
    [bezierPath addLineToPoint: CGPointMake(156.18, 91.32)];
    [bezierPath addLineToPoint: CGPointMake(150, 91.32)];
    [bezierPath addLineToPoint: CGPointMake(154.85, 90)];
    [bezierPath addLineToPoint: CGPointMake(157.94, 87.35)];
    [bezierPath addLineToPoint: CGPointMake(159.26, 85.59)];
    [bezierPath addLineToPoint: CGPointMake(161.91, 83.38)];
    [bezierPath addLineToPoint: CGPointMake(164.12, 80.29)];
    [bezierPath addLineToPoint: CGPointMake(167.65, 80.29)];
    [bezierPath addLineToPoint: CGPointMake(174.26, 80.29)];
    [bezierPath addLineToPoint: CGPointMake(179.12, 80.29)];
    [bezierPath addLineToPoint: CGPointMake(183.53, 77.65)];
    [bezierPath addLineToPoint: CGPointMake(185.29, 74.12)];
    [bezierPath addLineToPoint: CGPointMake(191.03, 73.24)];
    [bezierPath addLineToPoint: CGPointMake(194.12, 75.44)];
    [bezierPath addLineToPoint: CGPointMake(197.65, 74.12)];
    [bezierPath addLineToPoint: CGPointMake(201.18, 75.44)];
    [bezierPath addLineToPoint: CGPointMake(202.94, 71.91)];
    [bezierPath addLineToPoint: CGPointMake(206.91, 70.15)];
    [bezierPath addLineToPoint: CGPointMake(212.21, 70.15)];
    [bezierPath addLineToPoint: CGPointMake(202.94, 63.53)];
    [bezierPath addLineToPoint: CGPointMake(191.03, 56.91)];
    [bezierPath addLineToPoint: CGPointMake(175.59, 50.74)];
    [bezierPath addLineToPoint: CGPointMake(157.94, 47.21)];
    [bezierPath addLineToPoint: CGPointMake(144.26, 46.32)];
    [bezierPath addLineToPoint: CGPointMake(129.26, 47.21)];
    [bezierPath addLineToPoint: CGPointMake(114.71, 49.41)];
    [bezierPath addLineToPoint: CGPointMake(103.24, 53.82)];
    [bezierPath addLineToPoint: CGPointMake(93.09, 58.24)];
    [bezierPath addLineToPoint: CGPointMake(97.94, 60.88)];
    [bezierPath addLineToPoint: CGPointMake(101.47, 64.41)];
    [bezierPath addLineToPoint: CGPointMake(104.12, 69.26)];
    [bezierPath addLineToPoint: CGPointMake(104.56, 74.12)];
    [bezierPath addLineToPoint: CGPointMake(101.47, 81.18)];
    [bezierPath addLineToPoint: CGPointMake(96.62, 85.59)];
    [bezierPath addLineToPoint: CGPointMake(93.09, 87.35)];
    [bezierPath addLineToPoint: CGPointMake(89.12, 87.35)];
    [bezierPath addLineToPoint: CGPointMake(82.94, 84.71)];
    [bezierPath addLineToPoint: CGPointMake(78.53, 81.18)];
    [bezierPath addLineToPoint: CGPointMake(75.44, 75.44)];
    [bezierPath addLineToPoint: CGPointMake(75.44, 70.15)];
    [bezierPath addLineToPoint: CGPointMake(64.41, 79.85)];
    [bezierPath addLineToPoint: CGPointMake(56.91, 88.68)];
    [bezierPath addLineToPoint: CGPointMake(50.29, 98.82)];
    [bezierPath addLineToPoint: CGPointMake(45.44, 108.53)];
    [bezierPath addLineToPoint: CGPointMake(44.12, 113.82)];
    [bezierPath addLineToPoint: CGPointMake(47.21, 113.82)];
    [bezierPath addLineToPoint: CGPointMake(50.29, 112.94)];
    [bezierPath addLineToPoint: CGPointMake(56.03, 116.47)];
    [bezierPath addLineToPoint: CGPointMake(61.32, 116.47)];
    [bezierPath addLineToPoint: CGPointMake(66.62, 120.88)];
    [bezierPath addLineToPoint: CGPointMake(69.71, 120)];
    [bezierPath addLineToPoint: CGPointMake(74.12, 122.21)];
    [bezierPath addLineToPoint: CGPointMake(71.91, 123.09)];
    [bezierPath addLineToPoint: CGPointMake(66.62, 124.41)];
    [bezierPath addLineToPoint: CGPointMake(62.21, 123.53)];
    [bezierPath addLineToPoint: CGPointMake(60.44, 124.41)];
    [bezierPath addLineToPoint: CGPointMake(56.91, 124.41)];
    [bezierPath addLineToPoint: CGPointMake(54.26, 124.41)];
    [bezierPath addLineToPoint: CGPointMake(52.5, 126.18)];
    [bezierPath addLineToPoint: CGPointMake(50.74, 125.29)];
    [bezierPath addLineToPoint: CGPointMake(48.97, 125.29)];
    [bezierPath addLineToPoint: CGPointMake(44.12, 123.09)];
    [bezierPath addLineToPoint: CGPointMake(39.26, 125.29)];
    [bezierPath addLineToPoint: CGPointMake(37.06, 132.79)];
    [bezierPath addLineToPoint: CGPointMake(35.29, 155.74)];
    [bezierPath addLineToPoint: CGPointMake(39.26, 182.21)];
    [bezierPath addLineToPoint: CGPointMake(45.44, 176.03)];
    [bezierPath addLineToPoint: CGPointMake(50.29, 172.5)];
    [bezierPath addLineToPoint: CGPointMake(60.44, 161.47)];
    [bezierPath addLineToPoint: CGPointMake(69.71, 151.32)];
    [bezierPath moveToPoint: CGPointMake(237.35, 135.88)];
    [bezierPath addLineToPoint: CGPointMake(227.65, 140.74)];
    [bezierPath moveToPoint: CGPointMake(237.35, 135.88)];
    [bezierPath addLineToPoint: CGPointMake(235.74, 144.26)];
    [bezierPath addLineToPoint: CGPointMake(235.74, 154.41)];
    [bezierPath moveToPoint: CGPointMake(227.65, 140.74)];
    [bezierPath addLineToPoint: CGPointMake(217.5, 120)];
    [bezierPath addLineToPoint: CGPointMake(210, 113.38)];
    [bezierPath addLineToPoint: CGPointMake(202.94, 122.21)];
    [bezierPath addLineToPoint: CGPointMake(193.24, 133.24)];
    [bezierPath addLineToPoint: CGPointMake(189.26, 131.03)];
    [bezierPath addLineToPoint: CGPointMake(174.26, 146.91)];
    [bezierPath addLineToPoint: CGPointMake(161.91, 165)];
    [bezierPath moveToPoint: CGPointMake(227.65, 140.74)];
    [bezierPath addLineToPoint: CGPointMake(231.18, 146.91)];
    [bezierPath addLineToPoint: CGPointMake(235.74, 154.41)];
    [bezierPath moveToPoint: CGPointMake(161.91, 165)];
    [bezierPath addLineToPoint: CGPointMake(154.85, 157.06)];
    [bezierPath addLineToPoint: CGPointMake(136.76, 139.41)];
    [bezierPath addLineToPoint: CGPointMake(130.15, 122.21)];
    [bezierPath addLineToPoint: CGPointMake(126.18, 122.21)];
    [bezierPath addLineToPoint: CGPointMake(120.44, 113.38)];
    [bezierPath moveToPoint: CGPointMake(161.91, 165)];
    [bezierPath addLineToPoint: CGPointMake(161.91, 167.21)];
    [bezierPath addLineToPoint: CGPointMake(165, 170.29)];
    [bezierPath addLineToPoint: CGPointMake(171.4, 176.69)];
    [bezierPath moveToPoint: CGPointMake(120.44, 113.38)];
    [bezierPath addLineToPoint: CGPointMake(110.29, 120.88)];
    [bezierPath addLineToPoint: CGPointMake(107.21, 127.06)];
    [bezierPath addLineToPoint: CGPointMake(97.5, 138.09)];
    [bezierPath addLineToPoint: CGPointMake(92.21, 135.88)];
    [bezierPath moveToPoint: CGPointMake(120.44, 113.38)];
    [bezierPath addLineToPoint: CGPointMake(116.91, 120)];
    [bezierPath addLineToPoint: CGPointMake(115.59, 127.06)];
    [bezierPath moveToPoint: CGPointMake(92.21, 135.88)];
    [bezierPath addLineToPoint: CGPointMake(78.53, 153.53)];
    [bezierPath addLineToPoint: CGPointMake(69.71, 151.32)];
    [bezierPath moveToPoint: CGPointMake(92.21, 135.88)];
    [bezierPath addLineToPoint: CGPointMake(92.21, 146.91)];
    [bezierPath addLineToPoint: CGPointMake(93.97, 157.06)];
    [bezierPath moveToPoint: CGPointMake(69.71, 151.32)];
    [bezierPath addLineToPoint: CGPointMake(72.79, 156.62)];
    [bezierPath addLineToPoint: CGPointMake(74.12, 162.79)];
    [bezierPath addLineToPoint: CGPointMake(74.12, 171.18)];
    [bezierPath addLineToPoint: CGPointMake(78.53, 179.56)];
    [bezierPath moveToPoint: CGPointMake(177.79, 183.09)];
    [bezierPath addLineToPoint: CGPointMake(171.4, 176.69)];
    [bezierPath moveToPoint: CGPointMake(245.74, 172.06)];
    [bezierPath addLineToPoint: CGPointMake(237.35, 157.06)];
    [bezierPath addLineToPoint: CGPointMake(235.74, 154.41)];
    [bezierPath moveToPoint: CGPointMake(171.4, 176.69)];
    [bezierPath addLineToPoint: CGPointMake(183.53, 172.5)];
    [bezierPath addLineToPoint: CGPointMake(184.55, 173.82)];
    [bezierPath moveToPoint: CGPointMake(191.03, 182.21)];
    [bezierPath addLineToPoint: CGPointMake(184.55, 173.82)];
    [bezierPath moveToPoint: CGPointMake(184.55, 173.82)];
    [bezierPath addLineToPoint: CGPointMake(191.03, 171.18)];
    [bezierPath addLineToPoint: CGPointMake(196.76, 173.82)];
    [bezierPath addLineToPoint: CGPointMake(205.59, 179.56)];
    [bezierPath addLineToPoint: CGPointMake(214.85, 183.09)];
    [bezierPath addLineToPoint: CGPointMake(222.35, 189.26)];
    [bezierPath addLineToPoint: CGPointMake(227.65, 190.59)];
    [bezierPath addLineToPoint: CGPointMake(241.32, 201.18)];
    [bezierPath moveToPoint: CGPointMake(112.94, 149.12)];
    [bezierPath addLineToPoint: CGPointMake(112.94, 141.62)];
    [bezierPath addLineToPoint: CGPointMake(114.26, 133.24)];

    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(48.97, 206.03)];
    [bezier2Path addLineToPoint: CGPointMake(61.76, 206.03)];
    [bezier2Path addLineToPoint: CGPointMake(74.12, 202.94)];
    [bezier2Path addLineToPoint: CGPointMake(89.56, 194.56)];
    [bezier2Path addLineToPoint: CGPointMake(104.56, 190.15)];
    [bezier2Path addLineToPoint: CGPointMake(118.68, 195.88)];
    [bezier2Path addLineToPoint: CGPointMake(129.93, 200.96)];
    [bezier2Path moveToPoint: CGPointMake(141.18, 206.03)];
    [bezier2Path addLineToPoint: CGPointMake(129.93, 200.96)];
    [bezier2Path moveToPoint: CGPointMake(129.93, 200.96)];
    [bezier2Path addLineToPoint: CGPointMake(141.18, 197.65)];
    [bezier2Path addLineToPoint: CGPointMake(150, 198.97)];
    [bezier2Path addLineToPoint: CGPointMake(158.38, 200.96)];
    [bezier2Path addLineToPoint: CGPointMake(170.29, 202.94)];
    [bezier2Path addLineToPoint: CGPointMake(189.71, 209.56)];
    [bezier2Path moveToPoint: CGPointMake(181.32, 211.76)];
    [bezier2Path addLineToPoint: CGPointMake(192.35, 209.56)];
    [bezier2Path addLineToPoint: CGPointMake(201.62, 204.71)];
    [bezier2Path addLineToPoint: CGPointMake(213.97, 204.71)];
    [bezier2Path addLineToPoint: CGPointMake(226.76, 204.71)];
    [bezier2Path addLineToPoint: CGPointMake(244.41, 200.96)];
    [bezier2Path moveToPoint: CGPointMake(67.5, 230.74)];
    [bezier2Path addLineToPoint: CGPointMake(79.85, 230.74)];
    [bezier2Path addLineToPoint: CGPointMake(94.85, 227.65)];
    [bezier2Path addLineToPoint: CGPointMake(109.85, 230.74)];
    [bezier2Path addLineToPoint: CGPointMake(131.47, 233.38)];
    [bezier2Path addLineToPoint: CGPointMake(170.29, 237.35)];
    [bezier2Path moveToPoint: CGPointMake(141.18, 245.74)];
    [bezier2Path addLineToPoint: CGPointMake(161.91, 240.44)];
    [bezier2Path addLineToPoint: CGPointMake(181.32, 230.74)];
    [bezier2Path addLineToPoint: CGPointMake(192.35, 225)];
    [bezier2Path addLineToPoint: CGPointMake(208.68, 225)];
    [bezier2Path addLineToPoint: CGPointMake(228.09, 225)];
    [bezier2Path moveToPoint: CGPointMake(93.53, 251.47)];
    [bezier2Path addLineToPoint: CGPointMake(104.56, 249.26)];
    [bezier2Path addLineToPoint: CGPointMake(126.18, 251.47)];
    [bezier2Path addLineToPoint: CGPointMake(150.88, 252.35)];
    [bezier2Path addLineToPoint: CGPointMake(170.29, 252.35)];
    [bezier2Path addLineToPoint: CGPointMake(189.71, 245.74)];
    [bezier2Path addLineToPoint: CGPointMake(210, 243.53)];

    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(108.97, 152.65)];
    [bezier3Path addLineToPoint: CGPointMake(110.74, 158.38)];
    [bezier3Path addLineToPoint: CGPointMake(111.62, 168.09)];
    [bezier3Path addLineToPoint: CGPointMake(109.41, 184.41)];
    [bezier3Path addLineToPoint: CGPointMake(106.32, 199.85)];
    [bezier3Path addLineToPoint: CGPointMake(106.76, 208.24)];
    [bezier3Path addLineToPoint: CGPointMake(109.41, 215.29)];
    [bezier3Path moveToPoint: CGPointMake(113.38, 215.29)];
    [bezier3Path addLineToPoint: CGPointMake(114.26, 205.15)];
    [bezier3Path moveToPoint: CGPointMake(115.15, 201.62)];
    [bezier3Path addLineToPoint: CGPointMake(114.26, 191.03)];
    [bezier3Path addLineToPoint: CGPointMake(113.38, 183.97)];
    [bezier3Path addLineToPoint: CGPointMake(112.5, 177.35)];
    [bezier3Path moveToPoint: CGPointMake(120, 172.5)];
    [bezier3Path addLineToPoint: CGPointMake(121.76, 179.56)];
    [bezier3Path addLineToPoint: CGPointMake(123.09, 188.82)];
    [bezier3Path moveToPoint: CGPointMake(124.41, 180.44)];
    [bezier3Path addLineToPoint: CGPointMake(124.85, 185.74)];
    [bezier3Path addLineToPoint: CGPointMake(127.06, 193.68)];
    [bezier3Path addLineToPoint: CGPointMake(129.26, 198.97)];
    [bezier3Path moveToPoint: CGPointMake(127.94, 188.82)];
    [bezier3Path addLineToPoint: CGPointMake(128.38, 192.79)];
    [bezier3Path addLineToPoint: CGPointMake(131.47, 198.09)];
    [bezier3Path moveToPoint: CGPointMake(139.41, 178.24)];
    [bezier3Path addLineToPoint: CGPointMake(140.29, 184.41)];
    [bezier3Path addLineToPoint: CGPointMake(141.62, 190.59)];
    [bezier3Path addLineToPoint: CGPointMake(143.82, 195.44)];
    [bezier3Path moveToPoint: CGPointMake(146.91, 196.76)];
    [bezier3Path addLineToPoint: CGPointMake(144.26, 191.47)];
    [bezier3Path addLineToPoint: CGPointMake(142.94, 187.06)];
    [bezier3Path addLineToPoint: CGPointMake(142.5, 182.65)];
    [bezier3Path moveToPoint: CGPointMake(140.29, 190.59)];
    [bezier3Path addLineToPoint: CGPointMake(138.53, 185.29)];
    [bezier3Path addLineToPoint: CGPointMake(137.65, 180)];
    [bezier3Path addLineToPoint: CGPointMake(137.21, 172.94)];
    [bezier3Path addLineToPoint: CGPointMake(137.65, 166.76)];
    [bezier3Path moveToPoint: CGPointMake(87.35, 157.5)];
    [bezier3Path addLineToPoint: CGPointMake(85.15, 164.12)];
    [bezier3Path addLineToPoint: CGPointMake(84.26, 170.29)];
    [bezier3Path addLineToPoint: CGPointMake(84.26, 177.35)];
    [bezier3Path moveToPoint: CGPointMake(82.5, 172.5)];
    [bezier3Path addLineToPoint: CGPointMake(82.94, 165.44)];
    [bezier3Path addLineToPoint: CGPointMake(85.15, 157.5)];
    [bezier3Path addLineToPoint: CGPointMake(88.24, 150.88)];
    [bezier3Path moveToPoint: CGPointMake(90.44, 141.18)];
    [bezier3Path addLineToPoint: CGPointMake(86.91, 146.47)];
    [bezier3Path addLineToPoint: CGPointMake(84.26, 151.76)];
    [bezier3Path moveToPoint: CGPointMake(51.62, 177.35)];
    [bezier3Path addLineToPoint: CGPointMake(49.85, 184.41)];
    [bezier3Path addLineToPoint: CGPointMake(47.21, 191.03)];
    [bezier3Path addLineToPoint: CGPointMake(44.56, 195.88)];
    [bezier3Path moveToPoint: CGPointMake(54.26, 177.35)];
    [bezier3Path addLineToPoint: CGPointMake(52.5, 183.97)];
    [bezier3Path addLineToPoint: CGPointMake(49.41, 191.91)];
    [bezier3Path moveToPoint: CGPointMake(55.59, 170.29)];
    [bezier3Path addLineToPoint: CGPointMake(54.71, 175.15)];
    [bezier3Path moveToPoint: CGPointMake(67.5, 158.38)];
    [bezier3Path addLineToPoint: CGPointMake(65.29, 166.76)];
    [bezier3Path moveToPoint: CGPointMake(66.62, 169.41)];
    [bezier3Path addLineToPoint: CGPointMake(65.29, 175.15)];
    [bezier3Path addLineToPoint: CGPointMake(64.85, 181.76)];
    [bezier3Path moveToPoint: CGPointMake(63.97, 171.62)];
    [bezier3Path addLineToPoint: CGPointMake(63.09, 180)];
    [bezier3Path moveToPoint: CGPointMake(72.79, 182.65)];
    [bezier3Path addLineToPoint: CGPointMake(73.24, 187.94)];
    [bezier3Path moveToPoint: CGPointMake(74.56, 188.82)];
    [bezier3Path addLineToPoint: CGPointMake(74.56, 201.62)];
    [bezier3Path moveToPoint: CGPointMake(88.24, 171.62)];
    [bezier3Path addLineToPoint: CGPointMake(88.68, 181.32)];
    [bezier3Path addLineToPoint: CGPointMake(89.56, 188.82)];
    [bezier3Path moveToPoint: CGPointMake(186.62, 142.06)];
    [bezier3Path addLineToPoint: CGPointMake(187.06, 146.03)];
    [bezier3Path addLineToPoint: CGPointMake(189.26, 151.76)];
    [bezier3Path addLineToPoint: CGPointMake(189.74, 153.97)];
    [bezier3Path moveToPoint: CGPointMake(189.26, 164.56)];
    [bezier3Path addLineToPoint: CGPointMake(190.59, 157.94)];
    [bezier3Path addLineToPoint: CGPointMake(189.74, 153.97)];
    [bezier3Path moveToPoint: CGPointMake(190.59, 141.62)];
    [bezier3Path addLineToPoint: CGPointMake(190.15, 146.91)];
    [bezier3Path addLineToPoint: CGPointMake(189.74, 153.97)];
    [bezier3Path moveToPoint: CGPointMake(200.74, 135.44)];
    [bezier3Path addLineToPoint: CGPointMake(198.97, 142.06)];
    [bezier3Path addLineToPoint: CGPointMake(197.21, 148.68)];
    [bezier3Path moveToPoint: CGPointMake(217.06, 144.71)];
    [bezier3Path addLineToPoint: CGPointMake(218.38, 153.09)];
    [bezier3Path addLineToPoint: CGPointMake(223.68, 164.56)];
    [bezier3Path moveToPoint: CGPointMake(198.97, 183.97)];
    [bezier3Path addLineToPoint: CGPointMake(202.94, 190.59)];
    [bezier3Path addLineToPoint: CGPointMake(207.35, 195.44)];
    [bezier3Path moveToPoint: CGPointMake(197.21, 195.88)];
    [bezier3Path addLineToPoint: CGPointMake(192.35, 192.79)];
    [bezier3Path moveToPoint: CGPointMake(241.32, 150.88)];
    [bezier3Path addLineToPoint: CGPointMake(241.32, 153.97)];
    [bezier3Path moveToPoint: CGPointMake(245.29, 153.09)];
    [bezier3Path addLineToPoint: CGPointMake(245.29, 157.5)];
    [bezier3Path addLineToPoint: CGPointMake(247.5, 161.03)];
    [bezier3Path moveToPoint: CGPointMake(123.09, 137.65)];
    [bezier3Path addLineToPoint: CGPointMake(124.85, 146.03)];
    [bezier3Path addLineToPoint: CGPointMake(129.26, 148.68)];
    [bezier3Path addLineToPoint: CGPointMake(131.47, 153.97)];
    [bezier3Path moveToPoint: CGPointMake(210.88, 120.44)];
    [bezier3Path addLineToPoint: CGPointMake(212.65, 123.53)];
    [bezier3Path addLineToPoint: CGPointMake(212.65, 127.06)];
    [bezier3Path moveToPoint: CGPointMake(207.35, 125.74)];
    [bezier3Path addLineToPoint: CGPointMake(206.03, 134.56)];
    [bezier3Path moveToPoint: CGPointMake(214.85, 190.59)];
    [bezier3Path addLineToPoint: CGPointMake(217.06, 191.91)];
    [bezier3Path addLineToPoint: CGPointMake(221.47, 193.68)];
    [bezier3Path addLineToPoint: CGPointMake(228.97, 199.85)];
    [bezier3Path moveToPoint: CGPointMake(158.38, 171.62)];
    [bezier3Path addLineToPoint: CGPointMake(160.59, 177.35)];
    [bezier3Path addLineToPoint: CGPointMake(166.32, 183.97)];

    NSArray<UIBezierPath*> *bezierPathArray = [[NSArray alloc] initWithObjects:bezierPath, bezier2Path, bezier3Path, nil];
    
    CAShapeLayer *masterLayer = [self createShapeLayerWithBezierPathArray:bezierPathArray];

    [self.canvasView.layer addSublayer:masterLayer];
    [self drawShape:masterLayer];
}



@end



