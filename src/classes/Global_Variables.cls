public with sharing class Global_Variables 
{
    // Issue-10898
    public static Boolean isTerritoryUpdate = false;
    public static Boolean RenewalCloneFlag = false;
    public static Boolean Product_Duplicate_Trigger_Run_Once = false;
    public static Boolean OverRideUlrReactivationCheck = false;
    public static Boolean PCFlag = true;
    public static Boolean MIBNF_Component_Update_In_Progress = false;
    public static Boolean RunQuickOppLimitTrigger = true;
    /**************************************************************************
    Update by : Himanshu parashar
    Date : 3 Feb 2012
    Skip account null for sending temp insertion of Address and send Request mail
    ****************************************************************************/
    public static Boolean RunAddressRequestTrigger = true;
    //Update by: Sneha Date: 6th Nov, 2012 -- Oppty to Agreement Sync - stops sync if flag set to false
    public static Boolean syncAgreementToOppty = true;
    public static Boolean deleteAliWithOli = true;
    //Update by: Sneha Date: 6th Nov, 2012 - End
    
    //Updated by: Sunil Kumar Sharma: Issue IM1334541 : Too many SOQL queries on change currency functionality. - START
    public static Boolean OppttPICEmail_Hault_Execution = false;
    //Updated by: Sunil Kumar Sharma: Issue IM1334541 : Too many SOQL queries on change currency functionality. - START
    //Update by :Sunil Kumar Sharma : Issue IM1342651 : Too many SOQL queries on Create change Request functionality - START
    public static Boolean PCTrigger_Hault_Execution = false;
    //Update by :Sunil Kumar Sharma : Issue IM1342651 : Too many SOQL queries on Create change Request functionality - END
    
    //Update by: Himanshu Date: 10th Oct, 2013 : Flag to stop Contact sync when User deactivated
    public static Boolean RunContactSyncTrigger =true;
    //Update by: Himanshu Date: 28 Nov, 2013 : Flag to stop CMRR Loop change on OLI
    public static Boolean RunCMRRCalc=false;
    
    public static boolean CreateUpdateFeedback = true; //Added by: Himanshu Date: 21 April, 2014 : ER-703
    
    public static boolean runChatterFollowRules = true; // Added by Ritesh Gupta - Issue-07856
    
    //Added by Priyamvada - ER-2910 - start
    public static Boolean updatingResourceRateCard = false;
    public static Boolean updatingRR_RateCardInSameContext = false;
    //Added by Priyamvada - ER-2910 - end
    
    public static Boolean AsgTimecardCostUpdateBatchRunning = false; //Added by Priyamvada - ESIssue-09839 - 28Oct2016
    public static Boolean rrAgingBatchRunning = false; //Added by Priyamvada - ESIssue-09950 - 21Nov2016
    
     public static boolean isupdatableOppPlan = true; // added by dheeraj kumar 07 sept 2016 opp plan trigger
    
    //Added by Ritesh Gupta
    public static boolean isOLIJsonDataSetup = false; 
    public static boolean isS2SFlowRunning = false;
    
    //Update by: Suman Sharma Date: 30 DEC, 2016 : Flag to track cloning Opp
    public static boolean isclonningOpportunity = false;
    
    //Update by: Suman Sharma Date: 29 March 2016 : Flag to exclude Revenue Shedule validation on PA Opp Update 
    public static boolean EXCLUDE_SCHEDULE_DATE_VALIDATION_FOR_PA = false;
    
    //Added by: Sweta Sharma Date: 26 Dec 2017 : Flag to exclude Mulesoft Integration code rerun/ Description : ESPSFDCQI-767 
    public static boolean ALLOW_MULESOFT_INTEGRATION_FIELD_UPDATE = true;
    
    //Added by Anshita Feature-768 : To prevent execution of trigger twice
    public static Boolean olisTriggerAlreadyRun = false;
    
    //Mulesoft Integration Fields
    public static final String MULESOFT_SYNC_STATUS_COMPLETED = 'Completed';
    public static final String MULESOFT_SYNC_STATUS_PENDING = 'Pending';
    public static final String MULESOFT_SYNC_STATUS_FAILED = 'Failed';
    public static final String UPDATE_TYPE_MULESOFT_SLAVE = 'MULESOFT_SLAVE';
    public static final String UPDATE_TYPE_MULESOFT_TALKBACK = 'MULESOFT_TALKBACK';
    public static final String UPDATE_TYPE_USER = 'USER';
    public static boolean MULESOFT_VALIDATION_TRIGGER_HAS_RUN = false;
    public static boolean MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
    public static boolean MULESOFT_OLI_VALIDATION_TRIGGER_HAS_RUN = false;
    public static boolean MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
    public static boolean MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = false;
    public static boolean IS_BYPASS_OLI_TRIGGER = false;
    public static boolean IS_BYPASS_OPP_TRIGGER = false;
    public static String TEMP_UPDATE_TYPE_MULESOFT_SLAVE = 'USER';
    public static String TEMP_UPDATE_TYPE_MULESOFT_SLAVE_OLI = 'USER';
    
    //Added By Nikhil Garg for Issue 12144 on 28 June 2018 :  =======Start
    //Bypass future menthod called by user trigger when manager changes
    public static boolean UpdateManagerOnEPRandCostDays = true;
    //Bypass future menthod called by user trigger when manager changes
    
    //Bypass future method of chatter follow when manager changes on user
    public static boolean updateUserManagerforChatterFollow = true;
    //Bypass future method of chatter follow when manager changes on user
    //Added By Nikhil Garg for Issue 12144 on 28 June 2018 :  =======End
    //
}