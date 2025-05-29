/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_LearningProgress
 */
@isTest
private class TST_CNT_PEP_LearningProgress {

	@testSetup
    public static void setup(){
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;

        system.runAs(adminUser){
        	List<Learning_Path__c> lstLearn = new List<Learning_Path__c>();        
        	Product2 prod = TST_PEP_TestDataFactory.createProduct('OCE Sales');
        	insert prod;
            //have to set salesforce user id on record as admin for testing class only 
            //if we set as partner, asserts will fail because partner cannot see this data until sharing set is available in org
            //data model and code is part of same deployment, so cannot create sharing set as pre-dep
        	for(Integer i=1 ; i<=7;i++){
        		lstLearn.add(TST_PEP_TestDataFactory.createLearningPath('Path-00000'+i,'Path'+i,
            		'http://www.pathurl.com'+i, prod,(i*10), adminUser));
        	}
        	insert lstLearn;
        }
     }

     @isTest
     public static void testFoundLearningPath(){                 
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Learning_Path__c> lstLearn = new List<Learning_Path__c>();

        System.runAs(adminUser){
	        Test.startTest();	         	
	         	 lstLearn = CNT_PEP_LearningProgress.getLearn();
	        Test.stopTest();
	     }       
        System.assertEquals(7,lstLearn.size());              
    }

	@isTest
    public static void testNoLearningPath(){
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        List<Learning_Path__c> lstLearn = new List<Learning_Path__c>();
        System.runAs(partnerUser){
	        Test.startTest();	         	
	         	 lstLearn = CNT_PEP_LearningProgress.getLearn();
	        Test.stopTest();
	    }       
        System.assertEquals(0,lstLearn.size());
    }
}