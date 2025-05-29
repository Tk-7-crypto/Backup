@isTest
public class TST_UTL_SharepointFactory {
    public static void createCustomSetting(){
        Sharepoint_Config__c config = new Sharepoint_Config__c();
        config.Name = 'Sharepoint Site';
        config.Client_Id__c = 'cyLxTMzP12345e67685p4EjYM50Xc0LzqEHPerF39q0=';
        config.Client_Secret__c = 'e73bf7c1-e90c-3er6-7efc-6fcae732dd5f';
        config.Site_Url__c = 'test.sharepoint.com';
        config.Module__c = 'CLM';
        config.List_Name__c = 'Salesforce';
        config.Is_Https__c = true;
        insert config;
    }
    
    public static Apttus__APTS_Agreement__c createAgreement(Id recordTypeId,Boolean isInsert){
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Name = 'Test Agreement';
        agreement.RecordTypeId = recordTypeId;
        
        if(recordTypeId == null){
            agreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('MSA').getRecordTypeId();
        }
        if(agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID) {
            agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
            agreement.Apttus__Status__c = CON_CLM.REQUEST;
        }
        if(isInsert){
            insert agreement;
        }
        return agreement;
    }
    
    public static Sharepoint_File__c createSharepointFile(boolean isInsert){
        Sharepoint_File__c sharepointFile = new Sharepoint_File__c();
        sharepointFile.File_Name__c = 'test.pdf';
        sharepointFile.File_Url__c = '/shared documents/test/test.pdf';
        sharepointFile.Size__c = String.valueOf(Blob.valueOf('test').size());
        Apttus__APTS_Agreement__c objAgreement = createAgreement(null, true);
        sharepointFile.Parent_Id__c = objAgreement.Id;
        if(isInsert){
            insert sharepointFile;
        }
        return sharepointFile;
    }

    public static ContentVersion createContentVersion(boolean isInsert){
        ContentVersion testContentVersion = new Contentversion();
        testContentVersion.Title = 'CZDSTOU';
        testContentVersion.PathOnClient = 'test';
        testContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        
        if(isInsert)
            insert testContentVersion;
        return testContentVersion;
    }
}