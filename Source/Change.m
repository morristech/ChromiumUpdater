/**********************************************************
 * Change.m                                               *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import "Change.h"

@implementation Change

@synthesize revision, message, revisionHeight, messageHeight, width;

- (Change*) initFromEntry:(NSXMLElement*)someEntry width:(CGFloat)someWidth {
  if (self = [super init]) {
    entry = [someEntry retain];
    width = someWidth;
    revision = [[entry attributeForName:@"revision"] stringValue];
    for (NSXMLElement* child in [entry children]) {
      if ([[child name] isEqualToString:@"author"])
        author = [child stringValue];
      else if ([[child name] isEqualToString:@"date"])
        date = [child stringValue];
      else if ([[child name] isEqualToString:@"msg"])
        message = [child stringValue];
    }
    NSRect bounds = NSMakeRect(0, 0, width, 1);
    NSDictionary* msgAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [self messageFont], NSFontAttributeName,
                                   nil];
    NSDictionary* revAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [self revisionFont], NSFontAttributeName,
                                   nil];
    revisionHeight = [revision boundingRectWithSize:bounds.size
                                          options:NSStringDrawingUsesLineFragmentOrigin|
                     NSStringDrawingDisableScreenFontSubstitution
                                       attributes:revAttributes].size.height;
    messageHeight = [message boundingRectWithSize:bounds.size
                                          options:NSStringDrawingUsesLineFragmentOrigin|
                     NSStringDrawingDisableScreenFontSubstitution
                                       attributes:msgAttributes].size.height;
  }
  return self;
}

- (void) dealloc {
  [entry release];
  [super dealloc];
}

+ (Change*) changeFromEntry:(NSXMLElement*)someEntry width:(CGFloat)someWidth {
  return [[[Change alloc] initFromEntry:someEntry width:someWidth] autorelease];
}

// NSCell creates a copy of our object, so we need to implement the NSCopying protocol
- (id) copyWithZone:(NSZone*)zone {
  Change* copy = [[[self class] allocWithZone:zone] initFromEntry:entry width:width];
  return copy;
}

- (CGFloat) height {
  return revisionHeight + messageHeight + 8;
}

- (NSFont*) revisionFont {
  return [NSFont systemFontOfSize:13];
}

- (NSFont*) messageFont {
  return [NSFont systemFontOfSize:10];
}

- (NSComparisonResult) compare:(Change*)otherChange {
  return [revision compare:[otherChange revision]];
}

@end
