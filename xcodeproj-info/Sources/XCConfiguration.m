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
 * Parse a .pbxproj file and returns the array of configurations for a given configuration hash
 * code list, array of XCConfiguration objects
 */ 
+ (NSArray *)configurationsFromConfigurationListHash:(NSString *)configurationListHash inProjFile:(PBXProjFile *)projFile;

@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sdk;

@end

@implementation XCConfiguration

#pragma mark Class methods

+ (NSArray *)configurationsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile
{
    return [self configurationsFromConfigurationListHash:project.configurationListHash inProjFile:projFile];
}

+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile
{
    return [self configurationsFromConfigurationListHash:target.configurationListHash inProjFile:projFile];
}

+ (NSArray *)configurationsFromConfigurationListHash:(NSString *)configurationListHash inProjFile:(PBXProjFile *)projFile
{
    NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationListHash];
    if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCConfigurationList"]) {
        ddprintf(@"[WARN] The hash %@ does not correspond to a configuration list; skipped\n", configurationListHash);
        return nil;
    }
    NSArray *configurationHashes = [propertiesDict objectForKey:@"buildConfigurations"];
    
    NSMutableArray *configurations = [NSMutableArray array];
    for (NSString *configurationHash in configurationHashes) {
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:configurationHash];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"XCBuildConfiguration"]) {
            ddprintf(@"[WARN] The hash %@ does not correspond to a configuration; skipped\n", configurationHash);
            continue;
        }
        
        XCConfiguration *configuration = [[[XCConfiguration alloc] init] autorelease];
        configuration.hash = configurationHash;
        configuration.name = [propertiesDict objectForKey:@"name"];
        configuration.sdk = [[propertiesDict objectForKey:@"buildSettings"] objectForKey:@"SDKROOT"];
        [configurations addObject:configuration];
    }
    
    return [NSArray arrayWithArray:configurations];
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.hash = nil;
    self.name = nil;
    self.sdk = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize hash = m_hash;

@synthesize name = m_name;

@synthesize sdk = m_sdk;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; hash: %@; name: %@; sdk: %@>", 
            [self class],
            self,
            self.hash,
            self.name,
            self.sdk];
}

@end
