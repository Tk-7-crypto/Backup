/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-17647
* Purpose 1    : Batch to Clone US BU Opportunity once Stage is moved to in-Hand and Is_this_a_Renewable_Opportunity__c = True, And Send Email.
*/
global class BCH_CRM_USRenewalsAutomation implements Database.Batchable<sObject>,Database.RaisesPlatformEvents {
    
    String query = null;
    public BCH_CRM_USRenewalsAutomation() {        
    }   
    
    /**
     * Constructor to Take Query as Input
     * @param String query
     */
    public BCH_CRM_USRenewalsAutomation(String query) {
        if(Test.isRunningTest()){
            this.query = 'Select id from Opportunity Where Is_this_a_Renewable_Opportunity__c = \'Yes\' AND id = \''+ query +'\'' ;
        }else if(query == 'RunBatchForFirstTime'){
            this.query = 'Select id from Opportunity where Is_this_a_Renewable_Opportunity__c = \'Yes\' AND ( StageName = \'In-Hand\' OR ( StageName IN (\'3. Developing Proposal\',\'4. Delivering Proposal\',\'5. Finalizing Deal\',\'6. Received ATP/LOI\',\'7a. Closed Won\') AND In_Hand_Stage_Entry__c != null)) AND CreatedDate > 2024-01-01T00:00:00.000+00:00 AND Contract_End_Date__c >= 2025-01-01';
        }else{
            this.query = 'Select id from Opportunity Where Is_this_a_Renewable_Opportunity__c = \'Yes\' AND In_Hand_Stage_Entry__c = YESTERDAY AND id = \''+ query +'\'' ;
        }
    }
    
    /*
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null) {
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator([Select id from Opportunity Where Is_this_a_Renewable_Opportunity__c = 'Yes' and In_Hand_Stage_Entry__c = YESTERDAY]);
        }
    }
    /*
     * Execute method 
     * @params  Database.BatchableContext context
     * 
    */
    global void execute(Database.BatchableContext bc,List<Opportunity> oppList) {
        Set<Id> oppToCloneIdSet = (new Map<Id,Opportunity>(oppList)).keySet();
        List<Opportunity> oppListAlreadyCloned = [Select Name,From_Opportunity__c,CreatedDate,Parent_Opportunity__c from Opportunity where ( From_Opportunity__c =:oppToCloneIdSet OR Parent_Opportunity__c =:oppToCloneIdSet) and CreatedDate = THIS_YEAR ];
        List<OpportunityLineItem> oldOppInActiveOLIList = new List<OpportunityLineItem>();
        if(oppListAlreadyCloned.size() > 0 ){
            oppToCloneIdSet.clear();
        }
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType,
                OpportunityLineItemSchedule.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );
        if(oppToCloneIdSet.size() > 0){
            Map<String,String> MaptoFieldValue = new Map<String,String>();
            Map<String, Boolean> objectTypeToIsCloneMap = new Map<String, Boolean>();
            List<Opportunity> oppCloningDataList = [Select id,Is_this_a_Renewable_Opportunity__c,In_Hand_Stage_Entry__c,Opportunity_Number__c,Contract_Start_Date__c,Contract_End_Date__c,CloseDate,CurrencyIsoCode,LeadSource,FSP__c,OwnerId,Forecast_Category__c,Principle_inCharge__r.Email,Owner_Email__c,Owner.IsActive,Last_Modified_By_USER__r.Email,Last_Modified_By_USER__c,Account.Name, (Select id,CreatedBy.Email from Purchase_BNF_s1__r where CreatedBy.IsActive = true order by CreatedDate DESC limit 1),(Select id,CreatedBy.Email from BNF_s__r where CreatedBy.IsActive = true order by CreatedDate DESC limit 1) from Opportunity where id =:oppToCloneIdSet];
            if(oppCloningDataList[0].Is_this_a_Renewable_Opportunity__c == 'Yes'){
                oldOppInActiveOLIList = new SLT_OpportunityLineItems().selectByOpportunityIdandFilterCondition(oppToCloneIdSet, new Set<String>{'id','Product2.Name','SAP_Code__c'} , ' And Product2.IsActive = false');
                String OppName ;
                String OppStage = CON_CRM.IDENTIFYING_OPP_STAGE;
                String OppForcastCategory = CON_CRM.PIPELINE_FORECAST_CATEGORY;
                String OppContractStartDate ; 
                String OppClosedDate;
                String OppCurrency;
                String OppOwnerId;
                String closeYear;
                if(oppCloningDataList[0].Contract_End_Date__c == null){
                    closeYear = String.valueof(oppCloningDataList[0].CloseDate.year());
                }else{
                    closeYear = String.valueof(oppCloningDataList[0].Contract_End_Date__c.year());
                }
                OppName = 'Renewal '+ oppCloningDataList[0].Account.Name +' (' + oppCloningDataList[0].Opportunity_Number__c + ') ' + closeYear;
                if(OppName.length() >= 98){
                    OppName = 'Renewal '+' (' + oppCloningDataList[0].Opportunity_Number__c + ') ' + closeYear;
                }
                OppContractStartDate = oppCloningDataList[0].Contract_End_Date__c != null ? String.Valueof(oppCloningDataList[0].Contract_End_Date__c.addDays(1)) : ('');
                    Integer numberDaysDue ;
                if(oppCloningDataList[0].Contract_Start_Date__c != null && oppCloningDataList[0].Contract_End_Date__c != null ){
                    numberDaysDue = oppCloningDataList[0].Contract_Start_Date__c.daysBetween(oppCloningDataList[0].Contract_End_Date__c);
                }else{
                    numberDaysDue = 0;
                }
                
                OppClosedDate = String.Valueof(oppCloningDataList[0].CloseDate.addDays(numberDaysDue));
                OppCurrency = oppCloningDataList[0].CurrencyIsoCode;
                if(oppCloningDataList[0].Owner.IsActive){
                    OppOwnerId = oppCloningDataList[0].OwnerId;
                }else{
                    OppOwnerId = oppCloningDataList[0].Last_Modified_By_USER__c;
                }
                
                MaptoFieldValue.put('Name',OppName);
                MaptoFieldValue.put('Contract_Start_Date__c',OppContractStartDate);
                MaptoFieldValue.put('CloseDate',OppClosedDate);
                MaptoFieldValue.put('StageName',OppStage);
                MaptoFieldValue.put('OwnerId',OppOwnerId);
                MaptoFieldValue.put('Forecast_Category__c',OppForcastCategory);
                MaptoFieldValue.put('From_Opportunity__c',oppCloningDataList[0].id);
                MaptoFieldValue.put('CurrencyIsoCode',OppCurrency);
                if(Test.isRunningTest()){
                    MaptoFieldValue.put('Opportunity_Number__c','12121212');
                }
                objectTypeToIsCloneMap.put('Product2',true);
                objectTypeToIsCloneMap.put('OpportunityContactRole',true);
                objectTypeToIsCloneMap.put('RenewalOptions',false);
                objectTypeToIsCloneMap.put('OpportunityDrugProduct',true);
                CON_CRM_OpportunityRenewals.allowCbexQueueable = false;
                Id NewOppId = SRV_CRM_Opportunity.cloneOpportunity(oppCloningDataList[0].id, MaptoFieldValue, true , 0, 0, objectTypeToIsCloneMap);
                CON_CRM_OpportunityRenewals.allowCbexQueueable = true;
                if(String.IsNotBlank(NewOppId)){
                    List<OpportunityLineItem> newOliList = new SLT_OpportunityLineItems().selectByOpportunityIds(new Set<Id>{NewOppId} , new Set<String>{'id','Revenue_Start_Date__c','Revenue_End_Date__c'});
                    Map<Id,OpportunityLineItem> newOliMap = new Map<Id, OpportunityLineItem>(newOliList);
                    
                    List<OpportunityLineItemSchedule> newOlisList = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(newOliMap.keyset(),new Set<String>{'id','OpportunityLineItemId','ScheduleDate'});
                    Map<Id,List<OpportunityLineItemSchedule>> newOLISMap = new Map<Id,List<OpportunityLineItemSchedule>>();
                    for(OpportunityLineItemSchedule olis : newOlisList){
                        if(newOLISMap.containskey(olis.OpportunityLineItemId)){
                            newOLISMap.get(olis.OpportunityLineItemId).add(olis);
                        }else{
                            newOLISMap.put(olis.OpportunityLineItemId,new List<OpportunityLineItemSchedule>{olis});
                        }
                    }
                    List<OpportunityLineItemSchedule> OppLineItemScheduleUpdateList = new List<OpportunityLineItemSchedule>();
                    List<OpportunityLineItem> OppLineItemUpdateList = new List<OpportunityLineItem>();
                    Date OldEndDate = null;
                    Date OldStartDate = null;
                    Integer DayDifference = 0;
                    for(id lineItem : newOLISMap.keyset()){
                        OldEndDate = newOliMap.get(lineItem).Revenue_End_Date__c;
                        OldStartDate = newOliMap.get(lineItem).Revenue_Start_Date__c;
                        Integer TempDayDifference = OldStartDate.daysBetween(OldEndDate);
                        if(TempDayDifference > 7){
                            DayDifference = OldStartDate.monthsBetween(OldEndDate);
                        }else{
                            DayDifference = TempDayDifference;
                        }
                        List<OpportunityLineItemSchedule> tempLineItemScheduleDetailList = newOLISMap.get(lineItem);
                        date firstScheduleDate ;
                        date secondScheduleDate ;
                        integer DayDifferenceofScheduleDate = 0  ;
                        if(tempLineItemScheduleDetailList.size() >= 2){
                            firstScheduleDate = tempLineItemScheduleDetailList[0].ScheduleDate ;
                            secondScheduleDate = tempLineItemScheduleDetailList[1].ScheduleDate ;
                            DayDifferenceofScheduleDate = firstScheduleDate.daysBetween(secondScheduleDate);   
                        }
                        for(OpportunityLineItemSchedule tempolisDT : tempLineItemScheduleDetailList ){
                            OpportunityLineItemSchedule tempOLIStoUpdate = new OpportunityLineItemSchedule();
                            tempOLIStoUpdate.id = tempolisDT.id;
                            if(DayDifferenceofScheduleDate <= 7 && DayDifferenceofScheduleDate != 0){
                                tempOLIStoUpdate.ScheduleDate = (tempolisDT.ScheduleDate).addDays(TempDayDifference + 1 );
                            }else{
                                if(TempDayDifference > 7){
                                    tempOLIStoUpdate.ScheduleDate = (tempolisDT.ScheduleDate).addMonths(DayDifference).addDays(1);
                                }else{
                                    tempOLIStoUpdate.ScheduleDate = (tempolisDT.ScheduleDate).addDays(DayDifference + 1 );
                                }
                            }
                            OppLineItemScheduleUpdateList.add(tempOLIStoUpdate);
                        }
                        
                        OppLineItemUpdateList.add(new OpportunityLineItem(id = lineItem));
                    }
                    if(OppLineItemScheduleUpdateList.size() > 0 ){
                        uow.registerDirty(OppLineItemScheduleUpdateList);
                    }
                    
                    if(OppLineItemUpdateList.size() > 0 ){
                        uow.registerDirty(OppLineItemUpdateList);
                    }
                    
                    uow.commitWork();
                    
                    Opportunity clonedNewOpp = [Select id,Name,Opportunity_Number__c,Legacy_Quintiles_Opportunity_Number__c,Amount,CloseDate,Parent_Number__c,AccountId,Account.Name,From_Opportunity__c,CurrencyIsoCode,Parent_Opportunity__r.Opportunity_Number__c from Opportunity where id =:NewOppId];
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    String Subject = '';
                    String emailBody = '';
                    Subject = 'Opportunity: ' + oppCloningDataList[0].Opportunity_Number__c + ' has been identified as renewable opportunity';
                    emailBody = 'The following opportunity has been identified for as renewable opportunity and cloned: <br/><br/>';
                    emailBody += 'Opportunity Name: ' +'<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+clonedNewOpp.id+'">'+clonedNewOpp.Name + '</a><br/><br/>';
                    emailBody += 'Opportunity Number: ' + clonedNewOpp.Opportunity_Number__c + '<br/><br/>';
                    emailBody += 'Amount (<b>'+clonedNewOpp.CurrencyIsoCode+'</b>) : '+clonedNewOpp.Amount  +  '<br/><br/>';
                    emailBody += 'Expected Close Date : ' + String.Valueof(clonedNewOpp.CloseDate) +  '<br/><br/>';
                    emailBody += 'Parent Opportunity Number: ' + clonedNewOpp.Parent_Opportunity__r.Opportunity_Number__c+  '<br/><br/>';
                    emailBody += 'Account: ' + '<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+clonedNewOpp.AccountId+'">'+clonedNewOpp.Account.Name +'</a><br/><br/>';
                    List<String> toEmailList = new List<String>();
                    List<String> ccEmailList = new List<String>();
                    
                    if(oppCloningDataList[0].Owner.IsActive){
                        toEmailList.add(oppCloningDataList[0].Owner_Email__c);
                    }else{
                        toEmailList.add(oppCloningDataList[0].Last_Modified_By_USER__r.Email);
                    }
                    
                    if(!(String.isBlank(oppCloningDataList[0].Principle_inCharge__r.Email))){
                        toEmailList.add(oppCloningDataList[0].Principle_inCharge__r.Email);  
                    }
                    
                    if(oppCloningDataList[0].Purchase_BNF_s1__r.size()>0){
                        ccEmailList.add(oppCloningDataList[0].Purchase_BNF_s1__r[0].CreatedBy.Email);
                    }else if(oppCloningDataList[0].BNF_s__r.size()>0){
                        ccEmailList.add(oppCloningDataList[0].BNF_s__r[0].CreatedBy.Email);
                    }
                    
                    if(oldOppInActiveOLIList.size() > 0 ){
                        emailBody += 'Note: Following products have not been cloned in the renewal opportunity as they are no longer active:  <br/> <br/>';
                        for(Opportunitylineitem oppLineItem : oldOppInActiveOLIList ){
                            emailBody += oppLineItem.Product2.Name + ' ('+ oppLineItem.SAP_Code__c + ') <br/>';
                        }
                    }
                    message.subject = Subject;
                    message.toEmails = toEmailList;
                    message.ccEmails = ccEmailList;
                    message.staticContent = emailBody;
                    
                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}