//
//  ARArrayFilterTest.m
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


#import "ARArrayFilterTest.h"
#import "ARArrayFilter.h"
#import "ARDelayFilter.h"



@implementation ARArrayFilterTest

#pragma mark GHTestCase

- (void)testFilter {
	const int inputCount = 20;
	
	const double inputs[][3] = {
		{-0.157861295276236,   0.047184089422321,  -0.323830412297436},
		{-0.886373638052735,  -0.402369179785956,   0.718960214413579},
		{ 0.171493990468456,   0.407938157302389,  -0.319043378469135},
		{-0.651689511131937,  -0.236778248022235,  -0.723759193899827},
		{ 0.457221321132620,   0.135369995602973,   0.015597910705206},
		{ 0.068582099882058,   0.775721910622455,   0.713312953783380},
		{-0.493871424497175,   0.685898577990577,  -0.231372764234773},
		{ 0.834113496571170,   0.797597111664380,   0.391381853657539},
		{ 0.516389059430832,   0.878006182893110,   0.255808355581097},
		{ 0.774061464456026,   0.630870311877495,  -0.099223691296149},
		{-0.862403657792567,  -0.997284342427938,  -0.052764115802231},
		{-0.632943608944320,  -0.993818604885070,   0.899412707007065},
		{ 0.474145309173178,  -0.825062367362497,  -0.833004876421338},
		{ 0.393429705299443,  -0.478545297591361,  -0.440342159999575},
		{ 0.553985811412057,  -0.954402658718133,  -0.105985381330591},
		{ 0.003806838307487,  -0.151830362388241,   0.175142527990627},
		{-0.149006343994747,  -0.317870062181542,   0.755268276829044},
		{ 0.222474261548603,   0.082707866615409,  -0.061798959541962},
		{ 0.711543782723473,   0.852338165166146,  -0.125163048596559},
		{ 0.341594217960446,  -0.403001105881521,   0.492369879949691},
	};
	
	const double correctOutputs[][3] = {
		{-0.157861295276236,   0.047184089422321,  -0.323830412297436},
		{-0.157861295276236,   0.047184089422321,  -0.323830412297436},
		{-0.886373638052735,  -0.402369179785956,   0.718960214413579},
		{ 0.171493990468456,   0.407938157302389,  -0.319043378469135},
		{-0.651689511131937,  -0.236778248022235,  -0.723759193899827},
		{ 0.457221321132620,   0.135369995602973,   0.015597910705206},
		{ 0.068582099882058,   0.775721910622455,   0.713312953783380},
		{-0.493871424497175,   0.685898577990577,  -0.231372764234773},
		{ 0.834113496571170,   0.797597111664380,   0.391381853657539},
		{ 0.516389059430832,   0.878006182893110,   0.255808355581097},
		{ 0.774061464456026,   0.630870311877495,  -0.099223691296149},
		{-0.862403657792567,  -0.997284342427938,  -0.052764115802231},
		{-0.632943608944320,  -0.993818604885070,   0.899412707007065},
		{ 0.474145309173178,  -0.825062367362497,  -0.833004876421338},
		{ 0.393429705299443,  -0.478545297591361,  -0.440342159999575},
		{ 0.553985811412057,  -0.954402658718133,  -0.105985381330591},
		{ 0.003806838307487,  -0.151830362388241,   0.175142527990627},
		{-0.149006343994747,  -0.317870062181542,   0.755268276829044},
		{ 0.222474261548603,   0.082707866615409,  -0.061798959541962},
		{ 0.711543782723473,   0.852338165166146,  -0.125163048596559},
		{ 0.341594217960446,  -0.403001105881521,   0.492369879949691},
	};
	
	ARArrayFilter *filter = [[ARArrayFilter alloc] initWithSize:3 factory:[[[ARDelayFilterFactory alloc] initWithDelay:1] autorelease]];
	for (int i = 0; i < inputCount; ++i) {
		const double *input = inputs[i];
		const double *correctOutput = correctOutputs[i];
		const NSTimeInterval timestamp = 0;
		
		double output[3];
		[filter filterWithInputArray:input outputArray:output timestamp:timestamp];
		
		GHAssertEqualsWithAccuracy(correctOutput[0], output[0], 1e-6, nil);
		GHAssertEqualsWithAccuracy(correctOutput[1], output[1], 1e-6, nil);
		GHAssertEqualsWithAccuracy(correctOutput[2], output[2], 1e-6, nil);
	}
	
	[filter release];
}

@end
