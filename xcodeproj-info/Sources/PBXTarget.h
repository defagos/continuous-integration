//
//  PBXTarget.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"
#import "PBXProjFile.h"

@interface PBXTarget : NSObject {
@private
    NSString *m_hash;
    NSString *m_name;
    NSString *m_configurationListHash;
}

+ (NSArray *)targetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile;

@property (nonatomic, readonly, retain) NSString *hash;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *configurationListHash;

@end
