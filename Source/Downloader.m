/**********************************************************
 * Downloader.m                                           *
 * ------------------------------------------------------ *
 * Copyright (c) 2010 Markus Groß.                        *
 * ------------------------------------------------------ *
 * License: GPLv2 see LICENSE file                        *
 **********************************************************/

#import "Downloader.h"


@implementation Downloader

- (Downloader*) init:(AppController*)theController {
  if (self = [super init]) {
    controller = [theController retain];
    NSError* error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[controller temporaryDirectory] withIntermediateDirectories:YES attributes:nil error:&error])
      [NSApp presentError:error];
    NSURL* chromiumURL = [NSURL URLWithString:[controller downloadURL]];
    NSURLRequest* theRequest = [NSURLRequest requestWithURL:chromiumURL
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:10.0];
    NSURLDownload* theDownload = [[NSURLDownload alloc] initWithRequest:theRequest
                                                               delegate:self];
    if (theDownload)
      [theDownload setDestination:[controller temporaryFile] allowOverwrite:YES];
  }
  return self;
}

- (void) dealloc {
  [controller release];
  [super dealloc];
}

- (void) downloadDidFinish:(NSURLDownload*)download {
  [download release];
  [controller notifyDownloadFinished];
}

- (void) download:(NSURLDownload*)download didFailWithError:(NSError*)error {
  [download release];
  [controller notifyDownloadFailed:error];
}

- (void) download:(NSURLDownload*)download didReceiveResponse:(NSURLResponse*)response {
  bytesReceived = 0;
  [[controller progressUpdate] setDoubleValue:0];
  bytesTotal = [response expectedContentLength];
  [[controller progressUpdate] setIndeterminate:bytesTotal == NSURLResponseUnknownLength];
}

- (void) download:(NSURLDownload*)download didReceiveDataOfLength:(NSUInteger)length {
  bytesReceived = bytesReceived + length;

  if (bytesTotal != NSURLResponseUnknownLength) {
    double percentComplete = (bytesReceived / (double) bytesTotal) * 100.0;
    [[controller progressUpdate] setDoubleValue:percentComplete];
    CGFloat mbReceived = ((CGFloat) bytesReceived) / 1024 / 1024;
    CGFloat mbTotal = ((CGFloat) bytesTotal) / 1024 / 1024;
    [[controller lblInfo] setStringValue:[NSString stringWithFormat:@"%.2fmb / %.2fmb", mbReceived, mbTotal]];
  }
}

@end
