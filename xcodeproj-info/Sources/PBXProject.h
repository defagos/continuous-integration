//
//  PBXProject.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProjFile.h"

/**
 * Class for parsing and storing Xcode project data
 *
 * Designated initializer: init
 */
@interface PBXProject : NSObject {
@private
    NSString *m_uuid;
    NSArray *m_targetUUIDs;
    NSString *m_configurationListUUID;
}

/**
 * Parse a .pbxproj file and returns the array of projects found within it as an array of PBXProject objects
 */
+ (NSArray *)projectsInProjFile:(PBXProjFile *)projFile;

/**
 * Project data
 */
@property (nonatomic, readonly, retain) NSString *uuid;
@property (nonatomic, readonly, retain) NSArray *targetUUIDs;
@property (nonatomic, readonly, retain) NSString *configurationListUUID;

@end
