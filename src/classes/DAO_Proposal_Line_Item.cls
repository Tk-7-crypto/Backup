/**
 * This is Proposal line item trigger handler class.
 * 
 */
public class DAO_Proposal_Line_Item extends fflib_SObjectDomain{
	/**
     * Constructor of this class
     * @params sObjectList List<Apttus_Proposal__Proposal_Line_Item__c>
     */
    public DAO_Proposal_Line_Item(List<Apttus_Proposal__Proposal_Line_Item__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Proposal_Line_Item(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_Proposal_Line_Item.setLineItemCurrency((List<Apttus_Proposal__Proposal_Line_Item__c>)Records, null);
        DAOH_Proposal_Line_Item.setPLICountry((List<Apttus_Proposal__Proposal_Line_Item__c>)Records, null);
    }
}