//
//  ARSpatialState.m
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

#import "ARSpatialState.h"
#import "ARLocation.h"
#import "ARWGS84.h"


@implementation ARSpatialState

#pragma mark NSObject

- (id)initWithLocationAvailable:(BOOL)isLocationAvailable 
					   reliable:(BOOL)isLocationReliable
					   latitude:(CLLocationDegrees)aLatitude 
					  longitude:(CLLocationDegrees)aLongitude
					   altitude:(CLLocationDistance)anAltitude 
		   orientationAvailable:(BOOL)isOrientationAvailable 
					   reliable:(BOOL)isOrientationReliable 
	 ENUToDeviceSpaceQuaternion:(ARQuaternion)anENUToDeviceSpaceQuaternion
			EFToECEFSpaceOffset:(ARPoint3D)anEFToECEFSpaceOffset 
					  timestamp:(NSDate *)aTimestamp {
	NSAssert(!isLocationAvailable || (-90. <= aLatitude && aLatitude <= 90.), @"Expected latitude in range [-90,90] degrees.");
	NSAssert(!isLocationAvailable || (-180. <= aLongitude && aLongitude <= 180.), @"Expected longitude in range [-180,180] degrees.");
	NSAssert(aTimestamp != nil, @"Expected non-nil timestamp.");
	
	if (self = [super init]) {
		flags.locationAvailable = isLocationAvailable;
		flags.locationReliable = isLocationReliable;
		flags.orientationAvailable = isOrientationAvailable;
		flags.orientationReliable = isOrientationReliable;
		latitude = aLatitude;
		longitude = aLongitude;
		altitude = anAltitude;
		ENUToDeviceSpaceQuaternion = anENUToDeviceSpaceQuaternion;
		EFToECEFSpaceOffset = anEFToECEFSpaceOffset;
		timestamp = [aTimestamp retain];
	}
	return self;
}

- (void)dealloc {
	[timestamp release];
	[location release];
	
	[super dealloc];
}

#pragma mark ARSpatialState

- (BOOL)isLocationAvailable {
	return flags.locationAvailable;
}

- (BOOL)isLocationReliable {
	return flags.locationReliable;
}

- (BOOL)isOrientationAvailable {
	return flags.orientationAvailable;
}

- (BOOL)isOrientationReliable {
	return flags.orientationReliable;
}

@synthesize timestamp;

- (ARLocation *)location {
	if ([self isLocationAvailable]) {
		if (location == nil) {
			location = [[ARLocation alloc] initWithLatitude:latitude longitude:longitude altitude:altitude];
		}
		return location;
	}
	else {
		return nil;
	}
}

@synthesize altitude;

- (ARPoint3D)locationInECEFSpace {
	if (!flags.haveLocationInECEFSpace) {
		locationInECEFSpace = ARWGS84GetECEF(latitude, longitude, altitude);
		flags.haveLocationInECEFSpace = YES;
	}
	return locationInECEFSpace;
}

- (ARPoint3D)locationInEFSpace {
	return ARPoint3DSubtract([self locationInECEFSpace], [self EFToECEFSpaceOffset]);
}

- (double)bearing {
	double bearing;
	ARTransform3D transform = [self DeviceToENUSpaceTransform];
	
	// Different calculations for when the device is horizontal (i.e. when the device z-axis about matches ENU's z-axis)
	if (fabsf(transform.m33) > .999) {
		bearing = -atan2f(transform.m12, transform.m11);
	} else {
		bearing = -atan2f(transform.m31, -transform.m32);
	}
	
	return bearing;
}

- (double)pitch {
	ARTransform3D transform = [self DeviceToENUSpaceTransform];
	double pitch = asinf(-transform.m33);
	return pitch;
}

- (double)roll {
	double roll;
	ARTransform3D transform = [self DeviceToENUSpaceTransform];
	
	// Different calculations for when the device is horizontal (i.e. when the device z-axis about matches ENU's z-axis)
	if (fabsf(transform.m33) > .999) {
		roll = 0;
	} else {
		roll = atan2f(transform.m13, transform.m23);
	}
	
	return roll;
}

