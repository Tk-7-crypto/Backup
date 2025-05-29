public class UTL_TPA  { 

    private static Privacy_Policy_TPA__c settingObject = Privacy_Policy_TPA__c.getOrgDefaults();
    public static String TPA_COMMUNIYTURL = settingObject.TPA_Portal_URL__c;
    public static String docusignAccountId = settingObject.TPA_Docusign_Account_Id__c;
    public static String userId = settingObject.TPA_Docusign_User_Id__c;
    public static String password = settingObject.TPA_Docusign_Password__c;
    public static String integratorsKey = settingObject.TPA_Docusign_Integrator_Key__c;
    public static String webServiceUrl = settingObject.TPA_Docusign_URL__c;
    public static Integer daysToSendReminder = 1;
    public static String TLLATemplateName = settingObject.TLLA_Template_Name__c; 
    public static  String userNameContract = settingObject.ContractUserName__c;
    public  static String passwordContract = settingObject.ContractPassword__c;
    public  static String apiURL = URL.getOrgDomainUrl().toExternalForm() + settingObject.ContractAPIURL__c;
    public  static String helpfulHintsDocLabel = 'TPA Helpful Hints Addendum';

    public static TPA_Settings__c tpaSetting = TPA_Settings__c.getOrgDefaults();
    public static Integer commercialFormPageSize = Integer.ValueOf(tpaSetting.TPA_CommRev_Pagination_Size__c);
    public static String requestSubmissionformURL = tpaSetting.Request_Submission_Form_URL__c;
    public static String cshCommunityLoginURL = tpaSetting.CSH_Community_Login_Url__c;
    public static String orgWideEmailAddress = tpaSetting.TPA_From_Orgwide_Email_Id__c;
    public static String batchEmailAddresses = tpaSetting.TPA_Batch_Mail_Ids__c;
    public static String sharedEmailAddress = tpaSetting.Shared_Email__c;
    public static String DRNEmailCopyAddress = tpaSetting.TPA_DRN_Mails_Copy_To__c;
    public static String TPUSEMailAddress = tpaSetting.TP_US_Mail_Id__c;
    public static String IQVIAClientAMAAdmin = tpaSetting.IQVIA_Client_AMA_Administrator__c;
    public static Boolean isMessageShow = tpaSetting.Is_Show_Message__c;
    public static Boolean isTPAPermanentDown = tpaSetting.Is_TPA_Permanent_Down__c;
    public static Id emailTargetContactId = tpaSetting.TPA_Email_Target_Object__c;
    public static String billingAddressMissOnAccRecipientLst = tpaSetting.billingAddressMissOnAccRecipientLst__c;
    public static String docusignCCEmailList = tpaSetting.TPA_DocuSign_CC_Email_List__c;
    public static String dblContractContactId = tpaSetting.DBL_Contracts_Contact_Id__c;
    public static String dblContractContactEmail = tpaSetting.DBL_Contracts_Contact_Email__c;
    public static String tpaRequestSubmittedEmails = tpaSetting.TPA_RequestSubmitted_Email__c;
    public static String TPA_SITEURL = tpaSetting.Email_Template_Site_URL__c;
    public static Date restrictionDaterForMaintenance = tpaSetting.Restriction_Date_For_Maintenance__c;
    public static String TpaEmailAddress = tpaSetting.TPA_Mail_ID__c;
    public static String TPAQAandAdminEmailAddress = tpaSetting.TPA_QA_and_Admin_Email_Ids__c;
    public static String Tpa50orMoreLicensesEmailIds = tpaSetting.TPA_50_or_More_Licenses_Email_Ids__c;
    public static String ChristineEmailAddress = tpaSetting.Christine_Email_Id__c;
    public static Date NewDDNReqDeploymentDate = tpaSetting.New_DDN_Requirement_Deployment_Date__c;
    public static Boolean includeTestDataOnlyinDDNBatch = tpaSetting.Include_Test_Data_Only_in_DDN_Batch__c;
    public static Boolean includeTestDataOnlyinVendorNotiBatch = tpaSetting.Include_Test_Data_Only_in_VendorNoti_BCH__c;
    public static String TPA_ClientCOM_URL = tpaSetting.TPA_Client_Community_Url__c;
    public static String TPA_AdminEmailID = tpaSetting.TPA_Admin_Email_Address__c;
    public static String TPACloneUseGuide = tpaSetting.TPA_Clone_Use_Guide__c;
    public static String TPNordicsEmailID = tpaSetting.TP_Nordics_Email_ID__c;


    
    public static String customHomePage = '/VFP_TPA_PrivacyNotice';
    public static String tpaVendorProfile = 'TPA Vendor Community User';
    public static Set<String> tpaClientPortalProfiles = New Set<String> {'Super User Profile CCP', 'TPA Customer Community Plus Login User', 'TPA Processor Profile CCP', 'US TP Processor Profile CCP'};


    public static TPA_Settings__c emailSetting = TPA_Settings__c.getInstance();
    public static Boolean isSendOutgoingEmails = emailSetting.TPA_Send_Emails__c;
    public static Boolean modifyRequest = emailSetting.Modify_Agreement_Request__c;
    public static Boolean modifyRequestNonSysAdminUser = emailSetting.Modify_Agreement_If_Not_System_Admin__c;
    public static Boolean modifyAdditionalTerm = emailSetting.Skip_Modify_Additional_Term__c;

    public static List<TPA_AMA_Settings__c> amaSettings = TPA_AMA_Settings__c.getAll().values(); 
    
    public static boolean createActivityHistory = true;
    public static boolean createVendorSelectedActivityHistory = true;

    public static TPA_Functionality_Flags__c tpaFunctionalitySetting = TPA_Functionality_Flags__c.getOrgDefaults();

    public static String TPA_SFDCBASEURL = URL.getOrgDomainUrl().toExternalForm();

    public static Boolean executeDataAssetTrigger = true;
    public static Boolean isEnvelopeVoided = false;
    public static Boolean notificationsTriggerExecuted = false;
    public static Boolean isLegacySystem = true;
    public static Boolean isCancelledBySystem = false;
    public static Boolean modifyRequestForcefully = false;
    public static Boolean isMOUStatusChangeValidationChecked = false;
    public static Boolean isPurposeUpdateCalled = false;
    public static Boolean ClientSubmissionUpdate = false; 
    public static Boolean vendorSubmissionAddObjUpdate = false; 
    public static Boolean vendorSubmissionFirstUpdate = false; 

    public static Map<id, profile> mapProfiles  = new Map<id, profile>();
    public static Map<id, profile> mapTPAProfiles  = new Map<id, profile>();
    public static Map<id, profile> mapVendorProfiles  = new Map<id, profile>();
    public static List<Attachment> tpaAttach = new List<Attachment>();

    public static Boolean allowParentAddressChange = false;
    public static Boolean updateFromPage = false;
    
    public static String standardTermsAndCondDoc = 'STANDARD TERMS AND CONDITIONS'; 
    public static String complianceProgramDoc = 'Compliance Program';
    public static String potentialDenialStatus = 'Potential Denial - Request TP Processor to arrange meeting with IQVIA Legal';
    
    public static string consumerProfilesOfferingName = Label.TPA_Consumer_Profile;
    public static final Integer OFFERING_COUNT = 20;
    
    // Constant for Batch size
    public static final Integer BATCH_SIZE = 200;
    // Schedular string for Agreement Generation Batch
    public static final String SCHEDULAR_STRING_AGREEMENT_GENERATION = '0 00 02 * * ?';
    // Group name for Agreement Generation Batch
    public static final String TPA_PORTAL_AGREEMENT_GENERATION_GROUP = 'TPA_Portal_failed_to_generate_Agreement';

    public static final String VENDOR_CANCELED_21_AMA_TPA_EXP_12_31_20 = 'Vendor Canceled ‘21 AMA-TPA Exp-12/31/20';
    public static final String VENDOR_CANCELED_20_AMA_TPA_EXP_12_31_19 = 'Vendor Canceled ‘20 AMA-TPA Exp-12/31/19';
    public static final String VENDOR_CANCELED_22_AMA_TPA_EXP_12_31_21 = 'Vendor Canceled ‘22 AMA-TPA Exp-12/31/21';
    public static final String VENDOR_CANCELED_23_AMA_TPA_EXP_12_31_22 = 'Vendor Canceled ‘23 AMA-TPA Exp-12/31/22';
    public static final String VENDOR_CANCELED_24_AMA_TPA_EXP_12_31_23 = 'Vendor Canceled ‘24 AMA-TPA Exp 12/31/23';
    public static final String VENDOR_CANCELED_25_AMA_TPA_EXP_12_31_24 = 'Vendor Canceled ‘25 AMA-TPA Exp 12/31/24';
    public static final String VENDOR_CANCELED_26_AMA_TPA_EXP_12_31_25 = 'Vendor Canceled ‘26 AMA-TPA Exp 12/31/25';

    public static final String AWAITING_CLIENT_MODIFICATION = 'Awaiting Client Modification';
    public static final String PENDING_CANCELLATION = 'Pending Cancellation';
    public static final String AWAITING_FINAL_REVIEW = 'Awaiting Final Review';
    public static final String AWAITING_ACCOUNT_MGMT_COMMUNICATION = 'Awaiting Account Mgmt Communication';
    public static final String PENDING_VENDOR_DECLINED_AMA_FEES = 'Pending - Vendor Declined AMA Fees';
    public static final String PENDING_VENDOR_AMA_FEE_ACKNOWLEDGEMENT = 'Pending Vendor AMA Fee Acknowledgement';
    public static final String AWAITING_CLIENT_CONFIRMATION = 'Awaiting Client Acknowledgement';
    public static final String AMA_DISCONTINUED = 'AMA Discontinued';
    public static final String AMA_CANCELLED = 'AMA Cancelled';
    public static final String CLIENT_DISCONTINUED = 'Client Discontinued';
    public static final String INITIALIZING_VENDOR = 'Initializing Vendor';
    public static final String QUINTILESIMS_DENIED = Label.TPA_IQVIA_Denied_Status;
    public static final String SIGNATURE_UNDER_VALIDATION = 'Signature Under Validation';
    public static final String AWAITING_VENDOR_SUBMISSION = 'Awaiting Vendor Submission';
    public static final String IN_REVIEW_BY_IMS = Label.TPA_In_Review_By_IMS_Status;
    public static final String IN_REVIEW_BY_QUINTILESIMS = Label.TPA_In_Review_By_IQVIA_Status;
    public static final String PENDING_VENDOR_RESPONSE_ON_DDN_FROM_PRIOR_TPAs = 'Pending Vendor Response on Data Destruction from Prior TPAs';
    public static final String TPA_APPROVED_AWAITING_AMA_APPROVAL = 'TPA Approved Awaiting AMA Approval';
    public static final String IN_AUTO_APPROVAL_PROCESS = 'In Auto Approval Process';
    public static final String AWAITING_VENDOR_SIGNATURE = 'Awaiting Vendor Signature';
    public static final String IN_EFFECT = 'in effect';
    public static final String EXPIRED = 'expired';
    public static final Integer YEAR_2019 = 2019;
    public static final String AWAITING_VENDOR_RESPONSE_FOR_OFFSHORE_PROCESS = 'Awaiting Vendor Response: AMA Offshore Consent form has been sent to Vendor';
    public static final String VENDOR_COMPLETED_AMA_OFFSHORE_PROCESS = 'Vendor completed AMA Offshore Consent with Pre-Approved IT Technologies: Regenerate agreements';
    public static final String AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS = 'Awaiting AMA Response: Offshore Consent form requires AMA review/approval';
    public static final String AMA_APPROVED_OFFSHORE_PROCESS = 'AMA Approved Offshore Consent: Verify AMA Child Record regenerate agreements';
    public static final String AMA_DENIED_OFFSHORE_PROCESS = 'AMA Responded: AMA Offshore Consent form has been Denied';
    public static final String AMA_ADDITIONAL_QUESTIONS_FOR_OFFSHORE_PROCESS = 'AMA Responded: AMA has Additional Questions';
    public static final String AMA_RESPONSE_APPROVED = 'Offshore Consent request approved';
    public static final String AMA_RESPONSE_ADDITIONAL_QUESTIONS = 'Additional questions for Vendor requested by AMA';
    public static final String AMA_RESPONSE_NOT_APPROVED = 'Offshore request not approved by AMA';
    public static final String VENDOR_SELECTED_NON_APPROVED_AMA_LOCATION = 'Vendor selected non-approved AMA location - AMA Offshore Consent form has not been sent to Vendor';
    public static final String INVOICE_MAIL_SUBJECT = 'Email: '+Label.TPA_IQVIA_Keyword+' Invoice will be sent to vendorLegalName Payment';
    public static final String DBL_EXECUTED_MAIL_SUBJECT = 'Email: Signed AMA Agreement associated with tpaRequestNo vendorLegalName and clientName';
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String DBL_Val_IQVIA = 'IQVIA';
    public static final String TPA_AMA_Calculate_fee_if_vendor_has_not_reached_maxed_fees = 'Calculate Fee if vendor has not reached ‘Maxed Fees’';
    public static final String TPA_AMA_Calculate_Fee = 'Calculate Fee';
    public static final String TPA_AMA_No_Fee = 'No Fee';
    public static final String TPA_AMA_Calculate_Fee_For_Nex_Year_Only = 'Calculate Fee For Next Year Only';
    public static final String TPA_COMPLETED_KEYWORD = '_Completed';
    public static final String SpecialUseEngArch = 'engineering/system architecture';
    public static final String Pending_Client_Acknowledgements = 'Pending Client Acknowledgements';
    public static final String CLIENTS_AMA_AGREEMENT_IS_EXPIRED = 'Client\'s ama agreement is expired';
    public static final String CLIENT_DOES_NOT_HAVE_AMA_AGREEMENT = 'Client does not have an AMA agreement';
    public static final String Expert_Analysis_for_Legal_or_Governmental_Purposes_Selected = 'IQVIA Use of Expert Analysis for Legal or Governmental Purposes Selected';

    public static Boolean isSecondaryReviewUpdate = false;
    
    public static final Map<String, String> commercialReviewViewMode = new Map<String,String>{
        'CSubmit' =>'Commercial Owner',
            'SCSubmit' =>'Vendor - Use Secondary Review by;Offering Requires Secondary Commercial Review;Vendor - Use - Offering Secondary Review by',
            'TPSubmit' =>'TP-Country',            
            'TPUS' => 'TP-US',
            'MGMT'=>'Management',
            'LGL' => 'Legal'
            };
			
	public static Map<String, String> OfferingMapForAddText = new Map<String, String> {
        'APLD Study Data Source: Institutional Claims' => 'APLD Study Data Source: Institutional Claims (Hx)',
        'Consumer Profiles Patient as Consumer Custom Study Name & Project Delivery Date:' => 'Consumer Profiles [Patient as Consumer] Custom Study Name & Project Delivery Date:',
        'Promotional Response ROI Custom Study Name & Project Delivery Date:' => 'Promotional Response (ROI) Custom Study Name & Project Delivery Date:',
        'APLD Custom Study Name & Project Delivery Date:' => 'APLD Custom Study Name & Project Delivery Date:',
        'STI Data - Custom Report Name' => 'STI Data - Custom Report Name',
        'Longitudinal Patient Diagnosis' => 'Longitudinal Patient Diagnosis',
        'Nostradata Source of Business LRx' => 'Nostradata Source of Business (LRx)',
        'CH-Retail Profits' => 'CH-Retail Profits',
        'CH-Other Outlet Profits' => 'CH-Other Outlet Profits',
        'CH-Hospital Profits' => 'CH-Hospital Profits',
        'CH Combined Hos and Ret Profit AU' => 'CH Combined Hos and Ret Profit AU',
        'PharMetrics® Plus Health Plan Claims' => 'PharMetrics® Plus (Health Plan Claims)',
        'LAAD - Longitudinal Access and Adjudication Data' => 'LAAD - Longitudinal Access and Adjudication Data',
        'Payer Companion File' => 'Payer Companion File',
        'Provider Companion File' => 'Provider Companion File',
        'Patient Reference File' => 'Patient Reference File',
        'CWH NZ Scan data' => 'CWH NZ Scan data',
        'Customized IQVIA Data - Specify name of Customized Data will be shared:' => 'Customized IQVIA Data - Specify name of Customized Data will be shared:',
        'BrandImpact Custom Study Name & Project Delivery Date:' => 'BrandImpact Custom Study Name & Project Delivery Date:',
        'Channel Dynamics Custom Study Name & Project Delivery Date:' => 'Channel Dynamics Custom Study Name & Project Delivery Date:',
        'ProVoice Custom Study Name & Project Delivery Date:' => 'ProVoice Custom Study Name & Project Delivery Date:',
        'Pharmacy Scan' => 'Pharmacy Scan',
        'Combined Hos and Ret Profit AU' => 'Combined Hos and Ret Profit AU',
        'AU Other Outlet Data Profits' => 'AU Other Outlet Data Profits',
        'AU DDD Hospital Profits' => 'AU DDD Hospital Profits',
        'Nostradata LRx - Volume' => 'Nostradata LRx - Volume',
        'Nostradata Source of Business LRx'=> 'Nostradata Source of Business (LRx)',
        'AU Profits' => 'AU Profits',
        'STI Data Custom Report Name:' => 'STI Data Custom Report Name:',
        'Data Niche Associates DNA Medicaid Data: OutlierView Labeler Codes:' => 'Data Niche Associates (DNA) Medicaid Data: OutlierView Labeler Codes:',
        'APLD Study Data Source: Medical Claims Data' => 'APLD Study Data Source: Medical Claims Data (Dx)',
        'APLD Study Data Source: Longitudinal Prescription Data'=> 'APLD Study Data Source: Longitudinal Prescription Data (LRx)',
        'APLD Study Data Source: Institutional Claims' => 'APLD Study Data Source: Institutional Claims (Hx)',
        'APLD Study Data Source: Charge Data Master' => 'APLD Study Data Source: Charge Data Master™ (CDM)',
        'APLD Study Data Source: Remittance Data Remit' => 'APLD Study Data Source: Remittance Data (Remit)',
        'APLD Study Data Source: Patient Companion File PatCo - Formerly Patient Reference Fil' => 'APLD Study Data Source: Patient Companion File (PatCo) - Formerly Patient Reference Fil',
        'APLD Study Data Source: PharMetrics® Plus Health Plan Claims' => 'APLD Study Data Source: PharMetrics® Plus (Health Plan Claims)',
        'APLD Study Data Source: Ambulatory EMR' => 'APLD Study Data Source: Ambulatory EMR',
        'APLD Study Data Source: Oncology EMR'=> 'APLD Study Data Source: Oncology EMR'
    };		
			

    // to store contract type to validate the client in AMA process
    public static final Set<String> clientValidateLicenses = new Set<String> {
                                                                'biotech firm',
                                                                'commercial market research',
                                                                'emerging market pharmaceutical',
                                                                'healthcare provider',
                                                                'limited medical device equipment & supply',
                                                                'medical/diagnostic equipment & supply',
                                                                'otc pharmaceutical',
                                                                'pharmacy',
                                                                'pharmacy - wholesaler',
                                                                'pharmacy ad hoc',
                                                                'pharmacy benefit manager',
                                                                'retail pharmacy',
                                                                'rx pharmaceutical',
                                                                //'start up i - pharmaceutical',
                                                                //'start up ii - pharmaceutical',
                                                                'Start Up - Pharmaceutical',
                                                                'subcontractor-customer',
                                                                'susc',
                                                                'website operations',
                                                                'dr. finder website',
                                                                'physician authentication',
                                                                'healthcare provider - limited',
                                                                'pre-commercial',
                                                                'emerging market - mid',
                                                                'emerging market - large',
                                                                'psa - service bureau'
                                                            };
    public static Boolean Inserted_To_AMA_Data = false;
    public static Boolean DBL_Notification_Mail_Sent = false;
    
    public static final Set<String> templateContractTypes = new Set<String> {

                                                            'Lettershop',
                                                            'Service Bureau I',
                                                            'Service Bureau II',
                                                            'Contract Sales Force',
                                                            'SB I Evaluation Overlap for Amgen',
                                                            'CSF Amendment',
                                                            'SBII Amendment',
                                                            'LS ExUS Entity Foreign License',
                                                            'SBI ExUS Entity Foreign License',
                                                            'SBII ExUS Entity Foreign License' 
                                                        };

    public static final Set<String> lettershopUses = new Set<String> {
                                                        'packaging',
                                                        'personalized letters',
                                                        'printing',
                                                        'assembly',
                                                        'inserting',
                                                        'prescriber recruitment',
                                                        'telemarketing',
                                                        'labeling',
                                                        'distribution and mailing',
                                                        'email broadcasting',
                                                        'market research projects that include prescriber perception and attitude studies',
                                                        'positioning and messaging studies',
                                                        'analysis of market research results',
                                                        'focus groups'
                                                    };


    public static final Set<String> lettershopOtherUses = new Set<String> {
                                                        'Prescriber List Match only for overlap analysis, no prescriber communication'
                                                    };


    public static final Set<String> csfUses = new Set<String> {
                                                    'provide a supplemental sales force'
                                                };
                                               
    // contstant other uses for CSF Contract Type
    public static final Set<String> csfOtherUses = new Set<String> {
                                                        'sales reporting',
                                                        'call reporting / planning',
                                                        'maintain data for reporting or archiving',
                                                        'sample fulfillment / distribution'
                                                    };
                                                      
    // contstant uses for SBI Contract Type
    public static final Set<String> SBIUses = new Set<String> {
                                                    'prescriber list match only for overlap analysis, no prescriber communication',
                                                    'production of reports',
                                                    'statistical analysis',
                                                    'technical support',
                                                    'market forecasting',
                                                    'market opportunity assessment and sizing',
                                                    'market segmentation and situation analysis',
                                                    'territory alignment',
                                                    'targeting reports',
                                                    'tele-detailing',
                                                    'e-detailing'
                                                };

    // contstant uses for SBII Contract Type
    public static final Set<String> SBIIUsesDueToFrequencyAndUse = new Set<String> {
                                                                        'prescriber list match only for overlap analysis, no prescriber communication',
                                                                        'market forecasting',
                                                                        'market opportunity assessment and sizing',
                                                                        'market segmentation and situation analysis',
                                                                        'territory alignment',
                                                                        'targeting reports',
                                                                        'tele-detailing',
                                                                        'production of reports',
                                                                        'statistical analysis',
                                                                        'technical support',
                                                                        'e-detailing',
                                                                        'sales reporting',
                                                                        'maintain data for reporting or archiving',
                                                                        'banner ads',
                                                                        'call reporting / planning',
                                                                        'salesforce automation',
                                                                        'incentive compensation',
                                                                        'prescriber authentication / verification',
                                                                        'sample fulfillment / distribution'
                                                                    };

    // contstant uses for SBII Contract Type
    public static final Set<String> SBIIUsesDueToUse = new Set<String> {
                                                            'salesforce automation',
                                                            'prescriber authentication / verification',
                                                            'sample fulfillment / distribution',
                                                            'call reporting / planning',
                                                            'incentive compensation' ,
                                                            'sales reporting',
                                                            'maintain data for reporting or archiving',
                                                            'banner ads'
                                                        };
                                                        
    public static final Set<String> SBIIUseslessThan90  = new Set<String> {
                                                                    'salesforce automation',
                                                                    'prescriber authentication / verification',
                                                                    'sample fulfillment / distribution',
                                                                    'call reporting / planning',
                                                                    'incentive compensation',
                                                                    'sales reporting',
                                                                    'maintain data for reporting or archiving',
                                                                    'banner ads'
                                                                };

    // contstant uses for SBII Contract Type
    public static final Set<String> SBIIUsesGreaterThan90 = new Set<String> {
                                                                'packaging',
                                                                'personalized letters',
                                                                'printing',
                                                                'assembly',
                                                                'inserting',
                                                                'prescriber recruitment',
                                                                'telemarketing',
                                                                'labeling',
                                                                'distribution and mailing',
                                                                'email broadcasting',
                                                                'market research projects that include prescriber perception and attitude studies',
                                                                'positioning and messaging studies',
                                                                'analysis of market research results',
                                                                'focus groups',
                                                                'sales reporting',
                                                                'prescriber list match only for overlap analysis, no prescriber communication',
                                                                'production of reports',
                                                                'statistical analysis',
                                                                'technical support',
                                                                'market forecasting',
                                                                'market opportunity assessment and sizing',
                                                                'market segmentation and situation analysis',
                                                                'territory alignment',
                                                                'targeting reports',
                                                                'tele-detailing',
                                                                'e-detailing',
                                                                'salesforce automation',
                                                                'prescriber authentication / verification',
                                                                'sample fulfillment / distribution',
                                                                'call reporting / planning',
                                                                'incentive compensation',
                                                                'maintain data for reporting or archiving',
                                                                'banner ads'
                                                            };

    public static final Set<String> specialContractTypes = new Set<String> {

                                                            'medical/diagnostic equipment & supply',
                                                            'physician specific analysis',
                                                            'physician specific analytics'
                                                        };

    public static final Set<String> offshoreCountries = new Set<String>{
                                    'canada',
                                    'belgium',
                                    'brazil',
                                    'croatia',
                                    'denmark',
                                    'france',
                                    'germany',
                                    'india',
                                    'israel',
                                    'italy',
                                    'japan',
                                    'lithuania',
                                    'mexico',
                                    'norway',
                                    'ireland',
                                    'spain',
                                    'sweden',
                                    'switzerland',
                                    'netherlands',
                                    'united kingdom',
                                    'united states',
                                    'costa rica',
                                    'philippines',
                                    'singapore'
                                };

    public static final Set<String> SBIICondition30to32UsesListA = new Set<String> {
                                                                        'prescriber list match only for overlap analysis, no prescriber communication',
                                                                        'market forecasting',
                                                                        'market opportunity assessment and sizing',
                                                                        'market segmentation and situation analysis',
                                                                        'territory alignment',
                                                                        'targeting reports',
                                                                        'tele-detailing',
                                                                        'production of reports',
                                                                        'statistical analysis',
                                                                        'technical support',
                                                                        'e-detailing'
                                                                    };
                                                                    
    public static final Set<String> SBIICondition30to32UsesListB = new Set<String> {
                                                                        'sales reporting',
                                                                        'maintain data for reporting or archiving',
                                                                        'banner ads',
                                                                        'call reporting / planning',
                                                                        'salesforce automation',
                                                                        'incentive compensation',
                                                                        'prescriber authentication / verification',
                                                                        'sample fulfillment / distribution'
                                                                    };

    public static final Set<String> SBIICondition60to65UsesSet = new Set<String> {
                                    'prescriber list match only for overlap analysis, no prescriber communication',
                                    'market forecasting',
                                    'market opportunity assessment and sizing',
                                    'market segmentation and situation analysis',
                                    'territory alignment',
                                    'targeting reports',
                                    'tele-detailing',
                                    'production of reports',
                                    'statistical analysis',
                                    'technical support',
                                    'e-detailing'
                                };

    public static Set<String> clientFieldSet = new Set<String>{
        'Client_Address__r.TPA_Address_Country__c'
    };

    public static Set<String> amaAgreementFieldSet = new Set<String>{
        'AMA_USPrescriberData__c'
    };

    public static Set<String> regionCountryfieldSet = new Set<String>{'TP_Processor__r.region__c',
                    'TP_Processor__r.TP_Processor_Name__c',
                    'TP_Processor__r.TPA_Processor_Contact__c',
                    'TP_Processor__r.TPA_Processor_Contact__r.accountid',
                    'TP_Processor__r.TP_Processor_Email__c'
                };

    public static User currentUser;
    /**
     *  Method will return the current logged in user details.
     */
    public static User getCurrentUserDetails() {
        if(currentUser == null) {
            currentUser = [select Name,
                                Email,
                                User_Country__c,
                                TimeZoneSidKey,
                                CompanyName,
                                TPA_Is_Privacy_Policy_Agreed__c,
                                TPA_Is_Show_TPA_Down_Message__c,
                                UserName,
                                ContactId,
                                Contact.Email,
                                Contact.Phone,
                                Contact.MailingCountry,
                                Contact.MailingPostalCode,
                                Contact.MailingState,
                                Contact.MailingCity,
                                Contact.MailingStreet,
                                Contact.Name,
                                Contact.Salutation,
                                Contact.Title,
                                Contact.Client_Contact_Territory__c,
                                Contact.TPA_Last_Selected_Language__c,
                                Contact.AccountId,
                                Contact.Account.AccountCountry__c,
                                Contact.Account.Region_Territory__c,
                                Contact.Account.Name,
                                Profile.Name,
                                Profile.UserLicense.Name,
                                (SELECT AssigneeId , PermissionSet.Label FROM PermissionSetAssignments)
                            from User
                            where Id =: UserInfo.getUserId()] ;
        }
        system.debug('UTL_TPA.getUserDetails: ' + currentUser);
        return currentUser;
    }
    
    public static Boolean isUserTPASuperAdmin(){
        for(PermissionSetAssignment permSetAssign: UTL_TPA.getCurrentUserDetails().PermissionSetAssignments){
            if(permSetAssign.PermissionSet.Label == 'TPA Super Admin'){
                return true;
            }
        }
        return false;
    }

    public static String getNewReviewReason(String oldReason){
        if(oldReason != null && oldReason == 'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested'){
            return 'IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested';
        }
        else if(oldReason != null && oldReason == 'IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed'){
            return 'IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested';
        }
        else if(oldReason != null && oldReason == 'Renewal has "Additional Term(s) Added" and/or "Exhibit Page Added" in prior TLLA'){
            return 'Renewal includes an Ad-hoc Additional Term and, if applicable, an Exhibit / Schedule Page from the prior TLLA';
        }
        return '';
    }

    public static Boolean isManualReviewAddHoc(String manualRev){
        if(manualRev == 'IQVIA Legal Approval Required: [New] TPA: Ad-hoc Additional Term Requested' || manualRev == 'IQVIA Legal Approval Required: [Renew] TPA: Ad-hoc Additional Term Requested' 
        || manualRev == 'IQVIA Legal Approval Required: Prior TLLA had an Additional Term and/or Exhibit added and to be Renewed' || manualRev == 'IQVIA Legal Approval Required: New TPA - Ad-hoc Additional Term(s) / Exhibit Page(s) Requested'){
            return true;
        }
        return false;
    }

    public static Id AddressId;
    public static Id getAddressId(Id contactId) {
        if(AddressId == null) {
           AddressId = [select id
                             from Address__c 
                             where id =:[select Address__c from Contact_Address_Crosswalk__c where Contact__c = :contactId limit 1].Address__c
                            ].id ;
        }
        system.debug('UTL_TPA.getCurrentAddressDetails: ' + AddressId);
        return AddressId;
    }

    public static List<String> setAddressIds = new List<String>();
    public static List<String> getAddressIds(Id contactId) {
        if(setAddressIds == null || setAddressIds.size() == 0) {
            List<Contact_Address_Crosswalk__c> contactAddressCrosswalkList = new List<Contact_Address_Crosswalk__c>();
            contactAddressCrosswalkList = [select Id,Name,Contact__c,Address__c,Address__r.Id from Contact_Address_Crosswalk__c where Contact__c = :contactId];
            for(Contact_Address_Crosswalk__c contactAddressCrosswalk : contactAddressCrosswalkList){
                if(contactAddressCrosswalk.Address__r.Id != null){
                    setAddressIds.add(contactAddressCrosswalk.Address__r.Id);
                }
            }
        }
        system.debug('UTL_TPA.getAllAddressDetails: ' + setAddressIds);
        return setAddressIds;
    }
    
    public static Map<string, string> savePoints {
        get {
            if(savePoints == null) {
                savePoints = new Map<string, string>();
                savePoints.Put('1S', 'New Request Created By Client Start');
                savePoints.Put('1E', 'New Request Created By Client End');
                savePoints.Put('2S', 'New Request Created By US TP Processor Start');
                savePoints.Put('2E', 'New Request Created By US TP Processor End');
                savePoints.Put('3S', 'Request Edited By Client Start');
                savePoints.Put('3E', 'Request Edited By Client End');
                savePoints.Put('4S', 'Request Edited By TP Processor Start');
                savePoints.Put('4E', 'Request Edited By TP Processor End');
                savePoints.Put('5S', 'Request Submited By Vendor Start');
                savePoints.Put('5E', 'Request Submited By Vendor End');
                savePoints.Put('6S', 'Request Cloned By Client Start');
                savePoints.Put('6E', 'Request Cloned By Client End');
                savePoints.Put('7S', 'Request Cloned By US TP Processor Start');
                savePoints.Put('7E', 'Request Cloned By US TP Processor End');
                savePoints.Put('8S', 'Request Renewed By Client Start');
                savePoints.Put('8E', 'Request Renewed By Client End');
                savePoints.Put('9S', 'Request Renewed By US TP Processor Start');
                savePoints.Put('9E', 'Request Renewed By US TP Processor End');
            }
            return savePoints;
        }
        private set;
    }
    
    // Property to get Org Company Information
    public static Organization orgCompanyInformation {
        get{
            if(orgCompanyInformation == null) {
                orgCompanyInformation = [SELECT ID, IsSandbox FROM Organization LIMIT 1];
            }
            return orgCompanyInformation;
        }
        set;
    }
    
    // Property to check if current org is a Sandbox org or not
    public static Boolean isSandboxOrg {
        get{
            return orgCompanyInformation.IsSandbox;
        }
        set;
    }

    public static String createAddHocKey(TPA_Additional_Term__c addHocRecord){
        if(addHocRecord == null){
            return '';
        }
        String keyToReturn = '';
        keyToReturn += UTL_Validate.isEmptyOrNull(addHocRecord.Term_Name__c) ? '' :  addHocRecord.Term_Name__c;
        keyToReturn += UTL_Validate.isEmptyOrNull(addHocRecord.TPA_Legal_Entity_1__c) ? ';' :  (addHocRecord.TPA_Legal_Entity_1__c + ';');
        keyToReturn += UTL_Validate.isEmptyOrNull(addHocRecord.Category__c) ? ';' :  (addHocRecord.Category__c + ';');

        return keyToReturn;
    }

    public static Profile getCurrentUserProfileInfo() {
        return [select id, Name from profile where id =: Userinfo.getProfileId()];
    }

    // ESPSFDCTPA-2402
    public static List<String> getIdOfMembersOfGroup(){
        List<String> groupMembersId = new List<String>();
        String tpaGlobalGroupId = tpaSetting.TPA_Global_User_Group_ID__c;
        List<GroupMember> groupMembers= new List<GroupMember>([select UserOrGroupId from GroupMember where groupId =: tpaGlobalGroupId]);
        for(GroupMember groupUser : groupMembers){
            groupMembersId.add(groupUser.UserOrGroupId);
        }
        return groupMembersId;
    }  // end ESPSFDCTPA-2402

    public static List<String> getIdsOfQueue(){
        List<String> queueIds = new List<String>();
        List<Group> listOfGroup = [SELECT Id, DeveloperName,Name  FROM Group where id in (SELECT GroupId FROM GroupMember WHERE Group.Type = 'Queue' and UserOrGroupId = :UserInfo.getUserId())];
        for(Group queueDetail : listOfGroup){
            queueIds.add(queueDetail.Id);
        }
        return queueIds;
    }

    public static boolean isvalidPhone(String phone)
    {
        system.debug('@@@@@@@@@@@@@@@' + phone);
        if(phone.containsAny('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Phone : Invalid Phone number'));
                return false;
            }
        return true;
    }
    
    public static Map<id, profile> getPortalProfileMap(){
        if(mapProfiles.size() <= 0 )
        {
            mapProfiles = new Map<id, profile>([select id,name from profile where name ='TPA Customer Community Plus Login User']);
        }
        return mapProfiles;
    }

    public static Map<Id, Profile> getVendorProfileMap() {
        if(mapVendorProfiles.size() <= 0 ) {
            mapVendorProfiles = new Map<id, profile>([select id,name from profile where name ='TPA Vendor Community User']);
        }
        return mapVendorProfiles;
    }
    
    public static Map<id, profile> getTPAProfileMap(){
        if(mapTPAProfiles.size() <= 0 )
        {
            mapTPAProfiles = new Map<id, profile>([select id,name from profile where Name in ('Super User Profile', 'Super User Profile CCP', 'TPA Processor Profile', 'TPA Processor Profile CCP', 'US TP Processor Profile', 'US TP Processor Profile CCP', 'TPA Customer Community Plus Login User')]);
        }
        return mapTPAProfiles;
    }

    public static void sendCompetitiveMail(String whatId)
    {
        List<String> toAddresses = new List<String>();
        if(UTL_TPA.ChristineEmailAddress != null && UTL_TPA.ChristineEmailAddress != '') {
            toAddresses.add(UTL_TPA.ChristineEmailAddress);
        }

        List<String> ccAddresses = new List<String>();
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(UTL_TPA.TpaEmailAddress != null && UTL_TPA.TpaEmailAddress != '') {
            for(String emailToCc: UTL_TPA.TpaEmailAddress.split(';')) {
                ccAddresses.add(emailToCc);
            }
        }
        
        String emailType = 'Email CompetitiveServices';
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', whatId, true, null, null, FALSE, FALSE, null);

    }

    public static void VendorSpecificNotificationSendConfirmationToClient(TPA_Request__c reqObj,String clientEmail)
    {
        
        List<String> toAddresses = new List<String>{ clientEmail };
        List<String> ccAddresses = new List<String>();
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccAddresses.add(UTL_TPA.sharedEmailAddress);
        }
        if(reqObj.TP_Processor_Email__c != null)
            ccAddresses.add(reqObj.TP_Processor_Email__c);
        if(UTL_TPA.DRNEmailCopyAddress != null) {
            for(String emailToCc: UTL_TPA.DRNEmailCopyAddress.split(',')) {
                ccAddresses.add(emailToCc);
            }
        }

        List<Attachment> lstAttachment = [select Id, Name,Body from Attachment where ParentId =: reqObj.Id and Name like '%Offerings Notification Client%.pdf' order by LastModifiedDate Desc limit 1];
        
        SRV_TPA_TPARequest.updateActivityHistory(reqObj.id, 'Vendor-Specific Notification: Client Contact Notification Email Sent', true);
        String emailType = 'VSN Client Contact Notification';
        SRV_TPA_TPARequest.sendTPANotifications(toAddresses, ccAddresses, emailType, 'English', reqObj.id, true, lstAttachment, null, FALSE, FALSE, null);

    }

     
    //Method to make first character of every word capital in any string
    public static String capitalizeWords(String input) {
        String output = '';
        Matcher m = Pattern.compile('(\\w+|\\W+)').matcher(input);
        while (m.find()) {
            if(m.group().substring(0,1).toUpperCase() != m.group().substring(0,1)) {
                output += m.group().capitalize();
            }
        }
        return output;
    }

    /**
    * Get all the Contact_Address_Crosswalk__c records for a contact by Contact Id. 
    * @param: Contact Id
    * @return: List of Contact_Address_Crosswalk__c records
    */
    public static List<Contact_Address_Crosswalk__c> getContactAddressCrowalk(String contactId) {
        List<Contact_Address_Crosswalk__c> contactAddressCrosswalkList = [SELECT Id, 
                                                                                Address__c, 
                                                                                Address__r.Name,
                                                                                Address__r.TPA_Address_Street__c,
                                                                                Address__r.TPA_Address_City__c,
                                                                                Address__r.TPA_Address_State__c,
                                                                                Address__r.TPA_Address_Country__c,
                                                                                Address__r.Region_Territory__c,
                                                                                Address__r.TPA_Address_PostalCode__c,
                                                                                Address__r.Street__c,
                                                                                Address__r.City__c,
                                                                                Address__r.Country__c,
                                                                                Contact__c
                                                                            FROM Contact_Address_Crosswalk__c
                                                                            WHERE Contact__c =: contactId];
        return contactAddressCrosswalkList;
    }
    public static Id globalBrandingVendorId;
    public static Id getGlobalBrandingVendorId(TPA_Request__c reqObj){
        if(globalBrandingVendorId == null && reqObj.Service_Provider_Address__c != null && reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
            globalBrandingVendorId = reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c;
        }
        return globalBrandingVendorId;
    }

    
    public static Map<String,TPA_Assigned_TP_Processor__c> temporaryDetailsWithOff;
    public static Map<String,TPA_Assigned_TP_Processor__c> getTemporaryDetailsWithOff(){
        if(temporaryDetailsWithOff == null || temporaryDetailsWithOff.size() == 0){
            Date todayDate = System.now().date();
            List<TPA_Assigned_TP_Processor__c> assignTPProList = [select id,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c,Offering_Names__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_Start_Date__c <= :todayDate and Out_of_Office_Leave_End_Date__c >=  :todayDate];
            system.debug('assignTPProList: ' + assignTPProList);
            temporaryDetailsWithOff = new Map<String,TPA_Assigned_TP_Processor__c>();
            for(TPA_Assigned_TP_Processor__c obj :assignTPProList){
                List<String> offList = new List<String>();
                if(obj.Offering_Names__c != null && obj.Offering_Names__c != ''){
                    obj.Offering_Names__c = obj.Offering_Names__c.removeEnd(';');
                    offList = obj.Offering_Names__c.split(';');
                }
                if(offList != null && offList.size() > 0){
                    for(String offName : offList){
                        String finalOffNAme = offName;
                        if(offName.contains('->')){
                            finalOffNAme = (offName.split('->'))[1];
                        }
                        temporaryDetailsWithOff.put(obj.Commercial_Owner_Email__c.toLowerCase() + '~' + finalOffNAme, obj);

                    }
                }
                else{
                    temporaryDetailsWithOff.put(obj.Commercial_Owner_Email__c.toLowerCase(), obj);
                }
            }
        }
        return temporaryDetailsWithOff;
    }

    public static Map<String,TPA_Assigned_TP_Processor__c> temporaryComOwnerMapWithOff;
    public static Map<String,TPA_Assigned_TP_Processor__c> getTemporaryComOwnerMapWithOff(){
        if(temporaryComOwnerMapWithOff == null || temporaryComOwnerMapWithOff.size() == 0){
            Date todayDate = System.now().date();
            List<TPA_Assigned_TP_Processor__c> assignTPProList = [select id,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c,Offering_Names__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_End_Date__c >= :todayDate];
            system.debug('assignTPProList: ' + assignTPProList);
            temporaryComOwnerMapWithOff = new Map<String,TPA_Assigned_TP_Processor__c>();
            for(TPA_Assigned_TP_Processor__c obj :assignTPProList){
                List<String> offList = new List<String>();
                if(obj.Offering_Names__c != null && obj.Offering_Names__c != ''){
                    obj.Offering_Names__c = obj.Offering_Names__c.removeEnd(';');
                    offList = obj.Offering_Names__c.split(';');
                }
                if(offList != null && offList.size() > 0){
                    for(String offName : offList){
                        String finalOffNAme = offName;
                        if(offName.contains('->')){
                            finalOffNAme = (offName.split('->'))[1];
                        }
                        temporaryComOwnerMapWithOff.put(obj.Commercial_Owner_Email__c.toLowerCase() + '~' + finalOffNAme, obj);

                    }
                }
                else{
                    temporaryComOwnerMapWithOff.put(obj.Commercial_Owner_Email__c.toLowerCase(), obj);
                }
            }
        }
        return temporaryComOwnerMapWithOff;
    }

    public static Map<String,TPA_Assigned_TP_Processor__c> temporaryComOwnerMapDetails;
    public static Map<String,TPA_Assigned_TP_Processor__c> getTemporaryComOwnerDetails(){
        if(temporaryComOwnerMapDetails == null || temporaryComOwnerMapDetails.size() == 0){
            Date todayDate = System.now().date();
            List<TPA_Assigned_TP_Processor__c> assignTPProList = [select id,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_End_Date__c >= :todayDate];
            temporaryComOwnerMapDetails = new Map<String,TPA_Assigned_TP_Processor__c>();
            for(TPA_Assigned_TP_Processor__c obj :assignTPProList){
                temporaryComOwnerMapDetails.put(obj.Commercial_Owner_Email__c.toLowerCase(), obj);
            }
        }
        return temporaryComOwnerMapDetails;
    }

    public static List<TPA_Assigned_TP_Processor__c> temporaryComOwnerListDetails;
    public static List<TPA_Assigned_TP_Processor__c> getTemporaryComOwnerListDetails(){
        if(temporaryComOwnerListDetails == null || temporaryComOwnerListDetails.size() == 0){
            Date todayDate = System.now().date();
            List<TPA_Assigned_TP_Processor__c> assignTPProList = [select id, Secondary_Offering_Names__c, Primary_Offering_Names__c, Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_End_Date__c >= :todayDate];
            temporaryComOwnerListDetails = assignTPProList;
        }
        return temporaryComOwnerListDetails;
    }

    public static set<id> getFamilyIds(id parId){
            Map<ID, Address__c> addMap = new Map<ID, Address__c>([SELECT Id, Parent_Vendor_Name__c
                                                             FROM Address__c where (Parent_Vendor_Name__c = :parId or id = :parId) 
                                                             and Is_TPA_Account__c = true]);                                             
                                                             
            return addMap.keySet();                                            
    }

    public static boolean isRelatedToSameFamily(Id parId, Id childId){
        List<Address__c> addressList = [SELECT Id, 
                                            Parent_Vendor_Name__c
                                            FROM Address__c
                                            WHERE Id =: childId AND Parent_Vendor_Name__c = :parId];
                                            
        if(addressList != null && addressList.size() > 0) {
            return true;
        }
        return false;
    }

    public static void updateEntryInClientVendorSrchMap(id vendorId, String searchText){
        system.debug('vendorId: ' + vendorId + '::: searchText:' + searchText);
        List<TPA_AMA_Client_Vendor_Search_Map__c> searchMapList = [Select id, AMA_Account_Search_Text__c, 
                                    TPA_Account_Address__c, TPA_Account_Address__r.id From TPA_AMA_Client_Vendor_Search_Map__c 
                                    where AMA_Account_Search_Text__c = :searchText];
                                   
        TPA_AMA_Client_Vendor_Search_Map__c obj ;                           
        if(searchMapList != null && searchMapList.size() > 0){
            if(searchMapList[0].TPA_Account_Address__r.id == vendorId){
                return ;
            }
            else if(isRelatedToSameFamily(vendorId, searchMapList[0].TPA_Account_Address__r.id)) {
                obj = new TPA_AMA_Client_Vendor_Search_Map__c(id = searchMapList[0].id, TPA_Account_Address__c = vendorId);
            }
        }
        else{
            obj = new TPA_AMA_Client_Vendor_Search_Map__c(TPA_Account_Address__c = vendorId, AMA_Account_Search_Text__c = searchText);
        }
          
        try {
            if(obj != null )
               upsert obj; 
        } catch(Exception e) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::UTL_TPA.updateEntryInClientVendorSrchMap:::TPA_AMA_Client_Vendor_Search_Map__c record insertion Failed', '');
        }
        return; 
    }



    public static List<TPA_Request__c> getDDNAckPendingRequests(string vendorId) {
        List<TPA_Request__c> DDNAckPendingRecords = new List<TPA_Request__c>();
        List<TPA_Master_Extension_Information__c> lstTPAMasExt = [select id, Return_Destruction_Ack_Outstanding__c, DDN_Ack_Pending_Requests__c, TPA_Accounts_Address__c from TPA_Master_Extension_Information__c where TPA_Accounts_Address__c =: vendorId LIMIT 1];
        TPA_Master_Extension_Information__c masterExtRec;
        if(lstTPAMasExt != null && lstTPAMasExt.size() > 0) {
            masterExtRec = lstTPAMasExt[0];
            if(masterExtRec.Return_Destruction_Ack_Outstanding__c && masterExtRec.DDN_Ack_Pending_Requests__c != null){
                List<String> lstOfRequest = masterExtRec.DDN_Ack_Pending_Requests__c.split(', ');
                DDNAckPendingRecords = [Select id, Service_Provider_f__c, Service_Provider_Contact_f__c, 
                                        Vendor_Contact_e_mail__c, name, ClientContact__r.Email 
                                        , Vendor_e_mail__c, Authorized_Signer_Email__c,
                                        (select id, Type__c, Email__c from TPA_Request_Contacts__r) 
                                        from TPA_Request__c 
                                        where name IN : lstOfRequest];
            }
        }
        return DDNAckPendingRecords;
    }

    public static Map<String,Address__C> mapRequestToAddress;
    public static void getRequestToAddressMap(Set<Id> setRequestID){
        if(mapRequestToAddress == null){
            mapRequestToAddress = getRequestToAddress(setRequestID);
        }
    }

    public static Map<String,Address__C> getRequestToAddress(Set<Id> setRequestID){
        Map<String,Address__C> mapRequestToAddress = new Map <String,Address__C>();
        Map<Id,Address__c> mapAddressIdWithRecord = new Map<Id,Address__c>();
        Set<Id> setVendorID = new Set<Id>();
        List<TPA_Request__c> ReqList = [Select Service_Provider_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Primary_Vendor_Address__c from TPA_Request__c where id in: setRequestID];

        for(TPA_Request__c reqObj : ReqList){
            if(reqObj.Service_Provider_Address__c != Null ) {
                setVendorID.add(reqObj.Service_Provider_Address__c);
                if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null && !reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c){
                    setVendorID.add(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c);
                }
                
            }
        }

        mapAddressIdWithRecord = new Map<ID, Address__c>([Select id, (select id, Return_Destruction_Ack_Outstanding__c, DDN_Ack_Pending_Requests__c, On_Hold_TPA_Requests__c from TPA_Master_Extension_Informations__r)
        from Address__c where id IN: setVendorID]);

        if(mapAddressIdWithRecord != null && mapAddressIdWithRecord.size() > 0){
            for(TPA_Request__c reqObj : ReqList){
                if(reqObj.Service_Provider_Address__c != Null ) {
                    mapRequestToAddress.put(reqObj.id + '-localVendor', mapAddressIdWithRecord.get(reqObj.Service_Provider_Address__c));
                    if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null && !reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c){
                        mapRequestToAddress.put(reqObj.id + '-GBVendor', mapAddressIdWithRecord.get(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c));
                    }
                    else {
                        mapRequestToAddress.put(reqObj.id + '-GBVendor', mapAddressIdWithRecord.get(reqObj.Service_Provider_Address__c));
                    }
                    
                }
            }
        }
        
        return mapRequestToAddress;
    }

    public static String createTableFromManualReviews(List<TPA_Commercial_Review__c> comRevs){
        String bodytext = '<br><br><B> Commercial Review Records </B></p>';
        bodytext += '<br><table style="border-collapse: collapse;font-size:13px;font-family:arial;border:2px solid #0CB6F3;"><tr><th colSpan="8" style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Review Records Detail</th></tr>';
        bodytext += '<tr><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Manual Review Reason</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Associated Offering(s) to Review</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Associated Offering(s) Use(s) Requested</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Owner Name</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Date of Review</th><th style="border:2px solid #0CB6F3;font-size:13px;font-family:arial;">Commercial Owner Decision</th></tr>';
                
        for(TPA_Commercial_Review__c comRev: comRevs ){
            if(comRev.Action__c != null && (comRev.Action__c == 'Approved for this specific TPA request'
                || comRev.Action__c == 'Approved for this specific TPA. The Vendor and specified Use(s) and IQVIA Offerings specific combination can be auto-approved moving forward for future requests'
                || comRev.Action__c == System.Label.TPA_Approved_Future_Approved_AdHoc)){
                String reviewDate = '';
                if(comRev.Date_of_Action_Response__c != null){
                    reviewDate = comRev.Date_of_Action_Response__c.format();
                }
                bodytext += '<tr><td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Manual_Review_Reason__c != null ? comRev.Manual_Review_Reason__c : '') + '</td>';
                bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Associated_Offering_to_Review__c != null ? comRev.Associated_Offering_to_Review__c : '') + '</td>';
                bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Associated_Use_to_Review__c != null ? comRev.Associated_Use_to_Review__c : '') + '</td>';
                bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Commercial_Owner_Name__c != null ? comRev.Commercial_Owner_Name__c : '') + '</td>';
                bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + reviewDate  + '</td>';
                bodytext += '<td style="font-size:13px;font-family:arial;border:2px solid #0CB6F3;text-align: center;">' + (comRev.Action__c != null ? comRev.Action__c : '')+ '</td></tr>';
            }
            if(bodytext.length() > 200000){
                SRV_TPA_TPARequest.isSecRevTableRechedMaxLimit = true;
                break;
            }
        }
        bodytext += '</table><br>';
        if(SRV_TPA_TPARequest.isSecRevTableRechedMaxLimit ){
            bodytext = null;
        }
        return bodytext;
    }

    /**
    * Get Address__c record by Address Id. 
    * @param: Address Id
    * @return: Address__c record
    */
    public static Address__c getAddress(String addressId) {
        List<Address__c> addressList = [SELECT Id, 
                                            Name,
                                            TPA_Address_Street__c,
                                            TPA_Address_City__c,
                                            TPA_Address_State__c,
                                            TPA_Address_Country__c,
                                            Street__c,
                                            City__c,
                                            Country__c,
                                            Region_Territory__c
                                        FROM Address__c
                                        WHERE Id =: addressId];
        if(addressList != null && addressList.size() > 0) {
            return addressList[0];
        }
        return null;
    }

    public static Boolean isAmaDoc(String name) {
        if((name.indexOf('foreign license') != -1)){
            if(name.indexOf('exus entity foreign license') != -1){
                return true;
            }
            else{
                return false;
            }
        }
        return true;
    }
    public static Boolean isAmaFLDoc(String name) {
        if((name.indexOf('foreign license') != -1)){
            if(name.indexOf('exus entity foreign license') != -1){
                return false;
            }
            else{
                return true;
            }
        }
        return false;
    }

    public static map<String, TPA_Control_Settings__c> runBatchForTestRecordsMap {
        get {
            if(runBatchForTestRecordsMap == null) {
                runBatchForTestRecordsMap = new map<String, TPA_Control_Settings__c>();
                for(TPA_Control_Settings__c bchRecordObj : TPA_Control_Settings__c.getAll().values()) {
                    runBatchForTestRecordsMap.put(bchRecordObj.Name + ' ' + bchRecordObj.Control_Type__c , bchRecordObj);
                }
            }
            return runBatchForTestRecordsMap;
        }
        private set{runBatchForTestRecordsMap = value;}
    }
    
    public static Boolean runBatchForTestRecords(String bchName) {
        
        if (runBatchForTestRecordsMap != null && runBatchForTestRecordsMap.size() > 0 && runBatchForTestRecordsMap.get(bchName) != null){
            return runBatchForTestRecordsMap.get(bchName).isIncludeTestDataOnly__c;
        }
        else {
            return false;
        }
    }
    
    public static Map<String, Account_Compliance__c> mapTpaClientVendorComplianceDetails;
    public static Map<String, Account_Compliance__c> getTpaClientVendorComplianceDetails(String clientAddressId, String vendorAddressId) {
        if(UTL_Validate.isEmptyOrNull(clientAddressId) || UTL_Validate.isEmptyOrNull(vendorAddressId)) {
            return null;
        }
        else if(mapTpaClientVendorComplianceDetails == null || mapTpaClientVendorComplianceDetails.get('CC'+clientAddressId) == null || mapTpaClientVendorComplianceDetails.get('VC'+vendorAddressId) == null) {
            mapTpaClientVendorComplianceDetails = new Map<String, Account_Compliance__c>();
            Map<String, Address__c> mapTempTpaClientVendorCompDet = new Map<String, Address__c>([Select Id, Name, Account__c, Account__r.Client_Account_Compliance__c, 
                Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold__c, Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Date__c, 
                Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Reason__c, Account__r.Vendor_Account_Compliance__c, Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c, 
                Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Date__c, Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Reason__c, 
                Account__r.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c, Account__r.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c,
                Account__r.ParentId, Account__r.Parent.Client_Account_Compliance__c, Account__r.Parent.Client_Account_Compliance__r.Client_TPA_Compliance_Hold__c, Account__r.Parent.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Date__c, 
                Account__r.Parent.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Reason__c, Account__r.Parent.Vendor_Account_Compliance__c, Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c, 
                Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Date__c, Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Reason__c ,
                Account__r.Parent.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c, Account__r.Parent.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c               
                FROM Address__c WHERE Id =:clientAddressId OR Id =:vendorAddressId]);
            system.debug('mapTempTpaClientVendorCompDet'+mapTempTpaClientVendorCompDet);
            if(mapTempTpaClientVendorCompDet != null) {
                system.debug('clientAddressId'+clientAddressId);
                Address__c clientAddress = mapTempTpaClientVendorCompDet.get(clientAddressId);
                system.debug('clientAddress'+clientAddress);
                if(clientAddress != null && clientAddress.Account__c != null && clientAddress.Account__r.Client_Account_Compliance__c != null) {
                    mapTpaClientVendorComplianceDetails.put('CC-'+clientAddressId, new Account_Compliance__c(Id = clientAddress.Account__r.Client_Account_Compliance__c, 
                        Client_TPA_Compliance_Hold__c = clientAddress.Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold__c, 
                        Client_TPA_Compliance_Hold_Date__c = clientAddress.Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Date__c, 
                        Client_TPA_Compliance_Hold_Reason__c = clientAddress.Account__r.Client_Account_Compliance__r.Client_TPA_Compliance_Hold_Reason__c
                    )); //CC : Client Compliance Record
                }
                system.debug('mapTpaClientVendorComplianceDetails'+mapTpaClientVendorComplianceDetails);
                
                system.debug('vendorAddressId'+vendorAddressId);
                Address__c vendorAddress = mapTempTpaClientVendorCompDet.get(vendorAddressId);
                system.debug('vendorAddress'+vendorAddress);
                if(vendorAddress != null) {
                    Boolean vendCompliance = false, requiresSecondaryReview = false;
                    Date vendCompHoldDate;
                    String vendCompReason, mgmtEmail;
                    Id compId;
                    if(vendorAddress.Account__c != null && vendorAddress.Account__r.ParentId != null && vendorAddress.Account__r.Parent.Vendor_Account_Compliance__c != null) {
                        compId = vendorAddress.Account__r.Parent.Vendor_Account_Compliance__c;
                        if(vendorAddress.Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c){
                            vendCompliance = true;
                            vendCompHoldDate = vendorAddress.Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Date__c;
                            vendCompReason = vendorAddress.Account__r.Parent.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Reason__c;
                        }
                        if(vendorAddress.Account__r.Parent.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c){
                            requiresSecondaryReview = true;
                            mgmtEmail = vendorAddress.Account__r.Parent.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c;
                        }
                    }
                    if(vendorAddress.Account__c != null && vendorAddress.Account__r.Vendor_Account_Compliance__c != null){
                        compId = vendorAddress.Account__r.Vendor_Account_Compliance__c;
                        if(!vendCompliance && vendorAddress.Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold__c){
                            vendCompliance = true;
                            vendCompHoldDate = vendorAddress.Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Date__c;
                            vendCompReason = vendorAddress.Account__r.Vendor_Account_Compliance__r.Vendor_TPA_Compliance_Hold_Reason__c;
                        }
                        if(!requiresSecondaryReview && vendorAddress.Account__r.Vendor_Account_Compliance__r.TPAs_Require_Secondary_Review_by_Mgmt__c){
                            requiresSecondaryReview = true;
                            mgmtEmail = vendorAddress.Account__r.Vendor_Account_Compliance__r.TPA_Secondary_Review_Assigned_Mgmt_Email__c;
                        }
                    }
                    mapTpaClientVendorComplianceDetails.put('VC-'+vendorAddressId, new Account_Compliance__c(Id = compId, 
                        Vendor_TPA_Compliance_Hold__c = vendCompliance, 
                        Vendor_TPA_Compliance_Hold_Date__c = vendCompHoldDate, 
                        Vendor_TPA_Compliance_Hold_Reason__c = vendCompReason,
                        TPAs_Require_Secondary_Review_by_Mgmt__c = requiresSecondaryReview, 
                        TPA_Secondary_Review_Assigned_Mgmt_Email__c = mgmtEmail
                    ));
                }
            }
        }
        if(mapTpaClientVendorComplianceDetails != null && mapTpaClientVendorComplianceDetails.size() == 0) {
            mapTpaClientVendorComplianceDetails = null;
        }
        return mapTpaClientVendorComplianceDetails;
    }
    
    public static Map<String, TPA_Additional_Term__c> mapTpaAdditionalTerms;
    public static Map<String, TPA_Additional_Term__c> getTpaAdditionalTerms(TPA_Request__c tpaRequest) {
        if(UTL_Validate.isEmptyOrNull(tpaRequest) ) {
            return null;
        }
        else if(mapTpaAdditionalTerms == null) {
            mapTpaAdditionalTerms = new Map<String, TPA_Additional_Term__c>();
            List<TPA_Additional_Term__c> listAdditionalTerms = [SELECT Id, 
                                                                              Name, Term_Name__c,
                                                                              Addtional_Term__c, 
                                                                              Is_All_Legal_Entities_Selected__c,
                                                                              Parent_Additional_Terms__c,
                                                                              TPA_Legal_Entity_1__c, 
                                                                              Category__c,
                                                                              Use_Name__c,
                                                                              Country_of_Offering__c,
                                                                              Primary_Offering_Name__c, 
                                                                              Secondary_Offering_Name__c,
                                                                              Is_Future_Approved__c, 
                                                                              Exhibit_Attached__c,
                                                                              (Select Id From Attachments),
                                                                              TPA_Request__c
                                                                       FROM TPA_Additional_Term__c WHERE TPA_Request__c =: tpaRequest.Id ];
            
            if(listAdditionalTerms != null) {
                for(TPA_Additional_Term__c aditionalTerm: listAdditionalTerms){
                   mapTpaAdditionalTerms.put( tpaRequest.Id + ':' +aditionalTerm.Category__c+ ':' + aditionalTerm.Id,aditionalTerm);
                } 
                
            }
        }
        if(mapTpaAdditionalTerms != null && mapTpaAdditionalTerms.size() == 0) {
            mapTpaAdditionalTerms = null;
        }
        return mapTpaAdditionalTerms;
    }

    public static TPA_Master_Extension_Information__c getExtensionRecOfVendorAddress(Id vendorId){
        List<TPA_Master_Extension_Information__c> extensionRecords = [Select Id, Name, Commercial_Reason__c,TPA_Accounts_Address__c From TPA_Master_Extension_Information__c where TPA_Accounts_Address__c =: vendorId];
        if(extensionRecords != null && extensionRecords.size() > 0){
            return extensionRecords[0];
        }
        return null;
    }
    
    public static Map<String, TPA_Text_Editor__c> mapTpaTextAdditionalTerms;
    public static boolean getAdditionalTermsMethodCalled = False;
    public static Map<String, TPA_Text_Editor__c> getTpaTextAdditionalTerms(TPA_Request__c tpaRequest) {
        Set<String> lstFields = new Set<String>();
        Boolean isRepwise = false;
        Boolean isVeeva = false;
        //Boolean isDeepIntent = false;
        Boolean isSourceOrSymphonyVendor = false;
        Boolean isMedPro = false;
        Boolean isEdith = false;
        Boolean isDLIMI = false;
        //system.debug('mapTpaTextAdditionalTerms:' + mapTpaTextAdditionalTerms);
        if(UTL_Validate.isEmptyOrNull(tpaRequest) ) {
            system.debug('in if condition:');
            return null;
        }
        else if(mapTpaTextAdditionalTerms == null && !getAdditionalTermsMethodCalled) {
            List<IMS_Legal_Entity__c> IMSLegalEntityList = [Select Id, 
                                                            containUS__c,
                                                            Is_Ambulatory_EMR__c,
                                                            is_Canada__c,
                                                            isDDDOffering__c,
                                                            is_GE_Centricity_EMR__c,
                                                            Is_Glbl_PromoTrack_Selected__c,
                                                            Is_Health_Plan_Claims__c,
                                                            is_LAAD_Offering__c,
                                                            is_Managed_Workbook__c,
                                                            is_Midas__c,
                                                            Is_Oncology_EMR__c,
                                                            is_Patient_Companion_File__c,
                                                            is_Patient_Reference_File__c,
                                                            is_Payer_Companion_File__c,
                                                            is_Promotrak__c,
                                                            is_Provider_Companion_File__c,
                                                            is_South_Africa_Consumer_Health__c,
                                                            is_Xponent__c,
                                                            is_Xponent_or_OneKey__c,
                                                            Is_MedPages_Data__c,
                                                            is_AIM_XR__c,
                                                            is_Analytics_Link__c,
                                                            Legal_Entity_Name_for_TLLA__c,Name, IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.Name from IMS_Legal_Entity__C where TPA_Request__c = :tpaRequest.Id];
            if(tpaRequest.Service_Provider_Address__r.Name != null && tpaRequest.Service_Provider_Address__r.Name != '')
            {
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('veeva') != -1 )
                {
                    string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('veeva');
                    if(strMap != null)
                    {
                        if(strMap.size() == 0  )
                            isVeeva = true;
                        else if(strMap.size() == 1)
                        {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric())
                                isVeeva = true;
                        }
                        else
                        {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) 
                                isVeeva = true;
                        }
                        
                    }
                }
                /*if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('deepintent') != -1 )
                {
                    isDeepIntent = true;
                }*/
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('edith') != -1 )
                {
                    isEdith = true;
                }
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('repwise') != -1 )
                {
                    string []strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('repwise');
                    if(strMap != null)
                    {
                        if(strMap.size() == 0  )
                            isRepwise = true;
                        else if(strMap.size() == 1)
                        {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric())
                                isRepwise = true;
                        }
                        else
                        {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) 
                                isRepwise = true;
                            
                        }
                        
                    }
                }
                if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dlimi') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('dli') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('signum') != -1)) {
                    string []strMap;
                    if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dlimi')){
                        strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dlimi');
                    }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('dli')){
                        strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('dli');
                    }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('signum')){
                        strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('signum');
                    }
                    
                    if(strMap != null) {
                        if(strMap.size() == 0  ) {
                            isDLIMI = true;
                        }
                        else if(strMap.size() == 1) {
                            if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                                isDLIMI = true;
                            }
                        }
                        else {
                            if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                                isDLIMI = true;
                            }
                        }
                    }
                }
                if( tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('medpro') != -1 )
                {
                    string []strMap1 = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('medpro');
                    if(strMap1 != null)
                    {
                        if(strMap1.size() == 0){
                            isMedPro = true; 
                        }
                        else if(strMap1.size() == 1)
                        {
                            if(strMap1[0] == '' || !strMap1[0].substring(strMap1[0].length()-1,strMap1[0].length()).isAlphanumeric()){
                                isMedPro = true; 
                            }
                        }
                        else
                        {
                            if((strMap1[1] == '' || !strMap1[1].substring(0,1).isAlphanumeric()) && (strMap1[0] == '' || !strMap1[0].substring(strMap1[0].length()-1,strMap1[0].length()).isAlphanumeric()) ) {
                                isMedPro = true;
                            }
                        }
                        
                    }
                }
            
            if( (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('source') != -1) || (tpaRequest.Service_Provider_Address__r.Name.toLowerCase().indexOf('symphony') != -1)) {
                string []strMap;
                if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('source')){
                    strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('source');
                }else if(tpaRequest.Service_Provider_Address__r.Name.toLowerCase().contains('symphony')){
                    strMap = tpaRequest.Service_Provider_Address__r.Name.toLowerCase().split('symphony');
                }
                
                if(strMap != null) {
                    if(strMap.size() == 0  ) {
                        isSourceOrSymphonyVendor = true;
                    }
                    else if(strMap.size() == 1) {
                        if(strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) {
                            isSourceOrSymphonyVendor = true;
                        }
                    }
                    else {
                        if((strMap[1] == '' || !strMap[1].substring(0,1).isAlphanumeric()) && (strMap[0] == '' || !strMap[0].substring(strMap[0].length()-1,strMap[0].length()).isAlphanumeric()) ) {
                            isSourceOrSymphonyVendor = true;
                        }
                    }
                }
            }
        }
            /*if(tpaRequest.Is_Vendor_Veeva_for_all_Use__c){
                lstFields.add('Is_Vendor_Veeva_for_all_Use__c');
            }*/
            
            lstFields.add('AI_ML_Restrictions');
            
            if(isSourceOrSymphonyVendor || isEdith || isDLIMI) {
                if(isSourceOrSymphonyVendor){
                    lstFields.add('Is_Vendor_Related_to_Source_Symphony_Acc__c');
                }
                /*if(isDeepIntent){
                    lstFields.add('Is_Vendor_Name_Contains_DeepIntent__c');
                }*/
                if(isEdith){
                    lstFields.add('Is_Vendor_Name_Contains_Edith__c');
                }
                if(isDLIMI){
                    lstFields.add('Is_Vendor_Name_Contains_DLIMI__c');
                }
            }
            if(tpaRequest.Is_Veeva_Use_CRM_Off_OneKey__c){
                lstFields.add('Is_Veeva_Use_CRM_Off_OneKey__c');
            }
            /* if(tpaRequest.is_Veeva_Use_CRM__c){
                lstFields.add('is_Veeva_Use_CRM__c');
            } */
            if(tpaRequest.Is_Veeva_Use_CRM_SubNational_Off__c){
                lstFields.add('Is_Veeva_Use_CRM_SubNational_Off__c');
            }
            if(tpaRequest.Is_South_Africa_Sub_Off__c ){
                lstFields.add('Is_South_Africa_Sub_Off__c');
            }
            if(tpaRequest.is_Specific_Vendors_LAAD_Off__c ){
                lstFields.add('is_Specific_Vendors_LAAD_Off__c');
            }
            if(tpaRequest.is_Specific_Vendors_APLD_Off__c ){
                lstFields.add('is_Specific_Vendors_APLD_Off__c');
            }
            if(tpaRequest.is_Specific_Vendors_Long_Prescr_Data__c ){
                lstFields.add('is_Specific_Vendors_Long_Prescr_Data__c');
            }
            if(tpaRequest.is_Specific_Vendors_Medical_Claims_Data__c ){
                lstFields.add('is_Specific_Vendors_Medical_Claims_Data__c');
            }
            /* if(tpaRequest.is_20_or_more_Offering_Present__c ){
                lstFields.add('is_20_or_more_Offering_Present__c');
            } */

            if(IMSLegalEntityList != null) {
                for(IMS_Legal_Entity__C imsLegalEntity: IMSLegalEntityList){
                    if(imsLegalEntity.is_Midas__c){
                        lstFields.add('is_Midas__c');
                    }
                    if(imsLegalEntity.is_Patient_Reference_File__c){
                        lstFields.add('is_Patient_Reference_File__c');
                    }
                    if(imsLegalEntity.is_GE_Centricity_EMR__c){
                        lstFields.add('is_GE_Centricity_EMR__c');
                    }
                    if(imsLegalEntity.is_Promotrak__c){
                        lstFields.add('is_Promotrak__c');
                    }
                    if(imsLegalEntity.is_Managed_Workbook__c){
                        lstFields.add('is_Managed_Workbook__c');
                    }
                    if(imsLegalEntity.Is_Glbl_PromoTrack_Selected__c){
                        lstFields.add('Is_Glbl_PromoTrack_Selected__c');
                    }
                    if(imsLegalEntity.is_South_Africa_Consumer_Health__c){
                        lstFields.add('is_South_Africa_Consumer_Health__c');
                    }
                    if(imsLegalEntity.IS_Health_Plan_Claims__c){
                        lstFields.add('IS_Health_Plan_Claims__c');
                    }
                    if(imsLegalEntity.is_Patient_Companion_File__c){
                        lstFields.add('is_Patient_Companion_File__c');
                    }
                    if(imsLegalEntity.is_Provider_Companion_File__c){
                        lstFields.add('is_Provider_Companion_File__c');
                    }
                    if(imsLegalEntity.is_Payer_Companion_File__c){
                        lstFields.add('is_Payer_Companion_File__c');
                    }
                    if(imsLegalEntity.is_LAAD_Offering__c){
                        lstFields.add('is_LAAD_Offering__c');
                    }
                    if(imsLegalEntity.Is_Oncology_EMR__c){
                        lstFields.add('Is_Oncology_EMR__c');
                    }
                    if(imsLegalEntity.Is_Ambulatory_EMR__c){
                        lstFields.add('Is_Ambulatory_EMR__c');
                    }
                    if(tpaRequest.Is_Vendor_Name_Contains_MedPro__c && imsLegalEntity.is_Xponent_or_OneKey__c){
                        lstFields.add('is_Xponent_or_OneKey__c');
                    }
                    if(imsLegalEntity.is_Canada__c){
                        lstFields.add('is_Canada__c');
                    }
                    if(tpaRequest.AMA_USPrescriberData__c == 'Yes' && imsLegalEntity.containUS__c){
                        lstFields.add('containUS__c');
                    }
                    if(imsLegalEntity.isDDDOffering__c){
                        lstFields.add('isDDDOffering__c');
                    }
                    if(imsLegalEntity.is_Xponent__c){
                        lstFields.add('is_Xponent__c');
                    }
                    if(imsLegalEntity.Is_MedPages_Data__c){
                        lstFields.add('Is_MedPages_Data__c');
                    }
                    if(imsLegalEntity.is_AIM_XR__c){
                        lstFields.add('is_AIM_XR__c');
                    }
                    if(imsLegalEntity.is_Analytics_Link__c){
                        lstFields.add('is_Analytics_Link__c');
                    }
                }
            }
            mapTpaTextAdditionalTerms = new Map<String, TPA_Text_Editor__c>();
            List<TPA_Text_Editor__c> listAdditionalTerms = [SELECT Id, 
                                                                   Name, 
                                                                   Content__c, 
                                                                   English_Translation__c, 
                                                                   Japanese_Translation__c, 
                                                                   Page_Name__c, 
                                                                   Page_Title__c, 
                                                                   Page_Type__c 
                                                                   FROM TPA_Text_Editor__c where Page_Name__c in : lstFields ];
            
            if(listAdditionalTerms != null) {
                for(TPA_Text_Editor__c aditionalTerm: listAdditionalTerms){
                   mapTpaTextAdditionalTerms.put( aditionalTerm.Page_Name__c + ':' +aditionalTerm.Page_Type__c,aditionalTerm);
                } 
                
            }
        }
        getAdditionalTermsMethodCalled = true;
      //  system.debug('mapTpaTextAdditionalTerms:' + mapTpaTextAdditionalTerms.size());
        if(mapTpaTextAdditionalTerms != null && mapTpaTextAdditionalTerms.size() == 0) { 
            mapTpaTextAdditionalTerms = null;
        }
        //system.debug('mapTpaTextAdditionalTerms:' + mapTpaTextAdditionalTerms);
        return mapTpaTextAdditionalTerms;
    }
    
    public static Map<String, TPA_Offering_Notification_Mapping__c> mapTpaDynamicNotifications;
    public static Map<String, TPA_Offering_Notification_Mapping__c> getmapTpaDynamicNotifications(TPA_Request__c tpaRequest) {
        if(UTL_Validate.isEmptyOrNull(tpaRequest) ) {
            return null;
        }
        else if(mapTpaDynamicNotifications == null) {
            mapTpaDynamicNotifications = new Map<String, TPA_Offering_Notification_Mapping__c>();
            List<TPA_Offering_Notification_Mapping__c> addDynamicTerms = new List<TPA_Offering_Notification_Mapping__c>();
            if(tpaRequest != null ){
                if(SRV_TPA_TPARequest.allPurposeIds == null || SRV_TPA_TPARequest.allPurposeIds.size() == 0){
                    SRV_TPA_TPARequest.allPurposeIds = new Set<Id>();
                    for(TPA_Purpose__c purpose: tpaRequest.Purposes__r){
                        //system.debug('Purpose__r'+purpose.Purpose__r.Id);
                        system.debug('purpose.Id'+purpose.Id+'allPurpose'+SRV_TPA_TPARequest.allPurposeIds);
                        SRV_TPA_TPARequest.allPurposeIds.add(purpose.Purpose__r.Id);
                    }
                }
                if(SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor == null || SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor.size() == 0){
                   SRV_TPA_TPARequest.isDynamicNotificationRequiredForVendor(tpaRequest);
                }
                addDynamicTerms.addAll(SRV_TPA_TPARequest.dynamicOfferingsNotificationListForVendor);
                
                if(addDynamicTerms.size() > 0){
                    for(TPA_Offering_Notification_Mapping__c add: addDynamicTerms){
                        system.debug('addDynamicTerms'+add.Offering_Notifications__r.Content__c);
                        if(!mapTpaDynamicNotifications.containsKey(add.Name)){
                            mapTpaDynamicNotifications.put(add.Name, add);
                        }
                    }
                }
                system.debug('mapTpaDynamicNotifications'+mapTpaDynamicNotifications);
            }
        }
        if(mapTpaDynamicNotifications != null && mapTpaDynamicNotifications.size() == 0) {
            mapTpaDynamicNotifications = null;
        }
        return mapTpaDynamicNotifications;
    }
    
    public static String getOfferingDetailsToHtmlList(String offDetail) {
        String offeringHtmlList = '';
        List<String> offeringInfo;
        if(!UTL_Validate.isEmptyOrNull(offDetail)) {
            offeringHtmlList = '<ul style="list-style-type: disc;">';
            for(string offeringValue: offDetail.split(';')) {
                if(!UTL_Validate.isEmptyOrNull(offeringValue)) {
                    offeringInfo = offeringValue.split(':');
                    if(offeringInfo.size() > 1) {
                        offeringHtmlList += '<li>' + (offeringInfo.size() == 3 ? offeringInfo[2] : offeringInfo[1]) + ' - ' + offeringInfo[0] + '</li>';
                    }
                }
            }
            offeringHtmlList += '</ul>';
        }
        return offeringHtmlList;
    }
    
    public static List<TPA_Data_Asset__c>  getDataAsset(Id reqID){

        return [Select  t.Purpose__c, 
        Purpose__r.Name,
        Purpose__r.Primary_Purpose_Name__c, 
        BU__c,
        t.Asset_Name__c,
        Name,
        Other_Text__c, 
        APLD_Delivery_Date__c,
        APLD_Study_Name__c,
        RWE_Delivery_Date__c,
        RWE_Study_Name__c,
        Consumer_Profile_Study_Name__c, 
        Consumer_Profile_Delivery_Date__c, 
        Promotional_ROI_Study_Name__c, 
        Promotional_ROI_Delivery_Date__c, 
        Nostradata_Source_of_Business_LRx__c,
        Longitudanal_Patient_Diagonsis__c,
        CH_Combined_Hos_and_Ret_Profit_AU__c,
        CH_Hospital_Profits__c,
        CH_Other_Outlet_Profits__c,
        CH_Retail_Profits__c,
        Health_Plan_Claims_Data__c, 
        LAAD_Longitudinal_Access_and_Adj_data__c, 
        Patient_Reference_File__c,
        Patient_Companion_File__c, 
        Payer_Companion_File__c, 
        Provider_Companion_File__c,
        STI_Data_Report_Name__c,
        CWH_NZ_Scan_data__c,
        Customized_Data_Text__c,
        Data_Asset__r.BU__c,
        Purpose__r.TPA_Purpose_Category__c,
        Purpose__r.Purpose__c,
        DDD_Level__c,
        Data_Asset__c,
        Region__c,
        Request__c,
        hasDDD__c,
        hasMidas__c,
        Geo_Level__c,
        Asset_NametText__c,
        Other_Data_Asset_Details__c,
        Is_Restricted_Data__c,
        Data_Asset__r.Is_Restricted_Data__c,
        Data_Asset__r.Requires_Fee__c,
        Data_Asset__r.External_License_Data_Supplier_Req__c, 
        Data_Asset__r.Additional_Data_Protection_Terms__c, 
        Data_Asset__r.Geo_Level__c,
        Data_Asset__r.IMS_Legal_Entity__c, 
        Data_Asset__r.Commercial_Owner_Email__c,
        Data_Asset__r.Needs_license_or_data_supplier_response__c,
        Data_Asset__r.Requires_Secondary_Review__c,
        A_Column_Use_For_Template__c,
        Asset_Name_For_Template__c,
        hasXponentPlanTrak__c,
        Requires_Manual_Review__c,
        Data_Asset__r.Requires_Manual_Review__c,
        Is_IMSAG_Product_For_Template__c,
        Is_Restricted_Data_For_Template__c,
        Is_IMS_AGProduct__c,
        Purpose__r.TPA_Purpose_Category__r.Category_Name__c, 
        Region_For_Template__c,
        (Select Id,
         Name,
         Bu__c,
         Secondary_Asset_Name__c,
         Is_RestrictedData__c,
         IMS_Secondary_Data_Asset__c,
         IMS_Secondary_Data_Asset__r.Requires_Manual_Review__c,
         IMS_Secondary_Data_Asset__r.Requires_Secondary_Review__c,
         IMS_Secondary_Data_Asset__r.Commercial_Manager_Email__c, 
         IMS_Secondary_Data_Asset__r.Is_Restricted_Data__c,
         IMS_Secondary_Data_Asset__r.Need_license_or_data_supplier_permission__c,
         AU_Profits__c,
         Nostradata_LRx_Volume__c,
         Nostradata_Source_of_Business_LRx__c,
         AU_DDD_Hospital_Profits__c,
         AU_Other_Outlet_Data_Profits__c,
         Combined_Hos_and_Ret_Profit_AU__c,
         Pharmacy_Scan__c,
         STI_Data_Custom_Report_Name__c, 
         TPA_Data_Asset__r.Data_Asset__r.Commercial_Owner_Email__c, 
         TPA_Data_Asset__r.A_Column_Use_For_Template__c,BrandImpact_Delivery_Date__c,
         BrandImpact_Study_Name__c,
         Outliner_Label_Code__c,
         Outliner_Data_Period_Text__c,
         Channel_Dynamics_Delivery_Date__c,
         Channel_Dynamics_Study_Name__c,
         Pro_Voice_Delivery_Date__c,
         Pro_Voice_Study_Name__c, 
         Purpose__c,
         TPA_Data_Asset__r.Purpose__r.TPA_Purpose_Category__r.Category_Name__c,
         TPA_Data_Asset__r.Asset_Name__c,
         TPA_Data_Asset__r.APLD_Delivery_Date__c,
         TPA_Data_Asset__r.APLD_Study_Name__c
         from TPA_Secondary_Data_Assets__r ) 
        From TPA_Data_Asset__c t where Request__c = :reqID];

    }
    
    public static Map<String, Map<String, Map<String, String>>> setUseOfferingMap(List<TPA_Data_Asset__c> dataAssets){
        if(dataAssets == null){
            return new Map<String, Map<String, Map<String, String>>>();
        }
        List<TPA_Data_Asset__c> tpaDataAssets = dataAssets; 
        Map<String, String> secAssetFieldMap = new Map<String, String>();
        for(string secAssetField :  Label.TPA_Sec_Asset_Field_Map.split(',')) {
            secAssetFieldMap.put(secAssetField.split('~')[0], secAssetField.split('~')[1]);
        }
        Map<String, String> priAssetFieldMap = new Map<String, String>();
        for(string priAssetField : Label.TPA_Primary_Asset_Field_Map.split(',')){
            priAssetFieldMap.put(priAssetField.split('~')[0], priAssetField.split('~')[1]);
        }
        Map<String, String> geoLevelDataAssetMap;
        Map<String, Map<String, String>> PurposeGeoLevelDataAssetMap;
        Map<String, Map<String, Map<String, String>>> BUPurposeGeoLevelDataAssetMap = new Map<String, Map<String, Map<String, String>>>();
        for(TPA_Data_Asset__c da : tpaDataAssets) {
            String DataAssetsNames = '';
            String promotionCustomStudyDate = '';
            String outlinerLCodeDate = '';
            if(da.TPA_Secondary_Data_Assets__r.size() > 0)
            {
                for(TPA_Secondary_Data_Asset__c secDA : da.TPA_Secondary_Data_Assets__r)
                {
                    
                    promotionCustomStudyDate = '';
                    outlinerLCodeDate = '';
                    if(secDA.Secondary_Asset_Name__c == 'BrandImpact Custom Study Name & Project Delivery Date:')
                    {
                        promotionCustomStudyDate+= 'BrandImpact Custom Study Name: '+secDA.BrandImpact_Study_Name__c;
                        promotionCustomStudyDate+= ' BrandImpact Project Delivery Date: '+secDA.BrandImpact_Delivery_Date__c.format();
                        DataAssetsNames += ', ' + promotionCustomStudyDate;
                    }
                    else if(secDA.Secondary_Asset_Name__c == 'Channel Dynamics Custom Study Name & Project Delivery Date:')
                    {
                        promotionCustomStudyDate+= 'Channel Dynamics Custom Study Name: '+secDA.Channel_Dynamics_Study_Name__c;
                        promotionCustomStudyDate+= ' Channel Dynamics Project Delivery Date: '+secDA.Channel_Dynamics_Delivery_Date__c.format();
                        DataAssetsNames += ', <br>' + promotionCustomStudyDate; // Modified by Neha Bansal under CR-11024
                    }
                    else if(secDA.Secondary_Asset_Name__c == 'ProVoice Custom Study Name & Project Delivery Date:')
                    {
                        promotionCustomStudyDate+= 'ProVoice Custom Study Name: '+secDA.Pro_Voice_Study_Name__c;
                        promotionCustomStudyDate+= ' ProVoice Project Delivery Date: '+secDA.Pro_Voice_Delivery_Date__c.format();
                        DataAssetsNames += ', <br>' + promotionCustomStudyDate; 
                    }
                    else if(secDA.Secondary_Asset_Name__c == Label.STI_Data_Custom_Report_Name){
                        promotionCustomStudyDate += Label.STI_Data_Custom_Report_Name + ' ' + secDA.STI_Data_Custom_Report_Name__c;
                        DataAssetsNames += ', <br>' + promotionCustomStudyDate;
                    }
                    
                    else if(secAssetFieldMap != null && secAssetFieldMap.size() > 0 && secAssetFieldMap.keySet().contains(secDA.Secondary_Asset_Name__c)){
                        
                        String fieldName = secAssetFieldMap.get(secDA.Secondary_Asset_Name__c);
                        system.debug('fieldName:'+fieldName);
                        system.debug('secDA.get(fieldName):'+secDA.get(fieldName));
                        system.debug('promotionCustomStudyDate:'+promotionCustomStudyDate);
                        if(secDA.get(fieldName) != null){
                            promotionCustomStudyDate+= secDA.Secondary_Asset_Name__c + ': '+ secDA.get(fieldName);
                        }
                        system.debug('promotionCustomStudyDate:'+promotionCustomStudyDate);
                        DataAssetsNames += ', ' + promotionCustomStudyDate;
                        system.debug('DataAssetsNames:'+DataAssetsNames);
                    }
                    else if(secDA.Secondary_Asset_Name__c == Label.TPA_OutlierView)
                    {
                        outlinerLCodeDate+= ' Data Niche Associates (DNA) Medicaid Data: OutlierView Labeler Codes: '+secDA.Outliner_Label_Code__c;  
                        outlinerLCodeDate+= ' Data Niche Associates (DNA) Medicaid Data: OutlierView Date: '+secDA.Outliner_Data_Period_Text__c;
                        DataAssetsNames += ', ' + outlinerLCodeDate;
                    }
                    else {
                        DataAssetsNames += ', ' + secDA.Secondary_Asset_Name__c;
                    }
                }
                DataAssetsNames = DataAssetsNames.substring(2, DataAssetsNames.length());
                if(da.Asset_Name__c == 'APLD Custom Study Name & Project Delivery Date:') {
                    String apldStudyDateInfo = da.Asset_Name__c + '<br>APLD Custom Study Name: ' + da.APLD_Study_Name__c;
                    apldStudyDateInfo+= '<br>Project Delivery Date: ' + da.APLD_Delivery_Date__c.format();
                    apldStudyDateInfo += '<br>';
                    DataAssetsNames = apldStudyDateInfo + '&lt;' + DataAssetsNames + '&gt;';
                }
                else {
                    DataAssetsNames = da.Asset_Name__c + '&lt;' + DataAssetsNames + '&gt;'; 
                }
            }
            else {
                DataAssetsNames += da.Asset_Name__c;
            }
            
			if( BUPurposeGeoLevelDataAssetMap.containsKey(da.BU__c) )
            {
                PurposeGeoLevelDataAssetMap = BUPurposeGeoLevelDataAssetMap.get(da.BU__c);
                if(PurposeGeoLevelDataAssetMap.containsKey(da.Purpose__r.Name)|| PurposeGeoLevelDataAssetMap.containsKey(da.Purpose__r.Name +':'+da.A_Column_Use_For_Template__c)) // modified by neha under issue-9917
                {
                    if(da.Purpose__r.Name.equalsIgnoreCase('Other')) { 
                        geoLevelDataAssetMap = PurposeGeoLevelDataAssetMap.get(da.Purpose__r.Name +':'+da.A_Column_Use_For_Template__c); // added by neha under issue-9917
                    }
                    else {                                                                       
                        geoLevelDataAssetMap = PurposeGeoLevelDataAssetMap.get(da.Purpose__r.Name);
                    }
                    if(geoLevelDataAssetMap.containsKey(da.Geo_Level__c))
                    {
                        String dataAssetString = geoLevelDataAssetMap.get(da.Geo_Level__c);
                        dataAssetString += ', <br>' + DataAssetsNames; 
                        String tempStr = getFullOfferingName(DataAssetsNames,da);
                        if(tempStr != ''){
                            dataAssetString += tempStr;
                        }
                        else if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(DataAssetsNames)){
                            String fieldName = priAssetFieldMap.get(DataAssetsNames);
                            if(da.get(fieldName) != null){
                                dataAssetString+= ': ' + da.get(fieldName);
                            }
                        }
                        geoLevelDataAssetMap.put(da.Geo_Level__c, dataAssetString);
                    }
                    else
                    {
                        String APLDandRWEInfo = ''; 
                        String tempStr = getFullOfferingName(DataAssetsNames,da);
                        if(tempStr != ''){
                            geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames+tempStr);
                        }
                        else if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(DataAssetsNames)){
                            String fieldName = priAssetFieldMap.get(DataAssetsNames);
                            if(da.get(fieldName) != null){
                                APLDandRWEInfo+=  ': ' + da.get(fieldName);
                                geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames + APLDandRWEInfo);
                            }
                        }
                        
                        else
                        {
                            geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames);
                        }
                    }
                    if(da.Purpose__r.Name.equalsIgnoreCase('Other'))
                    {
                        PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name+':'+da.A_Column_Use_For_Template__c, geoLevelDataAssetMap);
                    }
                    else
                    {
                        PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name, geoLevelDataAssetMap);
                    }
                }
                else
                {
                    geoLevelDataAssetMap = new Map<String, String>();
                    String APLDandRWEInfo = ''; 
                    String tempStr = getFullOfferingName(DataAssetsNames,da);
                    if(tempStr != ''){
                        geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames+tempStr);
                    }
                    else if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(DataAssetsNames)){
                        String fieldName = priAssetFieldMap.get(DataAssetsNames);
                        if(da.get(fieldName) != null){
                            APLDandRWEInfo+= ': ' + da.get(fieldName);
                            geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames + APLDandRWEInfo);
                        }
                    }
                    else
                    {
                        geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames);
                    }
                    if(da.Purpose__r.Name.equalsIgnoreCase('Other'))
                    {
                        PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name+':'+da.A_Column_Use_For_Template__c, geoLevelDataAssetMap);
                    }
                    else
                    {
                        PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name, geoLevelDataAssetMap);
                    }
                }
                BUPurposeGeoLevelDataAssetMap.put(da.BU__c, PurposeGeoLevelDataAssetMap);
            }
            else
            {
                geoLevelDataAssetMap = new Map<String, String>();
                PurposeGeoLevelDataAssetMap = new Map<String, Map<String, String>>();
                String APLDandRWEInfo = ''; 
                String tempStr = getFullOfferingName(DataAssetsNames,da);
                if(tempStr != ''){
                    geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames+tempStr);
                }
                else if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(DataAssetsNames)){
                    String fieldName = priAssetFieldMap.get(DataAssetsNames);
                    if(da.get(fieldName) != null){
                        APLDandRWEInfo+= ': ' + da.get(fieldName);
                        geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames + APLDandRWEInfo);
                    }
                }
                else
                {
                    geoLevelDataAssetMap.put(da.Geo_Level__c, DataAssetsNames);
                }
                if(da.Purpose__r.Name.equalsIgnoreCase('Other'))
                {
                    PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name+':'+da.A_Column_Use_For_Template__c, geoLevelDataAssetMap);
                }
                else
                {
                    PurposeGeoLevelDataAssetMap.put(da.Purpose__r.Name, geoLevelDataAssetMap);
                }
                BUPurposeGeoLevelDataAssetMap.put(da.BU__c, PurposeGeoLevelDataAssetMap);
            }
            
        }
        return BUPurposeGeoLevelDataAssetMap;
    }

    public static String getFullOfferingName(String DataAssetsNames,TPA_Data_Asset__c da){
        String dataAssetStr = '';
        if(DataAssetsNames.equalsIgnoreCase('Other'))
        {
            dataAssetStr+= ':'+da.Other_Data_Asset_Details__c;
        }
        else if(DataAssetsNames.equalsIgnoreCase('RWE Custom Study Name & Project Delivery Date:'))
        {
            dataAssetStr+= '<br><br>RWE Custom Study Name: '+da.RWE_Study_Name__c;
            dataAssetStr+= '<br>Project Delivery Date: '+da.RWE_Delivery_Date__c.format();
        }
        else if(DataAssetsNames.equalsIgnoreCase(Label.TPA_STI_Data_Offering_Name)) {
            dataAssetStr += ' ' + da.STI_Data_Report_Name__c;
        }
        else if(DataAssetsNames.equalsIgnoreCase(UTL_TPA.consumerProfilesOfferingName))
        {
            dataAssetStr+= '<br><br>Consumer Profiles Custom Study Name: '+da.Consumer_Profile_Study_Name__c;
            dataAssetStr+= '<br>Project Delivery Date: '+da.Consumer_Profile_Delivery_Date__c.format();
        }
        else if(DataAssetsNames.equalsIgnoreCase('Promotional Response (ROI) Custom Study Name & Project Delivery Date:'))
        {
            dataAssetStr+= '<br><br>Promotional Response (ROI) Custom Study Name: '+da.Promotional_ROI_Study_Name__c;
            dataAssetStr+= '<br>Project Delivery Date: '+da.Promotional_ROI_Delivery_Date__c.format();
        }
        return dataAssetStr;
    }
    
    public static List<TPA_Country_Codes__c> lstTPACountryAndStateCodes;    
    public static Map<String, String> mapCountryCodeWithAllPossibleValues;    
    public static Map<String, String> mapStateCodeWithAllPossibleValues;
    
    static {
        lstTPACountryAndStateCodes = TPA_Country_Codes__c.getall().values();
        mapCountryCodeWithAllPossibleValues = new Map<String, String>();
        mapStateCodeWithAllPossibleValues = new Map<String, String>();
        
        for(TPA_Country_Codes__c objCode: lstTPACountryAndStateCodes) {
            if(objCode.Code_Type__c == 'C') {
                if(objCode.Country_Possible_Codes__c != null) {
                    for(string strCode: objCode.Country_Possible_Codes__c.split(';')) {
                        mapCountryCodeWithAllPossibleValues.put(strCode.toLowerCase(), objCode.Name + ';' + objCode.Country_Possible_Codes__c);
                    }
                    mapCountryCodeWithAllPossibleValues.put(objCode.Name.toLowerCase(), objCode.Name + ';' + objCode.Country_Possible_Codes__c);
                }
                else {
                    mapCountryCodeWithAllPossibleValues.put(objCode.Name.toLowerCase(), objCode.Name);
                }
            }
            else if(objCode.Code_Type__c == 'S') { 
                if(objCode.Country_Possible_Codes__c != null) {
                    for(string strCode: objCode.Country_Possible_Codes__c.split(';')) {
                        mapStateCodeWithAllPossibleValues.put(strCode.toLowerCase(), objCode.Name + ';' + objCode.Country_Possible_Codes__c);
                    }
                    mapStateCodeWithAllPossibleValues.put(objCode.Name.toLowerCase(), objCode.Name + ';' + objCode.Country_Possible_Codes__c);
                }
                else {
                    mapStateCodeWithAllPossibleValues.put(objCode.Name.toLowerCase(), objCode.Name);
                }
            }
        }
    }
}
