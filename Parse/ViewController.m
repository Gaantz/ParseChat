//
//  ViewController.m
//  Parse
//
//  Created by Cristian on 24/08/15.
//  Copyright (c) 2015 Cristian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)entrar:(id)sender
{
    PFUser *muser = [PFUser user];
    muser.username = _name.text;
    muser.password = @"default";
    
    [muser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self performSegueWithIdentifier:@"toChat" sender:self];
        } else {
            [PFUser logInWithUsernameInBackground:_name.text password:@"default"
            block:^(PFUser *user, NSError *error) {
                if (user) {
                    [self performSegueWithIdentifier:@"toChat" sender:self];
                } else {
                    NSLog(@"%@",[error userInfo][@"error"]);
                }
            }];
        }
    }];
}

@end
