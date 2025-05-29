//********      
//  IMS 

//  Created by Anjali Salecha on 12-July-2010
//  Abstract class contain common methods and abstract methods to create Opportunity clone with diffrent buisness logics
//*******

public abstract class INT_CRM_OpportunityRenewals {
    
    /////************  Properties   *************/////////////
    
     public Map<String,Schema.SObjectType> globalDescribe{get;set;}
     public Map<string,string> mapObjectNameAndSelectQuery{get;set;}


     public Map<String, id > prodCodeCurrCodePbEntryMap ;
    
    
    /////************  Abstract Methods   *************/////////////
    
    //Abstract method to set Stage field of Opportunity clone.
    //This method will be override by its extended classes according to the buisness rule.
    public abstract void SetStageField(Opportunity cloneOpportunity, Renewal_Task__c rt);
    
    
    /////************  Methods  *************/////////////    
    
    //Common method to set name of Opportunity clone
    // Method will be change as per the document 
    public void SetRenewalName(Opportunity cloneOpportunity)
    {
        Renewal_Dashboard_Settings__c R = Renewal_Dashboard_Settings__c.getOrgDefaults();
        String PreviousRenewalYear = String.valueOf(R.Renewal_Year__c.round()-1);
        String CurrentRenewalYear = String.valueOf(R.Renewal_Year__c.round());
        string RenewalName = cloneOpportunity.Name;
        if (Pattern.matches('.*(?i)(renewal '+ PreviousRenewalYear +').*', RenewalName))
        {
            cloneOpportunity.Name = RenewalName .replaceAll('(?i)renewal '+PreviousRenewalYear,'Renewal ' + CurrentRenewalYear);
        }
        else
        {
            cloneOpportunity.Name = RenewalName + ' Renewal '+ CurrentRenewalYear;
        }
    }
    
    //Common method to set ExpectedCloseDate of Opportunity clone
    public void SetExpectedCloseDate(Opportunity cloneOpportunity)
    {
        cloneOpportunity.CloseDate = cloneOpportunity.CloseDate;
    }
    
    public void SetOppProbability(Opportunity cloneOpportunity) {
        cloneOpportunity.probability = 50;
    }
    
    public void SetOppRenewalTask(Opportunity cloneOpportunity, Renewal_Task__c renewalTask ) {
        cloneOpportunity.Renewal_Task__c = renewalTask.id;
    }
    
    //Method to set diffrent field of Opportunity clone if user change the ExpectedCloseDate value
    public void SetCloneOpportunityFieldsIfTargetedCloseDateChanged(Opportunity cloneOpportunity,Opportunity originalOpportunity,Renewal_Task__c renewalTask)
    {
        cloneOpportunity.Contract_Term__c = 'Multi-Period';
        if(!originalOpportunity.CloseDate.isSameDay(renewalTask.Targeted_Close_Date__c))
            cloneOpportunity.CloseDate = renewalTask.Targeted_Close_Date__c;
    }
    
    public void SetClonedOpportunityLineItemFields(OpportunityLineItem clonedOppLineItem,Opportunity originalOpportunity,Renewal_Task__c renewalTask, Renewal_Task_Change_Detail__c cd )
    {
        //clonedOppLineItem.Sale_Type__c = 'Repeat';
        /*if(clonedOppLineItem.Revenue_Type__c == 'Subscription' )
            && !originalOpportunity.CloseDate.isSameDay(renewalTask.Targeted_Close_Date__c))
        {
            Integer dayDiffrence = originalOpportunity.CloseDate.daysBetween(renewalTask.Targeted_Close_Date__c); 
            if(clonedOppLineItem.Product_Start_Date__c != null)
                clonedOppLineItem.Product_Start_Date__c = clonedOppLineItem.Product_Start_Date__c.addDays(dayDiffrence);
            if(clonedOppLineItem.Product_End_Date__c != null) 
                clonedOppLineItem.Product_End_Date__c = clonedOppLineItem.Product_End_Date__c.addDays(dayDiffrence);
        }//*/
        /*if(clonedOppLineItem.Revenue_Type__c == 'Subscription' && renewalTask.Data_Period_Shift__c > 0){
            if(clonedOppLineItem.Product_Start_Date__c != null)
                clonedOppLineItem.Product_Start_Date__c = clonedOppLineItem.Product_Start_Date__c.addMonths(Integer.valueOf(renewalTask.Data_Period_Shift__c + ''));
            if(clonedOppLineItem.Product_End_Date__c != null) 
                clonedOppLineItem.Product_End_Date__c = clonedOppLineItem.Product_End_Date__c.addMonths( Integer.valueOf(renewalTask.Data_Period_Shift__c + '') );
        }//*/
        List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.OpportunityLineItem.FieldSets.OLI_Clone_Fields_Exclude.getFields();
        Set<String> excludeOLIFieldsSet = new Set<String>();
        for(Schema.FieldSetMember setMember : fieldSetMemberList) {
            if(String.valueOf(setMember.getType()) == 'Boolean'){
                clonedOppLineItem.put(setMember.getFieldPath(),false);
            }else{
                clonedOppLineItem.put(setMember.getFieldPath(),null);
            }
        }
        clonedOppLineItem.Revised_Price__c = null;
        //set rest of the captured info in change detail here for line items
        if(cd != null){
            clonedOppLineItem.Billing_Frequency__c = cd.Billing_Frequency__c;
            clonedOppLineItem.Sale_Type__c = cd.Sale_Type__c;
            clonedOppLineItem.Revenue_Type__c = cd.Revenue_Type__c;
            clonedOppLineItem.Delivery_Country__c = cd.Territory__c;
            if(cd.Winback__c == 'No')
                clonedOppLineItem.Winback__c = false;
            else
                clonedOppLineItem.Winback__c = true;
            clonedOppLineItem.Delivery_Media__c = cd.Delivery_Media__c;
            clonedOppLineItem.Proj_Rpt_Frequency__c = cd.Proj_Rpt_Frequency__c;

            clonedOppLineItem.Product_Start_Date__c = cd.Data_Month_Start__c;
            clonedOppLineItem.Product_End_Date__c = cd.Data_Month_End__c;
            clonedOppLineItem.Sale_Type__c = cd.Sale_Type__c;
            clonedOppLineItem.TotalPrice = cd.TotalPrice__c;
            clonedOppLineItem.Output_Format__c = cd.Output_Format__c;
            clonedOppLineItem.Product_Invoice_Text__c = cd.Product_Invoice_Text__c;
            clonedOppLineItem.Sales_Text__c = cd.Product_Invoice_Text__c;
            System.debug('Renewal_Task__r.CurrencyIsoCode = ' + cd.Renewal_Task__r.CurrencyIsoCode + ' cd.ProductCode__c = ' + cd.ProductCode__c);            
            clonedOppLineItem.PricebookEntryId = prodCodeCurrCodePbEntryMap.get(cd.ProductCode__c + '_'+ cd.Renewal_Task__r.CurrencyIsoCode);
            
            
            //Update by Himanshu : 3-June-2013 : Issue-02199
            clonedOppLineItem.Revenue_Dynamics__c=cd.id;
            System.debug('###1111###');
        }
    }
    
