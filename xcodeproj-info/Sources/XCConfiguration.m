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

+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile
{
    // Extract configurations at the project level
    NSMutableDictionary *nameToConfigurationMap = [NSMutableDictionary dictionary];
    NSArray *projectConfigurations = [self configurationsFromConfigurationListUUID:target.project.configurationListUUID 
                                                                        inProjFile:projFile];
    for (XCConfiguration *projectConfiguration in projectConfigurations) {
        [nameToConfigurationMap setObject:projectConfiguration forKey:projectConfiguration.name];
    }
    
    // Override with configurations associated with the target (if any)
    NSArray *targetConfigurations = [XCConfiguration configurationsFromConfigurationListUUID:target.configurationListUUID
                                                                                  inProjFile:projFile];
    for (XCConfiguration *targetConfiguration in targetConfigurations) {
        // Find project configuration to override
        XCConfiguration *projectConfiguration = [nameToConfigurationMap objectForKey:targetConfiguration.name];
        if (! projectConfiguration) {
            continue;
        }
        
        // Override values
        if (targetConfiguration.sdk) {
            projectConfiguration.sdk = targetConfiguration.sdk;
        }
    }
    
    NSSortDescriptor *uuidSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES];
    return [[nameToConfigurationMap allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:uuidSortDescriptor]];
}

+ (NSArray *)configurationsFromConfigurationListUUID:(NSString *)configurationListUUID inProjFile:(PBXProjFile *)projFile
{
    // Extract configuration UUIDs from the configuration list
    NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationListUUID];
    if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCConfigurationList"]) {
        ddprintf(@"[WARN] The uuid %@ does not correspond to a configuration list; skipped\n", configurationListUUID);
        return nil;
    }
    NSArray *configurationUUIDs = [propertiesDict objectForKey:@"buildConfigurations"];
    
    // Extract configurations
    NSMutableArray *configurations = [NSMutableArray array];
    for (NSString *configurationUUID in configurationUUIDs) {
        // Check that the uuid corresponds to a configuration
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationUUID];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCBuildConfiguration"]) {
            ddprintf(@"[WARN] The uuid %@ does not correspond to a configuration; skipped\n", configurationUUID);
            continue;
        }
        
        // Extract configuration data
        XCConfiguration *configuration = [[[XCConfiguration alloc] init] autorelease];
        configuration.uuid = configurationUUID;
        configuration.name = [propertiesDict objectForKey:@"name"];
        configuration.sdk = [[propertiesDict objectForKey:@"buildSettings"] objectForKey:@"SDKROOT"];
        [configurations addObject:configuration];
    }
    
    NSSortDescriptor *uuidSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES];
    return [configurations sortedArrayUsingDescriptors:[NSArray arrayWithObject:uuidSortDescriptor]];
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
