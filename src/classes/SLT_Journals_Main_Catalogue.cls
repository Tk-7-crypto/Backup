public class SLT_Journals_Main_Catalogue extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Journals_Main_Catalogue() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Journals_Main_Catalogue(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Journals_Main_Catalogue__c.sObjectType;
    }
    
    /**
     * This method used to query Journals_Main_Catalogue__c
     * @return  List<Journals_Main_Catalogue__c>
     */
    public List<Journals_Main_Catalogue__c> getMainJournalCatalog(Set<String> fieldSet){
        return (List<Journals_Main_Catalogue__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method returns List<Journals_Main_Catalogue__c> from IDs
     */
    public List<Journals_Main_Catalogue__c> getJournalsMainCatalogueFromIds(Set<String> journalsMainCatalogueIds, Set<String> requestedFields){
    	List<Journals_Main_Catalogue__c> journalsMainCatalogues = (List<Journals_Main_Catalogue__c>) Database.query(newQueryFactory(true).selectFields(requestedFields).setCondition('Name IN :journalsMainCatalogueIds').toSOQL());
        return journalsMainCatalogues;
    }
} 