    public void SetClonedOpportunityLineItemScheduleFields(OpportunityLineItemSchedule clonedOppLineItemSchedule,Opportunity originalOpportunity,Renewal_Task__c renewalTask
                                                            ,Renewal_Task_Change_Detail__c cd, OpportunityLineItem originalLineItem)
    {
        /*if(!originalOpportunity.CloseDate.isSameDay(renewalTask.Targeted_Close_Date__c))
           clonedOppLineItemSchedule.ScheduleDate = clonedOppLineItemSchedule.ScheduleDate.addDays(originalOpportunity.CloseDate.daysBetween(renewalTask.Targeted_Close_Date__c));
           //*/
        if(originalLineItem.TotalPrice != 0) {
            clonedOppLineItemSchedule.Revenue = (1 + ((cd.TotalPrice__c - originalLineItem.TotalPrice)/originalLineItem.TotalPrice) )* clonedOppLineItemSchedule.Revenue;
            if(renewalTask.Round_Up__c == true && (renewalTask.Cloning_Action__c == CON_CRM_OpportunityRenewals.NO_CHANGE_STR || renewalTask.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR)) {
                clonedOppLineItemSchedule.Revenue =  clonedOppLineItemSchedule.Revenue.round(System.RoundingMode.CEILING);
            }
        }
        if(renewalTask.Data_Period_Shift__c > 0)
            clonedOppLineItemSchedule.ScheduleDate = clonedOppLineItemSchedule.ScheduleDate.addMonths(Integer.valueOf(renewalTask.Data_Period_Shift__c));
    }
    
