//
//  pointAnnotation.m
//  Panoramio
//
//  Created by lily on 1/11/13.
//
//

#import "pointAnnotation.h"

@implementation pointAnnotation
@synthesize coordinatePoint;
@synthesize photoId;

- (pointAnnotation*) annotationForPhotowithCoordinate:(CLLocationCoordinate2D)coordinate
{
    pointAnnotation *annotation = [[pointAnnotation alloc] init];
    annotation.coordinatePoint = coordinate;
    annotation.photoId = photoId;
    return annotation;
}

-(CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate = self.coordinatePoint;
    return coordinate;
}

@end