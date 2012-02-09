//
//  XCConfiguration.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "XCConfiguration.h"

#import "DDCliUtil.h"

@interface XCConfiguration ()

/**
 * Parse a .pbxproj file and returns the array of configurations for a given target, as an
 * array of XCConfiguration objects
 */ 
+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile;

/**
 * Parse a .pbxproj file and returns the array of configurations for a given configuration uuid
 * code list, array of XCConfiguration objects
 */ 
+ (NSArray *)configurationsFromConfigurationListUUID:(NSString *)configurationListUUID inProjFile:(PBXProjFile *)projFile;

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sdk;

@end

@implementation XCConfiguration

#pragma mark Class methods

+ (NSArray *)configurationsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile
{
    return [self configurationsFromConfigurationListUUID:project.configurationListUUID inProjFile:projFile];
}

+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile
{
    return [self configurationsFromConfigurationListUUID:target.configurationListUUID inProjFile:projFile];
}

+ (NSArray *)configurationsFromConfigurationListUUID:(NSString *)configurationListUUID inProjFile:(PBXProjFile *)projFile
{
    NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationListUUID];
    if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCConfigurationList"]) {
        ddprintf(@"[WARN] The uuid %@ does not correspond to a configuration list; skipped\n", configurationListUUID);
        return nil;
    }
    NSArray *configurationUUIDs = [propertiesDict objectForKey:@"buildConfigurations"];
    
    NSMutableArray *configurations = [NSMutableArray array];
    for (NSString *configurationUUID in configurationUUIDs) {
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationUUID];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCBuildConfiguration"]) {
            ddprintf(@"[WARN] The uuid %@ does not correspond to a configuration; skipped\n", configurationUUID);
            continue;
        }
        
        XCConfiguration *configuration = [[[XCConfiguration alloc] init] autorelease];
        configuration.uuid = configurationUUID;
        configuration.name = [propertiesDict objectForKey:@"name"];
        configuration.sdk = [[propertiesDict objectForKey:@"buildSettings"] objectForKey:@"SDKROOT"];
        [configurations addObject:configuration];
    }
    
    return [NSArray arrayWithArray:configurations];
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.uuid = nil;
    self.name = nil;
    self.sdk = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize uuid = m_uuid;

@synthesize name = m_name;

@synthesize sdk = m_sdk;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; uuid: %@; name: %@; sdk: %@>", 
            [self class],
            self,
            self.uuid,
            self.name,
            self.sdk];
}

@end
