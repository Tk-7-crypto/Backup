/**
 * This class used for constants used in Qualtrics project.
 */
public class CON_Qualtrics {
    // Survey Type
    public static final String END_OF_ENGAGEMENT = 'End of Engagement';
    public static final String ONGOING = 'Ongoing';

    // Survey Initiation Status
    public static final String SURVEY_DECLINED_PENDING_MGR_APPROVAL = 'Survey Declined, Pending Mgr Approval';
    public static final String SURVEY_DECLINED_WITH_MGR_APPROVAL = 'Survey Declined w/Mgr Approval';
    public static final String NEW_SURVEY = 'New'; 
    public static final String SURVEY_APPROVED = 'Survey Approved';
    public static final String SURVEY_DELAYED_PENDING_APPROVAL = 'Survey Delayed, Pending Approval';
    public static final String SURVEY_DELAYED_WITH_MGR_APPROVAL = 'Survey Delayed w/Mgr Approval';
    public static final String SURVEY_SENT_WITHOUT_PIC_ACTION= 'Survey Sent without PIC Action';
	
    // Don't Send Survey Reason
    public static final String DELAYED = 'Delayed'; 
    public static final String DECLINED = 'Declined';
   
    // Survey Method
    public static final String WEB_SURVEY = 'Web Survey';
    public static final String INTERVIEW = 'Interview';
    
    // Send Survey
    public static final String SEND_SURVEY_NO = 'No';
    public static final String SEND_SURVEY_YES = 'Yes';
    
    // Groups
    public static final String CLIENT_SAT_ADMINS = 'Client Sat Admins';

    // Field API Name
    public static final String SURVEY_RECIPIENT_1 = 'Survey_Recipient_1__c'; 
    public static final String SURVEY_RECIPIENT_2 = 'Survey_Recipient_2__c'; 
    public static final String SURVEY_RECIPIENT_3 = 'Survey_Recipient_3__c';         

    // Opportunity Stage Name
    public static final String CLOSED_WON = '7a. Closed Won';
    public static final String IN_HAND = 'In-Hand';
    public static final String FINALIZING_DEAL_STAGE = '5. Finalizing Deal';
    public static final String RECEIVED_ATP_OLI_STAGE = '6. Received ATP/LOI'; 
    
    public static final String SURVEY_RECIPIENT = 'Survey_Recipient_';
    public static final String OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG = 'Selected Opportunity atleast have one Billable Project';
    public static final String SURVEY_HAS_ALREADY_BEEN_CREATED_WITHIN_LAST_6_MONTHS_ERROR_MSG = 'Survey has already been created within last 6 months.';
    public static final String MAIL_BEING_SENT_FOR_MONITORING_PURPOSE = 'This mail is being sent out for monitoring purpose only. Some reocrod\n';
    public static final String INSERTION_WILL_FAIL_DUE_TO_VALIDATIONS = 'insertion will fail due to validations. This does not necessarily mean an error.';
    public static final String SURVEY_CREATED_SUCCESSFULLY = 'Survey created successfully.';
    public static final String INACTIVE_APPROVERS_EXISTS_IN_CLIENT_SAT_APPROVER_GROUP = 'Inactive Approvers Exists in Client Sat Approver Groups';
    public static final String CLIENT_SAT_BATCH_CLONING_ERROR = 'Client Sat Batch cloning error';
    public static final String CLIENT_SAT_SURVEY_INSERTION_FAILED = 'Client Sat Survey Insertion Failed'; 
    public static final String INACTIVE_APPROVERS = 'Inactive Approvers'; 
    public static final String CLIENT_SAT_SURVEY_CREATION_STATUS = 'Client Sat Survey Creation Status'; 
    public static final String RECIPIENT_CREATED_SUCCESSFULLY = 'Recipient created successfully.';
    public static final String CLIENT_SAT_RECIPIENT_CREATION_STATUS = 'Client Sat Survey Recipient Creation Status'; 
    public static final String CLIENT_SAT_RECIPIENT_BATCH_CLONING_ERROR = 'Client Sat Survey Recipient Batch cloning error';
    public static final String RECORD_PENDING_FOR_APPROVAL = 'This record is pending for approval and cannot be edited';
    
    public static final String RECORD_TYPE_PROJECT = 'Project';
    public static final String RECORD_TYPE_ENGAGEMENT = 'Engagement';
    
    public static final Decimal AMOUNT_IN_USD = 400000;
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    public static final String VALIDATION_ERROR = 'Validation Error : ';
    public static final String ERROR_OCCURED_WHILE_PROCESSING_YOUR_REQUEST= 'Error occured while processing your request. ';
    public static final String CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR = 'Error occured: Cannot insert or update Client Sat Survey as the Opportunity stage is not Closed Won or the record is not eligible for survey creation';
    public static final String THERE_SHOULD_BE_ATLEAST_ONE_APPROVER = 'There should be atleast one Approver, Please contact Admin';

    public static final String CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR_FOR_RDS_MANNUAL = 'Error occured: Cannot insert or update Client Sat Survey as the Opportunity stage is not Closed Won,Received ATP/LOI,Finalizing Deal or the record is not eligible for survey creation';
    public static final String ALL = 'ALL'; 

    public static final String ACCEPT = 'ACCEPT'; 
    public static final String ACCEPTED = 'ACCEPTED'; 
    public static final String YES = 'YES';  
        
    public static final String REJECT = 'REJECT'; 
    public static final String REJECTED = 'REJECTED'; 
    public static final String NO = 'NO'; 
    
    public static final String DECLINE_SURVEY_REASSIGN_GROUP_LABEL = 'Decline Survey Reassign Group';
    public static final String NOT_ALLOWED_TO_MODIFY_RECORD = 'You are not allowed to modify this record. Please contact your administrator.';
}