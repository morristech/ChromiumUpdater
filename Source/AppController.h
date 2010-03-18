/**********************************************************
 * AppController.h                                        *
 * Controls the application logic.                        *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import <Cocoa/Cocoa.h>
#import "ChangeLog.h"
#import "ChangeCell.h"
#import "Downloader.h"

@class Downloader;

@interface AppController : NSObject
#ifdef MAC_OS_X_VERSION_10_6
<NSApplicationDelegate>
#endif
{
  IBOutlet NSWindow* window;

  IBOutlet NSProgressIndicator* progressStartup;
  IBOutlet NSProgressIndicator* progressUpdate;
  IBOutlet NSTextField* lblLocalVersion;
  IBOutlet NSTextField* lblRemoteVersion;
  IBOutlet NSButton* btnUpdate;
  IBOutlet NSTextField* lblInfo;
  IBOutlet NSTableView* tblChanges;
  IBOutlet NSButton* btnFetchChanges;
  IBOutlet NSTextField* lblHint;

  NSString* localChromium;
  NSString* remoteChromium;

  ChangeLog* log;
  Downloader* downloader;
  bool autoUpdateRunning;
}

@property (readonly) NSTextField* lblInfo;
@property (readonly) NSProgressIndicator* progressUpdate;

- (NSString*) detectLocalChromium;
- (NSString*) detectRemoteChromium;

- (NSString*) temporaryDirectory;
- (NSString*) temporaryFile;
- (NSString*) extractedDirectory;
- (NSString*) remoteApp;
- (NSString*) localApp;
- (NSString*) downloadURL;

- (IBAction) update:(id)sender;
- (IBAction) fetchChanges:(id)sender;
- (void) notifyDownloadFinished;
- (void) notifyDownloadFailed:(NSError*)error;
- (void) taskFinished:(NSNotification*)notification;

- (void) doFetchChanges;
- (void) doRefresh;


@end
