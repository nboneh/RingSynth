//
//  AxonixDemographics.h
//  Axonix iOS SDK
//
//  Copyright 2011 - 2014 Axonix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AXNDemographicsEducation) {
	AXNDemographicsEducationUnknown = 0,
	AXNDemographicsEducationHighSchool,
	AXNDemographicsEducationSomeCollege,
	AXNDemographicsEducationInCollege,
	AXNDemographicsEducationBachelorsDegree,
	AXNDemographicsEducationMastersDegree,
	AXNDemographicsEducationDoctoralDegree
};

typedef NS_ENUM(NSInteger, AXNDemographicsEthnicity) {
	AXNDemographicsEthnicityUnknown = 0,
	AXNDemographicsEthnicityMixed,
	AXNDemographicsEthnicityAsian,
	AXNDemographicsEthnicityBlack,
	AXNDemographicsEthnicityHispanic,
	AXNDemographicsEthnicityNativeAmerican,
	AXNDemographicsEthnicityWhite
};

typedef NS_ENUM(NSInteger, AXNDemographicsReligion) {
	AXNDemographicsReligionUnknown = 0,
	AXNDemographicsReligionBuddhism,
	AXNDemographicsReligionChristianity,
	AXNDemographicsReligionHinduism,
	AXNDemographicsReligionIslam,
	AXNDemographicsReligionJudaism,
	AXNDemographicsReligionUnaffiliated,
	AXNDemographicsReligionOther
};

typedef NS_ENUM(NSInteger, AXNDemographicsGender) {
	AXNDemographicsGenderUnknown = 0,
	AXNDemographicsGenderMale,
	AXNDemographicsGenderFemale,
	AXNDemographicsGenderBoth,
};

typedef NS_ENUM(NSInteger, AXNDemographicsMaritalStatus) {
	AXNDemographicsMaritalUnknown = 0,
	AXNDemographicsMaritalSingleAvailable,
	AXNDemographicsMaritalSingleUnavailable,
	AXNDemographicsMaritalMarried,
};

typedef struct {
	AXNDemographicsEducation education;
	AXNDemographicsEthnicity ethnicity;
	AXNDemographicsReligion religion;
	AXNDemographicsGender gender; // MCDemographicsGenderBoth is not valid for this field.
	AXNDemographicsGender datingGender; // MCDemographicsGenderBoth is valid for this field.
	AXNDemographicsMaritalStatus maritalStatus;
	NSUInteger income;
	NSUInteger areaCode;
	NSInteger dmaCode;
	NSInteger metroCode;
	const char* city;
	const char* country;
	const char* postalCode;
	const char* regionCode;
	double latitude;
	double longitude;
} AXNDemographics;

@interface AxonixDemographics : NSObject {

}

+ (void)updateDemographics:(AXNDemographics)demographics birthday:(NSDate*)birthday;

+ (AXNDemographics)demographics;
+ (NSDate*)birthday;

@end


#import "MobclixDemographics.h"