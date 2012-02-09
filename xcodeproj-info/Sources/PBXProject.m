//
//  PBXProject.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"

@interface PBXProject ()

@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSArray *targetHashes;
@property (nonatomic, retain) NSString *configurationListHash;

@end

@implementation PBXProject

#pragma mark Class methods

+ (NSArray *)projectsInProjFile:(PBXProjFile *)projFile
{
    NSMutableArray *projects = [NSMutableArray array];
    for (NSString *hash in [projFile.objectsDict allKeys]) {
        // Only consider projects
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:hash];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"PBXProject"]) {
            continue;
        }
        
        // Extract project data
        PBXProject *project = [[[PBXProject alloc] init] autorelease];
        project.hash = hash;
        project.targetHashes = [propertiesDict objectForKey:@"targets"];
        project.configurationListHash = [propertiesDict objectForKey:@"buildConfigurationList"];
        [projects addObject:project];
    }
    return [NSArray arrayWithArray:projects];
}

#pragma Object creation and destruction

- (void)dealloc
{
    self.hash = nil;
    self.targetHashes = nil;
    self.configurationListHash = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize hash = m_hash;

@synthesize targetHashes = m_targetHashes;

@synthesize configurationListHash = m_configurationListHash;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; hash: %@; targetHashes: %@; configurationListHash: %@>", 
            [self class],
            self,
            self.hash,
            self.targetHashes,
            self.configurationListHash];
}

@end
