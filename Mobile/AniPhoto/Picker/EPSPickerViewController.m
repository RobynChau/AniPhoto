//
//  EPSEditorViewController.m
//  DemoProject
//
//  Created by PhatCH on 12/12/2023.
//

#import "EPSPickerViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "AniganViewController.h"
#import "EPSUserEntity.h"
#import "AnimeGANv2_1024.h"
#import "EPSDefines.h"
@import FirebaseStorage;

#define BUTTON_WIDTH 180

@interface EPSPickerViewController () <
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *choosePhotoButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation EPSPickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage systemImageNamed:@"photo"];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_imageView];
        
        _choosePhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _choosePhotoButton.backgroundColor = UIColor.systemBlueColor;
        _choosePhotoButton.layer.cornerRadius = 20.0f;
        [_choosePhotoButton setTitle:@"Choose Photo" forState:UIControlStateNormal];
        [_choosePhotoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_choosePhotoButton addTarget:self action:@selector(showPickerOption) forControlEvents:UIControlEventTouchDown];
        _choosePhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_choosePhotoButton];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _spinner.tintColor = UIColor.blackColor;
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_spinner];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    // Set up your navigation bar with a right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Next"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(donePickingPhoto)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                   target:self
                                   action:@selector(closeButtonPressed)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [self.imageView.widthAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.widthAnchor multiplier:0.92],
        [self.imageView.heightAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.widthAnchor multiplier:0.92],
        [self.imageView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:100],
        
        [self.choosePhotoButton.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [self.choosePhotoButton.widthAnchor constraintEqualToConstant:BUTTON_WIDTH],
        [self.choosePhotoButton.heightAnchor constraintEqualToConstant:50],
        [self.choosePhotoButton.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:-100],
        
        [self.spinner.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor],
    ]];
    [super updateViewConstraints];
}

- (void)showPickerOption {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Choose photo from" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [ac addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentCamera];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentPhotoPicker];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self.navigationController presentViewController:ac animated:YES completion:nil];
}

- (void)presentPhotoPicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)presentCamera {
    // Check if the device has a camera available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Create and configure the UIImagePickerController
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        // Present the UIImagePickerController
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        // Display an alert if the device doesn't have a camera
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device doesn't have a camera." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = pickedImage;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)donePickingPhoto {
    [self uploadImageToFirebase:self.imageView.image userID:@"0000001"];
}

- (void)uploadImageToFirebase:(UIImage *)image
                       userID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner startAnimating];
    });
    
    NSData *uploadData = UIImageJPEGRepresentation(image, 0.8);
    NSString *fileID = [NSString stringWithFormat:@"%0.f.jpg", ceil(NSDate.now.timeIntervalSince1970)];
    FIRStorageMetadata *metaData = [[FIRStorageMetadata alloc] init];
    metaData.contentType = @"image/jpeg";
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    FIRStorageReference *userRef = [storageRef child:userID];
    FIRStorageReference *userRawRef = [userRef child:@"raw"];
    FIRStorageReference *photoRawRef = [userRawRef child:fileID];
    FIRStorageUploadTask *uploadTask = [photoRawRef
                                        putData:uploadData
                                        metadata:metaData
                                        completion:^(FIRStorageMetadata * _Nullable metadata,
                                                     NSError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner stopAnimating];
                UIAlertController *ac = [UIAlertController
                                         alertControllerWithTitle:@"Problem Generating Selfie"
                                         message:@"There is a problem generating anime-styled selfie. Please try again"
                                         preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:@"Try Again"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                    [self uploadImageToFirebase:self.imageView.image userID:@"0000001"];
                }]];
                [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil]];
                [self.navigationController presentViewController:ac animated:YES completion:nil];
            });
        } else {
            [photoRawRef downloadURLWithCompletion:^(NSURL * _Nullable rawFirebaseURL, NSError * _Nullable error) {
                if (rawFirebaseURL) {
                    NSString *urlString = [NSString stringWithFormat:@"%@/v2/process-images", kModelServerLink];
                    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
                    
                    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [urlRequest setHTTPMethod:@"POST"];
                    NSDictionary *mapData = @{
                        @"source_img_path" : rawFirebaseURL.absoluteString,
                    };
                    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
                    [urlRequest setHTTPBody:postData];
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    NSURLSessionDataTask *dataTask = [session
                                                      dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data,
                                                                          NSURLResponse *response,
                                                                          NSError *error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        if (httpResponse.statusCode == 200) {
                            NSError *parseError = nil;
                            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                            
                            if ([[responseDictionary objectForKey:@"processed_url"] isKindOfClass:NSString.class]) {
                                NSString *processedImageURL = [responseDictionary objectForKey:@"processed_url"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    AniganViewController *vc = [[AniganViewController alloc] init];
                                    vc.processedImageURL = processedImageURL;
                                    [self.navigationController pushViewController:vc animated:YES];
                                });
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.spinner stopAnimating];
                                UIAlertController *ac = [UIAlertController
                                                         alertControllerWithTitle:@"Problem Generating Selfie"
                                                         message:@"There is a problem generating anime-styled selfie. Please try again"
                                                         preferredStyle:UIAlertControllerStyleAlert];
                                [ac addAction:[UIAlertAction actionWithTitle:@"Try Again"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                    [self uploadImageToFirebase:self.imageView.image userID:@"0000001"];
                                }]];
                                [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil]];
                                [self.navigationController presentViewController:ac animated:YES completion:nil];
                            });
                        }
                    }];
                    [dataTask resume];
                }
            }];
        }
    }];
}


- (void)processUsingOnDeviceML {
    int randomValue = arc4random_uniform(2);
    if (randomValue == 0 ) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"There is an error generating photo" preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Pick photo again" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        AnimeGANv2_1024 *model = [[AnimeGANv2_1024 alloc] init];
        AnimeGANv2_1024Input *input = [[AnimeGANv2_1024Input alloc] initWithInputFromCGImage:self.imageView.image.CGImage error:nil];
        AnimeGANv2_1024Output *output = [model predictionFromFeatures:input error:nil];
        
        UIImage *result = [UIImage imageWithCIImage:[CIImage imageWithCVPixelBuffer:output.output]];
        
        [self.spinner stopAnimating];
        self.imageView.image = result;
        self.imageView.alpha = 1.0f;
    }
}

- (void)closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
