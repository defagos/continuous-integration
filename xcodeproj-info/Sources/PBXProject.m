//
//  PBXProject.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"

#import "DDCliUtil.h"

@interface PBXProject ()

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSArray *targetUUIDs;
@property (nonatomic, retain) NSString *configurationListUUID;

@end

@implementation PBXProject

#pragma mark Class methods

+ (PBXProject *)projectInProjFile:(PBXProjFile *)projFile
{
    for (NSString *uuid in [projFile.objectsDict allKeys]) {
        // Only consider projects
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:uuid];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"PBXProject"]) {
            continue;
        }
        
        // Extract project data
        PBXProject *project = [[[PBXProject alloc] init] autorelease];
        project.uuid = uuid;
        project.targetUUIDs = [propertiesDict objectForKey:@"targets"];
        project.configurationListUUID = [propertiesDict objectForKey:@"buildConfigurationList"];
        
        return project;
    }
    
    ddprintf(@"[ERROR] No project data found in %@", projFile);
    return nil;
}

#pragma Object creation and destruction

- (void)dealloc
{
    self.uuid = nil;
    self.targetUUIDs = nil;
    self.configurationListUUID = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize uuid = m_uuid;

@synthesize targetUUIDs = m_targetUUIDs;

@synthesize configurationListUUID = m_configurationListUUID;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; uuid: %@; targetUUIDs: %@; configurationListUUID: %@>", 
            [self class],
            self,
            self.uuid,
            self.targetUUIDs,
            self.configurationListUUID];
}

@end
