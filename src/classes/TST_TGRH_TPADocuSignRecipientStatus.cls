@isTest(seeAllData = false)
public class TST_TGRH_TPADocuSignRecipientStatus {
    public static Address__c getTestAccount() {
        Address__c TestAccount;
        List<Address__c> ListAccount = [Select id, Name From Address__c where Name like 'JayVardhan' LIMIT 1];
        if(ListAccount.size() == 0) {
            TestAccount = UTL_TPA_SetupTestData.getAccount();
            TestAccount.Name = 'JayVardhan';
            TestAccount.CurrencyIsoCode = 'USD';
           // TestAccount.Region_Territory__c = 'India';
          //  TestAccount.Industry_IMS__c = 'Biotech';
            TestAccount.Is_TPA_Account__c = true;
            TestAccount.Vendor_Registration_Number__c = 9999;
            TestAccount.Street__c = 'test';
            TestAccount.City__c = 'test';
            TestAccount.Country__c = 'test';
            TestAccount.PostalCode__c = 'test';
            insert TestAccount;
        }
        else {
            TestAccount = ListAccount[0];
        }
        return TestAccount;
    }
    
    public static Contact getTestContact(Account testAccount) {
        Contact TestContact ;
        List<Contact > ListContact = [Select id,Name  From Contact where Name like 'JayVardhan' LIMIT 1];
        if(ListContact.size() == 0) {
            TestContact = UTL_TPA_SetupTestData.getContact();
            TestContact.LastName = 'Test';
            TestContact.AccountId = testAccount.Id;
            TestContact.CurrencyIsoCode = 'USD';
            TestContact.email = 'A@metacube.com';
            insert TestContact;
        }
        else {
            TestContact = ListContact [0];
        }
        return TestContact ;
    }
    
    public static TPA_Request__c getAgreement( TPA_Request__c  tpaRequest) {  
        date strtDate = date.newInstance(2014, 1, 1);
        Address__c TestAccount = getTestAccount(); 
        
        List<TPA_Request__c> ListAgg = [Select id,Name  From TPA_Request__c LIMIT 1];
        
        TPA_Request__c TestAgreement;
        if(ListAgg.size() == 0) {
            TestAgreement = UTL_TPA_SetupTestData.getTPAAgreementBlank(false, tpaRequest.id);
            TestAgreement.Requires_Manual_Review__c = false; 
            TestAgreement.Is_TPA_Signed_Contract_Attached__c = true;
            insert TestAgreement;        
        }
        else {
            TestAgreement = ListAgg[0];
        }   
        return TestAgreement;    
    } 
    
    public static TPA_Request__c   getTPARequest() {
        Address__c TestAccount = getTestAccount();
        //  Contact TestContact = getTestContact(TestAccount); 
        // create test request
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IMS in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = TestAccount.Id;
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Status_Category__c = 'Expired';
        insert tpaRequest;
        
        return tpaRequest; 
    }
    
