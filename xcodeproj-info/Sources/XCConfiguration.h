//
//  XCConfiguration.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProjFile.h"
#import "PBXTarget.h"

/**
 * Class for parsing and storing Xcode project / target configuration data
 *
 * Designated initializer: init
 */
@interface XCConfiguration : NSObject {
@private
    NSString *m_uuid;
    NSString *m_name;
    NSString *m_sdk;
}

/**
 * Parse a .pbxproj file and returns the array of configurations for a given target
 */
+ (NSArray *)configurationsForTarget:(PBXTarget *)target inProjFile:(PBXProjFile *)projFile;

/**
 * Configuration data
 */
@property (nonatomic, readonly, retain) NSString *uuid;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *sdk;

@end

