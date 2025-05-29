public class DAOH_CDARequest {
    private static Boolean forceUpdateStatus = UTL_CDAUtility.forceUpdateStatus;
    public static Boolean IS_OTHER_CDA_ACCOUNT_UPDATED = false;

    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            CDA_Request__c.SobjectType
        }
    );

    /**
    * This method is called  for list of new record to be inserted during a BEFORE trigger
    * @params List<CDA_Request__c> newList --> new CDA Request List
    * @return void
    */
    public static void updateFieldsWhileInsert(List<CDA_Request__c> newList, String order) {
        if(order == 'before') {
            SRV_CDA_CDARequest.saveLocalizeFieldsForCDARequest(newList);
            for(CDA_Request__c cdaRequest : newList) {
                if(cdaRequest.Negotiator_Assigned_List__c == null) {
                    cdaRequest.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                }

            }
        } else if(order == 'after') {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    CDA_request__c.SobjectType
                }
            );
            Boolean toCommit = false;

            List<String> cdaIds = new List<String>();
            for(CDA_Request__c req : newList) {
                cdaIds.add(req.id);
            }

            List<CDA_Request__c> cdaRequestList = new List<CDA_Request__c>();
            String query = 'SELECT id, Name, CDA_Id__c, RecordTypeId FROM CDA_Request__c WHERE Id IN (\''+String.join(cdaIds, '\',\'')+'\') AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\'';
            system.debug('####inside DAOH_CDARequest.AfterInsert query: '+query);
            if (cdaIds != null && cdaIds.size() > 0) {
                cdaRequestList = Database.query(query);
                system.debug('####inside DAOH_CDARequest.AfterInsert cdaRequestList: '+cdaRequestList);
            }

            for(CDA_Request__c cdaRequest : cdaRequestList) {
                system.debug('####inside DAOH_CDARequest.AfterInsert cdaRequest: '+cdaRequest);
                system.debug('####inside DAOH_CDARequest.AfterInsert cdaRequest CDA_Id: '+cdaRequest.get('CDA_Id__c'));
                //Update CDA Name with Autonumber i.e. CDA_Id__c
                if(cdaRequest.Name == null || cdaRequest.Name == cdaRequest.Id) {
                    cdaRequest.Name = (String)cdaRequest.get('CDA_Id__c');
                }
                toCommit = true;
                if(toCommit) {
                    uow.registerDirty(cdaRequest);
                }
            }
            if(toCommit) {
                uow.commitWork();
            }
            system.debug('####inside DAOH_CDARequest.AfterInsert uow: '+uow);
        }
    }

    /**
    * beforeUpdate
    * This method is called  for list of new record to be updated during a BEFORE trigger.
    * @params List<CDA_Request__c> newList, Map<Id,CDA_Request__c> newMap, Map<Id,CDA_Request__c> oldMap
    * @return void
    */
    public static void updateFieldsBeforeUpdate(List<CDA_Request__c> newList, Map<Id,CDA_Request__c> newMap, Map<Id,CDA_Request__c> oldMap)
    {
        if(!IS_OTHER_CDA_ACCOUNT_UPDATED)
        {
            system.debug('####beforeUpdate' + IS_OTHER_CDA_ACCOUNT_UPDATED);
            SRV_CDA_CDARequest.saveLocalizeFieldsForCDARequestOnUpdate(newMap,oldMap);
            for(CDA_Request__c cdaRequest : newList) {
                if(cdaRequest.RecordTypeId != Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(Test.isRunningTest() == true ? 'HistoricalData' : UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {
                    if(cdaRequest.Negotiator_Assigned_List__c == null) {
                        cdaRequest.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                    }
                    if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED && oldMap.get(cdaRequest.Id).Status__c != UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
                        cdaRequest.Date_executed_signed_contract_received__c = System.now();
                    } else if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW) {
                        cdaRequest.Date_Sent_for_Review__c = System.now();
                        cdaRequest.Date_executed_signed_contract_received__c = null;
                    } else if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE || cdaRequest.Status__c == UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES) {
                        cdaRequest.Date_Sent_for_Review__c = null;
                        cdaRequest.Status_Completion_Date__c = null;
                        cdaRequest.Customer_Signed_Date__c = null;
                        cdaRequest.Date_executed_signed_contract_received__c = null;
                    } else if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_INDRAFT || cdaRequest.Status__c == UTL_CDAUtility.STATUS_AWAITINGREQSUB) {
                        cdaRequest.Status_Start_Date__c = null;
                        cdaRequest.Date_Sent_for_Review__c = null;
                        cdaRequest.Status_Completion_Date__c = null;
                        cdaRequest.Customer_Signed_Date__c = null;
                        cdaRequest.Date_executed_signed_contract_received__c = null;
                    } else if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFORSIGN && cdaRequest.Negotiator_Assigned_List__c == UTL_CDAUtility.NEGO_NOT_ASSIGN) {
                        cdaRequest.Negotiator_Assigned_List__c = UTL_CDAUtility.SELF_SERVICE_ONLY;
                    }
                    // This is used to cover if anyone manually try to update the cda status to contract Executed
                    if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED && cdaRequest.Status_Completion_Date__c == null) {
                        cdaRequest.addError('Docusign is not completed');
                        cdaRequest.Status__c = oldMap.get(cdaRequest.Id).Status__c;
                    } else if((cdaRequest.Status__c != UTL_CDAUtility.STATUS_CONTRACTEXECUTED && cdaRequest.Status__c != UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR && cdaRequest.Status__c != UTL_CDAUtility.STATUS_DISCLOSUREPERIODENDED) && ( oldMap.get(cdaRequest.Id).Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED || oldMap.get(cdaRequest.Id).Status__c == UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR || oldMap.get(cdaRequest.Id).Status__c == UTL_CDAUtility.STATUS_DISCLOSUREPERIODENDED) && !forceUpdateStatus) {
                        cdaRequest.Name.addError('CDA is already ' + cdaRequest.Status__c + '. You can\'t modify the details.');
                        cdaRequest.Status__c = oldMap.get(cdaRequest.Id).Status__c;
                    }
                }
            }
        }
    }

    /**
    * This methos is used to create new CDA Account once a CDA Request having Custom(Other) Account information, executed.
    * @params List<CDA_Request__c> newList --> List of new CDA Requests
    * @return void
    */
    public static void createCDAAccount(List<CDA_Request__c> newList) {
        if(!IS_OTHER_CDA_ACCOUNT_UPDATED)
        {
            system.debug('####afterUpdate' + IS_OTHER_CDA_ACCOUNT_UPDATED);
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    CDA_Account__c.SobjectType
                }
            );
            Boolean toCommit = false;
            List<CDA_Account__c> toBeUpdated =  new List<CDA_Account__c>();
            List<Id> cdaRequestIdsList = new List<Id>();
            Set<String> cdaRequestIdsSet = new Set<String>();
            Set<String> cdaAccountNameSet = new Set<String>();
            for(CDA_Request__c cdaRecord : newList) {
                if(cdaRecord.RecordTypeId != Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(Test.isRunningTest() == true ? 'HistoricalData' : UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {
                    if(cdaRecord.Customer_Legal_Entity_Name_Other__c != null){
                        cdaAccountNameSet.add(cdaRecord.Customer_Legal_Entity_Name_Other__c);
                    }
                    if(cdaRecord.Recipient_Account_Name_Other__c != null){
                        cdaAccountNameSet.add(cdaRecord.Recipient_Account_Name_Other__c);
                    }
                    if(cdaRecord.Sponsor_Legal_Entity_Name_Other__c != null){
                        cdaAccountNameSet.add(cdaRecord.Sponsor_Legal_Entity_Name_Other__c);
                    }
                }
            }

            List<CDA_Account__c> cdaAccountList = [SELECT Id, CDA_Account_Name__c, Name, Street__c, City__c, State__c, Country__c, Zip_Postal_Code__c, Competitor_flag__c, CEVA_Committee_Member__c FROM CDA_Account__c where CDA_Account_Name__c in : cdaAccountNameSet];
            for(CDA_Request__c cdaRecord : newList) {
                if(cdaRecord.RecordTypeId != Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(Test.isRunningTest() == true ? 'HistoricalData' : UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {
                    Boolean cdaAccountCustomerExits = false;
                    Boolean cdaAccountSponsorExits = false;
                    Boolean cdaAccountRecipientExits = false;
                    if(cdaAccountList != null && cdaAccountList.size() > 0){
                        for(CDA_Account__c cdaAccountRecord : cdaAccountList) {
                            if(cdaRecord.Customer_Legal_Entity_Name_Other__c != null && cdaAccountRecord.CDA_Account_Name__c == cdaRecord.Customer_Legal_Entity_Name_Other__c && cdaAccountRecord.Street__c == cdaRecord.Customer_Legal_Entity_Street_Other__c && cdaAccountRecord.City__c == cdaRecord.Customer_Legal_Entity_City_Other__c && cdaAccountRecord.State__c == cdaRecord.Customer_Legal_Entity_State_Other_PL__c && cdaAccountRecord.Country__c == cdaRecord.Customer_Legal_Entity_Country_Other_PL__c && cdaAccountRecord.Zip_Postal_Code__c == cdaRecord.Customer_Legal_Entity_ZipCode_Other__c) {
                                cdaAccountCustomerExits = true;
                            }
                            if(cdaRecord.Recipient_Account_Name_Other__c != null && cdaAccountRecord.CDA_Account_Name__c == cdaRecord.Recipient_Account_Name_Other__c && cdaAccountRecord.Street__c == cdaRecord.Recipient_Account_Street_Other__c && cdaAccountRecord.City__c == cdaRecord.Recipient_Account_City_Other__c && cdaAccountRecord.State__c == cdaRecord.Recipient_Account_State_Other_PL__c && cdaAccountRecord.Country__c == cdaRecord.Recipient_Account_Country_Other_PL__c && cdaAccountRecord.Zip_Postal_Code__c == cdaRecord.Recipient_Account_ZipCode_Other__c) {
                                cdaAccountRecipientExits = true;
                            }
                            if(cdaRecord.Sponsor_Legal_Entity_Name_Other__c != null && cdaAccountRecord.CDA_Account_Name__c == cdaRecord.Sponsor_Legal_Entity_Name_Other__c) {
                                cdaAccountSponsorExits = true;
                            }
                        }
                    }
                    if(cdaRecord.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
                        cdaRequestIdsList.add(cdaRecord.Id);
                        cdaRequestIdsSet.add((String)cdaRecord.get('CDA_Id__c'));
                        if(cdaRecord != null && cdaRecord.Customer_Legal_Entity_Name_Other__c != null && !cdaAccountCustomerExits) {
                            CDA_Account__c cdaAccountC = new CDA_Account__c();
                            cdaAccountC.CDA_Account_Name__c = cdaRecord.Customer_Legal_Entity_Name_Other__c;
                            cdaAccountC.Street__c = cdaRecord.Customer_Legal_Entity_Street_Other__c;
                            cdaAccountC.City__c = cdaRecord.Customer_Legal_Entity_City_Other__c;
                            cdaAccountC.State__c = cdaRecord.Customer_Legal_Entity_State_Other_PL__c;
                            cdaAccountC.Country__c = cdaRecord.Customer_Legal_Entity_Country_Other_PL__c;
                            cdaAccountC.Zip_Postal_Code__c = cdaRecord.Customer_Legal_Entity_ZipCode_Other__c;
                            cdaAccountC.Account_Source__c = UTL_CDAUtility.CDA_PROCESS;
                            toBeUpdated.add(cdaAccountC);
                        }

                        if(cdaRecord != null && cdaRecord.Recipient_Account_Name_Other__c != null && !cdaAccountRecipientExits) {
                            CDA_Account__c cdaAccountC = new CDA_Account__c();
                            cdaAccountC.CDA_Account_Name__c = cdaRecord.Recipient_Account_Name_Other__c;
                            cdaAccountC.Street__c = cdaRecord.Recipient_Account_Street_Other__c;
                            cdaAccountC.City__c = cdaRecord.Recipient_Account_City_Other__c;
                            cdaAccountC.State__c = cdaRecord.Recipient_Account_State_Other_PL__c;
                            cdaAccountC.Country__c = cdaRecord.Recipient_Account_Country_Other_PL__c;
                            cdaAccountC.Zip_Postal_Code__c = cdaRecord.Recipient_Account_ZipCode_Other__c;
                            if (cdaAccountC != null && cdaRecord.Competitor_Flag__c != null && cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES) {
                                    cdaAccountC.Competitor_flag__c = true;
                            }
                            if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && SRV_CDA_CDARequest.isCdaTypeAuditor(cdaRecord.CDA_Type__c)) {
                                cdaAccountC.CDA_Auditor_Indicator__c = true;
                            } else if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && SRV_CDA_CDARequest.isCdaTypeCustomer(cdaRecord.CDA_Type__c)) {
                                cdaAccountC.CDA_Customer_Indicator__c = true;
                            } else if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && SRV_CDA_CDARequest.isCdaTypeVendor(cdaRecord.CDA_Type__c)) {
                                cdaAccountC.CDA_Vendor_Indicator__c = true;
                            } else if(cdaAccountC != null && cdaRecord.CDA_Type__c != null && SRV_CDA_CDARequest.isCdaTypeCEVA(cdaRecord.CDA_Type__c)) {
                                cdaAccountC.CEVA_Committee_Member__c = true;
                            }
                            cdaAccountC.Individual_Indicator__c = cdaRecord.Individual_Indicator__c;
                            cdaAccountC.Account_Source__c = UTL_CDAUtility.CDA_PROCESS;
                            toBeUpdated.add(cdaAccountC);
                        }
                        uow.registerNew(toBeUpdated);
                        toCommit = true;
                    }
                }
            }
            if(cdaRequestIdsSet.size() > 0) {
                SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaRequestIdsSet);
            }

            if(toCommit) {
                uow.commitWork();
                system.debug('####before  = relateCdaReqToCdaAccount :: toBeUpdated = ' + toBeUpdated + ' cdaRequestList =  ' + newList);
                relateCdaReqToCdaAccount(newList, toBeUpdated);
            }
        }
    }

    /**
    * Name : relateCdaReqToCdaAccount
    * This method is used to relate a cda request to the cda Account inserted by selecting 'other' option.
    * Added by Babita Dadarwal Under Item #27
    */
    public static void relateCdaReqToCdaAccount(List<CDA_request__c> newCdaRequestList, List<CDA_Account__c> cdaAccountList) {
         fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
             new Schema.SObjectType[] {
                 CDA_request__c.SobjectType
             }
         );
         Boolean toCommit = false;
         IS_OTHER_CDA_ACCOUNT_UPDATED = true;
         List<CDA_request__c> cdaRequestList = [SELECT id, Name,
                                                Cust_Legal_Entity_Name__c,
                                                Customer_Legal_Entity_Name_Other__c,
                                                Customer_Legal_Entity_Street_Other__c,
                                                Customer_Legal_Entity_City_Other__c,
                                                Customer_Legal_Entity_State_Other_PL__c,
                                                Customer_Legal_Entity_Country_Other_PL__c,
                                                Customer_Legal_Entity_ZipCode_Other__c,
                                                Recipient_Account__c,
                                                Recipient_Account_Name_Other__c,
                                                Recipient_Account_Street_Other__c,
                                                Recipient_Account_City_Other__c,
                                                Recipient_Account_State_Other_PL__c,
                                                Recipient_Account_Country_Other_PL__c,
                                                Recipient_Account_ZipCode_Other__c
                                                FROM CDA_request__c
                                                WHERE id IN : newCdaRequestList];
         system.debug('####in relateCdaReqToCdaAccount :: cdaAccountList = ' + cdaAccountList + ' cdaRequestList =  ' + cdaRequestList);

         for(CDA_Request__c cdaRecord : cdaRequestList) {
             for(CDA_Account__c cdaAccountRecord : cdaAccountList) {
                 if(cdaRecord.Customer_Legal_Entity_Name_Other__c != null
                 && cdaAccountRecord.CDA_Account_Name__c == cdaRecord.Customer_Legal_Entity_Name_Other__c
                 && cdaAccountRecord.Street__c == cdaRecord.Customer_Legal_Entity_Street_Other__c
                 && cdaAccountRecord.City__c == cdaRecord.Customer_Legal_Entity_City_Other__c
                 && cdaAccountRecord.State__c == cdaRecord.Customer_Legal_Entity_State_Other_PL__c
                 && cdaAccountRecord.Country__c == cdaRecord.Customer_Legal_Entity_Country_Other_PL__c
                 && cdaAccountRecord.Zip_Postal_Code__c == cdaRecord.Customer_Legal_Entity_ZipCode_Other__c) {
                     cdaRecord.Cust_Legal_Entity_Name__c = cdaAccountRecord.Id;
                     toCommit = true;
                 }
                 if(cdaRecord.Recipient_Account_Name_Other__c != null
                 && cdaAccountRecord.CDA_Account_Name__c == cdaRecord.Recipient_Account_Name_Other__c
                 && cdaAccountRecord.Street__c == cdaRecord.Recipient_Account_Street_Other__c
                 && cdaAccountRecord.City__c == cdaRecord.Recipient_Account_City_Other__c
                 && cdaAccountRecord.State__c == cdaRecord.Recipient_Account_State_Other_PL__c
                 && cdaAccountRecord.Country__c == cdaRecord.Recipient_Account_Country_Other_PL__c
                 && cdaAccountRecord.Zip_Postal_Code__c == cdaRecord.Recipient_Account_ZipCode_Other__c) {
                     cdaRecord.Recipient_Account__c = cdaAccountRecord.Id;
                     toCommit = true;
                 }
             }
             if(toCommit) {
                 uow.registerDirty(cdaRecord);
             }
         }
         if(toCommit) {
             uow.commitWork();
         }
         system.debug('####after relateCdaReqToCdaAccount :: cdaAccountList = ' + cdaAccountList + ' cdaRequestList =  ' + cdaRequestList);
         IS_OTHER_CDA_ACCOUNT_UPDATED = false;
    }
    
    public static void updateCDAAccount(List<CDA_Request__c> records){
        if(CDA_Settings__c.getOrgDefaults().Is_Skip_CDA_Triggers__c){
            return;
        }
        List<CDA_Account__c> cdaAccountListtoUpdate = new List<CDA_Account__c>();
        Set<Id> recAccIdSet = new Set<Id>();
        for(CDA_Request__c cdaReq: records){
            if(cdaReq.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED){
                recAccIdSet.add(cdaReq.Recipient_Account__c);
            }
        }
        
        Map<Id, CDA_Account__c> cdaAccMap = new Map<Id, CDA_Account__c>([Select Id, Individual_Indicator__c from CDA_Account__c where Id IN :recAccIdSet]);
        
        for(CDA_Request__c cdaReq: records){
            if(cdaReq.Recipient_Account__c != null && cdaReq.Individual_Indicator__c != null){
                if(cdaAccMap.get(cdaReq.Recipient_Account__c) != null && cdaAccMap.get(cdaReq.Recipient_Account__c).Individual_Indicator__c == null){
                    CDA_Account__c cdaAcc = cdaAccMap.get(cdaReq.Recipient_Account__c);
                    cdaAcc.Individual_Indicator__c = cdaReq.Individual_Indicator__c;
                    cdaAccountListtoUpdate.add(cdaAcc);
                }
            }
        }
        
        if(!cdaAccountListtoUpdate.isEmpty()){
            try{
                update cdaAccountListtoUpdate;
            }Catch(Exception ex){
                System.debug('An Exception has occured while updating CDA Account: ' + ex.getCause() + 'detail----> ' + ex.getStackTraceString());
            }
        }
    }
}