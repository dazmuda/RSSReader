//
//  Article.h
//  RSSFeed
//
//  Created by Robert Carter on 8/28/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (strong,nonatomic) NSString* title;
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) UIImage* image;

-(void)retrieveImageWithBlock:(void(^)(void))block;

@end
