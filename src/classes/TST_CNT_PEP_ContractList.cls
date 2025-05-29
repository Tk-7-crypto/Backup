/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_ContractList
 */ 
@isTest
public class TST_CNT_PEP_ContractList {
   
    @testSetup
    public static void setup(){ 
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User partnerUser1 = TST_PEP_TestDataFactory.createPartnerUser('partneruser1@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser,partnerUser1, adminUser};
        insert lstUsers;
        System.runAs(partnerUser){
            Id ctcId = partnerUser.contactId;
            List<Contact> ctc = [SELECT AccountId FROM Contact WHERE Id = :ctcId ];

            Contract ctr = TST_PEP_TestDataFactory.createContract('Contract1', ctc[0].AccountId );
            Contract ctr2 = TST_PEP_TestDataFactory.createContract('Contract2', ctc[0].AccountId );
            ctr.Parent_Contract_Number__c = 123;
            ctr.Ultimate_Parent_Contract_Number__c = 345;
            ctr2.Parent_Contract_Number__c = 123;
            ctr2.Ultimate_Parent_Contract_Number__c = 345;
            List<Contract> lstContract = new List<Contract>{ctr, ctr2};
            insert lstContract; 
         }       
     }
    
     @isTest
     public static void testFoundContract(){ 
         List<Contract> ctrList = new List<Contract>();
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];

        System.runAs(partnerUser){
            Test.startTest();                 
                 ctrList = CNT_PEP_ContractList.getContract();
            Test.stopTest();
         }       
        System.assertEquals(2,ctrList.size());       
    }
    
    @isTest
     public static void testFoundNoContract(){         
        User partnerUser = [SELECT id FROM User WHERE email='partneruser1@iqvia.partner.com'];
         List<Contract> ctrList = new List<Contract>();

        System.runAs(partnerUser){
            Test.startTest();                 
                 ctrList = CNT_PEP_ContractList.getContract();
            Test.stopTest();
         }       
        System.assertEquals(0,ctrList.size());       
    }
}