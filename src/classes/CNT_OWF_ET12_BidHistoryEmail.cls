public class CNT_OWF_ET12_BidHistoryEmail {
    public Id recordId;
    public Bid_History__c bidHistory{get;set;}
    public Integer counter{get;set;}
    public String editableContent{get;set;}
    public String leadListString{get;set;}
    public List<String> leadPDVFList{get;set;}
    public Map<String,String> subGroupMap{get;set;}
    public String componentRef;
    public Boolean ConnectedDevicesEquipmentVendorForOther{get;set;}
    public Boolean ConnectedDevicesDeviceNameForOther{get;set;}
    public String linkToQuote{get;set;}
    public String getComponentRef(){
        return componentRef;
    }
    public void setComponentRef(String componentRef){
        if(componentRef != null){
        	this.componentRef = componentRef;
        	setPageMesaage(componentRef);
        }
    }
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
        }        
    }
    
    public String GBOLeadPDAssignment{get;set;}
    public String linkToBidHistory{get;set;}
    public String linkToOpportunity{get;set;}
    public String linkToRFPFolder{get;set;}
    public CNT_OWF_ET12_BidHistoryEmail() {
        counter = 0;
       
    }
    
    public Bid_History__c fetchfieldsAndInitializeObject(Id recordId)
    {
        if(counter == 0)
        {
            counter += 1;
            
            Set<Id> recordIdsSet = new Set<Id>();
            recordIdsSet.add(recordId);
            Set<String> bidHistoryFieldSet = new Set<String>{'Bid_History_Related_Opportunity__r.Name','Bid_History_Account__r.Name','Bid_History_Related_Opportunity__r.Opportunity_Number__c'
                ,'Bid_History_Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c','Line_of_Business__c','IQVIA_biotech__c','Bid_History_Account__r.Category__c','Bid_History_Account__r.RD_Spend__c','Phase__c','Indication__c'
                ,'Requested_Services__c','Additional_Services_Requested__c','Intervention_Type__c','Bid_Due_Date__c','Questions_Due_Date__c','CRO_Selection_Date__c','Proposal_Deliverable__c','Standard_Submission_Date__c','Project_Duration_Months__c','Service_Scope__c','Budget_Deliverable__c','Is_there_a_Client_Bid_Grid__c','Win_Probability__c','Estimated_Fees__c','Bid_History_Related_Opportunity__r.Amount'
                ,'Is_this_part_of_a_Program__c','Associated_CRM_Numbers__c','Pertinent_Details_Specific_Rebid_Request__c','Name'
                ,'Bid_History_Related_Opportunity__r.Business_Unit__c','Bid_History_Related_Opportunity__r.Potential_Regions__c'
                ,'Bid_History_Related_Opportunity__r.FSP__c','Bid_History_Related_Opportunity__r.Global_project_unit__c'
                ,'Bid_History_Related_Opportunity__r.Is_this_a_Virtual_Trials_Study__c','Related_Quote_Id__c'
                ,'Unity_Living_Proposal__c','Bid_History_Related_Opportunity__r.Identified_Business__c','Opportunity_Number__c','Bid_Number__c','Type_of_Request__c','Budget_Analyst_Assigned__r.Name','Grid_Due_Date__c','Name','Opportunity_Owner__c','Opportunity_Name__c','LastModifiedBy.Name','Client_Bid_Grid_Team__c',
                'Bid_History_Related_Opportunity__r.Phase_P__c','Bid_History_Related_Opportunity__r.Verbatim_Indication_Term__c','Opportunity_Number__c','Drug_Name__c','Owner.Name','Supporting_Bid_Owner__r.Name','Strategic_Pricing_Lead__r.Name'
                ,'Bid_History_Related_Opportunity__r.Owner.Name','Bid_History_Related_Opportunity__r.Account.Name','CreatedBy.FirstName','CreatedBy.LastName','Early_Engagement_Development_Plan__c','Targeted_Countries__c','Number_of_Sites__c','First_Patient_Entered_Date__c','Grid_QC_Assigned_to__r.Name'
                ,'Insufficient_Information__c','Reason_for_Insufficient_Information__c','RFP_Ranking__c','Therapeutic_Area__c','Bid_History_Related_Opportunity__r.Campaign.Name','Patients_Enrolled__c','Rationale_Customer_Requirements__c','Comments_Other_Services_Specific_Vendor__c'
                ,'Bid_Defense_Date__c','Bid_History_Related_Opportunity__r.Expected_Project_Start_Date__c','First_Patient_In_Date__c','CurrencyIsoCode','Customer_discount_in_place_or_requested__c','Discount_and_or_request_details__c','Customer_Opportunity_Background__c','Client_Need_s_Decision_Making__c','Advance_Plan__c'
                ,'Triage_Manager_Notes__c','RFP_Folder_Link__c','Budget_Tools__c','Bid_History_Related_Opportunity__r.StageName','Bid_History_Related_Opportunity__r.CloseDate','Bid_History_Number_CPQ__c','Bid_Sent_Date__c','Reason_for_Rebid__c','Additional_Explanation__c','Link_to_Budget_Files__c','Bid_Owner_CPQ__c'
                ,'Assign_Proposal_Ranking__c','Bid_Type__c','Rate_Card_MSA__c','Rate_card_MSA_explanation__c','Bid_History_Related_Opportunity__r.Drug_Product_Name__c','ECG_Monitoring_Sub_Services__c','Strategy_Call_Requirement__c','Type_of_Document__c','Cardiac_Safety_ECG_Equipment__c','Cardiac_Safety_Equipment_Vendor__c'
                ,'Cardiac_Safety_Equipment_Logistic_Vendor__c','Region__c','Bid_History_Related_Opportunity__r.FPI_Date__c','Connected_Devices_Device_Name_If_Other__c','Connected_Devices_Equipment_Vendor_If_o__c','Bid_Category__c','Opportunity_Type__c','RFx_Type__c','RFP_Received_Date__c','OCT_Product_List__c','GRA_Services__c','Description_of_Scope__c','Other_Teams_Supporting__c'
                ,'Client_Deliverable_What_is_the_client_s__c','Is_PPT_Format_Required__c','Opportunity_Account__c','Study_Indication__c','Therapy_Area__c','Describe_Activity__c','Bid_History_Related_Opportunity__r.Is_this_IQVIA_Biotech__c','Bid_History_Related_Opportunity__r.Opportunity_Attributes__c', 'People_who_need_to_be_included__c','Rebid_Complexity__c','Rebid_Proposal_Deliverable__c','Bid_History_Number__c','Bid_Due_Date__c','Standard_Turnaround_Time_BD__c'};
                    
            bidHistory = new SLT_Bid_History(false,false).getBidHistoriesById(recordIdsSet,bidHistoryFieldSet).values()[0];
            Set<String> assignmentFieldSetforGBO= new Set<String>{'pse__Resource__r.Name','pse__Resource_Request__r.SubGroup__c','pse__Resource_Request__r.Is_Created_Automatically__c'};
            String assignmentCondition ='AND pse__Resource_Request__r.SubGroup__c in (\'GBO-Lead PD\') and pse__Resource_Request__r.Is_Created_Automatically__c = true';
            List<pse__Assignment__c> asnList = new SLT_Assignment(false,false).getAssignmentByBhrAndCondition(recordIdsSet,assignmentCondition,assignmentFieldSetforGBO);
            if(!asnList.isEmpty()){
                GBOLeadPDAssignment = asnList[0].pse__Resource__r.Name;
            }
            ConnectedDevicesEquipmentVendorForOther = bidHistory.ECG_Monitoring_Sub_Services__c !=Null ? bidHistory.ECG_Monitoring_Sub_Services__c.contains('Other') : False;
            ConnectedDevicesDeviceNameForOther = bidHistory.Cardiac_Safety_ECG_Equipment__c != Null ? bidHistory.Cardiac_Safety_ECG_Equipment__c.contains('Other') : False;
            // leadPDFVList
            leadPDVFList = new List<String>();
            subGroupMap = new map<String,string>();
            subGroupMap.put(CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD,'N/A');
            subGroupMap.put(CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD,'N/A');
            subGroupMap.put(CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER,'N/A');
            Set<String> assignmentFieldSet = new Set<String>{'pse__Resource__r.Name', 'Subgroup_Name__c'};
            String assignCondition = ' and pse__Status__c in (\'Pending\', \'Accepted\') and pse__Resource_Request__r.SubGroup__c in (\'' + CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD + '\', \'' + CON_OWF.RES_REQ_TYPE_GBO_SUPPORT_PD + '\', \'' + CON_OWF.RES_REQ_TYPE_GBO_STRATEGIC_WRITER + '\')';
            for(pse__Assignment__c assign:new SLT_Assignment(false,false).getAssignmentByBhrAndConditionOrderByBhrOwner(recordIdsSet,assignCondition,assignmentFieldSet)){
                leadPDVFList.add(assign.pse__Resource__r.Name); 
                if (subGroupMap.get(assign.Subgroup_Name__c) != 'N/A') {
                    string subgroupMapValue= subGroupMap.get(assign.Subgroup_Name__c);
                    if(!subgroupMapValue.contains(assign.pse__Resource__r.Name)){
                        subGroupMap.put(assign.Subgroup_Name__c, subGroupMap.get(assign.Subgroup_Name__c) + ',' + '' + assign.pse__Resource__r.Name);
                    }
                }else{
                    subGroupMap.put(assign.Subgroup_Name__c, assign.pse__Resource__r.Name);
                }                   
            }
            
            
            if(leadPDVFList.size()== 1){
                leadListString = leadPDVFList[0];
            }
            else if (leadPDVFList.size()>1){
                leadListString = string.join(leadPDVFList,', ');
            }
            else{
                leadListString = ' ';
            }
            linkToQuote = URL.getOrgDomainUrl().toExternalForm()+ '/'+bidHistory.Related_Quote_Id__c;
            linkToBidHistory = URL.getOrgDomainUrl().toExternalForm()+'/'+recordId;
            linkToOpportunity = URL.getOrgDomainUrl().toExternalForm()+'/'+bidHistory.Bid_History_Related_Opportunity__r.Id;
            linkToRFPFolder = URL.getOrgDomainUrl().toExternalForm()+'/'+bidHistory.RFP_Folder_Link__c;
        }
        return bidHistory;
    }
    
    public void setPageMesaage(String componentRef){
        if(counter == 1){
            if(componentRef == 'TriageTemplate' && leadPDVFList != null && leadPDVFList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No GBO-Lead PD, No GBO-Support PD and No GBO–Strategic Writer Assignment with Accepted / Pending Status Present on this Agreement'));
            }
        }
    }

}
