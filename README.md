KCMutableDictionary
===================

KCMutableDictionary is a subclass of NSMutableDictionary that is transparently persisted in the app's keychain. The general idea is to make secure storage of small items in the keychain as easy as using a dictionary.

Four restrictions are imposed:

1. KCMutableDictionary may not be initialzed with data. Use, for example, [KCMutableDictionary dictionary] or KCMutableDictionary.new.

2. Keys and values are restricted to property list objects, that is, objects that can be serialized with NSPropertyListSerialization. This includes NSData, NSString, NSArray, NSDictionary, NSDate, and NSNumber, but not (for example) NSSet.

3. Mutable values may be stored in KCMutableDictionary, but they will be effectively be copied to their immutable variants.

4. Reads are fast, but writes are slow.

KCMutableDictionary was inspired by Mark Granoff's [granoff/Lockbox](https://github.com/granoff/Lockbox) and a suggestion by [Ernesto Rivera](https://github.com/rivera-ernesto).