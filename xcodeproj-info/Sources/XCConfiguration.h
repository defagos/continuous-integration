//
//  XCConfiguration.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"
#import "PBXProjFile.h"
#import "PBXTarget.h"

@interface XCConfiguration : NSObject {
@private
    NSString *m_hash;
    NSString *m_name;
    NSString *m_sdk;
}

+ (NSArray *)configurationsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile;
+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile;

@property (nonatomic, readonly, retain) NSString *hash;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *sdk;

@end

