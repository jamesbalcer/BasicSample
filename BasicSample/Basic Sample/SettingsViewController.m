

#import "SettingsViewController.h"

#import <Gimbal/Gimbal.h>

@interface SettingsViewController ()
    @property (weak, nonatomic) IBOutlet UISwitch *gimbalMonitoringSwitch;
    @property (weak, nonatomic) IBOutlet UISwitch *gimbalExperienceMonitoringSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.gimbalMonitoringSwitch setOn:[Gimbal isStarted] animated:NO];
    if (![Gimbal isStarted])
    {
        UIView *subView = [self.view viewWithTag:5000];
        [subView setUserInteractionEnabled:NO];
        [subView setAlpha:0.2];
    }
    else {
        [self.gimbalExperienceMonitoringSwitch setOn:[GMBLExperienceManager isMonitoring] animated:NO];
    }
}

- (IBAction)toggleGimbalMonitoringSwitch:(UISwitch *)sender {
    if (sender.isOn)
    {
        [Gimbal start];
        [self.gimbalExperienceMonitoringSwitch setOn:[GMBLExperienceManager isMonitoring] animated:NO];
        UIView *subView = [self.view viewWithTag:5000];
        [subView setUserInteractionEnabled:YES];
        [subView setAlpha:1];
    }
    else
    {
        [Gimbal stop];
        UIView *subView = [self.view viewWithTag:5000];
        [subView setUserInteractionEnabled:NO];
        [subView setAlpha:0.2];
    }
}
- (IBAction)toggleGimbalExperienceMonitoringSwitch:(UISwitch *)sender {
    if (sender.isOn)
    {
        [GMBLExperienceManager startExperiences];
    }
    else
    {
        [GMBLExperienceManager stopExperiences];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        [Gimbal resetApplicationInstanceIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
@end
