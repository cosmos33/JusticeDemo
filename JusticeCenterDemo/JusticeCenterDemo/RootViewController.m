//
//  RootViewController.m
//  JusticeCenterDemo
//
//  Created by MOMO on 2019/11/19.
//  Copyright © 2019 MOMO. All rights reserved.
//

#import "RootViewController.h"
#import <MMJusticeCenter/MMJusticeCenter.h>
#import <Photos/Photos.h>

#import <MMWebUploader/MMWebUploader-umbrella.h>
#import <GCDWebServer/GCDWebServer-umbrella.h>

@interface RootViewController () <MMWebUploaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *webLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ceateJusticeActivty;

@property (nonatomic, strong) MMWebUploader *uploader;
@property (nonatomic, strong) Justice *justice;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.uploader = [[MMWebUploader alloc] initWithUploadDirectory:[documentsPath stringByAppendingString:@"/.."]];
    self.uploader.delegate = self;
    self.uploader.allowHiddenItems = YES;
    self.webLabel.text = [NSString stringWithFormat:@"WEB: %@",GCDWebServerGetPrimaryIPAddress(NO)];
    
    [MMJusticeCenter configureAppId:@"ed908f89453ca1793dc7da5fb32e1b30"];
    

}

#pragma mark - UIAction
- (IBAction)webSwitchValueChanged:(UISwitch *)sender {
    if (sender.on) {
        if ([self.uploader start]) {
            NSLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"GCDWebServer running locally on port %i", nil), (int)self.uploader.port]);
        } else {
            NSLog(@"%@",NSLocalizedString(@"GCDWebServer not running!", nil));
        }
    } else {
        [self.uploader stop];
    }
}

- (void)prepareJusticeCenter {
//    [MMJusticeCenter prepareWithBusinessTypes:@[] completion:^(NSDictionary<MMJBusinessType,MMJResultInfo *> * _Nonnull resultsDic) {
//        NSLog(@"resultsDic %@", resultsDic);
//    }];
//    [MMJusticeCenter prepareWithSceneIds:@[@"live",@"chat"] completion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
//        NSLog(@"resultsDic %@", resultsDic);
//    }];
    [MMJusticeCenter prepareAllSupportedScenesWithCompletion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
        NSLog(@"resultsDic %@", resultsDic);
    }];
}

- (void)createJustice {
    [self.ceateJusticeActivty startAnimating];
//    [MMJusticeCenter asyncMakeJusticeWithBusinessTypes:@[@"AntiSpam", @"AntiPorn"] completion:^(Justice * _Nullable justice) {
//        [self.ceateJusticeActivty stopAnimating];
//        self.justice = justice;
//    }];
    [MMJusticeCenter asyncMakeJusticeWithSceneId:@"live" completion:^(Justice * _Nullable justice) {
        [self.ceateJusticeActivty stopAnimating];
        self.justice = justice;
    }];
}

- (void)openImagePicker {
    if (!self.justice) {
        NSLog(@"请先构建 Justice");
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            //    imagePicker.editing = YES;
            imagePicker.delegate = self;
            //    imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        });
    }];
}

- (void)clearLocalAssets {
    _justice = nil;
    BOOL ret = [MMJusticeCenter clearAllAssets];
    NSLog(@"==========清空 ret %d ===========", ret);
}

- (void)presentResultAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 测试代码
- (void)testAction {
    NSLog(@"==========开始测试===========");
    for (int i = 0; i < 5000; ++ i) {
        NSLog(@"调用次数 %d", i + 1);
        [MMJusticeCenter prepareWithBusinessTypes:@[@"AntiSpam", @"AntiPorn"] completion:^(NSDictionary<MMJBusinessType,NSNumber *> * _Nonnull resultsDic) {
            NSLog(@"=====请求1 结果，次序 %d=====", i + 1);
            NSLog(@"resultsDic %@", resultsDic);
        }];
        [MMJusticeCenter prepareWithBusinessTypes:@[@"AntiPorn", @"spam_4"] completion:^(NSDictionary<MMJBusinessType,NSNumber *> * _Nonnull resultsDic) {
            NSLog(@"=====请求2 结果，次序 %d=====", i + 1);
            NSLog(@"resultsDic %@", resultsDic);
        }];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //获取到的图片
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSString *result = [self.justice predict:image];
    [self presentResultAlertWithTitle:@"识别结果" message:result];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self prepareJusticeCenter];
                break;
                
            case 1:
                [self createJustice];
                break;
                
            case 2:
                [self openImagePicker];
                break;
                
            default:
                break;
        }
        return;
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                break;
                
            case 1:
                [self clearLocalAssets];
                break;
                
            case 2:
                [self testAction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - MMWebUploaderDelegate
- (void)webUploader:(MMWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
}

- (void)webUploader:(MMWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
}

- (void)webUploader:(MMWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
}

- (void)webUploader:(MMWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
}

- (void)webUploader:(MMWebUploader *)uploader didUnzipItemAtPath:(NSString *)path {
    NSLog(@"[UNZIP] %@", path);
}

- (void)webUploader:(MMWebUploader *)uploader didZipItemAtPath:(nonnull NSString *)path {
    NSLog(@"[ZIP] %@", path);
}

@end
