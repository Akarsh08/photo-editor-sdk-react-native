//
//  PhotoEditorSDK.m
//  FantasticPost
//
//  Created by Michel Albers on 16.08.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PhotoEditorSDK.h"
#import "React/RCTUtils.h"
#import "AVHexColor.h"

// Config options
NSString* const kBackgroundColorEditorKey = @"backgroundColorEditor";
NSString* const kBackgroundColorMenuEditorKey = @"backgroundColorMenuEditor";
NSString* const kBackgroundColorCameraKey = @"backgroundColorCamera";
NSString* const kCameraRollAllowedKey = @"cameraRowAllowed";
NSString* const kShowFiltersInCameraKey = @"showFiltersInCamera";

// Menu items
typedef enum {
    transformTool,
    filterTool,
    focusTool,
    adjustTool,
    textTool,
    stickerTool,
    overlayTool,
    brushTool,
    magic,
} FeatureType;

@interface PhotoEditorSDK ()

@property (strong, nonatomic) RCTPromiseResolveBlock resolver;
@property (strong, nonatomic) RCTPromiseRejectBlock rejecter;
@property (strong, nonatomic) PESDKPhotoEditViewController* editController;
@property (strong, nonatomic) PESDKCameraViewController* cameraController;


@end

@implementation PhotoEditorSDK
RCT_EXPORT_MODULE(PESDK);

static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"backgroundColorCameraKey":       kBackgroundColorCameraKey,
             @"backgroundColorEditorKey":       kBackgroundColorEditorKey,
             @"backgroundColorMenuEditorKey":   kBackgroundColorMenuEditorKey,
             @"cameraRollAllowedKey":           kCameraRollAllowedKey,
             @"showFiltersInCameraKey":         kShowFiltersInCameraKey,
             @"transformTool":                  [NSNumber numberWithInt: transformTool],
             @"filterTool":                     [NSNumber numberWithInt: filterTool],
             @"focusTool":                      [NSNumber numberWithInt: focusTool],
             @"adjustTool":                     [NSNumber numberWithInt: adjustTool],
             @"textTool":                       [NSNumber numberWithInt: textTool],
             @"stickerTool":                    [NSNumber numberWithInt: stickerTool],
             @"overlayTool":                    [NSNumber numberWithInt: overlayTool],
             @"brushTool":                      [NSNumber numberWithInt: brushTool],
             @"magic":                          [NSNumber numberWithInt: magic]
    };
}

-(void)_openEditor: (UIImage *)image config: (PESDKConfiguration *)config features: (NSArray*)features resolve: (RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)reject {
    self.resolver = resolve;
    self.rejecter = reject;
    
    // Just an empty model
    PESDKPhotoEditModel* photoEditModel = [[PESDKPhotoEditModel alloc] init];
    
    // Build the menu items from the features array if present
    NSMutableArray<PESDKPhotoEditMenuItem *>* menuItems = [[NSMutableArray alloc] init];
    
    // Default features
    if (features == nil || [features count] == 0) {
        features = @[
          [NSNumber numberWithInt: transformTool],
          [NSNumber numberWithInt: filterTool],
          [NSNumber numberWithInt: focusTool],
          [NSNumber numberWithInt: adjustTool],
          [NSNumber numberWithInt: textTool],
          [NSNumber numberWithInt: stickerTool],
          [NSNumber numberWithInt: overlayTool],
          [NSNumber numberWithInt: brushTool],
          [NSNumber numberWithInt: magic]
        ];
    }
    
    [features enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int feature = [obj intValue];
        switch (feature) {
            case transformTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createTransformToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case filterTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createFilterToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case focusTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createFocusToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case adjustTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createAdjustToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case textTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createTextToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case stickerTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createStickerToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case overlayTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createOverlayToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case brushTool: {
                PESDKToolMenuItem* menuItem = [PESDKToolMenuItem createBrushToolItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            case magic: {
                PESDKActionMenuItem* menuItem = [PESDKActionMenuItem createMagicItem];
                PESDKPhotoEditMenuItem* editMenuItem = [[PESDKPhotoEditMenuItem alloc] initWithActionMenuItem:menuItem];
                [menuItems addObject: editMenuItem];
                break;
            }
            default:
                break;
        }
    }];
    
    PESDK.bundleImageBlock = ^UIImage * _Nullable(NSString * _Nonnull name) {
        // To change the icons of outer UI
        if ([name isEqual:@"imgly_icon_save"]) {
            // toolbar --> save button icon
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/done_black_44" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        if ([name isEqual:@"imgly_icon_approve_44pt"]) {
            // toolbar --> apply button icont
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/apply_black_25_44" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        if ([name isEqual:@"imgly_icon_cancel_44pt"]) {
            // toolbar --> discard button icon
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/discard_black_25_44" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        if ([name isEqual:@"imgly_icon_flipHorizontal_48pt"]) {
            // transform tool --> flip button icon
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/flip_black_30" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        if ([name isEqual:@"imgly_icon_rotateLeft_48pt"]) {
            // transform tool --> rotate button icon
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/rotate_black_30" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        if ([name isEqual:@"imgly_icon_undo_24pt"]||[name isEqual:@"imgly_icon_redo_24pt"]) {
            // home --> undo/ redo button icons
            NSURL * url = [[NSBundle mainBundle] URLForResource:@"FilterIcons/blank_2" withExtension:@"png"];
            NSData * data =[NSData dataWithContentsOfURL:url];
            UIImage * img = [UIImage imageWithData:data];
            return img;
        }
        return NULL;
    };
    
    self.editController = [[PESDKPhotoEditViewController alloc] initWithPhoto:image configuration:config menuItems:menuItems photoEditModel:photoEditModel];
    // make toolbar background white
    self.editController.toolbar.backgroundColor = [UIColor whiteColor];
    
    self.editController.delegate = self;
    UIViewController *currentViewController = RCTPresentedViewController();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentViewController presentViewController:self.editController animated:YES completion:nil];
    });
}

