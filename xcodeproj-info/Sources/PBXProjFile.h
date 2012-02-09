//
//  PBXProjFile.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Class for loading a .pbxproj file
 *
 * Designated initializer: init
 */
@interface PBXProjFile : NSObject {
@private
    NSDictionary *m_objectsDict;
}

/**
 * Parse and load a .pbxproj file
 */
- (id)initWithFilePath:(NSString *)filePath;

/**
 * Dictionary of the objects contained within the .pbxproj file
 */
@property (nonatomic, readonly, retain) NSDictionary *objectsDict;

@end
