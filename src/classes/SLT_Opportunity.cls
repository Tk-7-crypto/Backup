/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Opportunity
 */
public class SLT_Opportunity extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Opportunity() {
        super(false, true, false);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_Opportunity(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Opportunity.Id,Opportunity.Name,Opportunity.Opportunity_Number__c};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity.sObjectType;
    }
    
    /*
    * This method is use to query Opportunity on the basis of id to get the required details
    *
    */
    public Opportunity getOpportunityDetails(Id opportunityId, Set<String> fieldSet){
        return (Opportunity) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ID = :opportunityId').toSOQL());
    }
    
    /**
     * This method used to get Opportunity by Id
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> getOpportunityById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method is used to get Opportunity with Parent Id
     * @return List<Opportunity>
     */
    public List<Opportunity> getOpportunityByParentId(Set<String> fieldSet, Set<String> parentIdSet) {
        return (List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Parent_Opportunity__c IN :parentIdSet').toSOQL());
    }
    
    /**
     * This method used to get Opportunity by with Opportunity Splits and OpportunityTeam Members
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> oppSplitFieldSet
     * @params  Set<String> oppTeamFieldSet
     * @params  String splitType
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByIdWithOpportuntiyTeamSplits(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> oppSplitFieldSet, Set<String> oppTeamFieldSet, String splitType) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_OpportunitySplit().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNTIY_SPLITS, true).selectFields(oppSplitFieldSet).setCondition('SplitType.DeveloperName = :splitType');
        new SLT_OpportunityTeamMember().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_TEAM_MEMBERS, true).selectFields(oppTeamFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    /**
     * This method used to get Opportunity by with Opportunity line Items.
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> oliFieldSet
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByIdWithOpportuntiyLineItem(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> oliFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_OpportunityLineItems().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_LINE_ITEMS, true).selectFields(oliFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    public Map<Id, Opportunity> selectByIdWithOpportuntiyLineItemFilter(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> oliFieldSet, String oliCondition, Integer oliLimit) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_OpportunityLineItems().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_LINE_ITEMS, true).selectFields(oliFieldSet).setCondition(oliCondition).setOrdering(OpportunityLineItem.TotalPrice, fflib_QueryFactory.SortOrder.DESCENDING, true).setLimit(oliLimit);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    public Map<Id, Opportunity> selectAgreementByOpportunity(Set<Id> oppIdSet, Set<String> oppfieldSet, Set<Id> agreementRecordTypes,Set<String> agreementFields) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_Agreement().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_AGREEMENT_FIELD_API, true).selectFields(agreementFields).setCondition('RecordTypeId NOT IN : agreementRecordTypes');
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }

    /**
     * This method used to get Opportunity by with Bid History
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByIdWithOpportuntiyBidHistory(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> agreementFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        //new SLT_APTS_Agreement().addQueryFactorySubselect(opportunitiesQueryFactory, CON_OWF.OPPORTUNITY_Bid_History, true).selectFields(agreementFieldSet).setCondition('Bid_Number__c != NULL');
        new SLT_Bid_History().addQueryFactorySubselect(opportunitiesQueryFactory, CON_OWF.OPPORTUNITY_Bid_History, true).selectFields(agreementFieldSet).setCondition('Bid_Number__c != NULL');
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();

        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
        


    /**
     * This method used to get Opportunity with Agreements using agr conditions
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> agreementFieldSet
     * @params  String agrCondition
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByIdWithAgrCondtion(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> agreementFieldSet, String agrCondition) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_APTS_Agreement().addQueryFactorySubselect(opportunitiesQueryFactory, CON_OWF.OPPORTUNITY_AGREEMENTS, true).selectFields(agreementFieldSet).setCondition(agrCondition);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    /**
     * This method used to get Opportunity with Bid Histories using agr conditions
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> agreementFieldSet
     * @params  String agrCondition
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByIdWithBidHistoryCondtion(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> agreementFieldSet, String agrCondition) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
        new SLT_Bid_History().addQueryFactorySubselect(opportunitiesQueryFactory, CON_OWF.OPPORTUNITY_Bid_History, true).selectFields(agreementFieldSet).setCondition(agrCondition);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    /**
     * This method used to get Opportunities with Agreements
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> agreementFieldSet
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectAgreementByOpportunities(Set<Id> oppIdSet, Set<String> oppfieldSet, Set<String> agreementFields) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_Agreement().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_AGREEMENT_FIELD_API, true).selectFields(agreementFields);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        System.debug('queryString' + queryString);
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    /**
     * This method used to get Opportunities
     * @return  List<Opportunity>
     */
    public List<Opportunity> getOpportunityByFieldCondition(Set<String> fieldSet, List<String> fieldValueList, Set<String> opportunityIds) {
        return (List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Opportunity_Number__c in :fieldValueList OR Id in :opportunityIds').toSOQL());
    }

    public Map<Id, Opportunity> selectByIdWithBNF(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> bnfFieldSet) {
        Id BNF_RECORD_TYPE_SAP_INTEGRATED  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_BNF().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_BNF_RELATIONSHIP, true).selectFields(bnfFieldSet).setCondition('RecordtypeId =: BNF_RECORD_TYPE_SAP_INTEGRATED'); 
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    public Map<Id, Opportunity> selectByIdWithMIBNF(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> mibnfFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_MIBNF_Component().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_MIBNF_COMPONENT_RELATIONSHIP, true).selectFields(mibnfFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition('Id in :oppIdSet').toSOQL();
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(queryString));
    }
    
    /**
     * This method used to get Opportunity by Id
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByOpportunityId(Set<ID> oppIdSet, Set<String> fieldSet) {
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :oppIdSet').toSOQL()));
    }
    
    /**
     * This method used to get Opportunity by Number
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> selectByOpportunityNumber(Set<String> oppNumberSet, Set<String> fieldSet) {
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Legacy_Quintiles_Opportunity_Number__c in :oppNumberSet').toSOQL()));
    }

    
    public Map<Id, Opportunity> getMapOfOpportunitiesWithProjectsById(Set<Id> oppIdSet) {
        return new Map<Id, Opportunity>([SELECT (SELECT  Is_Project_Billable__c 
                                                 FROM Proxy_Projects__r WHERE Record_Type_Name__c =: CON_Qualtrics.RECORD_TYPE_PROJECT) 
                                         FROM Opportunity o 
                                         WHERE Id IN :oppIdSet 
                                        ]);
    }

    /**
     * This method is used to get Opportunity with Opportunity Histories.
     * @params  Set<String> oppfieldSet
     * @params  String oppCondition
     * @params  Set<String> oppHistoryFieldSet
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator getOpportunityWithOpportunityHistories(Set<String> oppfieldSet, String oppCondition, Set<String> oppHistoryFieldSet){
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_OpportunityHistory().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITY_HISTORY, true).selectFields(oppHistoryFieldSet).setOrdering(OpportunityHistory.createdDate, fflib_QueryFactory.SortOrder.DESCENDING, true);
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition(oppCondition).toSOQL();
        return Database.getQueryLocator(queryString);
    }
    
    /**
     * This method used to get Opportunities
     * @return  List<Opportunity>
     */
    public List<Opportunity> getOpportunityByCondition(Set<String> fieldSet,list<String> idslist,list<String> oppStageNameList) {
        return (List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account.Id IN : idslist AND StageName IN: oppStageNameList AND X7a_Closed_Won_Stage_Entry__c = NULL AND X7b_Closed_Lost_Stage_Entry__c = NULL').toSOQL());
    }
    
    /**
     * This method is used to get Opportunity with Opportunity Histories.
     * @params  Set<String> oppfieldSet
     * @params  Set<String> oppTeamMemberFieldSet
     * @return  List<Opportunity>
     */
    public Database.QueryLocator getOpportunityWithOpportunityTeamMember(Set<String> oppfieldSet,Set<Id> oppidSet,Set<String> oppTeamMemberFieldSet){
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_OpportunityTeamMember().addQueryFactorySubselect(opportunitiesQueryFactory,CON_CRM.OPPORTUNITY_TEAM_MEMBERS,true).selectFields(oppTeamMemberFieldSet);
        String oppCondition = 'id in :oppidSet';
        String queryString = opportunitiesQueryFactory.selectFields(oppfieldSet).setCondition(oppCondition).toSOQL();
        return Database.getQueryLocator(queryString);
    }
    

    public List<Opportunity> selectById(Set<ID> oppIdSet, Set<String> fieldSet) {
        return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :oppIdSet').toSOQL());
    }
    public List<Opportunity> selectBySearchString(String searchString, Set<String> fieldSet) {
        return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE '+searchString+'').toSOQL());
    }

    public Opportunity getRecordByIdForCallOut(String recId){
        return Database.query('SELECT Name, Owner.Name, Owner.Email, Phase_P__c, Indication_List__c, Line_of_Business__c, ' +
        ' Is_this_IQVIA_Biotech__c, Legacy_Quintiles_Opportunity_Number__c, ' +
        ' Verbatim_Indication_Term__c, Protocol_Number__c, Drug_Product_Name__c, Phase_1_Study_Type__c, ' +
        ' FSP__c, Population_Age_Group__c, Is_this_a_Virtual_Trials_Study__c  FROM Opportunity '+
        ' WHERE id =: recId');
    }   

    public List<Opportunity> getLegacyQuintilesByOpportunityById(Set<ID> oppIdSet, Set<String> fieldSet) {
        return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :oppIdSet').toSOQL());
    }
    /**
     * This method is used to get opportunity with Client Sat Survey by opportunityId
     * @params Set<Id> csIdSet
     * @return  List<Client_Sat_Survey__c>
     */
    public List<opportunity> getOpportunityWithClientSatByoppId(Set<Id> oppIdSet ,Date createdDate) {
        return [SELECT Id, is_Survey_eligible_for_RDS_Manual__c, (SELECT Id , Survey_Type__c, CreatedDate FROM Client_Sat_Surveys__r 
                                                                  where CreatedDate >: createdDate ORDER BY CreatedDate DESC Limit 1)                                                               
                FROM Opportunity where Id in : oppIdSet
               ];
    }
   
    /**
     * This method is used to get opportunity with Client Sat Survey by opportunityId
     * @params Set<Id> csIdSet
     * @return  List<Client_Sat_Survey__c>
     */
    public List<opportunity> getLatestSurveyOfOpportunity(Set<Id> oppIdSet) {
        return [SELECT Id, is_Survey_eligible_for_RDS_Manual__c, Line_of_Business__c, Principle_inCharge__c,
                Principle_inCharge__r.Salesforce_user__r.Name, Principle_inCharge__r.Salesforce_user__r.Email, 
                Principle_inCharge__r.Salesforce_user__r.FirstName, Principle_inCharge__r.Salesforce_user__r.LastName,
                Principle_inCharge__r.Salesforce_user__r.EmployeeNumber, Principle_inCharge__r.Salesforce_user__r.User_Country__c,
                Survey_PIC__c, Survey_PIC__r.Salesforce_user__r.Name, Survey_PIC__r.Salesforce_user__r.Email, Survey_PIC__r.Salesforce_user__r.FirstName,
                Survey_PIC__r.Salesforce_user__r.LastName, Survey_PIC__r.Salesforce_user__r.EmployeeNumber, Survey_PIC__r.Salesforce_user__r.User_Country__c,
                BidTeam_2__c, BidTeam_2__r.Salesforce_User__r.Name, BidTeam_2__r.Salesforce_User__r.Email, BidTeam_2__r.Salesforce_User__r.EmployeeNumber,
                Survey_Recipient__c, Survey_Recipient_2__c, Survey_Recipient_3__c, 
                (SELECT Id, Related_Contract_Id__c,Survey_Type__c,Survey_Send_Date__c,Send_Survey__c, Survey_Initiation_Status__c FROM Client_Sat_Surveys__r WHERE Survey_Send_Date__c >= :System.today() ORDER BY CreatedDate  DESC Limit 1)                                                               
                FROM Opportunity where Id in : oppIdSet
               ];
    }

    /**
     * This method is used to get Opportunity by Account Id and Stage Name
     * @params Set<Id> accountIdSet
     * @params Set<String> fieldSet
     * @params Set<String> stageNameSet
     * @return Map<Id, Opportunity>
     */
    public Map<Id,Opportunity> getOpportunityByAccountIdANDStage(Set<Id> accountIdSet, Set<String> fieldSet, Set<String> stageNameSet){
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('AccountId IN : accountIdSet AND StageName IN : stageNameSet').toSOQL()));
    }

    /**
     * This method is used to get Non existing survey opportunity by opportunityId
     * @params Set<Id> oppIdSet
     * @return  List<opportunity>
     */
    public List<opportunity> getOpportunityWithNonExistingsurvey(Set<Id> oppIdSet, Set<String> fieldSet, String condition) {
        condition = 'Id in : oppIdSet AND ' + condition;
        return (List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method is used to get opportunity with last Client Sat Survey
     * @params Set<Id> csIdSet
     * @return  List<Client_Sat_Survey__c>
     */
    public List<opportunity> getLastSurveyOfOpportunity(Set<Id> oppIdSet) {
        return [SELECT Id, (SELECT Id, Opportunity__c, Survey_PIC__c, Survey_Send_Date__c, Related_Contract_Id__c FROM Client_Sat_Surveys__r WHERE Survey_Send_Date__c < TODAY AND Send_Survey__c = 'Yes' ORDER BY CreatedDate DESC Limit 1) FROM Opportunity where Id in :oppIdSet ];
    }
    
    /**
     * This method is used to get opportunity with Client Sat Survey by opportunityId
     * @params Set<Id> csIdSet
     * @return  List<Client_Sat_Survey__c>
     */
    public List<opportunity> getLatestSurveyOfOpportunitybyLOB(Set<Id> oppIdSet, Set<String> lobSet) {
        return [SELECT Id, Line_of_Business__c, (SELECT Id, Opportunity__c, Related_Contract_Id__c, Survey_PIC__c,Send_Survey__c, Survey_Initiation_Status__c
                                                 FROM Client_Sat_Surveys__r WHERE Survey_Send_Date__c >= :System.today() 
                                                 ORDER BY CreatedDate DESC LIMIT 1) 
                FROM Opportunity WHERE Id IN :oppIdSet AND Line_of_Business__c IN :lobSet];
    }
    
    /**
     * This method is used to get contract with opportunity
     * @params Set<Id> oppIdSet
     * @params Set<String> LOBs
     * @params Set<Id> contractRecordTypes
     * @return  Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> getOpportunityWithContractsWithFilter(Set<Id> oppIdSet, Set<String> LOBs, Set<Id> contractRecordTypes, Set<String> LOBs1) {
        Set<String> LOBSet = new Set<String>(LOBs);
        LOBSet.addAll(LOBs1);
        return new Map<Id, Opportunity>([SELECT Id, Previous_survey_sent_date__c, Principle_inCharge__c, (SELECT Id, CreatedDate, IQVIA_Project_Manager_Contact__c FROM Contracts__r WHERE RecordTypeId IN :contractRecordTypes AND Opportunity__r.Line_Of_Business__c IN :LOBSet ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity where Id in :oppIdSet and Line_of_Business__c IN :LOBSet]);
    }
    
    /**
     * This method is used to get Opportunity where current user is Inside sales
     * @params Set<Id> fieldSet
     * @return List<Opportunity>
     */
    public List<Opportunity> getOpportunityWithInsideSalesUser(Set<String> fieldSet, string insideSalesUser ) {
         return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('IsClosed = false And Inside_Sales__c =: insideSalesUser').setLimit(1000).toSOQL());
    }

    /**
    * This method used to get list of opporutnity based on condition and opporunity ids
    * @return  list
    */
    public List<Opportunity> getOppWithAGRByCondition(Set<String> oppFields, String oppCondition, Set<Id> opportunityIds, Set<String> agrFields, String agrCondition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(oppFields);
		fflib_QueryFactory agreementQueryFactory = new SLT_APTS_Agreement().addQueryFactorySubselect(factory, 'Apttus__R00N50000001Xl0FEAS__r', true);
        agreementQueryFactory.selectFields(agrFields);
        if(!String.isBlank(agrCondition)) {
            agreementQueryFactory.setCondition(agrCondition);
        }
        if(!String.isBlank(oppCondition)) {
            factory.setCondition(oppCondition);
        }
        return Database.query(factory.toSOQL());
    }
	
	/**
     * This method used to get Opportunities for a particular Line of business
     * @params Set<ID> oppIDSet
     * @params Set<String> fieldSet
     * @params String lineOfBusiness
     * @return Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> getOppWithFilterCondition(Set<ID> oppIDSet, Set<String> fieldSet, String condition){
        condition = 'Id in : oppIDSet AND ' + condition;
        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
    
    /**
     * This method used to get Opportunities for a User Set
     * @params Set<String> fieldSet
     * @params String condition
     * @params List<User> userList
     * @return List<Opportunity>
     */
    
    public List<Opportunity> getOppWithFilterOfUserId(Set<String> fieldSet,String condition,List<User> userList) {
        return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * method to get Opportunity by AccountId
     * @param Set<String> fieldSet
     * @param Set<Id> accountIdSet
     * @return List<Opportunity>
     */
    public List<Opportunity> getOppByAccountId(Set<String> fieldSet, Set<Id> accountIdSet) {
        return (List<Opportunity>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('AccountId IN :accountIdSet').toSOQL());
    }
    
    /**
     * method to get Opportunity with associated pricing assistent
     * @param Set<Id> oppIdSet
     * @return List<Opportunity>
     */
    public List<Opportunity> selectByIdWithPricingAssistant(Set<ID> oppIdSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        new SLT_PricingAssistant().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CPQ.OPP_WITH_PRICING_ASSISTANT, true).selectFields(new set<String>{CON_CPQ.ID, CON_CPQ.PRICING_CALCULATOR_STATUS});
        String queryString = opportunitiesQueryFactory.selectFields(new Set<String>{CON_CPQ.ID, CON_CPQ.LI_OPP_ID}).setCondition('Id in :oppIdSet').toSOQL();
        return  (List<Opportunity>) Database.query(queryString);
    }
}