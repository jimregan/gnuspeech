#import <Foundation/NSObject.h>

@class MonetList;
@class MMPoint, MMSlope;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMSlopeRatio : NSObject
{
    MonetList *points; // Of MMPoints
    MonetList *slopes; // Of MMSlopes
}

- (id)init;
- (void)dealloc;

- (MonetList *)points;
- (void)setPoints:(MonetList *)newList;
- (void)addPoint:(MMPoint *)newPoint;

- (MonetList *)slopes;
- (void)setSlopes:(MonetList *)newList;
- (void)addSlope:(MMSlope *)newSlope;
- (void)updateSlopes;

- (double)startTime;
- (double)endTime;

- (void)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
              toDisplay:(MonetList *)displayList;

- (double)calculatePoints:(double *)ruleSymbols tempos:(double *)tempos phones:phones andCacheWith:(int)newCacheTag
                 baseline:(double)baseline delta:(double)parameterDelta min:(double)min max:(double)max
              toEventList:eventList atIndex:(int)index;

- (double)totalSlopeUnits;
- (void)displaySlopesInList:(NSMutableArray *)displaySlopes;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
