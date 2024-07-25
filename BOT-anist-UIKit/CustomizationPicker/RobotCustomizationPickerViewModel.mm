//
//  RobotCustomizationPickerViewModel.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotCustomizationPickerViewModel.h"
#include <ranges>
#include <vector>

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewModel ()
@property (retain, readonly, nonatomic) RobotCustomizationPickerViewModelDataSource *dataSource;
@property (retain, readonly, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) RobotData robotData;
@end

@implementation RobotCustomizationPickerViewModel

- (instancetype)initWithDataSource:(RobotCustomizationPickerViewModelDataSource *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
        
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY);
        _queue = dispatch_queue_create("RobotCustomizationPickerViewModel", attr);
        _robotData = {};
    }
    
    return self;
}

- (void)dealloc {
    [_dataSource release];
    
    if (auto queue = _queue) {
        dispatch_release(queue);
    }
    
    [super dealloc];
}

- (void)updateDataSourceWithSelectedPart:(RobotData::Part)part {
    dispatch_async(self.queue, ^{
        [self _updateDataSourceWithSelectedPart:part];
    });
}

- (void)handleSelectedIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(self.queue, ^{
        [self _handleSelectedIndexPath:indexPath];
    });
}

- (void)_updateDataSourceWithSelectedPart:(RobotData::Part)part __attribute__((objc_direct)) {
    RobotData robotData = self.robotData;
    
    NSDiffableDataSourceSnapshot<RobotCustomizationPickerSectionModel *,RobotCustomizationPickerItemModel *> *snapshot = [NSDiffableDataSourceSnapshot new];
    
    //
    
    RobotCustomizationPickerSectionModel *partIndexSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypePartIndex];
    
    [snapshot appendSectionsWithIdentifiers:@[partIndexSectionModel]];
    
    auto partIndexItemModelsVector = RobotData::getIndicesByPart(part) |
    std::views::transform([part, &robotData, partIndexSectionModel](swift::Int index) {
        RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] 
                                                        initWithVariant:index
                                                        sectionModel:partIndexSectionModel
                                                        selectedPart:part
                                                        selected:robotData.getSelectedIndexByPart(part) == index];
        
        return [itemModel autorelease];
    }) |
    std::ranges::to<std::vector>();
    
    NSArray<RobotCustomizationPickerItemModel *> *partIndexItemModels = [[NSArray alloc] initWithObjects:partIndexItemModelsVector.data() count:partIndexItemModelsVector.size()];
    
    [snapshot appendItemsWithIdentifiers:partIndexItemModels intoSectionWithIdentifier:partIndexSectionModel];
    
    [partIndexSectionModel release];
    [partIndexItemModels release];
    
    //
    
    if (part == RobotData::Part::Head) {
        RobotCustomizationPickerSectionModel *faceSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypeFace];
        
        [snapshot appendSectionsWithIdentifiers:@[faceSectionModel]];
        
        auto faceItemModelsVector = RobotData::getAllFaces() |
        std::views::transform([&robotData, part, faceSectionModel](RobotData::Face face) {
            RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:face
                                                                                                         sectionModel:faceSectionModel
                                                                                                         selectedPart:part
                                                                                                             selected:robotData.getFace() == face];
            return [itemModel autorelease];
        }) |
        std::ranges::to<std::vector>();
        
        NSArray<RobotCustomizationPickerItemModel *> *faceItemModels = [[NSArray alloc] initWithObjects:faceItemModelsVector.data() count:faceItemModelsVector.size()];
        
        [snapshot appendItemsWithIdentifiers:faceItemModels intoSectionWithIdentifier:faceSectionModel];
        [faceItemModels release];
        
        [faceSectionModel release];
    }
    
    //
    
    RobotCustomizationPickerSectionModel *materialSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypeMaterial];
    
    [snapshot appendSectionsWithIdentifiers:@[materialSectionModel]];
    
    auto materialItemModelsVector = RobotData::getAllMaterials() |
    std::views::transform([&robotData, part, materialSectionModel](RobotData::Material material) {
        RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:material
                                                                                                     sectionModel:materialSectionModel
                                                                                                     selectedPart:part
                                                                                                         selected:robotData.getMaterialByPart(part) == material];
        
        return [itemModel autorelease];
    }) |
    std::ranges::to<std::vector>();
    
    NSArray<RobotCustomizationPickerItemModel *> *faceItemModels = [[NSArray alloc] initWithObjects:materialItemModelsVector.data() count:materialItemModelsVector.size()];
    
    [snapshot appendItemsWithIdentifiers:faceItemModels intoSectionWithIdentifier:materialSectionModel];
    
    [materialSectionModel release];
    [faceItemModels release];
    
    //
    
    RobotCustomizationPickerSectionModel *materialColorSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypeMaterialColor];
    
    [snapshot appendSectionsWithIdentifiers:@[materialColorSectionModel]];
    
    auto materialColorItemModelsVector = RobotData::getMaterialColorsByMaterial(robotData.getMaterialByPart(part)) |
    std::views::transform([&robotData, part, materialColorSectionModel](RobotData::MaterialColor materialColor) {
        RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:materialColor
                                                                                                     sectionModel:materialColorSectionModel 
                                                                                                     selectedPart:part
                                                                                                         selected:robotData.getMaterialColorByPart(part) == materialColor];
        
        return [itemModel autorelease];
    }) |
    std::ranges::to<std::vector>();
    
    NSArray<RobotCustomizationPickerItemModel *> *materialColorItemModels = [[NSArray alloc] initWithObjects:materialColorItemModelsVector.data() count:materialColorItemModelsVector.size()];
    
    [snapshot appendItemsWithIdentifiers:materialColorItemModels intoSectionWithIdentifier:materialColorSectionModel];
    
    [materialColorSectionModel release];
    [materialColorItemModels release];
    
    //
    
    RobotCustomizationPickerSectionModel *lightColorSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypeLightColor];
    
    [snapshot appendSectionsWithIdentifiers:@[lightColorSectionModel]];
    
    auto lightColorsVector = RobotData::getAllLightColors() |
    std::views::transform([&robotData, part, lightColorSectionModel](RobotData::LightColor lightColor) {
        RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:lightColor
                                                                                                     sectionModel:lightColorSectionModel
                                                                                                     selectedPart:part
                                                                                                         selected:robotData.getLightColorByPart(part) == lightColor];
        
        return [itemModel autorelease];
    }) |
    std::ranges::to<std::vector>();
    
    NSArray<RobotCustomizationPickerItemModel *> *lightColorItemModels = [[NSArray alloc] initWithObjects:lightColorsVector.data() count:lightColorsVector.size()];
    
    [snapshot appendItemsWithIdentifiers:lightColorItemModels intoSectionWithIdentifier:lightColorSectionModel];
    
    [lightColorSectionModel release];
    [lightColorItemModels release];
    
    //
    
