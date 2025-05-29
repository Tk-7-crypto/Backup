/**
* Description: Controller class for lwcCrmEditProductsiBNF
* Authour: Ronak Mehta
*/
public class CNT_CRM_Edit_Products_iBNF {
    
    public Static Final Set<String> bnfFieldSet = new Set<String>{'Id', 'Name', 'RecordTypeId', 'Addendum__c', 'Opportunity__c', 'Contract_Start_Date__c', 'Contract_End_Date__c', 'Sales_Org_Code__c', 'Opportunity__r.Account.Region_Territory__c', 'Opportunity_Number__c', 'BNF_Status__c'};
    public Static Final String bnfSubmittedError = 'BNF is submitted for approval and cannot be edited.';
    public Static Final String bnfApprovedError = 'BNF has been approved and cannot be edited.';
    public Static Final String bnfAcceptedError = 'BNF has been accepted for SAP load and cannot be edited.';
    
    /**
     * This Method to return basic data to render lwc
     * @param String recId: BNF recordId
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchAllDetails(String recId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Set<String> errorMsgSet = new Set<String>();
        Boolean isRecordLocked = false;
        Boolean isNewBnf = false;
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        BNF2__c bnf = new SLT_BNF().selectById(new Set<Id>{recId}, bnfFieldSet)[0];
        if(bnfSetting.BNF_Opportunity_Threshold__c != null  && bnf.Opportunity_Number__c !=null && bnf.Opportunity_Number__c != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(bnf.Opportunity_Number__c)) {
            isNewBnf = true;
        }
        User currentUser = new SLT_User().getUserById(new Set<Id> {UserInfo.getUserId()}, new Set<String>{'Id', 'Profile.Name'})[0];
        returnMap.put('bnf',bnf);
        
        /** record lock checking start **/
        List<ProcessInstanceWorkitem> PIW_List = new SLT_ProcessInstanceWorkitem().getAllPendingWorkItems(new Set<String>{'ActorId'}, new Set<Id>{bnf.Id});
        if(bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED')) {
            errorMsgSet.add(bnfApprovedError);
            isRecordLocked = true;
        }
        if(PIW_List.size() > 0) {
            Boolean hasAccessBNFAll = false;
            Set<Id> actorIdsSet = new Set<Id>();
            for(ProcessInstanceWorkitem workItem : PIW_List){
                actorIdsSet.add(workItem.ActorId);
            }
            List<PermissionSetAssignment> permSetAssList = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(new Set<String>{'Id'}, new Set<Id>{Userinfo.getUserId()}, 'Modify_all_privileges_on_BNF');
            if(permSetAssList.size() > 0) {
                hasAccessBNFAll = true;
            }
            if(isNewBnf) {
                if(currentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(CurrentUser.Id) || hasAccessBNFAll) {
                    isRecordLocked = false;
                } else if(bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING')) {
                    errorMsgSet.add(bnfAcceptedError);
                    isRecordLocked = true;
                } else {
                    errorMsgSet.add(bnfSubmittedError);
                    isRecordLocked = true;
                }
            } else {
                if(bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && (currentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(currentUser.Id) || hasAccessBNFAll )){
                    isRecordLocked = false;
                } else if(bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED')){
                    errorMsgSet.add(bnfSubmittedError);
                    isRecordLocked = true;
                } else if(bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING'))  {
                    errorMsgSet.add(bnfAcceptedError);
                    isRecordLocked = true;
                }
            }
        }
        if(isRecordLocked){
            returnMap.put('isRecordLocked',true);
            return  returnMap;
        }
        /** record lock checking End **/
        
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        /* remaining fields 
[PricebookEntry.Product2.Offering_Group__c, PricebookEntry.Product2.Offering_Type__c, Book_No__c, Business_Type__c, 
PO_Number__c, Product2.Id,Product2.ProductCode, Name, Product2.Name, UnitPrice, OpportunityId];
*/
        List <OpportunityLineItem> opptyLineItem2 = [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c, PO_Number__c,
                                                     Billing_Frequency__c, Sales_Text__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                                     Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyIsoCode, Budget_Therapy_Area__c, 
                                                     PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                                     PricebookEntry.Product2.Material_Group_1__c, PricebookEntry.Product2.Item_Category_Group__c, Other_Ship_To_Address__c, Other_Ship_To_SAP_Contact__c,Other_Ship_To_Address__r.Name, Other_Ship_To_SAP_Contact__r.Name,
                                                     Project_Start_Date__c, Project_End_Date__c, Billing_Schedule_Error_Msg__c, Revenue_Schedule_Error_Msg__c, Surcharge_Text__c, Revised_Revenue_Schedule__c, Opportunity.CEQActiveRelease__c, Delivery_Date__c
                                                     FROM OpportunityLineItem WHERE OpportunityId = :bnf.Opportunity__c AND Product_Material_Type__c NOT IN :excludedProducts 
                                                     ORDER BY PricebookEntry.ProductCode ASC, Product_Start_Date__c ASC];
        if(isNewBnf){
            for(OpportunityLineItem Oli: opptyLineItem2){
                if(oli.List_Price__c == null){
                    oli.List_Price__c = oli.TotalPrice;
                }
                if(oli.PricebookEntry.Product2.Material_Type__c == 'ZREP' || (oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC')){
                    oli.Billing_Frequency__c = null;
                    oli.Billing_Date__c = null;
                    oli.Proj_Rpt_Frequency__c = null;
                    oli.Delivery_Date__c = null;
                    oli.Invoice_Lag_to_Data_Period__c = null;
                }
                //Added By Himanshu : MIS Issue-05083: 12-Aug-2014
                if(oli.PricebookEntry.Product2.Material_Type__c == 'ZREP'){
                    if(!bnf.Addendum__c){//  Don't overwrite the data start date for revised BNF's as users need to be able to change this
                        oli.Product_Start_Date__c = oli.Project_Start_Date__c;
                    }
                    oli.Product_End_Date__c = oli.Project_End_Date__c;
                }
                
                //Added By Pramod : 06334 - Therapy area on Opportunity Line Item should be set to same as budget
                if(oli.PricebookEntry.Product2.Material_Type__c =='ZREP' && oli.Budget_Therapy_Area__c != null) {
                    oli.Therapy_Area__c = oli.Budget_Therapy_Area__c;
                }
                
                //  This gets the latest revised price that has been entered in the OLI.Revised_revenue_Schedule__c field but
                //  OLI.Revised_Price__c has not yet been updated on the OLI
                if(oli.Revised_Revenue_Schedule__c != null){
                    List<String> strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');
                    //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                    if (strRevSchedule[0] == 'x'){
                        strRevSchedule.clear();
                    }
                    oli.Revised_Price__c = 0;
                    for (integer i=0;i<strRevSchedule.size();i++){
                        //  Overwrite the Revised_Price__c to have the latest value as entered on revised revenue schedule
                        oli.Revised_Price__c += Decimal.valueOf(strRevSchedule[i].split(':')[1]);
                    }                   
                }
            }
        }
        returnMap.put('opptyLineItem2',opptyLineItem2);
        
