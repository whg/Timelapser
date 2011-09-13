//
//  MovieMaker.m
//  Timelapser
//
//  Created by Will Gallia on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MovieMaker.h"


@implementation MovieMaker

@synthesize delegate;
@synthesize imagePaths;
@synthesize dest;
@synthesize framesPerSecond;
@synthesize movieWidth;
@synthesize scaleImages;

- (id) init {
		
	if (self = [super init]) { 
	}	
	return self;
}

- (void) makeMovie {
		
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	
	//for some weird reason, this stops a:
	//posix_spawn fatal error: 9! and
	//qtmovie saying: the movie contains an invalid data reference
	[NSThread sleepForTimeInterval:0.05f];
	
	[QTMovie enterQTKitOnThread];

	NSError *error = nil;
	movie = [[QTMovie alloc] initToWritableFile:[dest path] error:&error];
	[movie autorelease];
	[movie attachToCurrentThread];
	
	//could't make movie
	if (!movie) {
		[[NSAlert alertWithError:error] runModal];
	} 
		
	//set up movie variables
	NSNumber* imageQuality = [NSNumber numberWithLong:codecMaxQuality];
	NSString* imageCodec = @"mp4v";
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
												 imageCodec, QTAddImageCodecType,
												 imageQuality, QTAddImageCodecQuality, nil];
	
	//this doesn't seem quite right but seems to work...
	QTTime time = QTMakeTime(1, framesPerSecond);
	
	//something to calculate percentages
	float i = 0;
	int numImages = [imagePaths count];
	
	//loop through all images and add them to the movie
	
	NSImageRep* imgRep;
		
	for (NSURL *url in imagePaths) {
		
		imgRep = [NSImageRep imageRepWithContentsOfURL:url];

		NSRect rect = NSMakeRect(0, 0, [imgRep pixelsWide], [imgRep pixelsHigh]);
		NSLog(@"s = asdfa%d", [imgRep pixelsWide]);
				
		CGImageRef ref = [imgRep CGImageForProposedRect:&rect context:nil hints:nil];
		
		float movieHeight = ((float) movieWidth/[imgRep pixelsWide])*[imgRep pixelsHigh];

		
		NSLog(@"state =%d", scaleImages);
		if (scaleImages == NSOffState) {
			movieHeight = [imgRep pixelsHigh];
			movieWidth = [imgRep pixelsWide];
		} 
		
		NSImage *nimg = [[NSImage alloc] initWithCGImage:ref size:NSMakeSize(movieWidth, movieHeight)];
		
		[movie addImage:nimg forDuration:time withAttributes:attrs];
		
		[nimg release];
		
		//update view
		float p = (i++)/numImages*100.0;
		NSNumber *prog = [NSNumber numberWithFloat:p];
		[self performSelectorOnMainThread:@selector(supdateview:) withObject:prog waitUntilDone:NO];
	}
	
	//write movie to file	
	[movie updateMovieFile];
	
	[movie detachFromCurrentThread];
	[QTMovie exitQTKitOnThread];


	[self performSelectorOnMainThread:@selector(sfinished) withObject:nil waitUntilDone:NO];
	
	[self.delegate movieMakingHasFinished];
		
	[pool release];
	
}

- (void) supdateview: (NSNumber*) value {
	[self.delegate updateView:[value floatValue]];
}

- (void) sfinished {

	[self.delegate movieMakingHasFinished];
}

- (void) dealloc {
	[imagePaths release];
	[dest release];
	[super dealloc];
}

@end
