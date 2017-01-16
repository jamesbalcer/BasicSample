

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

#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // here you'll need to check if the segue identifier is equal to the segue that take you to your Details View Controller. I believe it's this "listView"

    if ([segue.identifier isEqualToString:@"listView"]) {

        // get a reference to your Details View Controller

        ListViewController *destinationVC  = (ListViewController *)segue.destinationViewController

        // you need to obtain the item selected from the tableView

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow]

        // you have the events array, get item selected. What's types of obects are in the Events array?

        // you're gonna do something like
        // Event *event = events[indexPath.row]      => now you have the event that you're gonna pass to the Details VC
        // next, you set the property you declared in your ListViewController to this event

        //something like:
       // destinationVC.someProperty = event


    }
}

@end
