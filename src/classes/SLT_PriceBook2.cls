/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityLineItems
 */
public class SLT_PriceBook2 extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_PriceBook2() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Pricebook2.sObjectType;
    }
    
    /**
     * This method used to get Standard Pricebook2
     * @return  List<Pricebook2>
     */
    public List<Pricebook2> getStandardPriceBook(Set<String> fieldSet) {
        return (List<Pricebook2>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('IsStandard = True').toSOQL());
    }

}