@isTest
public class TST_BCH_CLM_BoxCount {
    
    @testSetup
    static void dataSetup() {
        List<Contract> lstContract = new List<Contract>();
        List<box__FRUP__c> frupList = new List<box__FRUP__c>();
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.Box_End_Point__c = 'https://api.box.com/2.0/';
        insert clmConfiguration;
        
        box__Folder_Details__c boxFolderDetails = new box__Folder_Details__c();
        boxFolderDetails.box__Folder_Name__c = 'Agreements';
        boxFolderDetails.box__FolderId__c = '104028912491';
        boxFolderDetails.Name = 'Agreements';
        insert boxFolderDetails; 
        
        Account acc = UTL_TestData.createAccount(); 
        insert acc; 
        
        Contract contract = new Contract();
        contract.Name = 'Test Contract';
        contract.AccountId = acc.Id;
        insert contract;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        agreement.Is_This_A_Migrated_Contract_Record__c = true;
        agreement.SFDC_ID_Of_Migrated_Contract__c = contract.Id; 
        insert agreement;
        
        box__FRUP__c frupRecord = new box__FRUP__c(); 
        frupRecord.box__Object_Name__c = 'Contract';
        frupRecord.box__Record_ID__c = contract.Id;  
        frupRecord.box__Folder_ID__c = '128739764476';
        insert frupRecord;
        
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 15;
        insert logSetting;
    }
    
    @isTest
    private static void testBoxCountBatch(){  
        String mockResponseBodyForCount = '{"type":"folder","id":"128739764476","sequence_id":"0","etag":"0","name":"NEw Folder SK- From Salesforce",'
            +'"created_at":"2020-12-27T22:43:04-08:00","modified_at":"2021-01-05T22:50:52-08:00","description":"","size":12224,"path_collection"'
            +':{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},'
            +'{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"},{"type":"folder","id":"104028912491","sequence_id":"1","etag":"1","name":"Agreements"}]},'
            +'"created_by":{"type":"user","id":"14013138185","name":"XYZ","login":"xyz@metacube.com"},"modified_by":{"type":"user","id":"14013138185","name":"XYZ","login":"xyz@metacube.com"},'
            +'"trashed_at":null,"purged_at":null,"content_created_at":"2020-12-27T22:43:04-08:00","content_modified_at":"2021-01-05T22:50:52-08:00",'
            +'"owned_by":{"type":"user","id":"13346358818","name":"ABC","login":"abc@metacube.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"104028912491","sequence_id":"1",'
            +'"etag":"1","name":"Agreements"},"item_status":"active","item_collection":{"total_count":2,"entries":[{"type":"folder","id":"129184492675","sequence_id":"0","etag":"0","name":"Test Folder"},{"type":"file","id":"760982116759",'
            +'"file_version":{"type":"file_version","id":"811483751959","sha1":"262bd481f7d89f0682abb914a761e4eaa7051107"},"sequence_id":"0","etag":"0","sha1":"262bd481f7d89f0682abb914a761e4eaa7051107","name":"GetCloudyConsultingLogo (1).png"}],'
            +'"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}';
        
        String query = 'SELECT Id FROM Contract WHERE Name =\'Test Contract\'';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBodyForCount, 'OK', 200));
        UTL_CLM_Box.lstBoxException.add('128739764476===Count API Error===');
        BCH_CLM_BoxCount boxCount = new BCH_CLM_BoxCount(query);
        boxCount.lstExceptionForLogs.add('Class.fflib_SObjectUnitOfWork.SimpleDML.dmlInsert: line 58');     
        
        Test.startTest();
            database.executebatch(boxCount, 50);
        Test.stopTest();
        
        Log_History__c logHistory = [SELECT Log_Detail__c, Log_Level__c, Log_Module__c, Record_Id__c FROM Log_History__c WHERE Log_Module__c = 'CLM' 
            AND Log_Module__c = 'CLM' AND Log_Level__c = 'WARN' LIMIT 1];
        System.assertNotEquals(null, logHistory, 'The log should be created');
    }
}