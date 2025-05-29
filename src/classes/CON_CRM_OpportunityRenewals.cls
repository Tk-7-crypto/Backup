public class CON_CRM_OpportunityRenewals {

    //Cloning action options
    public static final String NO_CHANGE_STR = 'No Change';
    public static final String CHANGE_DETAIL_STR = 'Change Detail';
    public static final String NO_RENEW_STR = 'No Renew';
    public static final String NEEDS_NO_RENEW_REASON_STR = 'Needs No Renew Reason';
    
    //Cloning status strings
    public static final String QUEUED_STATUS_STR = 'queued';
    public static final String CLONED_STATUS_STR = 'cloned';
    public static final String AW_DETAILS_STATUS_STR = 'Awaiting Details';
    public static final String NO_RENEW_STATUS_STR = 'No Renew';
    public static final String ERROR_STATUS_STR = 'errored';
    
    //Opportunity Stages
    public static final String OPP_STAGE_1 = '1. Identifying Opportunity';
    public static final String OPP_STAGE_2 = '2. Qualifying Opportunity';
    public static final String OPP_STAGE_3 = '3. Developing Proposal';
    public static final String OPP_STAGE_4 = '4. Delivering Proposal';
    public static final String OPP_STAGE_5 = '5. Finalizing Deal';
    public static final String OPP_STAGE_6 = '6. Received ATP/LOI';
    public static final String OPP_STAGE_6A = '7a. Closed Won';
    public static final String OPP_STAGE_6B = '7b. Closed Lost';
    public static final String OPP_STAGE_IN_HAND = 'In-Hand';
    
    //Debug related
    public static final Boolean IS_DEBUG_ENABLED = true;
    
    public static Boolean allowCbexQueueable = true;
}