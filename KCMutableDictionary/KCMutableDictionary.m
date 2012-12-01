//
//  KCMutableDictionary.m
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

#import "KCMutableDictionary.h"

@interface KCMutableDictionary ()

@property (strong, nonatomic) NSMutableDictionary *kcDict;
@property (strong, nonatomic) NSString *kcKey;

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
        (__bridge id)kSecAttrService : self.kcKey
    };
    status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        NSLog(@"SecItemDelete failed: %ld", status);
        return NO;
    }

    //  Add serialized dictionary to the keychain
    NSDictionary *dict = @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService : self.kcKey,
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
- (void)_fetchDict
{
    //  Fetch the serialized dictionary from the keychain
    NSDictionary *query = @{
        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecReturnData : (id)kCFBooleanTrue,
        (__bridge id)kSecAttrService : self.kcKey
    };
    
    CFDataRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    
    //  If not found, initialize with our current data dictionary
    if (status == errSecItemNotFound) {
        if (!self.kcDict) {
            self.kcDict = NSMutableDictionary.new;
        }
        [self _saveDict];
        return;
    }
    
    if (status != errSecSuccess) {
        NSLog(@"SecItemCopyMatching failed: %ld", status);
        return;
    }
    
    //  Deserialize the data into our local copy
    if (data) {
        NSError *error = nil;
        NSMutableDictionary *kcDict = [NSPropertyListSerialization
                                       propertyListWithData:(__bridge_transfer NSData *)(data)
                                       options:NSPropertyListMutableContainers
                                       format:NULL
                                       error:&error];
        if (error) {
            NSLog(@"NSPropertyListSerialization error: %@", error);
            return;
        }
        self.kcDict = kcDict;
    }
    return;
}

#pragma mark - NSDictionary methods

static NSDate *syncObject;
static NSMutableDictionary *_sharedDictionaries = nil;  // Dictionary of singleton KCMutableDictionary keyed by name

+ (void)initialize
{
    _sharedDictionaries = NSMutableDictionary.new;
}

+ (NSString *)keyFromName:(NSString *)name
{
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSString *key = [bundleID stringByAppendingString:@".__KCMutableDictionary__"];
    if (name)
        key = [key stringByAppendingFormat:@".%@", name];
    return key;
}

//  Allow named dictionaries, but supply a name by default.
//
+ (KCMutableDictionary *)dictionaryWithName:(NSString *)name
{
    NSString *key = [KCMutableDictionary keyFromName:name];
    @synchronized(_sharedDictionaries) {
        KCMutableDictionary *sharedDictionary = _sharedDictionaries[key];
        if (sharedDictionary)
            return sharedDictionary;
        return [[KCMutableDictionary alloc] initWithKey:key];
    }
}

+ (KCMutableDictionary *)dictionary
{
    return [KCMutableDictionary dictionaryWithName:nil];
}

- (id)initWithKey:(NSString *)key
{
    @synchronized(_sharedDictionaries) {
        KCMutableDictionary *sharedDictionary = _sharedDictionaries[key];
        if (sharedDictionary)
            self = sharedDictionary;
        else if (self) {
            self.kcKey = key;
            _sharedDictionaries[key] = self;
            [self _fetchDict];
        }
    }
    return self;
}

- (id)init
{
    return [self initWithKey:[KCMutableDictionary keyFromName:nil]];
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    if (objects.count || keys.count) {
        [NSException raise:@"bad_init" format:@"KCMutableDictionary cannot be initialized with data"];
        return nil;
    }
    return [self init];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    return [self init];
}

- (void)forget
{
    if (self.kcKey) {
        [_sharedDictionaries removeObjectForKey:self.kcKey];
        self.kcKey = nil;
        self.kcDict = nil;
    }
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
    @synchronized(syncObject) {
        [self.kcDict setObject:anObject forKey:aKey];
        if ([self _saveDict])
            [self _fetchDict];  // re-fetch so we end up with immutable copies of values
    }
}

- (void)removeObjectForKey:(id)aKey
{
    @synchronized(syncObject) {
        [self.kcDict removeObjectForKey:aKey];
        [self _saveDict];
    }
}

@end
