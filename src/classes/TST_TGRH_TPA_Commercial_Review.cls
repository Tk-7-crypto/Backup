@isTest
public class TST_TGRH_TPA_Commercial_Review {
	@testSetup static void setupData() {
        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        Account_Compliance__c accComp = new Account_Compliance__c(TPAs_Require_Secondary_Review_by_Mgmt__c = true,Account__c=acc.Id);
        insert accComp;
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress();
        testAccount1.Account__c = acc.Id;
        insert testAccount1;
        TPA_Request__c tpaRequest = new TPA_Request__c(AMA_Agreement_required__c=false,ClientContact__c = con.id,Client_Language__c = 'English', Data_Asset_List__c = 'AAN',TP_Processor_Email__c='test@gmail.com',Pending_Acknowledgements__c='Pending Commercial Review Acknowledgements',Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                       Is_Exhibit_Required__c=true,vendor_language__c='English',Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test',Request_Status__c='In Review by IQVIA',Data_Access_Start_Date__c = Date.today(),Service_Provider_Address__c = testAccount1.Id);
        insert tpaRequest;
        List<Attachment> lstAttachment = new List<Attachment>();
        
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.id, 'Helpful Hints ~ Doc'));
        lstAttachment.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.id, 'Original TLLA TPA Limited~ License Agreement Regenerated'));
        
        insert lstAttachment;
        
    }
    
    public static testmethod void sendAutoSignature(){
        TPA_Request__c tpaRequest = [Select Id,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,AMA_Agreement_required__c,ClientContact__c,Client_Language__c,TP_Processor_Email__c,Pending_Acknowledgements__c,Purpose_List__c,IMS_Legal_Entity_List__c,vendor_language__c,Agreement_Number__c,Secondary_Data_Asset_List__c,Request_Status__c,Data_Access_Start_Date__c,Service_Provider_Address__c From TPA_Request__c Limit 1]; 
        Account_Compliance__c accComp = [Select Id,TPAs_Require_Secondary_Review_by_Mgmt__c From Account_Compliance__c Limit 1];
        accComp.TPAs_Require_Secondary_Review_by_Mgmt__c = true;
        update accComp;
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id);
        insert comRev;
        SRV_TPA_TPARequest.primaryReviewsSubmission = true;
        comRev.Status__c = 'Combination Approved';
        update comRev;
        
        TGRH_TPA_Commercial_Review.sendForDocuSign(tpaRequest.Id);
        List<Attachment> attchs = new List<Attachment>();
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,' TLLA'));
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,' Helpful Hints'));
        attchs.add(UTL_TPA_SetupTestData.addAttachment(tpaRequest.Id,' AMA_'));
        insert attchs;
        TGRH_TPA_Commercial_Review.checkIfAllDocsAreGenerated(attchs,true,Datetime.newInstance(2023,1,1,0,0,0));
        //TGRH_TPA_Commercial_Review.sendEmailToTpProcessor(tpaRequest);
   	}
    
    public static testmethod void onHoldCase(){
        TPA_Request__c tpaRequest = [Select Id,AMA_Agreement_required__c,ClientContact__c,Client_Language__c,TP_Processor_Email__c,Pending_Acknowledgements__c,Purpose_List__c,IMS_Legal_Entity_List__c,vendor_language__c,Agreement_Number__c,Secondary_Data_Asset_List__c,Request_Status__c,Data_Access_Start_Date__c,Service_Provider_Address__c From TPA_Request__c Limit 1];
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test offshore Reason',TPA_Request__c=tpaRequest.Id);
        insert comRev;
        SRV_TPA_TPARequest.primaryReviewsSubmission = true;
        comRev.Status__c = 'Combination Approved';
        update comRev;
    }
    public static testmethod void onSecondaryReview(){
        TPA_Request__c tpaRequest = [Select Id,AMA_Agreement_required__c,ClientContact__c,Client_Language__c,TP_Processor_Email__c,Pending_Acknowledgements__c,Purpose_List__c,IMS_Legal_Entity_List__c,vendor_language__c,Agreement_Number__c,Secondary_Data_Asset_List__c,Request_Status__c,Data_Access_Start_Date__c,Service_Provider_Address__c,Service_Provider_Address__r.Account__c From TPA_Request__c Limit 1];
        List<TPA_Commercial_Review__c> listcom = new List<TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> listcomupdate = new List<TPA_Commercial_Review__c>();
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test secondary Reason',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev);
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Combination Approved',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Other Offering Selected',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev2);
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Combination Approved',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Other Use Selected',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev3);
        TPA_Commercial_Review__c comRev4 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Vendor Requires Secondary review',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev4);
        TPA_Commercial_Review__c comRev5 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id,  Action__c = 'Under Validation');
        listcom.add(comRev5);
        TPA_Commercial_Review__c comRev6 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Test Secondary reason 2' ,TPA_Request__c=tpaRequest.Id,  Action__c = 'Under Validation');
        listcom.add(comRev6);
        insert listcom;
        SRV_TPA_TPARequest.primaryReviewsSubmission = true;
        comRev.Status__c = 'Combination Approved';
        listcomupdate.add(comRev);
        comRev5.Action__c = 'Complete';
        listcomupdate.add(comRev5);
        comRev6.Action__c = 'Assigned to Commercial Owner (CO) – Awaiting CO Review';
        listcomupdate.add(comRev6);
        update listcomupdate;
        TGRH_TPA_Commercial_Review.createManualReview(tpaRequest,'Reason','a@a.in','off','use',null,null,'uc');
    }
    
    public static testmethod void offSecondaryReview(){
        TPA_Request__c tpaRequest = [Select Id,AMA_Agreement_required__c,ClientContact__c,Client_Language__c,TP_Processor_Email__c,Pending_Acknowledgements__c,Purpose_List__c,IMS_Legal_Entity_List__c,vendor_language__c,Agreement_Number__c,Secondary_Data_Asset_List__c,Request_Status__c,Data_Access_Start_Date__c,Service_Provider_Address__c,Service_Provider_Address__r.Account__c From TPA_Request__c Limit 1];
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'Test TPA Purpose', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis', isActive__c = true);
        insert tpaPurposeCategory;
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'Midas',Requires_Secondary_Review__c=true);
        insert imsDataAsset;
        List<TPA_Data_Asset__c> assetList = new List<TPA_Data_Asset__c>();
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Data_Asset__c = imsDataAsset.id,Purpose__c = tpaPurpose.Id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'Midas');
        insert tpaDataAsset;
        assetList.add(tpaDataAsset);
        IMS_Use_Offering_Atypical_Combination__c atyObj = new IMS_Use_Offering_Atypical_Combination__c(
          isActive__c = true, 
          Vendor_Name__c = tpaRequest.Service_Provider_Address__c,
          Use_Name__c = imsTpaPurpose.Id,
          Offering_Name__c = imsDataAsset.Id,
          Use_Category__c = tpaPurposeCategory.Id,
          Mgmt_Review_email__c = 'test@metacube.com',
          Legal_Review_Name__c = 'Test Offering',                         
          Legal_Review_Email__c = 'test@metacube.com',   
          Action_Needed_By__c = 'Vendor - Use - Offering Secondary Review by Legal' 
        );
        insert atyObj;
        List<TPA_Commercial_Review__c> listcom = new List<TPA_Commercial_Review__c>();
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Offering requires review',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c=tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        
        insert comRev;
        TPA_Commercial_Review__c comRev2 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Combination Approved',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Other Offering Selected',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c = tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        listcom.add(comRev2);
        TPA_Commercial_Review__c comRev3 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Combination Approved',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Other Use Selected',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c = tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        listcom.add(comRev3);
        TPA_Commercial_Review__c comRev4 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Vendor Requires Secondary Review',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c = tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        listcom.add(comRev4);
        TPA_Commercial_Review__c comRev5 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Offering Requires Secondary Commercial Review',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c = tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        listcom.add(comRev5);
        TPA_Commercial_Review__c comRev6 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='Vendor - Use - Offering Secondary Review by Legal',TPA_Request__c=tpaRequest.Id, Primary_Data_Asset__c = tpaDataAsset.Id, Associated_Use_to_Review__c = 'Test TPA Purpose', Associated_Offering_s_Use_Category_s__c = 'Expert Analysis', Associated_Offering_to_Review__c = 'Midas');
        listcom.add(comRev6);
        TPA_Commercial_Review__c comRev7 = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='Legal',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested',TPA_Request__c=tpaRequest.Id);
        listcom.add(comRev7);
        
        insert listcom;
        SRV_TPA_TPARequest.primaryReviewsSubmission = true;
        comRev.Status__c = 'Combination Approved';
        comRev5.Status__c = 'Awaiting to Send: Primary Commercial Owner Not Complete';
        update comRev;
        update comRev5;
        TGRH_TPA_Commercial_Review.createManualReview(tpaRequest,'Reason','a@a.in','off','use',null,null,'uc');
        List<TPA_Request__c> reqDetailsWithReviews = new List<TPA_Request__c>();
        reqDetailsWithReviews.add(tpaRequest);
        Map<Id,List<IMS_Use_Offering_Atypical_Combination__c>> reqWithSecComb = TGRH_TPA_Commercial_Review.checkforSecReviewCombinations(reqDetailsWithReviews, assetList);
    }
    
    public static testmethod void createManualReviewForSecComb(){
        TPA_Request__c request = [Select Id,AMA_Agreement_required__c,ClientContact__c,Client_Language__c,TP_Processor_Email__c,Pending_Acknowledgements__c,Purpose_List__c,IMS_Legal_Entity_List__c,vendor_language__c,Agreement_Number__c,Secondary_Data_Asset_List__c,Request_Status__c,Data_Access_Start_Date__c,Service_Provider_Address__c From TPA_Request__c Limit 1];
        IMS_Use_Offering_Atypical_Combination__c atyObj = new IMS_Use_Offering_Atypical_Combination__c(
          isActive__c = true,                                       
          Mgmt_Review_email__c = 'test@metacube.com',
          Legal_Review_Name__c = 'Test Offering',                         
          Legal_Review_Email__c = 'test@metacube.com',   
          Action_Needed_By__c = 'Vendor - Use Secondary Review by Legal' 
        );
        insert atyObj;
        String manualApprovalReason = 'Other Use Selected';
        String actionNeededBy = 'Commercial Owner';
        String offeringDetail = 'Channel Dynamics';
        String useDetail = 'Data Cleansing';
        TPA_Secondary_Data_Asset__c secondaryDataAsset;
        String useCategory = 'Technology';
        String key = TGRH_TPA_Commercial_Review.createKeyDataAsset(new TPA_Data_Asset__c());
        key = TGRH_TPA_Commercial_Review.createKeyComRev(new TPA_Commercial_Review__c());
        TGRH_TPA_Commercial_Review.createManualReviewForSecComb(request, manualApprovalReason, actionNeededBy, offeringDetail, useDetail, atyObj, secondaryDataAsset, useCategory);
    }
}
