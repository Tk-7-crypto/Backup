public with sharing class DAOH_TPA_Additional_Term {
    public static Boolean cloneAdditionalTerm = false;
    public static List<IMS_Legal_Entity__c> legalEntitiesForCloneList = new List<IMS_Legal_Entity__c>();
    public static Map<Id, TPA_Request__c> parentTpaRequestMap = new Map<Id, TPA_Request__c>();
    public static List<TPA_Additional_Term__c> additionalTermsToUpdate = new List<TPA_Additional_Term__c>();
    public static Set<Id> futureAppAddHocEdit = new Set<Id>();
    public static Boolean isCommProcessEnabledForBulk = TPA_Settings__c.getOrgDefaults() == null ? false : TPA_Settings__c.getOrgDefaults().Enable_Comm_Auto_for_Bulk_Requests__c;
    public static List<Task> tasksToInsert;
    public static Boolean insertForOtherEnitities = false;
    public static Boolean insertionFromPage = false;
    public static Boolean exhibitPageUpdated = false;
    public static Set<Id> reqsSendApprovalMail = new Set<Id>();
    public static Set<Id> reqsSendSecApprovalMail = new Set<Id>();
    public static Set<String> futureApprovedAdditionalTerms = new Set<String>();
    public static Boolean afterInEffectDoNotAppyUpdated = false;
    
    public static void onBeforeInsert(List<TPA_Additional_Term__c> newRecords) {
        updateLegalEntity(newRecords,null);
    }

    public static void onBeforeUpdate(List<TPA_Additional_Term__c> newRecords, List<TPA_Additional_Term__c> oldRecords, Map<Id, TPA_Additional_Term__c> newMap, Map<Id, TPA_Additional_Term__c> oldMap) {
        updateLegalEntity(newRecords,oldMap);
    }

    public static void onBeforeDelete(List<TPA_Additional_Term__c> oldRecords) {
        Map<Id, TPA_Additional_Term__c> oldMap = new Map<Id, TPA_Additional_Term__c>(oldRecords);
        Set<Id> parentTPARequestIdSet = new Set<Id>();
        
        for(TPA_Additional_Term__c additionalTerm : oldRecords) {
            parentTPARequestIdSet.add(additionalTerm.TPA_Request__c);
        }

        Map<Id, TPA_Request__c> parentTpaReqMap = new Map<Id, TPA_Request__c>([SELECT Id, Name, Is_Exhibit_Required__c,is_Bulk_TPA_Request__c, Request_status__c, (SELECT Id FROM TPA_Additional_Terms__r) FROM TPA_Request__c WHERE Id IN : parentTPARequestIdSet]);
        TPA_Request__c parentTPARequest;
        for(TPA_Additional_Term__c additionalTerm : oldRecords) {
            parentTPARequest = parentTpaReqMap.get(additionalTerm.TPA_Request__c);
            if(parentTPARequest != Null) {
                if(  parentTPARequest.Request_status__c == UTL_TPA.AMA_DISCONTINUED
                  || parentTPARequest.Request_status__c == UTL_TPA.IN_EFFECT
                  || parentTPARequest.Request_status__c == 'Cancelled'
                  || parentTPARequest.Request_status__c == UTL_TPA.CLIENT_DISCONTINUED
                  || parentTPARequest.Request_status__c == UTL_TPA.AMA_CANCELLED
                  || parentTPARequest.Request_status__c == UTL_TPA.EXPIRED
                  || parentTPARequest.Request_status__c == 'Closed-IQVIA Affiliate'
                  || parentTPARequest.Request_status__c == UTL_TPA.AWAITING_VENDOR_SIGNATURE) {
                    additionalTerm.addError('Addtional terms can not be deleted in TPA request \'' + parentTPARequest.Request_status__c + '\' Status.');
                }
            }
        }
        
        //Set<string> deletedParentAdditionalTermIds = new Set<string>();
        // List<string> additionalTermsToUpdateIds = new List<string>();
        
        // for(TPA_Additional_Term__c additionalTerm : oldRecords) {
        //     if(additionalTerm.Parent_Additional_Terms__c != Null && additionalTerm.Parent_Additional_Terms__c != '') {
        //         additionalTermsToUpdateIds.add(additionalTerm.Parent_Additional_Terms__c);
        //     } else if(additionalTerm.Parent_Additional_Terms__c == null || additionalTerm.Parent_Additional_Terms__c == '') {
        //         deletedParentAdditionalTermIds.add(additionalTerm.Id);
        //     }
        // }
        
        // for(TPA_Additional_Term__c updateAdditioalterm : [SELECT Id, Name, Parent_Additional_Terms__c, Is_All_Legal_Entities_Selected__c
        //                                                   FROM TPA_Additional_Term__c 
        //                                                   WHERE (Parent_Additional_Terms__c IN : deletedParentAdditionalTermIds
        //                                                   OR Id IN : additionalTermsToUpdateIds)]) {
        //     if(!oldMap.containsKey(updateAdditioalterm.Id)) {
        //         updateAdditioalterm.Is_All_Legal_Entities_Selected__c = false;
        //         updateAdditioalterm.Parent_Additional_Terms__c = '';
        //         additionalTermsToUpdate.add(updateAdditioalterm);
        //     }            
        // }
        List<TPA_Commercial_Review__c> comRevsToDelete = [Select Id From TPA_Commercial_Review__c where TPA_Additional_Term__c =: oldMap.KeySet()];
        if(comRevsToDelete != null && comRevsToDelete.size() > 0){
            delete comRevsToDelete;
        }
    }

    public static void onAfterInsert(List<TPA_Additional_Term__c> newRecords) {
        handleClonedAdditionalTerm(newRecords, Null);
    }

    public static void onAfterUpdate(List<TPA_Additional_Term__c> newRecords, List<TPA_Additional_Term__c> oldRecords, Map<Id, TPA_Additional_Term__c> newMap, Map<Id, TPA_Additional_Term__c> oldMap) {
        handleClonedAdditionalTerm(newRecords, oldMap);
        afterInEffectDoNotAppyUpdated = false;
    }

    public static void onAfterDelete(List<TPA_Additional_Term__c> oldRecords) {
        // if(additionalTermsToUpdate.size() > 0) {
        //     update additionalTermsToUpdate;
        // }

        Set<Id> parentTPARequestIdSet = new Set<Id>();
        for(TPA_Additional_Term__c additionalTerm : oldRecords) {
            parentTPARequestIdSet.add(additionalTerm.TPA_Request__c);
            String subject = '';
            String subStringTermName = '';
            String description = '';
            String oldValue = '';
            system.debug('after delete');
            if(additionalTerm.Term_Name__c != null){
                if(additionalTerm.Term_Name__c.length() > 50){
                    subStringTermName = additionalTerm.Term_Name__c.subString(0,50)+'...';
                }
                else {
                    subStringTermName = additionalTerm.Term_Name__c;
                }
                subject = 'Ad-Hoc Term Deleted: '+subStringTermName;
                description += 'Name (Old value): '+additionalTerm.Term_Name__c +'\n';
            }
            if(additionalTerm.Category__c != null){
                description += 'Category (Old value): '+additionalTerm.Category__c+'\n';
            }
            if(additionalTerm.Use_Name__c != null){
                description += 'Use (Old value): '+additionalTerm.Use_Name__c+'\n';
            }
            if(additionalTerm.Country_of_Offering__c != null){
                description += 'Country (Old value): '+additionalTerm.Country_of_Offering__c+'\n';
            }
            if(additionalTerm.Primary_Offering_Name__c != null){
                description += 'Primary Offering Name (Old value): '+additionalTerm.Primary_Offering_Name__c+'\n';
            }
            if(additionalTerm.Secondary_Offering_Name__c != null){
                description += 'Secondary Offering Name (Old value): '+additionalTerm.Secondary_Offering_Name__c+'\n';
            }
            description += 'Do Not Apply this Ad-hoc Term if Renewed (Old value):  '+additionalTerm.Do_Not_Apply_if_Renewed__c+'\n';
            description += 'Related Ad-Hoc Term Requires Exhibit / Schedule Page (Old value):  '+additionalTerm.Exhibit_Attached__c+'\n';
            if(additionalTerm.Addtional_Term__c != null){
                description += 'Additional Term (Old value): '+additionalTerm.Addtional_Term__c+'\n';
            }
            if(description.length() > 31995){
                description = description.subString(0,31995)+'...';
            }
            else {
                description = description;
            }
            if(additionalTerm.TPA_Request__c != null && subject != null && insertionFromPage){
                updateActivityHistory(additionalTerm.TPA_Request__c,subject,description);
            }
        }
        
        if( tasksToInsert != null && tasksToInsert.size() > 0 ) {
            insert tasksToInsert;
            tasksToInsert = new List<Task>();
        }

        List<TPA_Request__c> tpaRquestListToUpdate = new List<TPA_Request__c>();
        
        Boolean newTermPresent = false,renewTermPresent=false;
        for(TPA_Request__c tpaRequest : [SELECT Id, Name,Exhibit_Page_Required__c,Manual_Trigger_Reasons__c,is_Bulk_TPA_Request__c,Pending_Acknowledgements__c,isbatchProcessing__c,TLLA_Batch_Call_Sent_On__c,TPA_Ad_Hoc_Term_Last_Update__c, Is_Exhibit_Required__c, Request_status__c, (SELECT Id,Type__c,Exhibit_Attached__c FROM TPA_Additional_Terms__r) FROM TPA_Request__c WHERE Id IN : parentTPARequestIdSet]) {
            if(tpaRequest.Is_Exhibit_Required__c && tpaRequest.TPA_Additional_Terms__r.size() == 0) {
                tpaRequest.Is_Exhibit_Required__c = false;
            }
            newTermPresent = false;renewTermPresent=false;
            Boolean exhibitAttached = false;
            for(TPA_Additional_Term__c addHoc : tpaRequest.TPA_Additional_Terms__r){
                if(addHoc.Type__c == 'Renewed'){
                    renewTermPresent = true;
                }
                if(addHoc.Type__c == 'New'){
                    newTermPresent = true;
                }
                if(addHoc.Exhibit_Attached__c){
                    exhibitAttached = true;
                }
                if(renewTermPresent && newTermPresent && exhibitAttached){
                    break;
                }
            }
            if((!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && isCommProcessEnabledForBulk)) && (!renewTermPresent || !newTermPresent)){    
                if(tpaRequest.Manual_Trigger_Reasons__c != null && tpaRequest.Manual_Trigger_Reasons__c.indexOf('Additional Term') != -1){
                    string strPickListValue = tpaRequest.Manual_Trigger_Reasons__c;
                    if(strPickListValue != null) {
                        tpaRequest.Manual_Trigger_Reasons__c = '';
                        List<string> lstPicklistValues = strPickListValue.split(';');
                        for(String str:lstPicklistValues){
                            if(renewTermPresent && (str == 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA' || str == 'Renewal has "Additional Term(s) Added" and/or "Exhibit Page Added" in prior TLLA' || str == 'IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed' || str == 'IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested')){
                                tpaRequest.Manual_Trigger_Reasons__c += str + ';';
                            }
                            else if(newTermPresent && (str == '"Additional Term(s) Added" and/or "Exhibit Page Added" in prior TLLA'  ||str == 'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested' || str == 'IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested')){
                                tpaRequest.Manual_Trigger_Reasons__c += str + ';';
                            }
                            else if(!str.contains('Additional Term')){
                                tpaRequest.Manual_Trigger_Reasons__c += str + ';';
                            }
                        }
                        tpaRequest.Manual_Trigger_Reasons__c = tpaRequest.Manual_Trigger_Reasons__c != '' ? tpaRequest.Manual_Trigger_Reasons__c.substringBeforeLast(';') : '';
                    }
                }
            }
            if(!exhibitAttached && tpaRequest.Exhibit_Page_Required__c){
                tpaRequest.Exhibit_Page_Required__c = false;
            }
            tpaRequest.TPA_Ad_Hoc_Term_Last_Update__c = DateTime.now();
            tpaRequest.isbatchProcessing__c = false;
            tpaRequest.TLLA_Batch_Call_Sent_On__c = null;
			if(tpaRequest.Pending_Acknowledgements__c == null || tpaRequest.Pending_Acknowledgements__c == ''){
                tpaRequest.Pending_Acknowledgements__c =  'TLLA Generation Pending after Ad-Hoc Terms update' ;
            }
            else if(tpaRequest.Pending_Acknowledgements__c.indexOf('TLLA Generation Pending after Ad-Hoc Terms update') == -1){
                tpaRequest.Pending_Acknowledgements__c = tpaRequest.Pending_Acknowledgements__c + ';TLLA Generation Pending after Ad-Hoc Terms update' ;
            }
            tpaRquestListToUpdate.add(tpaRequest);
        }
        if(tpaRquestListToUpdate.size() > 0) {
            TGRH_TPARequest.runAllCompletedBlock = true;
            update tpaRquestListToUpdate;
            TGRH_TPARequest.runAllCompletedBlock = false;
        }
    }

    public static void updateActivityHistory(Id parId, String taskSubject, String description ) {
        
        if(UTL_TPA.createActivityHistory) {
            if(tasksToInsert == null) {
                tasksToInsert = new List<Task>();
            }
            
            Task task = new Task();
            task.WhatId = parId;
            task.ActivityDate = system.today();
            task.Status = 'Completed';
            task.Subject = taskSubject;
            task.Description = description;
            tasksToInsert.add( task );
        }
    }

    public static void updateLegalEntity(List<TPA_Additional_Term__c> newRecords,Map<Id,TPA_Additional_Term__c> oldMap) {
        Set<Id> parentTPARequestIdSet = new Set<Id>();
        Boolean doNotApplyRenewed = false;
        for(TPA_Additional_Term__c additionalTerm : newRecords) {
            if(Trigger.isUpdate && !exhibitPageUpdated && additionalTerm.Exhibit_Attached__c == oldMap.get(additionalTerm.Id).Exhibit_Attached__c && additionalTerm.Name == oldMap.get(additionalTerm.Id).Name && additionalTerm.Term_Name__c == oldMap.get(additionalTerm.Id).Term_Name__c && additionalTerm.Addtional_Term__c == oldMap.get(additionalTerm.Id).Addtional_Term__c
            && additionalTerm.Category__c == oldMap.get(additionalTerm.Id).Category__c && additionalTerm.Primary_Offering_Name__c == oldMap.get(additionalTerm.Id).Primary_Offering_Name__c
            && additionalTerm.Secondary_Offering_Name__c == oldMap.get(additionalTerm.Id).Secondary_Offering_Name__c && additionalTerm.Use_Name__c == oldMap.get(additionalTerm.Id).Use_Name__c
            && (additionalTerm.Category__c == 'Use Specific Ad-Hoc Terms' || additionalTerm.Country_of_Offering__c == oldMap.get(additionalTerm.Id).Country_of_Offering__c) && additionalTerm.Do_Not_Apply_if_Renewed__c != oldMap.get(additionalTerm.Id).Do_Not_Apply_if_Renewed__c){
                doNotApplyRenewed = true;
            }
            if(Trigger.isUpdate && additionalTerm.Is_Future_Approved__c 
            && (exhibitPageUpdated || additionalTerm.Exhibit_Attached__c != oldMap.get(additionalTerm.Id).Exhibit_Attached__c || additionalTerm.Name != oldMap.get(additionalTerm.Id).Name || additionalTerm.Term_Name__c != oldMap.get(additionalTerm.Id).Term_Name__c || additionalTerm.Addtional_Term__c != oldMap.get(additionalTerm.Id).Addtional_Term__c
            || additionalTerm.Category__c != oldMap.get(additionalTerm.Id).Category__c || additionalTerm.Primary_Offering_Name__c != oldMap.get(additionalTerm.Id).Primary_Offering_Name__c
            || additionalTerm.Secondary_Offering_Name__c != oldMap.get(additionalTerm.Id).Secondary_Offering_Name__c || additionalTerm.Do_Not_Apply_if_Renewed__c != oldMap.get(additionalTerm.Id).Do_Not_Apply_if_Renewed__c)){
                additionalTerm.Is_Future_Approved__c = false;
                futureAppAddHocEdit.add(additionalTerm.Id);
            }
            parentTPARequestIdSet.add(additionalTerm.TPA_Request__c);
        }

        parentTpaRequestMap = new Map<Id,TPA_Request__c>([Select Id,Name,Is_Exhibit_Required__c,Manual_Trigger_Reasons__c,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,
                Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,isbatchProcessing__c,Exhibit_Page_Required__c,
                is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,
                Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,TPA_Ad_Hoc_Term_Last_Update__c,
                Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,
                Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,
                Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,
                TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c,Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,
                Request_Status__c,is_Bulk_TPA_Request__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,
                isLegalEntityPresent__c,Is_Veeva_Use_CRM_SubNational_Off__c,Ack_Understanding_of_Prescriber_Data__c,Is_Veeva_Use_CRM_Off_OneKey__c,is_Veeva_Use_CRM__c,Pending_Acknowledgements__c,(Select Id,Status__c,Is_Review_Secondary__c,Manual_Review_Reason__c from TPA_Commercial_Reviews__r) , 
                (SELECT Id, Name FROM IMS_Legal_Entities__r) From TPA_Request__c where Id in: parentTPARequestIdSet]);

        TPA_Request__c parentTPARequest;
        for(TPA_Additional_Term__c additionalTerm : newRecords) {
            parentTPARequest = parentTpaRequestMap.get(additionalTerm.TPA_Request__c);
            if(parentTPARequest != Null) {
                if(  parentTPARequest.Request_status__c == UTL_TPA.AMA_DISCONTINUED
                  || parentTPARequest.Request_status__c == UTL_TPA.IN_EFFECT
                  || parentTPARequest.Request_status__c == 'Cancelled'
                  || parentTPARequest.Request_status__c == UTL_TPA.CLIENT_DISCONTINUED
                  || parentTPARequest.Request_status__c == UTL_TPA.AMA_CANCELLED
                  || parentTPARequest.Request_status__c == UTL_TPA.EXPIRED
                  || parentTPARequest.Request_status__c == 'Closed-IQVIA Affiliate'
                  || parentTPARequest.Request_status__c == UTL_TPA.AWAITING_VENDOR_SIGNATURE) {
                    if(doNotApplyRenewed && parentTPARequest.Request_status__c == UTL_TPA.IN_EFFECT){
                        afterInEffectDoNotAppyUpdated = true;
                    }
                    else{ 
                        additionalTerm.addError('Addtional terms can not be added or updated in TPA request \'' + parentTPARequest.Request_status__c + '\' Status.');
                    }
                } else if(parentTPARequest.IMS_Legal_Entities__r.size() > 0) {
                    List<IMS_Legal_Entity__c> legalEntityList = parentTPARequest.IMS_Legal_Entities__r;
                    system.debug('legalEntityList: ' + legalEntityList);
                    system.debug('additionalTerm.Is_All_Legal_Entities_Selected__c: ' + additionalTerm.Is_All_Legal_Entities_Selected__c);
                    if(additionalTerm.Parent_Additional_Terms__c == '' || additionalTerm.Parent_Additional_Terms__c == Null) {
                        if(!additionalTerm.Is_All_Legal_Entities_Selected__c) {
                            if(additionalTerm.TPA_Legal_Entity_1__c == Null) {
                                if(legalEntityList.size() == 1) {
                                    additionalTerm.TPA_Legal_Entity_1__c = legalEntityList[0].Id;
                                } else {
                                    additionalTerm.addError('Please select a legal entity for this additional term or select \'Is All Legal Entities Selected\' checkbox to display it under both legal entities in TLLA.');
                                }
                            } 
                        } else {
                            additionalTerm.TPA_Legal_Entity_1__c = legalEntityList[0].Id;
                        } 
                    } else if(additionalTerm.Parent_Additional_Terms__c != Null && !additionalTerm.Is_All_Legal_Entities_Selected__c) {
                        additionalTerm.Parent_Additional_Terms__c = null;
                    }
                }
            }             
        }
    }

    public static void handleClonedAdditionalTerm(List<TPA_Additional_Term__c> newRecords, Map<Id, TPA_Additional_Term__c> oldMap) {
        List<TPA_Request__c> tpaRquestListToUpdate = new List<TPA_Request__c>();
        List<TPA_Commercial_Review__c> commercialRevsToUpsert = new List<TPA_Commercial_Review__c>();
        //Set<Id> reqsSendApprovalMail = new Set<Id>();
        //Set<Id> reqsSendSecApprovalMail = new Set<Id>();
        List<TPA_Commercial_Review__c> comRevs = new List<TPA_Commercial_Review__c>();
        Set<Id> reqsExhibitAttached = new Set<Id>();
        Map<Id,List<TPA_Additional_Term__c>> reqWithAddHoc = new Map<Id,List<TPA_Additional_Term__c>>();
        Map<Id,TPA_Commercial_Review__c> comRevsToUpdate = new Map<Id,TPA_Commercial_Review__c>();
        
        List<Id> addHocTermsUpdated = new List<Id>();
        for(TPA_Additional_Term__c addHoc: newRecords){
            if(addHoc.Exhibit_Attached__c && (Trigger.isInsert || (!oldMap.get(addHoc.Id).Exhibit_Attached__c))){
                reqsExhibitAttached.add(addHoc.TPA_Request__c);
            }
            List<TPA_Additional_Term__c> addTerms = new List<TPA_Additional_Term__c>();
            if(reqWithAddHoc.containsKey(addHoc.TPA_Request__c)){
                addTerms = reqWithAddHoc.get(addHoc.TPA_Request__c);
            }
            addTerms.add(addHoc);
            reqWithAddHoc.put(addHoc.TPA_Request__c,addTerms);
            if(oldMap != null){
                String subject = '';
                String subStringTermName = '';
                String description = '';
                String oldValue = '';
                String newValue = '';
                Boolean valueUpdated = false;
                if(addHoc.Term_Name__c != null){
                    if(addHoc.Term_Name__c.length() > 50){
                        subStringTermName = addHoc.Term_Name__c.subString(0,50)+'...';
                    }
                    else {
                        subStringTermName = addHoc.Term_Name__c;
                    }
                    subject = 'Ad-Hoc Term Updated: '+subStringTermName;
                }
                if(oldMap.get(addHoc.id).Term_Name__c != addHoc.Term_Name__c)
                {
                    oldValue = oldMap.get(addHoc.id).Term_Name__c != null ? oldMap.get(addHoc.id).Term_Name__c : '';
                    newValue = addHoc.Term_Name__c != null ? addHoc.Term_Name__c : '';
                    description += 'Name (Old value): ' +oldValue +'\nName (New value): '+newValue +'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Category__c != addHoc.Category__c)
                {
                    oldValue = oldMap.get(addHoc.id).Category__c != null ? oldMap.get(addHoc.id).Category__c : '';
                    newValue = addHoc.Category__c != null ? addHoc.Category__c : '';
                    description += 'Category (Old value): ' +oldValue +'\nCategory (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Use_Name__c != addHoc.Use_Name__c)
                {
                    oldValue = oldMap.get(addHoc.id).Use_Name__c != null ? oldMap.get(addHoc.id).Use_Name__c : '';
                    newValue = addHoc.Use_Name__c != null ? addHoc.Use_Name__c : '';
                    description += 'Use (Old value): ' +oldValue +'\nUse (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Country_of_Offering__c != addHoc.Country_of_Offering__c)
                {
                    oldValue = oldMap.get(addHoc.id).Country_of_Offering__c != null ? oldMap.get(addHoc.id).Country_of_Offering__c : '';
                    newValue = addHoc.Country_of_Offering__c != null ? addHoc.Country_of_Offering__c : '';
                    description += 'Country (Old value):' +oldValue +'\nCountry (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Primary_Offering_Name__c != addHoc.Primary_Offering_Name__c)
                {
                    oldValue = oldMap.get(addHoc.id).Primary_Offering_Name__c != null ? oldMap.get(addHoc.id).Primary_Offering_Name__c : '';
                    newValue = addHoc.Primary_Offering_Name__c != null ? addHoc.Primary_Offering_Name__c : '';
                    description += 'Primary Offering Name (Old value): ' +oldValue +'\nPrimary Offering Name (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Secondary_Offering_Name__c != addHoc.Secondary_Offering_Name__c)
                {
                    oldValue = oldMap.get(addHoc.id).Secondary_Offering_Name__c != null ? oldMap.get(addHoc.id).Secondary_Offering_Name__c : '';
                    newValue = addHoc.Secondary_Offering_Name__c != null ? addHoc.Secondary_Offering_Name__c : '';
                    description += 'Secondary Offering Name (Old value): ' +oldValue +'\nSecondary Offering Name (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Do_Not_Apply_if_Renewed__c != addHoc.Do_Not_Apply_if_Renewed__c)
                {
                    description += 'Do Not Apply this Ad-hoc Term if Renewed (Old value): ' +oldMap.get(addHoc.id).Do_Not_Apply_if_Renewed__c +'\nDo Not Apply this Ad-hoc Term if Renewed (New value):  '+addHoc.Do_Not_Apply_if_Renewed__c+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Exhibit_Attached__c != addHoc.Exhibit_Attached__c)
                {
                    description += 'Related Ad-Hoc Term Requires Exhibit / Schedule Page (Old value): ' +oldMap.get(addHoc.id).Exhibit_Attached__c +'\nRelated Ad-Hoc Term Requires Exhibit / Schedule Page (New value):  '+addHoc.Exhibit_Attached__c+'\n\n';
                    valueUpdated = true;
                }
                if(oldMap.get(addHoc.id).Addtional_Term__c != addHoc.Addtional_Term__c)
                {
                    oldValue = oldMap.get(addHoc.id).Addtional_Term__c != null ? oldMap.get(addHoc.id).Addtional_Term__c : '';
                    newValue = addHoc.Addtional_Term__c != null ? addHoc.Addtional_Term__c : '';
                    description += 'Additional Term (Old value): ' +oldValue +'\nAdditional Term (New value): '+newValue+'\n\n';
                    valueUpdated = true;
                }
                if(description.length() > 31995){
                    description = description.subString(0,31995)+'...';
                }
                else {
                    description = description;
                }
                if(addHoc.TPA_Request__c != null && subject != null && insertionFromPage && valueUpdated){
                    updateActivityHistory(addHoc.TPA_Request__c,subject,description);
                }
            }
            if(oldMap == null){
                String subject = '';
                String subStringTermName = '';
                String description = '';
                String newValue = '';
                if(addHoc.Term_Name__c != null){
                    if(addHoc.Term_Name__c.length() > 50){
                        subStringTermName = addHoc.Term_Name__c.subString(0,50)+'...';
                    }
                    else {
                        subStringTermName = addHoc.Term_Name__c;
                    }
                    subject = 'Ad-Hoc Term Created: '+subStringTermName;
                    description += 'Name (New value): '+addHoc.Term_Name__c +'\n';
                }
                if(addHoc.Category__c != null){
                    description += 'Category (New value): '+addHoc.Category__c+'\n';
                }
                if(addHoc.Use_Name__c != null){
                   description += 'Use (New value): '+addHoc.Use_Name__c+'\n'; 
                }
                if(addHoc.Country_of_Offering__c != null){
                    description += 'Country (New value): '+addHoc.Country_of_Offering__c+'\n';
                }
                if(addHoc.Primary_Offering_Name__c != null){
                    description += 'Primary Offering Name (New value): '+addHoc.Primary_Offering_Name__c+'\n';
                }
                if(addHoc.Secondary_Offering_Name__c != null){
                    description += 'Secondary Offering Name (New value): '+addHoc.Secondary_Offering_Name__c+'\n';
                }
                description += 'Do Not Apply this Ad-hoc Term if Renewed (New value):  '+addHoc.Do_Not_Apply_if_Renewed__c+'\n';
                description += 'Related Ad-Hoc Term Requires Exhibit / Schedule Page (New value):  '+addHoc.Exhibit_Attached__c+'\n';
                if(addHoc.Addtional_Term__c != null){
                    description += 'Additional Term (New value): '+addHoc.Addtional_Term__c+'\n';
                }
                if(description.length() > 31995){
                    description = description.subString(0,31995)+'...';
                }
                else {
                    description = description;
                }
                if(addHoc.TPA_Request__c != null && subject != null && insertionFromPage){
                    updateActivityHistory(addHoc.TPA_Request__c,subject,description);
                }
            }
            if(Trigger.isUpdate && !UTL_TPA.updateFromPage){
                addHocTermsUpdated.add(addHoc.Id);
            }
        }
        if( tasksToInsert != null && tasksToInsert.size() > 0 ) {
            insert tasksToInsert;
            tasksToInsert = new List<Task>();
        }
        if(!afterInEffectDoNotAppyUpdated){
        for(TPA_Commercial_Review__c comRev: [Select Id,Action__c,Status__c,Is_Review_Secondary__c,Is_ReviewForm_Acknowledged__c,TPA_Additional_Term__c From TPA_Commercial_Review__c where TPA_Additional_Term__c in: addHocTermsUpdated and Is_Review_Secondary__c = true]){
            comRevsToUpdate.put(comRev.TPA_Additional_Term__c,comRev);
        }
        Boolean primaryComp = true,isPrimaryRevApp = true,isSecondaryApp=true;
        for(TPA_Request__c tpaRequest: parentTpaRequestMap.values()) {
            if(!tpaRequest.Is_Exhibit_Required__c) {
                tpaRequest.Is_Exhibit_Required__c = true;
            }
            if((!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && isCommProcessEnabledForBulk)) && tpaRequest.Request_Status__c != 'Awaiting Vendor Submission' && tpaRequest.Request_Status__c != 'In Draft' && Trigger.isInsert && tpaRequest.Manual_Trigger_Reasons__c != null && !tpaRequest.Manual_Trigger_Reasons__c.contains('IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested')){
                tpaRequest.Manual_Trigger_Reasons__c += ';IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested';
                tpaRequest.Is_Manually_Approved__c = true;
                tpaRequest = addPendingAck(tpaRequest,'Pending Commercial Review Acknowledgements');
            }
            
            primaryComp = true;
            isSecondaryApp = true;isPrimaryRevApp = true;
            for(TPA_Commercial_Review__c comRev:tpaRequest.TPA_Commercial_Reviews__r){
                if(!comRev.Is_Review_Secondary__c && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    primaryComp = false;
                }
                if(Trigger.isUpdate && comRev.Manual_Review_Reason__c != null && comRev.Manual_Review_Reason__c.contains('Additional Term(s)') && comRev.Is_Review_Secondary__c && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    isSecondaryApp = false;
                }
                else if(Trigger.isUpdate && comRev.Manual_Review_Reason__c != null && comRev.Manual_Review_Reason__c.contains('Additional Term(s)') && !comRev.Is_Review_Secondary__c && !TGRH_TPA_Commercial_Review.isComRevApproved(comRev.Status__c)){
                    isPrimaryRevApp = false;
                }
            }
            if((!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && isCommProcessEnabledForBulk)) && tpaRequest.Request_Status__c != 'Awaiting Vendor Submission' && tpaRequest.Request_Status__c != 'Client Draft' && Trigger.isInsert){
                for(TPA_Additional_Term__c addHocTerm : reqWithAddHoc.get(tpaRequest.Id)){
                    TPA_Commercial_Review__c comRevSec = createAddHocSecReview(tpaRequest,addHocTerm.Id,primaryComp,'New');
                    commercialRevsToUpsert.add(comRevSec);
                }
                if(primaryComp){
                    reqsSendSecApprovalMail.add(tpaRequest.Id);
                }
            }
            
            if((!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && isCommProcessEnabledForBulk)) && Trigger.isUpdate  &&  tpaRequest.Request_Status__c != 'Awaiting Vendor Submission' && tpaRequest.Request_Status__c != 'In Draft'){
                for(TPA_Additional_Term__c addHocTerm : reqWithAddHoc.get(tpaRequest.Id)){
                    if(comRevsToUpdate.containsKey(addHocTerm.Id)){
                        TPA_Commercial_Review__c comRev = comRevsToUpdate.get(addHocTerm.Id);
                        comRev.Action__c = '';
                        if(comRev.Is_Review_Secondary__c){
                            comRev.Status__c = primaryComp ? 'Awaiting Review' : 'Awaiting to Send: Primary Commercial Owner Not Complete';
                        }else {
                            comRev.Status__c = 'Awaiting Review';
                        }    
                        comRev.Is_ReviewForm_Acknowledged__c = false;
                        commercialRevsToUpsert.add(comRev);
                    }
                    else if(futureAppAddHocEdit.contains(addHocTerm.Id)){
                        TPA_Commercial_Review__c comRevSec = createAddHocSecReview(tpaRequest,addHocTerm.Id,primaryComp,addHocTerm.Type__c);
                        commercialRevsToUpsert.add(comRevSec);
                        String reviewReason = 'IQVIA Legal Approval Required: '+(addHocTerm.Type__c == 'Renewed' ? '[Renew]' : '[New]')+' TPA: Ad-hoc Additional Term Requested';
                        tpaRequest = addManualReviewReason(tpaRequest,reviewReason);
                        tpaRequest = addPendingAck(tpaRequest,'Pending Commercial Review Acknowledgements');
                    }
                }
                if((!isSecondaryApp || commercialRevsToUpsert.size() > 0) && isPrimaryRevApp && primaryComp){
                    reqsSendSecApprovalMail.add(tpaRequest.Id);
                }
            }
            if((!tpaRequest.is_Bulk_TPA_Request__c || (tpaRequest.is_Bulk_TPA_Request__c && isCommProcessEnabledForBulk)) && Trigger.isUpdate && !isPrimaryRevApp && tpaRequest.Request_Status__c != 'Awaiting Vendor Submission' && tpaRequest.Request_Status__c != 'In Draft'){
                reqsSendApprovalMail.add(tpaRequest.Id);
            }
            tpaRequest.TPA_Ad_Hoc_Term_Last_Update__c = DateTime.now();
            tpaRequest.isbatchProcessing__c = false;
            tpaRequest.TLLA_Batch_Call_Sent_On__c = null;
            if(tpaRequest.Pending_Acknowledgements__c == null || tpaRequest.Pending_Acknowledgements__c == ''){
                tpaRequest.Pending_Acknowledgements__c =  'TLLA Generation Pending after Ad-Hoc Terms update' ;
            }
            else if(tpaRequest.Pending_Acknowledgements__c.indexOf('TLLA Generation Pending after Ad-Hoc Terms update') == -1){
                tpaRequest.Pending_Acknowledgements__c = tpaRequest.Pending_Acknowledgements__c + ';TLLA Generation Pending after Ad-Hoc Terms update' ;
            }
            if(reqsExhibitAttached.contains(tpaRequest.Id) && !tpaRequest.Exhibit_Page_Required__c){
                tpaRequest.Exhibit_Page_Required__c = true;
            }
            tpaRquestListToUpdate.add(tpaRequest);
        }
        if(tpaRquestListToUpdate.size() > 0) {
            update tpaRquestListToUpdate;
        }
        if(commercialRevsToUpsert.size() > 0 && !Test.isRunningTest()){
            upsert commercialRevsToUpsert;
        }
        if(!insertForOtherEnitities && !insertionFromPage){
            DAOH_TPA_Additional_Term.sendEmails();
        }
        /*Map<Id,Id> tpReqComRev = new Map<Id,Id>();
        for(TPA_Commercial_Review__c comRev: [Select Id,TPA_Request__c From TPA_Commercial_Review__c where TPA_Request__c in: reqsSendApprovalMail and Action_Needed_By__c like '%TP-Country%' and Is_ReviewForm_Acknowledged__c = false]){
            tpReqComRev.put(comRev.TPA_Request__c,comRev.Id);
        }
        for(Id reqId:reqsSendApprovalMail){
            SRV_TPA_TPARequest.tpaRequest = parentTpaRequestMap.get(reqId);
            SRV_TPA_TPARequest.comRevId = tpReqComRev.get(reqId) != null ? tpReqComRev.get(reqId) : null;
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
            SRV_TPA_TPARequest.comRevId = null;
        }

        for(Id reqId:reqsSendSecApprovalMail){
            SRV_TPA_TPARequest.tpaRequest = parentTpaRequestMap.get(reqId);
            if(!Test.isRunningTest()){
            SRV_TPA_TPARequest.isSecComReview = true;
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
        }*/
        List<TPA_Additional_Term__c> additionalTermToUpdateList = new List<TPA_Additional_Term__c>();
        Map<Id,Attachment> currentAttachment = new Map<Id,Attachment>();
        List<Id> additionalTermsToDelList = new List<Id>();
        Set<Id> ParentAdditionalTermIds = new Set<Id>();
        Set<Id> childAdditionalTermIds = new Set<Id>();

        for(TPA_Additional_Term__c additionalTerm : newRecords) {
            if(oldMap != null && oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c != null && oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c != '') {
                childAdditionalTermIds.add(oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c);
            }else{
                ParentAdditionalTermIds.add(additionalTerm.Id);
            }
        }
        List<TPA_Additional_Term__c> childAdditionalTermsList = [SELECT Id, Name, Parent_Additional_Terms__c FROM TPA_Additional_Term__c WHERE ((Parent_Additional_Terms__c IN : ParentAdditionalTermIds) OR (Id IN : childAdditionalTermIds))];
        Map<Id, Id> parentIdToChildIdMap = new Map<Id, Id>();

        for(TPA_Additional_Term__c childAdditionalterm : childAdditionalTermsList) {
            if(childAdditionalterm.Parent_Additional_Terms__c != Null && childAdditionalterm.Parent_Additional_Terms__c != '') {
                parentIdToChildIdMap.put(childAdditionalterm.Parent_Additional_Terms__c, childAdditionalterm.Id);
            }else{
                parentIdToChildIdMap.put(childAdditionalterm.Id, childAdditionalterm.Id);
            }
        }

        for(TPA_Additional_Term__c additionalTerm : newRecords) {
            if(additionalTerm.Parent_Additional_Terms__c == '' || additionalTerm.Parent_Additional_Terms__c == Null) {
                if(additionalTerm.Is_All_Legal_Entities_Selected__c 
                && (oldMap == Null || oldMap.get(additionalTerm.Id).Is_All_Legal_Entities_Selected__c != additionalTerm.Is_All_Legal_Entities_Selected__c)
                && parentTpaRequestMap.get(additionalTerm.TPA_Request__c) != Null 
                && parentTpaRequestMap.get(additionalTerm.TPA_Request__c).IMS_Legal_Entities__r.size() > 1) {
                    List<IMS_Legal_Entity__c> legalEntityList = parentTpaRequestMap.get(additionalTerm.TPA_Request__c).IMS_Legal_Entities__r;
                    legalEntityList.remove(0);
                    for(IMS_Legal_Entity__c legalEntity : legalEntityList) {
                        TPA_Additional_Term__c newAdditionalTerm = additionalTerm.clone();
                        newAdditionalTerm.Parent_Additional_Terms__c = additionalTerm.Id;
                        newAdditionalTerm.TPA_Legal_Entity_1__c = legalEntity.Id;
                        if(additionalTerm.Exhibit_Attached__c){
                            List<Attachment> attachmentList = [Select Id,Name,Body,ContentType From Attachment where  ParentId =: additionalTerm.Id];
                            if(attachmentList != null && attachmentList.size() > 0){
                                currentAttachment.put(additionalTerm.Id, attachmentList[0]);
                            }
                        }
                        
                        newAdditionalTerm.Is_Future_Approved__c = ( futureApprovedAdditionalTerms != null && futureApprovedAdditionalTerms.contains(UTL_TPA.createAddHocKey(newAdditionalTerm)) ) ? true : false ;
                        additionalTermToUpdateList.add(newAdditionalTerm);
                    }
                } else if(!additionalTerm.Is_All_Legal_Entities_Selected__c && oldMap != Null && oldMap.get(additionalTerm.Id).Is_All_Legal_Entities_Selected__c != additionalTerm.Is_All_Legal_Entities_Selected__c) {
                    if(parentIdToChildIdMap.get(additionalTerm.Id) != Null) {
                        additionalTermsToDelList.add(parentIdToChildIdMap.get(additionalTerm.Id));
                    }
                    else if(oldMap != null && oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c != null && oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c != '' && parentIdToChildIdMap.get(oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c) != Null){
                        additionalTermsToDelList.add(parentIdToChildIdMap.get(oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c));
                    }
                }
            } 
            if(additionalTerm.Parent_Additional_Terms__c != null && additionalTerm.Parent_Additional_Terms__c != '' && !additionalTerm.Is_All_Legal_Entities_Selected__c) {
                additionalTermsToDelList.add(oldMap.get(additionalTerm.Id).Parent_Additional_Terms__c);                
            }
        }

        List<Attachment> ListOfAttachmentToInsert = new List<Attachment>();
        if(additionalTermToUpdateList.size() > 0) {
            insertForOtherEnitities = true;
            upsert additionalTermToUpdateList;
            for(TPA_Additional_Term__c addObj : additionalTermToUpdateList){
                if(currentAttachment.containsKey(addObj.Parent_Additional_Terms__c)){
                    Attachment attchToCopy = currentAttachment.get(addObj.Parent_Additional_Terms__c);
                    Attachment attch = new Attachment();
                    attch.Name = attchToCopy.Name;
                    attch.Body = attchToCopy.Body;
                    attch.ContentType = attchToCopy.ContentType;
                    attch.ParentId = addObj.Id;
                    ListOfAttachmentToInsert.add(attch);
                }
            }
            if(ListOfAttachmentToInsert != null && ListOfAttachmentToInsert.size() > 0){
                insert ListOfAttachmentToInsert;
            }

        }
        if(additionalTermsToDelList.size() > 0) {
            Database.delete(additionalTermsToDelList, true);
        }
        }
    }

    public static TPA_Request__c addManualReviewReason(TPA_Request__c tpaReq,String manRev){
        if(tpaReq.Manual_Trigger_Reasons__c != null && tpaReq.Manual_Trigger_Reasons__c.indexOf(manRev) == -1){
            tpaReq.Manual_Trigger_Reasons__c += ';'+manRev;
            tpaReq.Is_Manually_Approved__c = true;
        }    
        return tpaReq;
    }

    public static TPA_Request__c addPendingAck(TPA_Request__c tpaReq,String val){
        if(tpaReq.Pending_Acknowledgements__c == null || tpaReq.Pending_Acknowledgements__c == ''){
            tpaReq.Pending_Acknowledgements__c =  val ;
        }
        else if(tpaReq.Pending_Acknowledgements__c.indexOf(val) == -1){
            tpaReq.Pending_Acknowledgements__c = tpaReq.Pending_Acknowledgements__c + ';'+val ;
        }
        
        return tpaReq;
    }

    public static void sendEmails(){
        List<TPA_Request__c> parentTpaRequestList  = [Select Id,Name,Is_Exhibit_Required__c,Manual_Trigger_Reasons__c,Is_South_Africa_Sub_Off__c,Is_Vendor_Name_Contains_DeepIntent__c,Is_Vendor_Name_Contains_Edith__c,
        Is_Vendor_Related_to_Source_Symphony_Acc__c,is_20_or_more_Offering_Present__c,Is_Vendor_Name_Contains_MedPro__c,isbatchProcessing__c,
        is_Specific_Vendors_LAAD_Off__c,is_Specific_Vendors_APLD_Off__c,is_Specific_Vendors_Long_Prescr_Data__c,is_Specific_Vendors_Medical_Claims_Data__c,
        Data_Period_Start_Date__c,Data_Period_End_Date__c,Client_Project_Name__c,Client_Address__r.Name,Is_Manually_Approved__c,TPA_Ad_Hoc_Term_Last_Update__c,
        Data_Access_Start_Date__c,Data_Access_End_Date__c,Parent_Request__c,Parent_Request__r.Name,Parent_Request__r.Renewed_As__c,
        Is_Partially_Renewed__c,Vendor_Website__c,AMA_USPrescriberData__c,TPA_Processor_Contact__r.Name,Parent_Request__r.Is_Renewed__c,
        Service_Provider_Address__r.Name,Client_Address__c,Service_Provider_Address__c,AMA_Agreement_required__c,Vendor_App_Submitted__c,
        TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__r.Initials__c,Requires_Manual_Review__c,TP_Processor_Email__c,vendor_language__c,TLLA_Batch_Call_Sent_On__c,
        Request_Status__c,is_Bulk_TPA_Request__c,Is_VSN_Acknowlege_By_Client__c,isClientOnComplianceHold__c,isVendorOnComplianceHold__c,Is_Potential_Vendor_Case__c,
        isLegalEntityPresent__c,Is_Veeva_Use_CRM_SubNational_Off__c,Ack_Understanding_of_Prescriber_Data__c,is_Veeva_Use_CRM__c,Is_Veeva_Use_CRM_Off_OneKey__c,Pending_Acknowledgements__c,
        (SELECT Id, Name FROM IMS_Legal_Entities__r) From TPA_Request__c where Id in: reqsSendSecApprovalMail or Id in: reqsSendApprovalMail];
        Map<Id,Id> tpReqComRev = new Map<Id,Id>();
        for(TPA_Commercial_Review__c comRev: [Select Id,TPA_Request__c From TPA_Commercial_Review__c where TPA_Request__c in: reqsSendApprovalMail and Action_Needed_By__c like '%TP-Country%' and Is_ReviewForm_Acknowledged__c = false]){
            tpReqComRev.put(comRev.TPA_Request__c,comRev.Id);
        }
        for(Id reqId:reqsSendApprovalMail){
            SRV_TPA_TPARequest.tpaRequest = parentTpaRequestList[0];
            SRV_TPA_TPARequest.comRevId = tpReqComRev.get(reqId) != null ? tpReqComRev.get(reqId) : null;
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
            }
            SRV_TPA_TPARequest.comRevId = null;
        }

        for(Id reqId:reqsSendSecApprovalMail){
            SRV_TPA_TPARequest.tpaRequest = parentTpaRequestList[0];
            if(!Test.isRunningTest()){
                SRV_TPA_TPARequest.isSecComReview = true;
                SRV_TPA_TPARequest.sendLegalReviewMail = true;
                SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                SRV_TPA_TPARequest.isSecComReview = false;
                SRV_TPA_TPARequest.sendLegalReviewMail = false;
            }
        }
        reqsSendApprovalMail = new Set<Id>();
        reqsSendSecApprovalMail = new Set<Id>();
    }

    public static TPA_Commercial_Review__c createAddHocSecReview(TPA_Request__c tpaRequest,Id addHocId,Boolean primaryComp,String type){
        TPA_Commercial_Review__c comRevSec = new TPA_Commercial_Review__c();
        comRevSec.TPA_Additional_Term__c = addHocId;
        comRevSec.Action_Needed_By__c = 'Legal';
        comRevSec.Status__c = primaryComp ? 'Awaiting Review' : 'Awaiting to Send: Primary Commercial Owner Not Complete';
        comRevSec.TPA_Request__c = tpaRequest.Id;
        comRevSec.Receiver_s_Email__c = TPA_Settings__c.getOrgDefaults() != null ? TPA_Settings__c.getOrgDefaults().Legal_Review_Email__c : '';
        comRevSec.TP_Country_Email__c = tpaRequest.TP_Processor_Email__c; 
        comRevSec.TP_US_Email__c = UTL_TPA.TPUSEMailAddress; 
        comRevSec.Manual_Review_Reason__c = 'IQVIA Legal Approval Required: '+(type == 'Renewed' ? '[Renew]' :'[New]')+' TPA: Ad-hoc Additional Term Requested';
        return comRevSec;
    }
}
