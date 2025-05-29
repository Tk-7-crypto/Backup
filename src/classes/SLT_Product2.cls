/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Product
 */
public class SLT_Product2 extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
			Product2.Id,
			Product2.Name,
			Product2.Community_Topics__c,
                       Product2.Material_Type__c,
                       Product2.ZQUI_Product__c,
                       Product2.ProductCode,
                       Product2.Community_Description__c,
                       Product2.SAP_Code__c

		};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Product2.sObjectType;
    }
    
	/**
     * This method used to get Product2 by Id
     * @return  List<Product2>
     */
	public List<Product2> selectById(Set<ID> idSet) {
		return (List<Product2>) selectSObjectsById(idSet);
	}
	
	/**
     * This method used to get Product2 by accountId
     * @return  List<Product2>
     */
	public List<Product2> selectByAccountId(Set<ID> AccountIdSet) {
        return [SELECT Id, Name, Community_Topic__r.Name FROM Product2 WHERE Id in(SELECT Product2Id FROM asset WHERE AccountId=:AccountIdSet)];
    }
	
    /**
     * This method used to get product by filter condition.
     * @params  Set<String> productFields
     * @params  String filterCondition
     * @return  List<Product2>
     */
    public List<Product2> getProductWithFilter(Set<String> productFields, String filterCondition) {
        fflib_QueryFactory productQueryFactory = newQueryFactory(true);
        String queryString = productQueryFactory.selectFields(productFields).setCondition(filterCondition).toSOQL();
        return ((List<Product2>) Database.query(queryString));
    }
    
    public List<AggregateResult> getAllFieldValues(String fieldApiName){
        String q = 'SELECT COUNT(Id), '+fieldApiName+' FROM Product2 WHERE '+fieldApiName+' != null and IsActive =true GROUP BY '+fieldApiName;
        return Database.query(q);
    }
    
    /**
     * This Method is used to Get Products by ProductCode
     * @params Set<String> fieldSet
     * @params Set<String> productCodeSet
     * @return List<Product2>
     */
    public List<Product2> getProductsByProductCode(Set<String> fieldSet, Set<String> productCodeSet){
        return (List<Product2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ProductCode in :productCodeSet').toSOQL());
    }
    /**
     * This Method is used to Get Products by ProductName
     * @params Set<String> fieldSet
     * @params Set<String> productNameSet
     * @return List<Product2>
     */
    public List<Product2> getProductsByProductName(Set<String> fieldSet, Set<String> productNameSet) {
        return (List<Product2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name In :productNameSet').toSOQL());
    }

    public List<Product2> getProductsByCondition(Set<String> fieldSet, String condition, Set<String> productCodeSet) {
        return new List<Product2>((List<Product2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
}