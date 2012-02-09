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
 * Parse a .pbxproj file and returns the array of configurations for a given project, as an
 * array of XCConfiguration objects. The result takes into account overriding which might
 * have been made by targets
 */
+ (NSArray *)configurationsForProject:(PBXProject *)project inProjFile:(PBXProjFile *)projFile;

/**
 * Configuration data
 */
@property (nonatomic, readonly, retain) NSString *uuid;
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *sdk;

@end

