/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Product
 */
public class SLT_FavoriteProduct extends fflib_SObjectSelector {
	/**
     * constructor
     */    
    public SLT_FavoriteProduct() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Favorite_Product__c.User__c,
            Favorite_Product__c.Product__c,
            Favorite_Product__c.User_Comment__c,
            Favorite_Product__c.Category__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Favorite_Product__c.sObjectType;
    }
    
    public List<Favorite_Product__c> getUserFavoriteProducts() {
        String condition = CON_CRM.USER_FIELD + CON_CRM.SINGLE_SPACE + CON_CRM.EQUAL_LOGIC + CON_CRM.SINGLE_SPACE + CON_CRM.BACKSLASH + UserInfo.getUserId() + CON_CRM.BACKSLASH;
        String queryString = newQueryFactory().setCondition(condition).toSOQL();
        return (List<Favorite_Product__c>) Database.query(queryString);
    }
   
    /**
     * This method used to get Favorite Products by IdSet
     * @return  Map<Id, Favorite_Product>
     */
    public List<Favorite_Product__c> selectByProductId(Set<ID> ProductIdSet) {
        return [SELECT Id, User__c, Product__c, User_Comment__c,Category__c FROM Favorite_Product__c WHERE Product__c in : ProductIdSet AND User__c =: UserInfo.getUserId() ORDER BY LastModifiedDate desc LIMIT 200];
    }
    
    /**
	 * This method used to get Favorite Products by IdSet
	 * @return  Map<Id, Favorite_Product>
	 */
    public List<Favorite_Product__c> selectByProduct2Id(Id ProductId) {
        return [SELECT Id, User__c, Product__c, User_Comment__c,Category__c FROM Favorite_Product__c WHERE Product__c =: ProductId AND User__c =: UserInfo.getUserId()];
    }
}