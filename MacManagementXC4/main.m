//
//  main.m
//  MacManagementXC4
//
//  Created by Houle, Todd on 8/19/14.
//  Copyright (c) 2014 Partners. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, char *argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, (const char **)argv);
}
