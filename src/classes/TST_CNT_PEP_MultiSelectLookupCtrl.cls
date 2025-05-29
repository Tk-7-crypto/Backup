/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_MultiSelectLookupCtrl
 */ 
@isTest
public class TST_CNT_PEP_MultiSelectLookupCtrl {
    @testSetup
    public static void setup(){       
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
            insert lstUsers;
        
        List<Account> lstExObject = new List<Account>();
        for(Integer i=0; i<5; i++) {
            lstExObject.add(TST_PEP_TestDataFactory.createAccount('Account ' + i));
        }        
        insert lstExObject;
    }
    
    @isTest
    public static void testfetchLookUpValues() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<SObject> returnList = new List<SObject>();
        System.runAs(adminUser){
            Test.startTest();               
            	returnList = CNT_PEP_MultiSelectLookupCtrl.fetchLookUpValues('Account 4','Account',new List<Account>());
            Test.stopTest();
        }
        System.assertEquals(1, returnList.size());
    }
    
    @isTest
    public static void testfetchLookUpValuesExclude() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Account> lstExObject = [Select id from Account where name = 'Account 1'];
        List<SObject> returnList = new List<SObject>();
        System.runAs(adminUser){
            Test.startTest();               
            	returnList = CNT_PEP_MultiSelectLookupCtrl.fetchLookUpValues('Account ','Account',lstExObject);
            	system.debug('returnList = '+ returnList);
            Test.stopTest();
        }
        //System.assertEquals(3,returnList.size());
    }
    
}