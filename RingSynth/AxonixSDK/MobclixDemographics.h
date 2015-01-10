//
//  MobclixDemographics.h
//  Axonix iOS SDK
//
//  Copyright 2011 - 2014 Axonix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MCDemographicsEducation) {
	MCDemographicsEducationUnknown = 0,
	MCDemographicsEducationHighSchool,
	MCDemographicsEducationSomeCollege,
	MCDemographicsEducationInCollege,
	MCDemographicsEducationBachelorsDegree,
	MCDemographicsEducationMastersDegree,
	MCDemographicsEducationDoctoralDegree
};

typedef NS_ENUM(NSInteger, MCDemographicsEthnicity) {
	MCDemographicsEthnicityUnknown = 0,
	MCDemographicsEthnicityMixed,
	MCDemographicsEthnicityAsian,
	MCDemographicsEthnicityBlack,
	MCDemographicsEthnicityHispanic,
	MCDemographicsEthnicityNativeAmerican,
	MCDemographicsEthnicityWhite
};

typedef NS_ENUM(NSInteger, MCDemographicsReligion) {
	MCDemographicsReligionUnknown = 0,
	MCDemographicsReligionBuddhism,
	MCDemographicsReligionChristianity,
	MCDemographicsReligionHinduism,
	MCDemographicsReligionIslam,
	MCDemographicsReligionJudaism,
	MCDemographicsReligionUnaffiliated,
	MCDemographicsReligionOther
};

typedef NS_ENUM(NSInteger, MCDemographicsGender) {
	MCDemographicsGenderUnknown = 0,
	MCDemographicsGenderMale,
	MCDemographicsGenderFemale,
	MCDemographicsGenderBoth,
};

typedef NS_ENUM(NSInteger, MCDemographicsMaritalStatus) {
	MCDemographicsMaritalUnknown = 0,
	MCDemographicsMaritalSingleAvailable,
	MCDemographicsMaritalSingleUnavailable,
	MCDemographicsMaritalMarried,
};

typedef struct {
	MCDemographicsEducation education;
	MCDemographicsEthnicity ethnicity;
	MCDemographicsReligion religion;
	MCDemographicsGender gender; // MCDemographicsGenderBoth is not valid for this field.
	MCDemographicsGender datingGender; // MCDemographicsGenderBoth is valid for this field.
	MCDemographicsMaritalStatus maritalStatus;
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
} MCDemographics;

__deprecated_msg("Use AxonixDemographics instead. You'll need to import the AxonixDemographics.h header instead of MobclixDemographics.h")
@interface MobclixDemographics : NSObject {

}

+ (void)updateDemographics:(MCDemographics)demographics birthday:(NSDate*)birthday;

+ (MCDemographics)demographics;
+ (NSDate*)birthday;

@end
