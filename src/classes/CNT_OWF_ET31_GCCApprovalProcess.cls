public class CNT_OWF_ET31_GCCApprovalProcess {
    public Id recordId;
    Public String orgDomainUrl{get;set;}
    public String collectionToolLink{get;set;}
    public Bid_History__c bidHistory{get;set;}
    
    public ProcessInstanceWorkitem processInstanceWorkitem{get;set;}
    public String processInstanceWorkitemForOperationalLead1{get;set;}
    public String processInstanceWorkitemForOperationalLead2{get;set;}
    public ProcessInstanceStep processInstanceStep{get;set;}
    Public ProcessInstance processInstance{get;set;}
    
    public Id getRecordId()
    {
        return recordId;
    }
    public void setRecordId(Id incomingId)
    {
        if(incomingId!=null)
        {
            recordId = incomingId;
            fetchfieldsAndInitializeObject(recordId); 
            fetchProcessInstanceWorkitem(recordId);
            fetchProcessInstanceStep(recordId);
            fetchProcessInstance(recordId);
            fetchorgDomainUrl(recordId);
            
        }        
    }
    
    public String fetchorgDomainUrl(Id recordId) {
        orgDomainUrl = URL.getOrgDomainUrl().toExternalForm();
        collectionToolLink = orgDomainUrl + '/lightning/n/OWF_Generic_Collection_Tool?c__Bid_History='+recordId;
        return orgDomainUrl;
    }
    public ProcessInstance fetchProcessInstance(Id recordId) {
        processInstance = [Select Id,TargetObjectId,Status from ProcessInstance WHERE TargetObjectId =: recordId order by CreatedDate desc LIMIT 1];
        return processInstance;
    }
    public void fetchProcessInstanceWorkitem(Id recordId) {
        ProcessInstance instance = [Select Id,TargetObjectId from ProcessInstance WHERE TargetObjectId =: recordId order by CreatedDate desc LIMIT 1];
        List<ProcessInstanceWorkitem> processInstanceWorkitemList= [SELECT Id,Actor.name from ProcessInstanceWorkitem WHERE ProcessInstanceId =: instance.Id order by CreatedDate desc];
        if(!processInstanceWorkitemList.isEmpty()) {
            for(ProcessInstanceWorkitem item : processInstanceWorkitemList) {
                if(bidHistory.Operational_Lead1__c != null) {
                    if(item.Actor.name == bidHistory.Operational_Lead1__r.name) {
                        processInstanceWorkitemForOperationalLead1 = item.Id;
                    }
                }
                if(bidHistory.Operational_Lead2__c != null) {
                    if(item.Actor.name == bidHistory.Operational_Lead2__r.name) {
                        processInstanceWorkitemForOperationalLead2 = item.Id;
                    }
                }
            }
        }
    }
    
    public ProcessInstanceStep fetchProcessInstanceStep(Id recordId) {
        ProcessInstance instance = [Select Id,TargetObjectId from ProcessInstance WHERE TargetObjectId =: recordId order by CreatedDate desc LIMIT 1];
        List<ProcessInstanceStep> processInstanceStepList= [SELECT Id,Comments,Actor.Name from ProcessInstanceStep WHERE ProcessInstanceId =: instance.Id and StepStatus =: CON_OWF.OWF_STATUS_REJECTED order by CreatedDate desc LIMIT 1];
        processInstanceStep = !processInstanceStepList.isEmpty() ? processInstanceStepList[0] : null;
        return processInstanceStep;
    }
    public Bid_History__c fetchfieldsAndInitializeObject(Id recordId)
    {
        Set<Id> recordIdsSet = new Set<Id>();
        recordIdsSet.add(recordId);
        Set<String> bidHistoryFieldSet = new Set<String>{'Bid_History_Account__r.Name','Expected_Service_Start_Date__c','Protocol_LOS__c','Analyst_Profile__c','Calls_Emails_Contacts_Monthly_Inbound__c','Calls_Emails_Contacts_Monthly_Outbound__c',
            'Bid_Due_Date__c','Service_Scope__c','Budget_Deliverable__c','Is_there_a_Client_Bid_Grid__c','Win_Probability__c','Estimated_Fees__c','Bid_History_Related_Opportunity__r.Amount','Average_Handling_Time_Minutes__c',
            'Is_this_part_of_a_Program__c','Associated_CRM_Numbers__c','Pertinent_Details_Specific_Rebid_Request__c','Name','Training_Duration_Days__c','Service_Level_Agreements__c','Hubs__c'
            ,'Bid_History_Related_Opportunity__r.Business_Unit__c','Bid_History_Related_Opportunity__r.Potential_Regions__c','Pricing_Model__c','Assumption_for_Variable_Cost__c','Running_Service_Fees_Exc_Translation__c'
            ,'Bid_History_Related_Opportunity__r.FSP__c','Bid_History_Related_Opportunity__r.Global_project_unit__c','Total_FTE_Requirement__c','Total_Bid_Value_Labor_Direct_Discount__c','Service_Model__c'
            ,'Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c','FTE_Recruitment_Need__c','Management_FTE__c','Analyst_FTE__c','One_Off_Fees_For_Service_Implementation__c'
            ,'Unity_Living_Proposal__c','Bid_History_Related_Opportunity__r.Identified_Business__c','Opportunity_Number__c','Bid_Number__c','Type_of_Request__c','Budget_Analyst_Assigned__r.Name','Grid_Due_Date__c','Name','Opportunity_Owner__c','Opportunity_Name__c','LastModifiedBy.Name','Client_Bid_Grid_Team__c',
            'Bid_History_Related_Opportunity__r.Phase_P__c','Bid_History_Related_Opportunity__r.Verbatim_Indication_Term__c','Opportunity_Number__c','Drug_Name__c','Owner.Name','Supporting_Bid_Owner__r.Name','Strategic_Pricing_Lead__r.Name'
            ,'Bid_History_Related_Opportunity__r.Owner.Name','Bid_History_Related_Opportunity__r.Account.Name','CreatedBy.FirstName','CreatedBy.LastName','Early_Engagement_Development_Plan__c','Targeted_Countries__c','Number_of_Sites__c','First_Patient_Entered_Date__c','Grid_QC_Assigned_to__r.Name'
            ,'Insufficient_Information__c','Reason_for_Insufficient_Information__c','RFP_Ranking__c','Therapeutic_Area__c','Bid_History_Related_Opportunity__r.Campaign.Name','Patients_Enrolled__c','Rationale_Customer_Requirements__c','Comments_Other_Services_Specific_Vendor__c'
            ,'Bid_Defense_Date__c','Bid_History_Related_Opportunity__r.Expected_Project_Start_Date__c','First_Patient_In_Date__c','CurrencyIsoCode','Customer_discount_in_place_or_requested__c','Discount_and_or_request_details__c','Customer_Opportunity_Background__c','Client_Need_s_Decision_Making__c','Advance_Plan__c'
            ,'Triage_Manager_Notes__c','RFP_Folder_Link__c','Budget_Tools__c','Bid_History_Related_Opportunity__r.StageName','Bid_History_Related_Opportunity__r.CloseDate','Bid_History_Number_CPQ__c','Bid_Sent_Date__c','Reason_for_Rebid__c','Additional_Explanation__c','Link_to_Budget_Files__c','Bid_Owner_CPQ__c'
            ,'Assign_Proposal_Ranking__c','Bid_Type__c','Rate_Card_MSA__c','Rate_card_MSA_explanation__c','Bid_History_Related_Opportunity__r.Drug_Product_Name__c','ECG_Monitoring_Sub_Services__c','Strategy_Call_Requirement__c','Type_of_Document__c','Cardiac_Safety_ECG_Equipment__c','Cardiac_Safety_Equipment_Vendor__c'
            ,'Cardiac_Safety_Equipment_Logistic_Vendor__c','Region__c','Bid_History_Related_Opportunity__r.FPI_Date__c','Connected_Devices_Device_Name_If_Other__c','Connected_Devices_Equipment_Vendor_If_o__c','Bid_Category__c','Opportunity_Type__c','RFx_Type__c','RFP_Received_Date__c','OCT_Product_List__c','GRA_Services__c','Description_of_Scope__c','Other_Teams_Supporting__c'
            ,'Client_Deliverable_What_is_the_client_s__c','Is_PPT_Format_Required__c','Opportunity_Account__c','Study_Indication__c','Therapy_Area__c','Describe_Activity__c','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','Bid_History_Related_Opportunity__r.Opportunity_Attributes__c', 'People_who_need_to_be_included__c','Rebid_Complexity__c','Rebid_Proposal_Deliverable__c','Bid_History_Number__c','Bid_Due_Date__c','Standard_Turnaround_Time_BD__c','Bid_History_Status__c'
            ,'Operational_Lead1__c','Operational_Lead2__c','Operational_Lead1__r.name','Operational_Lead2__r.name'};
                
        bidHistory = new SLT_Bid_History(false,false).getBidHistoriesById(recordIdsSet,bidHistoryFieldSet).values()[0];
        return bidHistory;
    } 

}