/**
 * @description DAOH for Apttus_APTS_Agreement__c Object
 */
public class DAOH_CLM_APTS_Agreement {
    
    public static Boolean agreementOutputFormatUpdated;

     /**
    * This method is used to Prevent and update the companysignedby and companysigneddate in status category not In request,In Authoring
    * @params  newAgreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void updateCompanySignedByAndDate(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) { 
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.Apttus__Status_Category__c == CON_CLM.IN_AUTHORING
                && agreement.Apttus__Status_Category__c != oldMap.get(agreement.Id).Apttus__Status_Category__c){
                CLM_Configuration__c clmConfiguration = CLM_Configuration__c.getOrgDefaults();
                if(clmConfiguration != null){
                    agreement.Apttus__Company_Signed_By__c = clmConfiguration.AMA_Contact_Id__c;
                }
                agreement.Apttus__Company_Signed_Date__c = System.today();
            }
        }
    }

    /**
     * updateGenerateStatuses method checks the Generate button conditions to work, if those meet then agreement will be eligible to get update in statuses.
     * @param  newList is the list of newly updated agreement records.
     * @param  oldMap  is the map which contains previous values for the agreement records.
     */ 
    public static void updateGenerateStatuses(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c newAgreement : newList) {
            if(oldMap.get(newAgreement.Id).Apttus__Workflow_Trigger_Viewed_Final__c != newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c
                && (oldMap.get(newAgreement.Id).Apttus__Status_Category__c == CON_CLM.REQUEST 
                || oldMap.get(newAgreement.Id).Apttus__Status_Category__c == CON_CLM.IN_BUDGETING)
                && oldMap.get(newAgreement.Id).Apttus__Workflow_Trigger_Viewed_Final__c == false) {
                newAgreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
                newAgreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;
            }
        }
    }
    
    /**
    * This method is used to set Status Category and Status
    * @params  lstAptsAgreement List<Apttus__APTS_Agreement__c>
    * @params String strStatusCategory 
    * @params String strStatus
    * @return  void
    */
    public static void setStatusCategoryAndStatus(List<Apttus__APTS_Agreement__c> lstAptsAgreement, String strStatusCategory, String strStatus) {
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        for(Apttus__APTS_Agreement__c agreement: lstAptsAgreement) {
            if(agreement.recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID || agreement.recordTypeId == CON_CLM.RWLP_RECORDTYPEID 
                || agreement.recordTypeId == CON_CLM.PSA_RECORDTYPEID || agreement.recordTypeId == CON_CLM.OSA_RECORDTYPEID) {
                agreement.Apttus__Status__c = CON_CLM.ASSIGNED;   
            }
            else if(agreement.recordTypeId != CON_CLM.VENDOR_RECORDTYPEID && agreement.recordTypeId != CON_CLM.MSA_RECORDTYPEID) {
                agreement.Apttus__Status_Category__c = strStatusCategory;
                agreement.Apttus__Status__c = strStatus;
            }
        }
    }

    /**
    * This method is used to update field Apttus__Term_Months__c
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void updateTermYears(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if(agreement.Apttus__Term_Months__c != null && (oldMap == null || 
                (oldMap != null && agreement.Apttus__Term_Months__c != oldMap.get(agreement.id).Apttus__Term_Months__c))) {
                Integer yearNumber = Integer.valueOf(agreement.Apttus__Term_Months__c / 12);
                if(yearNumber > 0) {
                    agreement.O_Term_Years__c = convertNumberToWords(yearNumber) + ' ('+ yearNumber +')';
                }
            }
        }
    }
    
    /**
    * This method is used to update field Apttus__Renewal_Notice_Days__c,Apttus__Renewal_Notice_Date__c
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void updateRenewalNoticeDays(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if(String.isNotBlank(agreement.Renewal_Notification_Days__c) && (oldMap == null || 
                (oldMap != null && agreement.Renewal_Notification_Days__c != 
                oldMap.get(agreement.id).Renewal_Notification_Days__c))) {
                String days = agreement.Renewal_Notification_Days__c.substringBetween('(', ')');
                if(String.isNotBlank(days)) {
                    agreement.Apttus__Renewal_Notice_Days__c = Integer.valueOf(days);
                }
            }
        }
    }
    
    /**
    * This method is used to set value of Auto Renew (Boolean) field to always true
    * @params  newAgreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void setAutoRenewField(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
            for(Apttus__APTS_Agreement__c agreement: agreementList){
                if(agreement.Apttus__Auto_Renewal__c != null && oldMap == null) {
                    agreement.Apttus__Auto_Renewal__c = true;
                }
            }
        }

    /**
    * This method is used to update field Total Agreement Value Apttus__Total_Contract_Value__c
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void updateTotalAgreementValue(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if((oldMap == null && (agreement.Actual_Agreement_Value__c != null || 
                agreement.Project_Expenses__c != null || agreement.Apttus__Total_Contract_Value__c != null )) || 
                (oldMap != null && 
                (agreement.Actual_Agreement_Value__c != oldMap.get(agreement.id).Actual_Agreement_Value__c ||
                agreement.Project_Expenses__c != oldMap.get(agreement.id).Project_Expenses__c ||
                agreement.Apttus__Total_Contract_Value__c != oldMap.get(agreement.id).Apttus__Total_Contract_Value__c ))) {
                    agreement.Apttus__Total_Contract_Value__c = 
                        (agreement.Actual_Agreement_Value__c == null ? 0 : agreement.Actual_Agreement_Value__c) +
                        (agreement.Project_Expenses__c == null ? 0 : agreement.Project_Expenses__c);
                    agreement.Apttus__Total_Contract_Value__c = 
                        agreement.Apttus__Total_Contract_Value__c == 0 ? null : agreement.Apttus__Total_Contract_Value__c;
            }
        }
    }

    /**
     * checks for the status and if that meet the conditional requirement then it sets the values in 
     * appropriate fields of PSA agreement.
     * @param  agreements is the list of agreeements.
     * @param oldMap contains the old agreement values of fields.
     */
    public static void populatePSAInitialDraftFields(List<Apttus__APTS_Agreement__c> agreements, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for (Apttus__APTS_Agreement__c agreement : agreements) {
            if(agreement.Initial_Draft_At_High_Confidence_Date__c == null
                && agreement.Initial_Draft_At_High_Confidence_Value__c == null 
                && agreement.Initial_Draft_At_High_Confidence_Expense__c == null 
                && (agreement.Apttus__Status__c == 'Other Party Review' || agreement.Apttus__Status__c == 'Budget External Review'
                || agreement.Apttus__Status__c == 'Budget Customer Edits' || agreement.Apttus__Status__c == 'Author Contract'
                || agreement.Apttus__Status__c == 'Internal Review' || agreement.Apttus__Status__c == 'Customer Edits'
                || agreement.Apttus__Status__c == 'Ready for Signatures' || agreement.Apttus__Status__c == 'Internal Signatures'
                || agreement.Apttus__Status__c == 'Other Party Signatures' || agreement.Apttus__Status__c == 'Fully Signed')
                && agreement.Confidence_In_Approval_Of_Budget_Draft__c == 'High') {
                agreement.Initial_Draft_At_High_Confidence_Date__c = Date.today();
                agreement.Initial_Draft_At_High_Confidence_Value__c = agreement.Actual_Agreement_Value__c;
                agreement.Initial_Draft_At_High_Confidence_Expense__c = agreement.Project_Expenses__c;
            }
            if((oldMap != null) 
                && oldMap.get(agreement.Id).Confidence_In_Approval_Of_Budget_Draft__c == 'High' && agreement.Confidence_In_Approval_Of_Budget_Draft__c == 'Low') {
                agreement.Initial_Draft_At_High_Confidence_Date__c = null;
                agreement.Initial_Draft_At_High_Confidence_Value__c = null;
                agreement.Initial_Draft_At_High_Confidence_Expense__c = null;
                agreement.High_Confidence_Budget_Link1__c = null;
            }
        }
    }
    
    /**
     * Sets “Concession Amount” to 0.00 $ and “Concession Reason/Category” to N/A 
     * if “Concessions Discussion” is “No”.
     * @param  agreements is the list of agreeements.
     * @param oldMap contains the old agreement values of fields.
     */
    public static void populateConcessionFields(List<Apttus__APTS_Agreement__c> agreements, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for (Apttus__APTS_Agreement__c agreement : agreements) {
            if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER && agreement.Concessions_Discussion__c != null 
               && agreement.Concessions_Discussion__c != oldMap.get(agreement.Id).Concessions_Discussion__c) {
                if(agreement.Concessions_Discussion__c == 'No') {
                    agreement.Concession_Reason_Category__c = 'N/A';
                    agreement.Concession_Amount__c = 0.00;
                }
                else if(agreement.Concessions_Discussion__c == 'Yes'){
                    if(agreement.Concession_Amount__c == null) {
                        agreement.addError('Concession_Amount__c', 'Please enter the concession amount to set the concession discussion to Yes.');
                    }
                    if(agreement.Concession_Reason_Category__c == null) {
                        agreement.addError('Concession_Reason_Category__c', 'Please enter the concession reason to set the concession discussion to Yes.');
                    }
                }
            }
        }
    }

    /**
    * This method is used to update Opportunity_Number__c and Project_Number__c field of agreement
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateAGRFromOpportunity(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> oppIds = new Set<Id>(); 
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(); 
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if((oldMap == null || (oldMap != null 
               && agreement.Apttus__Related_Opportunity__c != oldMap.get(agreement.Id).Apttus__Related_Opportunity__c)) 
               && agreement.Apttus__Related_Opportunity__c != null) {
               oppIds.add(agreement.Apttus__Related_Opportunity__c);
            }
        }
        if(oppIds != null && !oppIds.isEmpty()) {
            opportunityMap = new SLT_Opportunity().getOpportunityById(oppIds, new Set<String>{'Id', 'Opportunity_Number__c', 'Legacy_Quintiles_Opportunity_Number__c', 
                'Protocol_Number__c', 'Proposal_Sent_Date__c','Global_project_unit__c'});
            for(Apttus__APTS_Agreement__c agreement: agreementList) {
                if((oldMap == null || (oldMap != null 
                    && agreement.Apttus__Related_Opportunity__c != oldMap.get(agreement.Id).Apttus__Related_Opportunity__c))
                    && agreement.Apttus__Related_Opportunity__c != null
                    && opportunityMap.containsKey(agreement.Apttus__Related_Opportunity__c)
                    && opportunityMap.get(agreement.Apttus__Related_Opportunity__c) != null) {
                    agreement.Opportunity_Number__c = opportunityMap.get(agreement.Apttus__Related_Opportunity__c).Opportunity_Number__c;
                    if(agreement.Apttus__Version_Number__c == 0
                        && agreement.Agreement_Cloned_From__c == null
                        && (agreement.RecordTypeId != CON_CLM.Vendor_RECORDTYPEID 
                        && agreement.RecordTypeId != CON_CLM.EMEA_RECORDTYPEID
                        && agreement.RecordTypeId != CON_CLM.AMESA_RECORDTYPEID
                        && agreement.RecordTypeId != CON_CLM.AMA_RECORDTYPEID)) {
                        agreement.Global_Project_Unit__c = opportunityMap.get(agreement.Apttus__Related_Opportunity__c).Global_project_unit__c;
                    }
                    if(agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID 
                        || agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                        agreement.Project_Number__c = opportunityMap.get(agreement.Apttus__Related_Opportunity__c).Legacy_Quintiles_Opportunity_Number__c;
                        agreement.Protocol_Number__c = opportunityMap.get(agreement.Apttus__Related_Opportunity__c).Protocol_Number__c;
                    } 
                    if(agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                        agreement.Proposal_Date__c = opportunityMap.get(agreement.Apttus__Related_Opportunity__c).Proposal_Sent_Date__c;
                    }
                }
        	}
        }
    }

    /**
    * This method is used to convert numbers to words
    * @params  Integer yearNumber
    */
    @testVisible
    private static String convertNumberToWords(Integer yearNumber) {
        switch on yearNumber { when 1 {
               return 'one';
            } when 2 {
               return 'two';
            } when 3 {
               return 'three';
            } when 4 {
                return 'four';
            } when 5 {
                return 'five';
            } when 6 {
                return 'six';
            } when 7 {
                return 'seven';
            } when 8 {
                return 'eight';
            } when 9 {
                return 'nine';
            } when 10 {
                return 'ten';
            } when else { 
                return '';
            }
        }
    }    

    /**
    * This method is update the status change date according to agreement status change
    * @params  List<Apttus__APTS_Agreement__c> newAgreementList
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldRecordsMap
    */
    public static void updateStatusChangeDateOnAgreement(List<Apttus__APTS_Agreement__c> newAgreementList, Map<Id, Apttus__APTS_Agreement__c> oldRecordsMap){
        for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
            if(agreement.Apttus__Status__c != oldRecordsMap.get(agreement.id).Apttus__Status__c && agreement.Apttus__Status__c != '' && agreement.Apttus__Status__c != null){
                agreement.Status_Change_Date__c = System.today();
            }  
        }
    }

    public static void updateAgreementforIsStudyAwarded(List<Apttus__APTS_Agreement__c> lstAgreementRecords, 
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<String> fieldSet = new Set<String>{'Id', 'StageName'};
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Set<Id> setOpportunityId = new Set<Id> ();
        for(Apttus__APTS_Agreement__c agreement : lstAgreementRecords) {
            if(oldMap == null || (oldMap != null && agreement.Is_Study_Awarded__c != oldMap.get(agreement.id).Is_Study_Awarded__c)) {
                setOpportunityId.add(agreement.Apttus__Related_Opportunity__c);
            }
        }
        if(setOpportunityId.size() > 0) {
            mapOpportunity = new SLT_Opportunity().getOpportunityById(setOpportunityId, fieldSet);
            for(Apttus__APTS_Agreement__c agreement : lstAgreementRecords) {
                if((oldMap == null || (oldMap != null && agreement.Is_Study_Awarded__c != oldMap.get(agreement.id).Is_Study_Awarded__c)) && 
                    agreement.Apttus__Related_Opportunity__c != null && 
                    mapOpportunity.containsKey(agreement.Apttus__Related_Opportunity__c)) {
                    Opportunity opportunity = mapOpportunity.get(agreement.Apttus__Related_Opportunity__c);
                    if (CON_CLM.OPPORTUNITY_STAGE_NAME_SET_FOR_YES.contains(opportunity.StageName)) {
                        agreement.Is_Study_Awarded__c = 'Yes';
                    } else if(CON_CLM.OPPORTUNITY_STAGE_NAME_SET_FOR_NO.contains(opportunity.StageName)) {
                        agreement.Is_Study_Awarded__c = 'No';
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to insert/update Provisions tab for project specific agreement
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap  
    */
    public static void setProvisionsTabForPSA(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
		Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Apttus__APTS_Agreement__c> agreementDefaultMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Apttus__APTS_Agreement__c> parentAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();     
        Set<String> provisionTabFields = new Set<String>{'Late_Payment_Clause__c', 'Upfront_Payment_Provision__c',
            'Currency_Exchange_Provision__c', 'Consequential_Damages_Disclaimer__c', 'Comprehensive_Indemnification_Provision__c'
            ,'IQVIA_Confidentiality_And_IP_Provisions__c', 'Investigator_Relationship_Provision__c', 'Cap_On_Damages__c',
            'Termination_Provision__c', 'Change_Order_Language__c', 'Discounts_Risk_Premium_Volume_Rebate__c', 'Penalty__c',
            'Non_Solicitation__c', 'Outcomes_Based_Gain_Risk_PFS__c', 'Rest_Work_For_Sponsor_Competitors__c',
            'Ok_To_Use_IQVIA_Affiliates__c', 'Ok_To_Use_Client_Affiliates__c', 'Non_Standard_Work_Order_Template_Reqd__c',
            'Late_Payment_Clause_Explanation__c', 'Upfront_Payment_Provision_Explanation__c',
            'Currency_Ex_Provision_Explanation__c', 'Consequential_Damages_Disc_Explanation__c',
            'Comp_Indemnification_Prov_Explanation__c', 'Confidentiality_And_IP_Prov_Explanation__c',
            'Investigator_Relp_Prov_Explanation__c', 'Cap_On_Damages_Explanation__c', 'Termination_Provision_Explanation__c',
            'Change_Order_Language_Explanation__c', 'Discounts_Risk_Pm_Vol_Rebate_Explanation__c', 'Penalty_Explanation__c',
            'Non_Solicitation_Explanation__c', 'Outcomes_Explanation__c', 'Rest_Work_For_Sponsor_Comp_Explanation__c',
            'Early_Termination_Payment__c', 'Force_Majeure_Provision__c', 'Electronic_Records_And_Signatures_Prov__c',
            'Confidential_And_Proprietary_Info_Id__c', 'Early_Termination_Payment_Explanation__c',
            'Force_Majeure_Provision_Explanation__c', 'Electronic_Records_and_Signatures_Expl__c',
            'Confidential_and_Propriety_Info_Expl__c'};
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((oldMap == null && agreement.Related_Master_Agreement__c != null) ||
                ((oldMap != null && oldMap.get(agreement.Id).Related_Master_Agreement__c != agreement.Related_Master_Agreement__c) 
				&& agreement.Related_Master_Agreement__c != null)) {
                agreementMap.put(agreement.Related_Master_Agreement__c, agreement);
			}	
            else if(oldMap != null && agreement.Related_Master_Agreement__c != oldMap.get(agreement.Id).Related_Master_Agreement__c 
			    && agreement.Related_Master_Agreement__c == null) {
                agreementDefaultMap.put(agreement.Related_Master_Agreement__c, agreement);
            }
        }
        if(!agreementMap.isEmpty()) {
            parentAgreementMap = new SLT_Agreement().selectAgreementById(agreementMap.keySet(), provisionTabFields);  
            for(Apttus__APTS_Agreement__c agreement : agreementMap.values()) {
                if(parentAgreementMap.containsKey(agreement.Related_Master_Agreement__c)) {
			        copyAgreementFields(agreement, parentAgreementMap.get(agreement.Related_Master_Agreement__c), provisionTabFields); 
                }    
		    }
        }
		if(!agreementDefaultMap.isEmpty()) {
            for(Apttus__APTS_Agreement__c agreement : agreementDefaultMap.values()) {
			    setProvisionTabToDefault(agreement);                          
		    }
        }
    }
    
    /**
    * This method is to update primary quote record on opportunity to populate Related Agreement
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateRelatedAgreementOnQuote(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Map<Id, Apttus_Proposal__Proposal__c> quotesMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> proposalIds = new Set<Id>();

        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.Apttus_QPComply__RelatedProposalId__c != null
                && (agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER
                || agreement.Apttus__Subtype__c == CON_CLM.AMESA_SOW_SUB_TYPE)) {
                proposalIds.add(agreement.Apttus_QPComply__RelatedProposalId__c);
            }
        }
        if(!proposalIds.isEmpty()) {
            Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Apttus_Proposal__Opportunity__c', 'Apttus_Proposal__Proposal_Category__c'};
            String condition = ' (RecordTypeId = \'' + CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE + '\' OR RecordTypeId = \'' + CON_CLM.QUOTE_RDS_NON_SF_RECORDTYPE + '\' OR RecordTypeId = \'' + CON_CLM.QUOTE_TECH_SOLN_RECORDTYPE + '\') AND Id IN :proposalIds';
            
            quotesMap  = new Map<Id, Apttus_Proposal__Proposal__c>(new SLT_Proposal().getQuoteByParentRelatedOppIdOrIds(null, proposalIds, fieldSet, condition));

            for(Apttus__APTS_Agreement__c agreement : agreementList) {
                if(agreement.Apttus_QPComply__RelatedProposalId__c != null 
                    && quotesMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c)) {
                    Apttus_Proposal__Proposal__c proposal = quotesMap.get(agreement.Apttus_QPComply__RelatedProposalId__c);
                    if ((agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER
                    && proposal.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_CHANGE_ORDER)
                    || agreement.Apttus__Subtype__c == CON_CLM.AMESA_SOW_SUB_TYPE) {
                        proposal.Apttus_QPComply__MasterAgreementId__c = agreement.Id;
                        proposalsToUpdate.add(proposal);
                    }
                }
            }
            if(!proposalsToUpdate.isEmpty()) {
                try {  
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            Apttus_Proposal__Proposal__c.SObjectType
                        }
                    );
                    uow.registerDirty(proposalsToUpdate);
                    uow.commitWork();
                } catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
            }
        }
    }
    
    /**
    * This method is used to set Provision tab to default
    * @param Apttus__APTS_Agreement__c agreement
    * @return Apttus__APTS_Agreement__c  
    */
    @testVisible
    private static Apttus__APTS_Agreement__c setProvisionTabToDefault(Apttus__APTS_Agreement__c agreement) {
        Set<String> agreementNoChangePicklistFields = new Set<String>{'Late_Payment_Clause__c', 'Upfront_Payment_Provision__c', 
            'Currency_Exchange_Provision__c', 'Consequential_Damages_Disclaimer__c', 'Termination_Provision__c',
            'Comprehensive_Indemnification_Provision__c', 'IQVIA_Confidentiality_And_IP_Provisions__c',
            'Investigator_Relationship_Provision__c','Cap_On_Damages__c', 'Change_Order_Language__c'};
        Set<String> agreementNullFields = new Set<String>{'Discounts_Risk_Premium_Volume_Rebate__c', 'Penalty__c', 
            'Non_Solicitation__c', 'Outcomes_Based_Gain_Risk_PFS__c', 'Rest_Work_For_Sponsor_Competitors__c',
            'Ok_To_Use_IQVIA_Affiliates__c', 'Ok_To_Use_Client_Affiliates__c', 'Non_Standard_Work_Order_Template_Reqd__c',
            'Late_Payment_Clause_Explanation__c', 'Upfront_Payment_Provision_Explanation__c',
            'Currency_Ex_Provision_Explanation__c', 'Consequential_Damages_Disc_Explanation__c',
            'Comp_Indemnification_Prov_Explanation__c', 'Confidentiality_And_IP_Prov_Explanation__c',
            'Investigator_Relp_Prov_Explanation__c', 'Cap_On_Damages_Explanation__c', 'Termination_Provision_Explanation__c',
            'Change_Order_Language_Explanation__c', 'Discounts_Risk_Pm_Vol_Rebate_Explanation__c', 'Penalty_Explanation__c',
            'Non_Solicitation_Explanation__c', 'Outcomes_Explanation__c', 'Rest_Work_For_Sponsor_Comp_Explanation__c',
            'Early_Termination_Payment_Explanation__c', 'Early_Termination_Payment__c', 'Force_Majeure_Provision_Explanation__c',
            'Force_Majeure_Provision__c', 'Electronic_Records_and_Signatures_Expl__c', 'Confidential_and_Propriety_Info_Expl__c',
            'Electronic_Records_And_Signatures_Prov__c', 'Confidential_And_Proprietary_Info_Id__c'};
        for(String field : agreementNoChangePicklistFields) {
            agreement.put(field , CON_CLM.NO_CHANGE);
        }
        for(String field: agreementNullFields) {
            agreement.put(field , null);
        }
        return agreement;
    }
    
    /**
    * This method is used to copy agreement fields from one agreement to another agreement
    * @param Apttus__APTS_Agreement__c agreementToReturn
    * @param Apttus__APTS_Agreement__c agreement
    * @param Set<String> agreementFields
    * @return Apttus__APTS_Agreement__c
    */
    @testVisible
    private static Apttus__APTS_Agreement__c copyAgreementFields(Apttus__APTS_Agreement__c agreementToReturn, 
        Apttus__APTS_Agreement__c agreement, Set<String> agreementFields) {
        for(String field : agreementFields) {
            if(agreement.get(field) != null) {
                agreementToReturn.put(field, agreement.get(field));
            }
        }
        return agreementToReturn;
    }
    
    /**
    * This method is used to fetch mapping values from two objects.
    * @params  newAgreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    * @return  void
    */
    public static void updateAgreementFromQuote(List<Apttus__APTS_Agreement__c> newAgreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap, String recordTypeDevName) {
        
        Map<String,String> sourceTargetFieldMap = new Map<String,String>();
        for(CLM_Field_Mappings__c mapping: UTL_CLM.getFilteredCSMappingList(recordTypeDevName,'Apttus__APTS_Agreement__c')) {
            sourceTargetFieldMap.put(mapping.Source_Field_API_Name__c,mapping.Target_Field_API_Name__c);
        }
        Set<Id> relatedQuoteProposalIdSet =  new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal__c> proposalIdMap = null; 
        for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
            if(agreement.Apttus_QPComply__RelatedProposalId__c != null 
                && (oldMap == null 
                || (oldMap != null 
                && agreement.Apttus_QPComply__RelatedProposalId__c != oldMap.get(agreement.Id).Apttus_QPComply__RelatedProposalId__c))) {
                relatedQuoteProposalIdSet.add(agreement.Apttus_QPComply__RelatedProposalId__c);
            }
        }
        if(!relatedQuoteProposalIdSet.isEmpty()) {
            List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalsById(relatedQuoteProposalIdSet, sourceTargetFieldMap.keySet());
            proposalIdMap = new Map<Id, Apttus_Proposal__Proposal__c>(proposalList);
        }          
        if(proposalIdMap != null && !proposalIdMap.isEmpty() && sourceTargetFieldMap != null 
            && !sourceTargetFieldMap.isEmpty()) {
            for(Apttus__APTS_Agreement__c agreement : newAgreementList) {
                if (proposalIdMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) 
                    && proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c) != null) {
                    Apttus_Proposal__Proposal__c proposal = proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c);
                    for (String sourceField : sourceTargetFieldMap.keySet()) {
                        String targetField = sourceTargetFieldMap.get(sourceField);
                        agreement.put(targetField, proposal.get(sourceField));
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to check Agreement fields before updating the status category 
    * to In Authoring Or In Signatures for PSA, PA, MSA, OSA, RWSSOW
    * @params agreementList List<Apttus__APTS_Agreement__c>
    * @params Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void validateAgreementBeforeStatusCategoryChanged(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Map<Id,Schema.RecordTypeInfo>  rtMapById = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();
		Boolean isProvisionTabInComplete = false;
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if(((oldMap.get(agreement.Id).Apttus__Status_Category__c != agreement.Apttus__Status_Category__c
                && agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT
                && agreement.Apttus__Status__c == CON_CLM.ACTIVATED)
                || (agreement.Apttus__Status_Category__c != CON_CLM.IN_EFFECT
                && (oldMap.get(agreement.Id).Apttus__Status__c != agreement.Apttus__Status__c 
                || oldMap.get(agreement.Id).Apttus__Status_Category__c != agreement.Apttus__Status_Category__c)))
                && (agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment)){
                String validationError = UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreement, rtMapById.get(agreement.recordTypeId).getDeveloperName(), 
                    agreement.Apttus__Subtype__c, agreement.Apttus__Status_Category__c, agreement.Apttus__Status__c, true);
                if(agreement.Apttus__Status__c == CON_CLM.READY_FOR_SIGNATURES 
                    && rtMapById.get(agreement.recordTypeId).getDeveloperName() == CON_CLM.PSA_RECORD_TYPE_NAME
                    && (agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_WO || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA)) {
                    if(validationError != null && validationError != '') {
                        isProvisionTabInComplete = true;
                    }
                    if(agreement.Local_Representative__c == null && agreement.EU_Legal_Representative__c == null && isProvisionTabInComplete) {
                        agreement.addError('Local_Representative__c', System.Label.CLM_CL00016_EU_AND_LOCAL_FIELD_MISSING_PROVISION_TAB_INCOMPLETE_ERROR);
                        agreement.addError('EU_Legal_Representative__c', System.Label.CLM_CL00016_EU_AND_LOCAL_FIELD_MISSING_PROVISION_TAB_INCOMPLETE_ERROR);
                    }
                    else if(agreement.Local_Representative__c == null && agreement.EU_Legal_Representative__c == null && !isProvisionTabInComplete) {
                        agreement.addError('Local_Representative__c', System.Label.CLM_CL00016_EU_AND_LOCAL_FIELD_MISSING_PROVISION_TAB_COMPLETE_ERROR);
                        agreement.addError('EU_Legal_Representative__c', System.Label.CLM_CL00016_EU_AND_LOCAL_FIELD_MISSING_PROVISION_TAB_COMPLETE_ERROR);
                    }
                    else if(agreement.EU_Legal_Representative__c == null && !isProvisionTabInComplete) {
                        agreement.addError('EU_Legal_Representative__c', System.Label.CLM_CL00016_EU_FIELD_MISSING_PROVISION_TAB_COMPLETE_ERROR);
                    } 
                    else if(agreement.EU_Legal_Representative__c == null && isProvisionTabInComplete) {
                        agreement.addError('EU_Legal_Representative__c', System.Label.CLM_CL00016_EU_FIELD_MISSING_PROVISION_TAB_INCOMPLETE_ERROR);
                    }
                    else if(agreement.Local_Representative__c == null && !isProvisionTabInComplete) {
                        agreement.addError('Local_Representative__c', System.Label.CLM_CL00016_LOCAL_FIELD_MISSING_PROVISION_TAB_COMPLETE_ERROR);
                    } 
                    else if(agreement.Local_Representative__c == null && isProvisionTabInComplete) {
                        agreement.addError('Local_Representative__c', System.Label.CLM_CL00016_LOCAL_FIELD_MISSING_PROVISION_TAB_INCOMPLETE_ERROR);
                    }
                }
            }
        }
    }
    /**
    * This method is used to prevent the User from creating Change Order PSA record from Opportunity
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void preventUserFromCreatingCOFromOpp(List<Apttus__APTS_Agreement__c> agreementList) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID
                && agreement.Special_Terms_Included__c == CON_CLM.RESTRICT_CO_AGREEMENT 
                && agreement.Agreement_Cloned_From__c == null)
                || (agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID
                && agreement.Agreement_Cloned_From__c == null
                && agreement.Apttus__Version_Number__c == 0
                )) {
                if (agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER) {
                    if(agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID) {
                        agreement.addError(System.Label.CLM_CL00014_ERROR_MESSAGE_FOR_CO_FROM_OPP);
                    }
                    if(agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID && 
                        agreement.Apttus__Agreement_Category__c != CON_CLM.FULL_SERVICE) {
                        agreement.addError(System.Label.CLM_CL00015_ERROR_MESSAGE_FOR_CO_RWSSOW);
                    }
                }
                if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER) {
                    agreement.addError(System.Label.CLM_CL00014_ERROR_MESSAGE_FOR_NEW_TERM_LETTER);
                }                     
            }
        }
    }
    
    /**
    * This method is used to prevent the user from selecting requested agreement type other than Change Order or Amendment
    * @param List<Apttus__APTS_Agreement__c> agreementList  
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void allowCOAmendmentSubTypeOnly(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> msaAgrIds = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> msaAgrMap = new Map<Id, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agreement : agreementList){
            if(agreement.Apttus__Version_Number__c > 0 && agreement.Agreement_Cloned_From__c != null 
                && agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID && agreement.Original_Agreement__c != null){
                msaAgrIds.add(agreement.Id);
            }
        }
        if(!msaAgrIds.isEmpty()){
            msaAgrMap = new SLT_Agreement().selectAgreementById(msaAgrIds, new Set<String>{'Id', 'Original_Agreement__c', 'Original_Agreement__r.Apttus__Subtype__c'});
        }
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.Apttus__Version_Number__c > 0 && agreement.Agreement_Cloned_From__c != null) {
                if(oldMap == null &&((agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID  && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER 
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER) || (agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID 
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER) 
                    || ((agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID) 
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGR_AMENDMENT)
                    || ((agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.COMMERCIAL_RECORDTYPEID) && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER))) {
					agreement.Apttus__Subtype__c = null;
				}
                else if(oldMap != null && (agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c
                    && (agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER))) {
                    agreement.addError(System.Label.CLM_CL00017_PSA_SUBTYPE_AMEND_ERROR);
                }
                else if(oldMap != null && (agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT 
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER)) {
                    agreement.addError(System.Label.CLM_CL00017_PA_TERMINATION_LETTER_AMEND_ERROR);
                }
                else if(oldMap != null && ((agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID
                    || agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID)
                    && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c)) {
                    if(agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGR_AMENDMENT){
                        agreement.addError(System.Label.CLM_CL00017_PA_MSA_SUBTYPE_AMEND_ERROR);
                    }
                    else if(agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID && (agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT
                        || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGR_AMENDMENT)){
                        if(!msaAgrMap.isEmpty() && msaAgrMap.containsKey(agreement.Id)){
                            if(msaAgrMap.get(agreement.Id).Original_Agreement__r.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGREEMENT 
                                && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGR_AMENDMENT){
                                agreement.addError(System.Label.CLM_CL00018_MSA_SERVICE_SUBTYPE_AMEND_ERROR);
                            } else if(msaAgrMap.get(agreement.Id).Original_Agreement__r.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGREEMENT 
                                && agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_SERVICE_AGR_AMENDMENT){
                                agreement.addError(System.Label.CLM_CL00017_PA_MSA_SUBTYPE_AMEND_ERROR);
                            }
                        }
                    }
                }
                else if(oldMap != null && ((agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID 
                    || agreement.RecordTypeId == CON_CLM.COMMERCIAL_RECORDTYPEID)
                    && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c
                    && (agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER))) {
                    agreement.addError(System.Label.CLM_CL00017_RWSSOW_SUBTYPE_AMEND_ERROR);
                }
                else if(oldMap != null && (agreement.RecordTypeId == CON_CLM.RWLP_RECORDTYPEID 
                    && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c
                    && (agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT))) {
                    agreement.addError(System.Label.CLM_CL00017_RWLP_SUBTYPE_CO_AMEND_ERROR);
                }
                else if(oldMap != null && (agreement.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID 
                    && agreement.Apttus__Subtype__c != null 
                    && agreement.Apttus__Subtype__c != oldMap.get(agreement.Id).Apttus__Subtype__c
                    && (agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_LETTER))) {
                    agreement.addError(System.Label.CLM_CL00017_VA_CO_AMEND_TERMINATION_LETTER_ERROR);
                }
            }
        } 
    }

    /**
    * This method is used update the payment term  on the WO to match the MSAs payment term field
    * @params  List<Apttus__APTS_Agreement__c> agreementList
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldRecordsMap
    * The method was created in CLMCMA-7653 and later updated in CLMCMA-8443
    */
    public static void updatePaymentTerm(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap){
        Map<Id, Id> agrIdToAssociateAgrMap = new Map<Id, Id>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID
                && agreement.Related_Master_Agreement__c != null 
                && CON_CLM.PSA_REQUESTED_AGR_TYPE_FOR_PAYMENTTERM_UPDATE.contains(agreement.Apttus__Subtype__c)
                && (oldMap == null || (oldMap != null 
                && (agreement.Related_Master_Agreement__c != oldMap.get(agreement.id).Related_Master_Agreement__c)))) {
                agrIdToAssociateAgrMap.put(agreement.Id, agreement.Related_Master_Agreement__c);
            }
            else if(agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID && 
                ((oldMap == null && (agreement.Related_Master_Agreement__c != null 
                && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT)) || 
                (oldMap != null && (agreement.Related_Master_Agreement__c != oldMap.get(agreement.id).Related_Master_Agreement__c &&
                agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT)))) {
                    agrIdToAssociateAgrMap.put(agreement.Id, agreement.Related_Master_Agreement__c);
            }
        }
        if(agrIdToAssociateAgrMap != null && agrIdToAssociateAgrMap.size() > 0) {
            Set<String> fieldSet = new Set<String>{'Id', 'Related_Master_Agreement__c', 'Apttus__Subtype__c', 'Payment_Term__c'};
            List<Apttus__APTS_Agreement__c> agreementPayTermList = new SLT_Agreement().getAgreementFieldsById(new Set<Id>(agrIdToAssociateAgrMap.values()), fieldSet);
            Map<Id, Apttus__APTS_Agreement__c> mapOfAssociatedMSA = new  Map<Id, Apttus__APTS_Agreement__c>(agreementPayTermList);
            if(mapOfAssociatedMSA != null && mapOfAssociatedMSA.size()>0 ){
                for(Apttus__APTS_Agreement__c agreementWo : agreementList) {
                    agreementWo.Payment_Term__c = mapOfAssociatedMSA.get(agrIdToAssociateAgrMap.get(agreementWo.Id)).Payment_Term__c;
                }
            }
        }
    }

    
    /**
    * This method is used to prevent the User from Changing status to Fully Signed 
    * if Company Signed Date and Other Party Signed Date is null
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void validateSignedDateBeforeFullySigned(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap.get(agreement.Id).Apttus__Status__c != agreement.Apttus__Status__c && 
                (agreement.Apttus__Status__c == CON_CLM.FULLY_SIGNED || agreement.Apttus__Status__c == CON_CLM.PO_RECEIVED)) {
                if(agreement.Apttus__Company_Signed_Date__c == null) {
                    agreement.addError('Apttus__Company_Signed_Date__c', System.Label.CLM_CL0002_Required_Field_Message);
                }
                if(agreement.Apttus__Other_Party_Signed_Date__c == null) {
                    agreement.addError('Apttus__Other_Party_Signed_Date__c', System.Label.CLM_CL0002_Required_Field_Message); 
                }      
            }
        }
    }

    /**
     * This method used to prevent user to update status category
     * if any review cycle is in progress
     * @params  agreementList List<Apttus__APTS_Agreement__c>
     * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
     */
    public static void validateReviewCycleBeforeStatusCategoryChanged(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
	    Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Set<Id> agreementIds = new Set<Id>();       
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap.get(agreement.Id).Apttus__Status_Category__c != agreement.Apttus__Status_Category__c 
                && agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES) {
                agreementMap.put(agreement.Id, agreement);
            }            
        }

        if(!agreementMap.isEmpty()) {
            String condition = 'Apttus__AgreementId__c IN: agreementIds AND Apttus__LatestReviewCycleStatus__c NOT IN (\'' + '' + '\',\'' + CON_CLM.CANCELLED + '\', \'' + CON_CLM.COMPLETED + '\')';
            for(Apttus__DocumentVersion__c documentVersion: new SLT_DocumentVersion().getDocumentVersionByConditions(
                agreementMap.keySet(),new Set<String>{'Id','Apttus__LatestReviewCycleStatus__c','Apttus__AgreementId__c'}, condition)) {
                agreementIds.add(documentVersion.Apttus__AgreementId__c);
            }
        }
        
        if(!agreementIds.isEmpty()) {
            for(Id agrId: agreementIds) {
                agreementMap.get(agrId).addError('Apttus__Status_Category__c', System.Label.CLM_CL00024_REVIEW_PROCCESS_IN_PROGRESS);
            }
        }
    }
    
    /**
    * This method is used to update related quote on agreement activation
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    /*public static void updateRelatedQuoteOnAgreementActivation(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Map<Id, Apttus_Proposal__Proposal__c> proposalIdMap = null;
        Set<Id> relatedQuoteProposalIdSet =  new Set<Id>();
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<String> quoteFieldsSet = new Set<String>{'Apttus_Proposal__Approval_Stage__c', 'Executed_Date__c',
            'Apttus_Proposal__Primary__c', 'RecordTypeId', 'Apttus_QPConfig__ConfigurationFinalizedDate__c'};
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap.get(agreement.Id).Apttus__Status__c != agreement.Apttus__Status__c && 
                agreement.Apttus__Status__c == CON_CLM.ACTIVATED && agreement.Apttus_QPComply__RelatedProposalId__c != null ) {
                relatedQuoteProposalIdSet.add(agreement.Apttus_QPComply__RelatedProposalId__c);
            }
        }
        if(!relatedQuoteProposalIdSet.isEmpty()) {
            proposalIdMap = new Map<Id, Apttus_Proposal__Proposal__c>(new SLT_Proposal().
                getProposalsById(relatedQuoteProposalIdSet, quoteFieldsSet));
        }
        if(proposalIdMap != null && !proposalIdMap.isEmpty()) {
            for(Apttus__APTS_Agreement__c agreement : agreementList) {
                if (proposalIdMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) 
                    && proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c) != null) {
                    Apttus_Proposal__Proposal__c proposal = proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c);
                    if(proposal.Apttus_Proposal__Primary__c &&
                        ((proposal.Apttus_Proposal__Approval_Stage__c == CON_CLM.PROPOSAL_APPROVAL_STAGE_PRESENTED &&
                        proposal.RecordTypeId == CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE &&
                        proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != null) ||
                        (proposal.Apttus_Proposal__Approval_Stage__c == CON_CLM.DRAFT &&
                        proposal.RecordTypeId == CON_CLM.QUOTE_RDS_NON_SF_RECORDTYPE))) {
                        proposal.Executed_Date__c = agreement.Apttus__Other_Party_Signed_Date__c;
                        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;
                        proposalList.add(proposal);
                    }
                }
            }
        }
        if(!proposalList.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                Apttus_Proposal__Proposal__c.SObjectType
            });
            uow.registerDirty(proposalList);
            uow.commitWork();            
        }
    }*/

    /**
     * This method will get the all picklist value of a picklist field and sets the label 
     * into the field.
     * For Account country, This method first gets of the account Ids and then fetched all account regarding those account IDs
     * then it will get the value from account and sets the label for that value on agreement.
     * @param agreements holds the list of agreements which will be updating.
     * @param oldMap holds the old agreement values in case of update trigger.
     * @param fromFieldName is the string which holds the API name of actual picklist field
     * @param toFieldName is the API name of a field which will hold the label for that picklist field option.
     */
    public static void setPickListLabelToField(List<Apttus__APTS_Agreement__c> agreements, Map<Id, Apttus__APTS_Agreement__c> oldMap,
        String fromFieldName, String toFieldName) {
        Map<String, String> mapPicklistLabelValue = new Map<String, String>();
        Map<Id, Account> accountIdMap = new Map<Id, Account>();
        Set<Id> accountIdSet = new Set<Id>();
        if(fromFieldName == CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME) {
            for(Apttus__APTS_Agreement__c agr : agreements) {
                if(agr.Apttus__Account__c != null && (oldMap == null 
                || (oldMap != null && oldMap.get(agr.Id).Apttus__Account__c != agr.Apttus__Account__c))) {
                    accountIdSet.add(agr.Apttus__Account__c);
                }
            }
        }
        if(!accountIdSet.isEmpty()) {
            Set<String> fieldSet = new Set<String>{'Id', CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME};
            accountIdMap = new SLT_Account().selectByAccountId(accountIdSet, fieldSet);
        }
        for(Apttus__APTS_Agreement__c agr : agreements) {
            if((oldMap == null || !accountIdMap.isEmpty()
            || (fromFieldName != CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME
            && oldMap != null && oldMap.get(agr.Id).get(fromFieldName) != agr.get(fromFieldName)))) {
                String sobjectName = !accountIdMap.isEmpty() ? 'Account' : 'Apttus__APTS_Agreement__c';
                mapPicklistLabelValue = UTL_CLM.getPicklistEntryValue(sobjectName, fromFieldName, true);
                String picklistOptionLabel = '';
                List<String> selectedCountryLabel = new List<String>();
                List<String> fieldValue = new List<String>();
                if(sobjectName == 'Account') {
                    picklistOptionLabel = mapPicklistLabelValue.get((String)accountIdMap.get(agr.Apttus__Account__c).get(fromFieldName));
                } else if(agr.get(fromFieldName) != null) {
                    selectedCountryLabel.addAll(((String)agr.get(fromFieldName)).split(';'));
                    for(String country : selectedCountryLabel) {
                        fieldValue.add(mapPicklistLabelValue.get(country));
                    }
                    picklistOptionLabel = String.join(fieldValue, ';');
                }
                agr.put(toFieldName, picklistOptionLabel);
            }
        }
    }

    /**
    * This method is used to update analyst start date on the agreement. 
    * @param List<Apttus__APTS_Agreement__c> agreements
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateAnalystStartDateOnAgr(List<Apttus__APTS_Agreement__c> agreements, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreements) {
            if(oldMap != null && agreement.Date_Tracking_Started__c != null 
                && agreement.Date_Tracking_Started__c != oldMap.get(agreement.Id).Date_Tracking_Started__c) {
                agreement.Analyst_Start_Date__c = agreement.Date_Tracking_Started__c; 
            }
        }
    }

    /**
    * This method is used to prevent the User from changing the currency from Agreement
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void preventUserFromUpdatingCurrencyFromAgreement(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((agreement.Apttus_QPComply__RelatedProposalId__c != null && oldMap != null
                && agreement.Apttus_QPComply__RelatedProposalId__c == oldMap.get(agreement.Id).Apttus_QPComply__RelatedProposalId__c
                && oldMap.get(agreement.Id).CurrencyIsoCode != agreement.CurrencyIsoCode)) {
                agreement.addError(System.Label.CLM_CL00018_AGR_CURRENCY_UPDATE_ERROR);
            }
        }
    }
    
    /**
    * This method updates Unsigned Comments Change Date when the Unsigned Comments field gets updated. 
    * @param List<Apttus__APTS_Agreement__c> lstAgreement
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap 
    */
    public static void updateUnsignedCommentsChangeDate(List<Apttus__APTS_Agreement__c> lstAgreement, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : lstAgreement) {
            if((oldMap == null && agreement.Unsigned_Comments__c != null) || (oldMap != null 
                && (agreement.Unsigned_Comments__c != oldMap.get(agreement.Id).Unsigned_Comments__c))) { 
                agreement.Unsigned_Status_Change_Date__c = System.today();
            }
        }    
    }

    /** 
     * This method populates 'Prob_to_move_to_High_Confidence_in_Qtr__c' when Confidence_In_Approval_Of_Budget_Draft__c is High
     * @params  agreementList List<Apttus__APTS_Agreement__c>
     * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void populateProbToMoveToHighConfidenceInQtr(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for (Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap == null || (oldMap != null && agreement.Confidence_In_Approval_Of_Budget_Draft__c != oldMap.get(agreement.id).Confidence_In_Approval_Of_Budget_Draft__c)) {
                if(agreement.Confidence_In_Approval_Of_Budget_Draft__c == CON_CLM.HIGH){
                    agreement.Prob_to_move_to_High_Confidence_in_Qtr__c = CON_CLM.LIKELY;
                } 
            }
        }
    } 
    
    /**
    * This method is used to move related quote stage to 'Cancelled'on agreement cancellation
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateRelatedQuoteOnAgreementCancellation(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> relatedQuoteProposalIdSet =  new Set<Id>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((agreement.Apttus__Status_Category__c == CON_CLM.CANCELLED && agreement.Apttus__Status__c == CON_CLM.CANCELLED_REQUEST) 
                && agreement.Apttus_QPComply__RelatedProposalId__c != null
                && (oldMap.get(agreement.Id).Apttus__Status__c != agreement.Apttus__Status__c &&
                oldMap.get(agreement.Id).Apttus__Status_Category__c != agreement.Apttus__Status_Category__c)) {
                relatedQuoteProposalIdSet.add(agreement.Apttus_QPComply__RelatedProposalId__c);
            }
        }
        if(!relatedQuoteProposalIdSet.isEmpty()) {
            CPQ_CLM_Utility.cancelQuoteOnAgreementCancellation(relatedQuoteProposalIdSet);
        }
    }
    
    /**
    * This method is used to validate quote and move related quote stage to 'Accepted' on the agreement activation
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateRelatedQuoteStageOnAgrActivation(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Map<Id, Apttus_Proposal__Proposal__c> proposalIdMap = new Map<Id, Apttus_Proposal__Proposal__c>(); 
        Set<Id> relatedQuoteProposalIdSet =  new Set<Id>();
        Map<Id, List<String>> acceptedQuoteProposalMapForActivated = new Map<Id, List<String>>();
        Map<Id, List<String>> quoteIdToErrorListMap = new Map<Id, List<String>>();   
        Set<String> quoteFieldsSet = new Set<String>{'Id', 'Apttus_Proposal__Approval_Stage__c'};
        Map<Id, Apttus__APTS_Agreement__c> quoteIdToAgreementActivateMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Apttus__APTS_Agreement__c> quoteIdToAgreementInSignaturesMap = new Map<Id, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES || agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT)  
                && agreement.Apttus_QPComply__RelatedProposalId__c != null && (oldMap != null  
                && (agreement.Apttus__Status_Category__c != oldMap.get(agreement.Id).Apttus__Status_Category__c))) {
                relatedQuoteProposalIdSet.add(agreement.Apttus_QPComply__RelatedProposalId__c);
            }
        }
        if(!relatedQuoteProposalIdSet.isEmpty()) {
            proposalIdMap = new Map<Id, Apttus_Proposal__Proposal__c>(new SLT_Proposal().getProposalsById(relatedQuoteProposalIdSet, quoteFieldsSet));
        }
        if(proposalIdMap != null && !proposalIdMap.isEmpty()) {
            for(Apttus__APTS_Agreement__c agreement : agreementList) {
                if(proposalIdMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) 
                    && proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c) != null) {
                    Apttus_Proposal__Proposal__c proposal = proposalIdMap.get(agreement.Apttus_QPComply__RelatedProposalId__c);
                    if(agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES) { 
                        quoteIdToAgreementInSignaturesMap.put(proposal.Id, agreement);
                    }
                    else if(agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agreement.Apttus__Status__c == CON_CLM.ACTIVATED) {
                        quoteIdToAgreementActivateMap.put(proposal.Id, agreement);
                    }
                }
            } 
        }
        if(!quoteIdToAgreementInSignaturesMap.isEmpty()) {
            quoteIdToErrorListMap = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(quoteIdToAgreementInSignaturesMap, false);
        }     
        if(!quoteIdToAgreementActivateMap.isEmpty()) {
            acceptedQuoteProposalMapForActivated = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(quoteIdToAgreementActivateMap, true); 
        }
        if(!quoteIdToErrorListMap.isEmpty() || !acceptedQuoteProposalMapForActivated.isEmpty()) {
            for(Apttus__APTS_Agreement__c agreement : agreementList) {
                if(quoteIdToErrorListMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) 
                    && !(quoteIdToErrorListMap.get(agreement.Apttus_QPComply__RelatedProposalId__c)).isEmpty()) {
                    agreement.addError(getQuoteErrorMessageBySequence(quoteIdToErrorListMap.get(agreement.Apttus_QPComply__RelatedProposalId__c)) + CON_CLM.IN_SIGNATURE_QUOTE_ERROR);
                }
                if(acceptedQuoteProposalMapForActivated.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) 
                    && !(acceptedQuoteProposalMapForActivated.get(agreement.Apttus_QPComply__RelatedProposalId__c)).isEmpty()) {                
                    agreement.addError(getQuoteErrorMessageBySequence(acceptedQuoteProposalMapForActivated.get(agreement.Apttus_QPComply__RelatedProposalId__c)) + CON_CLM.IN_EFFECT_QUOTE_ERROR);
                }
            }
        }
    }
    
    /**
    * This method is used to get related quote error message by sequence
    * @param List<String> errorList
    * @return String
    */ 
    @testVisible
    private static String getQuoteErrorMessageBySequence(List<String> errorList) {
        String errorMessage = '';
        for(Integer i = 1; i <= errorList.size(); i++) {
            errorMessage += i + '. ' + errorList.get(i-1) + '  ';
        }
        return errorMessage + ' - ';
    } 

    /**
    * This method is used to update Term(Month)
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params oldMap Map<Id, Apttus__APTS_Agreement__c>
    */
    public static void updateTermMonthValue(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((oldMap == null && agreement.Apttus__Contract_Start_Date__c != null && agreement.Apttus__Contract_End_Date__c != null) 
               || (oldMap != null && agreement.Apttus__Contract_Start_Date__c != null && agreement.Apttus__Contract_End_Date__c != null && 
               (agreement.Apttus__Contract_Start_Date__c != oldMap.get(agreement.Id).Apttus__Contract_Start_Date__c
                || agreement.Apttus__Contract_End_Date__c != oldMap.get(agreement.Id).Apttus__Contract_End_Date__c))) {
                agreement.Apttus__Term_Months__c = 12*((agreement.Apttus__Contract_End_Date__c).year() - (agreement.Apttus__Contract_Start_Date__c).year()) + 
                        ((agreement.Apttus__Contract_End_Date__c).month() -(agreement.Apttus__Contract_Start_Date__c).month());
                if((agreement.Apttus__Contract_End_Date__c).day() - (agreement.Apttus__Contract_Start_Date__c).day() >= 15) {
                    agreement.Apttus__Term_Months__c +=1;
                }
                else if((agreement.Apttus__Contract_Start_Date__c).day() - (agreement.Apttus__Contract_End_Date__c).day()> 0 
                        && (agreement.Apttus__Contract_Start_Date__c).day() - (agreement.Apttus__Contract_End_Date__c).day() <15) {
                    agreement.Apttus__Term_Months__c -=1;
                }
            }
        }
    }

    /**
    * This method is used to prevent the User to fill Company Signed By and Other Party Signed by 
    * if record type is incorrect
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void validateSignerInfo(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.Apttus__Company_Signed_By__c != null 
                && agreement.Apttus__Company_Signed_By__c != oldMap.get(agreement.Id).Apttus__Company_Signed_By__c)  {
                contactIds.add(agreement.Apttus__Company_Signed_By__c);
            } 
            if(agreement.Apttus__Other_Party_Signed_By__c != null
                && agreement.Apttus__Other_Party_Signed_By__c != oldMap.get(agreement.Id).Apttus__Other_Party_Signed_By__c) {
                contactIds.add(agreement.Apttus__Other_Party_Signed_By__c);
            } 
        }
        if(!contactIds.isEmpty()) {
            Map<Id,Contact> contactMap = new SLT_Contact().selectByContactId(contactIds, new Set<String>{'Id','RecordType.DeveloperName'});
            for(Apttus__APTS_Agreement__c agreement : agreementList) {
                if(agreement.Apttus__Company_Signed_By__c != null 
                    && agreement.Apttus__Company_Signed_By__c != oldMap.get(agreement.Id).Apttus__Company_Signed_By__c
                    && contactMap.containsKey(agreement.Apttus__Company_Signed_By__c)
                    && contactMap.get(agreement.Apttus__Company_Signed_By__c).RecordType.DeveloperName != 'IQVIA_User_Contact') {
                    agreement.addError('Apttus__Company_Signed_By__c','You have selected an external contact, please select an Internal IQVIA User Contact.');
                }
                if(agreement.Apttus__Other_Party_Signed_By__c != null 
                    && agreement.Apttus__Other_Party_Signed_By__c != oldMap.get(agreement.Id).Apttus__Other_Party_Signed_By__c
                    && contactMap.containsKey(agreement.Apttus__Other_Party_Signed_By__c)
                    && contactMap.get(agreement.Apttus__Other_Party_Signed_By__c).RecordType.DeveloperName == 'IQVIA_User_Contact') {
                    agreement.addError('Apttus__Other_Party_Signed_By__c','You have selected an internal contact, please select an External Contact.');
                }
            }
        }
    }
    /**
    * This method is used to share activated agreements on related opportunity
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void shareActivatedAGRDocOnOpp(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> agreementIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap != null && agreement.Apttus__Related_Opportunity__c != null
                && agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT 
                && agreement.Apttus__Status__c == CON_CLM.ACTIVATED
                && agreement.Apttus__Activated_Date__c != null
                && (agreement.Apttus__Status_Category__c != oldMap.get(agreement.Id).Apttus__Status_Category__c
                || agreement.Apttus__Status__c != oldMap.get(agreement.Id).Apttus__Status__c
                || (oldMap.get(agreement.Id).Apttus__Activated_Date__c == null
                && agreement.Apttus__Activated_Date__c != oldMap.get(agreement.Id).Apttus__Activated_Date__c))) { 
                agreementIds.add(agreement.Id);
            } 
        }
        if(!agreementIds.isEmpty()) {
            shareActivatedAGRDocOnOpp(agreementIds);
        }
    }
    /**
    * Future method is used to share activated agreements on related opportunity
    * @params  Set<Id> agreementIds
    */
    @future
    public static void shareActivatedAGRDocOnOpp(Set<Id> agreementIds) {
        Map<Id,Id> dvdIdOppIdMap = new Map<Id,Id>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        for(Apttus__DocumentVersion__c documentVersion: new SLT_DocumentVersion().getDocumentVersionByAgreementId(
            agreementIds,new Set<String>{'Id','Apttus__LatestVersionId__c','Apttus__AgreementId__r.Apttus__Related_Opportunity__c'})){
            dvdIdOppIdMap.put(documentVersion.Apttus__LatestVersionId__c,documentVersion.Apttus__AgreementId__r.Apttus__Related_Opportunity__c);
        }
        for(ContentDocumentLink cdl :new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(dvdIdOppIdMap.keySet())) {
            if(dvdIdOppIdMap.containsKey(cdl.LinkedEntityId)) {
                ContentDocumentLink cdlOpp = cdl.clone(false, true, false, false);
                cdlOpp.LinkedEntityId = dvdIdOppIdMap.get(cdl.LinkedEntityId);
                cdlOpp.ShareType = 'V';
                cdlToInsert.add(cdlOpp);
            }
        }
        if(!cdlToInsert.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        ContentDocumentLink.SObjectType
                    }
                );
                uow.registerNew(cdlToInsert);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }

    /**
    * This method is used to create tasks on agreement in authoring status category
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */ 
    public static void createTasksOnAgreementsInAuthoring(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        List<Task> lstTask = new List<Task>(); 
        Set<Id> ownerIdSet = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> agreementIdToAgreementMap = new Map<Id, Apttus__APTS_Agreement__c>();   
        Map<String, Id> agreementIdToTaskIdMap = new  Map<String, Id>();
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((agreement.Apttus__Status_Category__c != oldMap.get(agreement.Id).Apttus__Status_Category__c)
                && (oldMap.get(agreement.Id).Apttus__Status_Category__c == CON_CLM.REQUEST
                || oldMap.get(agreement.Id).Apttus__Status_Category__c == CON_CLM.IN_BUDGETING)
                && (agreement.Apttus__Status_Category__c == CON_CLM.IN_AUTHORING)) {  
                ownerIdSet.add(agreement.OwnerId);  
                agreementIdToAgreementMap.put(agreement.Id, agreement);
            }  
        }
        if(!agreementIdToAgreementMap.isEmpty()) {
            String condition = 'WhatId IN: whatIds AND Subject IN (\''+CON_CLM.SUBTYPE_PL+'\', \''+CON_CLM.SUBTYPE_PFM+'\', \''+CON_CLM.SUBTYPE_QC+'\', \''+CON_CLM.SUBTYPE_LCN_CHECK + '\', \''+CON_CLM.SUBTYPE_BAM + '\') AND Type=\''+CON_CLM.TASK_TYPE_REVIEW_APPROVAL+'\'';    
            List<Task> oldTaskList = new SLT_Task().selectTaskByWhatIds(new Set<String>{'Id', 'WhatId', 'Subject'}, agreementIdToAgreementMap.keySet(), condition);
            for(Task t : oldTaskList) {
                agreementIdToTaskIdMap.put((t.WhatId + t.Subject), t.Id);
            } 
        }
        for(Apttus__APTS_Agreement__c agreement : agreementIdToAgreementMap.values()) {
            if(!agreementIdToTaskIdMap.containsKey(agreement.Id + CON_CLM.SUBTYPE_PL) && !CON_CLM.EXCLUDED_REC_TYPE_FOR_TASK.contains(agreement.recordTypeId))
                lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_PL, 
                    Description = 'Contract PL review', OwnerId = agreement.OwnerId, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL, Sub_Type__c = CON_CLM.SUBTYPE_PL));
            if(!agreementIdToTaskIdMap.containsKey(agreement.Id + CON_CLM.SUBTYPE_PFM) && !CON_CLM.EXCLUDED_REC_TYPE_FOR_TASK.contains(agreement.recordTypeId))
                lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_PFM, 
                    Description = 'Contract PFM review', OwnerId = agreement.OwnerId, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL, Sub_Type__c = CON_CLM.SUBTYPE_PFM)); 
            if(!agreementIdToTaskIdMap.containsKey(agreement.Id + CON_CLM.SUBTYPE_QC) && !CON_CLM.EXCLUDED_REC_TYPE_FOR_TASK.contains(agreement.recordTypeId))
                lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_QC, 
                    Description = 'Contract QC review', OwnerId = agreement.OwnerId, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL, Sub_Type__c = CON_CLM.SUBTYPE_QC));  
            if(!agreementIdToTaskIdMap.containsKey(agreement.Id + CON_CLM.SUBTYPE_LCN_CHECK))
                lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_LCN_CHECK, 
                    Description = 'LCN Escalation Check is pending', OwnerId = agreement.OwnerId, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL, Sub_Type__c = CON_CLM.SUBTYPE_LCN_CHECK));  
            if(!agreementIdToTaskIdMap.containsKey(agreement.Id + CON_CLM.SUBTYPE_BAM) && !CON_CLM.EXCLUDED_REC_TYPE_FOR_TASK.contains(agreement.recordTypeId))
                lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_BAM, 
                    Description = 'Contract BAM review', OwnerId = agreement.OwnerId, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL, Sub_Type__c = CON_CLM.SUBTYPE_BAM));  
        }
        if(!lstTask.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Task.SObjectType
                    }
                );
                uow.registerNew(lstTask);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }  
    }

    /**
    * This method is used to create tasks on agreement when IQVIA Contract Manager/Negotiator is assigned
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */ 
    public static void createTaskonContractManagerUpdate(List<Apttus__APTS_Agreement__c> agreements, 
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        List<Task> lstTask = new List<Task>();
        List<Task> taskList = new List<Task>();
        Set<Id> contractManagerIdSet = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Id> agreementIdtoTaskId = new Map<Id, Id>();
        for(Apttus__APTS_Agreement__c agreement : agreements) {
            if(oldMap != null && agreement.IQVIA_Contract_Manager__c != null 
            && agreement.IQVIA_Contract_Manager__c != oldMap.get(agreement.Id).IQVIA_Contract_Manager__c) {        		
                agreementMap.put(agreement.Id, agreement);
                contractManagerIdSet.add(agreement.IQVIA_Contract_Manager__c);
            }
        }
        String condition = 'WhatId =: whatIds and Subject = \''+CON_CLM.SUBTYPE_LCN+'\'';
        if(!agreementMap.isEmpty()) {
            taskList = new SLT_Task().selectTaskByWhatIds(new Set<String>{'Id','WhatId'}, agreementMap.keyset(), condition);
        }
        for(Task task: taskList) {
            agreementIdtoTaskId.put(task.WhatId, task.Id);
        }
        Map<Id, Contact> contactMap = new SLT_Contact().getContactDetailsMap(contractManagerIdSet, new Set<String> {'Id','Salesforce_User__c'});
        for(Apttus__APTS_Agreement__c agreement : agreementMap.values()) {
            String taskOwner = (contactMap.get(agreement.IQVIA_Contract_Manager__c).Salesforce_User__c == null) ? agreement.OwnerId : contactMap.get(agreement.IQVIA_Contract_Manager__c).Salesforce_User__c ;
            lstTask.add(new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id,
            Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_LCN, Description = 'Contract LCN Review',
            OwnerId = taskOwner, Type = CON_CLM.TASK_TYPE_REVIEW_APPROVAL,
            Sub_Type__c = CON_CLM.SUBTYPE_LCN, Id = agreementIdtoTaskId.get(agreement.Id)));
        }
        if(!lstTask.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Task.SObjectType
                    }
                );
                uow.registerUpsert(lstTask);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }  
    }

    /**
    * This method is used to update Parent Agreement(Apttus__Parent_Agreement__c field)
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params oldMap Map<Id, Apttus__APTS_Agreement__c>
    */
    public static void updateParentAgreement(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if((oldMap == null || (oldMap != null 
               && agreement.Related_Master_Agreement__c != oldMap.get(agreement.Id).Related_Master_Agreement__c))) {
               agreement.Apttus__Parent_Agreement__c = agreement.Related_Master_Agreement__c;
            }
        }
    }
    /**
    * This method is used to populate Agreement Start Date
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params oldMap Map<Id, Apttus__APTS_Agreement__c>
    */
    public static void populateAgreementStartDate(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap != null 
                && agreement.Apttus__Status__c == CON_CLM.FULLY_SIGNED
                && agreement.Apttus__Contract_Start_Date__c == null) {
                agreement.Apttus__Contract_Start_Date__c = (agreement.Apttus__Company_Signed_Date__c != null && agreement.Apttus__Other_Party_Signed_Date__c != null) ? 
                    (agreement.Apttus__Company_Signed_Date__c > agreement.Apttus__Other_Party_Signed_Date__c ? agreement.Apttus__Company_Signed_Date__c : agreement.Apttus__Other_Party_Signed_Date__c)  : 
                    (agreement.Apttus__Company_Signed_Date__c != null ? agreement.Apttus__Company_Signed_Date__c : (agreement.Apttus__Other_Party_Signed_Date__c != null ? agreement.Apttus__Other_Party_Signed_Date__c : null));  
            }
        }
    }
    
    /**
    * This method is used to populate Date first sent to Customer
    * @params  agreementList List<Apttus__APTS_Agreement__c>
    * @params oldMap Map<Id, Apttus__APTS_Agreement__c>
    */
    public static void populateDateFirstSentToCustomer(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap != null && agreement.Apttus__Status__c != oldMap.get(agreement.Id).Apttus__Status__c &&
                (agreement.Apttus__Status__c == CON_CLM.BUDGET_EXTERNAL_REVIEW) && 
                agreement.Date_first_sent_to_Customer__c == null) {
                agreement.Date_first_sent_to_Customer__c = System.today();
            }
        }
    }

    /**
     * This method used to set Notify Customer If FD Missing in V Cont. Field.
     * @param List<Apttus__APTS_Agreement__c> agreements
     * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
     */
    public static void setNotifyCustomerIfMissingINVCont(List<Apttus__APTS_Agreement__c> agreements, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement: agreements) {
            if(oldMap != null && agreement.Does_MSA_Include_3rd_Party_Flow_Downs__c != oldMap.get(agreement.id).Does_MSA_Include_3rd_Party_Flow_Downs__c &&
                agreement.Does_MSA_Include_3rd_Party_Flow_Downs__c == CON_CLM.NO) {
                agreement.Notify_Customer_if_FD_missing_in_V_Cont__c = CON_CLM.NA;
            }
        }
    }
    
    /**
    * This method is used to update status and status category for parallel change order amendments 
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */ 
    public static void updateParallelChangeOrderAmendments(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> agrIds = new Set<Id>(); 
        Boolean isCancelled = false; 
        Set<String> agreementNumbers = new Set<String>();
        Set<Id> siblingAgrIds = new Set<Id>(); 
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'Apttus__Status_Category__c', 'Apttus__Status__c', 'Agreement_Cloned_From__c', 'Apttus__Agreement_Number__c', 'Special_Terms_Included__c'}; 
        Map<String, Apttus__APTS_Agreement__c> agrNoToInFlightAgrMap = new Map<String, Apttus__APTS_Agreement__c>();
        Map<String, Apttus__APTS_Agreement__c> agrNoToBeingAmendedAgrMap = new Map<String, Apttus__APTS_Agreement__c>(); 
        Map<Id, Id> inFlightIdToBeingAmendedIdMap = new Map<Id, Id>();
        for(Apttus__APTS_Agreement__c agr : agreementList) {
            if((((agr.Apttus__Status_Category__c != oldMap.get(agr.Id).Apttus__Status_Category__c) 
                && (agr.Apttus__Status_Category__c == CON_CLM.CANCELLED || agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT 
                || agr.Apttus__Status_Category__c == CON_CLM.AMENDED))
                || ((agr.Apttus__Status__c != oldMap.get(agr.Id).Apttus__Status__c) && agr.Apttus__Status__c == CON_CLM.ACTIVATED)
                || ((agr.Special_Terms_Included__c != oldMap.get(agr.Id).Special_Terms_Included__c) && (agr.Special_Terms_Included__c == CON_CLM.PARALLEL_CO))) 
                && (agr.Apttus_QPComply__RelatedProposalId__c != null || agr.RecordTypeId == CON_CLM.RWLP_RECORDTYPEID)) {
                if(oldMap.get(agr.Id).Apttus__Status_Category__c == CON_CLM.AMENDED) {
                    agr.Apttus__Status_Category__c = CON_CLM.AMENDED;
                    agr.Apttus__Status__c = CON_CLM.SUPERSEDED;
                }
                else if(oldMap.get(agr.Id).Apttus__Status__c == CON_CLM.BEING_AMENDED && agr.Apttus__Status__c == CON_CLM.ACTIVATED) {
                    agreementNumbers.add(agr.Apttus__Agreement_Number__c);
                }
                else {
                    agreementNumbers.add(agr.Apttus__Agreement_Number__c);
                    agrIds.add(agr.Id);
                }                 
            }
        }
        if(!agrIds.isEmpty() || !agreementNumbers.isEmpty()) {
            String condition = 'Apttus__Agreement_Number__c IN: strSet AND (Id NOT IN: agrIds)' 
                + 'AND ((Apttus__Status_Category__c IN (\'' + CON_CLM.REQUEST + '\', \'' + CON_CLM.IN_BUDGETING + '\', \'' + CON_CLM.IN_AUTHORING + '\', \'' + CON_CLM.IN_APPROVAL + '\' ,\'' + CON_CLM.IN_SIGNATURES + '\'))' 
                + 'OR (Apttus__Status_Category__c = \'' + CON_CLM.IN_EFFECT + '\' AND Apttus__Status__c = \'' + CON_CLM.BEING_AMENDED + '\'))';
            lstAgreement = new SLT_Agreement().getAgreementListByConditions(fieldSet, agreementNumbers, agrIds, condition, '');
        }
        for(Apttus__APTS_Agreement__c ag : lstAgreement) {
            if(ag.Apttus__Status_Category__c == CON_CLM.REQUEST || ag.Apttus__Status_Category__c == CON_CLM.IN_AUTHORING 
                || ag.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES || ag.Apttus__Status_Category__c == CON_CLM.IN_APPROVAL || ag.Apttus__Status_Category__c == CON_CLM.IN_BUDGETING) {
                agrNoToInFlightAgrMap.put(ag.Apttus__Agreement_Number__c, ag);
            }
            if(ag.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && ag.Apttus__Status__c == CON_CLM.BEING_AMENDED) {
                agrNoToBeingAmendedAgrMap.put(ag.Apttus__Agreement_Number__c, ag);
            }
        }
        for(Apttus__APTS_Agreement__c agr : agreementList) {
            if(agrNoToBeingAmendedAgrMap.containsKey(agr.Apttus__Agreement_Number__c) && agrNoToInFlightAgrMap.containsKey(agr.Apttus__Agreement_Number__c)
                && agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agr.Apttus__Status__c == CON_CLM.ACTIVATED) {
                if(agr.Special_Terms_Included__c != CON_CLM.PARALLEL_CO) {
                    siblingAgrIds.add(agr.Id);
                }    
                if(agr.Special_Terms_Included__c == CON_CLM.PARALLEL_CO) {
                    agr.Apttus__Status__c = CON_CLM.BEING_AMENDED;
                    inFlightIdToBeingAmendedIdMap.put(agrNoToInFlightAgrMap.get(agr.Apttus__Agreement_Number__c).Id, agr.Id);
                }                    
            }
            else if(!agrNoToBeingAmendedAgrMap.containsKey(agr.Apttus__Agreement_Number__c) && agrNoToInFlightAgrMap.containsKey(agr.Apttus__Agreement_Number__c)
                && agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agr.Apttus__Status__c == CON_CLM.ACTIVATED && agr.Special_Terms_Included__c == CON_CLM.PARALLEL_CO) {
                agr.Apttus__Status__c = CON_CLM.BEING_AMENDED;
                inFlightIdToBeingAmendedIdMap.put(agrNoToInFlightAgrMap.get(agr.Apttus__Agreement_Number__c).Id, agr.Id); 
            }
            else if(agrNoToBeingAmendedAgrMap.containsKey(agr.Apttus__Agreement_Number__c) && !agrNoToInFlightAgrMap.containsKey(agr.Apttus__Agreement_Number__c)
                && agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agr.Apttus__Status__c == CON_CLM.ACTIVATED 
                && agrNoToBeingAmendedAgrMap.get(agr.Apttus__Agreement_Number__c).Id != agr.Id) {
                siblingAgrIds.add(agrNoToBeingAmendedAgrMap.get(agr.Apttus__Agreement_Number__c).Id);
            }
            else if(agrNoToBeingAmendedAgrMap.containsKey(agr.Apttus__Agreement_Number__c) && !agrNoToInFlightAgrMap.containsKey(agr.Apttus__Agreement_Number__c)
                && agr.Apttus__Status_Category__c == CON_CLM.CANCELLED && agr.Apttus__Status__c == CON_CLM.CANCELLED_REQUEST) {
                siblingAgrIds.add(agrNoToBeingAmendedAgrMap.get(agr.Apttus__Agreement_Number__c).Id);
                isCancelled = true;
            }      
        }
        if(!siblingAgrIds.isEmpty()) {
            updateSiblingAgrForParallelCO(siblingAgrIds, isCancelled);
        }
        if(!inFlightIdToBeingAmendedIdMap.isEmpty()) {
            System.enqueueJob(new QUE_CLM_ParallelCO(inFlightIdToBeingAmendedIdMap));
        }
    }
    
    /**
    * This method is used to update sibling agreement for parallel change order amendments
    * @param Set<Id> agrSet
    * @param Boolean isCancelled
    */ 
    @future
    public static void updateSiblingAgrForParallelCO(Set<Id> agrSet, Boolean isCancelled) {
        Set<String> fieldSet = new Set<String>{'Id', 'Apttus__Status_Category__c', 'Apttus__Status__c', 'Special_Terms_Included__c'}; 
        List<Apttus__APTS_Agreement__c> lstAgreement = new SLT_Agreement().getAgreementFieldsById(agrSet, fieldSet); 
        for(Apttus__APTS_Agreement__c agr : lstAgreement) {
            if(agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agr.Apttus__Status__c == CON_CLM.BEING_AMENDED) {
                if(isCancelled) {
                    agr.Apttus__Status__c = CON_CLM.ACTIVATED;   
                }
                else {
                    agr.Apttus__Status_Category__c = CON_CLM.AMENDED;
                    agr.Apttus__Status__c = CON_CLM.SUPERSEDED;
                }
            }
            else if(agr.Apttus__Status_Category__c == CON_CLM.IN_EFFECT && agr.Apttus__Status__c == CON_CLM.ACTIVATED) {
                agr.Special_Terms_Included__c = CON_CLM.PARALLEL_CO;
            }
        }
        if(!lstAgreement.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(lstAgreement);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    /**
     * This method used to validate HC Budget Link
     * @param List<Apttus__APTS_Agreement__c> agreements
     * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
     */
    public static void validateHCBudgetLink(List<Apttus__APTS_Agreement__c> agreements, 
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<String> prelimType = new Set<String> {CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP, CON_CLM.REQUESTED_AGREEMENT_TYPE_SUWO, 
            CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT};
        for(Apttus__APTS_Agreement__c agreement: agreements) {
        	if(!prelimType.contains(agreement.Apttus__Subtype__c)
                && !prelimType.contains(agreement.Original_Agreement__r.Apttus__Subtype__c)
                && (oldMap == null || (oldMap != null 
            	&& (oldMap.get(agreement.Id).Confidence_In_Approval_Of_Budget_Draft__c != agreement.Confidence_In_Approval_Of_Budget_Draft__c)
              	||  oldMap.get(agreement.Id).High_Confidence_Budget_Link1__c != agreement.High_Confidence_Budget_Link1__c))
              	&& (agreement.Confidence_In_Approval_Of_Budget_Draft__c == CON_CLM.HIGH
                && String.isBlank(agreement.High_Confidence_Budget_Link1__c))) {
                agreement.High_Confidence_Budget_Link1__c.addError(System.Label.CLM_CL00025_HC_Budget_Link_Error);
            } 
        }
    } 

    /**
    * This method is used to sync IQVIA Agreement and Conga Agreement values.
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateIQAGRToInAuthoring(List<Apttus__APTS_Agreement__c> agreementList,
    Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> iqAgrIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c newAgreement : agreementList) {
            if(oldMap.get(newAgreement.Id).Apttus__Workflow_Trigger_Viewed_Final__c != newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c
                && oldMap.get(newAgreement.Id).Apttus__Status_Category__c == CON_CLM.REQUEST 
                && oldMap.get(newAgreement.Id).Apttus__Workflow_Trigger_Viewed_Final__c == false
                && newAgreement.IQVIA_Agreement__c != null) {
                iqAgrIds.add(newAgreement.IQVIA_Agreement__c);
            }
        }
        if(!iqAgrIds.isEmpty()) {
            List<IQVIA_Agreement__c> IQVIAAgreementList = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(
                iqAgrIds, new Set<String>{'Status__c', 'Status_Category__c', 'Subtype__c', 'Helper__c'});
            for(IQVIA_Agreement__c agr: IQVIAAgreementList) {
                if((agr.Helper__c == null ) || (agr.Helper__c != null && !agr.Helper__c.contains(CON_CLM.SELF_SERVICE_SOW))) {
                    agr.Status_Category__c = CON_CLM.IN_AUTHORING;
                    agr.Status__c = CON_CLM.AUTHOR_CONTRACT;
                }
            }
            if(!IQVIAAgreementList.isEmpty()) {     
                try {  
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    });
                    uow.registerDirty(IQVIAAgreementList);
                    uow.commitWork();
                }
                catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
            }
        }
    } 

    /**
    * This method is to validate the status change to Internal Review
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void validateStatusChangeToIR(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> agreementIds = new Set<Id>();
        Map<Id,DateTime> agrIdOPUpdateDate = new Map<Id,DateTime>();
        for(Apttus__APTS_Agreement__c newAgreement : newList) {
            if(oldMap != null && oldMap.get(newAgreement.Id).Apttus__Status__c != newAgreement.Apttus__Status__c
                && oldMap.get(newAgreement.Id).Apttus__Status__c == CON_CLM.STATUS_OTHER_PARTY_REVIEW
                && newAgreement.Apttus__Status__c == CON_CLM.INTERNAL_REVIEW
                && !UTL_ExecutionControl.skipValidate) {
                agreementIds.add(newAgreement.Id);
            }
        }
        if(!agreementIds.isEmpty()) {
            String condition = 'ParentId IN:parentIdSet AND Field = \'Apttus__Status__c\' and CreatedDate = Today';
            Set<String> setofFields = new Set<String> {'CreatedDate', 'NewValue', 'ParentId'};
            for(Apttus__APTS_Agreement__History agrH: new SLT_APTS_Agreement_History(false, false).getHistoryRecByParentId(agreementIds, setofFields, condition)) {
                if(agrH.NewValue == CON_CLM.STATUS_OTHER_PARTY_REVIEW && !agrIdOPUpdateDate.containsKey(agrH.ParentId)) {
                    agrIdOPUpdateDate.put(agrH.ParentId, agrH.CreatedDate);
                }
            }
            if(Test.isRunningTest()) {
                for(Id agrId: agreementIds) {
                    agrIdOPUpdateDate.put(agrId, DateTime.now());
                }
            }
            if(!agrIdOPUpdateDate.isEmpty()) {
                for(Apttus__APTS_Agreement__c newAgreement : newList) {
                    if(oldMap != null && oldMap.get(newAgreement.Id).Apttus__Status__c != newAgreement.Apttus__Status__c
                        && oldMap.get(newAgreement.Id).Apttus__Status__c == CON_CLM.STATUS_OTHER_PARTY_REVIEW
                        && newAgreement.Apttus__Status__c == CON_CLM.INTERNAL_REVIEW
                        && !UTL_ExecutionControl.skipValidate) {
                        Long historyCreatedDT = agrIdOPUpdateDate.get(newAgreement.Id).getTime();
                        Long currentDT = DateTime.now().getTime();
                        Long milliseconds = currentDT - historyCreatedDT;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        if(minutes < 1.5) {
                            newAgreement.addError(System.Label.CLM_CL00027_Internal_Review_Error);
                        }
                    }
                }
            }
        }
        UTL_ExecutionControl.skipValidate = false;
    }
    
    /**
    * This method is used to call UTL_OWF method to update Bid Due Date of Bid History
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */
    public static void updateBidonAgreementUpdate(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        List<Apttus__APTS_Agreement__c> agreements = new List<Apttus__APTS_Agreement__c>();
        List<BidHistoryWrapper> lstWrapper = new List<BidHistoryWrapper>();
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            if(oldMap != null && agreement.Bid_History__c != null 
                && ((oldMap.get(agreement.Id).Planned_Execution_Date__c != agreement.Planned_Execution_Date__c 
                && (agreement.Apttus__Status_Category__c == CON_CLM.REQUEST 
                || agreement.Apttus__Status_Category__c == CON_CLM.IN_BUDGETING 
                || agreement.Apttus__Status_Category__c == CON_CLM.IN_AUTHORING 
                || agreement.Apttus__Status_Category__c == CON_CLM.IN_APPROVAL 
                || agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES)) 
                ||(oldMap.get(agreement.Id).Apttus__Status_Category__c != agreement.Apttus__Status_Category__c
                && agreement.Apttus__Status_Category__c == CON_CLM.CANCELLED))) {
                agreements.add(agreement);
                BidHistoryWrapper wrapper = new BidHistoryWrapper();
                wrapper.SObjectName = 'Apttus__APTS_Agreement__c';
                wrapper.bidHistoryId = agreement.Bid_History__c;
                wrapper.agreementPlannedExecutionDate = agreement.Planned_Execution_Date__c;
                wrapper.statusCategory = agreement.Apttus__Status_Category__c;
                lstWrapper.add(wrapper); 
            }
        }
        if(!lstWrapper.isEmpty()) {
            try {
                UTL_OWF.updateContractPostAwardbidFromOtherObject(lstWrapper);
            }
            catch(Exception e) {
                for(Apttus__APTS_Agreement__c agreement: agreements) {
                    agreement.addError('Error from related Bid while updating Bid Due Date - :'
                        + e.getMessage().substringBefore('Class.'));
                }
            }
        }
    }

    /**
     * This method is used for populating IQ_Agreement_Record_Type_Developer_Name__c with the record type of associated IQ AGR
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @return void
     */
    public static void updateIQAGRRecordTypeName(List<Apttus__APTS_Agreement__c> agreementList) {
        Set<Id> setofIQAgrIds = new Set<Id>();  

        for (Apttus__APTS_Agreement__c agreement : agreementList) {
            if(agreement.IQVIA_Agreement__c != null) {
                setofIQAgrIds.add(agreement.IQVIA_Agreement__c);
            }
        }

        if(!setofIQAgrIds.isEmpty()) {
            
            Map<Id,IQVIA_Agreement__c> mapAgreement = new Map<Id,IQVIA_Agreement__c>(new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(setofIQAgrIds,
                new Set<String>{'Id', 'Record_Type_Developer_Name__c'}));
            if(!mapAgreement.isEmpty()) {
                for (Apttus__APTS_Agreement__c agreement : agreementList) {
                    if(mapAgreement.containsKey(agreement.IQVIA_Agreement__c)) {
                        agreement.IQ_Agreement_Record_Type_Developer_Name__c = mapAgreement.get(agreement.IQVIA_Agreement__c).Record_Type_Developer_Name__c;
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to set analyst start date from bid RR start date
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */    
    public static void setAnalystStartDateFromBidRR(List<Apttus__APTS_Agreement__c> agreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> bidIds = new Set<Id>();
        Map<Id, Date> bidIdToRRStartDateMap = new Map<Id, Date>();
        for(Apttus__APTS_Agreement__c agr : agreementList) {
            if(agr.Bid_History__c != null) {
                bidIds.add(agr.Bid_History__c);
            }
        }
        if(!bidIds.isEmpty()) {
            bidIdToRRStartDateMap = UTL_OWF.getAnalystStartDateforAgreement(bidIds);
        }
        if(!bidIdToRRStartDateMap.isEmpty()) {
            for(Apttus__APTS_Agreement__c agr: agreementList) {
                if(bidIdToRRStartDateMap.containsKey(agr.Bid_History__c)) {
                    agr.Analyst_Start_Date__c = bidIdToRRStartDateMap.get(agr.Bid_History__c);
                    agr.Start_Draft_Budget__c = bidIdToRRStartDateMap.get(agr.Bid_History__c);
                }
            }
        }
    }   

    /**
    * This method is used to set Perpetual field to true
    * @param List<Apttus__APTS_Agreement__c> agreementList
    * @param Map<Id, Apttus__APTS_Agreement__c> oldMap
    */ 
    public static void setPerpetualOnFullySigned(List<Apttus__APTS_Agreement__c> agreementList,
        Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for(Apttus__APTS_Agreement__c agreement : agreementList) {
            if(oldMap.get(agreement.Id).Apttus__Status__c != agreement.Apttus__Status__c && 
                (agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES && agreement.Apttus__Status__c == CON_CLM.FULLY_SIGNED)) {
                    agreement.Apttus__Perpetual__c = true;         
            }
        }
    }
}