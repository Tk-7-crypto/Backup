/**
* Created by Ronak Mehta on 25-Mar-2025
* Description : Contain common Methods to support LWC componet: lwcCrmOpportunityRenewalDashboard and lwcCrmOpportunityRenewalCloneOption
**/
public class CNT_CRM_OpportunityRenewalDashboard {
    
    /**
     * This Method retrive RenewalTask and change Details Record.
     * @params String additionalFilter
     * @return List<renewalTaskWrapper>
     **/
    @AuraEnabled(Cacheable=false)
    public static List<renewalTaskWrapper> generateRenewalTaskJson(String additionalFilter){
        if(additionalFilter == null)
            additionalFilter = '  ';
        Set<String> oppStages = new Set<String>{CON_CRM_OpportunityRenewals.OPP_STAGE_6A, CON_CRM_OpportunityRenewals.OPP_STAGE_IN_HAND, CON_CRM_OpportunityRenewals.OPP_STAGE_6B};
            Id userId = userInfo.getUserId();
        String NO_RENEW_STATUS_STR = CON_CRM_OpportunityRenewals.NO_RENEW_STATUS_STR;
        //CurrencyIsoCode, ownerId,
        String q = 'Select Id, Name, Round_Up__c, Price_Increase__c, Cloning_Action__c, Cloning_Status__c, Cloned_Opportunity__c, Cloned_Opportunity__r.name, Cloned_Opportunity__r.Opportunity_Number__c, Cloned_Opportunity__r.StageName, '+
            ' Targeted_Close_Date__c, Owner_Country__c, No_Renew_Reason__c, Data_Period_Shift__c, Opportunity__r.account.name, Opportunity__r.name, Opportunity__r.C_S_Contract_Value__c, Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c, '+
            ' Opportunity__r.Contract_Type__c, Opportunity__r.CloseDate, Opportunity__r.Actual_Close_Date__c, Opportunity__r.CurrencyIsoCode, Opportunity__r.Opportunity_Number__c, Opportunity__r.Parent_Opportunity__c,  Opportunity__r.Parent_Opportunity__r.name, '+
            ' (Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c, Dropped_Reason__c, Product_Invoice_Text__c, Billing_Frequency__c, Data_Month_End__c, Data_Month_Start__c, Proj_Rpt_Frequency__c, Territory__c, Delivery_Media__c, Revenue_Type__c, Sale_Type__c, '+
            ' Previous_Contract_Value__c, Type__c, TotalPrice__c, Winback__c From Renewal_Task_Change_Details__r) Opportunity__c, Opportunity__r.id  from Renewal_Task__c where ownerId = :userId '+
            ' and Cloned_Opportunity__r.StageName not in :oppStages and Cloning_Status__c != :NO_RENEW_STATUS_STR AND Is_Removed__c = false '+ additionalFilter +
            ' order by Opportunity__r.Contract_End_Date__c ASC Limit 200';
        List<Renewal_Task__c> listOfRenewal_Task = Database.query(q);
        
        List<Renewal_Task_Change_Detail__c> taskChangeDetailList = new List<Renewal_Task_Change_Detail__c> ();
        Map<String, Renewal_Task_Change_Detail__c> OliIdRtChangeDetailMap = new Map<String, Renewal_Task_Change_Detail__c> ();
        Map<String, Renewal_Task__c> rtIdMap = new Map<String, Renewal_Task__c> ();
        Map<Id, List<OpportunityLineItem>> oppIdLineItemsMap = new Map<Id, List<OpportunityLineItem>> ();
        
        Set<Id> setOpportunityIds = new Set<Id>();
        Boolean isInnerGridPresent = false;
        for(Renewal_Task__c renewaltsak :listOfRenewal_Task) {
            setOpportunityIds.add(renewaltsak.Opportunity__c);
            taskChangeDetailList.addAll(renewaltsak.Renewal_Task_Change_Details__r);  
            rtIdMap.put('' + renewaltsak.id , renewaltsak );          
        }
        for(Renewal_Task_Change_Detail__c changeDetail : taskChangeDetailList) {
            OliIdRtChangeDetailMap.put('' + changeDetail.Opportunity_Line_Item_Id__c, changeDetail);
        }
        List<OpportunityLineItem> listOfOpportunityLineItem = [SELECT Id, PricebookEntry.ProductCode, PricebookEntry.Name, TotalPrice, OpportunityId, Business_Type__c, Product_Start_Date__c, Product_End_Date__c, Sale_Type__c, Revenue_Type__c, Delivery_Country__c, Proj_Rpt_Frequency__c,
                                                               Winback__c, Billing_Frequency__c, Delivery_Media__c, Revised_Price__c, Output_Format__c,  (SELECT Id, Revenue FROM OpportunityLineItemschedules) FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityIds];
        
        for(OpportunityLineItem queryOLI : listOfOpportunityLineItem) {
            List<OpportunityLineItem> listQueryLIs = oppIdLineItemsMap.get(queryOLI.OpportunityId);
            if(listQueryLIs == null) {
                listQueryLIs = new List<OpportunityLineItem> ();
                oppIdLineItemsMap.put(queryOLI.OpportunityId, listQueryLIs);
                
            }
            listQueryLIs.add(queryOLI);
        }
        
        List<renewalTaskWrapper> renewalTaskWrapperList = new List<renewalTaskWrapper>();
        String RenewalTaskJson = '';
        if(listOfRenewal_Task.size() > 0){
            for( Renewal_Task__c renewalTask : listOfRenewal_Task ){
                renewalTaskWrapper rtw = new renewalTaskWrapper();
                rtw.id = renewalTask.Id;
                rtw.name = renewalTask.Name;
                rtw.oppName= renewalTask.Opportunity__r.name;
                rtw.dataPeriodShift= (renewalTask.Data_Period_Shift__c != null)? String.valueOf(renewalTask.Data_Period_Shift__c) : '';
                rtw.roundup_action= renewalTask.Round_Up__c;
                rtw.contractValue=  (renewalTask.Opportunity__r.Amount  != null) ? renewalTask.Opportunity__r.Amount : 0.0;
                rtw.accName= renewalTask.Opportunity__r.Account.Name;
                rtw.acc_Id= renewalTask.Opportunity__r.AccountId;
                rtw.oppNum= (renewalTask.Opportunity__r.Opportunity_Number__c != null) ? renewalTask.Opportunity__r.Opportunity_Number__c : '';
                rtw.oppId= (renewalTask.Opportunity__r.id != null ) ? renewalTask.Opportunity__r.id : '';
                rtw.contractEndDate= (renewalTask.Opportunity__r.Contract_End_Date__c != null) ? renewalTask.Opportunity__r.Contract_End_Date__c : null;
                //getFormatedDate(renewalTask.Opportunity__r.Contract_End_Date__c,'-',DateFormats.MMDDYY)
                rtw.contractType= (renewalTask.Opportunity__r.Contract_Type__c != null) ? renewalTask.Opportunity__r.Contract_Type__c : '';
                rtw.currencyCode= (renewalTask.Opportunity__r.CurrencyIsoCode != null) ? renewalTask.Opportunity__r.CurrencyIsoCode : '';
                if((renewalTask.Cloning_Status__c != null && renewalTask.Cloned_Opportunity__c != null && renewalTask.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B) || (renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_RENEW_STR)))
                    rtw.cloning_action = '1';
                else if(renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_CHANGE_STR))
                    rtw.cloning_action = '2';
                else if(renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR))
                    rtw.cloning_action = '3';   
                else
                    rtw.cloning_action = '';
                rtw.closeDate = (renewalTask.Targeted_Close_Date__c != null) ? renewalTask.Targeted_Close_Date__c : null;
                //getFormatedDate(renewalTask.Targeted_Close_Date__c,'-',DateFormats.MMDDYY)
                rtw.price_inc = (renewalTask.Price_Increase__c != null)  ? (renewalTask.Price_Increase__c/100) : 0.0;
                rtw.clonned_opportunity_id= (renewalTask.Cloned_Opportunity__c != null) ? String.valueOf(renewalTask.Cloned_Opportunity__c) : '';
                rtw.clonned_opportunity= (renewalTask.Cloned_Opportunity__c != null) ? renewalTask.Cloned_Opportunity__r.name : '';
                rtw.clonned_opportunity_num= (renewalTask.Cloned_Opportunity__c != null) ? renewalTask.Cloned_Opportunity__r.Opportunity_Number__c : '';
                rtw.noRenewComment= (renewalTask.No_Renew_Reason__c != null) ? renewalTask.No_Renew_Reason__c : '';
                if(renewalTask.Cloning_Status__c != null){
                    if(renewalTask.Cloned_Opportunity__c != null && renewalTask.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B){
                        rtw.cloning_status = CON_CRM_OpportunityRenewals.NEEDS_NO_RENEW_REASON_STR;
                    } else
                        rtw.cloning_status = renewalTask.Cloning_Status__c;
                } else
                    rtw.cloning_status = '';
                
