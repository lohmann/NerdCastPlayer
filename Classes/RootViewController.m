//
//  RootViewController.m
//  NerdcastPlayer
//
//  Created by Marcio Lohmann on 31/03/10.
//  Copyright Newsoft Consultoria 2010. All rights reserved.
//

#import "RootViewController.h"
#import "iPhoneStreamingPlayerViewController.h"
#import "ASIHTTPRequest.h"

#define kCustomRowHeight    60.0

@implementation RootViewController

@synthesize imageDownloadsInProgress;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Menu";
		
	cellSize = CGSizeMake([self.tableView bounds].size.width, 60);
	
	self.tableView.rowHeight = kCustomRowHeight;
	
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	if ([stories count] == 0) {
		NSString * path = @"http://jovemnerd.ig.com.br/?feed=rss2&cat=42";
		
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = CGPointMake(159, 208);
		activityIndicator.hidesWhenStopped = YES;
		[self.view addSubview:activityIndicator];
		[activityIndicator startAnimating];
		
		ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:path]];
		[request setDelegate:self];
		[request startAsynchronous];
	}
	
	UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	titleView.backgroundColor = [UIColor clearColor];
	
	UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tit_podcast.gif"]];	
	background.frame = CGRectMake(-5, 0, 320, 50);
	background.contentMode = UIViewContentModeScaleToFill;
	[titleView addSubview:background];
		
	self.navigationItem.titleView = titleView;	
	
	[background release];
	[titleView release];
}

- (void)viewDidUnload {
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:MyIdentifier] autorelease];
	}
	
	if ([stories count]>0){
		
		// Set up the cell
		int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
		cell.textLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		
		cell.detailTextLabel.text = [[stories objectAtIndex: storyIndex] objectForKey: @"summary"]; 
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.imageView.image = [UIImage imageNamed:@"ico_nerdinho.jpg"]; 
		cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		/*
		@try {
			IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
			
			// Only load cached images; defer new downloads until scrolling ends
			if (iconDownloader == nil || iconDownloader.appIcon == nil) {
				if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
				{
					NSString* imageURL = [[stories objectAtIndex: storyIndex] objectForKey: @"imageURL"]; 
					[self startIconDownload:imageURL forIndexPath:indexPath];
				}
				// if a download is deferred or in progress, return a placeholder image
				cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
			}
			else {
				cell.imageView.image = iconDownloader.appIcon;
			}			
		}
		@catch (NSException * e) {
			NSLog(@"Expception in Cell for row: %@", [e userInfo]);
		}
		@finally {
		}
		 */
	}
	
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	/*DetailViewController* detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	detailView.castTitle = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	detailView.castURL = [[stories objectAtIndex: storyIndex] objectForKey: @"url"];
	detailView.castEncoded = [[stories objectAtIndex: storyIndex] objectForKey: @"encoded"];
	detailView.castImageURL = [[stories objectAtIndex: storyIndex] objectForKey: @"imageURL"]; 
	[self.navigationController pushViewController:detailView animated:YES];
	[detailView release];*/
	
	iPhoneStreamingPlayerViewController* player = [[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
	player.castURL = [[stories objectAtIndex: storyIndex] objectForKey: @"url"];
	player.castTitle = [[stories objectAtIndex: storyIndex] objectForKey: @"title"];
	player.castImageURL = [[stories objectAtIndex: storyIndex] objectForKey: @"imageURL"];
	[self.navigationController pushViewController:player animated:YES];
	[player release];
	
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark -
#pragma mark RSS Parser

- (void)parseXMLFileData:(NSData *)data {	
	stories = [[NSMutableArray alloc] init];
		
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithData:data];
		
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:YES];
    [rssParser setShouldReportNamespacePrefixes:YES];
    [rssParser setShouldResolveExternalEntities:YES];
	
    [rssParser parse];
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" 
														  message:errorString 
														 delegate:self 
												cancelButtonTitle:@"OK" 
												otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentEncoded = [[NSMutableString alloc] init];
	}
	
	if ([elementName isEqualToString:@"enclosure"] && attributeDict != nil) {
		enclosureURL = [attributeDict objectForKey:@"url"];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
		[item setObject:currentEncoded forKey:@"encoded"];
		[item setObject:enclosureURL forKey:@"url"];
		[item setObject:[self getImageURLFromEncodedHTMLString:currentEncoded] forKey:@"imageURL"];
		
		
		//grava a url da imagem
		/*NSScanner* scanner = [NSScanner scannerWithString:currentEncoded];
		NSString* imgURL = @"";
		[scanner scanUpToString:@"src=\"" intoString:NULL];
		[scanner scanString:@"src=\"" intoString:NULL];
		[scanner scanUpToString:@"\"" intoString:&imgURL];
		[item setObject:imgURL forKey:@"imageURL"];		
		[scanner release];*/
		
		
		[stories addObject:[item copy]];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];	
	} else if ([currentElement isEqualToString:@"encoded"]) {
		[currentEncoded appendString:string];
	} 
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	
	//NSLog(@"all done!");
	//NSLog(@"stories array has %d items", [stories count]);
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark HTTP Data Request

-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"%@",[request responseString]);
	[self parseXMLFileData:[request responseData]];	
}	

-(void)requestFailed:(ASIHTTPRequest *)request {
	[[[UIAlertView alloc] initWithTitle:@"Error:" 
								 message:[[request error] localizedDescription] 
								delegate:self 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles: nil
	   ] show];
	[activityIndicator stopAnimating];
}

#pragma mark -
#pragma mark Table cell image support

- (NSString*)getImageURLFromEncodedHTMLString:(NSString*)htmlString {
	NSScanner* scanner = [NSScanner scannerWithString:htmlString];
	NSString* imgURL = @"";
	[scanner scanUpToString:@"src=\"" intoString:NULL];
	[scanner scanString:@"src=\"" intoString:NULL];
	[scanner scanUpToString:@"\"" intoString:&imgURL];
	return imgURL;
}

- (void)startIconDownload:(NSString *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil && imageURL != nil) 
    {
        //NSLog(@"imageURL %@", imageURL);
		iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imageURL = imageURL;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
		[iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.appIcon;
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
	@try {
		if ([stories count] > 0)
		{
			NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
			for (NSIndexPath *indexPath in visiblePaths)
			{
				IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
				
				if (iconDownloader == nil || iconDownloader.appIcon == nil) {
					int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
					NSString* imageURL = [[stories objectAtIndex: storyIndex] objectForKey: @"imageURL"]; 
					[self startIconDownload:imageURL forIndexPath:indexPath];
				}
			}
		}
	}
	@catch (NSException * e) {
		NSLog(@"Exception: %@", [e userInfo]);
	}
	@finally {
	}
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /*if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }*/
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[self loadImagesForOnscreenRows];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	NSLog(@"MemoryWarning");
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads performSelector:@selector(cancelDownload)];
}


- (void)dealloc {
	[self.imageDownloadsInProgress release];
    [super dealloc];
}


@end

