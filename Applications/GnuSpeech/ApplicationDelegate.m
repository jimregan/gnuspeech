//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "ApplicationDelegate.h"

#import <Foundation/Foundation.h>
#import "TTSParser.h"

@implementation ApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)parseText:(id)sender;
{
    NSString *inputString;
    TTSParser *parser;

    NSLog(@" > %s", _cmd);

    inputString = [inputTextView string];
    NSLog(@"inputString: %@", inputString);

    parser = [[TTSParser alloc] init];
    [parser parseString:inputString];
    [parser release];

    NSLog(@"<  %s", _cmd);
}

@end