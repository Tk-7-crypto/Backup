/**
 * This is OpportunityLineItem Domain handler class.
 * version : 1.0
 */
public class DAOH_OpportunityLineItem {
    public static Boolean isZeroAmountProduct = false;
    
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<OpportunityLineItem> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<OpportunityLineItem> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Outbound_Message_Deletion_queue__c.SobjectType });
        Boolean toCommit = false;
        Outbound_Message_Deletion_queue__c outBound;
        
        for(OpportunityLineItem oli : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            outBound.LI_Id__c = oli.LI_OpportunityLineItem_Id__c;
            outBound.LQ_Id__c = oli.LQ_OpportunityLineItem_Id__c;
            outBound.SObjectType__c = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
            outBound.RecordID__c = oli.Id;
            outBound.Opportunity__c = oli.OpportunityId;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    
    /**
     * This method is used to set OpportunityLineItemSchedule on OpportunityLineItem.
     * @params  Map<Id, OpportunityLineItem> newMap
     * @params  Map<Id, OpportunityLineItem> oldMap
     * @return  void
     */
    public static void setOLIS(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] { OpportunityLineItemSchedule.SObjectType }
            );
            
            Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
            if (Trigger.isBefore || UTL_ExecutionControl.olisTriggerAlreadyRun == false) {
                //Map<Date, OpportunityLineItemSchedule> dateToOLISMap = new Map<Date, OpportunityLineItemSchedule>();
                if(Trigger.isAfter){
                    newMap = new Map<Id, OpportunityLineItem>([select id, OpportunityLineItemSchedule_JSON__c from OpportunityLineItem where id IN :newMap.keySet() ]);
                }
                Set<String> fieldSet = new Set<String> {'Id', 'OpportunityLineItemId', 'Revenue', 'ScheduleDate', 'Description'};
                Set<Id> idSet = new Set<Id> (newMap.keySet());
                
                List<OpportunityLineItemSchedule> existingOLISList = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(idSet, fieldSet); 
                
                Map<Id, List<OpportunityLineItemSchedule>> oliIdToScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                for(OpportunityLineItemSchedule oliSchedule : existingOLISList){
                    if(oliIdToScheduleMap.containsKey(oliSchedule.OpportunityLineItemId)){
                        oliIdToScheduleMap.get(oliSchedule.OpportunityLineItemId).add(oliSchedule);
                    }
                    else{
                        oliIdToScheduleMap.put(oliSchedule.OpportunityLineItemId, new List<OpportunityLineItemSchedule>{oliSchedule});
                    }
                }
                
                Datetime currentDate = System.now();
                for(Id oliId : newMap.keySet()) {
                    OpportunityLineItem oli = newMap.get(oliId);
                    if(trigger.isBefore && trigger.isUpdate){
                        oli.Gross_Q1_Value__c = 0;
                        oli.Gross_Q2_Value__c = 0;
                        oli.Gross_Q3_Value__c = 0;
                        oli.Gross_Q4_Value__c = 0;
                        oli.Gross_Q1_NY_Value__c = 0;
                        oli.Gross_Q2_NY_Value__c = 0;
                        oli.Gross_Q3_NY_Value__c = 0;
                        oli.Gross_Q4_NY_Value__c = 0; 
                        if(oliIdToScheduleMap.get(oli.Id) != Null){
                            for(OpportunityLineItemSchedule oliSchedule : oliIdToScheduleMap.get(oli.Id)) {
                                if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() <= 3) {
                                    oli.Gross_Q1_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 3 && oliSchedule.ScheduleDate.month() <= 6) {                                  
                                    oli.Gross_Q2_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 6 && oliSchedule.ScheduleDate.month() <= 9) {                                  
                                    oli.Gross_Q3_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 9 && oliSchedule.ScheduleDate.month() <= 12) {                                  
                                    oli.Gross_Q4_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() <= 3) {
                                    oli.Gross_Q1_NY_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 3 && oliSchedule.ScheduleDate.month() <= 6) {                                  
                                    oli.Gross_Q2_NY_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 6 && oliSchedule.ScheduleDate.month() <= 9) {                                  
                                    oli.Gross_Q3_NY_Value__c += oliSchedule.Revenue;
                                }
                                if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 9 && oliSchedule.ScheduleDate.month() <= 12) {                                  
                                    oli.Gross_Q4_NY_Value__c += oliSchedule.Revenue;
                                }
                            }
                        }  
                    }
                    if(mulesoftSetting.Enable_OLIS_JSON__c == true){
                        if ((trigger.isInsert && trigger.isAfter) || (trigger.isUpdate && trigger.isAfter) && mulesoftSetting.Is_Mulesoft_User__c == true){
                            UTL_ExecutionControl.olisTriggerAlreadyRun = true;
                            Boolean isJSONChanged = false;
                            List<OpportunityLineItemSchedule> newOLISList = new List<OpportunityLineItemSchedule>();
                            List<OpportunityLineItemSchedule> oldOLISList = new List<OpportunityLineItemSchedule>();
                            if(!String.ISBLANK(oli.OpportunityLineItemSchedule_JSON__c)){
                                newOLISList = (List<OpportunityLineItemSchedule>)JSON.deserialize(oli.OpportunityLineItemSchedule_JSON__c, List<OpportunityLineItemSchedule>.class);
                            }
                            if(oldMap != null && oldMap.containsKey(oliId) && !String.ISBLANK(oldMap.get(oliId).OpportunityLineItemSchedule_JSON__c)){
                                oldOLISList = (List<OpportunityLineItemSchedule>)JSON.deserialize(oldMap.get(oliId).OpportunityLineItemSchedule_JSON__c, List<OpportunityLineItemSchedule>.class);
                            }
                            Set<String> keySet = new Set<String>();
                            if(newOLISList.size() != oldOLISList.size()){
                                isJSONChanged = true;
                            } else if(newOLISList.size() == 0 && oldOLISList.size() == 0){
                                isJSONChanged = false;
                            } else {
                                for (OpportunityLineItemSchedule olis : newOLISList) {
                                    keySet.add(olis.ScheduleDate + ':' + olis.Revenue + ':' + olis.Description);
                                }
                                for (OpportunityLineItemSchedule olis : oldOLISList) {
                                    if(!keySet.contains(olis.ScheduleDate + ':' + olis.Revenue + ':' + olis.Description)){
                                        isJSONChanged = true;
                                        break;
                                    }
                                }
                            } 
                            if(isJSONChanged){
                                if(oliIdToScheduleMap.containsKey(oliId)){
                                    uow.registerDeleted(oliIdToScheduleMap.get(oliId));
                                }
                                for (OpportunityLineItemSchedule olis : newOLISList) { 
                                    OpportunityLineItemSchedule olisNew = new OpportunityLineItemSchedule();
                                    olisNew.Revenue = olis.Revenue;
                                    olisNew.ScheduleDate = olis.ScheduleDate;
                                    olisNew.Description = olis.Description;
                                    olisNew.OpportunityLineItemId = oliId;
                                    olisNew.Type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
                                    uow.registerNew(olisNew); 
                                }
                            }
                        } else if(trigger.isUpdate && trigger.isBefore && mulesoftSetting.Is_Mulesoft_User__c == false) {
                            List<OpportunityLineItemSchedule> oliList = new List<OpportunityLineItemSchedule>();
                            if(oliIdToScheduleMap.get(oliId) != Null){
                                for(OpportunityLineItemSchedule olis : oliIdToScheduleMap.get(oliId)) {
                                    OpportunityLineItemSchedule olisJSON = new OpportunityLineItemSchedule();
                                    olisJSON.Revenue = olis.Revenue;
                                    olisJSON.ScheduleDate = olis.ScheduleDate;
                                    olisJSON.Description = olis.Description;
                                    oliList.add(olisJSON);
                                }
                            }
                            newMap.get(oliId).OpportunityLineItemSchedule_JSON__c = JSON.serialize(oliList);
                        }   
                    }
                }
                uow.commitWork();
            }
        } catch (Exception ex) {
            throw ex;
        }
    }
    
    /**
     * This method is used to validation weather user or mulesoft can do updates on OpportunityLineItem.
     * @params  newList List<OpportunityLineItem>
     * @params  newMap Map<Id, OpportunityLineItem>
     * @params  oldMap Map<Id, OpportunityLineItem>
     * @return  void
     */    
    public static void setMulesoftSyncField(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        if(!CON_CRM.MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN){
            CON_CRM.MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = true;
            Set<Id> oppIdSet = new Set<Id>();
            for(OpportunityLineItem oli : newList){
                oppIdSet.add(oli.OpportunityId);
            }
            List<Mulesoft_Opportunity_Sync__c> existingMulesoftOppSyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(oppIdSet);
            Map<String, Mulesoft_Opportunity_Sync__c> oppIdToMulesoftOppSyncMap = new Map<String, Mulesoft_Opportunity_Sync__c>();
            for(Mulesoft_Opportunity_Sync__c oppsync : existingMulesoftOppSyncList) {
                oppIdToMulesoftOppSyncMap.put(oppsync.Opportunity__c, oppsync);
            }
            Map<String, Mulesoft_OpportunityLineItem_Sync__c> oppIdToMulesoftOppOLISyncMap = new Map<String, Mulesoft_OpportunityLineItem_Sync__c>();            
            if(Trigger.isUpdate) {
                List<Mulesoft_OpportunityLineItem_Sync__c> existingMulesoftOppOLISyncList = new SLT_MulesoftOpportunityLineItemSync().selectByOLIIds(oldMap.keyset());            
                for(Mulesoft_OpportunityLineItem_Sync__c oppOlisync : existingMulesoftOppOLISyncList) {
                    oppIdToMulesoftOppOLISyncMap.put(oppOlisync.OpportunityLineItemId__c, oppOlisync);
                }
            }
            List<Mulesoft_OpportunityLineItem_Sync__c> mulesoftOppOLISyncList = new List<Mulesoft_OpportunityLineItem_Sync__c>();  
            for(OpportunityLineItem oli : newList) {
                if(oli.Opportunity_Sharing_Business_Unit__c != CON_CRM.LOB_Avacare){
                    if(trigger.isInsert || trigger.isUpdate) {
                        if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE || CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE == CON_CRM.TEMP_UPDATE_TYPE_MULESOFT_SLAVE_OLI) {
                            Mulesoft_OpportunityLineItem_Sync__c mls = new Mulesoft_OpportunityLineItem_Sync__c();
                            mls.Mulesoft_Incoming_Update_GUID__c = oli.Mulesoft_Incoming_Update_GUID__c;
                            mls.Mulesoft_Sync_Status__c = oli.Mulesoft_Sync_Status__c;
                            mls.Mulesoft_Sync_Timestamp__c = oli.Mulesoft_Sync_Timestamp__c;
                            mls.Mulesoft_Error_Message__c = oli.Mulesoft_Error_Message__c;   
                            mls.OpportunityLineItemId__c = oli.id;
                            mls.LI_OpportunityLineItem_Id__c = oli.LI_OpportunityLineItem_Id__c;
                            mls.LQ_OpportunityLineItem_Id__c = oli.LQ_OpportunityLineItem_Id__c;
                            mulesoftOppOLISyncList.add(mls); 
                        } else if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_USER && !Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c) {
                            //oli.Send_Mulesoft_Outbound_Msg__c = false;
                            String fieldAPI = '';
                            Mulesoft_OpportunityLineItem_Sync__c mls = new Mulesoft_OpportunityLineItem_Sync__c();
                            if(!oppIdToMulesoftOppOLISyncMap.containsKey(oli.Id)) {
                                mls.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
                            }
                            for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                                fieldAPI = sf.getFieldPath();
                                if ((trigger.isInsert || !oppIdToMulesoftOppOLISyncMap.containsKey(oli.Id) || (trigger.isUpdate && oli.get(fieldAPI) != oldMap.get(oli.Id).get(fieldAPI))) && Mulesoft_Integration_Control__c.getInstance().Enable_OLI_Sync_Validation__c) {
                                    //oli.Send_Mulesoft_Outbound_Msg__c = true;
                                    mls.Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                                    if ((trigger.isInsert || (trigger.isUpdate && oli.get(fieldAPI) != oldMap.get(oli.Id).get(fieldAPI))) && Mulesoft_Integration_Control__c.getInstance().Enable_OLI_Sync_Validation__c) {
                                        mls.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                    }
                                    mls.Mulesoft_Sync_Timestamp__c = null;
                                    mls.Mulesoft_Error_Message__c = null;   
                                    mls.OpportunityLineItemId__c = oli.id;   
                                    mls.LI_OpportunityLineItem_Id__c = oli.LI_OpportunityLineItem_Id__c;
                                    mls.LQ_OpportunityLineItem_Id__c = oli.LQ_OpportunityLineItem_Id__c;
                                    mulesoftOppOLISyncList.add(mls); 
                                    break;
                                }
                            }   
                        }
                    }
                }
            }
            if(mulesoftOppOLISyncList.size() > 0){
                upsert mulesoftOppOLISyncList OpportunityLineItemId__c;
            }
        }
    }  
    
    /**
     * This method is used to validation weather user or mulesoft can do updates on OpportunityLineItem.
     * @params  newList List<OpportunityLineItem>
     * @params  newMap Map<Id, OpportunityLineItem>
     * @params  oldMap Map<Id, OpportunityLineItem>
     * @return  void
     */
    public static void validateMulesoftFieldUpdates(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        if(Mulesoft_Integration_Control__c.getInstance().Enable_OLI_Sync_Validation__c && CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN == false){
            CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = true;
            Set<Id> oppIdSet = new Set<Id>();
            for(OpportunityLineItem oli : newList){
                oppIdSet.add(oli.OpportunityId);
            }

            List<Mulesoft_Opportunity_Sync__c> existingMulesoftOppSyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(oppIdSet);
            Map<String, Mulesoft_Opportunity_Sync__c> oppIdToMulesoftOppSyncMap = new Map<String, Mulesoft_Opportunity_Sync__c>();
            for(Mulesoft_Opportunity_Sync__c oppsync : existingMulesoftOppSyncList) {
                oppIdToMulesoftOppSyncMap.put(oppsync.Opportunity__c, oppsync);
            }            

            Map<String, Mulesoft_OpportunityLineItem_Sync__c> oppIdToMulesoftOppOLISyncMap = new Map<String, Mulesoft_OpportunityLineItem_Sync__c>();
            if(!Trigger.isInsert){
                List<Mulesoft_OpportunityLineItem_Sync__c> existingMulesoftOppOLISyncList = new SLT_MulesoftOpportunityLineItemSync().selectByOLIIds(oldMap.keyset());
                for(Mulesoft_OpportunityLineItem_Sync__c oppOlisync : existingMulesoftOppOLISyncList) {
                    oppIdToMulesoftOppOLISyncMap.put(oppOlisync.OpportunityLineItemId__c, oppOlisync);
                }
            }
            
            for(OpportunityLineItem oli : newList){
                if(oli.Opportunity_Sharing_Business_Unit__c != CON_CRM.LOB_Avacare){
                    //Updating update type to User when it is blank for old records.
                    if(String.isBlank(oli.Update_Type__c)){
                        oli.Update_Type__c = CON_CRM.UPDATE_TYPE_USER;
                    }
                    if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_FORCE_UPDATE_LI ) {
                        //  allow Mulesoft update to complete i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                        //  and to set the Mulesoft_update_GUID__c from the other org
                    }
                    else if(oli.Hierarchy_Level__c == CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI && oppIdToMulesoftOppSyncMap.containsKey(oli.OpportunityId) && (oppIdToMulesoftOppSyncMap.get(oli.OpportunityId).LQ_Opportunity_Id__c != null || oppIdToMulesoftOppSyncMap.get(oli.OpportunityId).LI_Opportunity_Id__c != null)) {
                        if((trigger.isInsert || !oppIdToMulesoftOppOLISyncMap.containsKey(oli.Id) || (trigger.isUpdate && oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED))) {
                            // TO BE UPDATED && oli.opportunity.LI_Opportunity_Id__c != null && oli.opportunity.LQ_Opportunity_Id__c != null) {
                            //  if update is coming from Mulesoft as result of action in another org
                            if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE) {
                                //  allow Mulesoft update to complete i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                                //  and to set the Mulesoft_update_GUID__c from the other org
                            } else if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                                oli.Send_Mulesoft_Outbound_Msg__c = false;
                                String fieldAPI = '';
                                for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                                    fieldAPI = sf.getFieldPath();
                                    if (trigger.isInsert || (trigger.isUpdate && oldMap.get(oli.Id).get(fieldAPI) != newMap.get(oli.Id).get(fieldAPI))) {
                                        oli.Send_Mulesoft_Outbound_Msg__c = true;
                                        /*oli.Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                                        oli.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                        oli.Mulesoft_Sync_Timestamp__c = null;
                                        oli.Mulesoft_Error_Message__c = null; */            
                                        break;
                                    }
                                }                      
                            } else {
                                oli.addError(Label.CRM_CL0011_UNEXPECTED_UPDATE_TYPE_ERROR);
                            }
                        } else if(oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING) {
                            //  if update is coming from Mulesoft as result of action in another org
                            //  This should only happen if the record in the legacy org is edited within the same time window while
                            //  the Mulesoft sync is in progress, or if Mulesoft goes down
                            if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE) {
                                oli.addError(Label.CRM_CL0010_MULESOFT_SYNC_PENDING_ERROR);
                            } else if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                                //  if the update is coming from the user, check if any of the synced fields are being updated
                                //  if a synced field is being updated, throw an error since Mulesoft_sync is still pending
                                //  else allow the update                      
                                String fieldAPI = '';
                                //  Set oli.Send_Mulesoft_Outbound_Msg__c = false so that if none of synced fields being updated then outbound message won't fire
                                oli.Send_Mulesoft_Outbound_Msg__c = false;                            
                                for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                                    fieldAPI = sf.getFieldPath();
                                    if (trigger.isUpdate && oldMap.get(oli.Id).get(fieldAPI) != newMap.get(oli.Id).get(fieldAPI))
                                            oli.addError(Label.CRM_CL0010_MULESOFT_SYNC_PENDING_ERROR); 
                                }     
                            }                       
                                    
                        } else if(oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED ) {
                            //  If update is from a user in this org
                            if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                                //  if the update is coming from the user, check if any of the synced fields are being updated
                                //  if a synced field is being updated, throw an error since Mulesoft_sync is still pending
                                //  else allow the update                      
                                String fieldAPI = '';
                                //  Set oli.Send_Mulesoft_Outbound_Msg__c = false so that if none of synced fields being updated then outbound message won't fire
                                oli.Send_Mulesoft_Outbound_Msg__c = false; 
                                for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {                           
                                    fieldAPI = sf.getFieldPath();
                                    if (trigger.isUpdate && oldMap.get(oli.Id).get(fieldAPI) != newMap.get(oli.Id).get(fieldAPI))
                                    {
                                        String legacyRecordUrl;
                                        String BaseURL = Account_Setting__c.getOrgDefaults().SFDC_Instance_URL__c;
                                        //  If material type == "ZQUI" then product is legacy Q product and error is in legacy Quintiles org or legacy IMS org
                                        if(oli.Product_Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI) {
                                            legacyRecordUrl = Legacy_Org_Link__c.getInstance().Legacy_Quintiles_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppOLISyncMap.get(oli.id).LQ_OpportunityLineItem_Id__c;
                                            //  Check whether LQ_OpportunityLineItem_Id__c is null to have a different message if the insert on legacy org failed
                                            if (oppIdToMulesoftOppOLISyncMap.get(oli.id).LQ_OpportunityLineItem_Id__c == null)
                                                oli.addError('Insert of record in legacy Quintiles org failed.  The error from the legacy Quintiles org is: "' + oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="' + BaseURL + '/' + oli.Id + '">' + BaseURL + '/' + oli.Id + '</a>',false);
                                            else
                                                oli.addError(Label.CRM_CL0013_RECORD_UPDATE_ERROR_1 + ' "' + oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Error_Message__c + '"  ' + Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyRecordUrl + Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);
                                        } else {
                                            legacyRecordUrl = ' https://' + Legacy_Org_Link__c.getInstance().Legacy_IMS_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppOLISyncMap.get(oli.id).LI_OpportunityLineItem_Id__c;
                                            if (oppIdToMulesoftOppOLISyncMap.get(oli.id).LI_OpportunityLineItem_Id__c == null)
                                                oli.addError('Insert of record in legacy IMS org failed.  The error from the legacy IMS org is: "' + oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="' + BaseURL + '/' + oli.Id + '">' + BaseURL + '/' + oli.Id + '</a>',false);
                                            else
                                                oli.addError(Label.CRM_CL0013_RECORD_UPDATE_ERROR_1 + ' "' + oppIdToMulesoftOppOLISyncMap.get(oli.id).Mulesoft_Error_Message__c + '"  ' + Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyRecordUrl + Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);
                                        }                                                  
                                    }
                                }                               
                            } else if(oli.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE ) {
                                //  if update is coming from Mulesoft as part of the "slave interface" where original action occurred in legacy org
                                //  Allow the update i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                                //  and to set the Mulesoft_update_GUID__c from the other org              
                            } else {
                                oli.addError(Label.CRM_CL0011_UNEXPECTED_UPDATE_TYPE_ERROR);
                            }                      
                        }
                    }
                    CON_CRM.TEMP_UPDATE_TYPE_MULESOFT_SLAVE_OLI = oli.Update_Type__c;
                    //  Reset Update_Type__c so that any updates will have "USER" unless Mulesoft specifically sets this field
                    oli.Update_Type__c = CON_CRM.UPDATE_TYPE_USER;
                }
            }
        }
    }
    
    /**
    * This method is used to validate BNF For opportunity Update.
    * @params  newMap Map<Id, Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void validationForProxyBNFApproval(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            Set<String> fieldSet = new Set<String>{'Id','BNF_Status__c','Opportunity__c' ,'Revenue_Analyst_del__c','Revenue_Analyst_User_2__c','Revenue_Analyst_User_3__c','Revenue_Analyst_User_4__c',
                'Revenue_Analyst_User_5__c','Revenue_Analyst_User_6__c','Revenue_Analyst_User_7__c','Revenue_Analyst_User_8__c','Revenue_Analyst_User_9__c','Revenue_Analyst_User_10__c', 'Record_Type_text__c', 'Opportunity__r.StageName'};
                    Map<id,List<BNF2__c>> BNFMap = new Map<id,List<BNF2__c>>();
            List<BNF2__c> BNFList = new List<BNF2__c>();
            Set<Id> oliIdsSet = new Set<Id>();
            if(Trigger.isExecuting) {
                Set<Id> oppIdSet = new Set<Id>();
                for(OpportunityLineItem oli : newMap.values()) {
                    oppIdSet.add(oli.OpportunityId);   
                    oliIdsSet.add(oli.Id);
                }
                String filterCondition = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet '+ CON_CRM.AND_LOGIC + CON_CRM.RECORD_TYPE_NAME_API + ' IN (\''+ CON_CRM.SAP_SD_INTEGRATED +'\',\''+ CON_CRM.MANUAL_SETUP_IN_SAP + '\') ' + CON_CRM.AND_LOGIC + '(not ' + CON_CRM.BNF_STATUS_API  + ' IN (\'' + CON_CRM.STATUS_NEW +'\',\'' + CON_CRM.REJECTED   +'\',\''+ CON_CRM.RA_REJECTED  +'\',\''+ CON_CRM.SAP_CONTRACT_CONFIRMED  + '\',\''+ CON_CRM.LQ_REJECTEDQ +'\'))';
                //System.debug('BNF : '+ filterCondition);
                BNFList = new SLT_BNF().selectByFilter(oppIdSet, fieldSet, filterCondition);
                if(BNFList.size() > 0){
                    for(BNF2__c BNF : BNFList) {
                        if(!BNFMap.containsKey(BNF.Opportunity__c)) {
                            BNFMap.put(BNF.Opportunity__c, new List<BNF2__c>());
                        }
                        BNFMap.get(BNF.Opportunity__c).add(BNF);
                    }
                    Map<Id, Set<Id>> oppIdToRevenueAnalystUsersSet = new Map<Id, Set<Id>>();
                    for(Id oppId : BNFMap.keySet()) {
                        List<BNF2__c> bnfsList = BNFMap.get(oppId);
                        Set<Id> userIds = new Set<Id>();
                        for(BNF2__c bnfObj : bnfsList) {
                            String count = 'del';
                            Integer countInt = 1;
                            while(countInt < 11) {
                                Object userId = bnfObj.get('Revenue_Analyst_'+ count +'__c');
                                if(userId != null) {
                                    userIds.add((Id)userId);
                                }
                                countInt++;
                                count =  'User_' + String.valueOf(countInt);
                            }
                        }
                        oppIdToRevenueAnalystUsersSet.put(oppId, userIds);
                    }
                    String profileName = UTL_CRM.getCurrentUserProfileName();
                    for(OpportunityLineItem oli : newMap.values()) {
                        if(BNFMap.containsKey(oli.OpportunityId)){
                            //ESPSFDCQI-10495
                            for(BNF2__c bnf : BNFMap.get(oli.OpportunityId)){
                                if(bnf.Record_Type_Text__c == CON_CRM.MANUAL_SETUP_IN_SAP){
                                    if(bnf.Opportunity__r.StageName == CON_CRM.IN_HAND_STAGE && (oli.UnitPrice != oldMap.get(oli.Id).UnitPrice || oli.TotalPrice != oldMap.get(oli.Id).TotalPrice)){
                                        if (!oppIdToRevenueAnalystUsersSet.get(oli.OpportunityId).contains(UserInfo.getUserId()) && !(profileName.contains(CON_CRM.SYS_ADMIN) || profileName.equals(CON_CRM.IQVIA_SF_PLATFORM_PROFILE))){
                                            oli.addError(System.Label.CRM_CL0016_RECORD_UPDATE_ERROR_17);    
                                        }
                                	}
                                }else if (!oppIdToRevenueAnalystUsersSet.get(oli.OpportunityId).contains(UserInfo.getUserId())) {
                                    oli.addError(System.Label.CRM_CL0016_RECORD_UPDATE_ERROR);    
                                } 
                            }
                        }
                    }
                }else{
                    Set<String> fieldSetMibnfLineItem = new Set<String>{'Opportunity_Line_Itemid__c', 'MIBNFComponent_OLI_ID__c', 'MIBNF_Component__c','MIBNF_Component__r.BNF_Status__c', 'Id',
                        CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_10__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_2__c', 
                        CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_3__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_4__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_5__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_6__c', 
                        CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_7__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_8__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user_9__c', CON_CRM.MIBNF_API_R+'Comp_Revenue_Analyst_user__c' };
                    String condition = 'Opportunity_Line_Itemid__c IN :oliIdsSet '+ CON_CRM.AND_LOGIC +  '(not ' + CON_CRM.MIBNF_API_R + CON_CRM.BNF_STATUS_API  + ' IN (\'' + CON_CRM.STATUS_NEW +'\',\'' + CON_CRM.REJECTED   +'\',\''+ CON_CRM.RA_REJECTED  +'\',\''+ CON_CRM.SAP_CONTRACT_CONFIRMED  + '\',\''+ CON_CRM.LQ_REJECTEDQ +'\'))';
                    List<MI_BNF_LineItem__c> mibnfLineItemList = new SLT_MIBNFLineItem().selectByFilter(oliIdsSet, fieldSetMibnfLineItem, condition);
                    Set<Id> oliIDsSetToCmpr = new Set<Id>();
                    Map<Id, Set<Id>> oppIdToRevenueAnalystUsersSet = new Map<Id, Set<Id>>();
                    for(MI_BNF_LineItem__c mibnfLineItem : mibnfLineItemList){
                        oliIDsSetToCmpr.add(mibnfLineItem.Opportunity_Line_Itemid__c);
                        Set<Id> revuserIDsList = new Set<Id>();
                        MIBNF_Component__c mib = mibnfLineItem.MIBNF_Component__r;
                        for(Integer ind = 1; ind<= 10; ind++){
                            if(ind == 1){
                                if(mib.get('Comp_Revenue_Analyst_user__c') != null){
                                    revuserIDsList.add((Id)mib.get('Comp_Revenue_Analyst_user__c'));    
                                }
                            }else{
                                String revAnalystApi =  'Comp_Revenue_Analyst_user_'+ind+'__c';
                                if(mib.get(revAnalystApi) != null){
                                    revuserIDsList.add((Id)mib.get(revAnalystApi));    
                                }
                            }
                        }
                        oppIdToRevenueAnalystUsersSet.put(mibnfLineItem.Opportunity_Line_Itemid__c,revuserIDsList);
                    }
                    for(OpportunityLineItem oli : newMap.values()) {
                        if(oliIDsSetToCmpr.contains(oli.Id) && oppIdToRevenueAnalystUsersSet.get(oli.Id).size() > 0 && !oppIdToRevenueAnalystUsersSet.get(oli.Id).contains(UserInfo.getUserId())) {
                            oli.addError(System.Label.CRM_CL0016_RECORD_UPDATE_ERROR);    
                        }                   
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to calculate quarterly revenue fields on the OLI.
    * @params  newList List<OpportunityLineItem>
    * @return  void
    */
    /*public static void calculateQuarterlyRevenueValues(Map<Id, OpportunityLineItem> newMap ) {
        Set<String> fieldSet = new Set<String> {'Id', 'OpportunityLineItemId', 'Revenue', 'ScheduleDate'};
        Set<Id> idSet = new Set<Id>(newMap.keySet());
        List<OpportunityLineItemSchedule> existingOLISList = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(idSet, fieldSet);
        Map<Id, List<OpportunityLineItemSchedule>> oliIdToScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
        for(OpportunityLineItemSchedule oliSchedule : existingOLISList){
            if(oliIdToScheduleMap.containsKey(oliSchedule.OpportunityLineItemId)){
                oliIdToScheduleMap.get(oliSchedule.OpportunityLineItemId).add(oliSchedule);
            }
            else{
                oliIdToScheduleMap.put(oliSchedule.OpportunityLineItemId, new List<OpportunityLineItemSchedule>{oliSchedule});
            }
        }
        
        Datetime currentDate = System.now();
        for(OpportunityLineItem oli : newMap.values()) {
            oli.Gross_Q1_Value__c = 0;
            oli.Gross_Q2_Value__c = 0;
            oli.Gross_Q3_Value__c = 0;
            oli.Gross_Q4_Value__c = 0;
            oli.Gross_Q1_NY_Value__c = 0;
            oli.Gross_Q2_NY_Value__c = 0;
            oli.Gross_Q3_NY_Value__c = 0;
            oli.Gross_Q4_NY_Value__c = 0; 
            if(oliIdToScheduleMap.get(oli.Id) != Null){
                for(OpportunityLineItemSchedule oliSchedule : oliIdToScheduleMap.get(oli.Id)) {
                    if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() <= 3) {
                        oli.Gross_Q1_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 3 && oliSchedule.ScheduleDate.month() <= 6) {                                  
                        oli.Gross_Q2_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 6 && oliSchedule.ScheduleDate.month() <= 9) {                                  
                        oli.Gross_Q3_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year() && oliSchedule.ScheduleDate.month() > 9 && oliSchedule.ScheduleDate.month() <= 12) {                                  
                        oli.Gross_Q4_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() <= 3) {
                        oli.Gross_Q1_NY_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 3 && oliSchedule.ScheduleDate.month() <= 6) {                                  
                        oli.Gross_Q2_NY_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 6 && oliSchedule.ScheduleDate.month() <= 9) {                                  
                        oli.Gross_Q3_NY_Value__c += oliSchedule.Revenue;
                    }
                    if(oliSchedule.ScheduleDate.year() == currentDate.year()+1 && oliSchedule.ScheduleDate.month() > 9 && oliSchedule.ScheduleDate.month() <= 12) {                                  
                        oli.Gross_Q4_NY_Value__c += oliSchedule.Revenue;
                    }
                }
            }
        } 
    }
*/
    
    /**
    * This method is used to prevent stage change of OpportunityLineItem for Proxy PA.
    * @params  Map<Id, OpportunityLineItem> oldMap
    * @params  List<OpportunityLineItem> oliList
    * @return  void
    */
    public static void validationOnOliForProxyPA(Map<Id, OpportunityLineItem> oldMap, List<OpportunityLineItem> oliList) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if((!CON_CRM.IGNORE_PA_VALIDATION) && (!mulesoftSetting.Ignore_Validation_Rules__c)) {
            //  Get a map of all Proxy_Pricing_Assitant records related to the opp
            Map<Id, Proxy_Pricing_Assistant__c> proxyPaMap = new Map<Id, Proxy_Pricing_Assistant__c>();
            Set<Id> oppIdSet = new Set<id>();
            for(OpportunityLineItem oli : oliList){
                if(trigger.isDelete || trigger.isInsert) {
                    oppIdSet.add(oli.OpportunityId);
                } else if(trigger.isUpdate) {
                    if (oldMap.get(oli.Id).Delivery_Country__c != oli.Delivery_Country__c || oldMap.get(oli.Id).TotalPrice != oli.TotalPrice){
                        oppIdSet.add(oli.OpportunityId);
                    } 
                }
            }
            Set<String> fieldSet = new Set<String>{'Id', 'PA_Status__c', 'LI_Record_Id__c', 'Opportunity__c', 'Opportunity__r.PA_Required__c'};
            List<Proxy_Pricing_Assistant__c> proxyPAList = new SLT_ProxyPricingAssistant().selectByOpportunityIds(oppIdSet, fieldSet);
            for(Proxy_Pricing_Assistant__c ppaRecord : proxyPAList) {
                if(ppaRecord.PA_Status__c == CON_CRM.PA_STATUS_APPROVED || ppaRecord.PA_Status__c == CON_CRM.SUBMITTED) {
                    proxyPaMap.put(ppaRecord.Opportunity__c, ppaRecord);
                }
            }
            for(OpportunityLineItem oli : oliList){
                if(proxyPaMap.containsKey(oli.OpportunityId)) {
                    oli.addError(System.Label.CRM_CL0016_PROXY_PA_ERROR3);
                } 
            }
        }
    }
    
    /**
    * This method is used to reset the trigger execution variables based on the change in new list size.
    * @params  List<OpportunityLineItem> oliList
    * @return  void
    */
    public static void resetTriggerExecutionFlag(List<OpportunityLineItem> oliList) {
        if(CON_CRM.OLI_NEW_LIST_OLD_COUNT != -1) {
            if(CON_CRM.OLI_NEW_LIST_OLD_COUNT == 0) {
                CON_CRM.OLI_NEW_LIST_OLD_COUNT = oliList.size();
            }
            if(CON_CRM.OLI_NEW_LIST_OLD_COUNT != oliList.size()) {
                CON_CRM.MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = false;
                CON_CRM.MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
                CON_CRM.OLI_NEW_LIST_OLD_COUNT = oliList.size();
            }
        }
    }
    
    /**
     * This method is used to prevent deletion of OLI if is associated with any proxy project
     * @params  List<OpportunityLineItem> deleteList
     * @return  void
     */
    public static void validationOnOliForProxyProject(List<OpportunityLineItem> deleteList) {
        Set<Id> idSet = new Set<Id>();
        for(OpportunityLineItem oli : deleteList) {
            idSet.add(oli.id);
        }
        Set<String> fieldSet = new Set<String>{'Id', 'QI_OpportunityLineItem_Id__c'};
        List<Proxy_Project__c> proxyProjectList = new SLT_Proxy_Project().selectByQIOLIId(idSet, fieldSet);
        Set<Id> qiOLIIdSet = new Set<Id>();
        for(Proxy_Project__c proxyProj : proxyProjectList) {
            qiOLIIdSet.add(proxyProj.QI_OpportunityLineItem_Id__c);
        }
        
        for(OpportunityLineItem oli : deleteList) {
            if(qiOLIIdSet.contains(oli.id)) {
                oli.addError(System.Label.CRM_CL0022_OLI_DELETION_ERROR);
            }
        }
    }
    
    /**
    * This method is used to populate Fields on opportunityLineItem.
    * @params  List<OpportunityLineItem> newList
    * @params  List<OpportunityLineItem> oldMap
    * @return  void
    */
    public static void setOliFields(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        Map<Id, Opportunity> oppMap = new map<Id, Opportunity>();
        Map<Id,OpportunityLineItem> oliIdtoOliMap = new Map<Id,OpportunityLineItem>();
        if(Trigger.isInsert){
            Set<Id> oppIdSet = new Set<Id>();
            for(OpportunityLineItem oli : newList) {
                oppIdSet.add(oli.OpportunityId);
            }
            Set<String> oppFieldSet = new Set<String> {'Id', 'StageName'}; 
            oppMap = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
        }
        Set<id> oppIdSet = new Set<Id>();
        CRM_Data_Migration_Activity__c dataMActivity = CRM_Data_Migration_Activity__c.getInstance();
        for(OpportunityLineItem oli : newList) {
            String oldSalesText = Trigger.isUpdate ? oldMap.get(oli.Id).Sales_Text__c : '';
            if (oli.Sales_Text__c != null && oldSalesText != oli.Sales_Text__c) {
                oli.Product_Invoice_Text__c = oli.Sales_Text__c;
            }
            oli.Product_Offering_Group_Code__c = oli.Offering_Group_Code__c;
            oli.Product_Material_Type_Text__c = oli.Product_Material_Type__c;
            oli.Unit_Name_Text__c = oli.Unit_Name__c;
            oli.Product_Group_Text__c = oli.Product_Group__c;
            if(((oli.Is_Product_Survey_Eligible__c && oli.Product_Material_Type__c == 'ZPUB')|| oli.Product_Material_Type__c == 'ZREP') && ((oli.Opportunity_Owner_Country__c == 'USA') || (oli.Opportunity_Owner_Country__c != 'USA' && oli.Unit_Name__c != 'Payer' && oli.Unit_Name__c != 'Provider'))){
                oli.Is_Survey_Eligible__c = true;
            }else{
                oli.Is_Survey_Eligible__c = false;
            }
            oli.Billing_System_Text__c = oli.Billing_System__c;
            oli.COE_Name_Text__c = oli.COE_Name__c;
            oli.ProductGroup_Text__c = oli.ProductGroup__c;
            oli.Product_Name_Text__c = oli.Product_Name__c;
            oli.Product_Business_Area__c = oli.Business_Area__c;
            oli.Product_Offering_Segment__c = oli.Offering_Segment__c;
            oli.Product_Offering_Group__c = oli.Offering_Group__c;
            oli.Product_Offering_Segment_Code__c = oli.Offering_Segment_Code__c;
            if(Trigger.isInsert && oppMap.containsKey(oli.OpportunityId) && oli.Opp_Stage_on_Insert__c == null){
               oli.Opp_Stage_on_Insert__c = oppMap.get(oli.OpportunityId).StageName;
            }
            if(Trigger.isInsert && oli.Product_Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI) {
                oli.Revenue_Type__c = 'Ad Hoc';
            }
            if(Trigger.isUpdate && (oli.Project_Awarded_Price__c != oldMap.get(oli.id).Project_Awarded_Price__c || oli.Signed_Contract_Price__c != oldMap.get(oli.id).Signed_Contract_Price__c)){
                oliIdtoOliMap.put(oli.Id,oli);
                oppIdSet.add(oli.OpportunityId);
            }
            if((oli.SAP_Code__c == 'US_SMARTMIDAS' || oli.SAP_Code__c == 'US_SMRTMVP' || oli.SAP_Code__c == 'AT_SMARTMIDAS' || oli.ProductGroup__c == 'Pricing Insights Support')){
                oli.Is_GMI_Product__c = true;
            }else{
                oli.Is_GMI_Product__c = false;
            }
            if((Trigger.isInsert || (Trigger.isUpdate && oli.Delivery_Country__c != oldMap.get(oli.Id).Delivery_Country__c) || dataMActivity.Existing_Business_Unit_Update__c) && String.isNotBlank(oli.Delivery_Country__c)){
                Delivery_Country_Mapping__c dcm = Delivery_Country_Mapping__c.getValues(oli.Delivery_Country__c);
                if(dcm != null && dcm.Business_Unit__c != null) {
                    oli.Business_Unit__c = dcm.Business_Unit__c;
                }
            }
            
            if(Trigger.isUpdate && oli.UnitPrice != oldMap.get(oli.Id).UnitPrice && oli.List_Price__c != null && oli.List_Price__c != oli.UnitPrice && (oli.Product_Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP || oli.Product_Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZPUB)){
                   oli.List_Price__c = oli.UnitPrice;
                   oli.Discount_Reason__c = CON_CRM.EMPTY_STRING;
                   oli.Surcharge_Text__c = CON_CRM.EMPTY_STRING;
            }
        }
        if(oppIdSet.size() > 0){
            // query all OPP + OLI + LIG
            Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Signed_Contract_Price__c', 'Project_Awarded_Price__c'};
            Set<String> oppFieldSet = new Set<String> {'Id', 'Total_Project_Awarded_Price__c', 'Total_Signed_Contract_Price__c'};
            Map<Id, Opportunity> oppIdToOppWithLineItemMap = new SLT_Opportunity().selectByIdWithOpportuntiyLineItem(oppIdSet, oppFieldSet, oliFieldSet);
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] { Opportunity.SObjectType }
            );
            for(Opportunity opp : oppIdToOppWithLineItemMap.values()){
                Double totalAwardedValue = 0;
                Double totalSignedValue = 0;
                for(OpportunityLineItem oli : oppIdToOppWithLineItemMap.get(opp.Id).OpportunityLineItems){
                    if(oliIdtoOliMap.containsKey(oli.Id)){
                        oli = oliIdtoOliMap.get(oli.Id);
                    }
                    if(oli.Project_Awarded_Price__c != null){
                        totalAwardedValue += oli.Project_Awarded_Price__c;
                    }
                    if(oli.Signed_Contract_Price__c != null){
                        totalSignedValue += oli.Signed_Contract_Price__c;
                    }
                }
                if(totalAwardedValue != 0){
                    opp.Total_Project_Awarded_Price__c = totalAwardedValue;
                }
                if(totalSignedValue != 0){
                    opp.Total_Signed_Contract_Price__c = totalSignedValue;
                }
                uow.registerDirty(opp);
            }
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        
    }
    
    /**
     * This method is used to set set ProxyProject Fields.
     * @params  Map<Id, OpportunityLineItem> newMap
     * @params  Map<Id, OpportunityLineItem> oldMap
     * @return  void
     */
    public static void setProxyProjectFields(Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { Proxy_Project__c.SObjectType }
        );
        Set<Id> psaProjectIdSet = new Set<Id>();
        for(OpportunityLineItem oli : newMap.values()) {
            system.debug('here'+oldMap.get(oli.id).PSA_Project__c+String.isBlank(oli.PSA_Project__c));
            if(oldMap != null && oldMap.containsKey(oli.id) && oldMap.get(oli.id).PSA_Project__c != null && String.isBlank(oli.PSA_Project__c)){
                psaProjectIdSet.add(oldMap.get(oli.id).PSA_Project__c);
            }
        }
        Set<String> fieldSet = new Set<String>{'Id', 'QI_OpportunityLineItem_Id__c', 'LI_OpportunityLineItem_Id__c'};
        List<Proxy_Project__c> proxyProjectList = new SLT_Proxy_Project().selectByLIRecordId(psaProjectIdSet, fieldSet);
        Boolean toCommit = false;
        for(Proxy_Project__c proxyProject : proxyProjectList) {
            proxyProject.QI_OpportunityLineItem_Id__c = '';
            proxyProject.LI_OpportunityLineItem_Id__c = '';
            uow.registerDirty(proxyProject);
            toCommit = true;
        }
        if(toCommit) {  
            uow.commitWork();
        }
    }
    
    /**
    * This method is used to populate Number_of_Unique_Offering_Types__c related Opportunity.
    * @params  List<OpportunityLineItem> newList
    * @return  void
    * ESPCRMINT-103
    */   
    public static void setOpportunityFields(List<OpportunityLineItem> newList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType
                    }
        );
        Set<Id> oppIdSet = new Set<Id>();
        for(OpportunityLineItem oli : newList) {
            oppIdSet.add(oli.OpportunityId);
            if(oli.UnitPrice == 0){
                isZeroAmountProduct = true;
            }
        }
        AggregateResult[] groupedResults = new SLT_OpportunityLineItems().fetchOfferingGroupResult(oppIdSet);
        for (AggregateResult ar : groupedResults)  {
            Opportunity opp = new Opportunity();
            opp.Id = (Id)ar.get('OpportunityId');
            opp.Number_of_Unique_Offering_Types__c = (Decimal)ar.get('groupCount');
            uow.registerDirty(opp);
        }
        Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId','Billing_System__c'};
        List<OpportunityLineItem> allOliList = (new SLT_OpportunityLineItems().selectByOpportunityId(oppIdSet, fieldSet)).values();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        if(allOliList.size() > 0){
            for(OpportunityLineItem oli :allOliList){
                if(oppMap.containsKey(oli.OpportunityId)){
                    if(oli.Billing_System__c != oppMap.get(oli.OpportunityId).Billing_system__c && oppMap.get(oli.OpportunityId).Billing_system__c != 'SAP and PeopleSoft'){
                        if((oli.Billing_System__c == 'SAP' && oppMap.get(oli.OpportunityId).Billing_system__c == 'PeopleSoft') ||
                           (oli.Billing_System__c == 'PeopleSoft' && oppMap.get(oli.OpportunityId).Billing_system__c == 'SAP')){
                               Opportunity opp = new Opportunity();
                               opp.Id = oli.OpportunityId;
                               opp.Billing_System__c = 'SAP and PeopleSoft';
                               oppMap.put(opp.Id,opp);
                           }
                    }
                }else{
                    Opportunity opp = new Opportunity();
                    opp.Id = oli.OpportunityId;
                    opp.Billing_System__c = oli.Billing_System__c;
                    oppMap.put(opp.Id,opp);
                }
            }
        }else{
            for(Id oppId:oppIdSet){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Billing_System__c = '';
                oppMap.put(opp.Id,opp);
            }
        }
        if(oppMap.size() > 0)
        	uow.registerDirty(oppMap.values());
        UTL_ExecutionControl.stopTriggerExecution = true;
        uow.commitWork();
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    /**
    * This method is used to populate Summary of Line Bussiness on related Opportunity.
    * @params  List<OpportunityLineItem> newList
    * @return  void
    */
    public static void setLOBOnOpp(List<OpportunityLineItem> newList) {
        Set<Id> oppIdSet = new Set<Id>();
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null) {
                oppIdSet.add(oli.OpportunityId);
            }
        }
        
        Map<Id, OpportunityLineItem> oliIdWithOliRecordMap = new Map<Id, OpportunityLineItem>();
        Set<String> oliFieldSet = new Set<String>{'OpportunityId', 'Opportunity.Summary_of_Lines_of_Business__c', 'Pricebookentry.Product2.LQ_Line_Of_Business__c'};
        if(oppIdSet.size() > 0) {
            oliIdWithOliRecordMap = new SLT_OpportunityLineItems(false).selectByOpportunityId(oppIdSet, oliFieldSet);
            Map<Id, String> oppIdWithLOBMap = new Map<Id, String>();
            Map<Id, Set<String>> oppIdWithLOBSetMap = new Map<Id, Set<String>>();
            
            for(OpportunityLineItem oli : oliIdWithOliRecordMap.values()) {
                if(!oppIdWithLOBSetMap.containskey(oli.OpportunityId)) {
                    oppIdWithLOBSetMap.put(oli.OpportunityId, new Set<String>());
                }
                if(oli.Pricebookentry.Product2.LQ_Line_Of_Business__c != null) {
                    oppIdWithLOBSetMap.get(oli.OpportunityId).add(oli.Pricebookentry.Product2.LQ_Line_Of_Business__c);
                }
                
                if(!oppIdWithLOBMap.containskey(oli.OpportunityId)) {
                    oppIdWithLOBMap.put(oli.OpportunityId, oli.Opportunity.Summary_of_Lines_of_Business__c);
                }
            }
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Opportunity.SobjectType
                }
            );
            Opportunity oppToUpdate;
            Boolean toCommit = false;
            for(Id oppId : oppIdWithLOBMap.keySet()) {
                
                String lobToCompare;
                Boolean isFirst = true;
                for(String lob : oppIdWithLOBSetMap.get(oppId)) {
                    if(isFirst)
                        lobToCompare = lob;
                    else
                        lobToCompare += ';' + lob;
                    isFirst = false;
                }
                
                if(lobToCompare != null && !lobToCompare.equals(oppIdWithLOBMap.get(oppId))) {
                    oppToUpdate = new Opportunity();
                    oppToUpdate.Id = oppId;
                    oppToUpdate.Summary_of_Lines_of_Business__c = lobToCompare;
                    uow.registerDirty((Opportunity)oppToUpdate);
                    toCommit = true;
                }
            }
            
            if(toCommit) {
                UTL_ExecutionControl.stopTriggerExecution = true;
                uow.commitWork();
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        }
    }
        
    /**
    * This method is used to populate Summary of Line Bussiness on related Opportunity.
    * @params  List<OpportunityLineItem> newList
    * @return  void
    */
    public static void setMC_CESAndSegmantFlag(List<OpportunityLineItem> newList) {
        Set<Id> pbeIdSet = new Set<Id>();
        for(OpportunityLineItem oli: newList) {
            pbeIdSet.add(oli.PricebookEntryId);
        }
        
        Map<Id, PricebookEntry> pricebookEntryMap = new SLT_PriceBookEntry().getMapOfPbEntriesByProductIdSet(pbeIdSet);
        for(OpportunityLineItem oli: newList) {
            if (oli.pricebookEntryId!=null && pricebookEntryMap.containsKey(oli.pricebookEntryId) && pricebookEntryMap.get(oli.pricebookEntryId)!=null && pricebookEntryMap.get(oli.pricebookEntryId).Product2.Offering_Type__c != null)
            {
                oli.MC_CES__c = pricebookEntryMap.get(oli.pricebookEntryId).Product2.Offering_Type__c;
            }
            else
            {
                oli.MC_CES__c = null;
            }
            if(pricebookEntryMap.containsKey(oli.pricebookEntryId) && pricebookEntryMap.get(oli.pricebookEntryId) != null && pricebookEntryMap.get(oli.pricebookEntryId).Product2 != null)
            {
                oli.Segment_Flag__c = pricebookEntryMap.get(oli.pricebookEntryId).Product2.Offering_Segment__c;
            }            
        }
    }
    /*ESPSFDCQI-4415*/
    public static void setOliTherapyArea(List<OpportunityLineItem> oliList) {
        for(OpportunityLineItem oli : oliList){
            if(String.isNotBlank(oli.Budget_Therapy_Area__c) && String.isBlank(oli.Therapy_area__c) && oli.Product_Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP){
                oli.Therapy_area__c = oli.Budget_Therapy_Area__c;
            } 
        }
    }
    
    /**
    * This method is used to verify Privacy Analytics TeamMember
    * @params  List<OpportunityLineItem> oliList
    * @return  void
    */
    public static void verifyPrivacyAnalyticsTeamMember(List<OpportunityLineItem> oliList) {
        String errorMsg = 'Need PA team member to add a PA product';
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id =:profileId].Name;
        if (profileName == CON_CRM.SYSTEM_ADMIN_PROFILE) {
            return;
        }
        Set<String> paProductCodeSet = new Set<String>();
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        Set<Id> paGroupMembersSet = new Set<Id>();
        Map<Id, List<OpportunityLineItem>> oppIdToOLIMap = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, OpportunityTeamMember> oppIdToOTMMap = new Map<Id, OpportunityTeamMember>();
        List<PrivacyAnalyticsProductCode__c> paProductCodeList = PrivacyAnalyticsProductCode__c.getall().values();
        for (PrivacyAnalyticsProductCode__c papc : paProductCodeList) {
            paProductCodeSet.add(papc.Product_Code__c);
        }
        Set<String> fieldSet = new Set<String>{'UserOrGroupId'};   
        List<GroupMember> groupMemberList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =: CON_CRM.GROUP_PLATFORM_ANALYTICS_SALES_GROUP];
        for (GroupMember gm : groupMemberList) {
            paGroupMembersSet.add(gm.UserOrGroupId);
        }
        for (OpportunityLineItem oli : oliList) {
            if (paProductCodeSet.contains(oli.ProductCode)) {
                if (oppIdToOLIMap.get(oli.OpportunityId) == null) {
                    oppIdToOLIMap.put(oli.OpportunityId, new List<OpportunityLineItem>());
                }
                oppIdToOLIMap.get(oli.OpportunityId).add(oli);
            }
        }
        fieldSet = new Set<String>{'Id', 'OpportunityId'};
        if (oppIdToOLIMap.size() > 0) {
            oppTeamMemberList = new SLT_OpportunityTeamMember().selectByOpportunityIdAndUserId(oppIdToOLIMap.keySet(), fieldSet, paGroupMembersSet);
        }
        for (OpportunityTeamMember otm : oppTeamMemberList) {
            oppIdToOTMMap.put(otm.OpportunityId, otm);
        }
        for (Id oppId: oppIdToOLIMap.keySet()) {
            if (oppIdToOTMMap.get(oppId) == null) {
                for (OpportunityLineItem oli : oppIdToOLIMap.get(oppId)) {
                    oli.addError(errorMsg);
                }
            }
        }   
    }
    
    /**
     * This method is used to upsert IQVIA_LI_ZQUI_MAPPING__c on OpportunityLineItem.
     * @params  List<OpportunityLineItem> newList
     * @params  Map<Id, OpportunityLineItem> newMap
     * @params  Map<Id, OpportunityLineItem> oldMap
     * @return  void
     */
    public static void upsertIqviaLiZquiMappingObject(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> newMap, Map<Id, OpportunityLineItem> oldMap){
        List<IQVIA_LI_ZQUI_MAPPING__c> IqviaLiZquiMappingList = new List<IQVIA_LI_ZQUI_MAPPING__c>();
        Map<Id,OpportunityLineItem> oliList = new Map<Id,OpportunityLineItem>(new SLT_OpportunityLineItems().selectByOLIIds(newMap.keySet(),new Set<String> {'Opportunity.IsCurrencyChanged__c','Opportunity.LI_Opportunity_Id__c','Product2.Material_Type__c','Product2.ZQUI_Product__c','Product2.Productcode' }));        
        for(OpportunityLineItem oli : newList) {
            String fieldAPI = '';
            for(Schema.FieldSetMember sf : Schema.SObjectType.OpportunityLineItem.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                fieldAPI = sf.getFieldPath();
                IQVIA_LI_ZQUI_MAPPING__c iqviaLImapping = new IQVIA_LI_ZQUI_MAPPING__c();
                if (((trigger.isInsert && !oliList.get(oli.id).Opportunity.IsCurrencyChanged__c)|| (trigger.isUpdate && oli.get(fieldAPI) != oldMap.get(oli.Id).get(fieldAPI)) || ( trigger.isUpdate && String.isBlank(oldMap.get(oli.Id).LQ_OpportunityLineItem_Id__c) && !String.isBlank(newMap.get(oli.Id).LQ_OpportunityLineItem_Id__c))) && !String.isBlank(oliList.get(oli.id).Opportunity.LI_Opportunity_Id__c) && oliList.get(oli.id).Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI && oliList.get(oli.id).Product2.ZQUI_Product__c) {
                    iqviaLImapping.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                    iqviaLImapping.Action_type__c = CON_CRM.UPSERT_LABEL;
                    mapIqviaLiZquiMappingObject(iqviaLImapping,oli,oliList.get(oli.id).Opportunity.LI_Opportunity_Id__c,oliList.get(oli.id).Product2.Productcode);
                    IqviaLiZquiMappingList.add(iqviaLImapping);
                    break;
                }   
            }
        }
        if(IqviaLiZquiMappingList.size() > 0){
            upsert IqviaLiZquiMappingList QI_OpportunityLineItem_Id__c;
        }
    }
    
    /**
     * This method is used to delete IQVIA_LI_ZQUI_MAPPING__c on OpportunityLineItem.
     * @params  List<OpportunityLineItem> oldList
     * @return  void
     */
    public static void deleteIqviaLiZquiMappingObject(List<OpportunityLineItem> oldList){
        List<IQVIA_LI_ZQUI_MAPPING__c> IqviaLiZquiMappingList = new List<IQVIA_LI_ZQUI_MAPPING__c>();
        Set<Id> OppIdSet = new Set<Id>();
        Set<Id> ProductIdSet = new Set<Id>();

        for(OpportunityLineItem oli : oldList){
           OppIdSet.add(oli.OpportunityId);
           ProductIdSet.add(oli.Product2Id);
        }
        Map<Id,Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>(OppIdSet), new Set<String>{'id','LI_Opportunity_Id__c'});
        Map<Id,Product2> prodMap = new Map<Id,Product2>(new SLT_Product2().selectById(new Set<Id>(ProductIdSet)));

        for(OpportunityLineItem oli : oldList) {
            IQVIA_LI_ZQUI_MAPPING__c iqviaLImapping = new IQVIA_LI_ZQUI_MAPPING__c();
                if (oppMap.get(oli.OpportunityId).LI_Opportunity_Id__c != '' && prodMap.get(oli.Product2Id).Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI && prodMap.get(oli.Product2Id).ZQUI_Product__c) {
                    iqviaLImapping.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                    iqviaLImapping.Action_type__c = CON_CRM.DELETE_LABEL;
                    mapIqviaLiZquiMappingObject(iqviaLImapping,oli,oppMap.get(oli.OpportunityId).LI_Opportunity_Id__c,prodMap.get(oli.Product2Id).Productcode);
                    IqviaLiZquiMappingList.add(iqviaLImapping);
                }   
        }
        
        if(IqviaLiZquiMappingList.size() > 0){
            upsert IqviaLiZquiMappingList QI_OpportunityLineItem_Id__c;
        }
    }
    
    /**
     * This method is used to set IQVIA_LI_ZQUI_MAPPING__c on OpportunityLineItem.
     * @params  IQVIA_LI_ZQUI_MAPPING__c iqviaLiZquiMapping
     * @params  OpportunityLineItem oli
     * @params  String oppLiId
     * @params  String productCode
     * @return  void
     */
    public static void mapIqviaLiZquiMappingObject(IQVIA_LI_ZQUI_MAPPING__c iqviaLiZquiMapping, OpportunityLineItem oli, String oppLiId,String productCode){
        iqviaLiZquiMapping.QI_OpportunityLineItem_Id__c = oli.Id;
        iqviaLiZquiMapping.QI_opportunity_id__c = oli.OpportunityID;
        iqviaLiZquiMapping.LI_Opportunity_Id__c = oppLiId;
        iqviaLiZquiMapping.Delivery_country__C = oli.Delivery_country__C;
        iqviaLiZquiMapping.Revenue_type__C = oli.Revenue_type__C;
        iqviaLiZquiMapping.Sale_type__C = oli.Sale_type__C;
        iqviaLiZquiMapping.ProductCode__C = productCode;
        iqviaLiZquiMapping.CurrencyIsocode__c = oli.CurrencyIsoCode;
        //iqviaLiZquiMapping.Mulesoft_Error_Message__c = oli.Mulesoft_Error_Message__c;
        //iqviaLiZquiMapping.LI_OpportunityLineItem_Id__c = oli.LI_OpportunityLineItem_Id__c;
        iqviaLiZquiMapping.Quantity__C = oli.Quantity;
        iqviaLiZquiMapping.Therapy_Area__c = oli.Therapy_Area__c;  
        iqviaLiZquiMapping.TotalPrice__c = oli.TotalPrice;
    }

    /**
     * This method is used to add a zero value opportunityLineITem by commercialOpsUser only.
     * @params  List<OpportunityLineItem> newList
     * @params  Map<Id, OpportunityLineItem> oldMap
     * @return  void
     */
   /* public static void addZeroValueProduct(List<OpportunityLineItem> newList,Map<Id,OpportunityLineItem> oldMap){
        if(Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            List<OpportunityLineItem> zeroValueOliList = new List<OpportunityLineItem>();
            Set<Id> productIdsSet = new Set<Id>();
            Set<Id> oppIdsSet = new Set<Id>();
            Decimal totalPrice;
            for(OpportunityLineItem oli : newList){
                if(oli.UnitPrice != null){
                    totalPrice = oli.UnitPrice;
                }else if(oli.TotalPrice != null){
                    totalPrice = oli.TotalPrice;
                }
                if((Trigger.IsInsert ||(Trigger.isUpdate && oldMap.get(oli.id).UnitPrice != totalPrice)) && totalPrice > 0 && totalPrice < 1){
                    zeroValueOliList.add(oli);
                    productIdsSet.add(oli.Product2Id);
                    oppIdsSet.add(oli.OpportunityId);
                }
            }
            if(zeroValueOliList.size() > 0){
                Profile currentProfile = new SLT_Profile().selectById(new Set<ID>{UserInfo.getProfileId()})[0];
                Map<Id,Opportunity> OppMap = new SLT_Opportunity().getOpportunityById(oppIdsSet, new Set<String>{'id','StageName'});
                Map<Id,Product2> ProductMap = new Map<Id,Product2>(new SLT_Product2().selectById(productIdsSet));
                for(OpportunityLineItem oli : zeroValueOliList) {
                    if(ProductMap.get(oli.Product2Id).Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI && ProductMap.get(oli.Product2Id).ZQUI_Product__c && !(OppMap.get(oli.OpportunityId).StageName == CON_CRM.IN_HAND_STAGE || OppMap.get(oli.OpportunityId).StageName == CON_CRM.CLOSED_LOST_STAGE) ){
                        if(currentProfile.Name != CON_CRM.COMMERCIAL_OPERATION_PROFILE ){                   
                            oli.adderror(' Only Commercial Ops Users can add $0.01 products to Opportunity');
                        }
                    }
                }
            }            
        }
    }
    */
    /**
    * This method is used to Prevent User to Edit OLI on Stage Closed and IN-Hand 
    * @params  oliList List<OpportunityLineItem>
    * @return  void
    */
    public static void preventUpdateOrDeleteOLIRecord(List<OpportunityLineItem> oliList) {
        Map<Id, OpportunityLineItem> oppIdOLIMap = new Map<Id, OpportunityLineItem>();
        Set<Id> productIdsSet = new Set<Id>();
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List<Profile> profileList = new SLT_Profile().selectById(new Set<Id>{ UserInfo.getProfileId()});
        String profileName = profileList[0].Name;
        String errorString = 'You cannot Add/Delete a product at stage ';
        Decimal totalPrice; 
        Set<String> oppStageSet = new Set<String>{CON_CRM.CLOSED_WON_STAGE, CON_CRM.IN_HAND_STAGE};
            if((!mulesoftSetting.Ignore_Validation_Rules__c || mulesoftSetting.Enforce_Admin_Validation__c) &&  !profileName.contains(CON_CRM.SYSTEM_ADMIN_PROFILE)) {
                for(OpportunityLineItem oli : oliList) {
                    oppIdOLIMap.put(oli.OpportunityId, oli);
                    productIdsSet.add(oli.Product2Id);
                }
                Map<Id, Opportunity> oppIdToOppMap = new SLT_Opportunity().getOpportunityById(oppIdOLIMap.keySet(), new Set<String>{'Id', 'StageName'});
                Map<Id,Product2> ProductMap = new Map<Id,Product2>(new SLT_Product2().selectById(productIdsSet));
                for(Opportunity opp : oppIdToOppMap.values()) {
                    OpportunityLineItem oli = oppIdOLIMap.get(opp.Id);
                    if(oli.TotalPrice != null){
                        totalPrice = oli.TotalPrice;
                    }else if(oli.UnitPrice != null){
                        totalPrice = oli.UnitPrice;
                    } 
                    if(opp.StageName == CON_CRM.CLOSED_LOST_STAGE) {
                        oli.addError(errorString + opp.StageName);
                    } else if(Trigger.isInsert && (profileName == CON_CRM.COMMERCIAL_OPERATION_PROFILE || FeatureManagement.checkPermission(CON_CRM.CP_COMMERCIAL_OPS_USER)) && (ProductMap.get(oli.Product2Id).ZQUI_Product__c || ProductMap.get(oli.Product2Id).ProductCode == CON_CRM.RWLP_SHADOW_PRODUCT_CODE) && totalPrice == 0){
                        CON_CRM.IGNORE_PA_VALIDATION = true;
                    } else if(oppStageSet.contains(opp.StageName)){
                        oli.addError(errorString + opp.StageName);
                    }
                }
            } 
    }

    /**
    * This method is used to populate Fields on opportunityLineItem.
    * @params  List<OpportunityLineItem> newList
    * @params  List<OpportunityLineItem> oldMap
    * @return  void
    */
    public static void setRevenueDateFields(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItem oli : newList) {
            if(Trigger.IsInsert || (Trigger.isUpdate && oli.OpportunityLineItemSchedule_JSON__c != oldMap.get(oli.Id).OpportunityLineItemSchedule_JSON__c)) {
                if(!String.ISBLANK(oli.OpportunityLineItemSchedule_JSON__c)) {
                    olisList = (List<OpportunityLineItemSchedule>)JSON.deserialize(oli.OpportunityLineItemSchedule_JSON__c, List<OpportunityLineItemSchedule>.class);
                    Integer listSize = olisList.size();
                    if(listSize > 0) {
                        oli.Revenue_Start_Date__c = olisList[0].ScheduleDate;
                        oli.Revenue_End_Date__c = olisList[listSize-1].ScheduleDate;
                    } else {
                        oli.Revenue_Start_Date__c = NULL;
                        oli.Revenue_End_Date__c = NULL;
                    }
                }
            }
        }
    }
}