                rtw.org_pri_opp = (renewalTask.Opportunity__r.Parent_Opportunity__c != null ) ? renewalTask.Opportunity__r.Parent_Opportunity__r.name : '' ;
                rtw.org_pri_opp_id = (renewalTask.Opportunity__r.Parent_Opportunity__c != null ) ? String.valueOf(renewalTask.Opportunity__r.Parent_Opportunity__c) : '';
                
                List<renewalTaskDetailWrapper> innerGridRecordList = new List<renewalTaskDetailWrapper>();
                List<OpportunityLineItem> oppLineItemsList = oppIdLineItemsMap.get(renewalTask.Opportunity__r.id);
                if(oppLineItemsList != null){
                    for(OpportunityLineItem OlI : oppLineItemsList) {
                        renewalTaskDetailWrapper innerGridRecord = new renewalTaskDetailWrapper();
                        if(renewalTask.Opportunity__c == OlI.OpportunityId){
                            Renewal_Task_Change_Detail__c cDetail = OliIdRtChangeDetailMap.get(OlI.id);
                            Boolean isDetailPresent = false;
                            if(cDetail != null){
                                isDetailPresent = true;
                                innerGridRecord.renewalTaskDetailId= cDetail.Id;
                            }
                            isInnerGridPresent = true;
                            innerGridRecord.id= OlI.Id;
                            innerGridRecord.sapCode= OlI.PricebookEntry.ProductCode;
                            innerGridRecord.productName= OlI.PricebookEntry.Name;
                            innerGridRecord.businessType= (OlI.Business_Type__c != null) ? OlI.Business_Type__c : '';
                            innerGridRecord.dataPeriodStart= (OlI.Product_Start_Date__c != null) ? OlI.Product_Start_Date__c : null;
                            innerGridRecord.dataPeriodEnd= (OlI.Product_End_Date__c != null) ? OlI.Product_End_Date__c : null;
                            innerGridRecord.saleType= (OlI.Sale_Type__c != null)? OlI.Sale_Type__c : '';
                            innerGridRecord.revenueType= (OlI.Revenue_Type__c != null) ? OlI.Revenue_Type__c : '';
                            innerGridRecord.delivery_cnty= (OlI.Delivery_Country__c != null) ? OlI.Delivery_Country__c : '';
                            innerGridRecord.rpt_freq= (OlI.Proj_Rpt_Frequency__c != null) ? OlI.Proj_Rpt_Frequency__c : '';
                            innerGridRecord.winback= (OlI.Winback__c != null) ? String.valueOf(OlI.Winback__c) : '' ;
                            innerGridRecord.bill_freq= (OlI.Billing_Frequency__c != null) ? OlI.Billing_Frequency__c : '';
                            innerGridRecord.del_media= (OlI.Delivery_Media__c != null) ? OlI.Delivery_Media__c : '';
                            innerGridRecord.outputFormat= (OlI.Output_Format__c != null) ? OlI.Output_Format__c : '';
                            innerGridRecord.value= (OlI.TotalPrice != null) ? String.valueOf(OlI.TotalPrice) : '';
                            innerGridRecord.currencyIsoCode= (renewalTask.Opportunity__r.CurrencyIsoCode != null) ? renewalTask.Opportunity__r.CurrencyIsoCode : '';
                            
                            if(isDetailPresent ) {
                                String comment = cDetail.Dropped_Reason__c;
                                if(comment != null && comment != '') {
                                    innerGridRecord.comment= cDetail.Dropped_Reason__c;
                                    innerGridRecord.status= 'dropped';
                                } else {
                                    innerGridRecord.status= CON_CRM_OpportunityRenewals.CLONED_STATUS_STR;
                                    innerGridRecord.comment= '';
                                }
                            } else{
                                innerGridRecord.status = '';
                            }
                        }
                        innerGridRecordList.add(innerGridRecord);
                    }
                    rtw.innerGridRecords = innerGridRecordList;
                }else{
                    rtw.innerGridRecords = new List<renewalTaskDetailWrapper>();
                }
                renewalTaskWrapperList.add(rtw);
            }
        }
        return renewalTaskWrapperList;
    }
    
    /**
     * This Method retrive RenewalTask and change Details Record based on Additional additionalFilte.
     * @return List<renewalTaskWrapper>
     **/
    @AuraEnabled(Cacheable=false)
    public static List<renewalTaskWrapper> searchRenwalTasks(String sOppNumber, String sOppName, String sAccName, String sPOppName, String sPOppNumber){
        String additionalFilter = ' ';
        if(sOppNumber != null && sOppNumber != '')
            additionalFilter += 'AND Opportunity__r.Opportunity_Number__c like \'%'+ sOppNumber + '%\' ';
        if(sOppName != null && sOppName !='')
            additionalFilter += 'AND Opportunity__r.Name like \'%'+ sOppName + '%\' ';
        if(sAccName != null && sAccName !='')
            additionalFilter += 'AND Opportunity__r.Account.Name like \'%'+ sAccName + '%\' ';
        if(sPOppName != null && sPOppName != '')
            additionalFilter += 'AND Opportunity__r.Parent_Opportunity__r.Name  like \'%'+ sPOppName + '%\' ';
        if(sPOppNumber != null && sPOppNumber != '')
            additionalFilter += 'AND Opportunity__r.Parent_Opportunity__r.Opportunity_Number__c  like \'%'+ sPOppNumber + '%\' ';
        return generateRenewalTaskJson(additionalFilter);
    }
    
    /**
     * This Method used to remove Renewal Task from LWC screen to be appear
     * @params List<String> renewalTaskToDeactivate
     * @return String
     **/
    @AuraEnabled(Cacheable=false)
    public static String deactiveRenewalTask(List<String> renewalTaskToDeactivate){
        try{
            List<Renewal_Task__c> renewalTaskToDeactiveList = new List<Renewal_Task__c>();
            for(String strId :renewalTaskToDeactivate){
                renewalTaskToDeactiveList.add(new Renewal_Task__c(Id = strId, Is_Removed__c = true));
            }
            update renewalTaskToDeactiveList;
            return 'true';
        }catch(Exception ex){
            system.debug(ex.getMessage());
            return ex.getMessage();
        }
    }
    
    /**
     * This Method used to reassign Renewal Task to other User
     * @params List<String> renewalTaskToDeactivate
     * @return String
     **/
    @AuraEnabled(Cacheable=false)
    public Static String reassignRenewalTask(String reassignUserId, List<String> renewalTaskIdToReassigne){
        try{
            List<Renewal_Task__c> renewalTaskListToReassigne = new List<Renewal_Task__c>();
            for(String strId :renewalTaskIdToReassigne){
                renewalTaskListToReassigne.add(new Renewal_Task__c(Id = strId, OwnerId = reassignUserId));
            }
            update renewalTaskListToReassigne;
            return 'true';
        }catch(Exception ex){
            system.debug(ex.getMessage());
            return ex.getMessage();
        }
    }
    
    /**
     * This Method used to Search User to assign Renewal Task
     * @params String searchKey
     * @return List<UTL_LookupSearchResult>
     **/
    @AuraEnabled(Cacheable=true)
    public static List<UTL_LookupSearchResult> findUsersBySearchKey(String searchKey){
        searchKey = '%' + searchKey + '%';
        List<User> userList =  Database.query('SELECT id, Name FROM User WHERE Name Like: searchKey AND IsActive = true');
        List<UTL_LookupSearchResult> lookupSearchResultList = new List<UTL_LookupSearchResult>();
        String userIcon = 'standard:user';
        for(User u: userList){
            lookupSearchResultList.add(new UTL_LookupSearchResult(u.Id, 'User', userIcon, u.Name, 'User'));
        }
        lookupSearchResultList.sort();
        return lookupSearchResultList;
    }
    
    /**
     * This Method used to reassign Renewal Task to other User
     * @params Renewal_Task__c rt
     * @params List<Renewal_Task_Change_Detail__c> rtcdList
     * @return String
     **/
    @AuraEnabled(Cacheable=false)
    public static String handleSubmit(Renewal_Task__c rt, List<Renewal_Task_Change_Detail__c> rtcdList){
        List<Renewal_Task_Change_Detail__c> changeDetailsForClone = new List<Renewal_Task_Change_Detail__c>();
        if(rt != null && rt.Id != null){
            if(rt.Cloning_Status__c == 'No Renew'){
                rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_RENEW_STR;
                rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.NO_RENEW_STATUS_STR ;//'No Renew';
            }
            if(rt.Cloning_Status__c == 'Basic Clone'){
                rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_CHANGE_STR;
                rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR;//'queued';
            }
            if(rt.Cloning_Status__c == 'Detail Clone'){
                rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR;
                rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR;//'Awaiting Details';
            }
        }
        if(rtcdList != null && rtcdList.size() > 0){
            Set<String> retiredSapCodes = new Set<String>();
            Map<String, Product_Replacement_Mapping__c> prodReplacementMap = new Map<String, Product_Replacement_Mapping__c>(); 
            Set<Id> selectedDetailsIdSet = new Set<Id>();
            for(Renewal_Task_Change_Detail__c selDetail : rtcdList ) {
                selectedDetailsIdSet.add(selDetail.Opportunity_Line_Item_Id__c);
            } 
            Map<Id, OpportunityLineItem> oppLineItemIdMap = new Map<Id, OpportunityLineItem>([SELECT Id, Business_Type__c, Product_Invoice_Text__c, Sales_Text__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.IsActive, Output_Format__c,Revised_Price__c,
                                                                                              Configured_Product__c, TotalPrice, Product_Start_Date__c, Product_End_Date__c, Billing_Frequency__c, Sale_Type__c, Winback__c, Revenue_Type__c,Delivery_Country__c, Delivery_Media__c, Proj_Rpt_Frequency__c, PricebookEntry.ProductCode,
                                                                                              (SELECT Id, revenue FROM OpportunityLineItemschedules) FROM OpportunityLineItem WHERE Id IN :selectedDetailsIdSet]);
            
            for(Renewal_Task_Change_Detail__c changeDetail: rtcdList){
                OpportunityLineItem Li = oppLineItemIdMap.get(changeDetail.Opportunity_Line_Item_Id__c);
                if(!Li.PricebookEntry.Product2.IsActive) {
                    retiredSapCodes.add(Li.PricebookEntry.Product2.ProductCode);
                }
            }
            if(!retiredSapCodes.isEmpty()){
                List<Product_Replacement_Mapping__c> tempList = [SELECT Retired_Product_SAP_Code__c, Replacement_Product_SAP_Code__c, Replacement_Product__r.Name FROM Product_Replacement_Mapping__c WHERE Retired_Product_SAP_Code__c in : retiredSapCodes];
                for(Product_Replacement_Mapping__c prRpRec : tempList){
                    prodReplacementMap.put(prRpRec.Retired_Product_SAP_Code__c, prRpRec);
                }
            }
            for(Renewal_Task_Change_Detail__c changeDetail: rtcdList){
                OpportunityLineItem Li = oppLineItemIdMap.get(changeDetail.Opportunity_Line_Item_Id__c);
                changeDetail.TotalPrice__c = Li.totalPrice;
                changeDetail.Previous_Contract_Value__c = Li.totalPrice;
                changeDetail.Billing_Frequency__c = Li.Billing_Frequency__c;
                changeDetail.Sale_Type__c = 'Repeat';
                changeDetail.Revenue_Type__c = Li.Revenue_Type__c;
                changeDetail.Territory__c = Li.Delivery_Country__c;
                changeDetail.Winback__c = (Li.Winback__c == false)? 'No': 'Yes';
                changeDetail.Delivery_Media__c = Li.Delivery_Media__c;
                changeDetail.Proj_Rpt_Frequency__c = Li.Proj_Rpt_Frequency__c;
                changeDetail.CurrencyIsoCode = rt.CurrencyIsoCode ;
                changeDetail.ProductCode__c = Li.PricebookEntry.Product2.ProductCode;
                changeDetail.Product_Name__c = Li.PricebookEntry.Product2.Name;
                changeDetail.Output_Format__c = Li.Output_Format__c;
                changeDetail.Product_Invoice_Text__c = LI.Sales_Text__c != null ? LI.Sales_Text__c : LI.Product_Invoice_Text__c;
                changeDetail.Type__c = (changeDetail.Dropped_Reason__c != null) ? 'Dropped':'Renewed';
                changeDetail.Data_Month_Start__c = Li.Product_Start_Date__c;
                changeDetail.Data_Month_End__c = Li.Product_End_Date__c;
                
                Product_Replacement_Mapping__c prRpRe  = null;
                if(prodReplacementMap.size() > 0) {
                    prRpRe  =  prodReplacementMap.get(Li.PricebookEntry.Product2.ProductCode);
                    if(prRpRe != null){
                        changeDetail.ProductCode__c = prRpRe.Replacement_Product_SAP_Code__c;
                        changeDetail.Product_Name__c = prRpRe.Replacement_Product__r.Name;
                    }
                }
                if(!Li.PricebookEntry.Product2.IsActive && prRpRe == null ) {
                    changeDetail.Dropped_Reason__c = 'Material no longer active';
                }
                if((rt.Owner_Country__c != null && rt.Owner_Country__c.toUpperCase() == 'UK') || (!Li.Configured_Product__c)) {
                    if(Li.Revised_Price__c != null && rt.Data_Period_Shift__c > 0) {
                        Integer dataPeriod = 0 ;
                        if(Li.Product_Start_Date__c != null) {
                            dataPeriod = Li.Product_Start_Date__c.monthsBetween(Li.Product_End_Date__c);
                            if(dataPeriod < 0 ) dataPeriod *= -1;
                            Integer monthsBasedOnDaysDiff = Li.Product_Start_Date__c.daysBetween(Li.Product_End_Date__c)/30 ;
                            if (monthsBasedOnDaysDiff > dataPeriod){
                                dataPeriod = monthsBasedOnDaysDiff;
                            }
                        }
                        
                        if(dataPeriod != 0) {
                            Decimal monthlyPrice = Li.Revised_Price__c/dataPeriod;
                            changeDetail.TotalPrice__c = monthlyPrice * dataPeriod  * ( 1 + (rt.Price_Increase__c/100));
                        } else {
                            changeDetail.TotalPrice__c = Li.Revised_Price__c * ( 1 + (rt.Price_Increase__c/100));
                        }
                        
                    } else {
                        changeDetail.TotalPrice__c = Li.totalPrice + (Li.totalPrice * (rt.Price_Increase__c/100) );
                    }
                }
                
                //Detail Clone - Round up is true then calculate revenues for Awaiting Details page total price update
                if(rt.Round_Up__c == true && rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR) {
                    Decimal roundupTotalPrice = 0;
                    for(OpportunityLineItemSchedule olis : li.OpportunityLineItemschedules) {
                        roundupTotalPrice += ((1 + ((changeDetail.TotalPrice__c - li.TotalPrice)/li.TotalPrice) ) * olis.Revenue).round(System.RoundingMode.CEILING);
                    }
                    changeDetail.Expect_Round_up_Total_Price__c = roundupTotalPrice;
                }
                
                //use data period shift for start date and end date shifting
                if(Li.Revenue_Type__c == 'Subscription' && rt.Data_Period_Shift__c > 0){
                    if(Li.Product_End_Date__c != null)
                        changeDetail.Data_Month_End__c = Li.Product_End_Date__c.addMonths( Integer.valueOf(rt.Data_Period_Shift__c + '') );
                    if(Li.Product_Start_Date__c != null) {
                        changeDetail.Data_Month_Start__c = Li.Product_Start_Date__c.addMonths(Integer.valueOf(rt.Data_Period_Shift__c + ''));
                    }
                }
                if(changeDetail.Id == null){//if inserting record then only Populate Master field
                    changeDetail.Renewal_Task__c = rt.Id;   
                }
                changeDetail.CurrencyIsoCode = rt.CurrencyIsoCode;
            }
        }
        SavePoint sp = Database.setSavePoint();
        try{
            update rt;
            upsert rtcdList;
        }catch(Exception Ex){
            database.rollback(sp);
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            system.debug(rtcdList.size());
            system.debug(rtcdList[0].get('Id'));
            return 'Server error occured while processing your request. (' + ex.getMessage() + ')';
        }
        return 'true';
    }
    
    public Class renewalTaskWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String oppName;
        @AuraEnabled public String dataPeriodShift;
        @AuraEnabled public Boolean roundup_action;
        @AuraEnabled public Double contractValue;
        @AuraEnabled public String accName;
        @AuraEnabled public String acc_Id;
        @AuraEnabled public String oppNum;
        @AuraEnabled public String oppId;
        @AuraEnabled public Date contractEndDate;
        @AuraEnabled public String contractType;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String org_pri_opp;
        @AuraEnabled public String org_pri_opp_id;
        @AuraEnabled public String cloning_action;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public Double price_inc;
        @AuraEnabled public String clonned_opportunity_id;
        @AuraEnabled public String clonned_opportunity;
        @AuraEnabled public String clonned_opportunity_num;
        public String noRenewComment;// no more needed as noRenew records are not shown on page
        @AuraEnabled public String cloning_status;
        @AuraEnabled public List<renewalTaskDetailWrapper> innerGridRecords;
    }
    
    public Class renewalTaskDetailWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String renewalTaskDetailId;
        @AuraEnabled public String sapCode;
        @AuraEnabled public String productName;
        @AuraEnabled public String businessType;
        @AuraEnabled public Date dataPeriodStart;
        @AuraEnabled public Date dataPeriodEnd;
        @AuraEnabled public String saleType;
        @AuraEnabled public String revenueType;
        @AuraEnabled public String delivery_cnty;
        public String rpt_freq;//no use-case found ultimate fetching value from OLI
        public String winback;//no use-case found ultimate fetching value from OLI
        public String bill_freq;//no use-case found
        public String del_media;//no use-case found
        public String outputFormat;//no use-case found
        @AuraEnabled public String comment;
        @AuraEnabled public String status;
        @AuraEnabled public String value;
        @AuraEnabled public String currencyIsoCode;
    }
}