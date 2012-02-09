//
//  PBXTarget.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXTarget.h"

#import "DDCliUtil.h"

@interface PBXTarget ()

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *configurationListUUID;
@property (nonatomic, retain) PBXProject *project;

@end

@implementation PBXTarget

#pragma mark Class methods

+ (NSArray *)targetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile
{
    NSMutableArray *targets = [NSMutableArray array];
    for (NSString *targetUUID in project.targetUUIDs) {
        // Check that the uuid corresponds to a target (can also be script phases, e.g., which we are not interested in)
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:targetUUID];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"PBXNativeTarget"]) {
            continue;
        }
        
        // Extract target data
        PBXTarget *target = [[[PBXTarget alloc] init] autorelease];
        target.uuid = targetUUID;
        target.name = [propertiesDict objectForKey:@"name"];
        target.configurationListUUID = [propertiesDict objectForKey:@"buildConfigurationList"];
        target.project = project;
        [targets addObject:target];    
    }
    return [NSArray arrayWithArray:targets];
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.uuid = nil;
    self.name = nil;
    self.configurationListUUID = nil;
    self.project = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize uuid = m_uuid;

@synthesize name = m_name;

@synthesize configurationListUUID = m_configurationListUUID;

@synthesize project = m_project;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; uuid: %@; name: %@; configurationListUUID: %@>", 
            [self class],
            self,
            self.uuid,
            self.name,
            self.configurationListUUID];
}

@end
