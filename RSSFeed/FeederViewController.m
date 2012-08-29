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

@interface FeederViewController () <RKRequestDelegate>
@property (strong, nonatomic) NSArray* rssData;
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
    return [self.rssData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Populate the cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"question"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article"];
    }
    
    NSDictionary *currentArticle = [self.rssData objectAtIndex: indexPath.row];
    cell.textLabel.text = [currentArticle objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User clicked a cell --> go to article in ArticleView
    ArticleViewController *avc = [ArticleViewController new];
    avc.url =  [[[self.rssData objectAtIndex: indexPath.row] objectForKey:@"atom:link"] objectForKey:@"href"];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:avc animated:YES];
}

- (void) makeRequest
{
    RKClient* client = [RKClient sharedClient];
    [client get:@"/HomePage.xml" delegate:self];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //here we create a new parser that can handle the RSS MIME type
    id xmlParser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeXML];
    //now we use this parser on our response to get a parsedResponse
    id parsedResponse = [xmlParser objectFromString:[response bodyAsString] error:nil];
    self.rssData = [[[parsedResponse objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];

    // NSLog(@"%@", [self.rssData objectAtIndex:0]);
    [self.tableView reloadData];
}

@end
