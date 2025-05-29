trigger MIBNF_Update_Components on MIBNF2__c (before update , before insert)
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c && Trigger.isBefore && trigger.isUpdate) {
        if (!Global_Variables.MIBNF_Component_Update_In_Progress)
        {
            Global_Variables.MIBNF_Component_Update_In_Progress = true;
            
            set<id> MIBNFset = new set<id>();
            for (MIBNF2__c MIBNF:trigger.New)
            {
                if(MIBNF.Renewal__c!= trigger.oldMap.get(MIBNF.id).Renewal__c)
                    MIBNFset.add(MIBNF.id);
            }
            
            List<MIBNF_Component__c> MIBNF_Comp_Array = [select Id,MIBNF__c,IMS_Sales_Org__c from MIBNF_Component__c where MIBNF__c in :MIBNFset];
            Map<Id,List<MIBNF_Component__c>> MIBNF_Comp_Map_List = new Map<Id,List<MIBNF_Component__c>>();
            for (MIBNF_Component__c MIBNF_Comp:MIBNF_Comp_Array)
            {
                if (MIBNF_Comp_Map_List.containsKey(MIBNF_Comp.MIBNF__c))
                {
                    MIBNF_Comp_Map_List.get(MIBNF_Comp.MIBNF__c).add(MIBNF_Comp);
                }
                else
                {
                    MIBNF_Comp_Map_List.put(MIBNF_Comp.MIBNF__c,new MIBNF_Component__c[]{MIBNF_Comp});        
                }
            }
            List<MIBNF_Component__c> MIBNF_Comp_Update_List = new List<MIBNF_Component__c>();
            if (MIBNF_Comp_Map_List.size() > 0)
            {
                for (MIBNF2__c MIBNF:trigger.New)
                {
                    for (MIBNF_Component__c MIBNF_Comp:MIBNF_Comp_Map_List.get(MIBNF.Id))
                    {
                        MIBNF_Comp.Renewal__c = MIBNF.Renewal__c;
                        MIBNF_Comp_Update_List.add(MIBNF_Comp);
                    }
                }
            }
            if (MIBNF_Comp_Update_List.size() > 0)
            {
                update MIBNF_Comp_Update_List;
            }
            Global_Variables.MIBNF_Component_Update_In_Progress = false;
        }
    }
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {

        Set<Id> idSet = new Set<Id>();
        
        for(MIBNF2__c mibnf : Trigger.new) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                idSet.add(mibnf.Id);
            }
        }
        
        if(idSet.size() > 0) {
            Set<String> mibnfFieldSet = new Set<String>{'Id', 'BNF_Status__c'};
            Set<String> mibnfCompFieldSet = new Set<String>{'Id', 'BNF_Status__c'};
            List<MIBNF2__c> mibnfList = new SLT_MIBNF().selectMibnfByMibnfId(idSet, mibnfFieldSet, mibnfCompFieldSet);
            
            Map<Id, String> idToMibnfMap = new Map<Id, String>();
            for(MIBNF2__c mibnf: mibnfList) {
                for(MIBNF_Component__c mibnfComp: mibnf.MIBNF_Components__r) {
                    if(!idToMibnfMap.containsKey(mibnf.Id)) {
                        idToMibnfMap.put(mibnf.Id, mibnfComp.BNF_Status__c);
                    } 
                    else {
                        if(idToMibnfMap.get(mibnf.Id) != mibnfComp.BNF_Status__c) {
                            idToMibnfMap.put(mibnf.Id, 'In Progress');
                        }
                    }
                }
            }
            
            for(MIBNF2__c mibnf : Trigger.new) {
                if(idToMibnfMap.containsKey(mibnf.Id)) {
                    mibnf.BNF_Status__c = idToMibnfMap.get(mibnf.Id);
                }
            }
        }
    }
}