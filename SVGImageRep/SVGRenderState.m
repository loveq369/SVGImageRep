//
//  SVGRenderState.m
//  SVGImageRep
//
//  Created by Charles Betts on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#import "SVGRenderState.h"
#import <Foundation/NSString.h>

@implementation SVGRenderState

@synthesize strokeOpacity, dash, color, opacity, dashLength, fillRule;
@synthesize fontSize, fillPaint, fontStyle, dashOffset, fontFamily, fontWeight;
@synthesize textAnchor, fillOpacity, strokePaint, strokeWidth;

- (id)copyWithZone:(NSZone *)zone
{
	SVGRenderState *new = [[SVGRenderState allocWithZone:zone] init];
	
	new.dashLength = dashLength;
	new.strokeOpacity = strokeOpacity;
	new.color = color;
	new.opacity = opacity;
	new.fillRule = fillRule;
	new.fontSize = fontSize;
	new.fillPaint = fillPaint;
	new.fontStyle = fontStyle;
	new.dashOffset = dashOffset;
	new.fontWeight = fontWeight;
	new.textAnchor = textAnchor;
	new.fillOpacity = fillOpacity;
	new.strokePaint = strokePaint;
	new.strokeWidth = strokeWidth;
	new.fontFamily = fontFamily; //Declared property has copy in it, so it doesn't retain it.
	
	if (dash) {
		new.dash = malloc(sizeof(CGFloat) * dashLength);
		memcpy(new.dash, dash, sizeof(CGFloat) * dashLength);
	}
	
	return new;
}

- (void)dealloc
{
	if (dash)
		free(dash);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"font family: \"%@\", size: %f; dash size: %zu, offset: %f; stroke opacity: %f", fontFamily, fontSize, dashLength, dashOffset, strokeOpacity];
}

@end
