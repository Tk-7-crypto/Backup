/* * version : 1.0
 * batch to populate Number_of_Unique_Offering_Types__c field value on opportunity based on offering group count
 * Need to rerun when product hierarchy changed.
*/
global class BCH_CRMINT_Avg_Offering_Group implements Database.Batchable<Sobject>{
    
    /*
	* Fetching all opportunities 
	*/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id from Opportunity');
    }  
    
    /*  Fetching Distinct count from OLIs per oportunity and updating Number_of_Unique_Offering_Types__c field
     *  The batch job executes and operates on one batch of records
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        List<Opportunity> oppList = (List<Opportunity>)scope;
        AggregateResult[] groupedResults = [SELECT COUNT_DISTINCT(Offering_Type__c) groupCount, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN : oppList  GROUP BY OpportunityId ];
        System.debug(groupedResults);
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for (AggregateResult ar : groupedResults)  {
            Opportunity opp = new Opportunity();
            opp.Id = (Id)ar.get('OpportunityId');
            opp.Number_of_Unique_Offering_Types__c = (Decimal)ar.get('groupCount');
            oppListToUpdate.add(opp);
        }
        UTL_ExecutionControl.stopTriggerExecution = true;
        Database.update(oppListToUpdate, false);
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){ 
    }
}