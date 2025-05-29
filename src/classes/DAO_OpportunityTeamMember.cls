/**
 * Author : Shubham Jain
 * Created Date : 26-03-2019
 * This is OpportunityTeamMember trigger handler class.
 */ 
public class DAO_OpportunityTeamMember extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<OpportunityTeamMember>
     */
    public DAO_OpportunityTeamMember(List<OpportunityTeamMember> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_OpportunityTeamMember(sObjectList);
        }
    }
    
    /**
     * Override method Before Insert Call
     */
    public override void onBeforeInsert(){
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_OpportunityTeamMember.validateOppTeam((List<OpportunityTeamMember>)Records, null);
        }
    }
    
    /**
     * Override method Before Update Call
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_OpportunityTeamMember.validateOppTeam((List<OpportunityTeamMember>)Records, (Map<Id, OpportunityTeamMember>)existingRecords);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_OpportunityTeamMember.verifyPrivacyAnalyticsProducts((List<OpportunityTeamMember>)Records);
    }
}