public class CNT_CRM_Edit_Products_eBNF {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchAllDetails(String recId){
        Map<String, Object> returnMap = new Map<String, Object>();
        BNF2__c bnf = [Select Name, RecordTypeId, Addendum__c, Opportunity__c from BNF2__c where id = :recId];
        returnMap.put('bnf',bnf);
        
        List<ProcessInstance> result = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE Status = 'Pending' AND TargetObjectId = :recId];
        if(result.size() > 0 ){
            returnMap.put('isRecordLocked',true);
            return  returnMap;
        }
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        /* remaining fields 
[Opportunity.CEQActiveRelease__c, PricebookEntry.Product2.Offering_Group__c, PricebookEntry.Product2.Offering_Type__c, Book_No__c, Business_Type__c, Delivery_Date__c, 
PO_Number__c, Sales_Text__c, PricebookEntry.Product2.Item_Category_Group__c, Product2.Id,Product2.ProductCode, Name,Revenue_Schedule_Error_Msg__c, Project_End_Date__c,Revised_Revenue_Schedule__c,
Project_Start_Date__c, Product2.Name,Other_Ship_To_Address__c, Other_Ship_To_SAP_Contact__c, Budget_Therapy_Area__c,UnitPrice, Billing_Schedule_Error_Msg__c, Surcharge_Text__c, OpportunityId];
*/
        List <OpportunityLineItem> opptyLineItem2 = [SELECT Id, PricebookEntry.Name, TotalPrice, ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                                     Billing_Frequency__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                                     Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyISOCode, 
                                                     PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                                     PricebookEntry.Product2.Material_Group_1__c
                                                     FROM OpportunityLineItem WHERE OpportunityId = :bnf.Opportunity__c AND Product_Material_Type__c NOT IN :excludedProducts 
                                                     ORDER BY PricebookEntry.ProductCode asc, Product_Start_Date__c ASC];
        returnMap.put('opptyLineItem2',opptyLineItem2);
        
        List<Document> glossaryDocumentList = [SELECT Id FROM Document WHERE DeveloperName = : MDM_Defines.Document_Dev_Name_IMSSFDCGlossary];
        if(glossaryDocumentList.size() > 0){
            returnMap.put('glossaryDocumentId',glossaryDocumentList[0].Id);
        }
        returnMap.putAll(setPickListValues(opptyLineItem2));
        return  returnMap;
    }
    
    
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
        for(Profit_Centre__c region : [SELECT id, name, (SELECT id FROM Profit_Centres__r) FROM Profit_Centre__c WHERE Profit_Center_Code_Chain__c like '%(TOTGEO)%' ORDER BY name]) {
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
    
    @AuraEnabled
    public static Map<String, Object> save(List<OpportunityLineItem> opptyLineItem2, String operationType){
        Set<String> errorMsgSet = new Set<String>();
        Map<String, Object> returnMap = new Map<String, Object>();
        if(operationType == 'validateAndSave'){
            errorMsgSet = validateOLI(opptyLineItem2);
        }
        if(errorMsgSet.size() == 0){
            try{
                update opptyLineItem2;
                returnMap.put('Success', true);
            }catch(Exception ex){
                returnMap.put('error', ex.getMessage());
            }
        }else{
            returnMap.put('error', errorMsgSet);
        }
        return returnMap;
    }
    
    private static Set<String> validateOLI(List<OpportunityLineItem> opptyLineItem2){
        Set<String> errorMsgSet = new Set<String>();
        Integer POValueCount = 0;
        Integer PONullCount = 0;
        for(OpportunityLineItem oli: opptyLineItem2){
            if(oli.Product_Start_Date__c == Null && oli.PricebookEntry.Product2.Material_Type__c=='ZPUB'){
                errorMsgSet.add('Data Period Start: You must enter a value.');
            }
            if(oli.Product_End_Date__c == Null && oli.PricebookEntry.Product2.Material_Type__c=='ZPUB'){
                errorMsgSet.add('Data Period End: You must enter a value.');
            }
            if(oli.Delivery_Media__c == Null || oli.Delivery_Media__c == ''){
                errorMsgSet.add('Delivery Media: You must enter a value.');
            }
            if(oli.Proj_Rpt_Frequency__c == Null || oli.Proj_Rpt_Frequency__c == ''){
                errorMsgSet.add('Delivery/Rpt Frequency: You must enter a value.');
            }
            if(oli.Billing_Frequency__c == Null || oli.Billing_Frequency__c == ''){
                errorMsgSet.add('Billing Frequency: You must enter a value.');
            }
            if(oli.Billing_Date__c == Null && oli.Revenue_Type__c == 'Ad Hoc'){
                errorMsgSet.add('Billing Date: Please enter Billing Date for Ad Hoc Product.');
            }
            if(oli.Sale_Type__c == Null || oli.Sale_Type__c == ''){
                errorMsgSet.add('Sale Type: You must enter a value.');
            }
            if(oli.Revenue_Type__c == Null || oli.Revenue_Type__c == ''){
                errorMsgSet.add('Revenue Type: You must enter a value.');
            }
            if(oli.Therapy_Area__c == Null || oli.Therapy_Area__c == ''){
                errorMsgSet.add('Therapy Area: You must enter a value.');
            }
            if(oli.Billing_Date__c == null && oli.Billing_Frequency__c == 'Once'){
                errorMsgSet.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected..');
            }
            if(oli.ProfitCenter__c == null && oli.PricebookEntry.Product2.Material_Group_1__c =='MAN') {
                errorMsgSet.add('Profit Center: Please Enter Profit Center.');
            }
            if(oli.PO_line_item_number__c != NULL){
                POValueCount++;
                if(!oli.PO_line_item_number__c.isNumeric()){
                    errorMsgSet.add('PO line item number: PO Line Item Number should be filled Numbers only.');
                }
            }else{
                PONullCount++;
            }
        }
        if(POValueCount > 0 && PONullCount > 0){
            errorMsgSet.add('PO line item number: PO Line Item Number should be filled or blank on all Products.');
        }
        return errorMsgSet;
    }
    
}