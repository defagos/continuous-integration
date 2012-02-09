//
//  PBXProjFile.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProjFile.h"

@interface PBXProjFile ()

@property (nonatomic, retain) NSDictionary *objectsDict;

@end

@implementation PBXProjFile

- (id)initWithFileName:(NSString *)fileName
{
    if ((self = [super init])) {
        self.objectsDict = [[NSDictionary dictionaryWithContentsOfFile:fileName] objectForKey:@"objects"];
    }
    return self;
}

- (void)dealloc
{
    self.objectsDict = nil;

    [super dealloc];
}

@synthesize objectsDict = m_objectsDict;

@end
