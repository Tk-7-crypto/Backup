trigger populateSoldToFields on MIBNF_Component__c (before update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Map<MIBNF_Component__c, ID> componentToAddressIdMap = new Map<MIBNF_Component__c, ID>(); 
        
        for(MIBNF_Component__c component : Trigger.new) {
            if(component.Sold_To__c != trigger.oldMap.get(component.Id).Sold_To__c) {
                componentToAddressIdMap.put(component, component.Sold_To__c);
            }
        }
        
        if(componentToAddressIdMap.size() > 0 ) {
            Map<Id, Address__c> IdToAddressMap = new Map<ID, Address__c>([Select id, International_Name__c, SAP_Reference__c from Address__c where id IN: componentToAddressIdMap.values()]);
            for(MIBNF_Component__c component : Trigger.new) {
                if(IdToAddressMap.containsKey(component.Sold_To__c)) {
                    component.Sold_To_Local__c = IdToAddressMap.get(component.Sold_To__c).International_Name__c;
                    component.Sold_To_SAP_Base_Code__c = IdToAddressMap.get(component.Sold_To__c).SAP_Reference__c;
                } else {
                    component.Sold_To_Local__c = null;
                    component.Sold_To_SAP_Base_Code__c = null;
                }
            }       
        }
    }
}