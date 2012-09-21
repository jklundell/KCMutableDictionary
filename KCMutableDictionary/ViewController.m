//
//  ViewController.m
//  KCMutableDictionary
//
//  Created by Jonathan Lundell on 2012-09-21.
//  Copyright (c) 2012 Jonathan Lundell. All rights reserved.
//

#import "ViewController.h"
#import "KCMutableDictionary.h"

#define kMyKeyString    @"MyKeyString"
#define kMyKeyArray     @"MyKeyArray"
#define kMyKeyDict      @"MyKeyDict"

#define kSaveAsString 0
#define kSaveAsArray  1
#define kSaveAsDict   2

@interface ViewController ()

@property (nonatomic, strong) KCMutableDictionary *kcDict;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:(NSString *)nibBundleOrNil bundle:nibBundleOrNil];
    if (self) {
        self.kcDict = KCMutableDictionary.new;
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
    
    switch (b.tag) {
        case kSaveAsString:
            [self.kcDict setObject:value forKey:kMyKeyString];
            break;
            
        case kSaveAsArray:
        {
            value = [value stringByAppendingString:@" - array element"];
            NSArray *array = @[
                [value stringByAppendingString:@" 1"],
                [value stringByAppendingString:@" 2"],
                [value stringByAppendingString:@" 3"],
            ];
            [self.kcDict setObject:array forKey:kMyKeyArray];
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
            [self.kcDict setObject:dict forKey:kMyKeyDict];
            break;
        }
    }
    
    self.statusLabel.text = @"Saved";
}

-(IBAction)fetchButtonPressed:(id)sender
{
    [self.inputTextField resignFirstResponder];
    UIButton *b = (UIButton *)sender;
    NSString *value = @"";
    
    switch (b.tag) {
        case kSaveAsString:
            value = [self.kcDict objectForKey:kMyKeyString];
            break;
            
        case kSaveAsArray:
        {
            NSArray *array = [self.kcDict objectForKey:kMyKeyArray];
            value = [NSString stringWithFormat:@"array=%@", array];
            break;
        }
            
        case kSaveAsDict:
        {
            NSDictionary *dict = [self.kcDict objectForKey:kMyKeyDict];
            value = [NSString stringWithFormat:@"dict=%@", dict];
        }
    }
    
    self.fetchedValueLabel.text = value;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
