/**********************************************************
 * AppController.m                                        *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import "AppController.h"

@implementation AppController

@synthesize lblInfo, progressUpdate;

#pragma mark Initialization/Destruction

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
}

- (void) awakeFromNib {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinished:) name:NSTaskDidTerminateNotification object:nil];
  ChangeCell* cell = [[[ChangeCell alloc] init] autorelease];
  [[tblChanges tableColumnWithIdentifier:@"Changes"] setDataCell:cell];
  log = [[ChangeLog alloc] initWithTableView:tblChanges];
  [lblHint setStringValue:[NSString stringWithFormat:[lblHint stringValue], [self localApp]]];
  [self performSelectorInBackground:@selector(doRefresh) withObject:nil];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication {
  return YES;
}

- (void) dealloc {
  [downloader release];
  [log release];
  [super dealloc];
}

#pragma mark Functions returning paths and urls

- (NSString*) temporaryDirectory {
  return [NSString stringWithFormat:@"%@%@/", NSTemporaryDirectory(), [[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString*) temporaryFile {
  return [NSString stringWithFormat:@"%@chromium_update.zip", [self temporaryDirectory]];
}

- (NSString*) extractedDirectory {
  return [NSString stringWithFormat:@"%@chrome-mac/", [self temporaryDirectory]];
}

- (NSString*) localApp {
  NSString* path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"org.chromium.Chromium"];
  if (!path) {
    FSRef folder;
    OSErr err = FSFindFolder(kSystemDomain, kApplicationsFolderType, false, &folder);
    if (err == noErr) {
      CFURLRef url = CFURLCreateFromFSRef(kCFAllocatorDefault, &folder);
      path = [(NSURL *)url path];
      CFRelease(url);
    }
    return path ? [path stringByAppendingString:@"/Chromium.app"] : path;
  }
  return path;
}

- (NSString*) remoteApp {
  return [NSString stringWithFormat:@"%@Chromium.app", [self extractedDirectory]];
}

- (NSString*) downloadURL {
  return [NSString stringWithFormat:@"%@%@/chrome-mac.zip", CHROMIUM_URL, remoteChromium];
}

#pragma mark Version detection functions

- (NSString*) detectLocalChromium {
  NSString *path = [self localApp];
  NSString *version = nil;
  if (path) {
    NSString *infoPList = [NSString stringWithFormat:@"%@/Contents/Info.plist", path];
    version = [[NSDictionary dictionaryWithContentsOfFile:infoPList] valueForKey:@"SVNRevision"];
  }
  return version;
}

- (NSString*) detectRemoteChromium {
  NSError *error;
  NSURL* latestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/LATEST", CHROMIUM_URL]];
  NSString *version = [NSString stringWithContentsOfURL:latestURL
                                               encoding:NSASCIIStringEncoding
                                                  error:&error];
  return version;
}

#pragma mark Refresh functions

- (void) doRefresh {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  [lblInfo setStringValue:@"refreshing..."];
  [progressStartup setHidden:NO];
  [progressStartup startAnimation:nil];

  localChromium = [self detectLocalChromium];
  [lblLocalVersion setStringValue:localChromium ? localChromium : @"Not installed!"];

  remoteChromium = [self detectRemoteChromium];
  [lblRemoteVersion setStringValue:remoteChromium ? remoteChromium : @"Unable to detect!"];

  if (localChromium && remoteChromium) {
    NSComparisonResult res = [localChromium compare:remoteChromium];
    switch (res) {
      case NSOrderedSame:
        [lblInfo setStringValue:@"Your Chromium version is up to date!"];
        [btnUpdate setHidden:YES];
        break;
      case NSOrderedAscending:
        [lblInfo setStringValue:@"Update possible!"];
        [btnUpdate setHidden:NO];
        break;
      case NSOrderedDescending:
        [lblInfo setStringValue:@"Your Chromium version is newer!"];
        [btnUpdate setHidden:YES];
        break;
    }
    [self fetchChanges:nil];
  } else {
    [btnFetchChanges setHidden:YES];
    if (!localChromium && remoteChromium) {
      [lblInfo setStringValue:@"You may install Chromium by clicking \"update\"!"];
      [btnUpdate setHidden:NO];
    }
    [progressStartup stopAnimation:nil];
    [progressStartup setHidden:YES];
  }

  [pool release];
}

- (IBAction) fetchChanges:(id)sender {
  [self performSelectorInBackground:@selector(doFetchChanges) withObject:nil];
}

- (void) doFetchChanges {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  [progressStartup setHidden:NO];
  [progressStartup startAnimation:nil];
  [btnFetchChanges setEnabled:NO];
  BOOL someLeft = [log fetchSetOfChanges:[localChromium integerValue] + 1 remote:[remoteChromium integerValue]];
  [btnFetchChanges setEnabled:YES];
  [btnFetchChanges setHidden:!someLeft];
  [progressStartup stopAnimation:nil];
  [progressStartup setHidden:YES];
  [pool release];
}

#pragma mark Update functions

- (IBAction) update:(id)sender {
  [btnUpdate setHidden:YES];
  [progressUpdate setHidden:NO];
  [downloader release];
  downloader = [[Downloader alloc] init:self];
}

- (void) notifyDownloadFinished {
  [lblInfo setStringValue:@"Extracting..."];
  [progressUpdate setIndeterminate:YES];

  NSTask* task = [[NSTask alloc] init];
  [task setLaunchPath: @"/usr/bin/unzip"];
  [task setCurrentDirectoryPath:[self temporaryDirectory]];

  NSArray* arguments = [NSArray arrayWithObjects:@"-qq", [self temporaryFile], nil];
  [task setArguments:arguments];
  [task launch];
}

- (void) notifyDownloadFailed:(NSError*)error {
  [lblInfo setStringValue:[error localizedDescription]];
  [btnUpdate setHidden:NO];
  [progressUpdate setHidden:YES];
}

- (void) taskFinished:(NSNotification*)notification {
  NSString* localPath = [self localApp];

  NSError* error;
  [[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
  [[NSFileManager defaultManager] moveItemAtPath:[self remoteApp] toPath:localPath error:&error];
  [[NSFileManager defaultManager] removeItemAtPath:[self temporaryDirectory] error:&error];

  [progressUpdate setIndeterminate:NO];
  [progressUpdate setDoubleValue:0];
  [progressUpdate setHidden:YES];
  [lblInfo setStringValue:@"finished!"];
  [lblLocalVersion setStringValue:[self detectLocalChromium]];
}

@end
