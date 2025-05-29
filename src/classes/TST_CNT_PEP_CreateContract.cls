/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_CreateContract
 */
@isTest
public class TST_CNT_PEP_CreateContract {

	@testSetup
    public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;
        
       System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('Test');
            insert prod;
        	Agency_Program__c ap = TST_PEP_TestDataFactory.createAgencyProgram(prod);
            insert ap;
           
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            Agency_Program_Financials__c apf=new Agency_Program_Financials__c();
            apf.RecordTypeId=agencyProgramFinancialsPrice;
            apf.Program_Name__c=ap.Id;
            apf.Country__c='US';
            apf.CurrencyIsoCode='USD';
            apf.Default__c=true;
            apf.Product__c=prod.Id;
            apf.Price__c=100;
            insert apf; 
	   }   
     }
    
     @isTest
     public static void testFoundActiveAgencyProg(){         
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        List<Agency_Program__c> agencyProgramList = new List<Agency_Program__c>();

        System.runAs(partnerUser){
	        Test.startTest();	         	
	         	 agencyProgramList = CNT_PEP_CreateContract.getActiveAgencyProg();
	        Test.stopTest();
	     }
    }
    
    @isTest
     public static void testCreateCaseForPartner(){         
        User partnerUser = [SELECT id,AccountId,ContactId FROM User WHERE email='partneruser@iqvia.partner.com'];
		Asset asset = [SELECT id,AccountId FROM Asset WHERE Name = 'Asset 1' LIMIT 1];
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='PRMQ1';
        queues1.Tier__c ='Tier 1';
        queues1.QueueName__c ='PRMQ1';
        queues1.Out_Of_Office_Notification__c = true;
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='PRMQ1';
        queues1.Out_Of_Office_Notification__c = true;
        queueUser1.Tier__c ='Tier 1';
        queueUser1.QueueName__c ='PRMQ1';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        System.runAs(partnerUser){
	        Test.startTest();	         	
	    Case cs2 = new Case();
        cs2.Force_CSAT_Email_Survey__c = true;
        cs2.ContactId = partnerUser.ContactId;
        cs2.AccountId = partnerUser.AccountId;
        cs2.AssignCaseToCurrentUser__c = false;
        cs2.OwnerId = UserInfo.getUserId();
        cs2.RecordTypeId = recordTypeIdTechno;
        cs2.Priority = 'Priority 3';
        cs2.Origin = 'Partner Portal';
        cs2.Mail_CC_List__c = 'nodata@info.com';
        cs2.Subject = 'Techno case';
        cs2.Description = 'Test class to check case creation';
        cs2.Status = 'New';
        cs2.CaseSource__c = 'Customer';
        cs2.AssetId = asset.Id;
        cs2.ProductName__c= 'OCE Sales';
        cs2.SubType1__c = 'Incident-Module';
        cs2.SubType2__c = 'Formularies';  
        cs2.SubType3__c = '--none--';
        cs2.CurrentQueue__c = queueUser1.Id;
        cs2.External_System_Type__c = CON_CSM.S_ROCHE_SN;
        cs2.SendAutomaticAcknowledgmentEmail__c = 'Yes';
        cs2.Set_Internal_Follow_Up_from_Priority__c = true;
        insert cs2;
	        Test.stopTest();
	     }
    }
    
     @isTest
     public static void testFoundNoActiveAgencyProg(){
		List<Agency_Program__c> lstAp = new List<Agency_Program__c>();         
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Agency_Program__c> agencyProgramList = [SELECT Id, Name, Status__c from Agency_Program__c where status__c = 'Active'];
        System.runAs(adminuser){
            for(Agency_Program__c ap : agencyProgramList){
                ap.Status__c = 'Inactive';
            }
            
            update(agencyProgramList);
	     } 
         
        System.runAs(partnerUser){
	        Test.startTest();	         	
	         	 lstAp = CNT_PEP_CreateContract.getActiveAgencyProg();
	        Test.stopTest();
	     }       
        System.assertEquals(0,lstAp.size());       
    }

    @isTest
    public static void testcreateContractController(){
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Agency_Program__c ap = [SELECT id FROM Agency_Program__c WHERE Name='Test'];
        String agencyId = ap.Id;
        
         System.runAs(partnerUser){
            Test.startTest();               
                String ctrId = CNT_PEP_CreateContract.createContractController(agencyId);
            Test.stopTest();

            system.assertNotEquals(null, ctrId);

         }
    }
}