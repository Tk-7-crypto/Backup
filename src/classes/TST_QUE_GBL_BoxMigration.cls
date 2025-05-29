@isTest
public class TST_QUE_GBL_BoxMigration {
    
    @testSetup
    static void dataSetup() {
        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        pse__Grp__c grp = new pse__Grp__c( Name = 'TestGroup', CurrencyIsoCode = 'USD' );
        insert grp;
        Contact cont = UTL_TestData.createContact(acc.Id);
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
        Bid_History__c bidHistory = new Bid_History__c();
        bidHistory.Bid_History_Related_Opportunity__c = opp.Id;
        bidHistory.RecordTypeId = CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID;
        bidHistory.Is_PPT_Format_Required__c = 'No';
        insert bidHistory;
        
        box__FRUP__c frupRecord = new box__FRUP__c(); 
        frupRecord.box__Object_Name__c = 'Bid_History__c';
        frupRecord.box__Record_ID__c = bidHistory.Id;  
        frupRecord.box__Folder_ID__c = '128739764476';
        insert frupRecord;
    }
    
    @isTest
    private static void testBoxMigrationQueueable() {
        List<box__FRUP__c> lstFRUP = [SELECT box__Record_ID__c, box__Folder_ID__c FROM box__FRUP__c LIMIT 1]; 
    
        Test.startTest();
            ID jobID = System.enqueueJob(new QUE_GBL_BoxMigration(lstFRUP));
        Test.stopTest();
        
        System.assertNotEquals(null, jobID, 'The id of queueable job should not be null');
    }

}