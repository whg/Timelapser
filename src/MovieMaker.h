//
//  MovieMaker.h
//  Timelapser
//
//  Created by Will Gallia on 06/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@protocol MovieMakerDelegate <NSObject>

- (void) updateView: (float) value;
- (void) movieMakingHasFinished;

@end

@interface MovieMaker : NSObject {
	
	id<MovieMakerDelegate> delegate;
	
	NSArray *imagePaths;
	NSURL *dest;
	int framesPerSecond, movieWidth;
	NSInteger scaleImages;
	QTMovie *movie;
}

@property (nonatomic, assign) id<MovieMakerDelegate> delegate;

@property (retain) NSArray *imagePaths;
@property (retain) NSURL *dest;
@property (assign) int framesPerSecond;
@property (assign) int movieWidth;
@property (assign) NSInteger scaleImages;

- (void) makeMovie;

//delegate methods
- (void) supdateview: (NSNumber*) value;
- (void) sfinished;

@end



