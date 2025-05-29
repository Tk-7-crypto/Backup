/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Asset
 */
public class SLT_Asset extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Asset.Id,
            Asset.Product2Id,
            Asset.Name,
            Asset.Status
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Asset.sObjectType;
    }
    
    /**
     * This method used to get Asset by Id
     * @return  List<Asset>
     */
    public List<Asset> selectById(Set<ID> idSet) {
        return (List<Asset>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Asset by AccountId and Product2 ID
     * @return  List<Asset>
     */
    public List<Asset> selectByAccountIdAndProductId(Set<ID> AccountIdSet,Set<ID> Product2IdSet) {
         return Database.query('SELECT Id, Name, accountId, Product2Id, Status FROM Asset WHERE accountId=:AccountIdSet AND Product2Id=:Product2IdSet');
    }
    /**
     * This method used to get Asset by Id
     * @return  Map<Id, Asset>
     */
    public Map<Id, Asset> selectByAssetId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Asset>((List<Asset>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
     /**
     * This method used to get Asset by filter condition.
     * @params  Set<String> assetFields
     * @params  String filterCondition
     * @return  List<Asset>
     */
    public List<Asset> getAssetsWithFilter(Set<String> assetFields, String filterCondition) {
        fflib_QueryFactory productQueryFactory = newQueryFactory(true);
        String queryString = productQueryFactory.selectFields(assetFields).setCondition(filterCondition).toSOQL();
        return ((List<Asset>) Database.query(queryString));
    }
    
    /**
     * This method used to get Asset by accountId
     * @return  List<Product2>
     */
	public List<Asset> selectByAccountId(Set<ID> AccountIdSet) {
		return (List<Asset>) Database.query('SELECT Id,Product2.Id, Product2.Name, Product2.Community_Topics__c FROM Asset WHERE AccountId=:AccountIdSet');
        
	}
    
    /**
     * This method used to get Asset by accountId Data Case
     * @return  List<Product2>
     */
	public List<Asset> selectByDataAccountId(Set<Id> accIdSet,String productId) {
		return (List<Asset>) Database.query('SELECT Id,Name FROM Asset WHERE AccountId In :accIdSet and Product2Id =:productId');
        
	}

    public List<Asset> selectCSHByAccounts(Set<Id> accIds,List<string> assets) {
		return (List<Asset>) Database.query('SELECT Id,Name,AccountId FROM Asset WHERE AccountId In :accIds and Name in :assets and Visible_in_CSH__c = true and Status !=\'Obsolete\' order by AccountId');  
	}

    public List<Asset> selectByAccountIdAndProductName(Id AccountId, String Product2Name) {
        return Database.query('SELECT Id, Name, AccountId, Product2Id, Status FROM Asset WHERE accountId = :AccountId AND Product2.Name =: Product2Name');
    }

    public List<Asset> selectByAccountIdAndProductNameList(Set<Id> accountIds, Set<String> productNames) {
        return Database.query('SELECT Id, Name, AccountId, Product2Id, Product2.Name FROM Asset WHERE AccountId in :accountIds AND Product2.Name in :productNames');
    }
    
    public List<Asset> selectAssetByProductId(Set<Id> prodId) {
        return Database.query('SELECT Id, Product2Id,Name,AccountId FROM Asset WHERE Product2ID IN :prodId AND Status !=\'Obsolete\'');
    }
}
