

#import "ViewController.h"

@interface ViewController () <GMBLPlaceManagerDelegate, GMBLCommunicationManagerDelegate, GMBLExperienceManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) GMBLCommunicationManager *communicationManager;
@property (nonatomic) GMBLExperienceManager *experienceManager;

@property (nonatomic, readonly) NSArray *events;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    
    self.communicationManager = [GMBLCommunicationManager new];
    self.communicationManager.delegate = self;
    
    self.experienceManager = [GMBLExperienceManager new];
    self.experienceManager.delegate = self;
}

# pragma mark - Gimbal PlaceManager delegate methods

- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit
{
    [self addEventWithMessage:visit.place.name date:visit.arrivalDate icon:@"placeEnter"];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit
{
    [self addEventWithMessage:visit.place.name date:visit.departureDate icon:@"placeExit"];
}

- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit withDelay:(NSTimeInterval)delayTime
{
    if (delayTime > 5.0){
        [self addEventWithMessage:[@"Delay: " stringByAppendingString:visit.place.name]  date:[NSDate date] icon:@"placeDelay"];
    }
}

# pragma mark - Gimbal CommunicationManager delegate methods

- (UILocalNotification *)communicationManager:(GMBLCommunicationManager *)manager
prepareNotificationForDisplay:(UILocalNotification *)notification forCommunication:(GMBLCommunication *)communication
{
    NSString *description = [NSString stringWithFormat:@"%@ %@", communication.descriptionText, @": CONTENT_DELIVERED"];
    [self addEventWithMessage:description date:[NSDate date] icon:@"commPresented"];
    
    // If you want to customize the notification, do it here.
    
    return notification;
}


- (UNNotificationContent *)communicationManager:(GMBLCommunicationManager *)manager
           prepareNotificationContentForDisplay:(UNMutableNotificationContent *)notificationContent
                               forCommunication:(GMBLCommunication *)communication
{
    NSString *description = [NSString stringWithFormat:@"%@ %@", communication.descriptionText, @": CONTENT_DELIVERED"];
    [self addEventWithMessage:description date:[NSDate date] icon:@"commPresented"];
    
    // If you want to customize the notification, do it here.
    
    return notificationContent;
}

# pragma mark - Gimbal ExperienceManager delegate methods

-(NSArray *)experienceManager:(GMBLExperienceManager *)experienceManager filterActions:(NSArray *)receivedActions
{
    return receivedActions;
}

-(void)experienceManager:(GMBLExperienceManager *)experienceManager
   presentViewController:(UIViewController *)actionViewController
               forAction:(GMBLAction *)action
{
    [self.navigationController popToViewController:self animated:YES];
    [self.navigationController pushViewController:actionViewController animated:YES];
    
    [self addEventWithMessage:[NSString stringWithFormat:@"%@", (action.notificationMessage ? action.notificationMessage : @"Experience")] date:[NSDate date] icon:@"experience"];
}


#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *item = self.events[indexPath.row];
    
    cell.textLabel.text = item[@"message"];
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:item[@"date"]
                                                               dateStyle:NSDateFormatterMediumStyle
                                                               timeStyle:NSDateFormatterMediumStyle];
    cell.imageView.image = [UIImage imageNamed:item[@"icon"]];
    
    return cell;
}

#pragma mark - Utility methods

- (NSArray *)events
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"events"];
}

- (void)addCommunication:(GMBLCommunication *)communication
{
    NSString *description = [NSString stringWithFormat:@"%@ %@", communication.descriptionText, @": CONTENT_CLICKED"];
    [self addEventWithMessage:description date:[NSDate date] icon:@"commEnter.png"];
}

- (void)addEventWithMessage:(NSString *)message date:(NSDate *)date icon:(NSString *)icon
{
    NSDictionary *item = @{@"message":message, @"date":date, @"icon":icon};
    
    NSLog(@"Event %@",[item description]);
    
    NSMutableArray *events = [NSMutableArray arrayWithArray:self.events];
    [events insertObject:item atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:@"events"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
