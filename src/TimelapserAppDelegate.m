//
//  TimelapserAppDelegate.m
//  Timelapser
//
//  Created by Will Gallia on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelapserAppDelegate.h"

@implementation TimelapserAppDelegate

@synthesize window;
@synthesize fileURL;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	movieMaker = [[MovieMaker alloc] init];
	printf("%d", FPS_TAG);
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification {
	
	//housework on labels and progress bar
	[progress setIndeterminate:NO];
	[progress setMinValue:0];
	[progress setMaxValue:100];
	[progress setDoubleValue:0];
	[label setIntValue:0];
	[progress setHidden:TRUE];
	[label setHidden:TRUE];
	[reveal setHidden:TRUE];
	[px setHidden:TRUE];
	[movieWidth setEnabled:FALSE];
	
	[fps setTag:[[NSNumber numberWithInt:FPS_TAG] integerValue]];
	[movieWidth setTag:[[NSNumber numberWithInt:MOVIE_WIDTH_TAG] integerValue]];
	
	//set logo image
	NSURL* url = [[NSBundle mainBundle] URLForResource:@"timelapser200" withExtension:@"png"];
	[logo setImageWithURL:url];
	
}

/* - - - ACTIONS - - - */

- (IBAction) chooseImages: (id) sender {
	
	//do this now in case we make another movie...
	[reveal setHidden:TRUE];

	NSOpenPanel *op = [NSOpenPanel openPanel];
		
	NSArray *filetypes = [[NSArray alloc] initWithObjects:
												@"png", @"PNG", @"jpg", @"JPG", @"jpeg", @"gif", @"GIF", nil];
	
	[op setAllowsMultipleSelection:YES];
	[op setAllowedFileTypes: filetypes];
	[op setCanChooseDirectories:NO];
	
	if ([op runModal] == NSOKButton) {
		
		[movieMaker setImagePaths:[op URLs]];
		
		numImages = [[op URLs] count];
		
		[label setHidden:FALSE];
		
		//show label w/ no images and time...
		[self controlTextDidChange:nil];
				
	}
	
}


- (IBAction) make: (id) sender {
	
	[reveal setHidden:TRUE];
	
	NSSavePanel *sp = [NSSavePanel savePanel];
	
	[sp setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"mp4v", nil]];
	[sp setCanSelectHiddenExtension:YES];
	[sp setExtensionHidden:NO];

	
	if ([sp runModal] == NSOKButton) {
		
		[movieMaker setFramesPerSecond:[fps intValue]];
		[movieMaker setMovieWidth:[movieWidth intValue]];
		[movieMaker setDest:[sp URL]];
		[movieMaker setScaleImages:[scale state]];
		
		[self setFileURL:[sp URL]];
		
		//start the movie making in a new thread
		[movieMaker setDelegate:self];
		[NSThread detachNewThreadSelector:@selector(makeMovie) toTarget:movieMaker withObject:nil];
		
	}
	
}

-(void) controlTextDidChange: (NSNotification *)aNotification {
	
	NSLog(@"tag = %d", [[aNotification object]	tag]);
	
	if ([label isHidden]) {
		return;
	}
	
	int f = [fps intValue];
	
	//if we don't have a number...
	if (f == 0) {
		[label setStringValue:[NSString stringWithString:@"Set a valid framerate"]];
		[make setEnabled:FALSE];
		return;
	}
	
	int w = [movieWidth intValue];
	
	if (w == 0) {
		[label setStringValue:[NSString stringWithString:@"Set a valid width"]];
		[make setEnabled:FALSE];
		return;
	}
	//end checks
	
	[make setEnabled:TRUE];
	
	//calculate the movie length
	double movieLength = numImages/[fps floatValue];
	double secs, frac;
	frac = modf(movieLength, &secs);
	secs = ((int) secs) % 60;
	secs+= frac;
	int mins = ((int) movieLength) / 60;
		
	[label setStringValue:[NSString stringWithFormat:@"%d images - %d:%2.1fs", numImages, mins, secs]];
	
}

- (void) updateView: (float) value {
		
	[progress setHidden:FALSE];
	[progress setDoubleValue:value];
	[label setStringValue:[NSString stringWithFormat:@"%3.1f%%", value]];	

}

- (void) movieMakingHasFinished {

	[progress setHidden:TRUE];
	[label setStringValue:@"Completed"];
	[reveal setHidden:FALSE];
	
	
}

- (IBAction) playMovie: (id) sender {

	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws openURL:fileURL];
}

- (IBAction) enableScale: (id) sender {
	if ([(NSButton*)sender state] == NSOnState) {
		[px setHidden:FALSE];
		[movieWidth setEnabled:TRUE];
	}
	else {
		[px setHidden:TRUE];
		[movieWidth setEnabled:FALSE];

	}
}

- (void) dealloc {
	
	[window release];
	[fps release];
	[progress release];
	[label release];
	[logo release];
	[fileURL release];
	[movieMaker release];
	
	[super dealloc];
}

@end
