@isTest
public class TST_CNT_OWF_MassUpdate {
    public static List<Opportunity> oppList = new List<Opportunity>();
    @testSetup
    static void setupTestData() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;   
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        oppList.add(opp);
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.id,opp.id,CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert bidHistory;
    }
    
    @isTest
    public static void testGetRecords(){
        Bid_History__c bid=[select id from Bid_History__c limit 1];
        List<String> idSet=new List<String>{bid.id};
        Test.startTest();
        list<SObject> SobjectList=CNT_OWF_MassUpdate.getRecords('Bid_History__c',idSet,new List<String>{'Id','Name'});
        Test.stopTest();
        system.assertEquals(1,SobjectList.size());             
    }
    
    @isTest
    public static void testUpdateRecords(){
        List<Bid_History__c> bid=[select id,Name from Bid_History__c];
        bid[0].Name='Test Bid History';
        Test.startTest();
        CNT_OWF_MassUpdate.updateRecords(bid);
        Test.stopTest();
        List<Bid_History__c> bidHistoryList=[select id,Name from Bid_History__c];
        system.assertEquals('Test Bid History',bidHistoryList[0].Name);     
    }
    
    @isTest
    public static void testGetrecordtypeId(){
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
        stdSetController.setSelected(oppList);
        CNT_OWF_MassUpdate cnt=new CNT_OWF_MassUpdate(stdSetController);
        Id resourceRequestRecId=CNT_OWF_MassUpdate.getrecordtypeId('pse__Resource_Request__c','OWF_Resource_Request');
        Id assignmentRecId=CNT_OWF_MassUpdate.getrecordtypeId('pse__Assignment__c','OWF_Assignment');
        Test.stopTest();
        system.assertEquals(resourceRequestRecId,Schema.SObjectType.pse__Resource_request__c.getRecordTypeInfosByDeveloperName().get('OWF_Resource_Request').getRecordTypeId());  
        system.assertEquals(assignmentRecId,Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByDeveloperName().get('OWF_Assignment').getRecordTypeId());  
    }
    
    @isTest
    public static void testPageReference(){
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
        stdSetController.setSelected(oppList);
        CNT_OWF_MassUpdate cnt=new CNT_OWF_MassUpdate(stdSetController);
        Id resourceRequestRecId=CNT_OWF_MassUpdate.getrecordtypeId('pse__Resource_Request__c','OWF_Resource_Request');
        Id assignmentRecId=CNT_OWF_MassUpdate.getrecordtypeId('pse__Assignment__c','OWF_Assignment');
        PageReference pg = cnt.navigationtoPreviouspage();
        Test.stopTest();
        system.assertEquals(resourceRequestRecId,Schema.SObjectType.pse__Resource_request__c.getRecordTypeInfosByDeveloperName().get('OWF_Resource_Request').getRecordTypeId());  
        system.assertEquals(assignmentRecId,Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByDeveloperName().get('OWF_Assignment').getRecordTypeId());  
    }
    
}
