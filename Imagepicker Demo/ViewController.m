//
//  ViewController.m
//  Imagepicker Demo
//
//  Created by Daniela on 3/26/13.
//  Copyright (c) 2013 Pyrogusto. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MediaPlayer/MediaPlayer.h"

#define PHOTO_LIBRART_BUTTON_TITLE @"Photo Library"
#define PHOTO_ALBUM_BUTTON_TITLE @"Camera Roll"
#define CAMERA_BUTTON_TITLE @"Camera"
#define CANCEL_BUTTON_TITLE @"Cancel"

@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) UIActionSheet *actionSheet;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@end

@implementation ViewController

- (IBAction)cameraButtonClicked:(id)sender {
    if(!self.actionSheet){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose Source of Image"
                                                                delegate:self cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
         
        // only add avaliable source to actionsheet
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            [actionSheet addButtonWithTitle:PHOTO_LIBRART_BUTTON_TITLE];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
            [actionSheet addButtonWithTitle:PHOTO_ALBUM_BUTTON_TITLE];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [actionSheet addButtonWithTitle:CAMERA_BUTTON_TITLE];
        }
        
        [actionSheet addButtonWithTitle:CANCEL_BUTTON_TITLE];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }
}

- (MPMoviePlayerController*)moviePlayerController{
    if(!_moviePlayerController){
        _moviePlayerController = [[MPMoviePlayerController alloc]init];
        float ratio = self.view.bounds.size.width / 320;
        _moviePlayerController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 180*ratio);
    }
    return _moviePlayerController;
}

- (void) displayPickedMedia:(NSDictionary *)info{
    self.imageView.image = nil;
    [self.moviePlayerController.view removeFromSuperview];
    NSLog(@"%@:%@",info[UIImagePickerControllerMediaType],(NSString *) kUTTypeMovie);
    if([info[UIImagePickerControllerMediaType]isEqualToString:(NSString *) kUTTypeImage]){
        UIImage *pickedImage = info[UIImagePickerControllerEditedImage];
        if(!pickedImage){
            pickedImage = info[UIImagePickerControllerOriginalImage];
        }
        if(pickedImage) {
            self.imageView.image = pickedImage;
        }
    }else if([info[UIImagePickerControllerMediaType]isEqualToString:(NSString *) kUTTypeMovie]){
        [self.view addSubview:_moviePlayerController.view];
        self.moviePlayerController.contentURL = info[UIImagePickerControllerMediaURL];
        [self.moviePlayerController play];
    }
}

#pragma mark - image picker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"didFinishPickingMediaWithInfo,%@",info);
    [self dismissViewControllerAnimated:YES completion:^{
        [self displayPickedMedia:info];
    }];
    
}


#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == self.actionSheet.destructiveButtonIndex){
        NSLog(@"destuctivebutton clicked");
    }else if(buttonIndex == self.actionSheet.cancelButtonIndex){
        NSLog(@"cancel clicked");
    }else{
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        
        picker.allowsEditing = YES;
        picker.delegate = self;
        picker.mediaTypes = @[(NSString *) kUTTypeMovie,(NSString *) kUTTypeImage]; // choose both video and image
        //picker.mediaTypes = @[(NSString *) kUTTypeImage]; // image only which is default
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([choice isEqualToString:PHOTO_LIBRART_BUTTON_TITLE]){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }else if([choice isEqualToString:PHOTO_ALBUM_BUTTON_TITLE]){
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }else if([choice isEqualToString:CAMERA_BUTTON_TITLE]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:^{
            NSLog(@"complete picked image");
        }];
        
    }
}
@end
