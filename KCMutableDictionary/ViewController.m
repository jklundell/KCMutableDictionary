//
//  ViewController.m
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

#import "ViewController.h"
#import "KCMutableDictionary.h"

#define kKeyString    @"MyKeyString"
#define kKeyArray     @"MyKeyArray"
#define kKeyDict      @"MyKeyDict"
#define kKeyDate      @"MyKeyDate"

enum {
    kSaveAsString = 0,
    kSaveAsArray,
    kSaveAsDict,
    kSaveDate
};

@interface ViewController ()

@property (nonatomic, strong) KCMutableDictionary *kcDict;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:(NSString *)nibBundleOrNil bundle:nibBundleOrNil];
    if (self) {
        self.kcDict = [KCMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self.inputTextField resignFirstResponder];
    
    UIButton *b = (UIButton *)sender;
    NSString *value = self.inputTextField.text;
    NSString *status = @"Error saving";
    
    switch (b.tag) {
        case kSaveAsString:
            [self.kcDict setObject:value forKey:kKeyString];
            status = @"String saved";
            break;
            
        case kSaveAsArray:
        {
            value = [value stringByAppendingString:@" - array element"];
            NSArray *array = @[
                [value stringByAppendingString:@" 1"],
                [value stringByAppendingString:@" 2"],
                [value stringByAppendingString:@" 3"],
            ];
            [self.kcDict setObject:array forKey:kKeyArray];
            status = @"Array saved";
            break;
        }
            
        case kSaveAsDict:
        {
            value = [value stringByAppendingString:@" - dict element"];
            NSDictionary *dict = @{
                @"1" : [value stringByAppendingString:@" 1"],
                @"2" : [value stringByAppendingString:@" 2"],
                @"3" : [value stringByAppendingString:@" 3"],
            };
            [self.kcDict setObject:dict forKey:kKeyDict];
            status = @"Dictionary saved";
            break;
        }
            
        case kSaveDate:
            [self.kcDict setObject:[NSDate date] forKey:kKeyDate];
            status = @"Date saved";
            break;
    }
    
    self.statusLabel.text = status;
}

-(IBAction)fetchButtonPressed:(id)sender
{
    [self.inputTextField resignFirstResponder];
    UIButton *b = (UIButton *)sender;
    NSString *value = @"";
    NSString *status = @"Error fetching";
    
    switch (b.tag) {
        case kSaveAsString:
            value = [NSString stringWithFormat:@"string=\"%@\"", [self.kcDict objectForKey:kKeyString]];
            status = @"String fetched";
            break;
            
        case kSaveAsArray:
        {
            NSArray *array = [self.kcDict objectForKey:kKeyArray];
            value = [NSString stringWithFormat:@"array=%@", array];
            status = @"Array fetched";
            break;
        }
            
        case kSaveAsDict:
        {
            NSDictionary *dict = [self.kcDict objectForKey:kKeyDict];
            value = [NSString stringWithFormat:@"dict=%@", dict];
            status = @"Dictionary fetched";
            break;
        }
            
        case kSaveDate:
        {
            NSDate *date = [self.kcDict objectForKey:kKeyDate];
            value = [NSString stringWithFormat:@"date=%@", date.description];
            status = @"Date fetched";
            break;
        }
    }
    
    self.statusLabel.text = status;
    self.fetchedValueLabel.text = value;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
