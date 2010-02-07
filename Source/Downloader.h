/**********************************************************
 * Downloader.h                                           *
 * Downloads the most recent Chromium version.            *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import <Cocoa/Cocoa.h>
#import "AppController.h"

@class AppController;

@interface Downloader : NSObject {
  AppController* controller;

  long long bytesReceived;
  long long bytesTotal;
}

- (Downloader*) init:(AppController*)theController;

@end
