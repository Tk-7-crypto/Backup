public with sharing class CON_OCE {

    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String STATUS_FINALIZED = 'Finalized';
    public static final String STATUS_NEW = 'New';
    public static final String NONE = 'None';
    public static final String AGREEMENT_BUSINESS_OBJECT = 'Agreement';
    public static final String MKTG_PRICING_TYPE = 'OCE Marketing';
    public static final String SALES_PRICING_TYPE = 'OCE Sales';
    public static final String SALES_PRIMARY_OPTION_GROUP = 'OCE Sales Subscriptions';
    public static final String MKTG_PRODUCT = 'OCE Marketing Subscription';
    public static final String MKTG_CAPACITY = 'OCE Marketing Platform / Capacity Expansion';
    public static final String PRODUCT_SERVICE = 'Product/Service';
    public static final String PRODUCT_OPTION = 'Option';
    public static final String ADMIN_SALES_GROUP = 'Admin';
    public static final String CORPORATE_SALES_GROUP = 'Corporate';
    public static final String ENTERPRISE_SALES_GROUP = 'Enterprise';
    public static final String MKTG_ADDON = 'OCE Mktg Add-On';
    public static final String SUBSCRIPTION_FEE_CHARGE_TYPE = 'Subscription Fee';
    public static final String IMPLEMENT_FEE_CHARGE_TYPE = 'Implementation Fee';
    public static final String ADD_ON_CHARGE_TYPE = 'Add-on Price';
    public static final String TOTAL_FEE = 'Total Fee';
    public static final String OPPORTUNITY_ACCOUNT_ID = 'AccountId';
    public static final String AGMT_RELATED_OPPORTUNITY = 'Apttus__Related_Opportunity__c';
    public static final String AGMT_ACCOUNT_ID = 'Apttus__Account__c';
    public static final String AGMT_PRICE_LIST = 'Apttus_CMConfig__PriceListId__c';
    public static final String AGMT_DESCRIPTION = 'Apttus__Description__c';
    public static final String AGMT_STATUS_CATEGORY = 'Apttus__Status_Category__c';
    public static final String AGMT_STATUS = 'Apttus__Status__c';
    public static final String YEAR = 'Year';
    public static final String DATE_FORMAT = 'MMMM d, yyyy';
    public static final String PRICELIST_NAME = 'OCE Price List';
    public static final String THROUGH = 'Through';
    public static final String STATUS_REQUEST = 'Request';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_AUTO_APPROVED = 'Auto Approved';
    public static final String SUBSCRIPTION_TYPE = 'Subscription';
    public static final String TESTIMONIAL = 'Testimonial';
    public static final String MULTI_YEAR = 'Multi year';
    public static final String MULTI_SUBSCRIPTION = 'Multi Subscription';
    public static final String DATA_PURCHASE = 'Data Purchase';
    public static final String ADDITIONAL_ECONOMIC_CONCESSION = 'Additional Economic Concession';
    public static final String LINE_ITEM_LINE_NUMBER = 'Apttus_Config2__LineNumber__c';
    public static final String BUNDLE_CLONE_SETTINGS = 'System_Settings';
    public static final String BATCH_JOB_COMPLETED = 'Completed';
    public static final String COUNTRY_ZONE_MATRIX = 'O_CountryZone Matrix';
    public static final String COUNTRY_FIELD = 'O_Country__c';
    public static final String ZONE_FIELD = 'O_Zone__c';
    public static final Integer DEFAULT_CLONE_BATCH_SIZE = 5;
    public static final Integer DEFAULT_COUNTRIES_TO_WAIT = 20;
    public static final String CLONE_BUNDLE_TEMPLATE = 'OCE_Clone_Bundle_Finished_Notification';
    public static final String CART_SAVED = 'Saved';
    public static final String SUMMARY_GROUP_FILTER = '%Grand%';
    public static final String SUMMARY_GROUP_EXT_PRICE = 'extendedListPrice';
    public static final String ADJUSTMENT_AGMT_ID = 'agreementId';
    public static final String ADJUSTMENT_LINE_ITEM_ID = 'lineItemId';
    public static final String ADJUSTMENT_LINE_TYPE = 'lineType';
    public static final String ADJUSTMENT_INCENTIVE_AMT = 'totalIncentiveAmount';
    public static final String AGREEMENT_AUTOAPPROVED = 'Agreement is Auto Approved';
    public static final String APPROVAL_WARNING = 'No applicable approval process found';
    public static final String APPROVAL_EMAIL_TEMPLATE = 'OCE_Approval_Submission_Notification';
    public static final String APPROVAL_NOTIFIER_EMAIL = 'Notify_User__r.Email';
    public static final String SUBTYPE_AGREEMENT = 'agreement';
    public static final String SUBTYPE_CURRENCY = 'currency';
    public static final String SUBTYPE_QUANTITY = 'quantity';
    public static final String SUBTYPE_FAMILY = 'family';
    public static final String SUBTYPE_OPTION_GROUP = 'option_group';
    public static final String SUBTYPE_ADD_ON = 'add_on';
    public static final String SUBTYPE_TIER = 'sub_tier';
    public static final String SUBTYPE_INSTANCE = 'instance_type';
    public static final String SUBTYPE_TERM = 'term';
    public static final String SUBTYPE_FEE = 'fee';
    public static final String SUBTYPE_ADMIN_LABEL = 'Administrator:  IQVIA Release and Maintenance';
    public static final String SUBTYPE_TOTAL_LABEL = 'Total Authorized Users';
    public static final String VALIDATION_ERROR = 'A maximum discount of 10% can be applied to add-on products. ' +
        'Please reduce the discount given for {0} add-ons:';
    public static final String VALIDATION_LINE_ERROR = 'Line number {0}: {1} => {2}%';
    public static final Integer VALIDATION_MAX_DISPLAY_LINES = 3;

    public static final Set<String> SUBSCRIPTION_FEE_FIELD_SET = new Set<String>{
        'Apttus_Config2__ProductId__r.OCE_Template_Label__c',
        'Apttus_Config2__OptionId__r.OCE_Template_Label__c',
        'Apttus_Config2__AttributeValueId__r.O_Mkt_InstanceIntent__c',
        'Apttus_Config2__ProductId__r.Unit_Name__c',
        'Apttus_Config2__ProductId__r.Name',
        'Apttus_Config2__OptionId__r.Name',
        'Apttus_Config2__LineType__c',
        'Apttus_Config2__ChargeType__c',
        'Apttus_Config2__OptionGroupLabel__c',
        'Apttus_Config2__NetPrice__c',
        'Apttus_Config2__ConfigurationId__r.Apttus_CMConfig__AgreementId__c',
        'Apttus_Config2__ConfigurationId__r.Apttus_CMConfig__AgreementId__r.Apttus__Term_Months__c',
        'Apttus_Config2__ConfigurationId__r.Apttus_CMConfig__AgreementId__r.CurrencyIsoCode'
    };

    public static final Set<String> SUBSCRIPTION_TERM_FIELD_SET = new Set<String>{
        'Apttus_CMConfig__AgreementId__r.Apttus__Contract_Start_Date__c',
        'Apttus_CMConfig__AgreementId__r.Apttus__Contract_End_Date__c',
        'Apttus_CMConfig__AgreementId__r.O_Term_Years__c'
    };

    public static final Set<String> AGREEMENT_FIELD_SET = new Set<String> {
        'Id',
        'CurrencyIsoCode',
        'Apttus__Related_Opportunity__c',
        'O_Contracting_Country__c'
    };

    public static final Set<String> AGREEMENT_LINE_ITEM_FIELD_SET = new Set<String> {
        'Id',
        'CurrencyIsoCode',
        'Apttus__ProductId__c',
        'Apttus__ProductId__r.ProductCode',
        'Apttus_CMConfig__OptionId__c',
        'Apttus_CMConfig__OptionId__r.ProductCode',
        'Apttus__AgreementId__c',
        'Apttus_CMConfig__LineType__c',
        'Apttus_CMConfig__IsPrimaryLine__c',
        'Apttus__NetPrice__c',
        'Apttus__Quantity__c',
        'Apttus__Description__c',
        'Apttus_CMConfig__AttributeValueId__r.O_Country__c'
    };

    public static final Set<String> AGREEMENT_APPROVAL_FIELD_SET = new Set<String> {
        'Id',
        'Name',
        'O_Contracting_Country__c',
        'OCE_To_be_Auto_Approved__c',
        'O_Total_Agreement_Value__c',
        'O_Subscription_Gross_Margin__c',
        'OCE_Regions__c'
    };

    public static final Set<String> CLONE_BUNDLE_FIELD_SET = new Set<String>{
        'Apttus_Config2__ConfigurationId__c',
        'Apttus_Config2__ConfigurationId__r.Apttus_CMConfig__AgreementId__c',
        'Apttus_Config2__LineNumber__c',
        'Apttus_Config2__PricingStatus__c',
        'Apttus_Config2__ProductId__r.Name',
        'Apttus_Config2__AttributeValueId__c',
        'Apttus_Config2__AttributeValueId__r.O_Country__c',
        'Apttus_Config2__AttributeValueId__r.O_Zone__c'
    };

    public static final Set<String> VALIDATE_LINE_ITEM_FIELD_SET = new Set<String>{
        'Id',
        'Apttus_Config2__LineNumber__c',
        'Apttus_Config2__NetPrice__c',
        'Apttus_Config2__ExtendedPrice__c',
        'Apttus_Config2__OptionId__r.Name'
    };

    public static final Set<String> CONFIG_AGREEMENT_FIELD_SET = new Set<String>{
        'Apttus_CMConfig__AgreementId__c',
        'Apttus_CMConfig__AgreementId__r.Id',
        'Apttus_CMConfig__AgreementId__r.Name',
        'Apttus_CMConfig__AgreementId__r.Opportunity_Name__c',
        'Apttus_CMConfig__AgreementId__r.O_Is_Locked_For_Cloning__c'
    };

    public static final Set<String> BATCH_JOB_FIELD_SET = new Set<String>{
        'Id',
        'Status',
        'NumberOfErrors',
        'CreatedById',
        'CreatedBy.Name',
        'CreatedBy.Email',
        'ExtendedStatus'
    };

    public static final Set<String> BATCH_JOB_FINISHED_VALUES = new Set<String>{
        BATCH_JOB_COMPLETED, 'Aborted', 'Failed'
    };

    public static final String ERROR_SYNC_INSUFFICIENT_PRIVILEGE = 'Insufficient Privilege: ' +
            'You do not have the level of access necessary to perform ' +
            'Synchronization with Opportunity on this agreement';
    public static final String ERROR_VALIDATION_VIOLATION = 'Custom Validation Violation';

    // Test Class Constants
    public static final String TEST_ACCOUNT_NAME = 'Test Account';
    public static final String TEST_OPPORTUNITY_NAME = 'Test Opportunity';
    public static final String TEST_AGREEMEENT_NAME = 'Test Agreement';
    public static final String TEST_PRODUCT_CONFIG_NAME = 'Test Product Config';
    public static final String TEST_PRODUCT1_NAME = 'Test Product 1';
    public static final String TEST_PRODUCT2_NAME = 'Test Product 2';
    public static final String TEST_PRODUCT3_NAME = 'Test Product 3';
    public static final String TEST_PRICELIST_NAME = 'Test PriceList';
    public static final String TEST_MATRIX_NAME = 'Test Matrix';
    public static final String TEST_APPROVAL_REGION = 'JAPAN Region';
    public static final String TEST_APPROVAL_LEVEL = 'Level 2a';
    public static final String TEST_APPROVAL_COUNTRY = 'JP';
    public static final String TEST_MKTG_AFFILIATE = 'Affiliate';
    public static final String TEST_MKTG_BRAND = 'Brand';
    public static final String TEST_MKTG_INSTANCE_HCP = 'HCP';
    public static final String TEST_MKTG_INSTANCE_CONSUMER = 'Consumer';
}