@isTest
public class TST_CSM_Util {

    @isTest
    static void testCreateAccount(){
        Test.startTest();
        Account accRecord1 = CSM_Util.createAccount();
        Account accRecord2 = CSM_Util.createRDAccount();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateContact(){
        Account accountRecord = CSM_Util.createAccount();
        
        Test.startTest();
        Contact contactRecord = CSM_Util.createContact(accountRecord.Id, 'Sharma');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateProduct(){
        Test.startTest();
        Product2 productRecord = CSM_Util.createProduct2();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateStudy(){
        Account accountRecord = CSM_Util.createAccount();
        Test.startTest();
        Study__c studyRecord = CSM_Util.createStudy(accountRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateAsset(){
        Account accountRecord = CSM_Util.createAccount();
        Contact contactRecord = CSM_Util.createContact(accountRecord.Id, 'Sharma');
        Study__c studyRecord = CSM_Util.createStudy(accountRecord.Id);
        Product2 productRecord = CSM_Util.createProduct2();
        
        Test.startTest();
        Asset assetRecord = CSM_Util.createAsset('CaseTestProduct',productRecord.Id, accountRecord.Id, contactRecord.Id, studyRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateStudySiteRelationship(){
        Account accountRecord = CSM_Util.createAccount();
        Contact contactRecord = CSM_Util.createContact(accountRecord.Id, 'Sharma');
        Study__c studyRecord = CSM_Util.createStudy(accountRecord.Id);
        
        Test.startTest();
        Study_Site_Relationship__c ssRecord = CSM_Util.createStudySiteRelationship(accountRecord.Id, studyRecord.Id, contactRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateStudySiteContactRelationship(){
        Account accountRecord = CSM_Util.createAccount();
        Contact contactRecord = CSM_Util.createContact(accountRecord.Id, 'Sharma');
        Study__c studyRecord = CSM_Util.createStudy(accountRecord.Id);
        
        Test.startTest();
        Study_Contact_Relationship__c scRecord = CSM_Util.createStudyContactRelationship(studyRecord.Id, contactRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateMikadoFiles(){
        ContentFolder cf = new ContentFolder(Name='TestContentFolder');
        insert cf;
        ContentFolder cf2 = new ContentFolder(Name='TestContentFolder2', ParentContentFolderId=cf.Id );
        insert cf2; 
        ContentVersion cv  = new ContentVersion(Title = 'Penguins', PathOnClient = 'Pengui.jpg',  VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert cv;
        ContentVersion cts = [SELECT Id, ContentDocumentId FROM ContentVersion where Title = 'Penguins' LIMIT 1];
        CSM_QI_Folder__c folder = new CSM_QI_Folder__c(Name='CSM');
        insert folder;
        CSM_QI_Folder_File_Relationship__c ff = new CSM_QI_Folder_File_Relationship__c(CSM_Folder__c =folder.Id, File_Id__c =cts.ContentDocumentId);
        insert ff;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        CNT_CSM_Mikado.getMikadoFolders();
        CNT_CSM_MikadoFiles.updateContentFolderMember(cf2.Id, cv.Id,folder.Id);
        CNT_CSM_MikadoFiles.getFiles(folder.Id);
        CNT_CSM_MikadoFiles.deleteContentDocumentById(cts.ContentDocumentId);
        Test.stopTest();
    }
    /*@isTest
    static void testCreateCase(){
        Account accountRecord = CSM_Util.createAccount();
        Contact contactRecord = CSM_Util.createContact(accountRecord.Id, 'Sharma');
        Study__c studyRecord = CSM_Util.createStudy(accountRecord.Id);
        Product2 productRecord = CSM_Util.createProduct2();
        Asset assetRecord = CSM_Util.createAsset('CaseTestProduct',productRecord.Id, accountRecord.Id, contactRecord.Id, studyRecord.Id);
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id userId = UserInfo.getUserId();
        
        Test.startTest();
        Case caseRecord = CSM_Util.createCase(recordTypeIdTechno, 'TechnologyCase', accountRecord.Id, contactRecord.Id, 
                                              studyRecord.Id, assetRecord.Id, null);
        Test.stopTest();
    }*/
}