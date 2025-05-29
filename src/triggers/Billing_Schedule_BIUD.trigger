/****************************************************************************************
Name            : Billing_Schedule_BIUD
Author          : Himanshu (Metacube)
Created Date    : Sep 1, 2014
Revision History: 
                : 
Usage           : This trigger is used to prevent Billing Schedule update if related BNF 
                : is in Approval Process
                :  
****************************************************************************************/
trigger Billing_Schedule_BIUD on Billing_Schedule__c (after insert,before update) {

    set<string> BNFStatus= new Set<String>{MDM_Defines.BnfStatus_Map.get('SUBMITTED'),
    MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED'),
    MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING'),MDM_Defines.BnfStatus_Map.get('SAP_PENDING'),
    MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')};
    set<id> BNFIds= new set<id>();
    set<id> OLIIds=new set<id>();
    for(Billing_Schedule__c bs : Trigger.new)
    {
       OLIIds.add(bs.OLIId__c);
    }
    
    if(Trigger.isinsert)
    {
        Map<id,Opportunitylineitem> OLIMap=new Map<id,Opportunitylineitem>([select id,Billing_Schedule__c,PricebookEntry.Product2.Material_Type__c from Opportunitylineitem where id in : OLIIds]);
        for(Billing_Schedule__c bs : Trigger.new)
        {
            if(OLIMap.containskey(bs.OLIId__c))
            {
                 OpportunityLineitem oli = OLIMap.get(bs.OLIId__c);
                 oli.Billing_schedule__c=bs.id;
                 OLIMap.put(bs.OLIId__c,oli);
            }
        }
        
        if(OLIMap.size()>0)
        {
            update OLIMap.values();
        }
    }
    
    /*if(Trigger.isupdate)
    {
        Map<Id,ProcessInstanceWorkitem> ProcessInstanceWorkitem_Map = new Map<Id,ProcessInstanceWorkitem>();
        List<ProcessInstanceWorkitem> workItemList = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId,
                                                  ProcessInstance.CreatedById, ActorId 
                                                  from ProcessInstanceWorkitem  where 
                                                  ProcessInstance.Status like 'Pending' and 
                                                  ProcessInstance.TargetObjectId in :Trigger.newMap.keySet()];
        for (ProcessInstanceWorkitem  P: workItemList )
        {
            ProcessInstanceWorkitem_Map.put(P.ProcessInstance.TargetObjectId,P);
        }
                                                  
        Map<id,BNF__c> BNFMap=new Map<id,BNF__c>([select id,BNF_Status__c from BNF__c where id in : BNFIds]);
        User CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        
        //Add Error to Billing Schedule if BNF is in Process
        for(Billing_Schedule__c bs : Trigger.new)
        {
           if(BNFMap.containskey(bs.BnfId__c) && BNFStatus.contains(BNFMap.get(bs.BnfId__c).BNF_Status__c) &&
           OLIMap.containskey(bs.OLIId__c) && OLIMap.get(bs.OLIId__c).PricebookEntry.Product2.Material_Type__c=='ZREP' &&
           !Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',CurrentUser.Profile.Name.toLowerCase()) &&
           (ProcessInstanceWorkitem_Map.containskey(bs.BnfId__c) && ProcessInstanceWorkitem_Map.get(bs.BnfId__c).ActorId!=userInfo.getUserId())
           )
           {
               bs.addError('Billing Schedule can\'t be updated because related BNF is locked for Approval.');
           }
        }
    
    
    }*/

    
}