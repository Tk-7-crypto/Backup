/*
 * Version       : 1.0
 * Description   : Service Class for OpportunityTeamMember
 */
global class SRV_CRM_OpportunityTeamMember {
    
    /**
     * This method add OpportunityTeamMember Records.
     * @params  List<OpportunityTeamMember>
     * @return  void
     */
    public static void addOpportunityTeamMember(List<OpportunityTeamMember> oppTeamMemberList) {
        System.SavePoint sp = null;
        try {
            sp = Database.setSavepoint();
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {OpportunityTeamMember.SobjectType});
            System.debug('oppTeamMemberList'+oppTeamMemberList);
            for(OpportunityTeamMember oppTeamMember : oppTeamMemberList) { 
                if(oppTeamMember.id != null){
                    uow.registerDirty(oppTeamMember);
                } else {
                    uow.registerNew(oppTeamMember);
                }
            }
            uow.commitWork();
        } catch(Exception ex) {
            Database.rollback(sp);
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new OpportunityTeamMemberServiceException(new List<String>{errMsg});
        }  
    }
    
    /**
     * This method delete OpportunityTeamMember Records.
     * @params  List<OpportunityTeamMember>
     * @return  void
     */
    public static void deleteOpportunityTeamMember(List<OpportunityTeamMember> oppTeamMemberList) {
        System.SavePoint sp = null;
        try {
            sp = Database.setSavepoint();
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {OpportunityTeamMember.SobjectType});
            uow.registerDeleted(oppTeamMemberList);          
            uow.commitWork();
        } catch(Exception ex) {
            Database.rollback(sp);
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new OpportunityTeamMemberServiceException(new List<String>{errMsg});
        }  
    }
    
    // Exception Class for OpportunityTeamMember Service
    public Class OpportunityTeamMemberServiceException extends Exception {
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public OpportunityTeamMemberServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}