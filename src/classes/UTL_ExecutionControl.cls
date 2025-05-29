/**
 * This class used for control the execution of triggers
 * version : 1.0
 */
public class UTL_ExecutionControl {
    public static Boolean stopTriggerExecution = false;
    public static Boolean olisTriggerAlreadyRun = false;
    public static Boolean stopMilestoneTriggerExecution = false;
    public static Boolean stopAuditTriggerExecution = false;
    public static Boolean disableTriggerCRUDSecurityForOpportunity = false;
    //Flag for OWF module
    public static Boolean stopTriggerExecution_OWF = false;
    public static Boolean stopUserUpdateFromUserTrigger = false;
    public static Boolean disableTriggerCRUDAGR = false;
    public static Boolean isCurrencyIsoCodeChangeAllowed = false; 
    public static Boolean coEmailSent = false; 
    public static Boolean hasTraversedTrigger = false;
    public static Boolean skipValidate = false;
    //Flag for CPQ module
    public static Boolean disableTriggerCRUDIQQuote = true;
    public static Boolean stopTriggerExecutionCPQ = false;
}