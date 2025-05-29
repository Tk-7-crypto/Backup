/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_Certifications
 */
@isTest
private class TST_CNT_PEP_Certifications {
	
	@testSetup
    public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;

        system.runAs(adminUser){
        	List<Certification__c> lstCertif = new List<Certification__c>();        
        	Product2 prod = TST_PEP_TestDataFactory.createProduct('Product2');
        	insert prod;
            //have to set salesforce user id on record as admin for testing class only 
            //if we set as partner, asserts will fail because partner cannot see this data until sharing set is available in org
            //data model and code is part of same deployment, so cannot create sharing set as pre-dep
        	for(Integer i=1 ; i<=7;i++){
        		lstCertif.add(TST_PEP_TestDataFactory.createCertification('Certif-00000'+i,'Certification'+i,
            		system.today().addMonths(-3), 'pathname', 'http://www.url.com'+i, prod, adminUser, 'v'+i));
        	}

        	insert lstCertif;
        }
     }

     @isTest
     public static void testFoundCertifications(){         
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Certification__c> lstCertif = new List<Certification__c>();

        System.runAs(adminUser){
	        Test.startTest();	         	
	         	 lstCertif = CNT_PEP_Certifications.getCert();
	        Test.stopTest();
	     }       
        System.assertEquals(7,lstCertif.size());       
    }

	@isTest
    public static void testNoCertif(){
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        List<Certification__c> lstCertif = new List<Certification__c>();
        System.runAs(partnerUser){
	        Test.startTest();	         	
	         	 lstCertif = CNT_PEP_Certifications.getCert();
	        Test.stopTest();
	    }       
        System.assertEquals(0,lstCertif.size());
    }
}