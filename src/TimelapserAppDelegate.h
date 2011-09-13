//
//  TimelapserAppDelegate.h
//  Timelapser
//
//  Created by Will Gallia on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MovieMaker.h"

enum TextFieldTags {
	FPS_TAG,
	MOVIE_WIDTH_TAG
};

@interface TimelapserAppDelegate : NSObject <NSApplicationDelegate, MovieMakerDelegate> {
	NSWindow *window;
	IBOutlet NSTextField *fps, *movieWidth;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *label, *px;
	IBOutlet IKImageView *logo;
	IBOutlet NSButton *make, *reveal, *scale;
	MovieMaker *movieMaker;
	
	NSURL *fileURL;
	int numImages;
}

- (IBAction) chooseImages: (id) sender;
- (IBAction) make: (id) sender;
- (IBAction) playMovie: (id) sender;
- (IBAction) enableScale: (id) sender;

//textfield delegate method
- (void) controlTextDidChange: (NSNotification *)aNotification;


@property (assign) IBOutlet NSWindow *window;
@property (retain) NSURL *fileURL;

- (void) updateView: (float) value;
- (void) movieMakingHasFinished;

@end
