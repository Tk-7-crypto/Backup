/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for CSM_QI_Case_Categorization__c
 */
public class SLT_CaseCategorization extends fflib_SObjectSelector  {
    /**
* This method used to get field list of sobject
* @return  List<Schema.SObjectField>
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CSM_QI_Case_Categorization__c.Product__c,
            CSM_QI_Case_Categorization__c.SubType1__c,
            CSM_QI_Case_Categorization__c.SubType2__c,
            CSM_QI_Case_Categorization__c.SubType3__c,
            CSM_QI_Case_Categorization__c.CSHSubType__c,
            CSM_QI_Case_Categorization__c.CSH_Visible__c,
            CSM_QI_Case_Categorization__c.LOS__c,
            CSM_QI_Case_Categorization__c.Id,
            CSM_QI_Case_Categorization__c.ProductName__c,
            CSM_QI_Case_Categorization__c.Article_Chapter__c,
            CSM_QI_Case_Categorization__c.CaseType__c,
            CSM_QI_Case_Categorization__c.Affects_Version__c,
            CSM_QI_Case_Categorization__c.RnD_Template__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CSM_QI_Case_Categorization__c.sObjectType;
    }
    
    /**
     * This method used to get CSM_QI_Case_Categorization__c by Id
     * @return  List<CSM_QI_Case_Categorization__c>
     */
    public List<CSM_QI_Case_Categorization__c> selectById(Set<ID> idSet) {
        return (List<CSM_QI_Case_Categorization__c>) selectSObjectsById(idSet);
    }
    
