//
//  PBXProjFile.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProjFile.h"

#import "DDCliUtil.h"

@interface PBXProjFile ()

@property (nonatomic, retain) NSDictionary *objectsDict;

@end

@implementation PBXProjFile

- (id)initWithFilePath:(NSString *)filePath
{
    if ((self = [super init])) {
        if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            ddprintf(@"[ERROR] The project file %@ does not exist", filePath);
            [self release];
            return nil;
        }
        
        self.objectsDict = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:@"objects"];
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
