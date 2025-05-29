public class CNT_PSA_PlannerFilter
{

    public String plannerType {get; set;}
    public String sObj {get; set;}
    public String urlParams {get; set;}
    public String sObjId {get; set;}
    
    public CNT_PSA_PlannerFilter()
    {
        //Retrieve relevant URL Params that may have been passed from calling code (in this case, we're just expecting plannerType, sObject, and sObjId - should extend to be more generic)
        plannerType = ApexPages.currentPage().getParameters().get('plannerType');
        sObj = ApexPages.currentPage().getParameters().get('sObj');
        sObjId = ApexPages.currentPage().getParameters().get('sObjId');
    }
        
    //Called via Page Action Method since DML not allowed in page constructor
    public PageReference redirectUserToPlanner()
    {
        List<Id> filtersToReactivate = new List<Id>();
        pse__Filter_Set__c userFilterSets = new pse__Filter_Set__c();
        
        //Delete the user's existing filter set(s)
        try{
        userFilterSets = [SELECT Id, Name FROM pse__Filter_Set__c WHERE pse__Feature__c = 'Resource Planner' AND OwnerId = :UserInfo.getUserId() LIMIT 1];
        List<pse__Filter__c> userFilters = [SELECT Id, Name, pse__Filter_Set__c, pse__Field__c, pse__Is_Active__c, 	CreatedById,pse__Filter_Set_SObject__c,
                                            pse__Value__c, pse__Operator__c FROM pse__Filter__c WHERE pse__Filter_Set__c =:userFilterSets.id];
        } catch(System.QueryException e){
            userFilterSets.Name = UserInfo.getUserName() + ' Suggested Resource Filter';
            userFilterSets.pse__Feature__c = plannerType == 'project' ? 'Project Planner' : 'Resource Planner';
            userFilterSets.pse__SObject__c = 'Contact';
            insert userFilterSets; 
        }
        
        // get suggested resources related to resource request
        List<Suggested_Resources__c> srList = [SELECT id,name,Total_match_percentage__c FROM Suggested_Resources__c WHERE Resource_Request__c=:sObjId];
        Map<String, Decimal> nameToSR = new Map<String, Decimal>();
        
        // create suggested resources values for filter
        List<String> srValues = new List<String>();
        for(Suggested_Resources__c sr : srList){
            srValues.add(JSON.serialize(sr.Name));
            nameToSR.put(sr.Name, sr.Total_match_percentage__c);
        }
        String values = String.join(srValues, ',');
        
        // set match percentage on contacts
        List<Contact> srContacts = [SELECT id, name, Match_Percentage__c FROM Contact WHERE name IN :nameToSR.keySet()];
        List<Contact> updateContacts = new List<Contact>();
        for(Contact c : srContacts){
            c.Match_Percentage__c = nameToSR.get(c.Name);
            updateContacts.add(c);
        }
        update updateContacts;
        
        //Create Suggested Resource Filter Record
        pse__Filter__c newFilter = new pse__Filter__c();
        newFilter.pse__Filter_Set__c = userFilterSets.Id;
        newFilter.pse__Field__c = 'Name';
        newFilter.pse__Is_Active__c = true;
        newFilter.pse__Operator__c = 'equals';
        newFilter.pse__Value__c = '{"position":0,"containerId":"filterColumn1","includeSublevels":false,"value":['+values+']}';
        insert newFilter;
        
        //Create filter string for final page reference, redirect user
        urlParams = '?isProjectPlanner=false';
        PageReference plannerRef = new PageReference('/apex/pse__PlannerScheduler'+urlParams);
        
        // schedule batches to re-add old filter sets/filters and delete new ones
        System.scheduleBatch(new BCH_OWF_FilterReversal(newFilter.id, nameToSR.keySet()), 'Re-adding Filters', 1);
        

        return plannerRef;
    }

}