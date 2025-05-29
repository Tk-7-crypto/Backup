/**
* Author : Ronak Mehta
* Created Date : 02-09-2024
* This is OpportunitySplit trigger handler class.
*/
public class DAO_OpportunitySplit extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<OpportunitySplit>
     */
    public DAO_OpportunitySplit(List<OpportunitySplit> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_OpportunitySplit(sObjectList);
        }
    }
    
    /**
     * Override method Before Insert Call
     */
    public override void onBeforeInsert(){
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_OpportunitySplit.validateOppSplit((List<OpportunitySplit>)Records);
        }
    }
}