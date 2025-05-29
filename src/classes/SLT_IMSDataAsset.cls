/*
 * Version       : 1.0
 * Description   : Selector Class for IMS_Data_Asset__c
 */
public class SLT_IMSDataAsset extends fflib_SObjectSelector {    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IMS_Data_Asset__c.Id,
            IMS_Data_Asset__c.Name,
            IMS_Data_Asset__c.Asset_Name__c,
            IMS_Data_Asset__c.BU__c,
            IMS_Data_Asset__c.Geo_Level__c,
            IMS_Data_Asset__c.Is_Active__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return IMS_Data_Asset__c.sObjectType;
    }

    /**
     * This method used to get all active IMS_Data_Asset__c records
     * @return  List<IMS_Data_Asset__c>
     */
    public List<IMS_Data_Asset__c> selectAllIMSDataAssetWithSec(Set<String> fieldSet, String orderBy, String sortOrder) {
        fflib_QueryFactory imsDataAssetFactory = newQueryFactory(true).selectFields(fieldSet);
        
        fflib_QueryFactory imsSecDataAssetFactory = SLT_IMSSecondaryDataAsset.instance.addQueryFactorySubselect(imsDataAssetFactory, 'IMS_Secondary_Data_Assets__r');
        imsSecDataAssetFactory.setCondition('Is_Active__c = true');
        imsSecDataAssetFactory.addOrdering('Secondary_Asset_Name__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        fflib_QueryFactory.SortOrder sortingOrder = (sortOrder == 'asc') ? fflib_QueryFactory.SortOrder.ASCENDING : fflib_QueryFactory.SortOrder.DESCENDING;
        return (List<IMS_Data_Asset__c>) Database.query(imsDataAssetFactory
                                                        .setCondition('Is_Active__c = true')
                                                        .addOrdering(orderBy, sortingOrder)
                                                        .toSOQL());
    }

    public static SLT_IMSDataAsset instance {
        get {
            if(instance == null) {
                instance = new SLT_IMSDataAsset();
            }
            return instance;
        }
        set;
    }
}