@isTest
public class TST_BCH_GBL_BoxMigration {
    
     @testSetup
    static void dataSetup() {
        Box_End_Point__c boxEndpoint = new Box_End_Point__c();
        boxEndPoint.End_point__c = 'https://app.box.com/';
        boxEndpoint.End_Point_for_Folders__c = 'https://api.box.com/2.0/';
        insert boxEndpoint;
        
        box__Folder_Details__c boxFolderDetails = new box__Folder_Details__c();
        boxFolderDetails.box__Folder_Name__c = 'BID_History';
        boxFolderDetails.box__FolderId__c = '104028912491';
        boxFolderDetails.Name = 'BID_History';
        insert boxFolderDetails; 
        
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
        
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        agreement.LQ_Bid_Histroy_Id__c = 'Test Id';
        
        //agreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
        insert agreement;
        
        Bid_History__c bidHistory = new Bid_History__c();
        bidHistory.Bid_History_Account__c = acc.Id;
        bidHistory.Bid_History_Related_Opportunity__c = opp.Id;
        bidHistory.LQ_Bid_Histroy_Id__c = 'Test Id';
        bidHistory.Requested_Services__c='Auditing and Compliance (Clinical)';
        bidHistory.RecordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
        bidHistory.Migrated_Agreement_Id__c = agreement.Id;
        insert bidHistory;
        
        box__FRUP__c frupRecord = new box__FRUP__c(); 
        frupRecord.box__Object_Name__c = 'Apttus__APTS_Agreement__c';
        frupRecord.box__Record_ID__c = agreement.Id;  
        frupRecord.box__Folder_ID__c = '128739764476';
        insert frupRecord;
        
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'OWF';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;
    }
    
    @isTest
    private static void testBoxMigrationBatch(){  
        String mockResponseBodyForCopy = '{"type":"folder","id":"128836283233","sequence_id":"0","etag":"0","name":"Test Folder","created_at":"2020-12-29T21:17:56-08:00",'
            +'"modified_at":"2020-12-29T21:17:56-08:00","description":"","size":4263142,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,'
            +'"etag":null,"name":"All Files"},{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"},{"type":"folder","id":"104028912491","sequence_id":"1",'
            +'"etag":"1","name":"Bid_Histories"}]},"created_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"modified_by":{"type":"user","id":"14013138185","name":"ABC"}}';

        String query = 'select id,name, Migrated_Agreement_Id__c from Bid_History__c where Migrated_Agreement_Id__c != null';
		String destinationObjectLabel = 'BID_History';
		String destinationObjectName = 'Bid_History__c';
		String logModule = 'OWF';
		String sourceIdInDestinationFieldName = 'Migrated_Agreement_Id__c';
        Map<String, Boolean> destiationFieldToValueMapToUpdate = new Map<String, boolean>();  
		destiationFieldToValueMapToUpdate.put('Is_Box_Folder_Migrated__c',true);
        List<String> successFailureEmailRecieverList = new List<String>{'xyz@metacube.com'};
        BCH_GBL_BoxMigration boxMigration = new BCH_GBL_BoxMigration(query,destinationObjectLabel,destinationObjectName,logModule,
                                                                     null, null,destiationFieldToValueMapToUpdate, sourceIdInDestinationFieldName, successFailureEmailRecieverList, null);
        boxMigration.lstException.add('Class.fflib_SObjectUnitOfWork.SimpleDML.dmlUpdate: line 96, column 1 Class.fflib_SObjectUnitOfWork.commitWork: line 364, column 1');
        boxMigration.lstExceptionForLogs.add('Class.fflib_SObjectUnitOfWork.SimpleDML.dmlUpdate: line 73');
        BoxTestMockCallout.MockResponse copyResponse = new BoxTestMockCallout.MockResponse(mockResponseBodyForCopy, 'OK', 201);
        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>{copyResponse};
        UTL_Box.lstBoxException.add('128739764476 : Copy API Error : Invalid value with value 128739764476 item_name_in_use');    
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBodyForCopy, 'OK', 201));
            database.executebatch(boxMigration, 30);
        Test.stopTest();    
        
        box__FRUP__c frupRecord = [SELECT Id , box__Record_ID__c, box__Folder_ID__c FROM box__FRUP__c WHERE box__Object_Name__c = 'Bid_History__c'];
        Log_History__c logHistory = [SELECT Name, Log_Detail__c FROM Log_History__c LIMIT 1];
        
        System.assertEquals('128836283233', frupRecord.box__Folder_ID__c);
        System.assertNotEquals(null, logHistory.Name);
    }

}