    public string GenerateSelectQueryWithAllFields(string ObjectName)
    {
        if (ObjectName == 'Opportunity') {
            String selectQuery = 'Select AccountId,Name,Description,StageName,Probability,CloseDate,Type,NextStep,LeadSource,CurrencyIsoCode,CampaignId,Pricebook2Id,OwnerId,Territory2Id,FiscalQuarter,FiscalYear,Fiscal,Parent_Opportunity__c,Budget_Available__c,Principle_inCharge__c,Therapy_Area__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Term__c,Contract_Type__c,CEQActiveRelease__c,SAP_Master_Contract__c,Id,Legacy_IMS_Opportunity_Number__c,Lead_Source_Detail__c,Drug_Product_Name__c from Opportunity ';
            //Fields not available on IQVIA so commented out
            //Accrual_Flag__c,Accrual_Flag_Date__c,Accrual_Flag_Set_By__c,Strategy__c,Acct_Plan_del__c,Brand__c,Other_Competitor__c,Partner__c,Threshold_History__c,Threshold_Reason__c,Compelling_Event__c,Unique_Business_Value__c,Deal_Type__c,Source_Sub_Category__c,Source_Description__c,Patient_level_Data__c,Doctor_level_Data__c,Unique_Doctor_Records__c,Sales_Representatives__c,Doctor_Rate__c,Sales_Rep_Rate__c,PIC_Email__c,PIC_User__c,Prior_Amount__c,Threshold_Flag__c,Threshold_Trigger__c,Bid_Team__c,Bid_Team_User__c,PIC_Entity__c,PIC_Sales_Org__c,IMS_Region__c,Business_Type_Name__c,DEPT__c,Opportunity_Number__c,Budget_Holder__c,Main_Decision_Maker__c
            return selectQuery;
        } else if (ObjectName == 'OpportunityLineItem') {                    
            String selectQuery = 'select Id,OpportunityId,SortOrder,PricebookEntryId,CurrencyIsoCode,Quantity,ListPrice,ServiceDate,Description,Service_Line__c,Delivery_Country__c,Discount_Amount__c,Business_Line__c,Business_Type__c,Practice_Area__c,SubPractice_Area__c,Delivery_Media__c,Nbr_of_Users__c,Product_Start_Date__c,Product_End_Date__c,Discount_Reason__c,Invoice_Date__c,Other_Ship_To__c,Cancel__c,Revised_Price__c,Cancel_Text__c,Output_Format__c,Sale_Type__c,Revenue_Type__c,TotalPrice,Product_Invoice_Text__c,Sales_Text__c,Therapy_Area__c from OpportunityLineItem ';
            //Fields not available on IQVIA so commented out
            //Net_Price__c,Book_No__c,Revenue_Comments__c,Billing_Frequency__c,Production_Reference__c
            return selectQuery;
        } else {
            String selectQuery = 'Select ';
            if(globalDescribe == null)
                    globalDescribe = Schema.getGlobalDescribe();
            if(mapObjectNameAndSelectQuery == null)        
                mapObjectNameAndSelectQuery = new map<string,string>();
            
            if(!mapObjectNameAndSelectQuery.containsKey(ObjectName) && mapObjectNameAndSelectQuery.size() < 11)
            {   
                Schema.SObjectType systemObjectType = globalDescribe.get(ObjectName);    
                if(systemObjectType != null)
                {
                    Schema.DescribeSObjectResult objectResult = systemObjectType.getDescribe();
                    Map<String,Schema.SObjectField> mapFieldNameAndSchema = objectResult.fields.getMap();
                    for(String fieldName : mapFieldNameAndSchema.keySet())
                    {
                         Schema.SObjectField fieldSchema = mapFieldNameAndSchema.get(fieldName); 
                         Schema.DescribeFieldResult fieldDescribe = fieldSchema.getDescribe();
                         if(fieldDescribe.isCreateable())
                         {
                            selectQuery += fieldDescribe.getName()+', ';
                         }
                    }
                    selectQuery = selectQuery.substring(0,selectQuery.lastIndexOf(',')) + ' ';
                    selectQuery += 'from '+ ObjectName+' ';
                    /*if (ObjectName == 'Opportunity')
                    {
                        selectQuery = 'select AccountId,Name,Description,StageName,Probability,CloseDate,Type,NextStep,LeadSource,CurrencyIsoCode,CampaignId,Pricebook2Id,OwnerId,TerritoryId,FiscalQuarter,FiscalYear,Fiscal,Accrual_Flag__c,Accrual_Flag_Date__c,Accrual_Flag_Set_By__c,Strategy__c,Acct_Plan_del__c,Brand__c,Other_Competitor__c,Partner__c,Parent_Opportunity__c,Threshold_History__c,Threshold_Reason__c,Compelling_Event__c,Unique_Business_Value__c,Budget_Available__c,Deal_Type__c,Source_Sub_Category__c,Source_Description__c,Patient_level_Data__c,Doctor_level_Data__c,Unique_Doctor_Records__c,Sales_Representatives__c,Doctor_Rate__c,Sales_Rep_Rate__c,Region_Delivery_Country__c,PIC_Email__c,PIC_User__c,Principal_In_Charge__c,Prior_Amount__c,Therapy_Area__c,Threshold_Flag__c,Threshold_Trigger__c,Bid_Team__c,Bid_Team_User__c,PIC_Entity__c,PIC_Sales_Org__c,IMS_Region__c,Business_Type_Name__c,DEPT__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Term__c,Contract_Type__c,CEQActiveRelease__c,SAP_Master_Contract__c from Opportunity ';
                    }
                    else if (ObjectName == 'OpportunityLineItem')
                    {                    
                        selectQuery = 'select Id,OpportunityId,SortOrder,PricebookEntryId,CurrencyIsoCode,Quantity,ListPrice,ServiceDate,Description,Service_Line__c,Delivery_Country__c,Discount_Amount__c,Net_Price__c,Business_Line__c,Business_Type__c,Practice_Area__c,SubPractice_Area__c,Book_No__c,Delivery_Media__c,Revenue_Comments__c,Nbr_of_Users__c,Billing_Frequency__c,Proj_Rpt_Frequency__c,Product_Start_Date__c,Product_End_Date__c,Discount_Reason__c,Invoice_Date__c,Other_Ship_To__c,Cancel__c,Revised_Price__c,Cancel_Text__c,Production_Reference__c,Output_Format__c,Sale_Type__c,Revenue_Type__c,TotalPrice from OpportunityLineItem ';
                    }//*/
                    mapObjectNameAndSelectQuery.put(ObjectName,selectQuery);
                }                
                system.debug('selectQuery###'+selectQuery);
            }
            return mapObjectNameAndSelectQuery.get(ObjectName);
        }
    }


    /*Map<Id, Boolean> userIdStatusMap = new Map<Id, Boolean> ();
    private void initOpportunityOwnersMap(List<Opportunity> opportunityList) {
        Set<id> oppOwnerIdSet = new Set<Id> ();
        for(Opportunity opp : opportunityList ) {
             oppOwnerIdSet.add(opp.ownerId);
        }

        List<User> userList = [select Id,IsActive from User where Id in :oppOwnerIdSet];
        
        for(User u : userList) {
            userIdStatusMap.put(u.id, u.IsActive);
        }

    }//*/

    //helper method to caputre datebase save result
    private void storeExecResult(List<BasicWrapper> basicWrapperList, Database.SaveResult [] sr) {
        if(basicWrapperList == null && basicWrapperList.size() <= 0 && sr == null && sr.size() <= 0)
            return;
        for(Integer i = 0; i < sr.size(); i++){   
            BasicWrapper wrapObj = basicWrapperList.get(i);            
            if(sr[i] != null && !sr[i].isSuccess()) {                 
                wrapObj.isClonedSuccessfully = false;               
                Database.Error[] err = sr[i].getErrors(); 
                if (err != null ) {
                    for(integer j = 0; j < err.size(); j++) {
                        wrapObj.errorMsgList.add(err[j].getStatusCode() + ' ' + err[j].getMessage());
                    }
                }
            } else {
                wrapObj.isClonedSuccessfully = true; 
            } 
            System.debug('wrapObj.isClonedSuccessfully = ' + wrapObj.isClonedSuccessfully );
        }        
    }
    
