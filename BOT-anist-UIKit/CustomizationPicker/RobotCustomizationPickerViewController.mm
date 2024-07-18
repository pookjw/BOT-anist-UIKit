//
//  RobotCustomizationPickerViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotCustomizationPickerViewController.h"
#import "RobotCustomizationPickerViewModel.h"

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewController ()
@property (retain, readonly, nonatomic) RobotCustomizationPickerViewModel *viewModel;
@end

@implementation RobotCustomizationPickerViewController
@synthesize viewModel = _viewModel;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
    [listConfiguration release];
    
    if (self = [super initWithCollectionViewLayout:collectionViewLayout]) {
        
    }
    
    return self;
}

- (void)dealloc {
    [_viewModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemCyanColor;
}

- (UICollectionViewDiffableDataSource *)makeDataSource __attribute__((objc_direct)) {
    abort();
}

@end
