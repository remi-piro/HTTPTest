//
//  FlipImageBrowser.m
//  HTTPTest
//
//  Created by Remi on 13/02/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#import "FlipImageBrowser.h"

#define VERTICAL_GAP 10.0f
#define HORIZONTAL_GAP 10.0f
#define VISIBLE_SIZE 20.0f

@interface FlipImageBrowser ()
{
    UIImageView *leftImageView_;
    UIImageView *mainImageView_;
    UIImageView *rightImageView_;
    
    NSUInteger position_;
    CGFloat origin_;
    CGFloat offset_;
    
    NSMutableArray *imagesArray_;
}

@end

@implementation FlipImageBrowser

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        imagesArray_ = [NSMutableArray arrayWithCapacity:10];
    }
    return self;    
}

- (void)addImagesToTheLeft:(NSArray *)images
{
    [imagesArray_ addObjectsFromArray:images];
    position_ = images.count/2;
    
    [self updateImageBrowser];
}

- (void)addImagesToTheRight:(NSArray *)images
{
    [imagesArray_ addObjectsFromArray:images];    
    position_ = images.count/2;
    
    [self updateImageBrowser];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self layoutImages];
}

- (CGFloat)verticalGap:(CGFloat)position
{
    CGFloat a, b;
    
    if (position < (HORIZONTAL_GAP + VISIBLE_SIZE)) {
        a = -VERTICAL_GAP / (self.frame.size.width + HORIZONTAL_GAP);
    }
    else {
        a = VERTICAL_GAP / (self.frame.size.width - HORIZONTAL_GAP - 2 * VISIBLE_SIZE);
    }
    
    b = -a * (HORIZONTAL_GAP + VISIBLE_SIZE);
    
    return a * position + b;
}

- (void)layoutImages
{
    if (mainImageView_ == nil) return;
    
    NSUInteger xSpace = VISIBLE_SIZE + HORIZONTAL_GAP;
    /*
    leftImageView_.frame = CGRectMake(offset_ + VISIBLE_SIZE - self.frame.size.width, VERTICAL_GAP, self.frame.size.width, self.frame.size.height - VERTICAL_GAP * 2);
    mainImageView_.frame = CGRectMake(offset_ + xSpace, 0, self.frame.size.width - xSpace * 2, self.frame.size.height);
    rightImageView_.frame = CGRectMake(offset_ + self.frame.size.width - VISIBLE_SIZE, VERTICAL_GAP, self.frame.size.width, self.frame.size.height - VERTICAL_GAP * 2);
     */
    
    CGFloat x, verticalGap;
    
    x = offset_ + VISIBLE_SIZE - self.frame.size.width;
    verticalGap = [self verticalGap:x];
    
    leftImageView_.frame = CGRectMake(x, verticalGap, self.frame.size.width, self.frame.size.height - verticalGap * 2);
    
    x = offset_ + xSpace;
    verticalGap = [self verticalGap:x];
    mainImageView_.frame = CGRectMake(x, verticalGap, self.frame.size.width, self.frame.size.height - verticalGap * 2);
    
    x = offset_ + self.frame.size.width - VISIBLE_SIZE;
    verticalGap = [self verticalGap:x];
    rightImageView_.frame = CGRectMake(x, verticalGap, self.frame.size.width, self.frame.size.height - verticalGap * 2);
}

- (void)updateImageBrowser
{
    UIImage *leftImage = [imagesArray_ objectAtIndex:position_-1];
    UIImage *mainImage = [imagesArray_ objectAtIndex:position_];
    UIImage *rightImage = [imagesArray_ objectAtIndex:position_+1];
    
    if (mainImageView_ == nil) {
        leftImageView_ = [[UIImageView alloc] initWithImage:leftImage];
        mainImageView_ = [[UIImageView alloc] initWithImage:mainImage];
        rightImageView_ = [[UIImageView alloc] initWithImage:rightImage];

        [self addSubview:leftImageView_];
        [self addSubview:mainImageView_];
        [self addSubview:rightImageView_];
        
        [self layoutImages];
    }
    else {
        leftImageView_.image = leftImage;
        mainImageView_.image = mainImage;
        rightImageView_.image = rightImage;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    origin_ = touchPoint.x;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    offset_ = touchPoint.x - origin_;
    
    [self layoutImages];
}


@end
