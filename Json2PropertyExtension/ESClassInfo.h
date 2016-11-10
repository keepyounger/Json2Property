//
//  ESClassInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESClassInfo : NSObject

@property (nonatomic) BOOL isSwift;

/**
 *  实体类的类名
 */
@property (nonatomic, copy) NSString *className;
/**
 *  当前类在JSON里面对应的key
 */
@property (nonatomic, copy) NSString *classNameKey;
/**
 *  当前类对应的字典
 */
@property (nonatomic, strong) NSDictionary *classDic;

/**
 *  当前类里面属性对应为类的字典 [key->JSON字段的key : value->ESClassInfo对象]
 */
@property (nonatomic, strong) NSMutableDictionary *propertyClassDic;

/**
 *  当前类里属性对应为集合(指定集合里面存某个模型，用作MJExtension) [key->JSON字段的key : value->ESClassInfo对象]
 */
@property (nonatomic, strong) NSMutableDictionary *propertyArrayDic;

/**
 *  atclass 内容，用于在创建类文件的时候，指定当前类里面引用哪些类-->通过遍历propertyClassDic生成
 */
@property (nonatomic, copy) NSString *atClassContent;

/**
 *  当前类的需要引用的calss集合
 */
@property (nonatomic, copy) NSArray *atClassArray;


/**
 *  所有属性对应的格式化的内容
 */
@property (nonatomic, copy) NSString *propertyContent;

/**
 *  整个类头文件的内容，包含头与尾 -- 会根据是否创建文件添加模板文字
 */
@property (nonatomic, copy) NSString *classContentForH;

/**
 *  直接插入到.h文件或者与.swift文件中内容 -- 不包含当前类里面属性字段，只有里面引用类的.h文件内容
 */
@property (nonatomic, copy) NSString *classInsertTextViewContentForH;


- (instancetype)initWithClassNameKey:(NSString *)classNameKey ClassName:(NSString *)className classDic:(NSDictionary *)classDic;

@end