    //Common method to create opportunity hierarchy and clone that hierarchy.
    public List<Renewal_Task__c> CreateOpportunityHierarchyAndItsClone(List<Renewal_Task__c> listRenewalTask)
    {
        
        Map<ID,Renewal_Task__c> mapOpportunityIdAndRenewalTask = new Map<ID,Renewal_Task__c>();
        Set<Id> renewalTaskIdSet = new Set<Id> ();
        if(listRenewalTask != null && listRenewalTask.size()>0)
            for(Renewal_Task__c renewalTask : listRenewalTask) {
                renewalTaskIdSet.add(renewalTask.id);
                mapOpportunityIdAndRenewalTask.put(renewalTask.Opportunity__c, renewalTask);
        }
        
        Set<ID> opportunityIds = mapOpportunityIdAndRenewalTask.keySet();
        system.debug('opportunityIds###'+opportunityIds);
        
        
        
        List<Opportunity> listOriginalOpportunity = Database.query(GenerateSelectQueryWithAllFields('Opportunity')+'where ID in :opportunityIds');

        //initialize the map of owner id and its active status
        //initOpportunityOwnersMap(listOriginalOpportunity);
            
        
        System.debug('listOriginalOpportunity###'+listOriginalOpportunity);
        Set<ID> setOpportunityIds = new Set<ID> ();
        for(Opportunity opp : listOriginalOpportunity)
        {
            setOpportunityIds.add(opp.Id);
        }

        List<Renewal_Task_Change_Detail__c> listChangeDetails = [ select id, 
                                                                    Renewal_Task__c,
                                                                    Territory__c, 
                                                                    ProductCode__c, 
                                                                    Data_Month_Start__c,
                                                                    Proj_Rpt_Frequency__c,
                                                                    Data_Month_End__c,
                                                                    Revenue_Type__c,
                                                                    Winback__c,
                                                                    Output_Format__c,
                                                                    Product_Invoice_Text__c,
                                                                    Renewal_Task__r.CurrencyIsoCode,
                                                                    Delivery_Media__c,
                                                                    TotalPrice__c,
                                                                    Billing_Frequency__c,
                                                                    Sale_Type__c,
                                                                    Opportunity_Line_Item_Id__c 
                                                                    From Renewal_Task_Change_Detail__c 
                                                                    where Dropped_Reason__c = '' AND Renewal_Task__r.id in :renewalTaskIdSet 
                                                                    ];
        System.debug('listChangeDetails = ' + listChangeDetails);
        //Map of original line item id and change detail object
        Map<Id, Renewal_Task_Change_Detail__c> LIIdChangeDetailMap = new Map<Id, Renewal_Task_Change_Detail__c> ();
        Set<String> changeDetailsOppLIIds = new Set<String> ();

        //set for querying pricebookEntry object
        Set<String> productCodeSet = new Set<String> ();
        Set<String> currCodeSet = new Set<String> ();
        for(Renewal_Task_Change_Detail__c d : listChangeDetails){
            LIIdChangeDetailMap.put(d.Opportunity_Line_Item_Id__c , d);
            changeDetailsOppLIIds.add(d.Opportunity_Line_Item_Id__c);
            productCodeSet.add(d.ProductCode__c);
            currCodeSet.add(d.Renewal_Task__r.CurrencyIsoCode);
        }
        
        //query for initializing prodCodeCurrCodePbEntryMap
        List<PriceBookEntry> pbEntryList = [select id, ProductCode, currencyIsoCode from Pricebookentry where ProductCode in : productCodeSet 
                                            and Product2.Duplicate__c = false and Product2.IsActive = true
                                            and currencyIsoCode in : currCodeSet];
        
        prodCodeCurrCodePbEntryMap = new Map<String, Id> ();
        for(PriceBookEntry pbe : pbEntryList ) {
             prodCodeCurrCodePbEntryMap.put(pbe.ProductCode + '_'+ pbe.currencyIsoCode, pbe.id );
        }

        System.debug('changeDetailsOppLIIds = ' + changeDetailsOppLIIds);
        
        
        List<OpportunityLineItem> listOpportunityLI = Database.Query(GenerateSelectQueryWithAllFields('OpportunityLineItem')+'where OpportunityId in :setOpportunityIds');
        System.debug('listOpportunityLI###'+listOpportunityLI);
        
        Set<ID> setOpportunityLIIds = new Set<ID>();
        for(OpportunityLineItem oppIL :listOpportunityLI)
        {
            setOpportunityLIIds.add(oppIL.Id);
        }
        
        List<OpportunityLineItemSchedule> listOpportunityLIS = Database.Query(GenerateSelectQueryWithAllFields('OpportunityLineItemSchedule')+'where OpportunityLineItemId in :setOpportunityLIIds');
        System.debug('listOpportunityLIS###'+listOpportunityLIS.Size());
        
        List<OpportunityWrapper> listOpportunityWrapper = new List<OpportunityWrapper>(); 
        for(Opportunity opp : listOriginalOpportunity)
        {  
            OpportunityWrapper oppWrapper = new OpportunityWrapper();
            oppWrapper.originalOpportunity = opp;
            oppWrapper.RenewalTask = mapOpportunityIdAndRenewalTask.get(opp.Id);
            listOpportunityWrapper.add(oppWrapper);
            oppWrapper.listOpportunityLIWrapper = new List<OpportunityLineItemWrapper>();

            for(OpportunityLineItem OLI :listOpportunityLI)
            {
                //if(opp.Id == OLI.OpportunityId)
                System.debug('opp.Id = ' + OLI.id);
                if(changeDetailsOppLIIds.contains(OLI.id) && OLI.opportunityId == opp.id) {
                    //oppWrapper.listOpportunityLIWrapper = new List<OpportunityLineItemWrapper>();
                    //OLI.TotalPrice *= (1 + oppWrapper.RenewalTask.Price_Increase__c/100);
                    OpportunityLineItemWrapper oppLIWrapper = new OpportunityLineItemWrapper();
                    oppLIWrapper.originalOpportunityLineItem = OLI;
                    oppWrapper.listOpportunityLIWrapper.add(oppLIWrapper);

                    oppLIWrapper.OpportunityLISWrapperList = new List<OpportunityLineItemScheduleWrapper> ();
                    for(OpportunityLineItemSchedule OLIS : listOpportunityLIS) {
                        if(OLI.Id == OLIS.OpportunityLineItemId)
                        {
                            OpportunityLineItemScheduleWrapper olisWrapper = new OpportunityLineItemScheduleWrapper();
                            //OLIS.Revenue *= (1 + oppWrapper.RenewalTask.Price_Increase__c/100);
                            olisWrapper.OriginalOpportunityLineItemSchedule = OLIS;
                            oppLIWrapper.OpportunityLISWrapperList.add(olisWrapper);

                        }
                    }
                    
                 }
            }
        }
        
        List<Opportunity> listOfClonedOpportunity = new List<Opportunity>();
        List<OpportunityWrapper> listOppWrapParallelList = new List<OpportunityWrapper> ();
        for(OpportunityWrapper oppWrap : listOpportunityWrapper)
        {
            if(oppWrap.originalOpportunity != null)
            {
                oppWrap.createOpportunityClone();
                //oppWrap.clonedOpportunity.StageName = '5 - Negotiate Contract Ts & Cs';
                SetStageField(oppWrap.clonedOpportunity, oppWrap.RenewalTask);
                //set the owner of the newly created opportunity here
                
                /*Boolean isOppOwnerActive = userIdStatusMap.get(oppWrap.clonedOpportunity.ownerId);
                if(!isOppOwnerActive) {
                    oppWrap.clonedOpportunity.ownerId = oppWrap.RenewalTask.ownerId;
                }//*/
                oppWrap.clonedOpportunity.ownerId = oppWrap.RenewalTask.ownerId;

                SetRenewalName(oppWrap.clonedOpportunity);
                SetExpectedCloseDate(oppWrap.clonedOpportunity);
                SetOppProbability(oppWrap.clonedOpportunity);
                SetOppRenewalTask(oppWrap.clonedOpportunity, oppWrap.RenewalTask);
                SetCloneOpportunityFieldsIfTargetedCloseDateChanged(oppWrap.clonedOpportunity,oppWrap.originalOpportunity,oppWrap.RenewalTask);
                listOfClonedOpportunity.add(oppWrap.clonedOpportunity);
                listOppWrapParallelList.add(oppWrap);
            }
        }
        
        // The false parameter allows for partial processing if multiple records passed into the operation.
        CON_CRM_OpportunityRenewals.allowCbexQueueable = false;
        Database.SaveResult[] sr = Database.insert(listOfClonedOpportunity, false);
        system.debug('listOfClonedOpportunity### '+listOfClonedOpportunity.size()); 
        
        //store database operation result on wrapper object
        storeExecResult(listOppWrapParallelList, sr);
        
        List<OpportunityLineItem> listOfClonedOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItemWrapper> parallelOpportunityLineItemWrapperList = new List<OpportunityLineItemWrapper> ();
        for(OpportunityWrapper oppWrap : listOpportunityWrapper)
        {
            if(oppWrap.clonedOpportunity != null && oppWrap.listOpportunityLIWrapper != null && oppWrap.isClonedSuccessfully)
            {
                for(OpportunityLineItemWrapper oppLIW :oppWrap.listOpportunityLIWrapper)
                {
                    oppLIW.createOpportunityLineItemClone();
                    Renewal_Task_Change_Detail__c cd = LIIdChangeDetailMap.get(oppLIW.originalOpportunityLineItem.id);
                    System.debug('cd = ' + cd);
                    SetClonedOpportunityLineItemFields(oppLIW.clonedOpportunityLineItem,oppWrap.originalOpportunity,oppWrap.RenewalTask, cd);                    
                    oppLIW.clonedOpportunityLineItem.OpportunityId = oppWrap.clonedOpportunity.Id;
                    listOfClonedOpportunityLineItem.add(oppLIW.clonedOpportunityLineItem);                    
                    parallelOpportunityLineItemWrapperList.add(oppLIW);
                    
                }
            }
        }
        // The false parameter allows for partial processing if multiple records passed into the operation.
        System.debug('444444');
        Database.SaveResult[] liSr = Database.insert(listOfClonedOpportunityLineItem, false);
        System.debug('55555');
        system.debug('listOfClonedOpportunityLineItem### '+listOfClonedOpportunityLineItem);
        List<opportunityLineItem> listOfClonedOpportunityLineItemAfterInsert = new List<opportunityLineItem>();
        for(OpportunityLineItem oli : listOfClonedOpportunityLineItem){
            listOfClonedOpportunityLineItemAfterInsert.add(new OpportunityLineItem(Id = oli.Id));
        }

        //store database operation result on wrapper object
        storeExecResult(parallelOpportunityLineItemWrapperList, liSr);
        
        CreateNewBNF(listOpportunityWrapper,setOpportunityIds);
        //system.debug('listOfBNF### '+[Select ID from BNF2__c where Opportunity__c = :listOfClonedOpportunity.get(0).Id]);
        
        //  Create contact roles for newly cloned opportunities
        CreateContactRoles(listOpportunityWrapper,setOpportunityIds);       
        
        List<OpportunityLineItemSchedule> listOfClonedOpportunityLineItemSchedule = new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemScheduleWrapper> parallerOLISWrapperList = new List<OpportunityLineItemScheduleWrapper> ();
        for(OpportunityWrapper oppWrap : listOpportunityWrapper)
        {
            if(oppWrap.clonedOpportunity != null && oppWrap.listOpportunityLIWrapper != null && oppWrap.isClonedSuccessfully)
            {
                for(OpportunityLineItemWrapper oppLIW :oppWrap.listOpportunityLIWrapper)
                {
                    //if(oppLIW.clonedOpportunityLineItem != null && oppLIW.OpportunityLISWrapper.listOriginalOpportunityLineItemSchedule.Size()>0 && oppLIW.isClonedSuccessfully)
                    if(oppLIW.clonedOpportunityLineItem != null && oppLIW.OpportunityLISWrapperList.Size()>0 && oppLIW.isClonedSuccessfully)
                    {
                        for(OpportunityLineItemScheduleWrapper olisWrapper: oppLIW.OpportunityLISWrapperList) {
                           olisWrapper.createOpportunityLineItemScheduleClone();
                           olisWrapper.clonedOpportunityLineItemSchedule.OpportunityLineItemId = oppLIW.clonedOpportunityLineItem.Id;
                           Renewal_Task_Change_Detail__c cd2 = LIIdChangeDetailMap.get(oppLIW.originalOpportunityLineItem.id);
                           SetClonedOpportunityLineItemScheduleFields( olisWrapper.clonedOpportunityLineItemSchedule, oppWrap.originalOpportunity, oppWrap.RenewalTask, cd2, oppLIW.originalOpportunityLineItem);
                           listOfClonedOpportunityLineItemSchedule.add(olisWrapper.clonedOpportunityLineItemSchedule);
                           parallerOLISWrapperList.add(olisWrapper);
                        }                    
                        
                    }
                }
            }
        }   
        //insert listOfClonedOpportunityLineItemSchedule;
        System.debug('DEBUG## listOfClonedOpportunityLineItemSchedule.size() : '+listOfClonedOpportunityLineItemSchedule.size());
        System.debug('DEBUG## Renewal_Dashboard_OLIs_Clone_Limit__c : '+CRM_Config__c.getOrgDefaults().Renewal_Dashboard_OLIs_Clone_Limit__c);
        Boolean stopTriggerExecutionForOLIs = listOfClonedOpportunityLineItemSchedule.size() > CRM_Config__c.getOrgDefaults().Renewal_Dashboard_OLIs_Clone_Limit__c;
        if(stopTriggerExecutionForOLIs){
        	UTL_ExecutionControl.stopTriggerExecution = true;            
        }
        System.debug('DEBUG###TriggerExecutionstopedForOLIs : ' + stopTriggerExecutionForOLIs);
        Database.SaveResult[] srLis = Database.insert(listOfClonedOpportunityLineItemSchedule, false);
        if(stopTriggerExecutionForOLIs){
	        UTL_ExecutionControl.stopTriggerExecution = false;
            Database.SaveResult[] liSru = Database.update(listOfClonedOpportunityLineItemAfterInsert, false);
        }
        CON_CRM_OpportunityRenewals.allowCbexQueueable = true;
        system.debug('listOfClonedOpportunityLineItemScheduleSize### ' + listOfClonedOpportunityLineItemSchedule.size());
        //store the execution result
        storeExecResult(parallerOLISWrapperList, srLis );
        
        ///////////////////////////////////////////////////////////////
        List<Renewal_Task__c> lstTasks = new List<Renewal_Task__c>();
        List<Note> notesList = new List<Note> ();

        List<Opportunity> erroredOppList = new List<Opportunity> ();
        for(OpportunityWrapper oppWrap : listOpportunityWrapper){
            List<Note> innerNotesList = new List<Note> ();
            //retrieve opportunity cloning errors
            for(String errMsg : oppWrap.errorMsgList ){
                //notesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Opportunity Cloning Error', body=errMsg) );
                innerNotesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Opportunity Cloning Error', body=errMsg) ); 
                System.debug('DEBUG## opp: '+oppWrap.RenewalTask.id + ' '+ errMsg);
            }
            //retrieve line item cloning errors
            for(OpportunityLineItemWrapper oLIWrapper : oppWrap.listOpportunityLIWrapper){
                for(String errMsg1 : oLIWrapper.errorMsgList ){
                    //notesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Error on Line Item Cloning with Id ' + oLIWrapper.originalOpportunityLineItem.id, body=errMsg1) );
                    innerNotesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Error on Line Item Cloning with Id ' + oLIWrapper.originalOpportunityLineItem.id, body=errMsg1) );
                    System.debug('DEBUG## LI : '+oLIWrapper.originalOpportunityLineItem.id + ' '+errMsg1);
                }
                //retrieve line item schedule clone errors
                for(OpportunityLineItemScheduleWrapper opplisWrapper : oLIWrapper.OpportunityLISWrapperList ) {
                    for(String errMsg2 : opplisWrapper.errorMsgList ){
                        /*notesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Error on Line Item Schedule Cloning for Line Item Id ' + 
                                    opplisWrapper.originalOpportunityLineItemSchedule.OpportunityLineItem.id + ' ' +
                                    opplisWrapper.originalOpportunityLineItemSchedule.id, body=errMsg2) );//*/
                        innerNotesList.add(new Note(parentId=oppWrap.RenewalTask.id, title='Error on Line Item Schedule Cloning for Line Item Id ' + 
                                    opplisWrapper.originalOpportunityLineItemSchedule.id, body=errMsg2) );
                        System.debug('DEBUG## OLIs: '+opplisWrapper.originalOpportunityLineItemSchedule.id + ' ' + errMsg2);
                    }
                }
            }
            
            //if(notesList.size() ==  0) {
            if(innerNotesList.size() ==  0) {
                oppWrap.RenewalTask.Cloning_Status__c = CON_CRM_OpportunityRenewals.CLONED_STATUS_STR;//'cloned';  
                oppWrap.RenewalTask.Cloned_Opportunity__c = oppWrap.clonedOpportunity.id;
            }
            else {
               oppWrap.RenewalTask.Cloning_Status__c = CON_CRM_OpportunityRenewals.ERROR_STATUS_STR;
               erroredOppList.add(oppWrap.clonedOpportunity);
               notesList.addAll(innerNotesList);
            }       
            
            lstTasks.add(oppWrap.RenewalTask);
        }
        try
        {
            Database.insert(notesList, false);        
            system.debug('lstTasks = ' + lstTasks);
        } catch (Exception ex) {
            sendMailNotification(ex.getMessage()); 
        } 
        try
        {
            delete erroredOppList;
        } catch (Exception ex) {
            sendMailNotification(ex.getMessage()); 
        } 
        try
        {
            update lstTasks;
        } catch (Exception ex) {
            sendMailNotification(ex.getMessage()); 
        }           
        
        ///////////////////////////////////////////////////////////////    
        return null;
    }
    
