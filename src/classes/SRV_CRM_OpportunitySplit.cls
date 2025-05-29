/*
 * Version       : 1.0
 * Description   : Service Class for OpportunitySplit
 */
global class SRV_CRM_OpportunitySplit {
    
    /**
     * This method get OpportunitySplit Records for given opportunity Id.
     * @params  Set<Id> oppIdSet
     * @params  String splitType
     * @params  Set<String> fieldSet
     * @return  List<OpportunitySplit>
     */
    public static List<OpportunitySplit> getOpportunitySplitRecords(Set<Id> oppIdSet, String splitType, Set<String> fieldSet) {
        List<OpportunitySplit> opportunitySplitList = new List<OpportunitySplit>();
        try {
            opportunitySplitList = new SLT_OpportunitySplit().selectByOpportunityId(oppIdSet, splitType, fieldSet);
        } catch(Exception ex) {
            throw new OpportunitySplitServiceException(new List<String>{ex.getMessage()});
        }   
        return opportunitySplitList;
    }
    
    /**
     * This method get OpportunitySplitType Id By it's Name
     * @params  String splitTypeName
     * @params  Set<String> fieldSet
     * @return  Id
     */
    public static Id getOpportunitySplitTypeIdByName(String oppSplitTypeName) {
        List<OpportunitySplitType> opportunitySplitTypeList = new List<OpportunitySplitType>();
        Id oppSplitTypeId = null;
        try {
            opportunitySplitTypeList = new SLT_OpportunitySplitType().selectByOppSplitTypeName(oppSplitTypeName);
            if(opportunitySplitTypeList.size() > 0) {
                oppSplitTypeId = opportunitySplitTypeList[0].Id;
            }
        } catch(Exception ex) {
            throw new OpportunitySplitServiceException(new List<String>{ex.getMessage()});
        }   
        return oppSplitTypeId;
    }
    
    /**
     * This method update OpportunitySplit Records
     * @params  List<OpportunitySplit>
     * @return  void
     */
    public static void updateOpportunitySplits(List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList) {
        System.SavePoint sp = null;
        try {
            sp = Database.setSavepoint();
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {OpportunitySplit.SobjectType});
            fflib_SObjectUnitOfWork uowDelete = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {OpportunitySplit.SobjectType});
            for(OpportunityWrapper.OpportunitySplitWrapper oppSplitWrapper : oppSplitWrapperList) { 
                OpportunitySplit spiltRecord = oppSplitWrapper.splitRecord;
                if(oppSplitWrapper.operationType == CON_CRM.DELETE_LABEL) {
                    uowDelete.registerDeleted(spiltRecord);
                } else if(oppSplitWrapper.operationType == CON_CRM.CREATE_LABEL) {
                    uow.registerNew(spiltRecord);
                } else if(oppSplitWrapper.operationType == CON_CRM.EDIT_LABEL) {
                    uow.registerDirty(spiltRecord);
                }
            }
            uowDelete.commitWork();
            uow.commitWork();
        } catch(Exception ex) {
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
            throw new OpportunitySplitServiceException(new List<String>(errorMsgList));
        }  
    }
    
    // Exception Class for OpportunitySplit Service
    public Class OpportunitySplitServiceException extends Exception {
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public OpportunitySplitServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}