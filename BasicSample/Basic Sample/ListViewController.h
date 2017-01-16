//
//  ListViewController.h
//  BasicSample
//
//  Created by James Balcer on 1/11/17.
//  Copyright © 2017 Gimbal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController

// here you want to have property to store the event/whatever object you need to pass to this view controller. I would keep all the labels, textviews and other subviews private. So keep them in the .m file. Use the property you declare here to fill out the information you need for those views.
//@property (nonatomic) SomeTypeObject *variableName
//note this property will be visible to other files.

@end