    //method to create new BNF to attached with new Opportunity
    public void CreateNewBNF(List<OpportunityWrapper> listOppWrapper , Set<Id> originalOpportunityIds)
    {
        BNF2__c newBNF;
        List<BNF2__c> listLatestApprovedBNF = Database.Query(GenerateSelectQueryWithAllFields('BNF2__c')+'where Opportunity__c in : originalOpportunityIds and (BNF_Status__c = \'Accepted\' or BNF_Status__c = \'SAP Contract Confirmed\') Order By CreatedDate Desc' );
        if(listLatestApprovedBNF.size() > 0)
       {
            List<BNF2__c> listNewApprovedBNF = new List<BNF2__c>() ;
            List<OpportunityWrapper> parallelOppWrapList = new List<OpportunityWrapper> ();
            for(OpportunityWrapper oppWrapper :listOppWrapper)
            {
                for(BNF2__c bnf : listLatestApprovedBNF)
                {
                    if(oppWrapper.originalOpportunity != null && bnf.Opportunity__c == oppWrapper.originalOpportunity.Id && oppWrapper.isClonedSuccessfully)
                    {
                        newBNF = bnf.clone(false,true);
                        newBNF.BNF_Status__c = 'New';
                        newBNF.Client_PO_Number__c = null;
                        newBNF.Contract_Term__c = 'Multi-Period' ; 
                        newBNF.Opportunity__c  = oppWrapper.clonedOpportunity.Id;
                        newBNF.Revenue_Analyst__c = null;
                        newBNF.Renewal__c = true;
                        //Revised BNF flag - Addendum__c
                        newBNF.Addendum__c = false;
                        //Revised BNF reason - Addendum_Reasons__c
                        newBNF.Addendum_Reasons__c = '';
                        //Revised BNF comments- Revised_BNF_Comment__c
                        newBNF.Revised_BNF_Comment__c = '';
                        //Revised BNF Date - Revised_BNF_Date__c
                        newBNF.Revised_BNF_Date__c = null;
                        //Set SAP contract fields to null
                        newBNF.Sales_Start_Date__c = null;
                        newBNF.BNF_Actor_Ids__c = null;
                        newBNF.Sales_End_Date__c = null;
                        newBNF.Sales_Processing_Time__c = null;
                        newBNF.LO_Start_Date__c = null;
                        newBNF.LO_End_Date__c = null;
                        newBNF.LO_Processing_Time__c = null;
                        newBNF.LO_First_Submission_Date__c = null;
                        newBNF.RA_Start_Date__c = null;
                        newBNF.RA_End_Date__c = null;
                        newBNF.RA_First_Submission_Date__c = null;
                        newBNF.RA_Processing_Time__c = null;
                        newBNF.SAP_Start_Date__c = null;
                        newBNF.SAP_End_Date__c = null;
                        newBNF.SAP_Processing_Time__c = null;
                        newBNF.SAP_First_Submission_Date__c = null;
                        newBNF.Final_BNF_Processing_Time__c = null;
                        newBNF.Final_BNF_RA_First_Submission_Date__c = null;
                        newBNF.Time_from_1st_Submission_from_RA_to_SAP__c = null;
                        newBNF.Time_to_1st_RA_Submission__c = null;
                        newBNF.LO_Rejection_Count__c = 0;
                        newBNF.RA_Rejection_Count__c = 0;
                        newBNF.SAP_Rejection_Count__c = 0;
                        newBNF.Manual_Handling_In_SAP__c = false;
                        //Update By Himanshu 31 July 2013 
                        //newBNF.SAP_Master_Contract__c = null;
                        if(oppWrapper.originalOpportunity.SAP_Master_Contract__c!=null)
                            newBNF.SAP_Master_Contract__c= oppWrapper.originalOpportunity.SAP_Master_Contract__c;
                        
                        newBNF.SAP_Contract__c = null;
                        //Set Original_Prior_Opportunity__c to Id of opp that was cloned on dasbhoard
                        newBNF.Original_Prior_Opportunity__c = oppWrapper.originalOpportunity.Id;
                        newBNF.Original_Prior_Opportunity_Id__c = oppWrapper.originalOpportunity.Legacy_IMS_Opportunity_Number__c;
                        //Set record type depending on Sales Org
                        if (MDM_Defines.EnabledSalesOrgs.contains(bnf.IMS_Sales_Org__c))
                        {
                            newBNF.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
                        }
                        if(newBNF.Invoice_Header_Text__c == null) 
                           newBNF.Invoice_Header_Text__c = '';


                        newBNF.Legacy_ID__c = null;
                        listNewApprovedBNF.add(newBNF);
                        parallelOppWrapList.add(oppWrapper);
                        oppWrapper.logDebugInfo( 'newBnf is ' + newBNF.id + ' ' + newBNF);
                        break;
                    }
                }
            }
            if(listNewApprovedBNF.size()>0) {
                Database.SaveResult[] srBNF = Database.insert(listNewApprovedBNF, false);
                storeExecResult(parallelOppWrapList, srBNF );
            }
        }
   }

