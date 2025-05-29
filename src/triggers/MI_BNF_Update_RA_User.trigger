/**************************************************************************************************/
// This Trigger check Update RA User field which is make Revenue Analyst as Related User in Approval Process
// Created by : Himanshu Parashar
// Date : 19 oct 2011
/**************************************************************************************************/
trigger MI_BNF_Update_RA_User on MIBNF2__c (before insert, before update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Map<Id,String> RA_Id_Map = new Map<Id,String>();
        
        for (MIBNF2__c MIBNF : Trigger.new)
        {
            if(trigger.isinsert)
            {
                RA_Id_Map.put(MIBNF.Revenue_Analyst__c,MIBNF.Revenue_Analyst__c);
            }
            
            if(trigger.isupdate && Trigger.oldMap.get(MIBNF.Id).Revenue_Analyst__c !=MIBNF.Revenue_Analyst__c)
                RA_Id_Map.put(MIBNF.Revenue_Analyst__c,MIBNF.Revenue_Analyst__c);
            
        }
        if(RA_ID_Map.size()>0)
        {
            Map<Id,Revenue_Analyst__c> RA_Map = new Map<Id,Revenue_Analyst__c>([select Id,Name,User__c from Revenue_Analyst__c where Id in :RA_Id_Map.keySet()]);
            
            for (MIBNF2__c MIBNF : Trigger.new)
            {
                
                if (RA_Map.containsKey(MIBNF.Revenue_Analyst__c) == true)
                {
                    MIBNF.Revenue_Analyst_del__c = RA_Map.get(MIBNF.Revenue_Analyst__c).User__c;
                }        
                else
                {
                    System.Debug('No user found for BNF');
                }
            }
        }
    }
}