//
//  PersistenceManager.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 06/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PersistenceManager : NSObject
{
	NSManagedObjectModel *_managedObjectModel;
	NSManagedObjectContext *_managedObjectContext;		
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (PersistenceManager *)sharedPersistenceManager;

- (void)saveManagedContext;

@end
