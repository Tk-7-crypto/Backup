/**
 * This is Proxy_Project__c trigger handler class.
 * version : 1.0
 */
public class DAOH_ProxyProject {
    
    /**
     * This method is used to set the QI OLI Id field  on the Proxy object records
     * @params  newList List<Proxy_Project__c>
     * @params  oldMap Map<Id, Proxy_Project__c>
     * @return  void
     */
    public static void setQIOLIId(List<Proxy_Project__c> newList, Map<Id, Proxy_Project__c> oldMap) {
        Map<Id,Proxy_Project__c> liIdWithProxyProjMap = new Map<Id,Proxy_Project__c>();
        for(Proxy_Project__c proj : newList) {
            if(proj.LI_OpportunityLineItem_Id__c != null && (Trigger.isInsert || (Trigger.isUpdate && proj.LI_OpportunityLineItem_Id__c != oldMap.get(proj.id).LI_OpportunityLineItem_Id__c))) {
                liIdWithProxyProjMap.put(proj.LI_OpportunityLineItem_Id__c, proj);
            }
        }        
        if(liIdWithProxyProjMap.size() > 0) {
            Set<Id> idSet = new Set<Id>();
            idSet.addAll(liIdWithProxyProjMap.keySet());
            Set<String> fieldSet = new Set<String>{'Id', 'LI_OpportunityLineItem_Id__c'};
            Set<String> fieldSetForZQUI = new Set<String>{'Id', 'LI_OpportunityLineItem_Id__c','QI_OpportunityLineItem_Id__c'};
            Map<Id, OpportunityLineItem> oliMap = new SLT_OpportunityLineItems().selectByLIOLIId(idSet, fieldSet);
            Map<Id, OpportunityLineItem> liOLIIDToOLIMap = new Map<Id, OpportunityLineItem>();
            for(OpportunityLineItem oli : oliMap.values()) {
                liOLIIDToOLIMap.put(oli.LI_OpportunityLineItem_Id__c, oli);
            }
            Map<Id, IQVIA_LI_ZQUI_MAPPING__c> zquiMappingMap = new SLT_IQVIA_LI_ZQUI_MAPPING().zquiMappingByLiOLIId(idSet,fieldSetForZQUI,' Action_type__c = \'Upsert\' AND ');
            Map<Id, IQVIA_LI_ZQUI_MAPPING__c > qiOLIIdToZQUIMappingMap = new Map<Id,IQVIA_LI_ZQUI_MAPPING__c >();
            for(IQVIA_LI_ZQUI_MAPPING__c zquiMapping : zquiMappingMap.values()) {
                qiOLIIdToZQUIMappingMap.put(zquiMapping.LI_OpportunityLineItem_Id__c, zquiMapping);
            }
            for(Proxy_Project__c proj : liIdWithProxyProjMap.values()) {
                if(liOLIIDToOLIMap.containsKey(proj.LI_OpportunityLineItem_Id__c)) {
                    proj.QI_OpportunityLineItem_Id__c = liOLIIDToOLIMap.get(proj.LI_OpportunityLineItem_Id__c).Id;
                } else if(qiOLIIdToZQUIMappingMap.containsKey(proj.LI_OpportunityLineItem_Id__c)) {
                    proj.QI_OpportunityLineItem_Id__c = qiOLIIdToZQUIMappingMap.get(proj.LI_OpportunityLineItem_Id__c).QI_OpportunityLineItem_Id__c;
                }
            }
        }
    }
    /**
     * This method is used to set the set OLI Date field on the OLI object records
     * @params  newList List<Proxy_Project__c>
     * @params  oldMap Map<Id, Proxy_Project__c>
     * @return  void
     */
    public static void setOLIDates(List<Proxy_Project__c> newList, Map<Id, Proxy_Project__c> oldMap) {
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        for(Proxy_Project__c proxyProject : newList){
            if(Trigger.isUpdate && !(String.isBlank(proxyProject.QI_OpportunityLineItem_Id__c)) && (proxyProject.Project_Start_Date__c != oldMap.get(proxyProject.Id).Project_Start_Date__c || proxyProject.Project_End_Date__c != oldMap.get(proxyProject.Id).Project_End_Date__c)){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = proxyProject.QI_OpportunityLineItem_Id__c;
                oli.Project_Start_Date__c = proxyProject.Project_Start_Date__c;
                oli.Project_End_Date__c = proxyProject.Project_End_Date__c;
                oliToUpdate.add(oli);
            }
        }
        if(oliToUpdate.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution = true;
            update oliToUpdate;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }	
	
    /**
     * This method is used to set the Master Project field  on the Proxy object records
     * @params  newList List<Proxy_Project__c>
     * @params  oldMap Map<Id, Proxy_Project__c>
     * @return  void
     */
    public static void updateProjectFieldsFromContact(List<Proxy_Project__c> listProxyProject) {
        Set<Id> setOfMasterProjectId = new Set<Id>();
        for(Proxy_Project__c project : listProxyProject) {
            if(String.isEmpty(project.Master_Project__c) && !String.isEmpty(project.Li_Master_Project_Id__c))
                setOfMasterProjectId.add(project.Li_Master_Project_Id__c);
        }
        List<Proxy_Project__c> listOfMasterProject = new SLT_Proxy_Project().selectByLIRecordId(setOfMasterProjectId, new Set<String>{'Id', 'LI_Record_Id__c'});
       
        Map<String, Proxy_Project__c> mapOfProjectAndId = new Map<String, Proxy_Project__c>();
        for(Proxy_Project__c project : listOfMasterProject) {
            mapOfProjectAndId.put(project.LI_Record_Id__c, project);
        }
        
        for(Proxy_Project__c project : listProxyProject) {
            if(mapOfProjectAndId.containsKey(project.Li_Master_Project_Id__c)) 
            	project.Master_Project__c = mapOfProjectAndId.get(project.Li_Master_Project_Id__c).Id;
        }
    }
    
    /**
     * This method is used to update Survey PIC on latest Client_Sat_Survey__c object
     * @params  List<Proxy_Project__c> newList
     * @params  Map<Id, Proxy_Project__c> oldMap
     * @return  void
     */
    public static void updateSurveyPIC(List<Proxy_Project__c> newList, Map<Id, Proxy_Project__c> oldMap){
        List<Update_Survey_Event__e> updateSurveyEventList_e = new List<Update_Survey_Event__e>();
        Update_Survey_Event__e updateSurveyEvent = null;
        
        for(Proxy_Project__c proxyProject : newList) {
            if(proxyProject.Record_Type_Name__c == 'Engagement' && (proxyProject.Delivery_PIC_Name__c != oldMap.get(proxyProject.id).Delivery_PIC_Name__c ||
                proxyProject.Delivery_PIC_Email__c != oldMap.get(proxyProject.id).Delivery_PIC_Email__c ||
                proxyProject.Delivery_PIC_EmployeeNumber__c != oldMap.get(proxyProject.id).Delivery_PIC_EmployeeNumber__c ||
                proxyProject.Delivery_PIC_User_Country__c != oldMap.get(proxyProject.id).Delivery_PIC_User_Country__c )){
                if(proxyProject.Opportunity__c != null){
                    updateSurveyEvent = new Update_Survey_Event__e(Related_record_ID__c = proxyProject.Id, Opportunity_ID__c = proxyProject.Opportunity__c, Is_Insert__c = Trigger.isInsert);
                    updateSurveyEventList_e.add(updateSurveyEvent);
                }
            }
        }
        if(updateSurveyEventList_e.size()>0){
            List<Database.SaveResult> results = EventBus.publish(updateSurveyEventList_e);
            system.debug(results);
        }
    }
}