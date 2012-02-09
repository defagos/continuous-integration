//
//  XcodeProjInfoApplication.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 09.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "XcodeProjInfoApplication.h"

static NSString * const kApplicationVersion = @"1.0";

@interface XcodeProjInfoApplication ()

- (void)displayHelpForApplication:(DDCliApplication *)application;
- (void)displayVersionForApplication:(DDCliApplication *)application;

@end

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

- (void)displayHelpForApplication:(DDCliApplication *)application
{
    ddprintf(@"Extract information from an Xcode project. Currently only configuration\n"
             "information is returned, but other options may appear in the future.\n"
             "\n"
             "The command locates projects in the directory it is run from. If several\n"
             "projects are found, the command exits. Use -p to select the project you\n"
             "want to load in such cases case\n"
             "\n"
             "Usage: %@ [-p project_name][-v] [-h]\n"
             "\n"
             "Options:\n"
             "   -h:                    Display this documentation\n"
             "   -p:                    If you have multiple projects in the same\n"
             "                          directory, indicate which one must be used using\n"
             "                          this option (without the .xcodeproj extension)\n"
             "   -v:                    Print the script version number\n", [application name]);
}

- (void)displayVersionForApplication:(DDCliApplication *)application
{
    ddprintf(@"%@ version %@", [application name], kApplicationVersion);
}

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
    if (self.version) {
        [self displayVersionForApplication:application];
        return EX_OK;
    }
    
    if (self.help) {
        [self displayHelpForApplication:application];
        return EX_USAGE;
    }
    
    
    [self displayHelpForApplication:application];
    return EX_USAGE;
}

@end
