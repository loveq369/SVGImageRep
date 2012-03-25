/*
copyright 2003, 2004 Alexander Malmberg <alexander@malmberg.org>
*/

#include "Document.h"

#include <math.h>
#include <time.h>

#import <Foundation/NSFileManager.h>
#import <AppKit/NSBezierPath.h>
#import <AppKit/NSFontManager.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSWindow.h>

#include <svg.h>
#import "SVGImageRep.h"

@interface SVGView : NSView
{
	SVGRenderContext *svg;
}

-(void) setSVGRenderContext: (SVGRenderContext *)s;

@end

@implementation SVGView

-(void) setSVGRenderContext: (SVGRenderContext *)s
{
	if(s != svg) 
		svg = [s retain];
	[self setNeedsDisplay: YES];
}

-(void) dealloc
{
	[svg release];
	[super dealloc];
}

-(BOOL) isOpaque
{
	return YES;
}

-(void) drawRect: (NSRect)r
{
	NSGraphicsContext *ctxt = [NSGraphicsContext currentContext];

	CGContextRef tempRef = (CGContextRef)[ctxt graphicsPort];
	
	if (svg)
	{
		CGContextSetGrayFillColor(tempRef, 1.0, 1.0);
		CGContextFillRect(tempRef, CGRectMake(0, 0, svg->size.width, svg->size.height));
		
//		DPScomposite(ctxt,0,0,svg->size.width,svg->size.height,[svg->result gState],0,0,NSCompositeSourceOver);
	}
}

@end


@implementation Document

+(void) openFile: (NSString *)apath
{
	[[self alloc] initWithFile: apath];
}


-(void) reload: (id)sender
{
	{
		svg_t *svg;
		clock_t t;
		SVGRenderContext *svg_render_context=[[SVGRenderContext alloc] init];

		svg_create(&svg);
//		printf("parsing...\n");
		svg_parse(svg,[[NSFileManager defaultManager] fileSystemRepresentationWithPath: path]);

//		printf("rendering...\n");
		t=clock();
		[svg_render_context prepareRender: scale];
		svg_render(svg,&cocoa_svg_engine,svg_render_context);
		[svg_render_context finishRender];
		t=clock()-t;
//		printf("done: %15.8f seconds\n",t/(double)CLOCKS_PER_SEC);

		[svg_view setFrame: NSMakeRect(0,0,svg_render_context->size.width,svg_render_context->size.height)];
		[svg_view setSVGRenderContext: svg_render_context];
		[svg_render_context release];

		svg_destroy(svg);
	}
}


- initWithFile: (NSString *)apath
{
	NSWindow *win;

	win=[[NSWindow alloc] initWithContentRect: NSMakeRect(100,100,450,300)
		styleMask: NSClosableWindowMask|NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask
		backing: NSBackingStoreRetained
		defer: YES];
	if (!(self=[super initWithWindow: win])) return nil;
	path = [apath copy];
	[win setTitleWithRepresentedFilename: path];
	[win setDelegate: self];

	//[NSObject enableDoubleReleaseCheck: YES];


	scale=1.0;

	svg_view=[[SVGView alloc]
		initWithFrame: NSMakeRect(0,0,10,10)];

	[self reload: nil];

	scroll_view=[[NSScrollView alloc] init];
	[scroll_view setDocumentView: svg_view];
	[svg_view release];
	[scroll_view setHasHorizontalScroller: YES];
	[scroll_view setHasVerticalScroller: YES];

	[win setContentView: scroll_view];
	[scroll_view release];

	[win release];

	[self showWindow: nil];


	return self;
}


-(void) windowWillClose: (NSNotification *)n
{
	[self autorelease];
}

-(void) dealloc
{
	[path release];
	[super dealloc];
}


#define SCALE(a,b) \
	-(void) scale_##a##_##b: (id)sender \
	{ \
		scale=a##.##b; \
		[self reload: nil]; \
	}

SCALE(0,1)
SCALE(0,25)
SCALE(0,5)
SCALE(0,75)
SCALE(1,0)
SCALE(1,5)
SCALE(2,0)
SCALE(3,0)
SCALE(4,0)
SCALE(5,0)

@end

