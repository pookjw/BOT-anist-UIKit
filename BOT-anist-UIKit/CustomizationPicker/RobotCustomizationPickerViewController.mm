//
//  RobotCustomizationPickerViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotCustomizationPickerViewController.h"
#import "RobotCustomizationPickerViewModel.h"
#import "RobotData.hpp"
#import <objc/message.h>
#import <objc/runtime.h>
#include <ranges>
#include <vector>

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewController ()
@property (retain, readonly, nonatomic) RobotCustomizationPickerViewModel *viewModel;
@property (retain, readonly, nonatomic) UICollectionView *collectionView;
@property (retain, readonly, nonatomic) UISegmentedControl *segmentedControl;
@property (retain, readonly, nonatomic) UICollectionViewCellRegistration *cellRegistration;
@end

@implementation RobotCustomizationPickerViewController
@synthesize viewModel = _viewModel;
@synthesize collectionView = _collectionView;
@synthesize segmentedControl = _segmentedControl;
@synthesize cellRegistration = _cellRegistration;

- (void)dealloc {
    [_viewModel release];
    [_collectionView release];
    [_segmentedControl release];
    [_cellRegistration release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cellRegistration];
    
    UIView *view = self.view;
    
    UISegmentedControl *segmentedControl = self.segmentedControl;
    UICollectionView *collectionView = self.collectionView;
    
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:segmentedControl];
    [view addSubview:collectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [segmentedControl.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor],
        [segmentedControl.leadingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.leadingAnchor],
        [segmentedControl.trailingAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.trailingAnchor],
        [segmentedControl.bottomAnchor constraintEqualToAnchor:collectionView.topAnchor],
        [collectionView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [collectionView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [collectionView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor]
    ]];
    
    NSInteger headPartIndex = [segmentedControl segmentIndexForActionIdentifier:[RobotCustomizationPickerViewController identifierFromPart:RobotData::Part::Head]];
    
    reinterpret_cast<void (*)(id, SEL, NSInteger, BOOL)>(objc_msgSend)(segmentedControl,
                                                                       sel_registerName("_setSelectedSegmentIndex:notify:"),
                                                                       headPartIndex,
                                                                       YES);
}

- (RobotCustomizationPickerViewModel *)viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    RobotCustomizationPickerViewModel *viewModel = [[RobotCustomizationPickerViewModel alloc] initWithDataSource:[self makeDataSource]];
    
    _viewModel = [viewModel retain];
    return [viewModel autorelease];
}

- (UICollectionView *)collectionView {
    if (auto collectionView = _collectionView) return collectionView;
    
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
    [listConfiguration release];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];
    
    _collectionView = [collectionView retain];
    return [collectionView autorelease];
}

- (UISegmentedControl *)segmentedControl {
    if (auto segmentedControl = _segmentedControl) return segmentedControl;
    
    RobotCustomizationPickerViewModel *viewModel = self.viewModel;
    
    std::vector<UIAction *> actionsVector = RobotData::getAllParts() |
    std::views::transform([viewModel](RobotData::Part part) {
        NSString *title = [RobotCustomizationPickerViewController stringFromPart:part];
        NSString *identifier = [RobotCustomizationPickerViewController identifierFromPart:part];
        
        UIAction *action = [UIAction actionWithTitle:title
                                               image:nil
                                          identifier:identifier
                                             handler:^(__kindof UIAction * _Nonnull action) {
            // TODO: selectedMaterial
            [viewModel updateDataSourceWithSelectedPart:part selectedMaterial:RobotData::Material::Metal];
        }];
        
        return action;
    }) | std::ranges::to<std::vector>();
    
    NSArray<UIAction *> *actions = [[NSArray alloc] initWithObjects:actionsVector.data() count:actionsVector.size()];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectNull actions:actions];
    
    [actions release];
    
    _segmentedControl = [segmentedControl retain];
    return [segmentedControl autorelease];
}

