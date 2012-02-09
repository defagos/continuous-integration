//
//  main.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "XcodeProjInfoApplication.h"

int main (int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int exitCode = DDCliAppRunWithClass([XcodeProjInfoApplication class]);
    [pool drain];
    return exitCode;
}

