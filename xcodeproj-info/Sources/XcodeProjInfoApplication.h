//
//  XcodeProjInfoApplication.h
//  xcodeproj-info
//
//  Created by Samuel Défago on 09.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "DDCommandLineInterface.h"

@interface XcodeProjInfoApplication : NSObject <DDCliApplicationDelegate> {
@private
    NSString *m_project;
    BOOL m_help;
    BOOL m_version;
}

// Command line parameters with argument
@property (nonatomic, retain) NSString *project;

// Command-line parameters without argument
@property (nonatomic, assign, getter=isHelp) BOOL help;
@property (nonatomic, assign, getter=isVersion) BOOL version;

@end