     public Map<Id, CSM_QI_Case_Categorization__c> getById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, CSM_QI_Case_Categorization__c>((List<CSM_QI_Case_Categorization__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get ALL CSM_QI_Case_Categorization__c 
     * @return  List<CSM_QI_Case_Categorization__c>
     */
    public List<CSM_QI_Case_Categorization__c> getAllCaseCategorization() {
        return (List<CSM_QI_Case_Categorization__c>) Database.query(newQueryFactory().toSOQL());
    }
    
    
    /**
     * This method used to get list of distinct SubType1__c
     * @params  String productName
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getSubType1ByProductName(String productName){
        return [select SubType1__c  from CSM_QI_Case_Categorization__c where Product__r.Name=:productName group by SubType1__c];
    }
    
    /**
     * This method used to get list of distinct CSHSubType__c
     * @params  String productName
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getCSHSubTypeByProductName(String productName){
        return [select CSHSubType__c  from CSM_QI_Case_Categorization__c where Product__r.Name=:productName and CSH_Visible__c = true group by CSHSubType__c];
    }

    /**
     * This method used to get list of distinct CSHSubType__c for PEP/PRM project
     * @params  String productName
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getPEPSubTypeByProductName(String productName){
        return [select CSHSubType__c  from CSM_QI_Case_Categorization__c where Product__r.Name=:productName and PRM_Visible__c = true group by CSHSubType__c];
    }
    
    /**
     * This method used to get list of distinct CSHSubType__c
     * @params  String productName
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getCSHSubTypeByProductId(String productId){
        return [select CSHSubType__c  from CSM_QI_Case_Categorization__c where Product__c =:productId and CSH_Visible__c = true group by CSHSubType__c];
    }
    
    /**
     * This method used to get list of distinct SubType2__c
     * @params  String productName,
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getSubType2BySubtype1Name(String productName,String subType1Name){
        return [select SubType2__c  from CSM_QI_Case_Categorization__c where Product__r.Name=:productName and SubType1__c =:subType1Name group by SubType2__c];
    }
    
    /**
     * This method used to get list of distinct Products
     * @params  Set<String> productName
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getProducts(Set<String> productName ){
        List<AggregateResult> products = new List<AggregateResult> ();
        if (productName != null) products = [select Product__r.Name  from CSM_QI_Case_Categorization__c where Product__r.Name in :productName   group by Product__r.Name];
        else products = [select Product__r.Name  from CSM_QI_Case_Categorization__c group by Product__r.Name];
        return products;
    }
    
        /**
     * This method used to get list of distinct Products
     * @params  Set<String> productName
     * @params  String recordType
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> getProducts(Set<String> productName,String recordType ){
        List<AggregateResult> products = new List<AggregateResult> ();
        if (productName != null) products = [select Product__r.Name  from CSM_QI_Case_Categorization__c where Type__c = 'Categorization' and SubType1__c = 'Please Specify' and Product__r.Name in :productName and RecordTypeId__c=:recordType  group by Product__r.Name];
        else products = [select Product__r.Name  from CSM_QI_Case_Categorization__c where RecordTypeId__c=:recordType group by Product__r.Name];
        return products;
    }
    
    /**
     * This method used to get CSM_QI_Case_Categorization__c by filter 
     * @params  String condition
     * @return  List<CSM_QI_Case_Categorization__c>
     */
    public List<CSM_QI_Case_Categorization__c> getCaseCategorizationByFilter(string condition) {
        return (List<CSM_QI_Case_Categorization__c>) Database.query(
        /**
          Query factory has been pre-initialised by calling
          getSObjectFieldList(), getOrderBy() for you.
        */
        newQueryFactory().
        /**
          Now focus on building the remainder of the
          query needed for this method.
        */
        setCondition(condition).
        // Finally build the query to execute
        toSOQL());
    }
    
     /**
     * This method used to selectByTopicId
     * @return  List<AggregateResult>
     */
    public List<AggregateResult> selectWithAggregate(string query)
     {
        return (List<AggregateResult>)  Database.query(query);
     }
    
    /**
     * This method used to select Activites for Activity Plan when the templete changed
     * @return  List<AggregateResult>
     */
    public List<CSM_QI_Case_Categorization__c> getCaseListForActivitesbyLosTemp(Set<String> los, Set<String> template){
        String typeC = 'Activity';
        return Database.query('SELECT Id, Activitties__c, LOS__c, Type__c, RnD_Template__c FROM CSM_QI_Case_Categorization__c Where LOS__c In :los and RnD_Template__c In :template and Type__c =:typeC');
    }
    
    public List<CSM_QI_Case_Categorization__c> getCaseCategorizationDetails(String productName, String subType1, String subType2, String subType3, String pillar){
        String query = 'SELECT Product__c, ProductName__c, SubType1__c, SubType2__c, SubType3__c, CaseType__c, Active__c, CSH_Visible__c, CSHSubType__c FROM CSM_QI_Case_Categorization__c WHERE Type__c = \'Categorization\' and pillar__c = \''+pillar+'\' AND Product__r.Name = \''+productName+'\' AND SubType1__c = \''+subType1+'\' AND SubType2__c = \''+subType2;
        if(subType3 != null && subType3 != '--none--'){
            query += '\' AND SubType3__c = \''+subType3+'\'';   
        }else{
            query += '\' AND SubType3__c IN (\''+subType3+'\', \'--none--\')';
        } 
        return (List<CSM_QI_Case_Categorization__c>)Database.query(query);
    }
    
    public List<CSM_QI_Case_Categorization__c> getActiveCaseCategorization(Set<Id> ids){
        String query = 'SELECT Id,Product__c, ProductName__c, LOS__c, SubType1__c, SubType2__c, SubType3__c, CaseType__c, Active__c, CSH_Visible__c, CSHSubType__c FROM CSM_QI_Case_Categorization__c WHERE Type__c = \'Categorization\' and Active__c = true and Id in :ids';
        return (List<CSM_QI_Case_Categorization__c>)Database.query(query);
    }

    public List<CSM_QI_Case_Categorization__c> getCountryofTheRequester2(Set<String> corList, String recordType){
        String query = 'SELECT Id,Active__c,Business_Hours__c,CountryOfRequester__c  FROM CSM_QI_Case_Categorization__c WHERE Type__c = \'CountryReqBusinessHour\' and Active__c = true and CountryOfRequester__c in :corList and RecordTypeId__c = :recordType';
        return (List<CSM_QI_Case_Categorization__c>)Database.query(query);
    }
    
    public List<CSM_QI_Case_Categorization__c> getCaseCategorizationList(Set<String> conSet,Set<String> prodSet,Set<String> sub1Set,Set<String> sub2Set,Set<String> sub3Set, String recordType){
        String query = '';
        if(!conSet.isEmpty() && !prodSet.isEmpty()){
            query = 'SELECT Id,Active__c,Business_Hours__c,CountryOfRequester__c,CaseType__c,ProductName__c,SubType1__c, SubType2__c, SubType3__c  FROM CSM_QI_Case_Categorization__c WHERE (Type__c = \'CountryReqBusinessHour\' and Active__c = true and CountryOfRequester__c in :conSet and RecordTypeId__c = :recordType) OR (ProductName__c in :prodSet and SubType1__c in :sub1Set and SubType2__c in :sub2Set and SubType3__c in :sub3Set)';  
        }else if(!conSet.isEmpty()){
            query = 'SELECT Id,Active__c,Business_Hours__c,CountryOfRequester__c,CaseType__c,ProductName__c,SubType1__c, SubType2__c, SubType3__c  FROM CSM_QI_Case_Categorization__c WHERE Type__c = \'CountryReqBusinessHour\' and Active__c = true and CountryOfRequester__c in :conSet and RecordTypeId__c = :recordType';
        }else if(!prodSet.isEmpty()){
            query = 'SELECT Id,Active__c,Business_Hours__c,CountryOfRequester__c,CaseType__c,ProductName__c,SubType1__c, SubType2__c, SubType3__c  FROM CSM_QI_Case_Categorization__c WHERE ProductName__c in :prodSet and SubType1__c in :sub1Set and SubType2__c in :sub2Set and SubType3__c in :sub3Set';  
        }
            
        return (List<CSM_QI_Case_Categorization__c>)Database.query(query);
    }
    
    public List<CSM_QI_Case_Categorization__c> getProductLevelRestrict(){
        String query = 'SELECT Id,Active__c,Type__c,Product__c  FROM CSM_QI_Case_Categorization__c WHERE Type__c = \'Product Level Restriction\' and Active__c = true';
        return (List<CSM_QI_Case_Categorization__c>)Database.query(query);
    }
}