    //method to copy contact roles from original opps to cloned opps
    public void CreateContactRoles(List<OpportunityWrapper> listOppWrapper , Set<Id> originalOpportunityIds)
    {      
        List<OpportunityContactRole> listOCR = [SELECT ContactId,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where OpportunityId in :originalOpportunityIds];
        if(listOCR.size() > 0)
        {
            List<OpportunityContactRole> listNewOCR = new List<OpportunityContactRole>() ;
            List<OpportunityWrapper> parallelOppWrapList = new List<OpportunityWrapper>();
            OpportunityContactRole newOCR = new OpportunityContactRole();
            for(OpportunityWrapper oppWrapper :listOppWrapper)
            {
                for(OpportunityContactRole OCR : listOCR)
                {
                    if(oppWrapper.originalOpportunity != null && OCR.OpportunityId == oppWrapper.originalOpportunity.Id && oppWrapper.isClonedSuccessfully)
                    {
                        newOCR = OCR.clone(false,true);
                        newOCR.OpportunityId = oppWrapper.clonedOpportunity.Id;
                        listNewOCR.add(newOCR);
                        parallelOppWrapList.add(oppWrapper);
                    }
                }
            }
            if(listNewOCR.size()>0) {
                Database.SaveResult[] srOCR = Database.insert(listNewOCR, false);
                storeExecResult(parallelOppWrapList, srOCR );
            }
        }
   }

