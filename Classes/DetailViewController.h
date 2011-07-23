//
//  DetailViewController.h
//  NerdcastPlayer
//
//  Created by Marcio Lohmann on 31/03/10.
//  Copyright 2010 Newsoft Consultoria. All rights reserved.
//

#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>


@interface DetailViewController : UIViewController {
	
	NSString	  *castTitle;
	NSString	  *castURL;
	NSString	  *castEncoded;
	NSString	  *castImageURL;
	NSTimer		  *progressUpdateTimer;
	AudioStreamer *streamer;
	
	//Outlets
	IBOutlet UILabel	  *titleLabel;
	IBOutlet MPVolumeView *volumeSlider;
	IBOutlet UISlider	  *progressSlider;
	IBOutlet UIImageView  *castImageView;
	IBOutlet UIToolbar    *toolBar;
	IBOutlet UIWebView    *webView;

}

- (void)createStreamer;
- (void)destroyStreamer;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)sliderMoved:(UISlider *)aSlider;

@property(nonatomic,retain)NSString *castTitle;
@property(nonatomic,retain)NSString *castURL;
@property(nonatomic,retain)NSString *castEncoded;
@property(nonatomic,retain)NSString *castImageURL;

@end
