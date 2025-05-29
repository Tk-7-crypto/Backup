/**
 * This test class is used to test all methods in CON_OCE.
 * version : 1.0
 */
@IsTest
private class TST_CON_OCE {
    
    @IsTest
    static void testConstant() {
        Test.startTest();
            String yesString = CON_OCE.YES;
            String noString = CON_OCE.NO;
            String none = CON_OCE.NONE;
            String finalized = CON_OCE.STATUS_FINALIZED;
            String newStatus = CON_OCE.STATUS_NEW;
            String agreement = CON_OCE.AGREEMENT_BUSINESS_OBJECT;
            String mktgPriceType = CON_OCE.MKTG_PRICING_TYPE;
            String salesPriceType = CON_OCE.SALES_PRICING_TYPE;
            String salesOptionGroup = CON_OCE.SALES_PRIMARY_OPTION_GROUP;
            String mktgProduct = CON_OCE.MKTG_PRODUCT;
            String productService = CON_OCE.PRODUCT_SERVICE;
            String productOption = CON_OCE.PRODUCT_OPTION;
            String adminGroup = CON_OCE.ADMIN_SALES_GROUP;
            String corporateGroup = CON_OCE.CORPORATE_SALES_GROUP;
            String enterpriseGroup = CON_OCE.ENTERPRISE_SALES_GROUP;
            String mktgAddOn = CON_OCE.MKTG_ADDON;
            String subscriptionFee = CON_OCE.SUBSCRIPTION_FEE_CHARGE_TYPE;
            String implementationFee = CON_OCE.IMPLEMENT_FEE_CHARGE_TYPE;
            String addOnChargeType = CON_OCE.ADD_ON_CHARGE_TYPE;
            String totalFee = CON_OCE.TOTAL_FEE;
            String dateFormat = CON_OCE.DATE_FORMAT;
            String priceListName = CON_OCE.PRICELIST_NAME;
            String statusApproved = CON_OCE.STATUS_APPROVED;
            String statusAutoApproved = CON_OCE.STATUS_AUTO_APPROVED;
            String subscriptionType = CON_OCE.SUBSCRIPTION_TYPE;
            String testimonial = CON_OCE.TESTIMONIAL;
            String multiSubscription = CON_OCE.MULTI_SUBSCRIPTION;
            String dataPurchase = CON_OCE.DATA_PURCHASE;
            String addlEconomicCon = CON_OCE.ADDITIONAL_ECONOMIC_CONCESSION;
            String lineNumber = CON_OCE.LINE_ITEM_LINE_NUMBER;
            String bundleCloneSettings = CON_OCE.BUNDLE_CLONE_SETTINGS;
            String batchJobCompleted = CON_OCE.BATCH_JOB_COMPLETED;
            String countryZoneMatrix = CON_OCE.COUNTRY_ZONE_MATRIX;
            Integer defaultBatchSize = CON_OCE.DEFAULT_CLONE_BATCH_SIZE;
            Integer defaultMaxCountries = CON_OCE.DEFAULT_COUNTRIES_TO_WAIT;
            String cloneBundleTemplate = CON_OCE.CLONE_BUNDLE_TEMPLATE;
            String cartSaved = CON_OCE.CART_SAVED;
            String summaryGroupFilter = CON_OCE.SUMMARY_GROUP_FILTER;
            String summaryGroupExtPrice = CON_OCE.SUMMARY_GROUP_EXT_PRICE;
            String adjustmentAgmtId = CON_OCE.ADJUSTMENT_AGMT_ID;
            String adjustmentLineItemId = CON_OCE.ADJUSTMENT_LINE_ITEM_ID;
            String adjustmentLineType = CON_OCE.ADJUSTMENT_LINE_TYPE;
            String adjustmentIncentiveAmt = CON_OCE.ADJUSTMENT_INCENTIVE_AMT;
            String agreementAutoApproved = CON_OCE.AGREEMENT_AUTOAPPROVED;
            String subTypeAdminLabel = CON_OCE.SUBTYPE_ADMIN_LABEL;
            String subTypeTotalLabel = CON_OCE.SUBTYPE_TOTAL_LABEL;
            Integer validationMaxLines = CON_OCE.VALIDATION_MAX_DISPLAY_LINES;
        Test.stopTest();

        String testdate = ((Datetime) System.today()).format(dateFormat);
        System.assertNotEquals(null, testdate);
        Set<String> subFeeFieldSet = CON_OCE.SUBSCRIPTION_FEE_FIELD_SET;
        Set<String> subTermFieldSet = CON_OCE.SUBSCRIPTION_TERM_FIELD_SET;
        Set<String> agmtFieldSet = CON_OCE.AGREEMENT_FIELD_SET;
        Set<String> agmtLineItemFieldSet = CON_OCE.AGREEMENT_LINE_ITEM_FIELD_SET;
        Set<String> cloneBundleFieldSet = CON_OCE.CLONE_BUNDLE_FIELD_SET;
        Set<String> validateLineItemFieldSet = CON_OCE.VALIDATE_LINE_ITEM_FIELD_SET;
        Set<String> configAgmtFieldSet = CON_OCE.CONFIG_AGREEMENT_FIELD_SET;
        Set<String> batchJobFieldSet = CON_OCE.BATCH_JOB_FIELD_SET;
        Set<String> batchJobFinished = CON_OCE.BATCH_JOB_FINISHED_VALUES;
    }
}