//
//  RootViewController.h
//  NerdcastPlayer
//
//  Created by Marcio Lohmann on 31/03/10.
//  Copyright Newsoft Consultoria 2010. All rights reserved.
//

#import "IconDownloader.h"

@interface RootViewController : UITableViewController <IconDownloaderDelegate, NSXMLParserDelegate> {

	UIActivityIndicatorView * activityIndicator;
	CGSize cellSize;
	NSXMLParser * rssParser;
	NSMutableArray * stories;
	NSMutableDictionary * item;
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink, * currentEncoded;
	NSString * enclosureURL;
	
	NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app

}

- (void)startIconDownload:(NSString *)imageURL forIndexPath:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)parseXMLFileData:(NSData *)data;
- (NSString*)getImageURLFromEncodedHTMLString:(NSString*)htmlString;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@end
