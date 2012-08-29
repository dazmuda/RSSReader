//
//  Article.m
//  RSSFeed
//
//  Created by Robert Carter on 8/28/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import "Article.h"
#import "TFHpple.h"

@implementation Article

//when you pass a block into a function ==== input ^ output name
-(void)retrieveImageWithBlock:(void(^)(void))block {
    //if we have an image, just run the block
    if (self.image) {
        block();
    } else {
        //retrieve image in another thread
        NSURL *url = [NSURL URLWithString: self.url];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
//        example of defining a block = then declaring the block
//        output (name) input = ^output(input)
//        void (^myFavoriteBlock)(void) = ^void(void){
//            NSLog(@"Hello everyone!!");
//        };
        
//        calling that block
//        myFavoriteBlock();
        
        // check out that completionHandler
        // it has the format of ==== ^output(inputs)
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^void(NSURLResponse *response, NSData *data, NSError *error) {
            //lets use hpple!!!!
            //sends request to get an image
            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *images = [doc searchWithXPathQuery:@"//img"];
            
            int n = 3;
            //make sure to not do this if there is no image on the page
            if ([images count]>n) {
                TFHppleElement *imageElement = [images objectAtIndex:n];
                
                //sets this image as the article's image (by grabbing an image from the url)
                NSString *imageSource = [imageElement objectForKey:@"src"];
                NSURL *imageUrl = [NSURL URLWithString:imageSource];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                UIImage *img = [[UIImage alloc] initWithData:imageData];
                self.image = img;
                
                //then perform the block
                block();
            }
        }];
    }
}


//put a method in here called
//performBlockWithImage:(void(^)(void))block {
    //if image already fetched, then just perform block
    //else fetch the image in another thread and then perform the block
    //the block is the callback (on the main thread)
    //the callback should be reload cell or table

//call this method when UITable view is requested
    //call it by [self.tableView performBlockWithImage]
//remember to give it a block
    //this block would get the image
    //then the block would set the cell.image = the image it got
    //also refresh the cell

@end
