/**********************************************************
 * ChangeLog.m                                            *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import "ChangeLog.h"

@implementation ChangeLog

#pragma mark Initialization/Destruction

- (ChangeLog*) initWithTableView:(NSTableView*)someTableView {
  if (self = [super init]) {
    changes = [[NSMutableArray alloc] init];
    revisions = [[NSMutableSet alloc] init];
    tableView = [someTableView retain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
  }
  return self;
}

- (void) dealloc {
  [tableView release];
  [revisions release];
  [changes release];
  [super dealloc];
}

#pragma mark Changes fetching functions

- (NSUInteger) revisionsPerFetch {
  return 50;
}

- (void) fetchRevisionsFrom:(NSUInteger)revisionStart to:(NSUInteger)revisionEnd {
  NSError* error;
  for (NSUInteger rev = revisionStart; rev <= revisionEnd; ++rev) {
    NSNumber* number = [NSNumber numberWithInteger:rev];
    if (![revisions containsObject:number]) {
      NSString *xmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%u/changelog.xml", CHROMIUM_URL, rev]] encoding:NSASCIIStringEncoding error:&error];
      NSXMLDocument* doc = [[NSXMLDocument alloc] initWithXMLString:xmlStr options:NSXMLDocumentTidyXML error:&error];
      NSArray* logEntries = [[doc rootElement] elementsForName:@"logentry"];
      for (NSXMLElement* entry in logEntries) {
        Change* c = [Change changeFromEntry:entry width:[tableView bounds].size.width - 24];
        [changes addObject:c];
        [revisions addObject:[NSNumber numberWithInteger:[[c revision] integerValue]]];
      }
      [doc release];
      [tableView reloadData];
    }
  }
}

- (BOOL) fetchSetOfChanges:(NSUInteger)firstRemoteRev remote:(NSUInteger)lastRemoteRev {
  if (revStart == 0)
    revStart = lastRemoteRev + 1;
  if (revStart > firstRemoteRev) {
    if (revStart - [self revisionsPerFetch] > firstRemoteRev) {
      [self fetchRevisionsFrom:revStart - [self revisionsPerFetch] to:revStart];
      revStart -= [self revisionsPerFetch];
    } else {
      [self fetchRevisionsFrom:firstRemoteRev to:revStart - 1];
      revStart = firstRemoteRev;
    }
    [changes sortUsingSelector:@selector(compare:)];
    [tableView reloadData];
  }
  return revStart > firstRemoteRev;
}

#pragma mark Table datasource functions

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView {
  return [changes count];
}

- (id) tableView:(NSTableView*)aTableView
objectValueForTableColumn:(NSTableColumn*)aTableColumn
             row:(NSInteger)rowIndex {
  return [changes objectAtIndex:rowIndex];
}

- (void) tableView:(NSTableView*)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
               row:(NSInteger)rowIndex {
}

- (CGFloat) tableView:(NSTableView*)tableView heightOfRow:(NSInteger)row {
  return [[changes objectAtIndex:row] height];
}

@end