- (UICollectionViewCellRegistration *)cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(__kindof UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, RobotCustomizationPickerItemModel * _Nonnull itemModel) {
        auto variant = itemModel.variant;
        
        if (auto selectedPartIndexPtr = std::get_if<swift::Int>(&variant)) {
            UIListContentConfiguration *contentConfiguration = [cell defaultContentConfiguration];
            // TODO: selectedPart
            contentConfiguration.image = [RobotCustomizationPickerViewController imageFromPartIndex:*selectedPartIndexPtr part:RobotData::Part::Head];
            contentConfiguration.imageProperties.maximumSize = CGSizeMake(80., 80.);
            cell.contentConfiguration = contentConfiguration;
            cell.backgroundConfiguration = [cell defaultBackgroundConfiguration];
        } else if (auto facePtr = std::get_if<RobotData::Face>(&variant)) {
            UIListContentConfiguration *contentConfiguration = [cell defaultContentConfiguration];
            contentConfiguration.image = [RobotCustomizationPickerViewController imageFromFace:*facePtr];
            contentConfiguration.imageProperties.maximumSize = CGSizeMake(80., 80.);
            cell.contentConfiguration = contentConfiguration;
            cell.backgroundConfiguration = [cell defaultBackgroundConfiguration];
        } else if (auto materialPtr = std::get_if<RobotData::Material>(&variant)) {
            UIListContentConfiguration *contentConfiguration = [cell defaultContentConfiguration];
            contentConfiguration.image = [RobotCustomizationPickerViewController imageFromMaterial:*materialPtr];
            contentConfiguration.imageProperties.maximumSize = CGSizeMake(80., 80.);
            cell.contentConfiguration = contentConfiguration;
            cell.backgroundConfiguration = [cell defaultBackgroundConfiguration];
        } else if (auto materialColorPtr = std::get_if<RobotData::MaterialColor>(&variant)) {
            UIBackgroundConfiguration *backgroundConfiguration = [cell defaultBackgroundConfiguration];
            backgroundConfiguration.backgroundColor = [RobotCustomizationPickerViewController colorFromMaterialColor:*materialColorPtr];
            cell.contentConfiguration = [cell defaultContentConfiguration];
            cell.backgroundConfiguration = backgroundConfiguration;
        } else if (auto lightColorPtr = std::get_if<RobotData::LightColor>(&variant)) {
            UIBackgroundConfiguration *backgroundConfiguration = [cell defaultBackgroundConfiguration];
            backgroundConfiguration.backgroundColor = [RobotCustomizationPickerViewController colorFromLightColor:*lightColorPtr];
            cell.contentConfiguration = [cell defaultContentConfiguration];
            cell.backgroundConfiguration = backgroundConfiguration;
        } else {
            abort();
        }
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (RobotCustomizationPickerViewModelDataSource *)makeDataSource __attribute__((objc_direct)) {
    UICollectionViewCellRegistration *cellRegistration = self.cellRegistration;
    
    RobotCustomizationPickerViewModelDataSource *dataSource = [[RobotCustomizationPickerViewModelDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        return [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
    }];
    
    return [dataSource autorelease];
}

+ (NSString *)stringFromPart:(RobotData::Part)part __attribute__((objc_direct)) {
    switch (part) {
        case RobotData::Part::Head:
            return @"Head";
        case RobotData::Part::Body:
            return @"Body";
        case RobotData::Part::Backpack:
            return @"Backpack";
        default:
            abort();
    }
}

+ (NSString *)identifierFromPart:(RobotData::Part)part __attribute__((objc_direct)) {
    switch (part) {
        case RobotData::Part::Head:
            return @"head";
        case RobotData::Part::Body:
            return @"body";
        case RobotData::Part::Backpack:
            return @"backpack";
        default:
            abort();
    }
}

+ (UIImage *)imageFromPartIndex:(swift::Int)partIndex part:(RobotData::Part)part __attribute__((objc_direct)) {
    NSString *imageName;
    switch (part) {
        case RobotData::Part::Head:
            imageName = [NSString stringWithFormat:@"head%ld", partIndex];
            break;
        case RobotData::Part::Body:
            imageName = [NSString stringWithFormat:@"body%ld", partIndex];
            break;
        case RobotData::Part::Backpack:
            imageName = [NSString stringWithFormat:@"backpack%ld", partIndex];
            break;
        default:
            abort();
    }
    
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)imageFromFace:(RobotData::Face)face __attribute__((objc_direct)) {
    NSString *imageName;
    
    switch (face) {
        case RobotData::Face::Square:
            imageName = @"square";
            break;
        case RobotData::Face::Circle:
            imageName = @"circle";
            break;
        case RobotData::Face::Heart:
            imageName = @"heart";
            break;
        default:
            abort();
    }
    
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)imageFromMaterial:(RobotData::Material)material __attribute__((objc_direct)) {
    NSString *imageName;
    switch (material) {
        case RobotData::Material::Metal:
            imageName = @"metal";
            break;
        case RobotData::Material::Rainbow:
            imageName = @"rainbow";
            break;
        case RobotData::Material::Plastic:
            imageName = @"plastic";
            break;
        case RobotData::Material::Mesh:
            imageName = @"mesh";
            break;
        default:
            abort();
    }
    
    return [UIImage imageNamed:imageName];
}

+ (UIColor *)colorFromMaterialColor:(RobotData::MaterialColor)materialColor __attribute__((objc_direct)) {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    switch (materialColor) {
        case RobotData::MaterialColor::MetalPink:
            red = 226. / 255.;
            green = 95. / 255.;
            blue = 151. / 255.;
            break;
        case RobotData::MaterialColor::MetalOrange:
            red = 227. / 255.;
            green = 138. / 255.;
            blue = 29. / 255.;
            break;
        case RobotData::MaterialColor::MetalGreen:
            red = 150. / 255.;
            green = 194. / 255.;
            blue = 70. / 255.;
            break;
        case RobotData::MaterialColor::MetalBlue:
            red = 92. / 255.;
            green = 140. / 255.;
            blue = 199. / 255.;
            break;
        case RobotData::MaterialColor::Beige:
            red = 224. / 255.;
            green = 211. / 255.;
            blue = 180. / 255.;
            break;
        case RobotData::MaterialColor::RainbowRed:
            red = 255. / 255.;
            green = 59. / 255.;
            blue = 48. / 255.;
            break;
        case RobotData::MaterialColor::Rose:
            red = 244. / 255.;
            green = 201. / 255.;
            blue = 201. / 255.;
            break;
        case RobotData::MaterialColor::Black:
            red = 0.;
            green = 0.;
            blue = 0.;
            break;
        case RobotData::MaterialColor::PlasticBlue:
            red = 59. / 255.;
            green = 152. / 255.;
            blue = 167. / 255.;
            break;
        case RobotData::MaterialColor::PlasticPink:
            red = 233. / 255.;
            green = 73. / 255.;
            blue = 127. / 255.;
            break;
        case RobotData::MaterialColor::PlasticOrange:
            red = 247. / 255.;
            green = 150. / 255.;
            blue = 31. / 255.;
            break;
        case RobotData::MaterialColor::PlasticGreen:
            red = 61. / 255.;
            green = 160. / 255.;
            blue = 87. / 255.;
            break;
        case RobotData::MaterialColor::MeshGray:
            red = 199. / 255.;
            green = 199. / 255.;
            blue = 204. / 255.;
            break;
        case RobotData::MaterialColor::MeshOrange:
            red = 206. / 255.;
            green = 78. / 255.;
            blue = 52. / 255.;
            break;
        case RobotData::MaterialColor::MeshYellow:
            red = 245. / 255.;
            green = 181. / 255.;
            blue = 58. / 255.;
            break;
        default:
            abort();
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.];
}

+ (UIColor *)colorFromLightColor:(RobotData::LightColor)lightColor __attribute__((objc_direct)) {
    switch (lightColor) {
        case RobotData::LightColor::Red:
            return [UIColor systemRedColor];
        case RobotData::LightColor::Yellow:
            return [UIColor systemYellowColor];
        case RobotData::LightColor::Green:
            return [UIColor systemGreenColor];
        case RobotData::LightColor::Blue:
            return [UIColor systemBlueColor];
        case RobotData::LightColor::Purple:
            return [UIColor systemPurpleColor];
        case RobotData::LightColor::White:
            return [UIColor whiteColor];
        case RobotData::LightColor::Rainbow:
            return [UIColor blackColor];
        case RobotData::LightColor::PurpleBlue:
            return [UIColor blackColor];
        default:
            abort;
    }
}

@end
