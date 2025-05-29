/**
 * This is Contract trigger handler class.
 * version : 1.0
 */
public class DAOH_Contract {
    
    /**
     * This method is used to create or update Contract Life Cycle based on Contract Status
     * @params  newList List<Contract>
     * @params  oldMap Map<Id, Contract>
     * @return  void
     */
    public static void createContractLifeCycleRecord(List<Contract> newList, Map<Id, Contract> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Contract_Lifecycle__c.SobjectType,
                Contract_Stage_Detail__c.SobjectType
               }
        );
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                User_Metric__c.SobjectType
               }
        );
        List<Stage_Gate_Status_Values__c> statusValueList = Stage_Gate_Status_Values__c.getAll().values();
        // Set of Status Values on which Code execute
        Set<String> statusValueSet = new Set<String>();
        for(Stage_Gate_Status_Values__c statusValue : statusValueList) {
            statusValueSet.add(statusValue.Status__c);
        }
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        for(Contract contractRecord : newList) {
            if(contractRecord.Status != null && statusValueSet.contains(contractRecord.Status) && (oldMap == null || contractRecord.Status != oldMap.get(contractRecord.Id).Status)) {
                contractMap.put(contractRecord.Id, contractRecord);
            }
        }
        if(contractMap.size() > 0) {
            List<Contract_Lifecycle__c> lifeCycleList = new SLT_ContractLifeCycle().selectByContractId(contractMap.keySet());
            Map<Id, Map<String, Contract_Lifecycle__c>> contractIdToStageToLifeCycleMap = new Map<Id, Map<String, Contract_Lifecycle__c>>();
            for(Contract_Lifecycle__c lifeCycle : lifeCycleList) {
                if(contractIdToStageToLifeCycleMap.containsKey(lifeCycle.Contract__c)) {
                    contractIdToStageToLifeCycleMap.get(lifeCycle.Contract__c).put(lifeCycle.Status__c, lifeCycle);
                } else {
                    contractIdToStageToLifeCycleMap.put(lifeCycle.Contract__c, new Map<String, Contract_Lifecycle__c>{lifeCycle.Status__c => lifeCycle});
                }
            }
            User_Metric__c userMetricRecord = null;
            List<User_Metric__c> userMetricList = new SLT_UserMetric().selectByUserId(new Set<Id>{UserInfo.getUserId()});
            if(userMetricList.size() > 0) {
                userMetricRecord = userMetricList[0];
            }
            else {
                userMetricRecord = new User_Metric__c(User__c = UserInfo.getUserId());
                uow1.registerNew(userMetricRecord);
                uow1.commitWork();
            }
            List<Contract_Lifecycle__c> allLifeCycleList = new List<Contract_Lifecycle__c>();
            for(Contract contractRecord : contractMap.values()) {
                if(contractIdToStageToLifeCycleMap.containsKey(contractRecord.Id) && contractIdToStageToLifeCycleMap.get(contractRecord.Id).containsKey(contractRecord.Status)) {
                    uow.registerDirty(contractIdToStageToLifeCycleMap.get(contractRecord.Id).get(contractRecord.Status));
                    allLifeCycleList.add(contractIdToStageToLifeCycleMap.get(contractRecord.Id).get(contractRecord.Status));
                }
                else {
                    Contract_Lifecycle__c lifeCycle = new Contract_Lifecycle__c();
                    lifeCycle.Contract__c = contractRecord.Id;
                    lifeCycle.Status__c = contractRecord.Status;
                    lifeCycle.Account__c = contractRecord.AccountId;
                    lifeCycle.CurrencyIsoCode = contractRecord.CurrencyIsoCode;
                    uow.registerNew(lifeCycle);
                    allLifeCycleList.add(lifeCycle);
                }
            }
            List<Contract_Stage_Detail__c> stageDetailList = new List<Contract_Stage_Detail__c>();
            for(Contract_Lifecycle__c lifeCycle : allLifeCycleList) {
                Contract_Stage_Detail__c stageDetail = createContractStageDetailRecord(lifeCycle.Contract__c, lifeCycle.Id, lifeCycle.Status__c, contractMap, oldMap, userMetricRecord.Id);
                uow.registerNew(stageDetail, Contract_Stage_Detail__c.Contract_Lifecycle__c, lifeCycle);
            }
            uow.commitWork();
        }
        
    }
    
    /**
     * This method is used to create Contract Stage Detail 
     * @params  contractId Id
     * @params  lifeCycleId Id
     * @params  contractStatus String
     * @params  contractMap Map<Id, Contract>
     * @params  oldContractMap Map<Id, Contract>
     * @params  userMetricId Id
     * @return  Contract_Stage_Detail__c
     */
    public static Contract_Stage_Detail__c  createContractStageDetailRecord(Id contractId, Id lifeCycleId, String contractStatus, Map<Id, Contract> contractMap,Map<Id, Contract> oldContractMap, Id userMetricId)  {
        Contract_Stage_Detail__c stageDetail = new Contract_Stage_Detail__c();
        stageDetail.Account_LU__c = contractMap.get(contractId).AccountId;
        stageDetail.Actual_Contract_Value__c = contractMap.get(contractId).Actual_Contract_Value__c;
        stageDetail.Analyst_Start_Date__c = contractMap.get(contractId).Analyst_Start_Date__c;
        stageDetail.Date_of_Stage_Entry__c = System.today();
        stageDetail.Contract_Number__c = contractId;
        stageDetail.Contract_Lifecycle__c = lifecycleId;
        stageDetail.Execution_Plan_Start_Date__c = contractMap.get(contractId).Execution_Plan_Start_Date__c;
        stageDetail.Expect_Internal_Budget_Approval__c = contractMap.get(contractId).Expected_Internal_Budget_Approval__c;
        stageDetail.Expect_Internal_Contract_Approval__c = contractMap.get(contractId).Expected_Internal_Contract_Approval__c;
        stageDetail.Owner__c = contractMap.get(contractId).OwnerId;
        stageDetail.Planned_Execution_Date__c = contractMap.get(contractId).Planned_Execution_Date__c;
        stageDetail.Project_Expenses__c = contractMap.get(contractId).Project_Expenses__c;
        stageDetail.Previous_Status__c = oldContractMap == null ? '' : oldContractMap.get(contractId).Status;
        stageDetail.Related_User_Metric__c = userMetricId;
        stageDetail.Receive_Budget_Approval_by_Customer__c = contractMap.get(contractId).Receive_Budget_Approval_by_Customer__c;
        stageDetail.Receive_Contract_Approval_by_Customer__c = contractMap.get(contractId).Receive_Contract_Approval_by_Customer__c;
        stageDetail.Receive_Customer_Budget_Comments__c = contractMap.get(contractId).Receive_Customer_Budget_Comments__c;
        stageDetail.Receive_Customer_Contract_Comments__c = contractMap.get(contractId).Receive_Customer_Contract_Comments__c;
        stageDetail.Receive_Draft_Budget_from_Internal_Team__c = contractMap.get(contractId).Receive_Draft_Budget_from_Internal_Team__c;
        stageDetail.Receive_Draft_Contract_from_Internal__c = contractMap.get(contractId).Receive_Draft_Contract_from_Internal__c;
        stageDetail.Send_1st_Budget_to_Customer_for_Review__c = contractMap.get(contractId).Send_Budget_to_Customer_for_Review__c;
        //stageDetail.Send_1st_Contract_to_Customer__c = contractMap.get(contractId).Send_1st_Contract_to_Customer__c;
        stageDetail.Send_1st_Draft_Budget_to_Internal_Team__c = contractMap.get(contractId).Send_Draft_Budget_to_Internal_Team__c;
        //stageDetail.Send_1st_Draft_Contract_to_Internal_Team__c = contractMap.get(contractId).Send_1st_Draft_Contract_to_Internal_Team__c;
        stageDetail.Status__c = contractMap.get(contractId).Status;
        stageDetail.Start_1st_Draft_Budget__c = contractMap.get(contractId).Start_1st_Draft_Budget__c;
        stageDetail.Start_1st_Draft_Contract__c = contractMap.get(contractId).Start_1st_Draft_Contract__c;
        stageDetail.Triaged_to_Analyst__c = contractMap.get(contractId).Triaged_to_Analyst__c;      
        return stageDetail;
    }
    
    /**
     * This method is used to set Contract Fields
     * @params  List<Contract> newList
     * @params  Map<Id, Contract> oldMap
     * @return  void
     */
    public static void setContractFields(List<Contract> newList, Map<Id, Contract> oldMap) {
        Set<String> contractStatusSet = new Set<String>{ CON_CRM.CONTRACT_STATUS_BUDGET_AT_CUSTOMER_FOR_REVIEW, 
            CON_CRM.CONTRACT_STATUS_BUDGET_WITH_ANALYST_FOR_CUSTOMER_EDITS, 
            CON_CRM.CONTRACT_STATUS_CONTRACT_BEING_PREPARED_BY_CA,
            CON_CRM.CONTRACT_STATUS_CONTRACT_AWAITING_INTERNAL_TEAM_REVIEW,
            CON_CRM.CONTRACT_STATUS_CONTRACT_WITH_ANALYST_FOR_OPERATIONAL_EDITS,
            CON_CRM.CONTRACT_STATUS_CONTRACT_AWAITING_INTERNAL_APPROVAL,
            CON_CRM.CONTRACT_STATUS_CONTRACT_ANALYST_PREPARING_CUSTOMER_CONTRACT_DELIVERABLE,
            CON_CRM.CONTRACT_STATUS_CONTRACT_WITH_ANALYST_FOR_CUSTOMER_EDITS,
            CON_CRM.CONTRACT_STATUS_READY_TO_EXECUTE,
            CON_CRM.CONTRACT_STATUS_CONTRACT_AT_CUSTOMER_FOR_REVIEW };
        Set<String> contractGBORecordTypeSet = new Set<String>{ CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO };
        Set<String> contractLeadBusinessGroup = new Set<String>{ CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_PRODUCT_DEVELOPMENT_INITIATIVES, 
            CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_CONTRACT_RESEARCH_ORGANIZATION, 
            CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_EARLY_CLINICAL_DEVELOPMENT, 
            CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_GLOBAL_LABS, 
            CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_CONSULTING };
        Set<String> contractRecordTypesSet = new Set<String>{ CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_THIRD_PARTY_AGREEMENT, 
            CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_SALES_MEDICAL, 
            CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL, 
            CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER };
        Set<String> contractLQRecordTypeSet = new Set<String>{ CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER, 
            CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO, CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_CONFIDENTIAL_DISCLOSURE_AGREEMENT, 
            CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_SALES_MEDICAL, 
            CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO, CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT,
            CON_CRM.CONTRACT_RECORD_TYPE_MASTER_SERVICE_AGREEMENT,
            CON_CRM.CONTRACT_RECORD_TYPE_MSA_CONSOLIDATION, CON_CRM.CONTRACT_RECORD_TYPE_OTHER_SPECIAL_AGREEMENT, 
            CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_SALES_MEDICAL, CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO, 
            CON_CRM.CONTRACT_RECORD_TYPE_THIRD_PARTY_AGREEMENT, CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL, 
            CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO };       
        List<Task> tasksList = new List<Task>();
        Set<String> fieldSet = new Set<String>{'Id','Parent_Contract__c','Parent_Contract__r.ContractNumber', 'Customer_Contract_Manager_Negotiator__r.FirstName', 'Customer_Contract_Manager_Negotiator__r.LastName','ContractNumber'};
        Set<Id> contractIdSet = new Set<Id>();
        
        for(Contract contract : newList){
            // FEATURE-3828
            if((Trigger.isInsert || contract.LQ_Mulesoft_Sync_Status__c == oldMap.get(contract.Id).LQ_Mulesoft_Sync_Status__c || (contract.LQ_Mulesoft_Sync_Status__c != oldMap.get(contract.Id).LQ_Mulesoft_Sync_Status__c 
                                    && (contract.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  contract.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) && contractLQRecordTypeSet.contains(contract.RecordTypeId)) {
                contract.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            }
            contractIdSet.add(contract.Id);
            if(contract.Initial_Draft_at_High_Confidence_Expense__c == null && 
                     contract.Initial_Draft_at_High_Confidence_Value__c == null && 
                     contract.Is_this_Contract_a_Ballpark__c == CON_CRM.CONTRACT_IS_A_BALLPARK_NO && 
                     contract.Confidence_in_Approval_of_Budget_Draft__c == CON_CRM.CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT &&
                     contract.Actual_Contract_Value__c >= CON_CRM.CONTRACT_ACTUAL_CONTRACT_VALUE &&
                     contractStatusSet.contains(contract.Status)){
                contract.Initial_Draft_at_High_Confidence_Value__c = contract.Actual_Contract_Value__c;
                contract.Initial_Draft_at_High_Confidence_Expense__c = contract.Project_Expenses__c;
                contract.Initial_Draft_at_High_Confidence_Date__c = System.today();
            }
            if(contractGBORecordTypeSet.contains(contract.RecordTypeId) && contract.Update_Contract_Status__c == CON_CRM.CONTRACT_STATUS_ON_HOLD_DUE_TO_COVID_19) {
                contract.Status = CON_CRM.CONTRACT_STATUS_ON_HOLD;
            } else if(contractGBORecordTypeSet.contains(contract.RecordTypeId) && contract.Update_Contract_Status__c == CON_CRM.CONTRACT_STATUS_CANCELLED_DUE_TO_COVID_19) {
                contract.Status = CON_CRM.CONTRACT_STATUS_CONTRACT_TERMINATED;
            } else if(contract.Status != CON_CRM.CONTRACT_STATUS_ACTIVATED){
                if(contract.Unsigned_Status__c != CON_CRM.CONTRACT_STATUS_EXECUTED && (Trigger.isInsert || (Trigger.isUpdate && contract.Update_Contract_Status__c != oldMap.get(contract.Id).Update_Contract_Status__c))){
                    if(contract.Update_Contract_Status__c == CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED){
                        contract.Status = CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED;
                    }else if(contract.Update_Contract_Status__c == CON_CRM.CONTRACT_STATUS_CONTRACT_AMENDED && contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_MASTER_SERVICE_AGREEMENT){
                        contract.Status = CON_CRM.CONTRACT_STATUS_CONTRACT_AMENDED;
                    }else {    
                        if(contract.Status != CON_CRM.CONTRACT_STATUS_CONTRACT_EXECUTED && contractGBORecordTypeSet.contains(contract.RecordTypeId) && !String.isBlank(contract.Update_Contract_Status__c)) {
                            contract.Status =  contract.Update_Contract_Status__c;
                        }
                    }
                }
                /*
                else{
                    if(contractGBORecordTypeSet.contains(contract.RecordTypeId)){
                        contract.Status = CON_CRM.CONTRACT_STATUS_CONTRACT_EXECUTED;
                        contract.Update_Contract_Status__c = CON_CRM.CONTRACT_STATUS_CONTRACT_EXECUTED;
                    }
                }
                */
            }        
            //Contract alert when Global P/U Field populated
            if(contract.Global_Project_Unit__c != null && (oldMap == null || oldMap.get(contract.Id).Global_Project_Unit__c == null)){
                contract.Date_Global_P_U_entered__c = System.today();
            }
            //Contract entered Budget at Customer Review
            if(oldMap != null && (contract.Update_Contract_Status__c != oldMap.get(contract.Id).Update_Contract_Status__c)){
                if(oldMap.get(contract.Id).Status == CON_CRM.CONTRACT_STATUS_BUDGET_AT_CUSTOMER_FOR_REVIEW){
                    //contract.Entered_Budget_at_Customer_Review__c = true;
                }
                if(oldMap.get(contract.Id).Status == CON_CRM.CONTRACT_STATUS_CONTRACT_AT_CUSTOMER_FOR_REVIEW){
                    contract.Entered_Contract_at_Customer_for_Review__c = true;
                }
            }
            
            //Field Update - Date Contract value changed
            if( contract.Actual_Contract_Value__c != null && (oldMap == null || contract.Actual_Contract_Value__c != oldMap.get(contract.Id).Actual_Contract_Value__c )){
                contract.Date_actual_contract_value_changed__c = System.today();
            }
            //Field Update - Prior Contract Value
            if(contract.Actual_Contract_Value__c != null ){
                if(Trigger.old == null){
                    contract.Previous_Actual_Contract_Value__c = null;
                }
            }
            else if(oldMap != null && (contract.Actual_Contract_Value__c != oldMap.get(contract.Id).Actual_Contract_Value__c )){
                contract.Previous_Actual_Contract_Value__c = oldMap.get(contract.Id).Actual_Contract_Value__c;
            }
            //Field Update - Project Number = Opp Number
            if(contract.Project_Number__c == null && (contractLeadBusinessGroup.contains(contract.Lead_Business_Group__c))){
                contract.Project_Number__c = contract.Opportunity_Number__c;
            }
            //Field Update - Analyst Start Date
            if( contract.Status == CON_CRM.CONTRACT_STATUS_START_PREPARING_BUDGET && contract.Analyst_Start_Date__c == null ){
                contract.Analyst_Start_Date__c = System.today();
            }
            //Contract Executed - Update Associate Opportunity
            if(contract.Status == CON_CRM.CONTRACT_STATUS_CONTRACT_EXECUTED && (oldMap == null || oldMap.get(contract.Id).Status != CON_CRM.CONTRACT_STATUS_CONTRACT_EXECUTED) && contractRecordTypesSet.contains(contract.RecordTypeId)){
                Task t = new Task();
                t.OwnerId = contract.OwnerId;
                t.Subject = 'Please Update the Opportunity Associated with this Contract';
                t.Status = 'Not Started';
                t.Priority = 'Medium';
                t.WhatId = contract.Id;
                t.ActivityDate = System.today();
                tasksList.add(t);
            }
            //Draft Labor Budget & Draft Expense Budget at Confidence High
            if(contract.Confidence_in_Approval_of_Budget_Draft__c == CON_CRM.CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT && contract.Initial_Draft_at_High_Confidence_Expense__c == null && contract.Initial_Draft_at_High_Confidence_Value__c == null && contract.Is_this_Contract_a_Ballpark__c != CON_CRM.CONTRACT_IS_A_BALLPARK_YES && contractStatusSet.contains(contract.Status)){
                contract.Initial_Draft_at_High_Confidence_Expense__c = contract.Project_Expenses__c;
                contract.Initial_Draft_at_High_Confidence_Value__c = contract.Actual_Contract_Value__c;
                contract.Initial_Draft_at_High_Confidence_Date__c = System.today();
            }
            //Field Update - Change and Work Order ballpark name
            if(contract.Is_this_Contract_a_Ballpark__c == CON_CRM.CONTRACT_IS_A_BALLPARK_YES && (contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER || contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO || contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO) && (contract.Lead_Business_Group__c == CON_CRM.CONTRACT_LEAD_BUSINESS_GROUP_CONTRACT_RESEARCH_ORGANIZATION || contract.Division_Business_Unit__C == CON_CRM.CONTRACT_DIVISION_BUSINESS_UNIT) && contract.Owner_Role__c != CON_CRM.CONTRACT_OWNER_ROLE && !contract.Name.contains(CON_CRM.CONTRACT_BALLPARK)){
                contract.Sequential_Reference__c = CON_CRM.CONTRACT_BALLPARK+' - ' + contract.Sequential_Reference__c;
                contract.Name = CON_CRM.CONTRACT_BALLPARK+' - ' + contract.Name;
            }
            //Field Update - Contract Parent Number
            if(contract.Parent_Contract__c != null ){
                contractIdSet.add(contract.Parent_Contract__c);
            }
            //Field Update - Email Approval Received Date
            if(contract.Email_Approval_Received__c == true && (oldMap != null && oldMap.get(contract.Id).Email_Approval_Received__c != true )){
                contract.Email_Approval_Received_Date__c = System.today();
            }
            //Field Update - Execution Plan Start Date
            // adding Trigger.isUpdate in condition because CreatedDate not available in before insert context
            if(Trigger.isUpdate && contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT && contract.Execution_Plan_Start_Date__c == null && contract.Requested_Contract_Type__c != null ){
                contract.Execution_Plan_Start_Date__c = date.newinstance(contract.CreatedDate.year(), contract.CreatedDate.month(), contract.CreatedDate.day());
            }
            //Field Update - Status Change Date
            if((oldMap == null || contract.Status != oldMap.get(contract.Id).Status)){
                contract.Status_change_date__c = System.today();
            }
            //Field Update - Triage to Analyst Date
            if( contract.Triaged_to_Analyst__c == null && contract.Status == CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED ){
                contract.Triaged_to_Analyst__c = System.today();
            }
            //Initial Budget Review Values
            /*
            if(contract.Status == CON_CRM.CONTRACT_STATUS_BUDGET_AT_CUSTOMER_FOR_REVIEW && contract.Initial_Draft_to_Customer_Value__c == null && contract.Initial_Draft_Project_Expenses__c == null ){
                contract.Initial_Draft_Project_Expenses__c = contract.Project_Expenses__c;
                contract.Initial_Draft_to_Customer_Date__c = System.today();
                contract.Initial_Draft_to_Customer_Value__c = currentContract.Actual_Contract_Value__c;
            }
            */
            if((contract.Status == CON_CRM.CONTRACT_STATUS_PENDING_ASSIGNMENT && (oldMap == null || oldMap.get(contract.Id).Status != CON_CRM.CONTRACT_STATUS_PENDING_ASSIGNMENT)) || (contract.Status == CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED && (oldMap == null || oldMap.get(contract.Id).Status != CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED))){
                contract.Processing_Source__c = CON_CRM.CONTRACT_GLOBAL_CONTRACT_TRIAGE_APP;
            }
            if(contract.Status == CON_CRM.CONTRACT_STATUS_PENDING_ASSIGNMENT && contract.Owner.Full_User_Name__c == CON_CRM.CONTRACT_GLOBAL_SALES_OPERATIONS && ((oldMap == null && contract.OwnerId != null) || contract.OwnerId != oldMap.get(contract.Id).OwnerId)){
                contract.Status = CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED;
            }
            if(Trigger.isUpdate) {
                /*if(contract.Sent_Budget_Loaded_to_Peoplesoft__c && contract.Initial_revenue_captured__c == NULL) {   
                	contract.Initial_revenue_captured__c = contract.Total_Pick_up_excluding_Outcome__c * 0.7;
                }
                if(contract.Sent_Budget_Loaded_to_Peoplesoft__c && contract.Date_Sent_Budget_Loaded_to_Peoplesoft__c == NULL) {    
                	contract.Date_Sent_Budget_Loaded_to_Peoplesoft__c = System.today();
                }*/
                if(contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO || contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO || contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO || contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO) {
                    contract.Contract_Execution_Date_Actual_Expected__c = contract.Planned_Execution_Date__c;
                    contract.Unsigned_Status__c = contract.Update_Contract_Status__c;
                    contract.Unsigned_Status_Change_Date__c = System.today();
                }
                
            }
        }
        if(tasksList.size() > 0) {
            try{
                insert tasksList;
            }catch(Exception e){
                System.debug('-Exception--'+e);
            }
            
        }
        Map<Id, Contract> contractIdToContractMap = new Map<Id, Contract>();
        if(contractIdSet.size() > 0) {
            contractIdToContractMap = new SLT_Contract().fetchParentContract(contractIdSet, fieldSet);
        }
        for(Contract cntrt : newList) {
            if(cntrt.Parent_Contract__c != null) {
                cntrt.Parent_Contract_Number__c = Decimal.valueOf(contractIdToContractMap.get(cntrt.Parent_Contract__c).ContractNumber);
            }
            //Field Update - Customer Contract Manager
            if(cntrt.Customer_Contract_Manager_Negotiator_Txt__c == null && cntrt.Customer_Contract_Manager_Negotiator__c != null){
                Contract tempContract = contractIdToContractMap.get(cntrt.Id);
                cntrt.Customer_Contract_Manager_Negotiator_Txt__c = tempContract.Customer_Contract_Manager_Negotiator__r.FirstName + ' ' + tempContract.Customer_Contract_Manager_Negotiator__r.LastName;
            }
        }
    }
    
    /**
     * This method is used to set Parent Contract Field on CNF - GBO contracts
     * @params  List<Contract> newList
     * @return  void
     */
    public static void setParentContractFieldsOnCNF(List<Contract> newList) {
        Set<String> projectNumberSet = new Set<String>();
        Set<String> changeOrderNumberSet = new Set<String>();
        for(Contract cont : newList) {
            if(cont.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO) {
                if(cont.Project_Number__c != null) {
                    projectNumberSet.add(cont.Project_Number__c);
                }
                if(cont.Change_Order_Number__c != null) {
                    changeOrderNumberSet.add(cont.Change_Order_Number__c);
                }
            }
        }
        
        if(projectNumberSet.size() > 0 || changeOrderNumberSet.size() > 0) {
            Set<String> fieldSet = new Set<String>{'Id', 'Change_Order_Parent__c', 'Project_Number__c', 'Change_Order_Number__c'};
            Map<Id, Contract> cnfGBOContractsMap = new Map<Id, Contract>();
            cnfGBOContractsMap = new SLT_Contract().selectCNFContractsByProjAndChangeOrderNumber(projectNumberSet, changeOrderNumberSet, fieldSet);
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Contract.SobjectType
                        }
            );
            Boolean toCommit = false;
            for(Contract cont : newList) {
                for(Contract cnfCont : cnfGBOContractsMap.values()) {
                    if(cont.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO) {
                        if(cont.Project_Number__c != null && cont.Change_Order_Number__c != null 
                           && cont.Project_Number__c == cnfCont.Project_Number__c && cont.Change_Order_Number__c == cnfCont.Change_Order_Number__c) {
                               cnfCont.Change_Order_Parent__c = cont.id;
                               uow.registerDirty((Contract)cnfCont);
                               toCommit = true;
                           }
                    }
                }
            }
            if(toCommit){
                uow.commitWork();
            }
        }
    }
    public static void linkToParentContract(List<Contract> newList, Map<Id, Contract> oldMap) {
        List<Contract> filteredContracts = new List<Contract>();
        Set<Id> parentContractIdSet = new Set<Id>();
        for(Contract contract : newList){
            if(Trigger.isInsert || (oldMap != null && (oldMap.get(contract.Id).Parent_Contract__c == null)) && contract.Parent_Contract__c != null){
                filteredContracts.add(contract);
                parentContractIdSet.add(contract.Parent_Contract__c);
            }
        }
        if(filteredContracts.size() > 0){
            Set<String> fieldSet = new Set<String>{'RecordTypeName__c','SourceField__c','TargetField__c','Id'};
            List<CRM_MSA_Contract_Mapping__mdt> msaContractMappingList = new List<CRM_MSA_Contract_Mapping__mdt>();
            msaContractMappingList = new SLT_MSAContractMapping().fetchMSAContractMapping(fieldSet);
            Map<String,List<CRM_MSA_Contract_Mapping__mdt>> groupedMsaContractMappings = new Map<String,List<CRM_MSA_Contract_Mapping__mdt>>();
            List<CRM_MSA_Contract_Mapping__mdt> currentMDTList = new List<CRM_MSA_Contract_Mapping__mdt>();
            Set<String> fieldsToQuery = new Set<String>();
            for(CRM_MSA_Contract_Mapping__mdt msaCtrMapping : msaContractMappingList){
                fieldsToQuery.add(msaCtrMapping.SourceField__c);
                if(groupedMsaContractMappings.containsKey(msaCtrMapping.RecordTypeName__c)){
                    currentMDTList = groupedMsaContractMappings.get(msaCtrMapping.RecordTypeName__c);
                    currentMDTList.add(msaCtrMapping);
                    groupedMsaContractMappings.put(msaCtrMapping.RecordTypeName__c,currentMDTList);
                }else{
                    currentMDTList = new List<CRM_MSA_Contract_Mapping__mdt>();
                    currentMDTList.add(msaCtrMapping);
                    groupedMsaContractMappings.put(msaCtrMapping.RecordTypeName__c,currentMDTList);
                }
            }
            Map<Id, Contract> parentContractMap = new SLT_Contract().selectByContractId(parentContractIdSet,fieldsToQuery);
            Map<Id, Contract> childIdToParentContractMap = new Map<Id, Contract>();
            if(parentContractMap.size() > 0){
                Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Contract.getRecordTypeInfosById();
                for(Contract  currentFilteredContract : filteredContracts){
                    String currentContractrecordTypeDevName =  recordTypeInfoIdMap.get(currentFilteredContract.RecordTypeId).getName();
                    if(groupedMsaContractMappings.containsKey(currentContractrecordTypeDevName)){
                        List<CRM_MSA_Contract_Mapping__mdt> contractMappingList = groupedMsaContractMappings.get(currentContractrecordTypeDevName);
                        for(CRM_MSA_Contract_Mapping__mdt msaMappingRecord : contractMappingList){
                            if(parentContractMap.get(currentFilteredContract.Parent_Contract__c).get(msaMappingRecord.SourceField__c) != null){
                                if(msaMappingRecord.SourceField__c == 'ContractNumber'){
                                    currentFilteredContract.put(msaMappingRecord.TargetField__c, Decimal.valueOf(String.valueOf(parentContractMap.get(currentFilteredContract.Parent_Contract__c).get(msaMappingRecord.SourceField__c)))); 
                                } else{
                                    currentFilteredContract.put(msaMappingRecord.TargetField__c, parentContractMap.get(currentFilteredContract.Parent_Contract__c).get(msaMappingRecord.SourceField__c)); 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    public static void updateContract(List<Contract> newList) {
        List<Contract> contractsToUpdate = new  List<Contract>();
        Set<Id> contractsToUpdateIdsList = new  Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id','Ultimate_Parent_Contract_Number__c','ContractNumber'};
        for(Contract currentContract : newList) {
            if(currentContract.Parent_Contract__c == null){
                contractsToUpdateIdsList.add(currentContract.Id);
            }
        }
        if(contractsToUpdateIdsList.size() > 0){
            contractsToUpdate = new SLT_Contract().selectByContractIdList(contractsToUpdateIdsList,fieldSet);
            for(Contract contractToUpdt : contractsToUpdate){
                contractToUpdt.Ultimate_Parent_Contract_Number__c = Decimal.valueOf(contractToUpdt.ContractNumber);
            }
        }
        try{
            UTL_ExecutionControl.stopTriggerExecution = true;
            update contractsToUpdate;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }catch(Exception e){
            
        }
    }
    /**
     * This method is used to update Contract Fields on before trigger
     * @params  List<Contract> newList
     * @params  Map<Id, Contract> oldMap
     * @return  void
     * 2970
     */
    public static void updateContractFields(List<Contract> newList, Map<Id, Contract> oldMap) {
        List<String> opportunityNumberList = new List<String>();
        Set<String> oppIds = new Set<String>(); 
        for(Contract currentContract : newList){
            if(currentContract.Opportunity_Number__c != null && currentContract.Opportunity_Number__c != '' && currentContract.RecordtypeId != CON_CRM.CONTRACT_RECORD_TYPE_PRM_CONTRACT){
                opportunityNumberList.add(currentContract.Opportunity_Number__c);
            }else if(Trigger.isInsert && currentContract.Opportunity__c != null && currentContract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT){
                oppIds.add(currentContract.Opportunity__c);
            }
        }
        if(opportunityNumberList.size()>0 || oppIds.size()>0){
            List<Opportunity> opportunityList = new SLT_Opportunity().getOpportunityByFieldCondition(new Set<String>{'Id','Opportunity_Number__c','AccountId', 'Line_of_Business__c', 'Global_project_unit__c'}, opportunityNumberList, oppIds);
            Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
            Map<String,Opportunity> oppIdMap = new Map<String,Opportunity>();
            for(Opportunity currentOpp : opportunityList){
                oppMap.put(currentOpp.Opportunity_Number__c, currentOpp);
                oppIdMap.put(currentOpp.Id, currentOpp);
            }
            Set<Id> iqvaiContractUsersSet = new Set<Id>();
            List<User> globalSalesOpUserList = new SLT_User().selectUserByName('%Global Sales Operations%');
            User globalSalesOpUser = new User();
            if(globalSalesOpUserList.size() > 0){
                globalSalesOpUser = globalSalesOpUserList[0];
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                for(Contract currentContract : newList){
                    if(currentContract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT && currentContract.Status == CON_CRM.CONTRACT_STATUS_PENDING_ASSIGNMENT && (oldMap == null || oldMap.get(currentContract.Id).Status != CON_CRM.CONTRACT_STATUS_PENDING_ASSIGNMENT)){
                        if(oppMap != null && oppMap.get(currentContract.Opportunity_Number__c) != null){
                            // currentContract.Lead_Business_Group__c = oppMap.get(currentContract.Opportunity_Number__c).Lead_Business_Group__c;
                            currentContract.AccountId = oppMap.get(currentContract.Opportunity_Number__c).AccountId;
                        }
                        if(Trigger.isInsert && globalSalesOpUser != null && globalSalesOpUser.Id != null){
                            currentContract.OwnerId = globalSalesOpUser.Id;
                        }
                    }
                    if(currentContract.IQVIA_Contract_Manager_Contact__c != null && (Trigger.isUpdate || (Trigger.isInsert && globalSalesOpUser == null)) && (oldMap == null || currentContract.IQVIA_Contract_Manager_Contact__c != oldMap.get(currentContract.Id).IQVIA_Contract_Manager_Contact__c)){
                        iqvaiContractUsersSet.add(currentContract.IQVIA_Contract_Manager_Contact__c);
                        //currentContract.OwnerId = currentContract.IQVIA_Contract_Manager_Contact__c;
                        //currentContract.Status = CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED;
                    }
                    
                    if(Trigger.isInsert && currentContract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT){
                        Opportunity opp = null;
                        if(oppMap.get(currentContract.Opportunity_Number__c) != null){
                            opp = oppMap.get(currentContract.Opportunity_Number__c);
                        }else if(oppIdMap.get(currentContract.Opportunity__c) != null){
                            opp = oppIdMap.get(currentContract.Opportunity__c);
                        }
                        
                        if(opp != null && opp.Line_of_Business__c == 'Outcome'){
                            currentContract.Global_Project_Unit__c = currentContract.Global_Project_Unit__c == null ? opp.Global_project_unit__c : currentContract.Global_Project_Unit__c;
                            currentContract.Lead_Business_Group__c = currentContract.Lead_Business_Group__c == null ? 'Integrated Health Services' : currentContract.Lead_Business_Group__c;
                            currentContract.Division_Business_Unit__c = currentContract.Division_Business_Unit__c == null ? 'Outcome' : currentContract.Division_Business_Unit__c;
                            currentContract.Delivery_Unit__c = currentContract.Delivery_Unit__c == null ? 'RWE' : currentContract.Delivery_Unit__c;
                        }
                    }
                }
                if(iqvaiContractUsersSet.size() > 0){
                    List<User> iqvaiContractUsersList = new SLT_User().selectActiveUserByUserId(iqvaiContractUsersSet, new Set<String>{'Id'});
                    Set<Id> activeContractUsers = new Set<Id>();
                    for(User user : iqvaiContractUsersList){
                        activeContractUsers.add(user.Id);
                    }
                    for(Contract currentContract : newList){
                        if(currentContract.IQVIA_Contract_Manager_Contact__c != null && activeContractUsers.contains(currentContract.IQVIA_Contract_Manager_Contact__c)){
                            currentContract.OwnerId = currentContract.IQVIA_Contract_Manager_Contact__c;
                            currentContract.Status = CON_CRM.CONTRACT_STATUS_ASSIGNED_NOT_STARTED;
                        }
                    }
                }
            }  
        }
    }
    /**
     * This method is used to check Contract record deletion if user is admin
     * @params  List<Contract> newList
     * @return  void
     * 3688
     */
    public static void checkRecordDeletion(List<Contract> newList) {
        Set<String> fieldsToQuery = new Set<String>{'Id','Profile.Name'};
        Map<Id, User> usersMap = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()}, fieldsToQuery); 
        
        if(usersMap.containsKey(UserInfo.getUserId())){
            if(usersMap.get(UserInfo.getUserId()).Profile.Name != CON_CRM.SYSTEM_ADMIN_PROFILE && usersMap.get(UserInfo.getUserId()).Profile.Name != CON_CRM.MULESOFT_SYS_ADMIN_PROFILE){
                for(Contract currentContract : newList){
                    currentContract.addError(System.label.CRM_CL0029_CTR_CANNOT_DELETE);
                }
            }
        }
    }
    public static void updateContractsBasedOnOppFields(List<Contract> newList) {
        Set<String> filteredOppNumbers = new Set<String>();
        List<Contract> contractsList = new List<Contract>();
        for(Contract currentContract : newList){
            if(currentContract.Opportunity_Number__c != null && currentContract.Created_By_FormAssembly__c == true && currentContract.RecordTypeId != CON_CRM.CONTRACT_RECORD_TYPE_PRM_CONTRACT ){
                filteredOppNumbers.add(currentContract.Opportunity_Number__c);
                contractsList.add(currentContract);
            }
        }
        if(contractsList.size()>0){
            Map<Id, Opportunity> opportunityMap = new SLT_Opportunity().selectByOpportunityNumber(filteredOppNumbers, new Set<String>{'Id','AccountId','Legacy_Quintiles_Opportunity_Number__c', 'Global_project_unit__c', 'Line_of_Business__c'});
            Map<String, Opportunity> oppNumberToOppMap = new Map<String, Opportunity>();
            for(Id oppId : opportunityMap.keySet()){
                oppNumberToOppMap.put(opportunityMap.get(oppId).Legacy_Quintiles_Opportunity_Number__c, opportunityMap.get(oppId));
            }
            for(Contract currentContract : contractsList){
                if(oppNumberToOppMap.get(currentContract.Opportunity_Number__c) != null){
                    currentContract.Opportunity__c = oppNumberToOppMap.get(currentContract.Opportunity_Number__c).Id;
                    currentContract.AccountId = oppNumberToOppMap.get(currentContract.Opportunity_Number__c).AccountId;
                    //currentContract.Lead_Business_Group__c = oppNumberToOppMap.get(currentContract.Opportunity_Number__c).SOURCEFIELD_TBD;
                    currentContract.Global_Project_Unit__c = oppNumberToOppMap.get(currentContract.Opportunity_Number__c).Global_project_unit__c;
                    
                    if(oppNumberToOppMap.get(currentContract.Opportunity_Number__c).Line_of_Business__c == 'Outcome'){
                        currentContract.Lead_Business_Group__c = 'Integrated Health Services';
                        currentContract.Division_Business_Unit__c = 'Outcome';
                        currentContract.Delivery_Unit__c = 'RWE';
                    }
                }
            }
        }
    }
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Contract> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Contract> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contract contract : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(contract.LQ_Contract_Id__c != null) {
                outBound.LQ_Id__c = contract.LQ_Contract_Id__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTRACT_OBJECT;
            outBound.RecordID__c = contract.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    
    /**
     * created By Devang Gandhi
     * This method set the Initial Draft At High Confidence Date  and Value and Expence fields.
     * This fields depend on Confidence in Approval of Budget Draft  field's value.
     * @params newContractList
     * @return  none
     */ 
    public static void updateContractFieldsValue(List<Contract> newContractList, Map<Id, Contract> oldMap){
        if(Trigger.isBefore &&  Trigger.isUpdate ) {
            for(Contract contract : newContractList){
                if(contract.Confidence_in_Approval_of_Budget_Draft__c == CON_CRM.CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT_LOW 
                     && oldMap.get(contract.Id).Confidence_in_Approval_of_Budget_Draft__c == CON_CRM.CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT ) { 
                    contract.Initial_Draft_at_High_Confidence_Date__c = NULL;
                    contract.Initial_Draft_at_High_Confidence_Expense__c = NULL;
                    contract.Initial_Draft_at_High_Confidence_Value__c = NULL;
                     }
            }
        }
    }

    /**
     * This method is used to set Contract Fields From Parent Contract Fields on before trigger
     * @params  List<Contract> newList
     * @params  Map<Id, Contract> oldMap
     * @return  void
     */
    public static void setContractFieldsFromParentContractFields(List<Contract> newList, Map<Id, Contract> oldMap) {
        List<Contract> contractWithParentContract = new List<Contract>();
        Set<Id> parentContract = new Set<Id>();
        Set<String> fieldsets = new Set<String>();
        Set<Id> ContracRrecordTypesets = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER , CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO , CON_CRM.CONTRACT_RECORD_TYPE_GENERIC_CONTRACT, CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO, CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO };

        for(Contract contract: newList){
            if(ContracRrecordTypesets.contains(contract.RecordTypeId) && contract.Parent_Contract__c != null){
                contractWithParentContract.add(contract);
                parentContract.add(contract.Parent_Contract__c);
            }
        }
        for(Schema.FieldSetMember f : SObjectType.Contract.FieldSets.ParentContractFieldsCopyIntoContract.getFields()) {
            fieldsets.add(f.getFieldPath());
        }
        if(contractWithParentContract.size() > 0){
            Map<Id, Contract> parentContractMap = new SLT_Contract().selectByContractId(parentContract, fieldsets);
            for(Contract contract: contractWithParentContract){
                if(Trigger.isInsert || (Trigger.isUpdate && (contract.RecordTypeId != oldMap.get(contract.id).RecordTypeId || contract.Parent_Contract__c != oldMap.get(contract.id).Parent_Contract__c))){
                    for(String fieldAPI: fieldsets) {
                        if(parentContractMap.get(contract.Parent_Contract__c).get(fieldAPI) != null){
                            contract.put(fieldAPI,parentContractMap.get(contract.Parent_Contract__c).get(fieldAPI));
                        }
                    }
                }
            }    
        }
    }
    
    /**
     * This method is used to update Survey PIC on latest Client_Sat_Survey__c object
     * @params  List<Contract> newList
     * @params  Map<Id, Contract> oldMap
     * @return  void
     */
    public static void updateSurveyPIC(List<Contract> newList, Map<Id, Contract> oldMap){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> RecordTypeSet1 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL};
        Set<Id> RecordTypeSet2 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL};
        
        List<Update_Survey_Event__e> updateSurveyEventList_e = new List<Update_Survey_Event__e>();
        Update_Survey_Event__e updateSurveyEvent = null;
        
        for(Contract ct : newList) {
            if((Trigger.isInsert || (Trigger.isUpdate && ct.IQVIA_Project_Manager_Contact__c != oldMap.get(ct.id).IQVIA_Project_Manager_Contact__c)) && ct.IQVIA_Project_Manager_Contact__c != null){//also check project manager not null
                if((RecordTypeSet1.contains(ct.RecordTypeId) || RecordTypeSet2.contains(ct.RecordTypeId)) && ct.Opportunity__c != null) {
                    if(!oppIdSet.contains(ct.Opportunity__c)){
                        oppIdSet.add(ct.Opportunity__c);
                        updateSurveyEvent = new Update_Survey_Event__e(Related_record_ID__c = ct.Id, Survey_PIC_ID__c = ct.IQVIA_Project_Manager_Contact__c, Opportunity_ID__c = ct.Opportunity__c, Is_Insert__c = Trigger.isInsert, Record_Type_ID__c = ct.RecordTypeId);
                        updateSurveyEventList_e.add(updateSurveyEvent);
                    }
                }
            }
        }
        if(updateSurveyEventList_e.size()>0){
            List<Database.SaveResult> results = EventBus.publish(updateSurveyEventList_e); 
            system.debug(results);
        }
    }

    /**
     * This method is used to set the Update Contract status and CNF/CO Log Status field.
     * These field value will be dependent on each other's value.
     * @params newList
     * @params oldMap
     * @return void
     */ 
    public static void updateContractFieldValues(List<Contract> newList, Map<Id, Contract> oldMap) {
        for(Contract contract : newList) {
            if(contract.RecordTypeId == CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO) {
                if(contract.Is_the_CNF_Accepted__c == CON_CRM.REJECTED) {
                    contract.Update_Contract_Status__c = CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED;
                }
                else if(contract.Update_Contract_Status__c == CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED) {
                    contract.Is_the_CNF_Accepted__c = CON_CRM.REJECTED;
                }
            }
        }
    }
}