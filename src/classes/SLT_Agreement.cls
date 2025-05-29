public class SLT_Agreement extends fflib_SObjectSelector{

    /**
      */
	public SLT_Agreement()
	{
	}
	
	/**
      */
    public SLT_Agreement(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            Apttus__APTS_Agreement__c.Id,
            Apttus__APTS_Agreement__c.Select_Pricing_Tool__c,
            Apttus__APTS_Agreement__c.Apttus__Related_Opportunity__c,
            Apttus__APTS_Agreement__c.Apttus__Is_System_Update__c,
            Apttus__APTS_Agreement__c.RECORDTYPEID
        };
    }

    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return CON_CRM.AGR_ORDERING_DESC;
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return Apttus__APTS_Agreement__c.sObjectType;
    }

    /**
    * This method used to get Apttus__APTS_Agreement__c by Id
    * @return  List<Apttus__APTS_Agreement__c>
    */
    public List<Apttus__APTS_Agreement__c> selectById(Set<Id> idSet){

        return (List<Apttus__APTS_Agreement__c>) selectSObjectsById(idSet);
    }

    /*
    * This method is use to query agreement on the basis of id to get the required details
    *
    */
    public Apttus__APTS_Agreement__c getAgreementDetails(Id agreementId, Set<String> fieldSet){
        return (Apttus__APTS_Agreement__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ID = :agreementId').toSOQL());
    }
    
    /*
    * This method is use to query agreement on the basis of id and record type
    *
    */
    public List<Apttus__APTS_Agreement__c> getAgreementDetailsByIdAndRecorType(Id agreementId, Set<Id> recordTypeIds,
        Set<String> fieldSet){
  
        return (List<Apttus__APTS_Agreement__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: agreementId AND RecordTypeId in:' +
                ' recordTypeIds').toSOQL());
    }
    
    /**
     * This method used to get Agreement by Id
     * @return  List<Apttus__APTS_Agreement__c>
     */
    public List<Apttus__APTS_Agreement__c> getAgreementFieldsById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Apttus__APTS_Agreement__c>) Database.query(
            									 newQueryFactory(true).
               									 selectFields(fieldSet).
               									 setCondition('Id in: idSet').
               									 toSOQL());
    }
    
    /*
    * This method is use to query agreement on the basis of id and record type
    *
    */
    public List<Apttus__APTS_Agreement__c> getAgreementDetailsByIdsAndRecorType(Set<Id> agreementIds, Set<Id> recordTypeIds,
                                                                                Set<String> fieldSet){

        return (List<Apttus__APTS_Agreement__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: agreementIds AND RecordTypeId in:' +
                                                                    ' recordTypeIds').toSOQL());
    }
    
	
    /**
     * This method used to get Agreement by Id
     * @return  List<Apttus__APTS_Agreement__c>
     */
    public List<Apttus__APTS_Agreement__c> getAgreementFieldsByIdAndRecordType(Set<ID> idSet, Set<String> fieldSet, String recordType) {
        return (List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN: idSet And RecordType.DeveloperName = :recordType').toSOQL());
    }

    /*
    * This method is use to query agreement with related items on the basis of id and record type
    * @return List<Apttus__APTS_Agreement__c>
    * @param Id
    * @param Set<Id>
    * @param Set<String>
    */
    public List<Apttus__APTS_Agreement__c> getAgreementDetailsByIdWithReletedFields(Id agreementId, Set<Id> recordTypeIds,
        Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        new SLT_Opportunity().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Related_Opportunity__c.getDescribe().getRelationShipName());
        new SLT_Account().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Account__c.getDescribe().getRelationShipName());
        new SLT_Contact().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Primary_Contact__c.getDescribe().getRelationShipName());
        new SLT_User().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Requestor__c.getDescribe().getRelationShipName());
        return (List<Apttus__APTS_Agreement__c>) Database.query(
            queryFactory.selectFields(fieldSet).setCondition('Id =: agreementId AND RecordTypeId IN:' + ' recordTypeIds').toSOQL());
    }
    
    /*
     * This method is use to query agreement with related items on the basis of id and record type
     * @return List<Apttus__APTS_Agreement__c>
     * @param Set<Id> agreementIdSet
     * @param Set<Id> recordTypeIds
     * @param Set<String> fieldSet
     */
    public List<Apttus__APTS_Agreement__c> getAgreementDetailsByIdWithReletedFields(Set<Id> agreementIdSet, Set<Id> recordTypeIds,
        Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        new SLT_Opportunity().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Related_Opportunity__c.getDescribe().getRelationShipName());
        new SLT_Account().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Account__c.getDescribe().getRelationShipName());
        new SLT_Contact().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Primary_Contact__c.getDescribe().getRelationShipName());
        new SLT_User().configureQueryFactoryFields(queryFactory, 
            Apttus__APTS_Agreement__c.Apttus__Requestor__c.getDescribe().getRelationShipName());
        return (List<Apttus__APTS_Agreement__c>) Database.query(
            queryFactory.selectFields(fieldSet).setCondition('Id IN: agreementIdSet AND RecordTypeId IN:' + ' recordTypeIds').toSOQL());
    }
	
    /**
     * This method used to get lists of attachment
     * @return  list
     */
    public List<Attachment> getLatestAttachments(String condition) {
        return Database.query('SELECT Id, Name, Body FROM Attachment WHERE ' + condition);
    }

    	public List<Apttus__APTS_Agreement__c> getAgreementByOpportunitesAll(Set<Id> oppIdset, Set<String> agreementFieldSet) {
        fflib_QueryFactory agreementQueryFactory = newQueryFactory(true);
        String queryString = agreementQueryFactory.selectFields(agreementFieldSet).setCondition('Apttus__Related_Opportunity__c in: oppIdset AND Bid_Due_Date__c >= TODAY').toSOQL();
        return ((List<Apttus__APTS_Agreement__c>) Database.query(queryString));
    }
    

    
    public Map<Id, Apttus__APTS_Agreement__c> selectAgreementById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    

    public Apttus__APTS_Agreement__c getRecordById(String recId){
        return Database.query('SELECT Apttus__Account__c, Regions__c, Therapy_Area__c,Indication__c, Intervention_Type__c,'+
        ' Drug_Name__c, RFP_Ranking__c, Phase__c, Targeted_Countries__c, Line_of_Business__c, IQVIA_biotech__c, Opportunity_Account__c,'+
        ' Is_there_a_Client_Bid_Grid__c,Full_Service__c,Requested_Services__c, Apttus__Related_Opportunity__r.Potential_Regions__c, '+
        ' Apttus__Related_Opportunity__r.Rare_Disease__c,Apttus__Related_Opportunity__c, Apttus__Related_Opportunity__r.InterventionType__c, '+
        ' Apttus__Related_Opportunity__r.AccountId FROM Apttus__APTS_Agreement__c '+
        ' WHERE Id =: recId');
    }
    public apttus__APTS_Agreement__c getRecordByIdForCallOut(String recId){
         return Database.query('SELECT Name, Apttus__Account__c, Apttus__Account__r.Name, Unity_Living_Proposal__c, Apttus__Related_Opportunity__c, Number_of_Sites__c, Targeted_Countries__c, '+
        'Indication__c, Intervention_Type__c, Opportunity_Type__c, Bid_Due_Date__c, Therapy_Area__c ' +
        ' FROM Apttus__APTS_Agreement__c'+
        ' WHERE Id =: recId');
    }
    
    /**
     * This method will query agreement on the basis of related opportunity and record type id of agreement
     * @param opportunityIds is the set contains the Ids of related opporunities
     * @param recordTypeIds is the set of agreement record type ids
     * @param fieldSet is the set of field which are going to fetched in query.
     * @return Map<Id, Apttus__APTS_Agreement__c> 
     */
    public Map<Id, Apttus__APTS_Agreement__c> getAgreementByOpportunityAndRecordTypeId(Set<Id> opportunityIds, 
        Set<Id> recordTypeIds, Set<String> fieldSet) {
        return new Map<Id, Apttus__APTS_Agreement__c>((List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition('Apttus__Related_Opportunity__c IN :opportunityIds ' + 
            'AND RecordTypeId IN :recordTypeIds').toSOQL()));
    }

     /**
    * This method used to get list of agreements
    * @return  list
    */
    public List<Apttus__APTS_Agreement__c> getAgreementListByCondition(Set<String> fields, String condition, Set<Id> agreementIds) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    
    /**
    * This method used to get list of agreements based on Agreement Number
    * @return  list
    */
    public List<Apttus__APTS_Agreement__c> getAgreementListByAgreementNumbers(Set<String> fields, Set<String> agreementNumbers) {
        return (List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true).selectFields(fields).setCondition(
            '(Apttus__Agreement_Number__c IN :agreementNumbers)')
             .setOrdering(new fflib_QueryFactory.Ordering('Apttus__APTS_Agreement__c', 'Apttus__Version_Number__c', fflib_QueryFactory.SortOrder.DESCENDING)).toSOQL());
    }

    /**
     * This method will query agreement on the basis of Quote
     * @param quoteIds is the set contains the Ids quote
     * @param fieldSet is the set of field which are going to fetched in query.
     * @return Map<Id, Apttus__APTS_Agreement__c> 
     */
    public List<Apttus__APTS_Agreement__c> getAgreementListByQuoteId(Set<Id> quoteIds, Set<String> fieldSet, String condition) {
        return (List<Apttus__APTS_Agreement__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
    * This method returns Apttus__APTS_Agreement__c list along with Document Version IDs on the basis of recordId   
    * @param Id recordId
    * @return List<Apttus__APTS_Agreement__c>
    */
    
    public List<Apttus__APTS_Agreement__c> getAgreementListWithDocumentVersions(set<ID> recordIds, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_DocumentVersion().addQueryFactorySubselect(queryFactory, 'Apttus__DocumentVersions__r');
        return (List<Apttus__APTS_Agreement__c>) Database.query(
            queryFactory.selectFields(fieldSet).setCondition('ID IN :recordIds').toSOQL());
    }
    
    /**
    * This method returns agreement list on the basis of conditions
    * @param Set<String> fieldSet
    * @param Set<String> strSet
    * @param Set<Id> agrIds
    * @param String condition
    * @param String orderField
    * @return List<Apttus__APTS_Agreement__c>
    */
    public List<Apttus__APTS_Agreement__c> getAgreementListByConditions(Set<String> fieldSet, Set<String> strSet, Set<Id> agrIds, String condition, String orderField) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fieldSet);
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        if(!String.isBlank(orderField)) {
            factory.setOrdering(orderField, fflib_QueryFactory.SortOrder.DESCENDING, true); 
        }
        return Database.query(factory.toSOQL());  
    }    
}