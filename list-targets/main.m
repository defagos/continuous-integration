//
//  main.m
//  list-targets
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"
#import "PBXProjFile.h"
#import "PBXTarget.h"
#import "XCConfiguration.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        PBXProjFile *projFile = [[[PBXProjFile alloc] initWithFileName:@"project.pbxproj"] autorelease];
        NSArray *projects = [PBXProject projectsInProjFile:projFile];
        for (PBXProject *project in projects) {
            NSLog(@"Project: %@", project);
            NSArray *projectConfigurations = [XCConfiguration configurationsForProject:project inProjFile:projFile];
            NSLog(@"   Configurations: %@", projectConfigurations);
            
            NSArray *targets = [PBXTarget targetsForProject:project inProjFile:projFile];
            for (PBXTarget *target in targets) {
                NSLog(@"   Target: %@", target);
                NSArray *targetConfigurations = [XCConfiguration configurationsForTarget:target inProjFile:projFile];
                NSLog(@"      Configurations: %@", targetConfigurations);
            }
        }
    }
    return 0;
}

