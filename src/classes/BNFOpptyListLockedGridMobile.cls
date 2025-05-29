public class BNFOpptyListLockedGridMobile{    
    
    private static List<Map<String, String>> setRevenueCountryList() {
        String revenueCountryMapJSON = '';
        Map<String, Id> revenueCountryToRevenueCountryIdMap = new Map<String, Id>();
        List<Profit_Centre__c> regionList = [SELECT id, name, (SELECT id FROM Profit_Centres__r) FROM Profit_Centre__c WHERE Profit_Center_Code_Chain__c like '%(TOTGEO)%' order by name];
        List<Map<String, String>> profitCenterOptions = new List<Map<String, String>>();
        Map<String, String> optionMap = new Map<String, String>();
        optionMap.put('label','');
        optionMap.put('value','');
        profitCenterOptions.add(optionMap);
        for(Profit_Centre__c region : regionList) {
            if(region.Profit_Centres__r.size() == 0) {
                revenueCountryToRevenueCountryIdMap.put(region.name, region.id);
                optionMap = new Map<String, String>();
                optionMap.put('label',region.id);
                optionMap.put('value',region.name);
                profitCenterOptions.add(optionMap);
                
            }
        }
        if(revenueCountryToRevenueCountryIdMap.size() > 0) {
            revenueCountryMapJSON = JSON.serialize(revenueCountryToRevenueCountryIdMap);
        }   
        //return revenueCountryMapJSON;
        return profitCenterOptions;
    }
    //setIsNewBnfFlag
    private static Boolean setIsNewBnfFlag(BNF_Settings__c bnfSetting, BNF2__c bnf){
        Boolean isNewBnf = false;
        try {
            if(bnfSetting.BNF_Opportunity_Threshold__c != null) {
                String opportunityNumber = bnf.Opportunity_Number__c;
                if(opportunityNumber !=null && opportunityNumber != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(opportunityNumber)) {
                    isNewBnf = true;
                } else {
                    isNewBnf = false;
                }
            } else {
                isNewBnf = true;
            } 
        } catch(Exception exp) {
            isNewBnf = false;
        }
        return isNewBnf;
    }
    
    public static Map<String, Object> fetchAllDetailsOnLoad(String recsId){
        Map<String, Object> returnMap = new Map<String, Object>();
        BNF2__c bnf = [SELECT Opportunity__r.opportunity_number__c, Opportunity_Number__c, Name, Addendum__c, Contract_Start_Date__c, Contract_End_Date__c, X2nd_Address__c, Comments__c,Sales_Org_Code__c,
                       RecordTypeId,BNF_Status__c,Revenue_Analyst__r.User__c, Bill_To__r.PO_Required__c, Client_PO_Number__c FROM BNF2__c WHERE id = :recsId];
        returnMap.put('bnfRecord', bnf);
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        String addressPrefix = Address__c.SobjectType.getDescribe().getKeyPrefix();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        returnMap.put('profitCenterOptions', setRevenueCountryList());
        List<boolean> isProfitCenterReadOnlyList = new List<boolean>();
        Boolean hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        returnMap.put('LocalekeyFormat', setLocaleFormat());
        String oliTherapyError = '';
        Boolean HasZrepZlicProduct = false;
        Boolean isNewBnf = setIsNewBnfFlag(bnfSetting,bnf);
        String opportunityNumber = null;
        returnMap.put('isNewBnf', isNewBnf);
        Boolean US_SalesOrg = false;
        if (bnf.Sales_Org_Code__c != null){
            US_SalesOrg = (bnf.RecordTypeId !=  MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? true : false;        
        }
        returnMap.put('US_SalesOrg', US_SalesOrg);
        returnMap.put('Label_CES_TOT_Offering_Type', System.Label.CES_TOT_Offering_Type);
        List<OpportunityLineItem> opptyLineItem2 = [SELECT UnitPrice,Product2.ProductCode ,ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c,Name,Audit_Subscription_Status__c, Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, 
                                                    PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                                    PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                                    CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                                    PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                                    Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                                    Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                                    Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                                    Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, Product2.Name,Product2.Id,
                                                    OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c, PricebookEntry.Product2.Therapy_Class__c FROM OpportunityLineItem WHERE OpportunityId = :bnf.Opportunity__c and Product_Material_Type__c NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, 
                                                    Product_Start_Date__c asc];
        Boolean PreventEdit = false;
        User CurrentUser = [SELECT Id,Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        returnMap.put('CurrentUser', CurrentUser);
        Map<id,List<Map<String,String>>> DeliveryMedia_Map = new Map<id,List<Map<String,String>>>();
        Map<Id, List<Map<String,String>>> oliIdToTherapyAreaOptionsMap = new Map<Id, List<Map<String,String>>>();
        Map<id,List<Map<String,String>>> DeliveryFrequency_Map = new Map<id,List<Map<String,String>>>();
        Map<id,String> Surchargetext=new Map<id,String>();
        Schema.DescribeFieldResult fieldResultDeliveryMedia = OpportunityLineItem.Delivery_Media__c.getDescribe();
        List<Schema.PicklistEntry> pleDeliveryMedia = fieldResultDeliveryMedia.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultProj_Rpt_Frequency = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> pleProj_Rpt_Frequency = fieldResultProj_Rpt_Frequency.getPicklistValues();      
        
        Schema.DescribeFieldResult fieldResultTherapyArea = OpportunityLineItem.Therapy_Area__c.getDescribe();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = fieldResultTherapyArea.getPicklistValues();   
        for(OpportunityLineItem oli : opptyLineItem2){
            isProfitCenterReadOnlyList.add(oli.PricebookEntry.Product2.Material_Group_1__c != 'MAN');
            if(isNewBnf) {
                if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP' || oli.PricebookEntry.Product2.Material_Type__c=='ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'){
                    oli.Billing_Frequency__c = null;
                    oli.Billing_Date__c = null;               
                    oli.Proj_Rpt_Frequency__c = null;
                    oli.Delivery_Date__c = null;
                    oli.Invoice_Lag_to_Data_Period__c = null;
                }
            }
            if(oli.surcharge_text__c!=null && oli.surcharge_text__c!=''){
                Surchargetext.put(oli.id,oli.surcharge_text__c);
            }else
                Surchargetext.put(oli.id,'');
            if(!IsNewBNF) {
                if(oli.Therapy_Area__c==null && oli.Opportunity.Therapy_Area__c!=null)
                    oli.Therapy_Area__c=oli.Opportunity.Therapy_Area__c; 
            }     
            
            List<Map<String,String>> therapyAreaoptionList = new List<Map<String,String>>();
            Map<String,String> therapyAreaoptionMap = new Map<String,String>();
            therapyAreaoptionMap.put('label','--None--');
            therapyAreaoptionMap.put('value','');
            therapyAreaoptionList.add(therapyAreaoptionMap);
            Set<String> therapyAreavaluesSet = new Set<String>(); 
            if(oli.PricebookEntry.Product2.Therapy_Class__c == null || oli.PricebookEntry.Product2.Therapy_Class__c == ''){
                for(Schema.PicklistEntry pickEntry : therapyAreaPickEntryList){
                    therapyAreaoptionMap = new Map<String,String>();
                    therapyAreaoptionMap.put('label',pickEntry.getLabel());
                    therapyAreaoptionMap.put('value',pickEntry.getValue());
                    therapyAreaoptionList.add(therapyAreaoptionMap);
                }
            }else{
                Map<String, String> therapyAreaKeyToValueMap = new Map<String, String>();                
                for(Schema.PicklistEntry pickEntry : therapyAreaPickEntryList){
                    therapyAreaKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), pickEntry.getValue()); 
                }
                List<String> supportedTherapyAreaList = oli.PricebookEntry.Product2.Therapy_Class__c.split(':');
                for (String therapyAreaOption : supportedTherapyAreaList){
                    if(therapyAreaKeyToValueMap.containsKey(therapyAreaOption)){
                        therapyAreaoptionMap = new Map<String,String>();
                        therapyAreaoptionMap.put('label',therapyAreaKeyToValueMap.get(therapyAreaOption));
                        therapyAreaoptionMap.put('value',therapyAreaKeyToValueMap.get(therapyAreaOption));
                        therapyAreaoptionList.add(therapyAreaoptionMap);
                        therapyAreavaluesSet.add(therapyAreaKeyToValueMap.get(therapyAreaOption));
                    }
                }
                if(oli.Therapy_Area__c != null && !therapyAreavaluesSet.contains(oli.Therapy_Area__c)) {
                    therapyAreaoptionMap = new Map<String,String>();
                    therapyAreaoptionMap.put('label',oli.Therapy_Area__c);
                    therapyAreaoptionMap.put('value',oli.Therapy_Area__c);
                    therapyAreaoptionList.add(therapyAreaoptionMap);
                }
            }
            oliIdToTherapyAreaOptionsMap.put(oli.id,therapyAreaoptionList);
            returnMap.put('oliIdToTherapyAreaOptionsMap', oliIdToTherapyAreaOptionsMap);
            List<Map<String,String>> options = new List<Map<String,String>>();
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('label','');
            optionMap.put('value','--None--');
            options.add(optionMap);
            if (oli.PricebookEntry.Product2.Delivery_Media__c == null || oli.PricebookEntry.Product2.Delivery_Media__c == ''){
                for(Schema.PicklistEntry f : pleDeliveryMedia){
                    optionMap = new Map<String,String>();
                    optionMap.put('label',f.getLabel());
                    optionMap.put('value',f.getValue());
                    options.add(optionMap); 
                }
            }else{
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleDeliveryMedia){
                    FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
                }
                List<String> SupportedDeliveryMedia = oli.PricebookEntry.Product2.Delivery_Media__c.split(':');
                for (String DeliveryMediaOption : SupportedDeliveryMedia){
                    if(FieldsvaluesMap.containsKey(DeliveryMediaOption)){
                        optionMap = new Map<String, String>();
                        optionMap.put('label',FieldsvaluesMap.get(DeliveryMediaOption));
                        optionMap.put('value',FieldsvaluesMap.get(DeliveryMediaOption));
                        options.add(optionMap); 
                    }
                }
            }
            DeliveryMedia_Map.put(oli.id,options);
            returnMap.put('DeliveryMedia_Map', DeliveryMedia_Map);
            if(IsNewBnf) {
                if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP')
                    oli.delivery_media__c='Not Applicable [NA]';  
            }   
            List<Map<String,String>> DeliveryFrequencyOptions = new List<Map<String,String>>();  
            Map<String,String> deliveryFrequencyMap = new Map<String,String>();
            deliveryFrequencyMap.put('label','--None--');
            deliveryFrequencyMap.put('value','');
            DeliveryFrequencyOptions .add(deliveryFrequencyMap); 
            if (oli.PricebookEntry.Product2.Delivery_Frequency__c == null || oli.PricebookEntry.Product2.Delivery_Frequency__c == ''){
                for(Schema.PicklistEntry f : pleProj_Rpt_Frequency){
                    deliveryFrequencyMap = new Map<String, String>();
                    deliveryFrequencyMap.put('label',f.getLabel());
                    deliveryFrequencyMap.put('value',f.getValue());
                    DeliveryFrequencyOptions.add(deliveryFrequencyMap); 
                }
            }else{
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleProj_Rpt_Frequency){
                    if(f.getLabel()!='Other')
                        FieldsvaluesMap.put(f.getLabel().substringBetween('[',']'), f.getLabel()); 
                }
                List<String> SupportedDeliveryFrequencies = oli.PricebookEntry.Product2.Delivery_Frequency__c.split(':');
                for (String DeliveryFrequencyOption : SupportedDeliveryFrequencies){
                    if(FieldsvaluesMap.containsKey(DeliveryFrequencyOption))   {
                        deliveryFrequencyMap = new Map<String, String>();
                        deliveryFrequencyMap.put('label',FieldsvaluesMap.get(DeliveryFrequencyOption));
                        deliveryFrequencyMap.put('value',FieldsvaluesMap.get(DeliveryFrequencyOption));
                        DeliveryFrequencyOptions.add(deliveryFrequencyMap); 
                    }                 
                }
            }
            DeliveryFrequency_Map.put(oli.id,DeliveryFrequencyOptions);
            returnMap.put('DeliveryFrequency_Map', DeliveryFrequency_Map);
            if(IsNewBnf) {
                if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP'){
                    if(!bnf.Addendum__c)
                        oli.Product_Start_Date__c=oli.Project_Start_Date__c;
                    oli.Product_End_Date__c=oli.Project_End_Date__c;
                }
                if(oli.PricebookEntry.Product2.Material_Type__c =='ZREP' && oli.Budget_Therapy_Area__c != null) {
                    oli.Therapy_Area__c = oli.Budget_Therapy_Area__c;            
                }             
            }
            if (IsNewBnf){
                if(oli.Revised_Revenue_Schedule__c != null){
                    List<String> strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');
                    if (strRevSchedule[0] == 'x')
                        strRevSchedule.clear();      
                    oli.Revised_Price__c = 0;            
                    for (integer i=0;i<strRevSchedule.size();i++){
                        oli.Revised_Price__c += Decimal.valueOf(strRevSchedule[i].split(':')[1]);            
                    }                   
                }
            }      
            if(IsNewBnf){ 
                if (oli.PricebookEntry.Product2.Material_Type__c == 'ZREP'|| oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'){
                    HasZrepZlicProduct = true;                       
                }
            }   
        }
        returnMap.put('HasZrepZlicProduct', HasZrepZlicProduct);
        returnMap.put('opptyLineItem2', opptyLineItem2);
        String isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);
        returnMap.put('isProfitCenterReadOnlyList', isProfitCenterReadOnlyList);
        String PreventEdit_Msg = '';
        if(IsNewBnf) {
            List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId FROM ProcessInstanceWorkitem  WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :bnf.Id]);
            Set<Id> actorIdsSet = new Set<Id>();
            for(ProcessInstanceWorkitem workItem : PIW_List){
                actorIdsSet.add(workItem.ActorId);
            }
            if (PIW_List.size() > 0) {
                if (CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(CurrentUser.Id) || hasAccessBNFAll /*this.CurrentUser.Id == PIW_List[0].ActorId*/) {
                    PreventEdit = false;
                } else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') ||
                           bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING')) {
                               PreventEdit_Msg = 'BNF has been accepted for SAP load and cannot be edited';
                               PreventEdit = true;                 
                           }    
                //  Else if the BNF is someWHERE else within the approval process
                else {
                    PreventEdit_Msg = 'BNF is submitted for approval and cannot be edited';
                    PreventEdit = true;
                }
                
            } else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED')) {
                PreventEdit_Msg =  'BNF has been approved and cannot be edited';
                PreventEdit = true;
            }                      
        } else {
            List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId FROM ProcessInstanceWorkitem  WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :bnf.Id]);
            Set<Id> actorIdsSet = new Set<Id>();
            for(ProcessInstanceWorkitem workItem : PIW_List){
                actorIdsSet.add(workItem.ActorId);
            }
            if (PIW_List.size() > 0){
                //  If BNF has been submitted, only sys admins or the user to which it has been assigned are able to edit
                if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && 
                    (CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(CurrentUser.Id) || hasAccessBNFAll /*this.CurrentUser.Id == PIW_List[0].ActorId*/ )){
                        PreventEdit_Msg = ''; 
                        PreventEdit = false;
                    }
                //  Else if the BNF is submitted and user is not allowed to edit products, show message as appropriate
                else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED')){
                    PreventEdit_Msg = 'BNF is submitted for approval and cannot be edited';
                    PreventEdit = true; 
                }
                else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') ||
                         bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING')){
                             PreventEdit_Msg =  'BNF has been accepted for SAP load and cannot be edited';
                             PreventEdit = true;                 
                         }          
            }
            else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED')){
                PreventEdit_Msg = 'BNF has been approved and cannot be edited';
                PreventEdit = true; 
            }                   
        }  
        returnMap.put('PreventEdit', PreventEdit); 
        returnMap.put('PreventEdit_Msg', PreventEdit_Msg);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveOLI(BNF2__c bnfRec, OpportunityLineItem oliRec) {
        return ValidateOLI(bnfRec, oliRec);
    }
    
    private static Map<String,Object> ValidateOLI(BNF2__c bnf, OpportunityLineItem oliRec){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<OpportunityLineItem> opptyLineItem2 = new List<OpportunityLineItem>{oliRec};  
        List<String> errorListToReturn = new List<String>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        boolean Val = true;
        Boolean US_SalesOrg = false;
        if (bnf.Sales_Org_Code__c != null){
            US_SalesOrg = (bnf.RecordTypeId !=  MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? true : false;        
        }
        Boolean IsNewBnf = setIsNewBnfFlag(bnfSetting,bnf);
        boolean BillingDateError = false;
        boolean DeliveryDateError = false;
        boolean ListPriceError=false; // List Price Validation :: Date : 29 Dec 2011 :: Update By: Himanshu Parashar
        boolean dataMonthChgListPriceError = false;
        boolean ValError = false;
        boolean TriggerError=false;       
        boolean poErrorOccured = false;   
        Map<Id,OpportunityLineItem>  OLI_Map = new Map<Id,OpportunityLineItem>([select Id, Nbr_of_Users__c, Revised_Revenue_Schedule__c,Billing_Schedule__r.Total_Billing_Amount__c,TotalPrice,Discount_Amount_Formula__c from OpportunityLineItem where OpportunityId = :bnf.Opportunity__c]);
        
        //==== START code to check project start/end dates vs revenue schedule dates (ER003)
        Map<String,Boolean> OLIScheduleMapStartDate = new Map<String,Boolean>();
        Map<String,Boolean> OLIScheduleMapEndDate = new Map<String,Boolean>(); 
        Map<Id,OpportunityLineItem> opptyLineItem2_Map = new Map<Id,OpportunityLineItem>();
        for (OpportunityLineItem OLI:opptyLineItem2){
            opptyLineItem2_Map.put(OLI.Id,OLI);
        }
        //  Retrieve all OpportunityLineItemSchedules to validate against project start/end dates
        LIST<AggregateResult> OLSSchedule_Array = [Select MIN(ScheduleDate) StartDate,Max(ScheduleDate) EndDate,
                                                   OpportunityLineItemId,OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c from OpportunityLineItemSchedule where OpportunitylineitemId in : OLI_Map.keySet() and OpportunityLineItem.PricebookEntry.Product2.Material_Type__c = 'ZREP'
                                                   group by OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c,OpportunityLineItemId];
        
        for(AggregateResult agg : OLSSchedule_Array){
            //  If a revised BNF is being validated but no revised schedule has been specified, then the validation must be done against the original
            //  Opportunitylineitemschedules using the updated data period start
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
            if (OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c != null)
                OLI.Revised_Revenue_Schedule__c = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c;
            //  Check revised revenue schedule against project start/end dates (only for ZREP products)
            if (OLI.Revised_Revenue_Schedule__c != null && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP'){
                List<String> strRevSchedule = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c.split('\\|');  
                //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                if (strRevSchedule[0] == 'x')
                    strRevSchedule.clear();       
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
        if(IsNewBnf && !Trigger.isExecuting){
            for (OpportunityLineItem OLI:opptyLineItem2){
                if (OLIScheduleMapStartDate.containskey(oli.id) && OLIScheduleMapStartDate.get(oli.id)==true || OLIScheduleMapEndDate.containskey(oli.id) && OLIScheduleMapEndDate.get(oli.id)==true){
                    //  If there is a revised price, put the error on the revised price field and the other field that can also be used to edit the revised revenue schedules.
                    if (OLI.Revised_Price__c != null){
                        errorListToReturn.add('Revenue Schedule Error Msg: Revised revenue schedules must be within project start/end dates');
                        //OLI.Revenue_Schedule_Error_Msg__c.addError('Revised revenue schedules must be within project start/end dates');
                        //OLI.Revised_Price__c.addError('Revised revenue schedules must be within project start/end dates');                          
                    }
                    //  Else put the error on the field with the link to edit the OpportunityLineItemSchedules
                    else
                        errorListToReturn.add('Revenue Schedule Error Msg: Revenue schedules must be within project start/end dates');
                    ValError = true;                                         
                }
            } 
        }
        //==== END code to check project start/end dates vs revenue schedule dates (ER003)
        
        for(Integer i=0;i<opptyLineItem2.size();i++){
            if(IsNewBnf) {
                if ((opptyLineItem2[i].Billing_Frequency__c == '50% upon signature, 50% upon completion' || opptyLineItem2[i].Billing_Frequency__c == 'Other') && 
                    opptyLineItem2[i].Pricebookentry.product2.Material_Type__c=='ZPUB' && opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC') {
                        if(Trigger.isExecuting)
                            TriggerError=true;
                        else{
                            errorListToReturn.add('Billing Frequency: \'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable for ZPUB products. Please select some other Billing Frequency.');
                            //opptyLineItem2[i].Billing_Frequency__c.addError('\'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable for ZPUB products. Please select some other Billing Frequency.');
                        }
                        ValError = true; 
                    } 
            }            
            //  Delivery date must be after data period end, except for materials with "PERF" in the material code
            if (opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !='Management Consulting' &&
                opptyLineItem2[i].List_Price__c==null && 
                opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !=Label.CES_TOT_Offering_Type && US_SalesOrg == false){	
                    if(Trigger.isExecuting)
                        TriggerError=true;
                    else{
                        errorListToReturn.add('List Price: Please Enter List price');
                        //opptyLineItem2[i].List_Price__c.addError('Please Enter List price');
                    }
                    ValError = true; 
                } 
            //  Delivery date must be after data period end, except for materials with "PERF" in the material code
            if (!opptyLineItem2[i].PricebookEntry.ProductCode.toUpperCase().contains('PERF') &&
                opptyLineItem2[i].Delivery_Date__c < opptyLineItem2[i].Product_End_Date__c){
                    if(Trigger.isExecuting)
                        TriggerError=true;
                    else{
                        errorListToReturn.add('Delivery Date: Delivery date cannot be earlier than data period end');
                        //opptyLineItem2[i].Delivery_Date__c.addError('Delivery date cannot be earlier than data period end');
                    }
                    ValError = true; 
                }
            // ------- BEGIN CONTRACT VS DATA PERIOD DATES VALIDATION              
            //  Data month start must be before contract end date
            //  For new C&S iBNF (ER003), the data period vs contract date validation is ignored as the data periods come from project start/end and project start/end
            //  must be within engagement start/end and engagement start/end must be within contract start/end
            if (opptyLineItem2[i].Product_Start_Date__c > bnf.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                ValError = true;
                if(Trigger.isExecuting)
                    TriggerError=true;
                else{
                    errorListToReturn.add('Product Start Date: Data period must start before contract end date');
                }
            }     
            //  Data month end must be before contract end date
            if (opptyLineItem2[i].Product_End_Date__c > bnf.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                ValError = true;
                if(Trigger.isExecuting)
                    TriggerError=true;
                else{
                    errorListToReturn.add('Product End Date: Data period must end before contract end date');
                    //opptyLineItem2[i].Product_End_Date__c.addError('Data period must end before contract end date');
                }
            }     
            // For subscription products (i.e. not back data and not ad hoc)      
            if (opptyLineItem2[i].Revenue_Type__c != 'Back Data' && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                //  Data period end must be after contract start date
                if (opptyLineItem2[i].Product_End_Date__c < bnf.Contract_Start_Date__c){    
                    ValError = true;
                    if(Trigger.isExecuting)
                        TriggerError=true;
                    else{
                        errorListToReturn.add('Product End Date: Data period must end after contract start date.');
                        //opptyLineItem2[i].Product_End_Date__c.addError('Data period must end after contract start date.');
                    }
                }
                //  Data period start must be after contract start date
                if (opptyLineItem2[i].Product_Start_Date__c < bnf.Contract_Start_Date__c){
                    ValError = true;
                    if(Trigger.isExecuting)
                        TriggerError=true;
                    else{
                        errorListToReturn.add('Product Start Date: Data period must start after contract start date.');
                        //opptyLineItem2[i].Product_Start_Date__c.addError('Data period must start after contract start date.');
                    }
                }
            }
            // ------- END CONTRACT VS DATA PERIOD DATES VALIDATION              
            
            if(IsNewBnf) {
                if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null) && 
                   opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP') {
                       BillingDateError = true;                  
                       if(Trigger.isExecuting)
                           TriggerError=true;
                       else{
                           errorListToReturn.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
                           //opptyLineItem2[i].Billing_Date__c.addError('Billing date is mandatory when billing frequency "Once" is selected.');
                       }
                   }
            } else {
                if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null)) {
                    BillingDateError = true;                  
                    if(Trigger.isExecuting)
                        TriggerError=true;
                    else{
                        errorListToReturn.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
                        //opptyLineItem2[i].Billing_Date__c.addError('Billing date is mandatory when billing frequency "Once" is selected.');
                    }
                    
                }                 
            }                               
            
            if((opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]')&&(opptyLineItem2[i].Delivery_Date__c==null) && bnf.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id){
                DeliveryDateError = true;                  
                if(Trigger.isExecuting)
                    TriggerError=true;
                else{
                    errorListToReturn.add('Delivery Date: Delivery date is mandatory when Delivery frequency "Once" is selected.');
                    //opptyLineItem2[i].Delivery_Date__c.addError('Delivery date is mandatory when Delivery frequency "Once" is selected.');
                }
            }
            
            Decimal SalesPrice = bnf.Addendum__c ? (opptyLineItem2[i].Revised_Price__c != null ? opptyLineItem2[i].Revised_Price__c : opptyLineItem2[i].TotalPrice)  : opptyLineItem2[i].TotalPrice;
            
            
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (opptyLineItem2[i].Surcharge_Text__c==null || opptyLineItem2[i].Surcharge_Text__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP)) )
              ){
                  if(Trigger.isExecuting)
                      TriggerError=true;
                  else{
                      errorListToReturn.add('Surcharge Text: Please input Surcharge Text.');
                      //opptyLineItem2[i].Surcharge_Text__c.addError('Please input Surcharge Text');
                  }
                  
                  ListPriceError = true;    
              }
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (opptyLineItem2[i].Discount_Reason__c==null || opptyLineItem2[i].Discount_Reason__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) ))
              ){
                  if(Trigger.isExecuting)
                      TriggerError=true;
                  else{
                      errorListToReturn.add('Discount Reason: Please input Discount reason.');
                      //opptyLineItem2[i].Discount_Reason__c.addError('Please input Discount reason');
                  }
                  
                  
                  ListPriceError = true;    
              }
            
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) )){
                opptyLineItem2[i].Surcharge_Text__c='';
                
            }
            else if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                opptyLineItem2[i].Discount_Reason__c='';
            }
            else if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) == SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                opptyLineItem2[i].Discount_Reason__c='';
                opptyLineItem2[i].Surcharge_Text__c='';
            }
            
            
            
            //  Issue-05969 - Pramod : For ZPUB products, if delivery frequency "once" is selected, then users must select billing frequency of "once".             
            if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c =='ZPUB' && opptyLineItem2[i].Proj_Rpt_Frequency__c == 'Once [O]' && opptyLineItem2[i].Billing_Frequency__c != 'Once'){
                if(Trigger.isExecuting)
                    TriggerError=true;
                else{
                    errorListToReturn.add('Billing Frequency: If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.');
                    //opptyLineItem2[i].Billing_Frequency__c.addError('If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.');
                }
                
                ValError = true; 
            }   
            
            // Ensure that Sale type and revenue type are not null
            if (opptyLineItem2[i].Sale_Type__c == null || opptyLineItem2[i].Revenue_Type__c == null){
                if(Trigger.isExecuting)
                    TriggerError=true;
                ValError = true; 
            } 
            // 
            
            //  Check that billing schedule adds up to total of sales price/revised sales price
            //  If user has entered this screen as part of creating a new BNF we can ignore the billing schedule validations
            if(IsNewBnf/* && !IgnoreBillingScheduleValidations*/){
                ////Billing Schedule Validation for ZREP and ZLIC proeducts 
                if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c == 'ZREP'|| opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'){
                    
                    //Billing Schedule Validation    
                    //  Set revised price as the comparison to be used for revised bnf                        
                    Decimal ValidationPrice;
                    if (bnf.Addendum__c && opptyLineItem2[i].Revised_Price__c != null)
                        ValidationPrice = opptyLineItem2[i].Revised_Price__c.setScale(2);
                    else
                        ValidationPrice = opptyLineItem2[i].TotalPrice.setscale(2);    
                    
                    if(OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c==NULL && (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0)){                       
                        ValError = true; 
                        if(Trigger.isExecuting)
                            TriggerError=true;
                        else{
                            errorListToReturn.add('Billing Schedule: No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').');
                            //  Use the "dummy" Billing_Schedule_Error_Msg__c field to display an error next to the billing schedule link      
                            //opptyLineItem2[i].Billing_Schedule_Error_Msg__c.addError('No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').');
                        }
                    }   
                    if( OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c!=NULL && OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) != ValidationPrice  && 
                       (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0)){
                           ValError = true; 
                           if(Trigger.isExecuting)
                               TriggerError=true;
                           else{
                               errorListToReturn.add('Billing Schedule: Billing schedule total (' + OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').');
                               //  Use the "dummy" Billing_Schedule_Error_Msg__c field to display an error next to the billing schedule link                                
                               //opptyLineItem2[i].Billing_Schedule_Error_Msg__c.addError('Billing schedule total (' + OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').');
                           }
                       }
                }
            }
            
            if(IsNewBnf){
                if(opptyLineItem2[i].List_Price__c!=null && opptyLineItem2[i].TotalPrice==0 && opptyLineItem2[i].List_Price__c!=0 && 
                   (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c=='ZREP' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')){
                       ListPriceError = true;                  
                       if(Trigger.isExecuting)
                           TriggerError=true;
                       else{
                           errorListToReturn.add('List Price: ZREP/ZLIC materials with zero value sales price must also have zero value list price');
                           //opptyLineItem2[i].List_Price__c.addError('ZREP/ZLIC materials with zero value sales price must also have zero value list price.');
                       }
                   }
            }                   
            if((opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLI' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLU') && opptyLineItem2[i].Nbr_of_Users__c <= 0){
                ValError = true; 
                if(Trigger.isExecuting)
                    TriggerError=true;
                else{
                    errorListToReturn.add('Nbr of Users: Please enter a non-zero amount for number of users.');
                    //opptyLineItem2[i].Nbr_of_Users__c.addError('Please enter a non-zero amount for number of users');
                }
                
            }
            // Dheeraj Kumar Issue-10593 -- 25 April 2017
            if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null){
                ValError = true;
                errorListToReturn.add('Profit Center: Please Enter Profit Center.');
                //opptyLineItem2[i].ProfitCenter__c.addError('Please Enter Profit Center');
                
            }
            
        }
        
        if (Val==false || BillingDateError || DeliveryDateError || dataMonthChgListPriceError || ListPriceError || ValError || TriggerError){             
            returnMap.put('error',errorListToReturn);
        }
        else{
            try{
                update opptyLineItem2;
                returnMap.put('success',opptyLineItem2);
            }catch(DmlException ex){
                returnMap.put('error',ex);
            }    
        }
        
        return returnMap;
    }
    
    //This function set user locale which is used on page
    private static String setLocaleFormat(){
        String LocalekeyFormat = '';
        if((User_Locale__c.getinstance('Format1').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format1').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
           (User_Locale__c.getinstance('Format1').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format1').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                LocalekeyFormat='Locale_Format1';
            }else if((User_Locale__c.getinstance('Format2').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format2').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                     (User_Locale__c.getinstance('Format2').LocaleSidKey1__c!=null && 
                      User_Locale__c.getinstance('Format2').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                          LocalekeyFormat='Locale_Format2';
                      }else if((User_Locale__c.getinstance('Format3').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format3').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                               (User_Locale__c.getinstance('Format3').LocaleSidKey1__c!=null && 
                                User_Locale__c.getinstance('Format3').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                                    LocalekeyFormat='Locale_Format3';
                                }else if((User_Locale__c.getinstance('Format4').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format4').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                                         (User_Locale__c.getinstance('Format4').LocaleSidKey1__c!=null && 
                                          User_Locale__c.getinstance('Format4').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                                              LocalekeyFormat='Locale_Format4';
                                          }else if(User_Locale__c.getinstance('Format5').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
                                              LocalekeyFormat='Locale_Format5';
                                          }else if(User_Locale__c.getinstance('Format6').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
                                              LocalekeyFormat='Locale_Format6';
                                          }else if(User_Locale__c.getinstance('Format7').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
                                              LocalekeyFormat='Locale_Format7';
                                          }else
                                              LocalekeyFormat='Locale_Format1';   
        return LocalekeyFormat;
    }
    
}