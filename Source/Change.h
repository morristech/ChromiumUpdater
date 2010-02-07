/**********************************************************
 * Changes.h                                              *
 * Container for a changeset.                             *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import <Cocoa/Cocoa.h>


@interface Change : NSObject<NSCopying> {
  NSString* revision;
  NSString* author;
  NSString* date;
  NSString* message;
  NSXMLElement* entry;

  CGFloat revisionHeight;
  CGFloat messageHeight;
  CGFloat width;
}

@property (readonly) NSString* revision;
@property (readonly) NSString* message;
@property (readonly) CGFloat revisionHeight;
@property (readonly) CGFloat messageHeight;
@property (readonly) CGFloat width;

- (Change*) initFromEntry:(NSXMLElement*)someEntry width:(CGFloat)width;
+ (Change*) changeFromEntry:(NSXMLElement*)someEntry width:(CGFloat)width;

- (CGFloat) height;
- (NSFont*) revisionFont;
- (NSFont*) messageFont;
- (NSComparisonResult) compare:(Change*)otherChange;

@end
