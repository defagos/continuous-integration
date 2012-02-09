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

@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *configurationListHash;

@end

@implementation PBXTarget

#pragma mark Class methods

+ (NSArray *)targetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile
{
    NSMutableArray *targets = [NSMutableArray array];
    for (NSString *targetHash in project.targetHashes) {
        // Check that the hash corresponds to a target
        NSDictionary *propertiesDict = [projFile.objectsDict objectForKey:targetHash];
        if (! [[propertiesDict objectForKey:@"isa"] isEqualToString:@"PBXNativeTarget"]) {
            ddprintf(@"[WARN] The hash %@ does not correspond to a target; skipped\n", targetHash);
            continue;
        }
        
        // Extract target data
        PBXTarget *target = [[[PBXTarget alloc] init] autorelease];
        target.hash = targetHash;
        target.name = [propertiesDict objectForKey:@"name"];
        target.configurationListHash = [propertiesDict objectForKey:@"buildConfigurationList"];
        [targets addObject:target];    
    }
    return [NSArray arrayWithArray:targets];
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.hash = nil;
    self.name = nil;
    self.configurationListHash = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize hash = m_hash;

@synthesize name = m_name;

@synthesize configurationListHash = m_configurationListHash;

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; hash: %@; name: %@; configurationListHash: %@>", 
            [self class],
            self,
            self.hash,
            self.name,
            self.configurationListHash];
}

@end