- (ARPoint3D)upDirectionInENUSpace {
	return ARPoint3DMake(0., 0., 1.); // By definition
}

- (ARPoint3D)upDirectionInDeviceSpace {
	if (!flags.haveUpDirectionInDeviceSpace) {
		upDirectionInDeviceSpace = ARTransform3DHomogeneousVectorMatrixMultiply([self upDirectionInENUSpace], [self ENUToDeviceSpaceTransform]);
		flags.haveUpDirectionInDeviceSpace = true;
	}
	return upDirectionInDeviceSpace;
}

- (ARPoint3D)upDirectionInECEFSpace {
	return [self locationInECEFSpace];
}

- (ARPoint3D)upDirectionInEFSpace {
	return [self upDirectionInECEFSpace];
}

- (ARPoint3D)northDirectionInENUSpace {
	return ARPoint3DMake(0., 1., 0.); // By definition; alongst the horizontal plane. TODO: Document that the northDirectionIn...Space methods do -not- return the same vector when transformed back to the same space.
}

- (ARPoint3D)northDirectionInDeviceSpace {
	if (!flags.haveNorthDirectionInDeviceSpace) {
		northDirectionInDeviceSpace = ARTransform3DHomogeneousVectorMatrixMultiply([self northDirectionInENUSpace], [self ENUToDeviceSpaceTransform]);
		flags.haveNorthDirectionInDeviceSpace = true;
	}
	return northDirectionInDeviceSpace;
}

- (ARPoint3D)northDirectionInECEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return ARPoint3DMake(0., 0., 1.);
}

- (ARPoint3D)northDirectionInEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return [self northDirectionInECEFSpace];
}

- (CATransform3D)ENUToDeviceSpaceTransform {
	if (!flags.haveENUToDeviceSpaceTransform) {
		if ([self isOrientationAvailable]) {
			ENUToDeviceSpaceTransform = ARQuaternionConvertToMatrix(ENUToDeviceSpaceQuaternion);
		}
		else {
			ENUToDeviceSpaceTransform = CATransform3DIdentity;
		}
		flags.haveENUToDeviceSpaceTransform = YES;
	}
	return ENUToDeviceSpaceTransform;
}

- (CATransform3D)DeviceToENUSpaceTransform {
	if (!flags.haveDeviceToENUSpaceTransform) {
		// Since we're dealing with orthogonal matrices, transposing is the same as inverting (but then easier)
		DeviceToENUSpaceTransform = ARTransform3DTranspose([self ENUToDeviceSpaceTransform]);
		flags.haveDeviceToENUSpaceTransform = YES;
	}
	return DeviceToENUSpaceTransform;
}

- (CATransform3D)ENUToEFSpaceTransform {
	if (!flags.haveENUToEFSpaceTransform) {
		if ([self isLocationAvailable] && [self isOrientationAvailable]) {
			// The ENU coordinate space is defined in ECEF coordinate space by looking:
			// * from the device, which is given by the GPS after conversion to ECEF;
			// * towards the sky, which is the same vector as the ECEF position since the ECEF origin is defined to be at the Earth's center; and
			// * oriented towards the North pole, which is defined to be the z-axis of the ECEF coordinate system.
			ENUToEFSpaceTransform = ARTransform3DLookAtRelative([self locationInEFSpace], [self upDirectionInEFSpace], [self northDirectionInEFSpace], ARPoint3DZero);
		}
		else {
			ENUToEFSpaceTransform = CATransform3DIdentity;
		}
		flags.haveENUToEFSpaceTransform = YES;
	}
	return ENUToEFSpaceTransform;
}

- (CATransform3D)EFToENUSpaceTransform {
	if (!flags.haveEFToENUSpaceTransform) {
		// Note: due to translation this is not an orthogonal matrix, so we really need to invert
		EFToENUSpaceTransform = CATransform3DInvert([self ENUToEFSpaceTransform]);
		flags.haveEFToENUSpaceTransform = YES;
	}
	return EFToENUSpaceTransform;
}

@synthesize EFToECEFSpaceOffset;

@end
