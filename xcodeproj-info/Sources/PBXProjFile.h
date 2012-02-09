//
//  PBXProjFile.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface PBXProjFile : NSObject {
@private
    NSDictionary *m_objectsDict;
}

- (id)initWithFileName:(NSString *)fileName;

@property (nonatomic, readonly, retain) NSDictionary *objectsDict;

@end