-(PESDKConfiguration*)_buildConfig: (NSDictionary *)options {
    if (@available(iOS 9.0, *)) {
        PESDKConfiguration* config = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * builder) {
            [builder configurePhotoEditorViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * b) {
                if ([options valueForKey:kBackgroundColorEditorKey]) {
                    b.backgroundColor = [AVHexColor colorWithHexString: [options valueForKey:kBackgroundColorEditorKey]];
                }
                
                if ([options valueForKey:kBackgroundColorMenuEditorKey]) {
                    b.menuBackgroundColor = [AVHexColor colorWithHexString: [options valueForKey:kBackgroundColorMenuEditorKey]];
                }
                // make undo /redo button background transparent
                b.overlayButtonConfigurationClosure = ^(PESDKOverlayButton * _Nonnull overlayButton, enum PhotoEditOverlayAction action) {
                    overlayButton.backgroundColor = [UIColor colorWithRed:(CGFloat) 255 green:(CGFloat) 255 blue:(CGFloat) 255 alpha:(CGFloat) 0];
                    overlayButton.enabled = false;
                    overlayButton.tintColor = [UIColor blackColor];
                };
                // make tool menu buttons icon and title black
                b.actionButtonConfigurationBlock = ^(PESDKIconCaptionCollectionViewCell * _Nonnull cell, PESDKPhotoEditMenuItem * _Nonnull menuButton) {
                    cell.iconTintColor = [UIColor blackColor];
                    cell.captionTintColor = [UIColor blackColor];
                };
            }];
            
            [builder configureTransformToolController:^(PESDKTransformToolControllerOptionsBuilder * _Nonnull options) {
                options.allowFreeCrop = NO;
                // make transform tool scale picker background white and text and tick color black
                options.scalePickerConfigurationClosure = ^(PESDKScalePicker * _Nonnull scalePicker) {
                    scalePicker.backgroundColor = [UIColor whiteColor];
                    scalePicker.textColor = [UIColor blackColor];
                    scalePicker.tickColor = [UIColor blackColor];
                    scalePicker.tintColor = [UIColor whiteColor];
                    scalePicker.valueLabelBackgroundColor = [UIColor whiteColor];
                };
                // make tranfrom tool screen --> flip/rotate button  bacground white              
                options.transformButtonConfigurationClosure = ^(PESDKButton * _Nonnull transformButton, enum TransformAction action) {
                    transformButton.backgroundColor = [UIColor whiteColor];
                    transformButton.tintColor = [UIColor blackColor];
                };
                // make transform tool screen--> crop ratio selection button border gray / font black 
                options.cropAspectButtonConfigurationClosure = ^(PESDKLabelBorderedCollectionViewCell * _Nonnull cell, PESDKCropAspect * _Nullable aspect){
                    cell.borderColor = [UIColor grayColor];
                    cell.tintColor = [UIColor blackColor];
                    cell.textLabelTintColor = [UIColor blackColor];
                };
                // make transform tool background white 
                options.backgroundColor = [UIColor whiteColor];
                options.menuBackgroundColor = [UIColor whiteColor];
                // setting allowed crop ratios
                options.allowedCropRatios = @[
                                              [[PESDKCropAspect alloc] initWithWidth:4 height:5 localizedName:@"4 : 5" rotatable:NO],
                                              [[PESDKCropAspect alloc] initWithWidth:1 height:1 localizedName:@"1 : 1" rotatable:NO],
                                              [[PESDKCropAspect alloc] initWithWidth:4 height:3 localizedName:@"4 : 3" rotatable:NO],
                                              [[PESDKCropAspect alloc] initWithWidth:3 height:2 localizedName:@"3 : 2" rotatable:NO],
                                              [[PESDKCropAspect alloc] initWithWidth:5 height:3 localizedName:@"5 : 3" rotatable:NO],
                                              [[PESDKCropAspect alloc] initWithWidth:16 height:9 localizedName:@"16 : 9" rotatable:NO]
                                            ];
            }];
            // configuring Filter tool
            [builder configureFilterToolController:^(PESDKFilterToolControllerOptionsBuilder * _Nonnull options) {
                options.backgroundColor = [UIColor whiteColor];
                options.menuBackgroundColor = [UIColor whiteColor];
                options.filterIntensitySliderContainerConfigurationClosure = ^(UIView * _Nonnull view) {
                    view.backgroundColor = [UIColor whiteColor];
                };
                // make filter tool screen --> filter intesity slider color
                options.filterIntensitySliderConfigurationClosure = ^(PESDKSlider * _Nonnull slider) {
                    slider.backgroundColor = [UIColor whiteColor]; 
                    slider.thumbTintColor = [UIColor blackColor];
                    slider.filledTrackColor = [UIColor blackColor];
                    slider.unfilledTrackColor = [UIColor lightGrayColor];
                };
            }];
            // setting filter effects to e shown on filter tool screen
            PESDKPhotoEffect.allEffects = @[
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"normal" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/normal" withExtension:@"png"] displayName:@"normal"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"arabica12" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/arabica12" withExtension:@"png"] displayName:@"arabica12"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"ava614" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/ava614" withExtension:@"png"] displayName:@"ava614"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"azrael93" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/azrael93" withExtension:@"png"] displayName:@"azrael93"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"byers11" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/byers11" withExtension:@"png"] displayName:@"byers11"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"chemical168" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/chemical168" withExtension:@"png"] displayName:@"chemical168"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"clayton33" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/clayton33" withExtension:@"png"] displayName:@"clayton33"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"clouseau54" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/clouseau54" withExtension:@"png"] displayName:@"clouseau54"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"cobi3" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/cobi3" withExtension:@"png"] displayName:@"cobi3"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"contrail35" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/contrail35" withExtension:@"png"] displayName:@"contrail35"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"cubicle99" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/cubicle99" withExtension:@"png"] displayName:@"cubicle99"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"django25" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/django25" withExtension:@"png"] displayName:@"django25"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"domingo145" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/domingo145" withExtension:@"png"] displayName:@"domingo145"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"faded47" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/faded47" withExtension:@"png"] displayName:@"faded47"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"folger50" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/folger50" withExtension:@"png"] displayName:@"folger50"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"fusion88" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/fusion88" withExtension:@"png"] displayName:@"fusion88"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"hyla68" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/hyla68" withExtension:@"png"] displayName:@"hyla68"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"korben214" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/korben214" withExtension:@"png"] displayName:@"korben214"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"lenox340" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/lenox340" withExtension:@"png"] displayName:@"lenox340"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"lucky64" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/lucky64" withExtension:@"png"] displayName:@"lucky64"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"mc-kinnon75" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/mc-kinnon75" withExtension:@"png"] displayName:@"mc-kinnon75"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"milo5" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/milo5" withExtension:@"png"] displayName:@"milo5"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"neon770" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/neon770" withExtension:@"png"] displayName:@"neon770"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"paladin1875" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/paladin1875" withExtension:@"png"] displayName:@"paladin1875"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"pasadena21" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/pasadena21" withExtension:@"png"] displayName:@"pasadena21"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"pitaya15" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/pitaya15" withExtension:@"png"] displayName:@"pitaya15"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"reeve38" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/reeve38" withExtension:@"png"] displayName:@"reeve38"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"remy24" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/remy24" withExtension:@"png"] displayName:@"remy24"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"sprocket231" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/sprocket231" withExtension:@"png"] displayName:@"sprocket231"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"teigen28" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/teigen28" withExtension:@"png"] displayName:@"teigen28"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"trent18" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/trent18" withExtension:@"png"] displayName:@"trent18"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"tweed71" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/tweed71" withExtension:@"png"] displayName:@"tweed71"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"vireo37" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/vireo37" withExtension:@"png"] displayName:@"vireo37"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"zed32" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/zed32" withExtension:@"png"] displayName:@"zed32"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"zeke39" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/zeke39" withExtension:@"png"] displayName:@"zeke39"]
            ];
            
            [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * b) {
                if ([options valueForKey:kBackgroundColorCameraKey]) {
                    b.backgroundColor = [AVHexColor colorWithHexString: (NSString*)[options valueForKey:kBackgroundColorCameraKey]];
                }
                
                if ([[options allKeys] containsObject:kCameraRollAllowedKey]) {
                    b.showCameraRoll = [[options valueForKey:kCameraRollAllowedKey] boolValue];
                }
                
                if ([[options allKeys] containsObject: kShowFiltersInCameraKey]) {
                    b.showFilters = [[options valueForKey:kShowFiltersInCameraKey] boolValue];
                }
                
                // TODO: Video recording not supported currently
                b.allowedRecordingModesAsNSNumbers = @[[NSNumber numberWithInteger:RecordingModePhoto]];
            }];
        }];
        return config;
    } else {
        // Fallback on earlier versions
        return NULL;
    }
}

