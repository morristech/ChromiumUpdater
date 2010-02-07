/**********************************************************
 * ChangeLog.h                                            *
 * Holds a list of changes and fetches new ones.          *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import <Cocoa/Cocoa.h>
#import "Change.h"
#import "ChangeCell.h"

@interface ChangeLog : NSObject
#ifdef MAC_OS_X_VERSION_10_6
<NSTableViewDataSource, NSTableViewDelegate>
#endif
{
  NSMutableArray* changes;
  NSMutableSet* revisions;
  NSTableView* tableView;
  NSUInteger revStart;
}

- (ChangeLog*) initWithTableView:(NSTableView*)someTableView;

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView;

- (id) tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
             row:(NSInteger)rowIndex;

- (void) tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
               row:(NSInteger)rowIndex;

- (NSUInteger) revisionsPerFetch;
- (void) fetchRevisionsFrom:(NSUInteger)revisionStart to:(NSUInteger)revisionEnd;
- (BOOL) fetchSetOfChanges:(NSUInteger)firstRemoteRev remote:(NSUInteger)lastRemoteRev;

@end
