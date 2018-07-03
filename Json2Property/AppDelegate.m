//
//  AppDelegate.m
//  Json2Property
//
//  Created by 李向阳 on 2016/10/21.
//  Copyright © 2016年 ifang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *textField;

@end

@implementation AppDelegate

- (IBAction)helpClick:(NSMenuItem *)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/keepyounger/Json2Property"]];
}

- (IBAction)doneClick:(NSButton *)sender {
    NSString *str = self.textField.stringValue;
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [pathes.firstObject stringByReplacingOccurrencesOfString:@"/Documents" withString:@"/Library/Containers/com.ifang.Json2Property.Json2PropertyExtension/Data/Documents"];
    NSError *error = nil;
    NSString *path = [documents stringByAppendingPathComponent:@"SuperClass.txt"];
    [str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    if (!error) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"done";
        [alert addButtonWithTitle:@"OK"];
        alert.window.level = NSStatusWindowLevel;
        [alert.window makeKeyAndOrderFront:alert.window];
        
        if([alert runModal] == NSAlertFirstButtonReturn) {
            
        }
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = error.localizedDescription;
        [alert addButtonWithTitle:@"OK"];
        alert.window.level = NSStatusWindowLevel;
        [alert.window makeKeyAndOrderFront:alert.window];
        
        if([alert runModal] == NSAlertFirstButtonReturn) {
            
        }
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
