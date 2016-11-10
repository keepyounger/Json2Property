//
//  SourceEditorCommand.h
//  Json2PropertyExtension
//
//  Created by 李向阳 on 2016/10/21.
//  Copyright © 2016年 ifang. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface SourceEditorCommand : NSObject <XCSourceEditorCommand>

@property (nonatomic) BOOL isSwift;

@end