        List<Document> glossaryDocumentList = new SLT_Document().selectByDeveloperName(MDM_Defines.Document_Dev_Name_IMSSFDCGlossary);
        if(glossaryDocumentList.size() > 0){
            returnMap.put('glossaryDocumentId',glossaryDocumentList[0].Id);
        }
        returnMap.putAll(setPickListValues(opptyLineItem2));
        return  returnMap;
    }
    
    /**
     * This Helper Method to return picklist options based on OLI
     * @param List<OpportunityLineItem>
     * @return Map<String, Object>
     */
    private static Map<String, Object> setPickListValues(List<OpportunityLineItem> opptyLineItem2){
        Map<String, Object> returnMap = new Map<String, Object>();
        
        // Start: DeliveryMedia_Map Base creation
        List<Map<String,String>> allDeliveryMediaList = new List<Map<String,String>>();// List{Map('label','--None--'),Map('value','')> 
        Map<String, Map<String,String>> deliveryMediaKeyToValueMap = new Map<String, Map<String,String>>();
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Delivery_Media__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allDeliveryMediaList.add(optionMap);
            deliveryMediaKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), optionMap);
        }
        
        // Start: DeliveryFrequency_Map Base creation
        List<Map<String,String>> allDeliveryFrequencyList = new List<Map<String,String>>();
        Map<String, Map<String,String>> deliveryFrequencyKeyToValueMap = new Map<String, Map<String,String>>();
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allDeliveryFrequencyList.add(optionMap);
            if(pickEntry.getLabel() !='Other'){
                deliveryFrequencyKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), optionMap);
            }
        }
        // Start: BillingFrequency_Map Base creation
        List<Map<String,String>> allBillingFrequencyList = new List<Map<String,String>>();
        allBillingFrequencyList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Billing_Frequency__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allBillingFrequencyList.add(optionMap);
        }
        returnMap.put('allBillingFrequencyList',allBillingFrequencyList);
        
        // Start: DiscountReason_Map Base creation
        List<Map<String,String>> allDiscountReasonList = new List<Map<String,String>>();
        allDiscountReasonList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Discount_Reason__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allDiscountReasonList.add(optionMap);
        }
        returnMap.put('allDiscountReasonList',allDiscountReasonList);
        
        // Start: SaleType_Map Base creation
        List<Map<String,String>> allSaleTypeList = new List<Map<String,String>>();
        allSaleTypeList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Sale_Type__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allSaleTypeList.add(optionMap);
        }
        returnMap.put('allSaleTypeList',allSaleTypeList);
        
        // Start: RevenueType_Map Base creation
        List<Map<String,String>> allRevenueTypeList = new List<Map<String,String>>();
        allRevenueTypeList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Revenue_Type__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allRevenueTypeList.add(optionMap);
        }
        returnMap.put('allRevenueTypeList',allRevenueTypeList);
        
        // Start: InvoiceLagToDataPeriod_Map Base creation
        List<Map<String,String>> allInvoiceLagToDataPeriodList = new List<Map<String,String>>();
        allInvoiceLagToDataPeriodList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Invoice_Lag_to_Data_Period__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allInvoiceLagToDataPeriodList.add(optionMap);
        }
        returnMap.put('allInvoiceLagToDataPeriodList',allInvoiceLagToDataPeriodList);
        
        // Start: TherapyArea_Map Base creation
        List<Map<String,String>> allTherapyAreaList = new List<Map<String,String>>();
        Map<String, Map<String,String>> therapyAreaKeyToValueMap = new Map<String, Map<String,String>>();
        for(Schema.PicklistEntry pickEntry : OpportunityLineItem.Therapy_Area__c.getDescribe().getPicklistValues()){
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',pickEntry.getLabel());
            optionMap.put('value',pickEntry.getValue());
            allTherapyAreaList.add(optionMap);
            therapyAreaKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), optionMap);
        }
        
        // Start: allProfitCenterList_Map Base creation
        List<Map<String,String>> allProfitCenterList = new List<Map<String,String>>();
        allProfitCenterList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Profit_Centre__c region : [SELECT Id, name, (SELECT Id FROM Profit_Centres__r) FROM Profit_Centre__c WHERE Profit_Center_Code_Chain__c like '%(TOTGEO)%' ORDER BY Name]) {
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label',region.Name);
            optionMap.put('value',region.Id);
            allProfitCenterList.add(optionMap);
        }
        returnMap.put('allProfitCenterList',allProfitCenterList);
        
        Map<Id,List<Map<String,String>>> oliToDeliveryMediaMap = new Map<Id,List<Map<String,String>>> (); // id => List{Map('label','--None--'),Map('value','')> 
        Map<Id,List<Map<String,String>>> oliToDeliveryFrequencyMap = new Map<Id,List<Map<String,String>>> ();
        Map<Id,List<Map<String,String>>> oliToTherapyAreaMap = new Map<Id,List<Map<String,String>>> ();
        for(OpportunityLineItem oli: opptyLineItem2){
            List<Map<String,String>>  deliveryMediaOptionList = new List<Map<String,String>>();
            List<Map<String,String>>  deliveryFrequencyOptionList = new List<Map<String,String>>();
            List<Map<String,String>>  therapyAreaOptionList = new List<Map<String,String>>();
            deliveryMediaOptionList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
            deliveryFrequencyOptionList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
            therapyAreaOptionList.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
            if (oli.PricebookEntry.Product2.Delivery_Media__c == null || oli.PricebookEntry.Product2.Delivery_Media__c == ''){
                deliveryMediaOptionList.addAll(allDeliveryMediaList);
            }else{
                for (String deliveryMediaOption : oli.PricebookEntry.Product2.Delivery_Media__c.split(':')) {
                    if(deliveryMediaKeyToValueMap.containsKey(deliveryMediaOption)){}
                    deliveryMediaOptionList.add(deliveryMediaKeyToValueMap.get(deliveryMediaOption));
                }
            }
            
            if(oli.PricebookEntry.Product2.Delivery_Frequency__c == null || oli.PricebookEntry.Product2.Delivery_Frequency__c == ''){
                deliveryFrequencyOptionList.addAll(allDeliveryFrequencyList);
            }else{
                for (String deliveryFrequencyOption : oli.PricebookEntry.Product2.Delivery_Frequency__c.split(':')) {
                    if(deliveryFrequencyKeyToValueMap.containsKey(deliveryFrequencyOption)){}
                    deliveryFrequencyOptionList.add(deliveryFrequencyKeyToValueMap.get(deliveryFrequencyOption));
                }
            }
            
            if (oli.PricebookEntry.Product2.Therapy_Class__c == null || oli.PricebookEntry.Product2.Therapy_Class__c == '') {
                therapyAreaOptionList.addAll(allTherapyAreaList);
            }else{
                for (String therapyAreaOption : oli.PricebookEntry.Product2.Therapy_Class__c.split(':')) {
                    if(therapyAreaKeyToValueMap.containsKey(therapyAreaOption)){}
                    therapyAreaOptionList.add(therapyAreaKeyToValueMap.get(therapyAreaOption));
                }
            }
            oliToDeliveryMediaMap.put(oli.Id,deliveryMediaOptionList);
            oliToDeliveryFrequencyMap.put(oli.Id,deliveryFrequencyOptionList);
            oliToTherapyAreaMap.put(oli.Id,therapyAreaOptionList);
        }
        returnMap.put('oliToDeliveryMediaMap',oliToDeliveryMediaMap);
        returnMap.put('oliToDeliveryFrequencyMap',oliToDeliveryFrequencyMap);
        returnMap.put('oliToTherapyAreaMap',oliToTherapyAreaMap);
        return returnMap;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Billing_Schedule_Item__c> getBillingSchList(Id oppLiId){
        Set<String> fieldSet = new Set<String>{'Id', 'Billing_Amount__c', 'Billing_Date__c', 'CurrencyIsoCode'};
        return new SLT_BillingScheduleItem().getBillingScheduleItemOliId(new Set<Id>{oppLiId}, fieldSet);
    }
    
    /**
     * This Method to Save the OLIs in db
     * @param List<OpportunityLineItem>
     * @param String operationType
     * @param BNF2__c bnf
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> save(List<OpportunityLineItem> opptyLineItem2, String operationType, BNF2__c bnf){
        List<errorWrapper> errorMsgSet = new List<errorWrapper>();
        Map<String, Object> returnMap = new Map<String, Object>();
        if(operationType == 'validateAndSave'){
            errorMsgSet = validateOLI(opptyLineItem2, bnf);
        }else if(operationType == 'saveOnly'){
            errorMsgSet = validateOliForPartialSave(opptyLineItem2, bnf);
        }
        if(errorMsgSet.size() == 0){
            try{
                update opptyLineItem2;
                returnMap.put('Success', true);
            }catch(Exception ex){
                returnMap.put('error', ex.getMessage());
            }
        }else{
            returnMap.put('errorCNT', errorMsgSet);
        }
        return returnMap;
    }
    
    /**
     * This helper method validate the OLI in case of Final Save
     * @param List<OpportunityLineItem>
     * @param BNF2__c bnf
     * @return Map<String, Object>
     */
    private static List<errorWrapper> validateOLI(List<OpportunityLineItem> opptyLineItem2, BNF2__c bnf){
        //Set<String> errorMsgSet = new Set<String>();
        Integer POValueCount = 0;
        Integer POnullCount = 0;
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        Boolean isNewBnf = false;
        if(bnfSetting.BNF_Opportunity_Threshold__c != null && bnf.Opportunity_Number__c !=null && bnf.Opportunity_Number__c != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(bnf.Opportunity_Number__c)) {
            isNewBnf = true;
        }
        List<errorWrapper> errorWrapperList = new List<errorWrapper>();
        for(OpportunityLineItem oli: opptyLineItem2){
            if(oli.Product_End_Date__c == null && oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB'){
                //errorMsgSet.add('Data Period End: You must enter a value.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Product_End_Date__c', 'Data Period End', 'You must enter a value.'));
            }
            if(oli.Sale_Type__c == null || oli.Sale_Type__c == ''){
                //errorMsgSet.add('Sale Type: You must enter a value.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Sale_Type__c', 'Sale Type', 'You must enter a value.'));
            }
            if(oli.Revenue_Type__c == null || oli.Revenue_Type__c == ''){
                //errorMsgSet.add('Revenue Type: You must enter a value.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Revenue_Type__c', 'Revenue Type', 'You must enter a value.'));
            }
            if(oli.Billing_Date__c == null && oli.Billing_Frequency__c == 'Once'){
                //errorMsgSet.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Date__c', 'Billing Date', 'Billing date is mandatory when billing frequency "Once" is selected.'));
            }
            if(oli.Delivery_Date__c==null && oli.Proj_Rpt_Frequency__c == 'Once [O]'){
                //errorMsgSet.add('Delivery Date: Delivery date is mandatory when Delivery frequency "Once" is selected.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Delivery_Date__c', 'Delivery Date', 'Delivery date is mandatory when Delivery frequency "Once" is selected.'));
            }
            
            if(oli.PO_line_item_number__c != null){
                POValueCount++;
                if(!oli.PO_line_item_number__c.isNumeric()){
                    //errorMsgSet.add('PO line item number: PO Line Item Number should be filled Numbers only.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'PO_line_item_number__c', 'PO line item number', 'PO Line Item Number should be filled Numbers only.'));
                }
            }else{
                POnullCount++;
            }
        }
        if(POValueCount > 0 && POnullCount > 0){
            //errorMsgSet.add('PO line item number: PO Line Item Number should be filled or blank on all Products.');
            errorWrapperList.add(new errorWrapper(null, 'PO_line_item_number__c', 'PO line item number', 'PO Line Item Number should be filled or blank on all Products.'));
        }
        
        /** ValidateOLI method containt**/
        //The Revised_Revenue_Schedule__c and Billing_Schedule__r.Total_Billing_Amount__c can be changed in a popup window, hence we need to retrieve the latest value
        Map<Id,OpportunityLineItem> OLI_Map = new Map<Id,OpportunityLineItem>([SELECT Id, Nbr_of_Users__c, Revised_Revenue_Schedule__c,Billing_Schedule__r.Total_Billing_Amount__c,TotalPrice,Discount_Amount_Formula__c FROM OpportunityLineItem WHERE OpportunityId = :bnf.Opportunity__c]);
        
        Map<String,Boolean> OLIScheduleMapStartDate = new Map<String,Boolean>();
        Map<String,Boolean> OLIScheduleMapEndDate = new Map<String,Boolean>(); 
        Map<Id,OpportunityLineItem> opptyLineItem2_Map = new Map<Id,OpportunityLineItem>();
        for (OpportunityLineItem OLI:opptyLineItem2){
            opptyLineItem2_Map.put(OLI.Id,OLI);
        }
        //  Retrieve all OpportunityLineItemSchedules to validate against project start/end dates
        List<AggregateResult> OLSSchedule_Array = [Select MIN(ScheduleDate) StartDate, Max(ScheduleDate) EndDate, OpportunityLineItemId,OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c 
                                                   FROM OpportunityLineItemSchedule WHERE OpportunitylineitemId in : OLI_Map.keySet() AND OpportunityLineItem.PricebookEntry.Product2.Material_Type__c = 'ZREP'
                                                   GROUP BY OpportunityLineItem.Project_Start_Date__c, OpportunityLineItem.Project_End_Date__c, OpportunityLineItemId];
        for(AggregateResult agg : OLSSchedule_Array){
            Date StartDate = (bnf.Addendum__c ? opptyLineItem2_Map.get(String.valueof(agg.get('OpportunityLineItemId'))).Product_Start_Date__c : Date.valueof(agg.get('Project_Start_Date__c')));
            if(StartDate!=null && (Date.valueof(agg.get('StartDate')) < StartDate)){
                OLIScheduleMapStartDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
            }
            if(agg.get('Project_End_Date__c')!=null && (Date.valueof(agg.get('EndDate')) > Date.valueof(agg.get('Project_End_Date__c')))){
                OLIScheduleMapEndDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
            }           
        }
        
        for (OpportunityLineItem OLI:opptyLineItem2){
            //  Get the latest value for OLI.Revised_Revenue_Schedule__c
            if (OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c != null){
                OLI.Revised_Revenue_Schedule__c = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c;
            }
            //  Check revised revenue schedule against project start/end dates (only for ZREP products)
            if (OLI.Revised_Revenue_Schedule__c != null && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP'){
                List<String> strRevSchedule = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c.split('\\|');  
                //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                if (strRevSchedule[0] == 'x'){
                    strRevSchedule.clear();
                }
                String tempDate;
                Integer RevenueYear;
                Integer RevenueMonth;
                Integer RevenueDay;
                Date RevenueDate;   
                //  If any OLI id's were put into the error map because of the original (not revised) revenue schedules, remove them from the map                   
                OLIScheduleMapEndDate.remove(OLI.Id);
                OLIScheduleMapStartDate.remove(OLI.Id);
                for (integer i=0;i<strRevSchedule.size();i++){
                    tempDate = strRevSchedule[i].split(':')[0];
                    RevenueYear = Integer.valueOf(tempDate.left(4));
                    RevenueMonth = Integer.valueOf(tempDate.mid(4,2));
                    RevenueDay = Integer.valueOf(tempDate.right(2));
                    RevenueDate = Date.newInstance(RevenueYear,RevenueMonth,RevenueDay);
                    if (RevenueDate < OLI.Product_Start_Date__c){
                        OLIScheduleMapStartDate.put(OLI.Id,True);
                    }
                    if (RevenueDate > OLI.Project_End_Date__c){
                        OLIScheduleMapEndDate.put(OLI.Id,True);
                    }
                }       
            }
        }
        
        for(OpportunityLineItem oli : opptyLineItem2){
            Boolean notSetByOther =  (oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c !='ZLIC') ? true : false;
            if(isNewBnf){
                if (OLIScheduleMapStartDate.containskey(oli.id) && OLIScheduleMapStartDate.get(oli.id) == true || OLIScheduleMapEndDate.containskey(oli.id) && OLIScheduleMapEndDate.get(oli.id) == true){
                    //  If there is a revised price, put the error on the revised price field and the other field that can also be used to edit the revised revenue schedules.
                    if (OLI.Revised_Price__c != null){
                        //errorMsgSet.add('Revenue Schedule Error Msg: Revised revenue schedules must be within project start/end dates.');
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Revenue_Schedule_Error_Msg__c', 'Revenue Schedule Error Msg', 'Revised revenue schedules must be within project start/end dates.'));
                    }else{//  Else put the error on the field with the link to edit the OpportunityLineItemSchedules
                        //errorMsgSet.add('Revenue Schedule Error Msg: Revenue schedules must be within project start/end dates');
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Revenue_Schedule_Error_Msg__c', 'Revenue Schedule Error Msg', 'Revenue schedules must be within project start/end dates'));
                    }
                }
                if(oli.Product_Start_Date__c == null && (oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB'  || bnf.Addendum__c == true)){
                    //errorMsgSet.add('Data Period Start: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Product_Start_Date__c', 'Data Period Start', 'You must enter a value.'));
                }
                if ((oli.Billing_Frequency__c == '50% upon signature, 50% upon completion' || oli.Billing_Frequency__c == 'Other') && oli.Pricebookentry.product2.Material_Type__c == 'ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC') {
                    //errorMsgSet.add('Billing Frequency: \'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable for ZPUB products. Please select some other Billing Frequency.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Frequency__c', 'Billing Frequency', '\'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable for ZPUB products. Please select some other Billing Frequency.'));
                }
                if(oli.Billing_Frequency__c == 'Once' && oli.Billing_Date__c == null && oli.PricebookEntry.Product2.Material_Type__c != 'ZREP') {
                    //errorMsgSet.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Date__c', 'Billing Date', 'Billing date is mandatory when billing frequency "Once" is selected.'));
                }
                if((oli.Proj_Rpt_Frequency__c == null || oli.Proj_Rpt_Frequency__c == '') && notSetByOther){
                    //errorMsgSet.add('Delivery/Rpt Frequency: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Proj_Rpt_Frequency__c', 'Delivery/Rpt Frequency', 'You must enter a value.'));
                }
                if((oli.Billing_Frequency__c == null || oli.Billing_Frequency__c == '') && notSetByOther){
                    //errorMsgSet.add('Billing Frequency: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Frequency__c', 'Billing Frequency', 'You must enter a value.'));
                }
                if(oli.Delivery_Media__c == null || oli.Delivery_Media__c == ''){
                    //errorMsgSet.add('Delivery Media: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Delivery_Media__c', 'Delivery Media', 'You must enter a value.'));
                }
                if((oli.Nbr_of_Users__c == null || oli.Nbr_of_Users__c <= 0) && (oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZPLI' || oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZPLU')){
                    //errorMsgSet.add('Number of Users: Please enter a non-zero amount for number of users.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Nbr_of_Users__c', 'Number of Users', 'Please enter a non-zero amount for number of users.'));
                }
                if((oli.Therapy_Area__c == null || oli.Therapy_Area__c == '') && oli.Pricebookentry.product2.Material_Type__c != 'ZREP'){
                    //errorMsgSet.add('Therapy Area: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Therapy_Area__c', 'Therapy Area', 'You must enter a value.'));
                }
            }else{
                if(oli.Billing_Frequency__c == 'Once' && oli.Billing_Date__c == null) {
                    //errorMsgSet.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Date__c', 'Billing Date', 'Billing date is mandatory when billing frequency "Once" is selected.'));
                }
                if(oli.Product_Start_Date__c == null && oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB'){
                    //errorMsgSet.add('Data Period Start: You must enter a value');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Product_Start_Date__c', 'Data Period Start', 'You must enter a value.'));
                }
                if(oli.Delivery_Media__c == null || oli.Delivery_Media__c == ''){
                    //errorMsgSet.add('Delivery Media: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Delivery_Media__c', 'Delivery Media', 'You must enter a value.'));
                }
                if(oli.Proj_Rpt_Frequency__c == null || oli.Proj_Rpt_Frequency__c == ''){
                    //errorMsgSet.add('Delivery/Rpt Frequency: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Proj_Rpt_Frequency__c', 'Delivery/Rpt Frequency', 'You must enter a value.'));
                }
                if(oli.Billing_Frequency__c== null || oli.Billing_Frequency__c== '') {
                    //errorMsgSet.add('Billing Frequency: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Frequency__c', 'Billing Frequency', 'You must enter a value.'));
                }
                if(oli.Therapy_Area__c == null || oli.Therapy_Area__c == ''){
                    //errorMsgSet.add('Therapy Area: You must enter a value.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Therapy_Area__c', 'Therapy Area', 'You must enter a value.'));
                }
            }
            
            if (oli.Product_Start_Date__c > bnf.Contract_End_Date__c && oli.Revenue_Type__c != 'Ad Hoc' && (isNewBnf ? oli.PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                //errorMsgSet.add('Data Period Start: Data period must start before contract end date');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Product_Start_Date__c', 'Data Period Start', 'Data period must start before contract end date.'));
            }     
            if (oli.Product_End_Date__c > bnf.Contract_End_Date__c && oli.Revenue_Type__c != 'Ad Hoc' && (isNewBnf ? oli.PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                //errorMsgSet.add('Data Period End: Data period must end before contract end date');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Product_End_Date__c', 'Data Period End', 'Data period must end before contract end date.'));
            }     
            if (oli.Revenue_Type__c != 'Back Data' && oli.Revenue_Type__c != 'Ad Hoc' && (isNewBnf ? oli.PricebookEntry.Product2.Material_Type__c!='ZREP' : true)) {
                if (oli.Product_End_Date__c < bnf.Contract_Start_Date__c){    
                    //errorMsgSet.add('Data Period End: Data period must end after contract start date.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Product_End_Date__c', 'Data Period End', 'Data period must end after contract start date.'));
                }
                if (oli.Product_Start_Date__c < bnf.Contract_Start_Date__c){
                    //errorMsgSet.add('Data Period Start: Data period must start after contract start date.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'Product_Start_Date__c', 'Data Period Start', 'Data period must start after contract start date.'));
                }
            }
            if (oli.PricebookEntry.ProductCode.toUpperCase().contains('PERF') && oli.Delivery_Date__c < oli.Product_End_Date__c) {
                //errorMsgSet.add('Delivery date: Delivery date cannot be earlier than data period end');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Delivery_Date__c', 'Delivery date', 'Delivery date cannot be earlier than data period end.'));
            }
            if(oli.Proj_Rpt_Frequency__c == 'Once [O]' &&  oli.PricebookEntry.Product2.Material_Type__c =='ZPUB' && oli.Billing_Frequency__c != 'Once'){
                //errorMsgSet.add('Billing Frequency: If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Proj_Rpt_Frequency__c', 'Billing Frequency', ' If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.'));
            }
            if(oli.ProfitCenter__c == null && oli.PricebookEntry.Product2.Material_Group_1__c =='MAN') {
                //errorMsgSet.add('Profit Center: Please Enter Profit Center.');
                errorWrapperList.add(new errorWrapper(oli.Id, 'ProfitCenter__c', 'Profit Center', 'Please Enter Profit Center.'));
            }
            if (oli.List_Price__c == null) {
                //errorMsgSet.add('List Price: Please Enter List price');
                errorWrapperList.add(new errorWrapper(oli.Id, 'List_Price__c', 'List Price', 'Please Enter List price.'));
            }
            
            Decimal SalesPrice = bnf.Addendum__c ? (oli.Revised_Price__c != null ? oli.Revised_Price__c : oli.TotalPrice)  : oli.TotalPrice;
            
            if(bnfSetting.Enable_BNF_Surcharge__c == true && (oli.Surcharge_Text__c == null || oli.Surcharge_Text__c == '') && (oli.Opportunity.CEQActiveRelease__c == null || oli.Opportunity.CEQActiveRelease__c == 0) && (oli.List_Price__c!=null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP)) )){
                //errorMsgSet.add('Surcharge Text: Please input Surcharge Text');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Surcharge_Text__c', 'Surcharge Text', 'Please input Surcharge Text.'));
            }
            
            if(bnfSetting.Enable_BNF_Surcharge__c == true && (oli.Discount_Reason__c == null || oli.Discount_Reason__c == '') && (oli.Opportunity.CEQActiveRelease__c == null || oli.Opportunity.CEQActiveRelease__c == 0) && (oli.List_Price__c!=null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) ))){
                //errorMsgSet.add('Discount Reason: Please input Discount reason');
                errorWrapperList.add(new errorWrapper(oli.Id, 'Discount_Reason__c', 'Discount Reason', 'Please input Discount reason.'));
            }
            
            if(bnfSetting.Enable_BNF_Surcharge__c == true &&  oli.List_Price__c != null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) )){
                oli.Surcharge_Text__c='';
            }else if(bnfSetting.Enable_BNF_Surcharge__c == true && oli.List_Price__c != null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                oli.Discount_Reason__c='';
            }else if(bnfSetting.Enable_BNF_Surcharge__c == true && oli.List_Price__c != null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) == SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                oli.Discount_Reason__c='';
                oli.Surcharge_Text__c='';
            }
            
            if(isNewBnf){
                if(oli.List_Price__c != null && oli.TotalPrice == 0 && oli.List_Price__c != 0 && (oli.PricebookEntry.Product2.Material_Type__c == 'ZREP' || oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC')){
                    //errorMsgSet.add('List Price: ZREP/ZLIC materials with zero value sales price must also have zero value list price.');
                    errorWrapperList.add(new errorWrapper(oli.Id, 'List_Price__c', 'List Price', 'ZREP/ZLIC materials with zero value sales price must also have zero value list price.'));
                }
                
                //  Check that billing schedule adds up to total of sales price/revised sales price
                if (oli.PricebookEntry.Product2.Material_Type__c == 'ZREP'|| oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC') {
                    Decimal ValidationPrice;
                    if (bnf.Addendum__c && oli.Revised_Price__c != null){
                        ValidationPrice = oli.Revised_Price__c.setScale(2);
                    }else{
                        ValidationPrice = oli.TotalPrice.setscale(2);
                    }
                    
                    if(OLI_Map.get(oli.id).Billing_Schedule__c == null && (oli.TotalPrice != 0 || oli.List_Price__c != null && (oli.TotalPrice - oli.List_Price__c) != 0)){                       
                        //errorMsgSet.add('No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').');
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Schedule_Error_Msg__c', 'Billing Schedule', 'No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').'));
                    }   
                    if( OLI_Map.get(oli.id).Billing_Schedule__c != null && OLI_Map.get(oli.id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) != ValidationPrice  && (oli.TotalPrice != 0 || oli.List_Price__c != null && (oli.TotalPrice - oli.List_Price__c) != 0)){
                        //errorMsgSet.add('Billing schedule total (' + OLI_Map.get(oli.id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').');
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Billing_Schedule_Error_Msg__c', 'Billing Schedule', 'Billing schedule total (' + OLI_Map.get(oli.id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').'));
                    }
                }
            }
        }
        return errorWrapperList;
    }
    
    
    /**
     * This helper method validate the OLI in case of Save Draft
     * @param List<OpportunityLineItem>
     * @param BNF2__c bnf
     * @return List<errorWrapper>
     */
    private static List<errorWrapper> validateOliForPartialSave(List<OpportunityLineItem> opptyLineItem2, BNF2__c bnf){
        List<errorWrapper> errorWrapperList = new List<errorWrapper>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        for(OpportunityLineItem oli : opptyLineItem2){
            if(bnfSetting.Enable_BNF_Surcharge__c == true && (oli.Opportunity.CEQActiveRelease__c == null || oli.Opportunity.CEQActiveRelease__c == 0) ){
                if(oli.Discount_Reason__c == null || oli.Discount_Reason__c == ''){
                    if(oli.List_Price__c != null && oli.Revised_Price__c != null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > oli.Revised_Price__c.setScale(2,system.roundingMode.HALF_UP))){
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Discount_Reason__c', 'Discount Reason', 'Please input Discount reason.'));
                    } else if(oli.List_Price__c != null && oli.Revised_Price__c == null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > oli.TotalPrice.setScale(2,system.roundingMode.HALF_UP))){
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Discount_Reason__c', 'Discount Reason', 'Please input Discount reason.'));
                    }
                }
                if(oli.Surcharge_Text__c==null || oli.Surcharge_Text__c==''){
                    if(oli.List_Price__c!=null && oli.Revised_Price__c!=null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < oli.Revised_Price__c.setScale(2,system.roundingMode.HALF_UP))){
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Surcharge_Text__c', 'Surcharge Text', 'Please input Surcharge Text.'));
                    } else if(oli.List_Price__c!=null && oli.Revised_Price__c==null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < oli.TotalPrice.setScale(2,system.roundingMode.HALF_UP))){
                        errorWrapperList.add(new errorWrapper(oli.Id, 'Surcharge_Text__c', 'Surcharge Text', 'Please input Surcharge Text.'));
                    }
                }
                
            }
        } 
        return errorWrapperList;
    }
    
    Public class errorWrapper {
        @AuraEnabled public String oliId;
        @AuraEnabled public String fieldApi;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String errorMessage;
        
        public errorWrapper(String oliId, String fieldApi, String fieldLabel, String errorMessage){
            this.oliId = oliId;
            this.fieldApi = fieldApi;
            this.fieldLabel = fieldLabel;
            this.errorMessage = errorMessage;
        }
    }
    
}