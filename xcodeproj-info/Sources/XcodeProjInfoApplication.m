//
//  XcodeProjInfoApplication.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 09.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "XcodeProjInfoApplication.h"

@implementation XcodeProjInfoApplication

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.project = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize project = m_project;

@synthesize help = m_help;

@synthesize version = m_version;

#pragma mark Application

- (void)application:(DDCliApplication *)application willParseOptions:(DDGetoptLongParser *)optionsParser
{
	DDGetoptOption optionTable[] = {
		// Long / var name          Short           Argument
		{@"project",                'p',            DDGetoptOptionalArgument},
		{@"version",                'v',            DDGetoptNoArgument},
		{@"help",                   'h',            DDGetoptNoArgument},
		{nil,                       0,              0},
	};
	[optionsParser addOptionsFromTable:optionTable];
}

- (int)application:(DDCliApplication *)application runWithArguments:(NSArray *)arguments
{
    // TODO:
    return 0;
}

@end
