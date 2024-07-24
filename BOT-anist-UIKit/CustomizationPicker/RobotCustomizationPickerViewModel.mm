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

- (void)updateDataSourceWithSelectedPart:(RobotData::Part)part selectedMaterial:(RobotData::Material)material __attribute__((objc_direct)) {
    dispatch_async(self.queue, ^{
        NSDiffableDataSourceSnapshot<RobotCustomizationPickerSectionModel *,RobotCustomizationPickerItemModel *> *snapshot = [NSDiffableDataSourceSnapshot new];
        
        //
        
        RobotCustomizationPickerSectionModel *partIndexSectionModel = [[RobotCustomizationPickerSectionModel alloc] initWithType:RobotCustomizationPickerSectionModelTypePartIndex];
        
        [snapshot appendSectionsWithIdentifiers:@[partIndexSectionModel]];
        
        auto partIndexItemModelsVector = RobotData::getIndicesByPart(part) |
        std::views::transform([part, partIndexSectionModel](swift::Int index) {
            RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:index sectionModel:partIndexSectionModel selectedPart:part];
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
            std::views::transform([part, faceSectionModel](RobotData::Face face) {
                RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:face sectionModel:faceSectionModel selectedPart:part];
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
        std::views::transform([part, materialSectionModel](RobotData::Material material) {
            RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:material sectionModel:materialSectionModel selectedPart:part];
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
        
        auto materialColorItemModelsVector = RobotData::getMaterialColorsByMaterial(material) |
        std::views::transform([part, materialColorSectionModel](RobotData::MaterialColor materialColor) {
            RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:materialColor sectionModel:materialColorSectionModel selectedPart:part];
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
        std::views::transform([part, lightColorSectionModel](RobotData::LightColor lightColor) {
            RobotCustomizationPickerItemModel *itemModel = [[RobotCustomizationPickerItemModel alloc] initWithVariant:lightColor sectionModel:lightColorSectionModel selectedPart:part];
            return [itemModel autorelease];
        }) |
        std::ranges::to<std::vector>();
        
        NSArray<RobotCustomizationPickerItemModel *> *lightColorItemModels = [[NSArray alloc] initWithObjects:lightColorsVector.data() count:lightColorsVector.size()];
        
        [snapshot appendItemsWithIdentifiers:lightColorItemModels intoSectionWithIdentifier:lightColorSectionModel];
        
        [lightColorSectionModel release];
        [lightColorItemModels release];
        
        //
        
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
        [snapshot release];
    });
}

@end
