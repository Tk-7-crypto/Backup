/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_ScheduledCourses
 */
@isTest
private class TST_CNT_PEP_ScheduledCourses {

	@testSetup
    public static void setup(){
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;

        system.runAs(adminUser){
        	List<Classroom_Course__c> lstCourses = new List<Classroom_Course__c>();        
        	Product2 prod = TST_PEP_TestDataFactory.createProduct('OCE Marketing');
        	insert prod;
            
            Learning_Path__c learninpth = TST_PEP_TestDataFactory.createLearningPath('Path-00000','Path',
            		'http://www.pathurl.com', prod,80, partnerUser);
        	insert learninpth;
            //have to set salesforce user id on record as admin for testing class only 
            //if we set as partner, asserts will fail because partner cannot see this data until sharing set is available in org
            //data model and code is part of same deployment, so cannot create sharing set as pre-dep
        	for(Integer i=1 ; i<=7;i++){
        		lstCourses.add(TST_PEP_TestDataFactory.createClassroomCourse('Class-2000'+i,'Class2'+i,
        			'2 days','ENROLLED', learninpth, 'http://www.url.com'+i, 'city1', prod,adminUser,
                    system.today().addMonths(2), system.today().addMonths(4)));

        		lstCourses.add(TST_PEP_TestDataFactory.createClassroomCourse('Class-1000'+i,'Class1'+i,
        			'1 day','ENROLLED', learninpth, 'http://www.url.com'+i, 'city2', prod,adminUser,
                    system.today().addMonths(-2), system.today()));
        	}

        	insert lstCourses;
        }
     }

     @isTest
     public static void testFoundCourses(){
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Classroom_Course__c> lstCourses = new List<Classroom_Course__c>();

        System.runAs(adminUser){
	        Test.startTest();	         	
	         	 lstCourses = CNT_PEP_ScheduledCourses.getCourse();
	        Test.stopTest();
	     }       
        System.assertEquals(7,lstCourses.size());       
    }

	@isTest
    public static void testNoCourse(){
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        List<Classroom_Course__c> lstCourses = new List<Classroom_Course__c>();
        System.runAs(partnerUser){
	        Test.startTest();	         	
	         	 lstCourses = CNT_PEP_ScheduledCourses.getCourse();
	        Test.stopTest();
	    }       
        System.assertEquals(0,lstCourses.size());
    }

}