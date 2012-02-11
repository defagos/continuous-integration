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

typedef enum {
    ActionEnumBegin = 0,
    ActionListTargets = ActionEnumBegin,
    ActionListConfigurations,
    ActionEnumEnd,
    ActionEnumSize = ActionEnumEnd - ActionEnumBegin
} Action;

static NSString * const kApplicationVersion = @"1.0";

@interface XcodeProjInfoApplication ()

- (int)displayHelpForApplication:(DDCliApplication *)application;
- (int)displayVersionForApplication:(DDCliApplication *)application;
- (int)extractTargetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile;
- (int)extractConfigurationsForProject:(PBXProject *)project targetName:(NSString *)targetName inProjFile:(PBXProjFile *)projFile;

@end

@implementation XcodeProjInfoApplication

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.project = nil;
    self.target = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize project = m_project;

@synthesize target = m_target;

@synthesize help = m_help;

@synthesize version = m_version;

#pragma mark Application

- (void)application:(DDCliApplication *)application willParseOptions:(DDGetoptLongParser *)optionsParser
{
	DDGetoptOption optionTable[] = {
		// Long / var name          Short           Argument
		{@"project",                'p',            DDGetoptRequiredArgument},
        {@"target",                 't',            DDGetoptRequiredArgument},
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
        return [self displayVersionForApplication:application];
    }
    
    // Help option
    if (self.help) {
        return [self displayHelpForApplication:application];
    }
    
    // Finish extracting arguments
    if ([arguments count] == 0) {
        ddprintf(@"[ERROR] Missing action\n");
        return [self displayHelpForApplication:application];
    }
    else if ([arguments count] > 1) {
        ddprintf(@"[ERROR] Too many parameters\n");
        return [self displayHelpForApplication:application];
    }
    
    // Validate remaining arguments
    NSString *actionArgument = [arguments objectAtIndex:0];
    Action action;
    if ([actionArgument isEqualToString:@"list-targets"]) {
        action = ActionListTargets;
    }
    else if ([actionArgument isEqualToString:@"list-configurations"]) {
        action = ActionListConfigurations;
    }
    else {
        ddprintf(@"[ERROR] Unknown action\n");
        return [self displayHelpForApplication:application];
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
    
    // Load project
    PBXProject *project = [PBXProject projectInProjFile:projFile];
    if (! project) {
        return EX_SOFTWARE;
    }
    
    // Execute action
    switch (action) {
        case ActionListTargets: {
            return [self extractTargetsForProject:project inProjFile:projFile];
            break;
        }
            
        case ActionListConfigurations: {
            return [self extractConfigurationsForProject:project targetName:self.target inProjFile:projFile];
            break;
        }
                        
        default: {
            ddprintf(@"[ERROR] Unsupported action\n");
            return EX_SOFTWARE;
            break;
        }
    }
}

#pragma mark Functionalities

- (int)displayHelpForApplication:(DDCliApplication *)application
{
    ddprintf(@"\n"
             "Extract information from an Xcode project. Currently only basic options\n"
             "are available, but more may appear in the future.\n"
             "\n"
             "Information is extracted by invoking actions. Use -p and -t options to\n"
             "filter out projects or targets you do not care about.\n"
             "\n"
             "The command locates projects in the directory it is run from. If several\n"
             "projects are found, the command exits. Use -p to select the project you\n"
             "want to load in such cases case\n"
             "\n"
             "Usage: %@ [-p project_name] [-v] [-h] action\n"
             "\n"
             "Mandatory parameters:\n"
             "   action                 The action to be performed:\n"
             "                            list-targets\n"
             "                            list-configurations: Output format is\n"
             "                                target configuration sdk\n"
             "\n"
             "Options:\n"
             "   -h (--help):           Display this documentation\n"
             "   -p (--project):        If you have multiple projects in the same\n"
             "                          directory, indicate which one must be used using\n"
             "                          this option (without the .xcodeproj extension)\n"
             "   -t (--target):         Restrict output to a given target\n"
             "   -v (--version):        Print the script version number\n", [application name]);
    
    return EX_USAGE;
}

- (int)displayVersionForApplication:(DDCliApplication *)application
{
    ddprintf(@"%@ version %@\n", [application name], kApplicationVersion);
    
    return EX_OK;
}

- (int)extractTargetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile
{
    NSArray *targets = [PBXTarget targetsForProject:project inProjFile:projFile];
    for (PBXTarget *target in targets) {
        ddprintf(@"%@\n", target.name);
    }
    
    return EX_OK;
}

- (int)extractConfigurationsForProject:(PBXProject *)project targetName:(NSString *)targetName inProjFile:(PBXProjFile *)projFile
{
    NSArray *targets = [PBXTarget targetsForProject:project inProjFile:projFile];
    
    // Target specified: Display only corresponding configurations
    if (targetName) {
        targets = [targets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", targetName]];
        if ([targets count] == 0) {
            ddprintf(@"[ERROR] Target %@ not found\n", targetName);
            return EX_SOFTWARE;
        }
    }
    
    // List all configurations
    for (PBXTarget *target in targets) {
        NSArray *configurations = [XCConfiguration configurationsForTarget:target inProjFile:projFile];
        for (XCConfiguration *configuration in configurations) {
            // Separate using tabs. Easy to detect as delimiters by command-line tools like cut, and cannot be
            // part of target or configuration names
            ddprintf(@"%@\t%@\t%@\n", target.name, configuration.name, configuration.sdk);
        }
    }
    
    return EX_OK;
}

@end
