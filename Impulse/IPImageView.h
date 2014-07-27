//
//  IPImageView.h
//  Impulse
//
//  Created by Jerome, Samuel on 7/27/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPImageView : UIImageView
@property (nonatomic, strong) NSString *price;
@property (nonatomic,strong) NSString *postID;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@end
