//
//  MiProductViewController.m
//  JuiceSync
//
//  Created by Guorong ZHANG on 4/8/14.
//
//

#import "MiProductViewController.h"
//#import "MiDiscoveryCell.h"
#import "MiMainViewController.h"
#import "MiPeripherialCell.h"

@interface MiProductViewController ()

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSString *periphRename;
@property (nonatomic, strong) NSTimer *savePowerTimer;
@property (nonatomic, assign) int rssi;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MiProductViewController
{
    MiBlueToothGlobal *instance;
    NSInteger  selectedRow;
}


@synthesize peripherals,periphRename,savePowerTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DelegateBecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delegateBecomeActive:)
                                                 name:@"DelegateBecomeActive"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DelegateBecomeActiveNoReload" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delegateBecomeActiveNoReload:)
                                                 name:@"DelegateBecomeActiveNoReload"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceStateReady" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceStateReady:)
                                                 name:@"DeviceStateReady"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphRefreshAdd" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(periphRefreshAdd:)
                                                 name:@"PeriphRefreshAdd"
                                               object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphReconnect" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(periphReconnect:)
    //                                             name:@"PeriphReconnect"
    //                                           object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphRefreshDelete" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(periphRefreshDelete:)
                                                 name:@"PeriphRefreshDelete"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphRefreshTable" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPeriphRefreshTable:)
                                                 name:@"PeriphRefreshTable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BluetoothOFF" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceStateOFF:)
                                                 name:@"BluetoothOFF"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RenameRefresh" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedRenameRefresh:)
                                                 name:@"RenameRefresh"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphDisconnectedErrorDeleteRefresh" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(periphDisconnectedErrorDeleteRefresh:)
                                                 name:@"PeriphDisconnectedErrorDeleteRefresh"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PeriphRSSIUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(periphRSSIUpdate:)
                                                 name:@"PeriphRSSIUpdate"
                                               object:nil];
    
    instance = [MiBlueToothGlobal shared];
    NSLog(@"invalidate1");
    
    self.peripherals = [NSMutableArray array];
    //[instance init];
    self.tableView.sectionFooterHeight = 0.0;
    self.navigationItem.title = NSLocalizedString(@"AppName", @"");
    
    self.tableView.dataSource =self;
    [self.tableView setDelegate:self];
    [self.view setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];//
    //in storyboard, view background also should be set as clear color which is whitecolor in default
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    selectedRow = 0;
}

-(void)viewWillAppear:(BOOL)animated{


}


-(void)delegateBecomeActiveNoReload:(NSNotification *)notification{
    
        
      //  [instance startScan];
        

}


-(void)delegateBecomeActive:(NSNotification *)notification{
   
        
   // [instance startScan];
    
    
    [self.tableView reloadData];
    
}


-(void)periphDisconnectedErrorDeleteRefresh:(NSNotification *)notification{
    
    CBPeripheral *myPeriph = (CBPeripheral *)notification.object;
    [peripherals removeObject:myPeriph];
    [self.tableView reloadData];
    
}
 

-(void)deviceStateReady:(NSNotification *)notification{
    
   // [instance startScan];
}


- (void)periphRSSIUpdate:(NSNotification *) notification {
    
    NSDictionary *myDict = (NSDictionary *)notification.object;
    
    CBPeripheral *myPeriph = (CBPeripheral *)[myDict objectForKey:@"peripheral"];
    NSNumber *myRSSI = (NSNumber *)[myDict objectForKey:@"rssi"];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"lastConnectUUID"] isEqualToString:[self GetUUID:myPeriph]]) {
        self.rssi = [myRSSI intValue];
    }
    
}

