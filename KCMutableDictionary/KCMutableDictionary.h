//
//  KCMutableDictionary.h
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCMutableDictionary : NSMutableDictionary

- (id)initWithName:(NSString *)name;    // optional initializer for named dictionaries

@end