//    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    [self.dataSource applySnapshotUsingReloadData:snapshot];
    [snapshot release];
}

- (void)_handleSelectedIndexPath:(NSIndexPath *)indexPath __attribute__((objc_direct)) {
    RobotCustomizationPickerViewModelDataSource *dataSource = self.dataSource;
    RobotCustomizationPickerItemModel *itemModel = [dataSource itemIdentifierForIndexPath:indexPath];
    assert(itemModel != nil);
    
    RobotData robotData = self.robotData;
    RobotData::Part part = itemModel.selectedPart;
    auto varient = itemModel.variant;
    
    if (auto selectedPartIndexPtr = std::get_if<swift::Int>(&varient)) {
        robotData.setSelectedIndexByPart(part, *selectedPartIndexPtr);
    } else if (auto facePtr = std::get_if<RobotData::Face>(&varient)) {
        robotData.setFace(*facePtr);
    } else if (auto materialPtr = std::get_if<RobotData::Material>(&varient)) {
        robotData.setMaterialByPart(*materialPtr, part);
        
        RobotData::MaterialColor firstMaterialColor = RobotData::getMaterialColorsByMaterial(*materialPtr).at(0);
        robotData.setMaterialColorByPart(firstMaterialColor, part);
    } else if (auto materialColorPtr = std::get_if<RobotData::MaterialColor>(&varient)) {
        robotData.setMaterialColorByPart(*materialColorPtr, part);
    } else if (auto lightColorPtr = std::get_if<RobotData::LightColor>(&varient)) {
        robotData.setLightColorByPart(*lightColorPtr, part);
    } else {
        abort();
    }
    
    self.robotData = robotData;
    [self postRobotDataDidChangeNotification];
    
    [self _updateDataSourceWithSelectedPart:part];
//    NSDiffableDataSourceSnapshot<RobotCustomizationPickerSectionModel *, RobotCustomizationPickerItemModel *> *snapshot = [dataSource.snapshot copy];
//    [snapshot reconfigureItemsWithIdentifiers:@[]]
}

- (void)postRobotDataDidChangeNotification __attribute__((objc_direct)) {
    // https://x.com/_silgen_name/status/1816481593869103433
    RobotData *copyPtr = new RobotData(self.robotData);
    NSData *data = [[NSData alloc] initWithBytesNoCopy:copyPtr length:sizeof(RobotData) deallocator:^(void * _Nonnull bytes, NSUInteger length) {
        delete reinterpret_cast<RobotData *>(bytes);
    }];
    
    [NSNotificationCenter.defaultCenter postNotificationName:RobotCustomizationPickerViewModelRobotDataDidChangeNotificationName
                                                      object:self
                                                    userInfo:@{RobotCustomizationPickerViewModelRobotDataKey: data}];
    
    [data release];
}

@end
