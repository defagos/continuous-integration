//
//  XcodeProjInfoApplication.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 09.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "XcodeProjInfoApplication.h"

#import "PBXProject.h"
#import "PBXProjFile.h"
#import "PBXTarget.h"
#import "XCConfiguration.h"

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
    ddprintf(@"%@ version %@\n", [application name], kApplicationVersion);
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
    // Version option
    if (self.version) {
        [self displayVersionForApplication:application];
        return EX_OK;
    }
    
    // Help option
    if (self.help) {
        [self displayHelpForApplication:application];
        return EX_USAGE;
    }
    
    // Project option
    NSString *currentDirectoryPath = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *xcodeProjFilePath = nil;
    if (self.project) {
        xcodeProjFilePath = [[currentDirectoryPath stringByAppendingPathComponent:self.project] stringByAppendingPathExtension:@"xcodeproj"];
        if (! [[NSFileManager defaultManager] fileExistsAtPath:xcodeProjFilePath]) {
            ddprintf(@"[ERROR] No project %@.xcodeproj has been found in the current directory\n", self.project);
            return EX_SOFTWARE;
        }
    }
    // No project option: Look for a project in the current directory
    else {
        NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentDirectoryPath error:NULL];
        NSString *xcodeProjFileName = nil;
        for (NSString *fileName in fileNames) {
            if ([[fileName pathExtension] isEqualToString:@"xcodeproj"]) {
                // If several projects found, exit
                if (xcodeProjFileName) {
                    ddprintf(@"[ERROR] Several .xcodeproj found in the current directory. Use -p for disambiguation\n");
                    return EX_SOFTWARE;
                }
                
                xcodeProjFileName = fileName;
            }
        }
        
        if (! xcodeProjFileName) {
            ddprintf(@"[ERROR] No .xcodeproj found in the current directory\n");
            return EX_SOFTWARE;
        }
        
        xcodeProjFilePath = [currentDirectoryPath stringByAppendingPathComponent:xcodeProjFileName];
    }
        
    // Load .pbxproj
    NSString *projectFilePath = [xcodeProjFilePath stringByAppendingPathComponent:@"project.pbxproj"];
    PBXProjFile *projFile = [[[PBXProjFile alloc] initWithFilePath:projectFilePath] autorelease];
    if (! projFile) {
        return EX_SOFTWARE;
    }
    
    // Extract configuration information
    NSArray *projects = [PBXProject projectsInProjFile:projFile];
    for (PBXProject *project in projects) {
        NSArray *projectConfigurations = [XCConfiguration configurationsForProject:project inProjFile:projFile];
        NSLog(@"%@", projectConfigurations);
    }
    
    
    // TODO: Override with target configuration if available, otherwise use project configuration
    
    return EX_OK;
}

@end
