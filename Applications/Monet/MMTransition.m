#import "MMTransition.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MonetList.h"
#import "MMPoint.h"
#import "MMSlopeRatio.h"
#import "NamedList.h"

#import "MModel.h"
#import "MUnarchiver.h"

@implementation MMTransition

- (id)init;
{
    MMPoint *aPoint;

    if ([super init] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = DIPHONE;
    points = [[MonetList alloc] init];

    aPoint = [[MMPoint alloc] init];
    [aPoint setType:DIPHONE];
    [aPoint setFreeTime:0.0];
    [aPoint setValue:0.0];
    [points addObject:aPoint];
    [aPoint release];

    return self;
}

- (id)initWithName:(NSString *)newName;
{
    if ([self init] == nil)
        return nil;

    [self setName:newName];

    return self;
}

- (void)dealloc;
{
    [name release];
    [comment release];
    [points release];

    [super dealloc];
}

- (NamedList *)group;
{
    return nonretained_group;
}

- (void)setGroup:(NamedList *)newGroup;
{
    nonretained_group = newGroup;
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
}

- (NSString *)comment;
{
    return comment;
}

- (void)setComment:(NSString *)newComment;
{
    if (newComment == comment)
        return;

    [comment release];
    comment = [newComment retain];
}

- (BOOL)hasComment;
{
    return comment != nil && [comment length] > 0;
}

- (MonetList *)points;
{
    return points;
}

- (void)setPoints:(MonetList *)newList;
{
    if (newList == points)
        return;

    [points release];
    points = [newList retain];
}

//pointTime = [aPoint getTime];
- (BOOL)isTimeInSlopeRatio:(double)aTime;
{
    unsigned pointCount, pointIndex;
    id currentPointOrSlopeRatio;

    pointCount = [points count];
    for (pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        currentPointOrSlopeRatio = [points objectAtIndex:pointIndex];

        if ([currentPointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            if (aTime < [currentPointOrSlopeRatio startTime])
                return NO;
            else if (aTime < [currentPointOrSlopeRatio endTime]) /* Insert point into Slope Ratio */
                return YES;
        } else if (aTime < [currentPointOrSlopeRatio getTime]) {
            return NO;
        }
    }

    return NO;
}

- (void)insertPoint:(MMPoint *)aPoint;
{
    int i, j;
    id temp, temp1, temp2;
    double pointTime = [aPoint getTime];

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex:i];
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            if (pointTime < [temp startTime]) {
                [points insertObject:aPoint atIndex:i];
                return;
            } else if (pointTime < [temp endTime]) { /* Insert point into Slope Ratio */
                temp1 = [temp points];
                for (j = 1; j < [temp1 count]; j++) {
                    temp2 = [temp1 objectAtIndex:j];
                    if (pointTime < [temp2 getTime]) {
                        [temp1 insertObject:aPoint atIndex:j];
                        [temp updateSlopes];
                        return;
                    }
                }

                /* Should never get here */
                return;
            }
        } else {
            if (pointTime < [temp getTime]) {
                [points insertObject:aPoint atIndex:i];
                return;
            }
        }
    }

    [points addObject:aPoint];
}

- (int)type;
{
    return type;
}

- (void)setType:(int)newType;
{
    type = newType;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    int i, j;
    id temp;

    for (i = 0; i < [points count]; i++) {
        temp = [points objectAtIndex: i];
        if ([temp isKindOfClass:[MMSlopeRatio class]]) {
            temp = [temp points];
            for (j = 0; j < [temp count]; j++)
                if (anEquation == [[temp objectAtIndex:j] expression])
                    return YES;
        } else
            if (anEquation == [[points objectAtIndex:i] expression])
                return YES;
    }

    return NO;
}

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
{
    unsigned count, index;
    int j;
    id pointOrSlopeRatio;

    count = [points count];
    for (index = 0; index < count; index++) {
        pointOrSlopeRatio = [points objectAtIndex:index];
        if ([pointOrSlopeRatio isKindOfClass:[MMSlopeRatio class]]) {
            MonetList *slopePoints;

            slopePoints = [pointOrSlopeRatio points];
            for (j = 0; j < [slopePoints count]; j++)
                if (anEquation == [[slopePoints objectAtIndex:j] expression]) {
                    [aList addObject:self];
                    return;
                }
        } else {
            if (anEquation == [[points objectAtIndex:index] expression]) {
                [aList addObject:self];
                return;
            }
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;
    MonetList *archivedPoints;
    MModel *model;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    name = nil;
    comment = nil;
    type = 2;
    points = [[MonetList alloc] init];

    model = [(MUnarchiver *)aDecoder userInfo];

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**i", &c_name, &c_comment, &type];
    //NSLog(@"c_name: %s, c_comment: %s, type: %d", c_name, c_comment, type);
    [self setName:[NSString stringWithASCIICString:c_name]];
    [self setComment:[NSString stringWithASCIICString:c_comment]];

    archivedPoints = [aDecoder decodeObject];
    //NSLog(@"archivedPoints: %@", archivedPoints);

    //NSLog(@"Points = %d", [points count]);

    if (archivedPoints == nil) {
        MonetList *defaultPoints;
        MMPoint *aPoint;

        NSLog(@"Archived points were nil, using defaults.");
        defaultPoints = [[MonetList alloc] initWithCapacity:3];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:0.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"Zero"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:12.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"diphoneOneThree"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:87.5];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Test" named:@"diphoneTwoThree"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        aPoint = [[MMPoint alloc] init];
        [aPoint setValue:100.0];
        [aPoint setType:DIPHONE];
        [aPoint setExpression:[model findEquationList:@"Defaults" named:@"Mark1"]];
        [defaultPoints addObject:aPoint];
        [aPoint release];

        if (type != DIPHONE) {
            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:12.5];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Test" named:@"triphoneOneThree"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:87.5];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Test" named:@"triphoneTwoThree"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            aPoint = [[MMPoint alloc] init];
            [aPoint setValue:100.0];
            [aPoint setType:TRIPHONE];
            [aPoint setExpression:[model findEquationList:@"Defaults" named:@"Mark2"]];
            [defaultPoints addObject:aPoint];
            [aPoint release];

            if (type != TRIPHONE) {
                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:12.5];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Test" named:@"tetraphoneOneThree"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:87.5];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Test" named:@"tetraphoneTwoThree"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];

                aPoint = [[MMPoint alloc] init];
                [aPoint setValue:100.0];
                [aPoint setType:TETRAPHONE];
                [aPoint setExpression:[model findEquationList:@"Durations" named:@"TetraphoneDefault"]];
                [defaultPoints addObject:aPoint];
                [aPoint release];
            }
        }

        [self setPoints:defaultPoints];
        [defaultPoints release];
    } else
        [self setPoints:archivedPoints];

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);

    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, type: %d, points: %@",
                     NSStringFromClass([self class]), self, name, comment, type, points];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<transition name=\"%@\" type=\"%d\">\n",
                  GSXMLAttributeString(name, NO), type];

    if (comment != nil) {
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];
    }

    [points appendXMLToString:resultString elementName:@"point-or-slopes" level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</transition>\n"];
}

- (NSString *)transitionPath;
{
    return [NSString stringWithFormat:@"%@:%@", [[self group] name], name];
}

@end
