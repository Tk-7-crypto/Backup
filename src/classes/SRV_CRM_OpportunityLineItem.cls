/*
 * Version       : 1.0
 * Description   : Service Class for OpportunityLineItem
 */
global class SRV_CRM_OpportunityLineItem {
    
    /**
     * This method used to get list of OLIs
     * @params  Set<Id> oppIdset
     * @params  Set<string> fieldSet
     * @return  OLIWrapper
     */
    public static List<OpportunityLineItem> getListOfOLI(Set<Id> oppIdset, Set<string> fieldSet) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        try {
            Map<Id, OpportunityLineItem> oliIdToLineItemMap = new SLT_OpportunityLineItems().selectByOpportunityId(oppIdSet, fieldSet);
            oliList = oliIdToLineItemMap.values();
            return oliList;
        } catch (exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new SRV_CRM_OpportunityLineItem_Exception(new List<String>{errMsg});
        }
    }
    
    /**
     * This method used to get list of OLI
     * @params  Set<Id> oliIdset
     * @params  Set<String> fieldSet
     * @return  List<OpportunityLineItem>
     */
    public static List<OpportunityLineItem> getOpportunityLineItemsDetail(Set<Id> oliIdset, Set<String> fieldSet) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        try {
            oliList = new SLT_OpportunityLineItems().selectByOLIIds(oliIdset, fieldSet);
        } catch (exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new SRV_CRM_OpportunityLineItem_Exception(new List<String>{errMsg});
        }
        return oliList;
    }
    
    /**
     * This method used to perform CRUD on OLI
     * @params  List<OpportunityLineItemWrapper> oliList
     * @params  String action
     * @params  OpportunityLineItem recordToDelete
     */
    public static List<Id> updateOliRecords(List<OpportunityLineItemWrapper> oliList) {
        List<Id> oliIdList = new List<Id>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItem.SObjectType,
                OpportunityLineItemSchedule.SObjectType
            }
        );
        fflib_SObjectUnitOfWork uowForSchedules = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItemSchedule.SObjectType
            }
        );
        Boolean toCommit = false;
        Boolean createSchedule = false;
        Savepoint sp = Database.setSavepoint(); 
        try {
            for(OpportunityLineItemWrapper oli : oliList) {
                if(oli.operationType == CON_CRM.EDIT_LABEL) {
                    uow.registerDirty(oli.oliRecord);
                    toCommit = true;
                } else if(oli.operationType == CON_CRM.CREATE_LABEL) {
                    oli.oliRecord.Quantity = 1;
                    uow.registerNew(oli.oliRecord);
                    toCommit = true;
                    if(oli.revSchWrapperList != null && oli.revSchWrapperList.size() > 0) {
                        Map<String, OpportunityLineItemSchedule> oliDateToSchedulteMap = new Map<String, OpportunityLineItemSchedule>();
                        for(OpportunityLineItemScheduleWrapper olisWrapper : oli.revSchWrapperList) {
                            if(olisWrapper.operationType == CON_CRM.CREATE_LABEL) {
                                olisWrapper.schRecord.OpportunityLineItemId = oli.oliRecord.Id;
                                String key;
                                if(String.isBlank(olisWrapper.schRecord.Description)){
                                    key = olisWrapper.schRecord.ScheduleDate + '';
                                } else{
                                    key = olisWrapper.schRecord.ScheduleDate + ':' + olisWrapper.schRecord.Description;
                                }
                                if(oliDateToSchedulteMap.containsKey(key)) {
                                    oliDateToSchedulteMap.get(key).Revenue += olisWrapper.schRecord.Revenue;
                                } else {
                                    oliDateToSchedulteMap.put(key, olisWrapper.schRecord);
                                }
                            } else if(olisWrapper.operationType == CON_CRM.DELETE_LABEL) {
                                uow.registerDeleted(olisWrapper.schRecord);
                            }
                        }
                        if(oliDateToSchedulteMap.size() > 0) {
                            for(OpportunityLineItemSchedule olisch : oliDateToSchedulteMap.values()) {
                                uowForSchedules.registerNew(olisch, OpportunityLineItemSchedule.OpportunityLineItemId, oli.oliRecord);
                            }
                        }
                    }
                } else if(oli.operationType == CON_CRM.DELETE_LABEL) {
                    uow.registerDeleted(oli.oliRecord);
                    toCommit = true;
                }
            }
            
            if(toCommit) {
                uow.commitWork();
                for(OpportunityLineItemWrapper oliWrapper : oliList){
                    oliIdList.add(oliWrapper.oliRecord.id);
                }
                //below assignment will stop reset of oli mulesoft sync flag to reset.
                CON_CRM.OLI_NEW_LIST_OLD_COUNT = -1;
                uowForSchedules.commitWork();
            }
            return oliIdList;
        } catch (exception ex) {
            Database.rollback(sp);
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CRM_OpportunityLineItem_Exception(new List<String>(errorMsgList));
            //return oliIdList;
        }
    }
    
    /**
     * This method returns Opportunity line Item with Schedule Records for any opportunity.
     * @params  Set<Id> opportinityId
     * @params  List<String> olifieldList
     * @params  List<String> olifieldList
     * @return  List<OpportunityLineItem> opportunityLineItemList
     */
    public static List<OpportunityLineItem> getOliByIdWithSchedule(Set<Id> oppIdSet, Set<String> olifieldList, Set<String> oliSchedulefieldList) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        try {
            Map<Id, OpportunityLineItem> oliIdToLineItemMap = new SLT_OpportunityLineItems().getOlisWithSchedules(oppIdSet, olifieldList, oliSchedulefieldList);
            oliList = oliIdToLineItemMap.values();
            return oliList;
        } catch (exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new SRV_CRM_OpportunityLineItem_Exception(new List<String>{errMsg});
        }
    }
    
    /**
     * Exception class for SRV_CRM_OpportunityLineItem
     */
    public class SRV_CRM_OpportunityLineItem_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
         * constructor of SRV_CRM_OpportunityLineItem_Exception
         */
        public SRV_CRM_OpportunityLineItem_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
}