    private void sendMailNotification(String errMsg) {
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = new List<String>{'sduncan@uk.imshealth.com'};
        message.whatId = UserInfo.getUserId();
        message.subject = 'Batch cloning error';
        message.staticContent = '<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Batch opportunity cloning failed ***<br><br>The automated cloning process failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ errMsg +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
    }
    
    /////************  Inner classes  *************/////////////
    //basic class to hold common wrapper info
    public virtual class BasicWrapper {
        public Boolean isClonedSuccessfully{get;set;}
        public List<String> errorMsgList = new List<String> ();
    }
    
    //Class to hold Opportunity object with some more properties and methods
    public class OpportunityWrapper extends BasicWrapper 
    {
        public Renewal_Task__c RenewalTask{get;set;}
        public Opportunity originalOpportunity{get;set;}
        public Opportunity clonedOpportunity{get;set;}
        public List<OpportunityLineItemWrapper> listOpportunityLIWrapper{get;set;}
        public String cloningDebugStr = '';
        
        public void setOpportunidyIdInOpportunityLineItem()
        {
            if(clonedOpportunity != null)
            {
                for(OpportunityLineItemWrapper oppLIW : listOpportunityLIWrapper)
                {
                    logDebugInfo('Setting cloned opportunity id = ' + clonedOpportunity.Id + ' for cloning the line item with id = ' + oppLIW.originalOpportunityLineItem.id );
                    oppLIW.clonedOpportunityLineItem.opportunityId = clonedOpportunity.Id;
                }
            }
        }
        