RCT_EXPORT_METHOD(openEditor: (NSString*)path options: (NSArray *)features options: (NSDictionary*) options resolve: (RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)reject) {
    UIImage* image = [UIImage imageWithContentsOfFile: path];
    PESDKConfiguration* config = [self _buildConfig:options];
    [self _openEditor:image config:config features:features resolve:resolve reject:reject];
}

- (void)close {
    UIViewController *currentViewController = RCTPresentedViewController();
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}

RCT_EXPORT_METHOD(openCamera: (NSArray*) features options:(NSDictionary*) options resolve: (RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)reject) {
    __weak typeof(self) weakSelf = self;
    UIViewController *currentViewController = RCTPresentedViewController();
    PESDKConfiguration* config = [self _buildConfig:options];
    
    self.cameraController = [[PESDKCameraViewController alloc] initWithConfiguration:config];

    [self.cameraController.cameraController setupWithInitialRecordingMode:RecordingModePhoto error:nil];
    
    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.cameraController.view addGestureRecognizer:swipeDownRecognizer];
    [self.cameraController setCompletionBlock:^(UIImage * image, NSURL * _) {
        [currentViewController dismissViewControllerAnimated:YES completion:^{
            [weakSelf _openEditor:image config:config features:features resolve:resolve reject:reject];
        }];
    }];
    
    [currentViewController presentViewController:self.cameraController animated:YES completion:nil];
}

-(void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController *)photoEditViewController {
    if (self.rejecter != nil) {
        // self.rejecter(@"DID_CANCEL", @"User did cancel the editor", nil);
        // self.rejecter = nil;
        self.resolver(@"USER_SKIP_EDITING");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.editController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        });
    }
}

-(void)photoEditViewControllerDidFailToGeneratePhoto:(PESDKPhotoEditViewController *)photoEditViewController {
    if (self.rejecter != nil) {
        // self.rejecter(@"DID_FAIL_TO_GENERATE_PHOTO", @"Photo generation failed", nil);
        // self.rejecter = nil;
        self.resolver(@"GENERATE_IMAGE_ERROR");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.editController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        });
        
    }
}

-(void)photoEditViewController:(PESDKPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *randomPath = [PhotoEditorSDK randomStringWithLength:10];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [randomPath stringByAppendingString:@".jpg"] ];
    
    [data writeToFile:path atomically:YES];
    self.resolver(path);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    });
    
}

@end
