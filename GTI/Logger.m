//
//  Logger.m
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 17/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//

#include "Logger.h"

/**
 * Logs instance of class with specified class type
 */
void ICLog(id instance, Class classType)
{
    NSLog(@"%@:%p{%@}",[instance class], instance, reflectWithClass(instance, classType));
}

/**
 * Logs instance of class
 */
void ILog(id instance)
{
    NSLog(@"%@", reflect(instance));
}

NSString *reflectWithClass(id instance, Class classType)
{
    NSUInteger count;
    // get all class properties
    objc_property_t *propertyList = class_copyPropertyList(classType, &count);
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < count; i++)
    {
        // get particular property
        objc_property_t property = propertyList[i];
        // get property name
        NSString *name =[NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        if(name) 
        {
            // get property value
            id value = [instance valueForKey:name];
            [result appendString:[NSString stringWithFormat:@"{%@=%@}", name, value]];
        }
    }
    free(propertyList);
    
    // add properties from superclass
    Class superClass = class_getSuperclass(classType);
    if (superClass != nil && ! [superClass isEqual:[NSObject class]])
    {
        // recursive call
        [result appendString:reflectWithClass(instance, superClass)];
    }
    
    return result;
}

NSString *reflect(id instance)
{
    return [NSString stringWithFormat:@"%@:%p{%@}",
            [instance class], instance, reflectWithClass(instance, [instance class])];
}



