/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunitySplitType
 */
public class SLT_OpportunitySplitType extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OpportunitySplitType() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{OpportunitySplitType.Id};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunitySplitType.sObjectType;
    }
    
    /**
     * This method used to get OpportunitySplitType by it's Name
     * @return List<OpportunitySplitType>
     */
    public List<OpportunitySplitType> selectByOppSplitTypeName(String oppSplitTypeName) {
        return (List<OpportunitySplitType>)Database.query(newQueryFactory(true).setCondition('DeveloperName = :oppSplitTypeName').toSOQL());
    }
}