    public static testMethod void updateAgreementDetailInDSStatus() {
        upsert new  Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        
        Address__c TestAccount = getTestAccount();  
        TPA_Request__c ObjTpa = getTPARequest(); 
        TPA_Request__c TestAgreement = getAgreement(ObjTpa); 
        list<TPA_Request__c> listRequest = new list<TPA_Request__c>();      
        list<Id> reqIds = new list<Id>();     
        List<TPA_Request__c> ListAgg = new List<TPA_Request__c>();
        ListAgg.add(TestAgreement);
        
           
                          
            Test.startTest();
            
            list<dsfs__DocuSign_Recipient_Status__c > listRecipient = new list<dsfs__DocuSign_Recipient_Status__c >();   
            dsfs__DocuSign_Status__c statusObj = new dsfs__DocuSign_Status__c();
            statusObj.TPA_Request__c = TestAgreement.id;  
            statusObj.dsfs__DocuSign_Envelope_ID__c = 'EFFDCCFB-B395-4509-BF5F-004E50A0B893';           
            statusObj.dsfs__Envelope_Status__c = 'Completed';           
            statusObj.dsfs__Sender__c = 'IMS Alliance Team'; 
            statusObj.dsfs__Sender_Email__c = 'bmanning@us.imshealth.com';
            statusObj.dsfs__Subject__c = 'IQVIA TPA Program: '+TestAgreement.Name + ','+ObjTpa.Name;
            // listDSStatus.add(statusObj); 
            
            insert statusObj;
            dsfs__DocuSign_Recipient_Status__c receipient = new dsfs__DocuSign_Recipient_Status__c();
            receipient.dsfs__Parent_Status_Record__c = statusObj.id; 
            receipient.dsfs__DocuSign_Recipient_Id__c = 'C54833C0-7664-42D4-B7F3-8B59653F1076';
            receipient.dsfs__Date_Signed__c = Date.today();
            receipient.dsfs__Recipient_Status__c = 'AutoResponded';
            //  receipient.TPA_Request__c = TestAgreement.id;
            insert receipient;
            
            TGRH_TPADocuSignRecipientStatus controller = new TGRH_TPADocuSignRecipientStatus();
            listRequest.add(ObjTpa);
            reqIds.add(ObjTpa.id);
            Map<Id,dsfs__DocuSign_Recipient_Status__c> oldRecordsMap = new Map<Id,dsfs__DocuSign_Recipient_Status__c>();
            oldRecordsMap .put(receipient.id,receipient);
            
            controller.oldRecordsMap = oldRecordsMap;
            receipient.dsfs__Date_Signed__c = Datetime.newInstance(2014, 9, 25);
            listRecipient.add(receipient);
            List<Document> lstDocument = new List<Document>();
            List<TPA_RequestDocument__c> lstTpaReqDocument = new List<TPA_RequestDocument__c>();
            List<Folder> lstFolder = [Select Id From Folder Where Name = 'Public Folder'];
            if(lstFolder.size() > 0) {
                Document document1 = new Document(FolderId = lstFolder.get(0).Id, Name='Compliance Program',Keywords = 'Test');
                lstDocument.add(document1);
                Document document2 = new Document(FolderId = lstFolder.get(0).Id, Name='STANDARD TERMS AND CONDITIONS',Keywords = 'Test');
                lstDocument.add(document2);
                Document document3 = new Document(FolderId = lstFolder.get(0).Id, Name='Restricted Data Security Requirement',Keywords = 'Test');
                lstDocument.add(document3);
                insert lstDocument;
                TPA_RequestDocument__c tpaReqDocument1 = UTL_TPA_SetupTestData.getTPARequestDocument(ObjTpa);
                tpaReqDocument1.Document_Id__c = lstDocument[0].Id;
                tpaReqDocument1.TPA_Request_Id__c = ObjTpa.Id;
                lstTpaReqDocument.add(tpaReqDocument1);
                TPA_RequestDocument__c tpaReqDocument2 = UTL_TPA_SetupTestData.getTPARequestDocument(ObjTpa);
                tpaReqDocument2.Document_Id__c = lstDocument[1].Id;
                tpaReqDocument2.TPA_Request_Id__c = ObjTpa.Id;
                lstTpaReqDocument.add(tpaReqDocument2);
                TPA_RequestDocument__c tpaReqDocument3 = UTL_TPA_SetupTestData.getTPARequestDocument(ObjTpa);
                tpaReqDocument3.Document_Id__c = lstDocument[2].Id;
                tpaReqDocument3.TPA_Request_Id__c = ObjTpa.Id;
                lstTpaReqDocument.add(tpaReqDocument3);
                insert lstTpaReqDocument;
            }
            Attachment wetSignAttachment = UTL_TPA_SetupTestData.addAttachmentToParent(TestAgreement.id,'Signed on Paper');
            Attachment amaLetteroshoAttach = UTL_TPA_SetupTestData.addAttachmentToParent(TestAgreement.id,'AMA_Lettershop_TPA-33194_Test AMA Accou_Test AMA A_2016.pdf_Completed'); //Added by Sunny Bansal under ER-2261
            
            List <dsfs__DocuSign_Recipient_Status__c> updatedStatusList = [SELECT Id ,Name,  dsfs__Parent_Status_Record__c, dsfs__Parent_Status_Record__r.TPA_Request__c,dsfs__Envelope_Id__c,//Modified by Govind under ER-3145
                   LastActivityDate, LastModifiedById, LastModifiedDate,  SystemModstamp, dsfs__Date_Delivered__c, dsfs__Date_Signed__c  FROM dsfs__DocuSign_Recipient_Status__c
                   where id IN : listRecipient] ;
            controller.onAfterUpdate(updatedStatusList);  
            // controller.updateRecipientDetailInTPARequest(listRecipient);
            // controller.captureActivityInAgreementForReadReceipt(listRecipient);
            //s(string agreementId,string tpaRequestId,boolean updateAttachmentFlag )
          //  TGRH_TPADocuSignRecipientStatus.updateStatusToInEffect(TestAgreement.Id, (System.now()).date());
            delete wetSignAttachment;
           // TGRH_TPADocuSignRecipientStatus.updateStatusToInEffect(TestAgreement.Id, (System.now()).date());
           // TGRH_TPADocuSignRecipientStatus.sendDataAuthorizationForAgreement(TestAgreement);
            Test.stopTest();
        
    
    }
}