        public void createOpportunityClone()
        {
            logDebugInfo('Cloning opportunity id = ' + originalOpportunity.id + ' name = ' + originalOpportunity.name);
            clonedOpportunity = originalOpportunity.clone(false,true);   
            List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Opportunity.FieldSets.Opp_Clone_Fields_Exclude.getFields();
            Set<String> excludeOLIFieldsSet = new Set<String>();
            for(Schema.FieldSetMember setMember : fieldSetMemberList) {
                if(String.valueOf(setMember.getType()) == 'Boolean'){
                    clonedOpportunity.put(setMember.getFieldPath(),false);
                }else{
                    clonedOpportunity.put(setMember.getFieldPath(),null);
                }
                
            } 
            clonedOpportunity.Parent_Opportunity__c = originalOpportunity.id;
            clonedOpportunity.From_Opportunity__c = originalOpportunity.id;  
            clonedOpportunity.Deal_Desk_Status__c = 'Open';
            if (RenewalTask.Owner_Country__c != null && RenewalTask.Owner_Country__c.toUpperCase() == 'UK')     
            {
                clonedOpportunity.CEQActiveRelease__c = 0;
            }        
        }
        
        public void logDebugInfo(String debugStr){
            if(CON_CRM_OpportunityRenewals.IS_DEBUG_ENABLED) {
                System.debug(debugStr );
                cloningDebugStr += debugStr ;
            }
        }
    }
    
    //Class to hold OpportunityLineItem object with some more properties and methods
    public class OpportunityLineItemWrapper extends BasicWrapper
    {
        public OpportunityLineItem originalOpportunityLineItem{get;set;}
        public OpportunityLineItem clonedOpportunityLineItem{get;set;}
        public List<OpportunityLineItemScheduleWrapper> OpportunityLISWrapperList {get;set;}
        
        public void setOpportunidyIdInOpportunityLineItem()
        {
            if(clonedOpportunityLineItem != null && OpportunityLISWrapperList != null)
            {                
                for(OpportunityLineItemScheduleWrapper olisWrapper : OpportunityLISWrapperList) {
                    olisWrapper.clonedOpportunityLineItemSchedule.OpportunityLineItemId = clonedOpportunityLineItem.Id;
                }
            }
        }
        
        public void createOpportunityLineItemClone()
        {
            if(originalOpportunityLineItem != null)
            {
                system.debug('About to clone: ');
                system.debug(originalOpportunityLineItem);
                clonedOpportunityLineItem = originalOpportunityLineItem.clone(false,true);
                clonedOpportunityLineItem.Legacy_Opportunity_LineItemId__c = originalOpportunityLineItem.Id;
                
            }
        } 
    }

    //Class to hold OpportunityLineItemSchedule object with some more properties and methods
    public class OpportunityLineItemScheduleWrapper extends BasicWrapper
    {
        public OpportunityLineItemSchedule originalOpportunityLineItemSchedule{get;set;}
        public OpportunityLineItemSchedule clonedOpportunityLineItemSchedule{get;set;}
        
        
        public void createOpportunityLineItemScheduleClone()
        {
            if(originalOpportunityLineItemSchedule != null)
                clonedOpportunityLineItemSchedule = originalOpportunityLineItemSchedule.clone(false, true);
        }
    }
     
    
    /////&&&&&&&&&& End Inner classes Section  &&&&&&&&&&/////////////
}