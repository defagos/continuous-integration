//
//  PBXTarget.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"
#import "PBXProjFile.h"

/**
 * Class for parsing and storing Xcode target data
 *
 * Designated initializer: init
 */
@interface PBXTarget : NSObject {
@private
    NSString *m_hash;
    NSString *m_name;
    NSString *m_configurationListHash;
}

/**
 * Parse a .pbxproj file and returns the array of targets found within it as an array of PBXTarget objects
 */
+ (NSArray *)targetsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile;

/**
 * Target data
 */
@property (nonatomic, readonly, retain) NSString *hash;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *configurationListHash;

@end
