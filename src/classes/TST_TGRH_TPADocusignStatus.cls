@isTest(seeAllData = false)
public class TST_TGRH_TPADocusignStatus { 
    public static dsfs__DocuSign_Status__c objDocusignStatus;
    
    public static testMethod void updateAgreementDetailInDSStatus() {
        Address__c TestAccount = UTL_TPA_SetupTestData.getAddress();  
        TestAccount.Name = 'Test Acc';
        TestAccount.Vendor_Registration_Number__c = 9100;
        insert TestAccount; 
        
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        TPA_Request__c TestAgreement = TST_TGRH_TPADocusignStatus.getTestAgreement(); 
        TestAgreement = [Select id, Name, TP_Processor_Email__c, Vendor_Language__c,Vendor_First_Name__c,Vendor_Contact_Last_Name__c From TPA_Request__c where id = :TestAgreement.id LIMIT 1];     
        
        list<dsfs__DocuSign_Status__c> listDSStatus = new list<dsfs__DocuSign_Status__c>();  
        Test.startTest();
        TGRH_TPADocusignStatus controller = new TGRH_TPADocusignStatus();
        dsfs__DocuSign_Status__c statusObj = TST_TGRH_TPADocusignStatus.getDocusignStatus(TestAgreement.name);
        
        
        
        listDSStatus.add(statusObj);    
        addAttachmentToParent(TestAgreement.Id,TestAgreement.Name);
        addAttachmentToParent(TestAgreement.Id,TestAgreement.Name);
        //controller.onAfterInsert(listDSStatus);
        //controller.onAfterUpdate(listDSStatus);
        //controller.onBeforeInsert(listDSStatus);  
        //controller.objAgg = TestAgreement;
        //controller.updateAgreementFields(); 
        objDocusignStatus.dsfs__Envelope_Status__c = 'Declined';
                   
        Test.stopTest();
        update objDocusignStatus;
    }
    
    public static testMethod void updateAgreementDetailInDSStatus2() {
        Address__c TestAccount = UTL_TPA_SetupTestData.getAddress();  
        TestAccount.Name = 'Test Acc';
        TestAccount.Vendor_Registration_Number__c = 9100;
        insert TestAccount; 
        
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        TPA_Request__c TestAgreement = TST_TGRH_TPADocusignStatus.getTestAgreement(); 
        TestAgreement = [Select id, Name, TP_Processor_Email__c, Vendor_Language__c,Vendor_First_Name__c,Vendor_Contact_Last_Name__c From TPA_Request__c where id = :TestAgreement.id LIMIT 1];     
        
        list<dsfs__DocuSign_Status__c> listDSStatus = new list<dsfs__DocuSign_Status__c>();
        Test.startTest();
        TGRH_TPADocusignStatus controller = new TGRH_TPADocusignStatus();
        
        dsfs__DocuSign_Status__c statusObj = TST_TGRH_TPADocusignStatus.getDocusignStatus(TestAgreement.name);
        
         
        
        listDSStatus.add(statusObj);    
        addAttachmentToParent(TestAgreement.Id,TestAgreement.Name);
        //addAttachmentToParent(TestAgreement.Id,TestAgreement.Name);
        //controller.onAfterInsert(listDSStatus);
        //controller.onAfterUpdate(listDSStatus);
        //controller.onBeforeInsert(listDSStatus);  
        //controller.objAgg = TestAgreement;
        //controller.updateAgreementFields();
        objDocusignStatus.dsfs__Envelope_Status__c = 'Voided';
                   
        Test.stopTest();
        update objDocusignStatus;
    }
    
    private static void addAttachmentToParent(Id parentId,string Name) {  
        Blob b = Blob.valueOf('Test Data');  
          
        Attachment attachment = new Attachment();  
        attachment.ParentId = parentId;  
        attachment.Name = Name + '_Test';  
        attachment.Body = b;  
          
        insert(attachment);  
    }
    
    public static dsfs__DocuSign_Status__c getDocusignStatus(String tpaName) {
        system.debug('TestAgreement:'+TestAgreement);
        List<dsfs__DocuSign_Status__c> lstStatus = new List<dsfs__DocuSign_Status__c>();
        lstStatus = [select id, TPA_Request__c, dsfs__Subject__c, dsfs__Sender_Email__c, dsfs__Sender__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c limit 1 ];
        system.debug('lstStatus:'+lstStatus);
        if(lstStatus.size() == 0) {        
            objDocusignStatus = UTL_TPA_SetupTestData.getNewDocusignStatus();
            objDocusignStatus.dsfs__Envelope_Status__c = 'Sent';
            objDocusignStatus.dsfs__DocuSign_Envelope_ID__c = '86D7009C-8254-4835-B52E-F3A98757AABE';
            objDocusignStatus.dsfs__Subject__c = ' IQVIA TPA Program: '+tpaName+', Signature Request for TPA Test A TLLA';
            objDocusignStatus.dsfs__Sender__c ='IQVIA Third Party Access Program';
            objDocusignStatus.dsfs__Sender_Email__c = 'sender.mail@gmail.com';
            objDocusignStatus.TPA_Request__c = TestAgreement.id;
            insert objDocusignStatus;
            
            system.debug('objDocusignStatus:'+objDocusignStatus);
            return objDocusignStatus;
        }
        else {
            return lstStatus[0];
        }    
    }
    
    public static TPA_Request__c TestAgreement;            
            
    public static TPA_Request__c getTestAgreement() {
    
        Address__c testAccount = UTL_TPA_SetupTestData.getAddress();
        testAccount.Name = 'Test Acc';
        testAccount.Vendor_Registration_Number__c = 9999;
        insert testAccount; 
        
        date strtDate = date.newInstance(2014, 1, 1);
        
         TestAgreement = UTL_TPA_SetupTestData.getTPAAgreementBlank(false, '');
        TestAgreement.Data_Access_Start_Date__c = strtDate;
        TestAgreement.Data_Access_End_Date__c = strtDate.addDays(2);
        TestAgreement.Requires_Manual_Review__c = false;
        TestAgreement.TP_Processor_Email__c = 'a.a@gmail.com';
        TestAgreement.TP_Processor_Name__c = 'Test TP Processor';
        TestAgreement.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        TestAgreement.TPA_Authorised_Signer__c = 'Yes';
        TestAgreement.Client_Address__c = TestAccount.Id;
        TestAgreement.Service_Provider_Address__c = TestAccount.Id;
        TestAgreement.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        TestAgreement.Vendor_First_Name__c = 'FName';
        TestAgreement.Vendor_Contact_Last_Name__c = 'LName';
        TestAgreement.Vendor_Language__c = 'English';
        testAgreement.Request_Status__c = 'Awaiting Vendor Signature';
        insert TestAgreement;
     
        getTPARequestDocument(TestAgreement.Id);
        return TestAgreement;    
    }
    
    public  static TPA_RequestDocument__c getTPARequestDocument(Id reqId) {
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = UserInfo.getUserId();
        insert document;
        
        TPA_RequestDocument__c objTPARequestDocument = new TPA_RequestDocument__c(
            Version__c = 5,
            Document_Type__c = 'CP',
            Document_Id__c = document.id,
            TPA_Request_Id__c = reqId        
        );
        insert objTPARequestDocument; 
        return objTPARequestDocument; 
    } 
}