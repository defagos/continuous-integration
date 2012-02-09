//
//  PBXProject.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProjFile.h"

@interface PBXProject : NSObject {
@private
    NSString *m_hash;
    NSArray *m_targetHashes;
    NSString *m_configurationListHash;
}

+ (NSArray *)projectsInProjFile:(PBXProjFile *)projFile;

@property (nonatomic, readonly, retain) NSString *hash;
@property (nonatomic, readonly, retain) NSArray *targetHashes;
@property (nonatomic, readonly, retain) NSString *configurationListHash;

@end
