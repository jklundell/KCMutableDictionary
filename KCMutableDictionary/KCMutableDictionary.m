//
//  KCMutableDictionary.m
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

static NSString *_kcKey = nil;

#import "KCMutableDictionary.h"

@interface KCMutableDictionary ()

@property (strong, nonatomic) NSMutableDictionary *kcDict;

@end

@implementation KCMutableDictionary

//  Save our data dictionary to the keychain
//
- (BOOL)_saveDict
{
    //  Serialize our dictionary
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.kcDict
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (error) {
        NSLog(@"NSPropertyListSerialization error: %@", error);
        return NO;
    }

    //  Delete the old copy first
    OSStatus status;
    NSDictionary *query = @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecReturnData : (id)kCFBooleanTrue,
        (__bridge id)kSecAttrService : _kcKey
    };
    status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        NSLog(@"SecItemDelete failed: %ld", status);
        return NO;
    }

    //  Add serialized dictionary to the keychain
    NSDictionary *dict = @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService : _kcKey,
        (__bridge id)kSecValueData : data
    };
    status = SecItemAdd ((__bridge CFDictionaryRef)dict, NULL);
    if (status != errSecSuccess) {
        NSLog(@"SecItemAdd failed: %ld", status);
        return NO;
    }
    return YES;
}

//  Fetch our data dictionary from the keychain
//
- (BOOL)_fetchDict
{
    //  Fetch the serialized dictionary from the keychain
    NSDictionary *query = @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecReturnData : (id)kCFBooleanTrue,
        (__bridge id)kSecAttrService : _kcKey
    };
    
    CFDataRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    
    //  If not found, initialize with our data dictionary
    if (status == errSecItemNotFound) {
        if (!self.kcDict)
            self.kcDict = NSMutableDictionary.new;
        return [self _saveDict];
    }
    
    if (status != errSecSuccess) {
        NSLog(@"SecItemCopyMatching failed: %ld", status);
        return NO;
    }
    
    //  Deserialize the data into our local copy
    if (data) {
        NSError *error = nil;
        NSMutableDictionary *kcDict = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)(data)
                                                                options:NSPropertyListMutableContainers
                                                                 format:NULL
                                                                  error:&error];
        if (error) {
            NSLog(@"NSPropertyListSerialization error: %@", error);
            return NO;
        }
        self.kcDict = kcDict;
    }
    return YES;
}

#pragma mark - NSDictionary methods

static KCMutableDictionary *_sharedDictionary = nil;

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    if (objects.count || keys.count) {
        [NSException raise:@"bad_init" format:@"KCMutableDictionarry cannot be initialized with data"];
        return nil;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self) {
            _sharedDictionary = self;
            NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
            _kcKey = [bundleID stringByAppendingString:@".__KCMutableDictionary__"];
            [self _fetchDict];
        }
    });
    return _sharedDictionary;
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithObjects:@[] forKeys:@[]];
}

- (id)init
{
    return [self initWithObjects:@[] forKeys:@[]];
}

- (NSUInteger)count
{
    return self.kcDict.count;
}

- (id)objectForKey:(id)aKey
{
    return [self.kcDict objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return self.kcDict.keyEnumerator;
}

#pragma mark - NSMutableDictionary methods

- (void)setObject:(id)anObject forKey:(id < NSCopying >)aKey
{
    [self.kcDict setObject:anObject forKey:aKey];
    if ([self _saveDict])
        [self _fetchDict];  // re-fetch so we end up with immutable copies of values
}

- (void)removeObjectForKey:(id)aKey
{
    [self.kcDict removeObjectForKey:aKey];
    [self _saveDict];
}

@end
