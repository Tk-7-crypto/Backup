global class BCH_TPA_Update_Commercial_Review implements Database.Batchable<sObject>, Database.Stateful{
    public static Boolean updateTemporaryDetails = false;
    public static Boolean isProcessingSeconary = false; 
    public string comEmailID;
    public string tempAction;
    public Boolean sendComReviewEmail;
    String OffName;
    public Boolean includeTestDataOnly{
        get{
            if(includeTestDataOnly == null) {
                includeTestDataOnly = false;
            }
            return includeTestDataOnly;
        }
        set;
    }
    public Boolean BatchForTemporaryComUpdate = false;
    global BCH_TPA_Update_Commercial_Review(Boolean forTemporaryComUpdate, String comID, String action, Boolean sendEmail, String OfferingName){
        BatchForTemporaryComUpdate = forTemporaryComUpdate;
        comEmailID = comID;
        tempAction = action;
        sendComReviewEmail = sendEmail;
        OffName = OfferingName;
    }
    public Map<String,String> keysWithNewId = new Map<String,String>();
    public Set<Id> reqsSet =  new Set<Id>();
    Set<String> assetNames = new Set<String>();
    Set<String> assetCategoryNames = new Set<String>();
    Set<String> assetBUNames = new Set<String>();
    Set<String> assetUseNames = new Set<String>();
    Set<String> assetUseCategoryNames = new Set<String>();
    global BCH_TPA_Update_Commercial_Review(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        intializeSets();
        String query = 'Select Id,Is_Exhibit_Required__c,Name,Manual_Trigger_Reasons__c,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,';
        query += 'Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,isbatchProcessing__c,';
        query += 'is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,';
        query += 'Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,TPA_Ad_Hoc_Term_Last_Update__c,';
        query += 'Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,is_Bulk_TPA_Request__c,';
        query += 'Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,';
        query += 'Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,';
        query += 'TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c,Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,';
        query += 'Request_Status__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,';
        query += 'isLegalEntityPresent__c,Pending_Acknowledgements__c,Is_Vendor_Veeva_for_all_Use__c,Is_Veeva_Use_CRM_Off_OneKey__c,is_Veeva_Use_CRM__c,Is_Veeva_Use_CRM_SubNational_Off__c,Ack_Understanding_of_Prescriber_Data__c,';
        query += '(select id, name, CreatedDate from Attachments order by createddate desc),(Select Id,AMA_Manual_Review__c,Is_AMA_License_Required__c From AMA_Agreement_Details__r) From TPA_Request__c where';
        query += ' Id in: reqsSet';
        query += ' and Request_Status__c in (\'Awaiting Account Mgmt Communication\',\'' + UTL_TPA.AWAITING_CLIENT_CONFIRMATION + '\',\'Awaiting Client Modification\',\'Awaiting Final Review\',\'In Review By IQVIA\',\'Pending Vendor AMA Fee Acknowledgement\',\'Pending - Vendor Declined AMA Fees\',\'TPA Approved Awaiting AMA Approval\',\'Pending Vendor Response on Data Destruction from Prior TPAs\',\'Hold for TPA non-compliance\') ';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> objList){
        String key ;
        List<String> emails = new List<String>();
        Set<String> useOffValues = new Set<String>();
        Set<String> secUseOffValues = new Set<String>();
        List<Id> commonRevIds = new List<Id>();
        List<Id> offSecRevIds = new List<Id>();
        List<TPA_Commercial_Review__c> comReviewsList = new List<TPA_Commercial_Review__c>();
        List<TPA_Commercial_Review__c> comRevsToUpdate = new List<TPA_Commercial_Review__c>();
        Map<Id,TPA_Request__c> reqWithId = new Map<Id,TPA_Request__c>();
        Set<Id> requestsIdsToCheck = new Set<Id>();
        Map<String,List<String>> reqWithvendorReviews = new Map<String,List<String>>();
        Map<String,List<String>> reqWithoffSecReviews = new Map<String,List<String>>();
        Map<String,List<String>> reqWithReviews = new Map<String,List<String>>();
        Map<String,List<TPA_Data_Asset__c>> requestWithtpaDataAssets = new Map<String,List<TPA_Data_Asset__c>>();
        Map<Id,List<TPA_Commercial_Review__c>> comRevsMap = new Map<Id,List<TPA_Commercial_Review__c>>();
        List<Id> tpaReqIds = new List<Id>();
        List<TPA_Request__c> reqDetailsWithReviews = new List<TPA_Request__c>();
        Boolean reviewUpdated = false;
        
        for(sObject sobj:objList){
            TPA_Request__c tpaReq = (TPA_Request__c)sobj;
            tpaReqIds.add(tpaReq.Id);
            reqDetailsWithReviews.add(tpaReq);
            reqWithId.put(tpaReq.Id, tpaReq);
        }
        if(!BatchForTemporaryComUpdate) {
        offSecRevIds = new List<Id>();
        commonRevIds = new List<Id>();
        secUseOffValues = new Set<String>();
        useOffValues = new Set<String>();
        for(TPA_Commercial_Review__c comreview:[Select Id,Name,Is_Review_Secondary__c,Status__c,Action__c,Action_Needed_By__c,Manual_Review_Reason__c,Receiver_s_Email__c,Associated_Offering_to_Review__c,Associated_Offering_Category__c,BU__c,Associated_Use_to_Review__c,Associated_Offering_s_Use_Category_s__c,Retrigger_By__c,Retrigger_Date__c,TPA_Request__c,TPA_Request__r.Id From TPA_Commercial_Review__c where Associated_Offering_Category__c in: assetCategoryNames and BU__c in: assetBUNames and Associated_Use_to_Review__c in: assetUseNames and Associated_Offering_s_Use_Category_s__c in: assetUseCategoryNames and Status__c Not in ('Combination Approved', 'Combination Approved and Future Approved' ) and TPA_Request__c in: tpaReqIds]){

            Boolean offFound = ((comreview.Associated_Offering_to_Review__c != null && comreview.Associated_Offering_to_Review__c.contains(':')) ? !assetNames.contains(resolvedOfferingName(comreview.Associated_Offering_to_Review__c.split(':')[0])) : !assetNames.contains(comreview.Associated_Offering_to_Review__c));
            if(comreview.Associated_Offering_to_Review__c == null || offFound){
                continue;
            }

            key = '';
            key +=comreview.Associated_Use_to_Review__c + ';';
            key +=comreview.Associated_Offering_s_Use_Category_s__c + ';';
            key +=comreview.Associated_Offering_Category__c + ';';
            key +=comreview.BU__c + ';';
            if(comreview.Associated_Offering_to_Review__c != null && comreview.Associated_Offering_to_Review__c.contains(':')){
                key += resolvedOfferingName(comreview.Associated_Offering_to_Review__c.split(':')[0]);
            }
            else{
                key +=comreview.Associated_Offering_to_Review__c;
            }
            system.debug('key:::'+key);
            if(keysWithNewId.containsKey(Key) && keysWithNewId.get(key) != null && (comreview.Action_Needed_By__c != null && !comreview.Action_Needed_By__c.contains('TP-Country') && !comreview.Action_Needed_By__c.contains('TP-US'))){
                emails = keysWithNewId.get(key).split('~');
                String priEmail = '',secEmail = '';
                if(emails != null && emails.size() > 1 && emails[1].trim() != '') {
                    secEmail = emails[1];
                } else if(emails != null && emails.size() > 0 && emails[0].trim() != '') {
                    priEmail = emails[0];
                }

                if(!comreview.Is_Review_Secondary__c && priEmail != ''){
                    comreview.Receiver_s_Email__c = priEmail;
                    reviewUpdated = true;
                }
                else if(comreview.Is_Review_Secondary__c && secEmail != ''){
                    comreview.Receiver_s_Email__c = secEmail;
                    reviewUpdated = true;
                }
                else{
                    continue;
                }

                if(reviewUpdated){
                    if(comreview.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review' && comreview.Status__c == 'Awaiting Review' && !secUseOffValues.contains('Offering Requires Secondary Commercial Review' + comreview.TPA_Request__c+comreview.Associated_Offering_to_Review__c+comreview.Associated_Use_to_Review__c)){
                        secUseOffValues.add('Offering Requires Secondary Commercial Review' + comreview.TPA_Request__c+comreview.Associated_Offering_to_Review__c+comreview.Associated_Use_to_Review__c);
                        offSecRevIds.add(comreview.Id);
                        isProcessingSeconary = true;
                    }
                    if(comreview.Manual_Review_Reason__c != 'Offering Requires Secondary Commercial Review' && !useOffValues.contains(comreview.TPA_Request__c+comreview.Associated_Offering_to_Review__c+comreview.Associated_Use_to_Review__c)){
                        useOffValues.add(comreview.TPA_Request__c+comreview.Associated_Offering_to_Review__c+comreview.Associated_Use_to_Review__c);
                        commonRevIds.add(comreview.Id);                    
                    }
                    commonRevIds.addAll(offSecRevIds);
                    if(!commonRevIds.isEmpty()){
                        reqWithReviews.put(comreview.TPA_Request__c,commonRevIds);
                    }
                    
                    comreview.Retrigger_By__c = UTL_TPA_Multilingual.CurrentUser.Name;
                    comreview.Retrigger_Date__c = Datetime.now();
                    comRevsToUpdate.add(comreview);
                    requestsIdsToCheck.add(comreview.TPA_Request__r.Id);
                    List<TPA_Commercial_Review__c> comRevs = new List<TPA_Commercial_Review__c>();
                    if(comRevsMap.containsKey(comreview.TPA_Request__r.Id)){
                        comRevs = comRevsMap.get(comreview.TPA_Request__r.Id);
                    }
                    comRevs.add(comreview);
                    comRevsMap.put(comreview.TPA_Request__r.Id,comRevs);
                    reviewUpdated = false;
                }

                
            }
        }
		}else{
            String commericalEmail = '%' + comEmailID + '%';
            Map<String,TPA_Assigned_TP_Processor__c> temporaryComOwnerMap = UTL_TPA.getTemporaryComOwnerMapWithOff();
            Date todayDate = System.now().date();
            for(TPA_Commercial_Review__c comreview:[Select Id,Associated_Offering_to_Review__c,Receiver_s_Email__c,TPA_Request__r.Id from TPA_Commercial_Review__c where Status__c Not in ('Combination Approved', 'Combination Approved and Future Approved' ) and TPA_Request__c in: tpaReqIds and Receiver_s_Email__c like: commericalEmail]){
                String temoraryDetails = '';
                String CorrectOffName = '';
                if(comreview.Associated_Offering_to_Review__c != null && comreview.Associated_Offering_to_Review__c.contains(':')){
                    CorrectOffName = resolvedOfferingName(comreview.Associated_Offering_to_Review__c.split(':')[0]);
                }
                else{
                    CorrectOffName = comreview.Associated_Offering_to_Review__c;
                }
                if(tempAction == 'update' || (tempAction == 'delete' && (OffName == null || OffName == '' || OffName.contains(CorrectOffName)))){
                    if(comreview.Receiver_s_Email__c != null){
                        for(String revID : comreview.Receiver_s_Email__c.split(';')){
                            TPA_Assigned_TP_Processor__c obj;
                            if(temporaryComOwnerMap.containsKey(revID.toLowerCase() + '~' + CorrectOffName)){
                                obj = temporaryComOwnerMap.get(revID.toLowerCase() + '~' + CorrectOffName);
                            }
                            else if(temporaryComOwnerMap.containsKey(revID.toLowerCase())){
                                obj = temporaryComOwnerMap.get(revID.toLowerCase());
                            }
                            if(obj != null){
                                temoraryDetails += revID + ' - Temp. CO - ' + obj.Temporary_Commercial_Owner_Email__c + ' From ' + DateTime.newInstance(obj.Out_of_Office_Leave_Start_Date__c.year(),obj.Out_of_Office_Leave_Start_Date__c.month(),obj.Out_of_Office_Leave_Start_Date__c.day()).format('MM/dd/YY') + ' To ' + DateTime.newInstance(obj.Out_of_Office_Leave_End_Date__c.year(),obj.Out_of_Office_Leave_End_Date__c.month(),obj.Out_of_Office_Leave_End_Date__c.day()).format('MM/dd/YY') + ';'; 
                                if(obj.Out_of_Office_Leave_Start_Date__c <= todayDate &&  obj.Out_of_Office_Leave_End_Date__c >= todayDate){
                                    if(!reqWithReviews.containsKey(comreview.TPA_Request__r.Id)) {
                                        reqWithReviews.put(comreview.TPA_Request__r.Id, new list<Id>{comreview.Id});
                                    } else {
                                        reqWithReviews.get(comreview.TPA_Request__r.Id).add(comreview.Id);
                                    }
                                }
                            }
                        }
                    }
                    
                    if(temoraryDetails == '' && tempAction == 'delete'){
                        comreview.Temporary_Reviewer_s_Email__c = '';
                        comRevsToUpdate.add(comreview);
                        if(sendComReviewEmail){
                            if(!reqWithReviews.containsKey(comreview.TPA_Request__r.Id)) {
                                reqWithReviews.put(comreview.TPA_Request__r.Id, new list<Id>{comreview.Id});
                            } else {
                                reqWithReviews.get(comreview.TPA_Request__r.Id).add(comreview.Id);
                            }
                        }
                    }

                    if(temoraryDetails != ''){
                        comreview.Temporary_Reviewer_s_Email__c = temoraryDetails;
                        comRevsToUpdate.add(comreview);
                    }

                }
                
                
                system.debug('comreview:'+comreview);
                system.debug('reqWithReviews:'+reqWithReviews);
                // if(temporaryComOwnerMap.get(comEmailID.toLowerCase()).Out_of_Office_Leave_Start_Date__c <= todayDate &&  temporaryComOwnerMap.get(comEmailID.toLowerCase()).Out_of_Office_Leave_End_Date__c >= todayDate){
                //     if(!reqWithReviews.containsKey(comreview.TPA_Request__r.Id)) {
                //         reqWithReviews.put(comreview.TPA_Request__r.Id, new list<Id>{comreview.Id});
                //     } else {
                //         reqWithReviews.get(comreview.TPA_Request__r.Id).add(comreview.Id);
                //     }
                // }

            }

        }
        if(comRevsToUpdate.size() > 0){
            try{
                if(BatchForTemporaryComUpdate) {
                    updateTemporaryDetails = true;
                }
                update comRevsToUpdate;
                updateTemporaryDetails = false;
            }
            catch(Exception e)
            {
                UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                    FALSE, 
                                                    UTL_LogFactory.GUID, 
                                                    'Exception: ' + e.getMessage() +', Line: '+e.getLineNumber(), 
                                                    'TPA', 
                                                    'Exception', 
                                                    'ERROR', 
                                                    ':::BCH_TPA_Update_Commercial_Review:::execute', 
                                                    '');
            }

        }

        /*if(!BatchForTemporaryComUpdate) {
            for(TPA_Request__c tparequest: reqDetailsWithReviews) {
                reqWithId.put(tparequest.Id, tparequest);
                offSecRevIds = new List<Id>();
                commonRevIds = new List<Id>();
                secUseOffValues = new Set<String>();
                useOffValues = new Set<String>();
                System.debug('comRevsMap//'+comRevsMap);
                if(comRevsMap.get(tparequest.Id) == null){
                    continue;
                }
                for(TPA_Commercial_Review__c comRevObj: comRevsMap.get(tparequest.Id)) {
                    if(comRevObj.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review' && !secUseOffValues.contains('Offering Requires Secondary Commercial Review' + comRevObj.TPA_Request__c+comRevObj.Associated_Offering_to_Review__c+comRevObj.Associated_Use_to_Review__c)){
                        secUseOffValues.add('Offering Requires Secondary Commercial Review' + comRevObj.TPA_Request__c+comRevObj.Associated_Offering_to_Review__c+comRevObj.Associated_Use_to_Review__c);
                        offSecRevIds.add(comRevObj.Id);
                        isProcessingSeconary = true;
                    }
                    if(comRevObj.Manual_Review_Reason__c != 'Offering Requires Secondary Commercial Review' && !useOffValues.contains(comRevObj.TPA_Request__c+comRevObj.Associated_Offering_to_Review__c+comRevObj.Associated_Use_to_Review__c)){
                        useOffValues.add(comRevObj.TPA_Request__c+comRevObj.Associated_Offering_to_Review__c+comRevObj.Associated_Use_to_Review__c);
                        commonRevIds.add(comRevObj.Id);                    
                    }
                }
                commonRevIds.addAll(offSecRevIds);
                if(!commonRevIds.isEmpty()){
                    reqWithReviews.put(tparequest.Id,commonRevIds);
                }
            }
        }*/
        if(!BatchForTemporaryComUpdate) {
            for(Id tparequestID: reqWithReviews.keySet()){
                SRV_TPA_TPARequest.tpaRequest = reqWithId.get(tparequestID);
                SRV_TPA_TPARequest.multiRetriggerIds = reqWithReviews.get(tparequestID);
                //SRV_TPA_TPARequest.multiRetriggerForSecondaryReviews = isProcessingSeconary;
                SRV_TPA_TPARequest.reminderSecOfferingMailRequired = isProcessingSeconary;
                if(!Test.isRunningTest()){
                    SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                }
                SRV_TPA_TPARequest.multiRetriggerForSecondaryReviews = false;
                SRV_TPA_TPARequest.multiRetriggerIds = null;
            }
        }else{
            for(Id tparequestID: reqWithReviews.keySet()){
                SRV_TPA_TPARequest.tpaRequest = reqWithId.get(tparequestID);
                SRV_TPA_TPARequest.multiRetriggerIds = reqWithReviews.get(tparequestID);
                if(!Test.isRunningTest()){
                    SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                }
                SRV_TPA_TPARequest.multiRetriggerIds = null;
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public String resolvedOfferingName(String offeringName){
        String resolvedName = '';
        resolvedName = offeringName.replace(' [Patient as Consumer]', '')
            .replace('STI Data - Custom Report Name', 'STI Data Custom Report Name')
        	.removeEnd(' Provide Market');
        if(OfferingName.contains('Study Name')){
            resolvedName = OfferingName + ' & Project Delivery Date';
        }
        return resolvedName;
    } 
    global void intializeSets(){
        List<String> splitedKey ;
        for(String key:keysWithNewId.KeySet()){
            splitedKey = key.split(';');
            if(splitedKey != null && splitedKey.size() == 5){
                assetNames.add(splitedKey[4]);
                assetBUNames.add(splitedKey[3]);
                assetCategoryNames.add(splitedKey[2]);
                assetUseNames.add(splitedKey[0]);
                assetUseCategoryNames.add(splitedKey[1]);
            }
        }
    }
}
