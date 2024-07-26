//
//  ExplorationBoardViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import "ExplorationBoardViewController.h"
#import "_ExplorationBoardView.h"
#import "Exploration.h"

__attribute__((objc_direct_members))
@interface ExplorationBoardViewController ()
@property (retain, readonly, nonatomic) _ExplorationBoardView *boardView;
@property (retain, readonly, nonatomic) NSUUID *sessionUUID;
@end

@implementation ExplorationBoardViewController
@synthesize boardView = _boardView;

- (instancetype)initWithSessionUUID:(NSUUID *)sessionUUID {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _sessionUUID = [sessionUUID retain];
    }
    
    return self;
}

- (void)dealloc {
    [_boardView release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.boardView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveDidChangePlantsFoundNotification:)
                                               name:ExplorationDidChangePlantsFoundNotificationName
                                             object:nil];
}

- (_ExplorationBoardView *)boardView {
    if (auto boardView = _boardView) return boardView;
    
    _ExplorationBoardView *boardView = [_ExplorationBoardView new];
    
    _boardView = [boardView retain];
    return [boardView autorelease];
}

- (void)didReceiveDidChangePlantsFoundNotification:(NSNotification *)notification {
    
}

@end