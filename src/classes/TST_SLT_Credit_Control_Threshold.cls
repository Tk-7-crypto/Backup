/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Credit_Control_Threshold
 */
@isTest
public class TST_SLT_Credit_Control_Threshold {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Credit Control Groups,Super Credit Control Admins');
        Group grp = [Select id From Group where developername = 'Super_Credit_Control_Admins' limit 1];
        Id userId = UserInfo.getUserId();
        User testUser = new User(id = userId);
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;
            List<Credit_Control_Threshold__c> creditControlThresholdList = new List<Credit_Control_Threshold__c>();
            Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Account__c=account.Id, Threshold_value_USD__c=5000000.00, Description__c='test');
        	creditControlThresholdList.add(cct);
            Credit_Control_Threshold__c cct2 = new Credit_Control_Threshold__c(Threshold_value_USD__c=5000000.00, Description__c='global');
        	creditControlThresholdList.add(cct2);            
            insert creditControlThresholdList;
        }
    }
    
    /**
    * This method used to get Credit Control Threshold by AccountID
    */    
    @IsTest
    static void testGetCreditControlThresholdByAccountId() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Set<Id> accIdSet = new Set<Id>{acc.Id};
        Set<String> accCountrySet = new Set<String>{'US'};
        List<Credit_Control_Threshold__c> cctList = new  List<Credit_Control_Threshold__c>();
        Credit_Control_Threshold__c cct = [SELECT Id FROM Credit_Control_Threshold__c WHERE Account__c =: acc.Id];        
        Test.startTest();
        ccTList = new SLT_Credit_Control_Threshold().getCreditControlThresholdByAccountId(accIdSet, accCountrySet);
        Test.stopTest();
    }
    
    /**
    * This method used to get Global Credit Control Threshold
    */    
    @IsTest
    static void testGetGlobalCreditControlThreshold() {        
        List<Credit_Control_Threshold__c> cctList = new  List<Credit_Control_Threshold__c>();
    	Credit_Control_Threshold__c cct = [SELECT Id FROM Credit_Control_Threshold__c WHERE Account__c = null And Country__c = null];
        Set<String> cctFieldSet = new Set<String> {'Id','Account__c','Country__c','Threshold_value_USD__c'};
        
        Test.startTest();
        	ccTList = new SLT_Credit_Control_Threshold().getGlobalCreditControlThreshold(cctFieldSet);
        Test.stopTest();
    }
    /**
    * This method used to get All Credit_Control_Threshold
    */    
    @IsTest
    static void testGetAllCreditControlThreshold() {        
        List<Credit_Control_Threshold__c> cctList = new  List<Credit_Control_Threshold__c>();
        Set<String> cctFieldSet = new Set<String> {'Id','Account__c','Country__c','Threshold_value_USD__c'};
        
        Test.startTest();
        	ccTList = new SLT_Credit_Control_Threshold().getAllCreditControlThreshold(cctFieldSet);
        Test.stopTest();
    }

}