//
//  ARDelayFilter.h
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


#import "ARFilter.h"
#import "ARCyclicBuffer.h"


/**
 * A filter to delay a sample for a given amount of samples.
 */
@interface ARDelayFilter : ARFilter {
@private
	ARCyclicBuffer *sampleBuffer;
}

/**
 * Initialize this filter.
 * @param delay the desired delay, in samples.
 * @return the initialized filter.
 */
- (id)initWithDelay:(NSUInteger)delay;

@end


/**
 * Factory class for ARDelayFilter.
 */
@interface ARDelayFilterFactory : ARFilterFactory {
@private
	NSUInteger delay;
}

/**
 * Initialize this filter factory.
 * @param delay the desired delay, in samples.
 * @return the initialized filter factory.
 */
- (id)initWithDelay:(NSUInteger)delay;

@end
