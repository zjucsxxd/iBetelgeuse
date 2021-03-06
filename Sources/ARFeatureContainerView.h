//
//  ARFeatureContainerView.h
//  iBetelgeuse
//
//  Copyright 2010 Finalist IT Group. All rights reserved.
//
//  This file is part of iBetelgeuse.
//  
//  iBetelgeuse is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  iBetelgeuse is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with iBetelgeuse.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ARPoint3D.h"


@class ARSpatialState;


/**
 * This class contains all features, and applies the required transformations to
 * them so that they are properly projected.
 */
@interface ARFeatureContainerView : UIView {
@private
	CATransform3D EFToDeviceSpaceTransform;
	CATransform3D perspectiveTransform;
	CATransform3D screenTransform;
	CATransform3D invertedScreenTransform;
	CGFloat distanceFactor;
}

/**
 * Update the transformation, the positions and orientations of the features,
 * etc. based on the new spatial state.
 * @param spatialState the new spatial state.
 * @param relativeAltitude YES if relative altitudes is enabled for the dimension.
 */
- (void)updateWithSpatialState:(ARSpatialState *)spatialState usingRelativeAltitude:(BOOL)relativeAltitude;

@end
