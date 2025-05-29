/**
* This test class is used to test all methods in FRUP trigger helper.
* version : 1.0
*/
@isTest
public class TST_DAOH_box_FRUP {
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Box_End_Point__c boxEndPoint = new Box_End_Point__c(End_Point_for_Folders__c = 'https://api.box.com/2.0', End_Point__c = 'https://app.box.com');
        insert boxEndPoint;
    }
    
    @isTest
    static void testGenerateBoxFolderURLonOpp(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = 'Q2 Solutions';
        insert opp;
        String body = 'body';
        box__FRUP__c boxFrup = new box__FRUP__c(box__Object_Name__c = 'Opportunity', box__Record_ID__c = opp.Id, box__Folder_ID__c = '12345678');
        Box_End_Point__c boxEndPoint = [SELECT End_Point__c FROM Box_End_Point__c WHERE End_Point__c = 'https://app.box.com'];
        Survey_Setting__c testsetting = new Survey_Setting__c();
        testsetting.Intake_Survey_Delay_Duration__c = 30;
        testsetting.Survey_Error_Email_Ids__c = 'abc@gmail.com';
        insert testsetting; 
        Test.startTest();
        	insert boxFrup;
        	DAOH_box_FRUP.sendEmailOnException(body);
        Test.stopTest();
        opp = [SELECT Id,Box_Folder_Url__c FROM Opportunity WHERE Id = :opp.Id];
        String expectedFolderURL = 'https://app.box.com/folder/12345678';
        String actualFolderURL = opp.Box_Folder_Url__c;
        System.debug(actualFolderURL);
        System.assertEquals(expectedFolderURL, actualFolderURL); 
    }
}