/**********************************************************
 * ChangeCell.m                                           *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import "ChangeCell.h"

@implementation ChangeCell

#pragma mark Initialization/Destruction

- (ChangeCell*) copyWithZone:(NSZone*)zone {
  return (ChangeCell*) [super copyWithZone:zone];
}

#pragma mark Drawing

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
  [self setTextColor:[NSColor blackColor]];

  Change* data = (Change*) [self objectValue];

  NSColor* revColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];
  NSString* rev = [NSString stringWithFormat:@"Revision: %@", [data revision]];

  NSDictionary* revAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 revColor, NSForegroundColorAttributeName,
                                 [data revisionFont], NSFontAttributeName,
                                 nil];
  [rev drawAtPoint:NSMakePoint(cellFrame.origin.x + 4, cellFrame.origin.y) withAttributes:revAttributes];

  NSColor* msgColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor disabledControlTextColor];

  NSDictionary* msgAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 msgColor, NSForegroundColorAttributeName,
                                 [data messageFont], NSFontAttributeName,
                                 nil];
  NSRect msgRect = NSMakeRect(cellFrame.origin.x + 4,
                              cellFrame.origin.y + [data revisionHeight] + 4,
                              [data width],
                              [data messageHeight] + 8);
  [[data message] drawInRect:msgRect withAttributes:msgAttributes];
}

@end