- (void)periphRefreshAdd:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"PeriphRefreshAdd"]) {
        
        CBPeripheral *myPeriph = (CBPeripheral *)notification.object;
        
        
        [[self peripherals] addObject:myPeriph];
        NSLog(@"%d",[self peripherals].count);
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray;
        sortedArray = [self.peripherals sortedArrayUsingDescriptors:sortDescriptors];
        NSLog(@"removeAllObjects1");
        [self.peripherals removeAllObjects];
        [self.peripherals addObjectsFromArray:sortedArray];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

/*
- (void)periphReconnect:(NSNotification *) notification {

    CBPeripheral *myPeriph = (CBPeripheral *)notification.object;
    int index = -1;
    for (int i = 0; i < self.peripherals.count; i++) {
        CBPeripheral *curPeriph = [self.peripherals objectAtIndex:i];
        if(curPeriph != myPeriph){
            [instance.manager cancelPeripheralConnection:curPeriph];
        }else{
            index = i;
        }
    }
    if (index != -1) {
        
        NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:index inSection:1];
        [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        CBPeripheral *CBobject = [self.peripherals objectAtIndex:selectedCellIndexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PeriphConnected" object:CBobject];
        
        //[self performSegueWithIdentifier:@"SegueProductToMain" sender:selectedCellIndexPath];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastConnectUUID"];
    }
    
}


 - (void)reconnect:(NSTimer *)timer {
 
 CBPeripheral *myPeriph = [timer userInfo];
 [self performSegueWithIdentifier:@"showDetail" sender:myPeriph];
 }
 */

- (NSString *)GetUUID :(CBPeripheral *)myPeriph
{
    CFUUIDRef theUUID = [myPeriph UUID];
    if (theUUID == 0x0) {
        //NSLog(@"Yes");
        return nil;
    }else{
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        return (__bridge_transfer NSString *)string ;
    }
}

- (void)periphRefreshDelete:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"PeriphRefreshDelete"]) {
        NSLog(@"%@",notification.object);
        
        [[self peripherals] removeObject:notification.object];
        NSLog(@"periph remains %d",peripherals.count);
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void)receivedPeriphRefreshTable:(NSNotification *) notification {
    NSLog(@"table refresh1");
    [self.tableView reloadData];
    
    //[self performSelector:@selector(delayAutoReconnect) withObject:nil afterDelay:0];
    
    
}
/*
-(void)autoReconnect{
    
    for (CBPeripheral* periph in peripherals) {
        
        //NSLog(@"reconnect, %d", [periph.RSSI intValue]);
        if ( self.rssi > -80 && !periph.isConnected && [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastConnectUUID"] isEqualToString:[self GetUUID:periph]] && [[NSUserDefaults standardUserDefaults]boolForKey:@"autoReconnect"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PeriphReconnect" object:periph];
            
            
        }
    }
}

-(void)delayAutoReconnect{
    [self autoReconnect];
}*/

- (void)deviceStateOFF:(NSNotification *) notification {
    NSLog(@"here check2");
    [[instance holdPeripherals] removeAllObjects];
    [[instance discoveredPeripherals] removeAllObjects];
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    
    
}

- (void)receivedRenameRefresh:(NSNotification *) notification {
    
    
    CBPeripheral *myPeriph = (CBPeripheral*)notification.object;
    self.periphRename = myPeriph.name;
    
    NSLog(@"update name %@", myPeriph.name);
    
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:[self.peripherals indexOfObject:myPeriph] inSection:1];
    // Add them in an index path array
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
    // Launch reload for the two index path
    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(section == 0)
    {
        if ([self.peripherals count] > 0) {
            return [self.peripherals count];
        }else{
            return 1;
        }
    }
    else
    {
        
        return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PeriphCell"];
    if(indexPath.section == 0){
        
       // NSLog(@"perioheral count is %d",[self.peripherals count]);
        
        if ([self.peripherals count] > 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"PeriphCell"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PeriphCell"];
                
            }
            
            CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
            
            MiPeripherialCell *tempCell = (MiPeripherialCell*)cell;
            [tempCell.contentView setBackgroundColor:[UIColor clearColor]];
            tempCell.periphName.text = peripheral.name;
            if (indexPath.row == selectedRow) {
                [tempCell.deviceItemBtn setImage: [UIImage imageNamed:@"device_box_white"]];
            }else{
            
                [tempCell.deviceItemBtn setImage: [UIImage imageNamed:@"device_box_selected_#d9dad6"]];
            }
            NSLog(@"detected %@",peripheral.name);
            //[cell setExclusiveTouch:YES];
        }else{
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoBatteryFound"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoBatteryFound"];
                
            }
        }
        
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.section == 0) {
    //   indexPathes = [tableView indexPathForSelectedRow];
    //}
    if (indexPath.section == 0) {
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
        NSLog(@"selected row %ld",(long)indexPath.row);
        selectedRow = indexPath.row;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
        if(indexPath.section== 0)
        {
            return 60;
        }else
        {
            return 44;
            
        }

}*/
-(void)tableView:(UITableView*)tableView  willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];//without this statement, a blank cell appear when no device found
}


- (IBAction)pariPeriph:(id)sender {
    [instance.manager stopScan];
    if([self.peripherals count] >0 ){
    [self performSegueWithIdentifier:@"SegueProductToMain" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueProductToMain"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CBPeripheral *object = [self.peripherals objectAtIndex:selectedRow];
        [[segue destinationViewController] setDetailItem:object];
    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    /*
     NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
     cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
     */
    
}


- (void)peripheralDidWriteChracteristic:(CBCharacteristic *)characteristic
                         withPeripheral:(CBPeripheral *)peripheral
                              withError:(NSError *)error
{
    
    
}

- (void)peripheralDidReadChracteristic:(CBCharacteristic *)characteristic
                        withPeripheral:(CBPeripheral *)peripheral
                             withError:(NSError *)error
{
    //NSLog(@"%@", characteristic.value);
    
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
