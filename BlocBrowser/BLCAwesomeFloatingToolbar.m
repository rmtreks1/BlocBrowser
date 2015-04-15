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
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;


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
        
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // making the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init]; // why are we creating a new object every time, why can't we just change the value?
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex]; // why did we need this. Isn't this circular? We already get this value in currentTitle
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
            
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview: thisLabel];
        }
    }
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    [self addGestureRecognizer:self.tapGesture];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
    [self addGestureRecognizer:self.longPressGesture];
    
    return self;
}


- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
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
        
        // code for testing
        NSLog(@"long press began");
        NSLog(@"labels has %lu", self.labels.count);
        
        NSMutableArray *currentColorsArray = [[NSMutableArray alloc] init];

        for (UILabel *thisLabel in self.labels) {
            UIColor *labelColor;
            labelColor = thisLabel.backgroundColor;
            [currentColorsArray addObject:labelColor];
        }
        
       
        
        NSLog(@"current colors array has %lu", (unsigned long)currentColorsArray.count); // just for testing

        UILabel *thisLabel1 = self.labels[0];
        thisLabel1.backgroundColor = currentColorsArray[1];
        UILabel *thisLabel2 = self.labels[1];
        thisLabel2.backgroundColor = currentColorsArray[2];
        UILabel *thisLabel3 = self.labels[2];
        thisLabel3.backgroundColor = currentColorsArray[3];
        UILabel *thisLabel4 = self.labels[3];
        thisLabel4.backgroundColor = currentColorsArray[0];


        
        
        
        
//        
//        for (int i = 0; i < self.labels.count -2; i++) {
//            UILabel *thisLabel = self.labels[i];
//            UIColor *thisColor = currentColorsArray[i+1];
//            thisLabel.backgroundColor = thisColor;
//        }
//
//        
//        for (UILabel *thisLabel in self.labels) {
//            UILabel *nextLabel = self.labels[2];
//            thisLabel.backgroundColor = nextLabel.backgroundColor;
//        }

        
    }
}



- (void) layoutSubviews {
    // set the frames for the 4 labels
    // in the checkpoint notes it says - layoutSubviews will get called any time our view's frame is changed.
    // why is this the case?
    
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
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
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
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
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}







@end
