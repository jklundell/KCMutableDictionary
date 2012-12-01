//
//  KCMutableDictionary.h
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCMutableDictionary : NSMutableDictionary

+ (KCMutableDictionary *)dictionary;                            // return default singleton dictionary
+ (KCMutableDictionary *)dictionaryWithName:(NSString *)name;   // return named singleton dictionary
- (void)forget;                                                 // release singleton dictionary

@end
