//
//  ChatViewController.m
//  Parse
//
//  Created by Cristian on 24/08/15.
//  Copyright (c) 2015 Cristian. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.senderId = @"0001";
    self.senderDisplayName = @"Gaantz";
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;

    self.inputToolbar.contentView.textView.placeHolder = @"Mensaje";
    
    UIButton *send = self.inputToolbar.contentView.rightBarButtonItem;
    [send setTitle:@"Inciar" forState:UIControlStateNormal];
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
//    [self.demoData.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
