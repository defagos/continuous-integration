//
//  main.m
//  xcodeproj-info
//
//  Created by Samuel Défago on 08.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PBXProject.h"
#import "PBXProjFile.h"
#import "PBXTarget.h"
#import "XCConfiguration.h"
#import "XcodeProjInfoApplication.h"

int main (int argc, const char *argv[])
{
    // TODO: Get projects & targets. If a target overrides the project settings, use them. Return the list
    //       of configuration name with SDK
    
    @autoreleasepool {        
        return DDCliAppRunWithClass([XcodeProjInfoApplication class]);
    }
    return 0;
}

