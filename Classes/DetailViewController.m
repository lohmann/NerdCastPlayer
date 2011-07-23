//
//  DetailViewController.m
//  NerdcastPlayer
//
//  Created by Marcio Lohmann on 31/03/10.
//  Copyright 2010 Newsoft Consultoria. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

@synthesize castTitle, castURL, castEncoded, castImageURL;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = castTitle;
	titleLabel.text = castTitle;
	
	[super viewDidLoad];
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeView sizeToFit];
	[volumeSlider addSubview:volumeView];
	
	[self createStreamer];
	[streamer start];
	
	//playBtn.enabled = FALSE;
	//stopBtn.enabled = TRUE;
	
	NSScanner* scanner = [NSScanner scannerWithString:self.castEncoded];
	NSString* imgURL = @"";
	[scanner scanUpToString:@"src=\"" intoString:NULL];
	[scanner scanString:@"src=\"" intoString:NULL];
	[scanner scanUpToString:@"\"" intoString:&imgURL];
	
	castImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
	
	/*NSString* css1 = @"<link rel=\"stylesheet\" href=\"http://jovemnerd.ig.com.br/wp-content/themes/default/style.css\" type=\"text/css\" media=\"screen\" /><div class=\"widecolumn\" id=\"post-26036\">";

	//NSString* css2 = @"<link rel=\"stylesheet\" href=\"http://jovemnerd.ig.com.br/wp-content/plugins/wp-pagenavi/pagenavi-css.css\" type=\"text/css\" media=\"screen\" /><div class=\"widecolumn\"><div class=\"post\" id=\"post-26036\">";
		
	NSString* url = [NSString stringWithFormat:@"%@ %@ %@", css1, self.castEncoded, @"</div></div>"];
	
	NSLog(@"%@",url);
	
	//[scanner release];

	
	[webView loadHTMLString:url baseURL:nil];*/
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[streamer stop];
	[self destroyStreamer];
}

#pragma mark -
#pragma mark Audio Streamer

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
	
	[self destroyStreamer];
	
	NSString *escapedValue =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(
														 nil,
														 (CFStringRef)self.castURL,
														 NULL,
														 NULL,
														 kCFStringEncodingUTF8)
	 autorelease];
	
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
	[NSTimer
	 scheduledTimerWithTimeInterval:0.1
	 target:self
	 selector:@selector(updateProgress:)
	 userInfo:nil
	 repeats:YES];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		//[self spinButton];
	}
}

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	UIBarButtonItem* btn;
	if ([streamer isPlaying]) {
		btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(buttonPressed:)];
		[streamer pause];
	} else {
		btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(buttonPressed:)];
		[streamer start];
	}

	NSArray* buttons = [[NSArray alloc] initWithObjects:
						[toolBar.items objectAtIndex:0], 
						btn,
						[toolBar.items objectAtIndex:2], 
						nil];
	[btn release];
	//[toolBar.items release];
	toolBar.items = buttons;
	[self.view setNeedsDisplay];
		
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		//[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
	}
	else if ([streamer isPlaying])
	{
		//[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		//[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			/*[positionLabel setText:
			 [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
			  progress,
			  duration]];*/
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		//positionLabel.text = @"Time Played:";
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
}


@end
