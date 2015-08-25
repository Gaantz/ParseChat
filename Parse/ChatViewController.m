//
//  ChatViewController.m
//  Parse
//
//  Created by Cristian on 24/08/15.
//  Copyright (c) 2015 Cristian. All rights reserved.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>

@interface ChatViewController ()

@property (strong,nonatomic) NSMutableArray *messages;

@end

@implementation ChatViewController

-(void)refrescar:(NSNotification *) notification
{
    if ([notification.name isEqualToString:@"refreshView"])
    {
        NSDictionary *userInfo = notification.userInfo;
        NSString *json = userInfo[@"mensaje"];
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"111111"
                                                 senderDisplayName:@"admin"
                                                              date:[NSDate date]
                                                              text:json];
        [self.messages addObject:message];
        
        PFObject *objmsg = [PFObject objectWithClassName:@"Message"];
        objmsg[@"senderId"] = @"111111";
        objmsg[@"senderDisplayName"] = @"admin";
        objmsg[@"date"] = [NSDate date];
        objmsg[@"text"] = json;
        [objmsg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.inputToolbar.contentView.rightBarButtonItem setEnabled:NO];
            if (succeeded) {
                    [self.collectionView reloadData];
                
                NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
                NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:section] - 1;
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                
            } else {
                NSLog(@"%@",[error description]);
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrescar:) name:@"refreshView" object:nil];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messages = [[NSMutableArray alloc] init];
            
            for (PFObject *obj in objects) {
                JSQMessage *message =
                [[JSQMessage alloc] initWithSenderId:[obj objectForKey:@"senderId"]
                                   senderDisplayName:[obj objectForKey:@"senderDisplayName"]
                                                date:[obj objectForKey:@"date"]
                                                text:[obj objectForKey:@"text"]];
                [self.messages addObject:message];
            }
            
            [self.collectionView reloadData];
            
            NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
            NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:section] - 1;
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user.username;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.inputToolbar.contentView.textView.placeHolder = @"Mensaje";
    
    UIButton *send = self.inputToolbar.contentView.rightBarButtonItem;
    [send setTitle:@"Inciar" forState:UIControlStateNormal];
}

-(void)didPressSendButton:(UIButton *)button
          withMessageText:(NSString *)text
                 senderId:(NSString *)senderId
        senderDisplayName:(NSString *)senderDisplayName
                     date:(NSDate *)date
{
    [self.inputToolbar.contentView.rightBarButtonItem setEnabled:YES];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.messages addObject:message];
    
    PFObject *objmsg = [PFObject objectWithClassName:@"Message"];
    objmsg[@"senderId"] = senderId;
    objmsg[@"senderDisplayName"] = senderDisplayName;
    objmsg[@"date"] = date;
    objmsg[@"text"] = text;
    [objmsg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.inputToolbar.contentView.rightBarButtonItem setEnabled:NO];
        if (succeeded) {
            
        } else {
            NSLog(@"%@",[error description]);
        }
    }];
    
    [self finishSendingMessageAnimated:YES];
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
   
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImage *icon = nil;
    if ([message.senderId isEqualToString:self.senderId]) {
        icon =
        [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }else{
        icon =
        [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return icon;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    JSQMessagesAvatarImage *jsqImage =
    [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@""
                                               backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                     textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                          font:[UIFont systemFontOfSize:14.0f]
                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
//    return [self.demoData.avatars objectForKey:message.senderId];
    return jsqImage;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


@end
