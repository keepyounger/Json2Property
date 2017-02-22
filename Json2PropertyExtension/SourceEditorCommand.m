//
//  SourceEditorCommand.m
//  Json2PropertyExtension
//
//  Created by 李向阳 on 2016/10/21.
//  Copyright © 2016年 ifang. All rights reserved.
//

#define ESRootClassName @"ESRootClass"

#import "SourceEditorCommand.h"
#import "ESClassInfo.h"
#import <AppKit/AppKit.h>

@interface SourceEditorCommand ()
@property (nonatomic, strong) XCSourceTextBuffer *buffer;
@property (nonatomic, copy) void(^completionHandler)(NSError * _Nullable nilOrError);
@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    self.completionHandler = completionHandler;
    self.buffer = invocation.buffer;
    self.isSwift = [self.buffer.contentUTI rangeOfString:@"swift"].length!=0;
    
    XCSourceTextRange *range = self.buffer.selections.firstObject;
    NSString *jsonString = @"";
    for (NSInteger i=range.start.line; i<=range.end.line; i++) {
        if (i<self.buffer.lines.count) {
            jsonString = [NSString stringWithFormat:@"%@%@",jsonString,self.buffer.lines[i]];
        }
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if (err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = err.localizedDescription;
            [alert addButtonWithTitle:@"OK"];
            alert.window.level = NSStatusWindowLevel;
            [alert.window makeKeyAndOrderFront:alert.window];
            if([alert runModal] == NSAlertFirstButtonReturn) {
                
            }
            self.completionHandler(nil);
        });
    } else {
        ESClassInfo *classInfo = [self dealClassNameWithJsonResult:dicOrArray];
        [self outputResult:classInfo];
        self.completionHandler(nil);
    }
    
}

/**
 *  初始类名，RootClass/JSON为数组/创建文件与否
 *
 *  @param result JSON转成字典或者数组
 *
 *  @return 类信息
 */
- (ESClassInfo *)dealClassNameWithJsonResult:(id)result{
    __block ESClassInfo *classInfo = nil;
    //如果当前是JSON对应是字典
    if ([result isKindOfClass:[NSDictionary class]]) {

        //不生成到文件，Root class 里面用户自己创建
        classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:result];
        classInfo.isSwift = self.isSwift;
        [self dealPropertyNameWithClassInfo:classInfo];
        
    }else if([result isKindOfClass:[NSArray class]]){
        NSDictionary *dic = [NSDictionary dictionaryWithObject:result forKey:@"<#ClassName#>"];
        classInfo = [[ESClassInfo alloc] initWithClassNameKey:ESRootClassName ClassName:ESRootClassName classDic:dic];
        classInfo.isSwift = self.isSwift;
        [self dealPropertyNameWithClassInfo:classInfo];
    }
    return classInfo;
}

/**
 *  处理属性名字(用户输入属性对应字典对应类或者集合里面对应类的名字)
 *
 *  @param classInfo 要处理的ClassInfo
 *
 *  @return 处理完毕的ClassInfo
 */
- (ESClassInfo *)dealPropertyNameWithClassInfo:(ESClassInfo *)classInfo{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:classInfo.classDic];
    for (NSString *key in dic) {
        //取出的可能是NSDictionary或者NSArray
        id obj = dic[key];
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            if ([obj isKindOfClass:[NSArray class]]) {
                //May be 'NSString'，will crash
                if (!([[obj firstObject] isKindOfClass:[NSDictionary class]] || [[obj firstObject] isKindOfClass:[NSArray class]])) {
                    continue;
                }
            }
           
            NSString *childClassName = @"<#ClassName#>";
            //如果当前obj是 NSDictionary 或者 NSArray，继续向下遍历
            if ([obj isKindOfClass:[NSDictionary class]]) {
                ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:obj];
                childClassInfo.isSwift = classInfo.isSwift;
                [self dealPropertyNameWithClassInfo:childClassInfo];
                //设置classInfo里面属性对应class
                [classInfo.propertyClassDic setObject:childClassInfo forKey:key];
            }else if([obj isKindOfClass:[NSArray class]]){
                //如果是 NSArray 取出第一个元素向下遍历
                NSArray *array = obj;
                if (array.firstObject) {
                    NSObject *obj = [array firstObject];
                    //May be 'NSString'，will crash
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:(NSDictionary *)obj];
                        childClassInfo.isSwift = classInfo.isSwift;
                        [self dealPropertyNameWithClassInfo:childClassInfo];
                        //设置classInfo里面属性类型为 NSArray 情况下，NSArray 内部元素类型的对应的class
                        [classInfo.propertyArrayDic setObject:childClassInfo forKey:key];
                    }
                }
            }
        }
    }
    return classInfo;
}

-(void)outputResult:(ESClassInfo*)info{
    ESClassInfo *classInfo = info;
    
    XCSourceTextRange *range = self.buffer.selections.firstObject;
    [self.buffer.lines removeObjectsInRange:NSMakeRange(range.start.line, range.end.line-range.start.line+1)];
    
    //先添加主类的属性
    [self.buffer.lines insertObject:classInfo.propertyContent atIndex:range.start.line];
    
    //再添加把其他类的的字符串拼接到最后面
    [self.buffer.lines insertObject:classInfo.classInsertTextViewContentForH atIndex:self.buffer.lines.count];
    
    if (!info.isSwift) {
        //@class
        NSString *atClassContent = classInfo.atClassContent;
        NSInteger index = -1;
        for (int i=0; i<self.buffer.lines.count; i++) {
            NSString *str = self.buffer.lines[i];
            if ([str rangeOfString:@"@interface"].length>0) {
                index = i;
                break;
            }
        }
        if (index!=-1 && atClassContent.length>0) {
            [self.buffer.lines insertObject:[NSString stringWithFormat:@"\n%@\n",atClassContent] atIndex:index];
        }
    }
  
    XCSourceTextRange *selection = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(0, 0) end:XCSourceTextPositionMake(0, 0)];
    [self.buffer.selections removeAllObjects];
    [self.buffer.selections insertObject:selection atIndex:0];
}

@end
