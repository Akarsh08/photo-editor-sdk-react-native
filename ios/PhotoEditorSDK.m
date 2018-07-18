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
NSString* selectedFilter = @"normal";

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
            UIImage * img = [UIImage imageNamed:@"doneButton"];
            return img;
        }
        if ([name isEqual:@"imgly_icon_approve_44pt"]) {
            // toolbar --> apply button icont
            UIImage * img = [UIImage imageNamed:@"applyButton"];
            return img;
        }
        if ([name isEqual:@"imgly_icon_cancel_44pt"]) {
            // toolbar --> discard button icon
            UIImage * img = [UIImage imageNamed:@"discardButton"];
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
                // saving selected filter
                options.filterSelectedClosure = ^(PESDKPhotoEffect * _Nonnull effect) {
                    selectedFilter = effect.displayName;
                };
                
                options.discardButtonConfigurationClosure = ^(PESDKButton * _Nonnull but) {
                    but.actionClosure = ^(id _Nonnull lic) {
                        selectedFilter = @"normal";
                    };
                    
                };
            }];
            // setting filter effects to e shown on filter tool screen
            PESDKPhotoEffect.allEffects = @[
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"normal" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/normal" withExtension:@"png"] displayName:@"ORIGINAL"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A1" withExtension:@"png"] displayName:@"Promenade"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A3" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A3" withExtension:@"png"] displayName:@"Ambre"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A4" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A4" withExtension:@"png"] displayName:@"Nuages"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A6" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A6" withExtension:@"png"] displayName:@"Dimanche"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A7" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A7" withExtension:@"png"] displayName:@"Profond"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A8" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A8" withExtension:@"png"] displayName:@"Bleuté"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"A10" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/A10" withExtension:@"png"] displayName:@"Amande"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"B1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/B1" withExtension:@"png"] displayName:@"Soir"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"B2" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/B2" withExtension:@"png"] displayName:@"Sombre"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"C3" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/C3" withExtension:@"png"] displayName:@"Aquarelle"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"C4" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/C4" withExtension:@"png"] displayName:@"Rivière"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"C5" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/C5" withExtension:@"png"] displayName:@"Aube"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"C8" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/C8" withExtension:@"png"] displayName:@"Lavande"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"C9" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/C9" withExtension:@"png"] displayName:@"Turquoise"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"E2" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/E2" withExtension:@"png"] displayName:@"Lumière"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"E5" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/E5" withExtension:@"png"] displayName:@"Douce"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"E6" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/E6" withExtension:@"png"] displayName:@"L'eau"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"F2" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/F2" withExtension:@"png"] displayName:@"Ciel"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"F3" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/F3" withExtension:@"png"] displayName:@"Rochelle"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"G2" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/G2" withExtension:@"png"] displayName:@"Soleil"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"HB1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/HB1" withExtension:@"png"] displayName:@"Froide"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"K1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/K1" withExtension:@"png"] displayName:@"Couleurs"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"M3" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/M3" withExtension:@"png"] displayName:@"Hiver"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"M5" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/M5" withExtension:@"png"] displayName:@"Blanche"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"M6" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/M6" withExtension:@"png"] displayName:@"Brille"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"P5" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/P5" withExtension:@"png"] displayName:@"Atlantis"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"T1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/T1" withExtension:@"png"] displayName:@"Pastel"],
                                            [[PESDKPhotoEffect alloc] initWithIdentifier:@"X1" lutURL:[[NSBundle mainBundle] URLForResource:@"ImageFilters/X1" withExtension:@"png"] displayName:@"Rétro"],
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
        selectedFilter = @"normal";
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
    NSString* response = [NSString stringWithFormat:@"{\"path\":\"%@\", \"filter\":\"%@\"}",path, selectedFilter];
    self.resolver(response);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.editController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    });
    
}

@end
