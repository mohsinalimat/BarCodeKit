//
//  BCKCodabarCode.m
//  BarCodeKit
//
//  Created by Geoff Breemer on 14/09/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "BCKCodabarCode.h"
#import "BCKCodabarCodeCharacter.h"
#import "BCKCodabarContentCodeCharacter.h"
#import "NSError+BCKCode.h"

@implementation BCKCodabarCode

#pragma mark - Subclass Methods

+ (NSString *)barcodeStandard
{
	return @"Not an international standard";
}

+ (NSString *)barcodeDescription
{
	return @"Codabar";
}

+ (BOOL)canEncodeContent:(NSString *)content error:(NSError **)error
{
	BCKCodabarCodeCharacter *codeCharacter;
	NSString *message;
	
	if ([content length] < 3)
	{
		if (error)
		{
			message = [NSString stringWithFormat:@"%@ requires at least three characters", NSStringFromClass([self class])];
			
			if (error)
			{
				*error = [NSError BCKCodeErrorWithMessage:message];
			}
			
			return NO;
		}
	}
	
	for (NSUInteger index=0; index<[content length]; index++)
	{
		NSString *character = [content substringWithRange:NSMakeRange(index, 1)];
		
		// If it is the first or last character create a start/stop characters. For all others create a content code character
		if ((index==0) || (index==[content length]-1))
		{
			codeCharacter = [BCKCodabarCodeCharacter startStopCodeCharacter:character];
		}
		else
		{
			codeCharacter = [[BCKCodabarContentCodeCharacter alloc] initWithCharacter:character];
		}
		
		if (!codeCharacter)
		{
			if (error)
			{
				if (index==0)
				{
					message = [NSString stringWithFormat:@"Character at index %d '%@' is an invalid start character for %@", index, character, NSStringFromClass([self class])];
				}
				else if (index==[content length]-1)
				{
					message = [NSString stringWithFormat:@"Character at index %d '%@' is an invalid stop character for %@", index, character, NSStringFromClass([self class])];
				}
				else {
					message = [NSString stringWithFormat:@"Character at index %d '%@' cannot be encoded in %@", index, character, NSStringFromClass([self class])];
				}
				
				*error = [NSError BCKCodeErrorWithMessage:message];
			}
			
			return NO;
		}
	}
	
	return YES;
}

- (NSArray *)codeCharacters
{
	// If the array was created earlier just return it
	if (_codeCharacters)
	{
		return _codeCharacters;
	}
	
	// Array that holds all code characters, including start/stop, spacing, modulo-11 check digits
	NSMutableArray *finalArray = [NSMutableArray array];
	
	// Encode the barcode's content and add it to the array
	for (NSUInteger index=0; index<[_content length]; index++)
	{
		NSString *character = [_content substringWithRange:NSMakeRange(index, 1)];
		
		// Start character
		if (index==0)
		{
			[finalArray addObject:[BCKCodabarCodeCharacter startStopCodeCharacter:character]];
			[finalArray addObject:[BCKCodabarCodeCharacter spacingCodeCharacter]];
		}
		// Stop character
		else if (index == [_content length]-1)
		{
			[finalArray addObject:[BCKCodabarCodeCharacter startStopCodeCharacter:character]];
		}
		// All other characters
		else
		{
			[finalArray addObject:[BCKCodabarCodeCharacter codeCharacterForCharacter:character]];
			[finalArray addObject:[BCKCodabarCodeCharacter spacingCodeCharacter]];
		}
	}
	
	_codeCharacters = [finalArray copy];
	
	return _codeCharacters;
}

- (NSUInteger)horizontalQuietZoneWidth
{
	return 17;
}

- (CGFloat)aspectRatio
{
	return 0;
}

- (CGFloat)fixedHeight
{
	return 34;
}

- (CGFloat)_captionFontSizeWithOptions:(NSDictionary *)options
{
	return 10;
}

- (NSString *)captionTextForZone:(BCKCodeDrawingCaption)captionZone
{
	if (captionZone == BCKCodeDrawingCaptionTextZone)
	{
		return _content;
	}
	
	return nil;
}

- (UIFont *)_captionFontWithSize:(CGFloat)fontSize
{
	UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
	
	return font;
}

@end
