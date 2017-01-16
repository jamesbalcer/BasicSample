

#import "OptInViewController.h"

#import <Gimbal/Gimbal.h>

@interface OptInViewController ()

@end

@implementation OptInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)didEnable
{
    [Gimbal start];
    [GMBLExperienceManager startExperiences];
    
    [self presentMainViewController];
}

- (IBAction)didNotEnable
{
    [self presentMainViewController];
}

- (void)presentMainViewController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasBeenPresentedWithOptInScreen"];
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:vc animated:YES completion:^{
        [[UIApplication sharedApplication].delegate window].rootViewController = vc;
    }];
}

- (IBAction)didPressShowPrivacyPolicy
{
#warning Place a link to your privacy policy below
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://your-privacy-policy-url"]];
}

- (IBAction)didPressShowTermsOfUse
{
#warning Place a link to your terms of use below
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://your-terms-of-use-url"]];
}

@end
