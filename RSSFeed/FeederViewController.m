//
//  FeederViewController.m
//  RSSFeed
//
//  Created by Robert Carter on 8/28/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import "RestKit.h"
#import "FeederViewController.h"
#import "ArticleViewController.h"
#import "Article.h"

@interface FeederViewController () <RKRequestDelegate,NSURLConnectionDelegate>
@property (strong, nonatomic) NSMutableArray* articlesArray;
@end

@implementation FeederViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [RKClient clientWithBaseURLString:@"http://rss.nytimes.com/services/xml/rss/nyt"];
    [self makeRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.articlesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Populate the cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"question"];
    //lets make a new cell class that inheritys from tvc and use that instead!
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article"];
    }
    
    //  Grab the article for the cell
    Article *currentArticle = [self.articlesArray objectAtIndex: indexPath.row];
    cell.textLabel.text = currentArticle.title;

    [currentArticle retrieveImageWithBlock:^{
        //set the image for the cell as the image you got back
        cell.imageView.image = currentArticle.image;
        //refresh the cell
        [cell setNeedsLayout];
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User clicked a cell --> go to article in ArticleView
    ArticleViewController *avc = [ArticleViewController new];
    Article *currentArticle = [self.articlesArray objectAtIndex:indexPath.row];
    avc.url = currentArticle.url;

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:avc animated:YES];
}

- (void) makeRequest
{
    RKClient* client = [RKClient sharedClient];
    [client get:@"/HomePage.xml" delegate:self];
}

// Delegate for RestKit requests
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //here we create a new parser that can handle the RSS MIME type
    id xmlParser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeXML];
    //now we use this parser on our response to get a parsedResponse
    id parsedResponse = [xmlParser objectFromString:[response bodyAsString] error:nil];
    NSArray* rssData = [[[parsedResponse objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];

    
    self.articlesArray = [NSMutableArray new];
    for (NSDictionary* articleHash in rssData) {
        Article *article = [Article new];
        article.title = [articleHash objectForKey:@"title"];
        article.url = [[articleHash objectForKey:@"atom:link"] objectForKey:@"href"];
        [self.articlesArray addObject:article];
    }
    [self.tableView reloadData];
}

@end


