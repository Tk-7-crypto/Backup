/*
 * Author		: 
 * Purpose		: Trigger Handler for the Revenue_Analyst__c SObject. This class extends the VTrigger Virtual Class to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class DAO_Revenue_Analyst extends fflib_SObjectDomain {
    DAOH_Revenue_Analyst raHelper = new DAOH_Revenue_Analyst();
    
	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Revenue_Analyst(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Revenue_Analyst(sObjectList); 
        }
    }

	/**
	 * beforeInsert
	 *
	 * This method is called iteratively for each record to be inserted during a BEFORE
	 * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
	 */
	public override void onBeforeInsert() {
        raHelper.syncRevenueAnalystWithSBSQueue();
	}

    
	/**
	 * beforeUpdate
	 *
	 * This method is called iteratively for each record to be updated during a BEFORE
	 * trigger.
	 */    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        raHelper.syncRevenueAnalystWithSBSQueue();
    }
    
}