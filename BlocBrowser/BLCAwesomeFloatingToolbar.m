//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Roshan Mahanama on 14/04/2015.
//  Copyright (c) 2015 RMTREKS. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;



@end



@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    
    self = [super init]; // what does this line mean?
    
    if (self) { // is this line basically checking that self isn't nil?
        
        // save the titles and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // making the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.alpha = 0.25;

            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex]; // why did we need this. Isn't this circular? We already get this value in currentTitle
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.backgroundColor = colorForThisLabel;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            [buttonsArray addObject:button];

            
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [thisButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview: thisButton];
        }
    }
    
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
    [self addGestureRecognizer:self.longPressGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchFired:)];
    [self addGestureRecognizer:self.pinchGesture];
    
    return self;
}




- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self]; // keeps resetting to 0. Does this means if a user is moving the toolbar from say bottom right to top left, this method needs to be called multiple times?
    }
    }


- (void) longPressFired: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
           
        NSMutableArray *currentColorsArray = [[NSMutableArray alloc] init];

        for (UIButton *thisButton in self.buttons) {
            UIColor *labelColor;
            labelColor = thisButton.backgroundColor;
            [currentColorsArray addObject:labelColor];
        }
        
     
        for (int i = 0; i <= self.buttons.count -1; i++) {
            UIButton *thisButton = self.buttons[i];
            int j = (i+1) % currentColorsArray.count;
            thisButton.backgroundColor = currentColorsArray[j];
            NSLog(@"%d", i);
        }

        
 
        
    }
}


- (void) pinchFired: (UIPinchGestureRecognizer *)recognizer {
   
    
    
    NSLog(@"pinch fired");
    CGFloat pinchScale = recognizer.scale;
    NSLog(@"pinchScale is %f",pinchScale);
    [self.delegate floatingToolbar:self didPinch:pinchScale];
    
}


- (void) layoutSubviews {
    // set the frames for the 4 labels
    // in the checkpoint notes it says - layoutSubviews will get called any time our view's frame is changed.
    // why is this the case?
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        // could this have been done using a Switch statement?
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}



# pragma mark - Touch Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview; // how did subview which was a UIView become a UILabel? => Casting.
}




- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}




# pragma mark - Button Actions

- (void) buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(buttonPressed:)]) {
    [self.delegate buttonPressed:sender];
    }
}


@end
