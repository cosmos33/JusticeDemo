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


#define MMJLog(str, ...) [self printLog:str, ##__VA_ARGS__]

@interface RootViewController () <MMWebUploaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *businessIdList;
@property (weak, nonatomic) IBOutlet UITextField *businessId;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UILabel *webLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ceateJusticeActivty;

@property (nonatomic, strong) NSString *secenId;
@property (nonatomic, strong) MMWebUploader *uploader;
@property (nonatomic, strong) Justice *justice;

@property (nullable, strong) NSMutableString *outputString;

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
    
    self.outputString = [NSMutableString string];
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
    NSString *listStr = self.businessIdList.text;
    if (!listStr.length) {
        MMJLog(@"请输入预加载业务场景列表");
        return;
    }
    
    NSArray *listArray = [listStr componentsSeparatedByString:@","];
    
    if (!listArray.count) {
        MMJLog(@"请输入预加载业务场景列表");
        return;
    }
    [self.ceateJusticeActivty startAnimating];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [MMJusticeCenter prepareWithSceneIds:listArray completion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
        [self.ceateJusticeActivty stopAnimating];
        for (NSString *sceneId in listArray) {
            MMJResultInfo *result = resultsDic[sceneId];
            if (result) {
                MMJLog(@"%@: result %d errorCode %ld", sceneId, result.result, (long)result.errorCode);
            }
        };
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        MMJLog(@"请求耗时 %lf ms", linkTime * 1000);
    }];
//    [MMJusticeCenter prepareWithSceneIds:@[@"live",@"chat"] completion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
//        NSLog(@"resultsDic %@", resultsDic);
//    }];
//    [MMJusticeCenter prepareAllSupportedScenesWithCompletion:^(NSDictionary<MMJSceneId,MMJResultInfo *> * _Nonnull resultsDic) {
//        NSLog(@"resultsDic %@", resultsDic);
//    }];
}

- (void)createJustice {
    NSString *text = self.businessId.text;
    if (!text.length) {
        MMJLog(@"请输入预加载业务场景");
        return;
    }
    [self.ceateJusticeActivty startAnimating];
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    [MMJusticeCenter asyncMakeJusticeWithSceneId:text completion:^(Justice * _Nullable justice) {
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        MMJLog(@"创建 Justice 耗时 %f ms", linkTime *1000.0);
        [self.ceateJusticeActivty stopAnimating];
        if (justice) {
            self.justice = justice;
            [self openImagePicker];
        } else {
            MMJLog(@"创建 Justice 失败");
        }
    }];
}

- (void)openImagePicker {
    if (!self.justice) {
        MMJLog(@"请先构建 Justice");
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
    MMJLog(@"==========清空 ret %d ===========", ret);
}

- (void)presentResultAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fetchCenterConfig {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [MMJusticeCenter fetchCenterConfigWithCompletion:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            NSArray *list = [MMJusticeCenter allSupportedSceneIds];
            NSString *tip = [list componentsJoinedByString:@","];
            self.tipLabel.text = tip;
        }
        MMJLog(@"更新结果：%d", result);
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        MMJLog(@"请求耗时 %lf ms", linkTime * 1000);
    }];
}

- (void)printLog:(NSString *)format, ...  {
    if (format) {
        NSString *dateStr = [NSDate date].description;
        va_list args;
        va_start(args, format);
        NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [self.outputString appendFormat:@"%@: %@\n", dateStr, log];
        self.outputView.text = self.outputString;
    }
}

- (IBAction)clearLog:(id)sender {
    self.outputString = [NSMutableString string];
    self.outputView.text = nil;
}
#pragma mark - 测试代码
- (void)testAction {
    MMJLog(@"==========开始测试===========");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 200; ++ i) {
            [MMJusticeCenter prepareWithBusinessTypes:@[@"AntiSpam", @"AntiPorn"] completion:^(NSDictionary<MMJBusinessType,NSNumber *> * _Nonnull resultsDic) {
                MMJLog(@"=====请求1 结果，次序 %d=====", i + 1);
                MMJLog(@"resultsDic %@", resultsDic);
            }];
            [MMJusticeCenter prepareWithBusinessTypes:@[@"AntiPorn", @"spam_4"] completion:^(NSDictionary<MMJBusinessType,NSNumber *> * _Nonnull resultsDic) {
                MMJLog(@"=====请求2 结果，次序 %d=====", i + 1);
                MMJLog(@"resultsDic %@", resultsDic);
            }];
        }
    });
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
//    [self presentResultAlertWithTitle:@"识别结果" message:result];
    MMJLog(result);
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 1:
                [self prepareJusticeCenter];
                break;
                
            case 3:
                [self createJustice];
                break;
                
            case 4:
                [self fetchCenterConfig];
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
