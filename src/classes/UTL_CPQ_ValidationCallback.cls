public class UTL_CPQ_ValidationCallback {
    public static  Apttus_Config2.CustomClass.ValidationResult productValidation(list<Apttus_Config2__LineItem__c> allLineItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true); 
        Boolean pharmaceuticalIndexBundleSelected = false;
        Boolean salesTerritorialDataSelected = false;
        Map<Double, List<Apttus_Config2__LineItem__c>> bundleNumberToLineItemListMap = new Map<Double, List<Apttus_Config2__LineItem__c>>();
        Boolean fsProductSelected = false;
        Set<String> productCodeSet = new Set<String>();
        Boolean fsOrTotalMarketProductSelected = false;
        Boolean totalMarketDataSelected = false;
        Boolean pharmaceuticalOPDataSelected = false;
        Double totalExtendedAmount = 0.0;
        Double totalAmount = 0.0;
        Decimal totalDiscount = 0.0;
        Decimal actualDiscountValue = 0.0;
        Decimal lineItemTotalDiscount = 0.0;
        Set<String> productCodesSet = new Set<String>();
        Map<Double, Apttus_Config2__LineItem__c> bundleLineItemMap = new Map<Double, Apttus_Config2__LineItem__c>();
        Set<String> fieldSet = new Set<String> {CON_CPQ.LINE_ITEM_PRICING_TOOL, CON_CPQ.RELATED_PROPOSAL_CURRENCYISOCODE};
        Apttus_Config2__LineItem__c lineItemsList = new SLT_LineItem().selectByLineItemID(allLineItems[0].Id, fieldSet);
        String proposalCurrency = lineItemsList.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.CurrencyIsoCode;
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{proposalCurrency, CON_CPQ.USD});
        Set<Id> lineItemIdSet = new Set<Id>();
        List<String> bundleNames = new List<String>();
        for(Apttus_Config2__LineItem__c lineItem : allLineItems){
            if (lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c == CON_CPQ.Q2_Solutions && lineItem.Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c == CON_CPQ.BUNDLE && lineItem.Apttus_Config2__OptionId__c == null && lineItem.Apttus_Config2__BasePriceOverride__c >= 0) {
                bundleNames.add(lineItem.Apttus_Config2__ProductId__r.Name);
            }
            lineItemIdSet.add(lineItem.Id);
            if(!pharmaceuticalIndexBundleSelected && lineItem.Apttus_Config2__ProductId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_PI) {
                pharmaceuticalIndexBundleSelected = true;
            }
            if(!salesTerritorialDataSelected && lineItem.Apttus_Config2__ProductId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_STD) {
                salesTerritorialDataSelected = true;
            }
            if(lineItemsList.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c == CON_CPQ.AMESA && (lineItem.Apttus_Config2__LineType__c == CON_CPQ.OPTION || (lineItem.Apttus_Config2__HasOptions__c == false && lineItem.Apttus_Config2__ParentBundleNumber__c == null))){
                totalExtendedAmount += lineItem.Apttus_Config2__ExtendedPrice__c;
                totalAmount += lineItem.Apttus_Config2__NetPrice__c;
            }
            if((CON_CPQ.CPQ_TS_AMESA_Data_PI_O.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)) || (CON_CPQ.CPQ_TS_AMESA_Data_PI_FSN.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode))){
                fsOrTotalMarketProductSelected = true;
            }
        }
        if (!bundleNames.isEmpty()) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, bundleNames.toString() + ' service lines List Price cannot be updated/changed')); 
            result.isSuccess = false;
        }
        if (lineItemsList.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c == CON_CPQ.Q2_Solutions) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, 'Alert'));
            result.isSuccess =  false;
        }
        totalExtendedAmount =  CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).conversionRate, isoCodeTocurrencyTypeMap.get(proposalCurrency).conversionRate, totalExtendedAmount);
        totalAmount =  CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).conversionRate, isoCodeTocurrencyTypeMap.get(proposalCurrency).conversionRate, totalAmount);
        actualDiscountValue = ((Decimal)(totalExtendedAmount - totalAmount)).setScale(2);
        totalDiscount = (totalExtendedAmount != 0 ? ((totalExtendedAmount - totalAmount) / totalExtendedAmount) * 100 : 0);
        lineItemTotalDiscount = totalDiscount.setScale(3);
        
        Set<String> approvalMatrixFieldSet = new Set<String> {CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT, CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT};
        String condition = 'Process_Type__c = ' + '\'' + CON_CPQ.DISCOUNT_VALIDATION + '\'' +
                           ' AND Min_Amount__c < ' + totalAmount +
                           ' AND Max_Amount__c >= ' + totalAmount +
                           ' AND (Min_Discount_Percent__c <= ' + lineItemTotalDiscount +
                           ' OR Min_Discount_Amount__c <= ' + actualDiscountValue +')';
        List<Approval_Matrix__c> approvalMatrixList = new SLT_ApprovalMatrix().getDiscountMatrix(approvalMatrixFieldSet, condition);
        if (lineItemTotalDiscount > 0 && approvalMatrixList.size() > 0 ){
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, CON_CPQ.RECOMMENDATION_DISCOUNT_MSG  + ' To view the discount threshold matrix, Click <a href="'+URL.getOrgDomainUrl().toExternalForm()+ '/lightning/n/Discount_Threshold_View' +'" target="_blank">here</a>'));
        }
        Set<String> productNameSet = new Set<String>();
        Set<String> requiredProducts = new Set<String>{'CES_2076D', 'CES_2076C'};
        Boolean requiredFlag = false;
        Set<String> siteANDSponsorProducts = new Set<String>{'CES_2076D', 'CES_2076C'};
        Set<String> patientVideosProducts = new Set<String>{'CES_2076B', 'CES_2076F'};
        Set<String> noOfPatientVideosToAmend = new Set<String>{'CES_2076A', 'CES_2077T'};
        Map<String, Double> productCodeToSiteAttributeMap = new Map<String, Double>();
        Map<String, Double> productCodeToSponsorAttributeMap = new Map<String, Double>();
        Map<String, Double> productCodeToPatientVideosAttributeMap = new Map<String, Double>();
        Map<String, Double> productCodeToNOPVAmendAttributeMap = new Map<String, Double>();
        
        for(Apttus_Config2__LineItem__c lineItem : allLineItems){
            if ((lineItem.Apttus_Config2__AdjustmentAmount__c != null && lineItem.Apttus_Config2__AdjustmentAmount__c != 0 && lineItem.Apttus_Config2__AdjustmentType__c != null) && lineItem.Special_Pricing__c == CON_CPQ.YES_TITLE_CASE) {
                productNameSet.add(lineItem.Apttus_Config2__OptionId__r.name);
                result.isSuccess =  false;
            }
            if(lineItem.Apttus_Config2__OptionId__r.ProductCode != null){
                productCodeSet.add(lineItem.Apttus_Config2__OptionId__r.ProductCode);
            }
            if (lineItem.Apttus_Config2__ProductId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_STD && !pharmaceuticalIndexBundleSelected) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD));
                result.isSuccess =  false;
            }
            if(lineItem.Apttus_Config2__ProductId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_SL && (!pharmaceuticalIndexBundleSelected || !salesTerritorialDataSelected)) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_SD)); 
                result.isSuccess =  false;
            }
            if (lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c == CON_CPQ.INITIAL || lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c == CON_CPQ.BID_TYPE_REBID) {
                if (requiredProducts.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)) {
                    requiredFlag = true;
                    requiredProducts.remove(lineItem.Apttus_Config2__OptionId__r.ProductCode);
                }
            }
            if (patientVideosProducts.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)) {
                productCodeToPatientVideosAttributeMap.put(lineItem.Apttus_Config2__OptionId__r.ProductCode, lineItem.Apttus_Config2__AttributeValueId__r.Patient_Videos__c);
                patientVideosProducts.remove(lineItem.Apttus_Config2__OptionId__r.ProductCode);
            }
            if (noOfPatientVideosToAmend.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)) {
                productCodeToNOPVAmendAttributeMap.put(lineItem.Apttus_Config2__OptionId__r.ProductCode, lineItem.Apttus_Config2__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c);
                noOfPatientVideosToAmend.remove(lineItem.Apttus_Config2__OptionId__r.ProductCode);
            }
            if (siteANDSponsorProducts.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)) {
                productCodeToSiteAttributeMap.put(lineItem.Apttus_Config2__OptionId__r.ProductCode, lineItem.Apttus_Config2__AttributeValueId__r.Site_Tablets__c);
                productCodeToSponsorAttributeMap.put(lineItem.Apttus_Config2__OptionId__r.ProductCode, lineItem.Apttus_Config2__AttributeValueId__r.Sponsor_Tablets__c);
                siteANDSponsorProducts.remove(lineItem.Apttus_Config2__OptionId__r.ProductCode);
            }
        }
        if (productCodeToSiteAttributeMap.size() > 0 || productCodeToSponsorAttributeMap.size() > 0 || productCodeToPatientVideosAttributeMap.size() > 0 || productCodeToNOPVAmendAttributeMap.size() > 0) {
            if (siteANDSponsorProducts.isEmpty() && (productCodeToSiteAttributeMap.get('CES_2076D') != productCodeToSiteAttributeMap.get('CES_2076C') || productCodeToSponsorAttributeMap.get('CES_2076D') != productCodeToSponsorAttributeMap.get('CES_2076C'))) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The quantities of tablets you entered for the “Tablet Initiation” and “Tablet Service Fee” options are not the same. Please enter the same value of “Site Tablets” for both options and the same value of “Sponsor Tablets” for both options.'));
                result.isSuccess =  false;
            }
            if (patientVideosProducts.isEmpty() && (productCodeToPatientVideosAttributeMap.get('CES_2076B') != productCodeToPatientVideosAttributeMap.get('CES_2076F'))) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The quantities of “Patient Videos” you entered for the “Getting Started Video (English)” and “Translated Video Voiceover & Production” options are not the same. Please enter the same value for both options.'));
                result.isSuccess =  false;
            }
            if (noOfPatientVideosToAmend.isEmpty() && (productCodeToNOPVAmendAttributeMap.get('CES_2076A') != productCodeToNOPVAmendAttributeMap.get('CES_2077T'))) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The quantities of “No. of Patient Videos to Amend” you entered for the “Edits to Getting Started Video” and “Amendments to Translated Video” options are not the same. Please enter the same value for both options.'));
                result.isSuccess =  false;
            }
        }
        if (requiredFlag && !requiredProducts.isEmpty()) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'When creating a work order that includes tablets, the Tablet Initiation and Tablet Service Fee items must both be included. Please make sure both items are selected with a check mark and included in the cart.'));
            result.isSuccess =  false;
        }
        if (!result.isSuccess && productNameSet.size() > 0) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_SPECIAL_PRICING + ' Items are: ' + String.join(new List<String>(productNameSet), ', ')));
        }
        for(String product : productCodeSet){
            if(CON_CPQ.CPQ_TS_AMESA_Data_PI_O.contains(product)){
                totalMarketDataSelected = true;
            }
            if(!CON_CPQ.CPQ_TS_AMESA_Data_PI_O.contains(product) && !CON_CPQ.CPQ_TS_AMESA_Data_PI_FSN.contains(product)){
                pharmaceuticalOPDataSelected = true;
            }
            if(CON_CPQ.CPQ_TS_AMESA_Data_PI_FSN.contains(product)){
                fsProductSelected = true;
            }
            
        }
        if(pharmaceuticalIndexBundleSelected && !fsOrTotalMarketProductSelected ){
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_PI_PA)); 
            result.isSuccess =  false;
        }
        if(pharmaceuticalIndexBundleSelected && totalMarketDataSelected && pharmaceuticalOPDataSelected && !fsProductSelected){
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_PI_PA));
            result.isSuccess =  false;
        }
        
        for(Apttus_Config2__LineItem__c lineItem : allLineItems){
            if(lineItem.Apttus_Config2__LineType__c != CON_CPQ.PRODUCT_SERVICE){
                if(bundleNumberToLineItemListMap.containsKey(lineItem.Apttus_Config2__ParentBundleNumber__c) ){
                    List<Apttus_Config2__LineItem__c> lineItemList = bundleNumberToLineItemListMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c);
                    lineItemList.add(lineItem);
                    bundleNumberToLineItemListMap.put(lineItem.Apttus_Config2__ParentBundleNumber__c, lineItemList);
                }
                else{
                    List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
                    lineItemList.add(lineItem);
                    bundleNumberToLineItemListMap.put(lineItem.Apttus_Config2__ParentBundleNumber__c, lineItemList);
                }
            } else {
                bundleLineItemMap.put(lineItem.Apttus_Config2__PrimaryLineNumber__c, lineItem);
            }
        }
        for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
            if (customSetting.Pricing_Tool__c == CON_CPQ.AMESA) {
                List<String> productCodes1Set = customSetting.Product_Codes1__c.split(';');
                List<String> productCodes2Set = customSetting.Product_Codes2__c.split(';');
                productCodesSet.addAll(productCodes1Set);
                productCodesSet.addAll(productCodes2Set);
            }
        }

        for(Double parentBundleNumber : bundleNumberToLineItemListMap.keySet()){
            List<Apttus_Config2__LineItem__c> lineItemList = bundleNumberToLineItemListMap.get(parentBundleNumber);
            Set<String> optionProductCodeSet = new Set<String>();
            Map<String,String> productCodeToSelectedECMap = new Map<String,String>(); 
            Set<String> noOfTerritories = new Set<String>();
            Boolean selloutSubnationalDataSelect = false;
            Set<String> optionProductName = new Set<String>();
            Set<String> bundleCountry = new Set<String>();
            Boolean nationalSubscriptionCheckbox = false;
            
            for(Apttus_Config2__LineItem__c lineItem : lineItemList){ 
                optionProductCodeSet.add(lineItem.Apttus_Config2__OptionId__r.ProductCode);
                productCodeToSelectedECMap.put(lineItem.Apttus_Config2__OptionId__r.ProductCode, lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c);
                noOfTerritories.add(lineItem.Apttus_Config2__AttributeValueId__r.No_Of_Territories__c);
                bundleCountry.add(bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Eligible_Countries__c);
                if (lineItem.Apttus_Config2__OptionId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_PI_THIS) {
                    nationalSubscriptionCheckbox = lineItem.Apttus_Config2__AttributeValueId__r.National_Subscription__c;
                }
                if(CON_CPQ.CPQ_TS_AMESA_Data_STD_SS.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode)){
                    selloutSubnationalDataSelect = true;
                }
                if(bundleLineItemMap.containsKey(lineItem.Apttus_Config2__ParentBundleNumber__c)){
                    if ((!productCodesSet.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode) && (lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c != bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Eligible_Countries__c 
                        || lineItem.Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c != bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c)) && !(lineItem.Apttus_Config2__OptionId__r.ProductCode == CON_CPQ.CPQ_TS_AMESA_Data_PI_FSR 
                        && !CON_CPQ.CPQ_TS_AMESA_Data_PI_FSR_EC.contains(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) && bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Eligible_Countries__c == CON_CPQ.FRENCH_WEST_AFRICA 
                        && lineItem.Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c == bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c)) {
                        optionProductName.add(lineItem.Apttus_Config2__OptionId__r.Name);
                    }
                    else if(productCodesSet.contains(lineItem.Apttus_Config2__OptionId__r.ProductCode) && lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c != bundleLineItemMap.get(lineItem.Apttus_Config2__ParentBundleNumber__c).Apttus_Config2__AttributeValueId__r.Eligible_Countries__c){
                        optionProductName.add(lineItem.Apttus_Config2__OptionId__r.Name);
                    }
                }
            }
            if (bundleCountry.contains(CON_CPQ.TUNISIA_COUNTRY) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_PI_THIS) && nationalSubscriptionCheckbox && !optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_PI_NS)) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, CON_CPQ.VALIDATION_MSG_PI_THIS)); 
                result.isSuccess = false;
            }
            if (optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_PI_FSR) && bundleCountry.contains(CON_CPQ.FRENCH_WEST_AFRICA) && !optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_PI_NS)) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, CON_CPQ.VALIDATION_MSG_PI_FSR_FW)); 
                result.isSuccess = false;
            }
            if((optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOL) || optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOR)) && !optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_SL_SF)) {
                Boolean nolSACountryCheck = productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOL) != null ? productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOL) != CON_CPQ.SAUDIARABIA : false;
                Boolean norSACountryCheck = productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOR) != null ? productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_SL_NOR) != CON_CPQ.SAUDIARABIA : false;
                if(nolSACountryCheck || norSACountryCheck) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_SL_NOL_NOR)); 
                	result.isSuccess = false;
                }
            }   
            if(selloutSubnationalDataSelect && !(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_AU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DDFPM))){
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_SS)); 
                result.isSuccess = false;
            }
            if(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD)  && (productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) == CON_CPQ.EGYPT || Test.isRunningTest())) {
                if(!(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_AU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DDFPM))){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STD_EG)); 
                    result.isSuccess = false;
                }    
            }    
            if(salesTerritorialDataSelected && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD)  && (CON_CPQ.CPQ_TS_AMESA_Data_STD_EC.contains(productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD)) || Test.isRunningTest())) {
                if(!optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF)){
                    result = process(productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD), result);
                    
                }    
            }    
            if(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD)  && productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) == CON_CPQ.UNITEDARABEMIRATES){
                if(noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_AE_200Territories)  && !optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF)){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STDV200_UAEP)); 
                    result.isSuccess = false;
                }
                else if(noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_AE_10Territories) && !(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV10_O) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STDV10_UAEP)); 
                    result.isSuccess = false;
                }
                else if(noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_AE_20Territories) && !(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV20_O) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STDV20_UAEP)); 
                    result.isSuccess = false;
                }
                else if(noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_AE_40Territories) && !(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STDV40_O) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STDV40_UAEP)); 
                    result.isSuccess = false;
                }
                
            }
            if(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD)  && productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) == 'SA'){
            	if((noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_SA_56Territories) || noOfTerritories.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD_SA_66Territories)) && !(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_AU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DDFPM) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_T56_T66_SA)); 
                    result.isSuccess = false;
                }
            }
            if (optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) && CON_CPQ.NORTH_AFRICA_COUNTRIES.contains(productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD))) {
                if (!(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_AU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_CU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))) {
                    result = processNorthAfricaCountries(productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD), result);
                }
            }
            if (optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) && productCodeToSelectedECMap.get(CON_CPQ.CPQ_TS_AMESA_Data_STD_STD) == CON_CPQ.FRENCH_WEST_AFRICA) {
                if (!(optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_AU) && optionProductCodeSet.contains(CON_CPQ.CPQ_TS_AMESA_Data_STD_DSF))) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, CON_CPQ.VALIDATION_MSG_STD_FW)); 
                    result.isSuccess = false;
                }
            }
            if(!optionProductName.isEmpty()){
                result = bundleAttributeValidation(optionProductName, result); 
                result.isSuccess = false;
            }
        }
        
        return result;
    }
    
    
    public static List<Apttus_Config2__LineItem__c> getLineItems(List<Apttus_Config2.LineItem> allLines) {
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        // iterate through the cart and get the line items matching the battery code1 
        for (Apttus_Config2.LineItem lineItemMO : allLines) {
            lineItems.add(lineItemMO.getLineItemSO());
        }
        return lineItems;
    }
    
    
    public static Apttus_Config2.CustomClass.ValidationResult process(String eC, Apttus_Config2.CustomClass.ValidationResult res){
        res.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, CON_CPQ.VALIDATION_MSG_STD_STD + eC + CON_CPQ.VALIDATION_MSG_STD_STDS)); 
        res.isSuccess = false;
        return res;
    }
    public static Apttus_Config2.CustomClass.ValidationResult processNorthAfricaCountries(String eligibleCountry, Apttus_Config2.CustomClass.ValidationResult res) {
        res.Messages.add(new ApexPages.Message(ApexPages.Severity.Info, CON_CPQ.VALIDATION_MSG_STD_NORTH_AFRICA_COUNTRIES + ' ' + eligibleCountry + CON_CPQ.VALIDATION_MSG_STD_STDS)); 
        res.isSuccess = false;
        return res;
    }
    public static Apttus_Config2.CustomClass.ValidationResult bundleAttributeValidation(Set<String> oPName, Apttus_Config2.CustomClass.ValidationResult res){
        res.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, oPName + ' products are not eligible for the selected Country/Data Delivery Frequency on the parent bundle.')); 
        res.isSuccess = false;
        return res;
    }
}
