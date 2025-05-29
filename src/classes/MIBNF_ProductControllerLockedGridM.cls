public class MIBNF_ProductControllerLockedGridM {
    Static boolean validationError = false;
    
    public static List<Map<String, String>> setRevenueCountryList() {
        Map<String, Id> revenueCountryToRevenueCountryIdMap = new Map<String, Id>();
        List<Profit_Centre__c> regionList = [select id, name, (select id from Profit_Centres__r) from Profit_Centre__c where Profit_Center_Code_Chain__c like '%(TOTGEO)%' order by name];
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
            String revenueCountryMapJSON = JSON.serialize(revenueCountryToRevenueCountryIdMap);
        }      
        return profitCenterOptions;     
    }
    //inner class introduced for list price validation
    //If data period is changing and bnf is revised then list
    //price should also be modified.
    //----- START -----------------
    public class DBOppLineItem {
        Date Data_Period_Start;
        Date Data_Period_End;
        
        Decimal List_Price;
        
        DBOppLineItem (Date in_Data_Period_Start, Date in_Data_Period_End, Decimal in_list_Price) {
            Data_Period_Start = in_Data_Period_Start;
            Data_Period_End = in_Data_Period_End;        
            List_Price = in_list_Price;
        }
        
    }
    
    //setIsNewBnfFlag
    public static Boolean setIsNewBnfFlag(BNF_Settings__c bnfSetting, MIBNF_Component__c MIBNF_Comp){
        Boolean isNewBnf = true;
        try {
            if(bnfSetting.BNF_Opportunity_Threshold__c != null) {
                String opportunityNumber = MIBNF_Comp.Opportunity__r.opportunity_number__c;
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
    
    // Constructor
    public static Map<String,Object> fetchAllDetailsOnLoad(String recsId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        Map<Id, DBOppLineItem> DBoppLineItemMap = new Map<Id, DBOppLineItem>();
        returnMap.put('profitCenterOptions', setRevenueCountryList());
        String addressPrefix  = Address__c.SobjectType.getDescribe().getKeyPrefix();
        List<boolean> isProfitCenterReadOnlyList = new List<boolean>();
        returnMap.put('LocalekeyFormat', setLocaleFormat());
        BNF_Settings__c bnfSetting =BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        // Load Lineitem for single invoice
        Boolean AllowedToApprove = false;
        Boolean hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        //if(System.currentPageReference().getParameters().get('compid') != null){
        
        MIBNF_Component__c MIBNF_Comp  = [Select Opportunity__r.opportunity_number__c, Name,BNF_Status__c,Comments__c,MIBNF__c,MIBNF__r.Opportunity__c,MIBNF__r.Sales_Org_Code__c,Addendum__c,MIBNF__r.Contract_Start_Date__c,
                                          MIBNF__r.Contract_End_Date__c from MIBNF_Component__c where id = :recsId]; //--- add Comments by ej. temporary solution --->
        
        returnMap.put('bnfRecord', MIBNF_Comp);
        Boolean HasZrepZlicProduct = false;
        Boolean IsNewBnf = setIsNewBnfFlag(bnfSetting,MIBNF_Comp);
        returnMap.put('isNewBnf', IsNewBnf);
        Boolean UserIsSysAdmin = false;
        //Check for Sysadmin and allow user to Edit Products if user has rights
        User U = [select Id, Sales_Org__c,Profile.Name from User where Id = :UserInfo.getUserId()];
        if(U.Profile.Name.contains('Administrator'))
            UserIsSysAdmin=true;
        else
            UserIsSysAdmin=false;
        
        //Check for Approval User
        ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :MIBNF_Comp.Id];        
        if (P_array.size()!= 0){
            for (ProcessInstanceWorkitem P2:P_array){
                if (P2.ActorId == U.Id || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase()) || hasAccessBNFAll){
                    AllowedToApprove = true;
                }
            }
        }
        String PreventEdit_Msg = '';
        Boolean PreventEdit = false;
        Boolean ErrorFlag = false;
        if(!UserIsSysAdmin && !AllowedToApprove && MIBNF_Comp.BNF_Status__c!='New' && MIBNF_Comp.BNF_Status__c!=MDM_Defines.BnfStatus_Map.get('REJECTED') &&
           MIBNF_Comp.BNF_Status__c!=MDM_Defines.BnfStatus_Map.get('LO_REJECTED') && MIBNF_Comp.BNF_Status__c!=MDM_Defines.BnfStatus_Map.get('RA_REJECTED')){
               ErrorFlag=true;
               PreventEdit_Msg = 'Products from Submitted BNF cannot be edited.';
               PreventEdit = true;
           }
		returnMap.put('PreventEdit', PreventEdit); 
        returnMap.put('PreventEdit_Msg', PreventEdit_Msg);        
        ID Opportunityid=MIBNF_Comp.MIBNF__r.Opportunity__c;
        Boolean US_SalesOrg=(Pattern.matches('US[\\s|[A-z]|[0-9]]*',MIBNF_Comp.MIBNF__r.Sales_Org_Code__c.toUpperCase())) ? true : false;   
        returnMap.put('US_SalesOrg', US_SalesOrg);
        returnMap.put('Label_CES_TOT_Offering_Type', System.Label.CES_TOT_Offering_Type);
        ID MIBNFID = MIBNF_Comp.MIBNF__c;
        
        set<id> oppLineItemset= new set<id>();
        //adding MIBNF line item in to set
        for(MI_BNF_LineItem__c MI_BNF_oppLineItem : [select Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__c=: recsId]){
            oppLineItemset.add(MI_BNF_oppLineItem.Opportunity_Line_Itemid__c);
        }
        // Getting LineItem details
        // Added Therapy_Area__C field in query
        // querying Therapy_Area field
        //  ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c
        //  PricebookEntry.Product2.Therapy_Class__c
        List<OpportunityLineItem> opptyLineItem2=[Select ProfitCenter__c,Name, PricebookEntry.Product2.Material_Group_1__c, Audit_Subscription_Status__c,Product2.Id,Product2.ProductCode,
                                                  Opportunity.Therapy_Area__c,PriceBookEntry.Product2.Delivery_Frequency__c ,PriceBookEntry.Product2.Delivery_Media__c,Project_End_Date__c,
                                                  Project_Start_Date__c,Revenue_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Surcharge_Text__c,UnitPrice,Other_Ship_To_SAP_Contact__c,
                                                  Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c,Therapy_Area__c, PricebookEntry.Name,Product2.Name,Other_Ship_To_Address__c,
                                                  PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c,PricebookEntry.Product2.Offering_Type__c,Budget_Therapy_Area__c,
                                                  List_Price__c, Nbr_of_Users__c, Book_No__c,CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c,Billing_Schedule_Error_Msg__c, 
                                                  PricebookEntry.ProductCode,Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,OpportunityId,Revenue_Type__c,
                                                  Discount_Reason__c, Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, PricebookEntry.Product2.Item_Category_Group__c,
                                                  Invoice_Lag_to_Data_Period__c, Revised_Price__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,Sales_Text__c,
                                                  PricebookEntry.Product2.Therapy_Class__c  from OpportunityLineItem where id in :oppLineItemset  and Product_Material_Type__c NOT IN :excludedProducts order by
                                                  PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
        
        
        // BEGIN - BInit Map for list price validation
        If(MIBNF_Comp.Addendum__c && opptyLineItem2 != null && opptyLineItem2.size() > 0) {
            for(OpportunityLineItem oli : opptyLineItem2 ) {
                DBoppLineItemMap.put(oli.id, new DBoppLineItem(oli.Product_Start_Date__c,oli.Product_End_Date__c,oli.List_Price__c));    
            }
        }
        // Show only selected Delivery media for user
        Map<id,List<Map<String,String>>> DeliveryMedia_Map = new Map<id,List<Map<String,String>>>();
        Map<id,List<Map<String,String>>> DeliveryFrequency_Map = new Map<id,List<Map<String,String>>>();
        
        // Delivery media default values from the OLI
        Schema.DescribeFieldResult fieldResultDeliveryMedia = OpportunityLineItem.Delivery_Media__c.getDescribe();
        List<Schema.PicklistEntry> pleDeliveryMedia = fieldResultDeliveryMedia.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultTherapyArea = OpportunityLineItem.Therapy_Area__c.getDescribe();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = fieldResultTherapyArea.getPicklistValues();
        
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 
        Map<Id, List<Map<String,String>>> oliIdToTherapyAreaOptionsMap = new Map<Id, List<Map<String,String>>>();
        Schema.DescribeFieldResult fieldResultProj_Rpt_Frequency = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> pleProj_Rpt_Frequency = fieldResultProj_Rpt_Frequency.getPicklistValues();        
        Map<id,String> SurchargetextMap=new Map<id,String>();               
        
        for(OpportunityLineItem oli : opptyLineItem2){
            isProfitCenterReadOnlyList.add(oli.PricebookEntry.Product2.Material_Group_1__c != 'MAN');
            if(oli.surcharge_text__c!=null && oli.surcharge_text__c!=''){
                SurchargetextMap.put(oli.id,oli.surcharge_text__c);
                /*if(oli.Discount_Reason__c!=null && (oli.Surcharge_Text__c!=oli.Discount_Reason__c))
oli.surcharge_text__c='';*/
            }
            else
                SurchargetextMap.put(oli.id,'');
            //setting up default value to Opportunity therapy area  
            if(oli.Therapy_Area__c==null && oli.Opportunity.Therapy_Area__c!=null)
                oli.Therapy_Area__c=oli.Opportunity.Therapy_Area__c;
            
            
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
            }
            else{
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
                // Delivery frequencies from SAP
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleDeliveryMedia){
                    FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
                }
                
                List<String> SupportedDeliveryMedia = oli.PricebookEntry.Product2.Delivery_Media__c.split(':');
                for (String DeliveryMediaOption : SupportedDeliveryMedia){
                    if(FieldsvaluesMap.containsKey(DeliveryMediaOption))
                        optionMap = new Map<String, String>();
                    optionMap.put('label',FieldsvaluesMap.get(DeliveryMediaOption));
                    optionMap.put('value',FieldsvaluesMap.get(DeliveryMediaOption));
                    options.add(optionMap); 
                }
            }
            DeliveryMedia_Map.put(oli.id,options);
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
            }
            else{
                // Delivery frequencies from SAP
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleProj_Rpt_Frequency){
                    if(f.getLabel()!='Other')
                        FieldsvaluesMap.put(f.getLabel().substringBetween('[',']'), f.getLabel()); 
                }
                List<String> SupportedDeliveryFrequencies = oli.PricebookEntry.Product2.Delivery_Frequency__c.split(':');
                for (String DeliveryFrequencyOption : SupportedDeliveryFrequencies){
                    if(FieldsvaluesMap.containsKey(DeliveryFrequencyOption))                        
                        deliveryFrequencyMap = new Map<String, String>();
                    deliveryFrequencyMap.put('label',FieldsvaluesMap.get(DeliveryFrequencyOption));
                    deliveryFrequencyMap.put('value',FieldsvaluesMap.get(DeliveryFrequencyOption));
                    DeliveryFrequencyOptions.add(deliveryFrequencyMap);
                }
            }
            DeliveryFrequency_Map.put(oli.id,DeliveryFrequencyOptions);
            
            if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP'){
                //if(oli.Product_Start_Date__c==null)
                oli.Product_Start_Date__c=oli.Project_Start_Date__c;
                //if(oli.Product_End_Date__c==null)
                oli.Product_End_Date__c=oli.Project_End_Date__c;
                
            }
            if(IsNewBnf) {
                // Therapy area on Opportunity Line Item should be set to same as budget
                if(oli.PricebookEntry.Product2.Material_Type__c =='ZREP' && oli.Budget_Therapy_Area__c != null) {
                    oli.Therapy_Area__c = oli.Budget_Therapy_Area__c;
                }
                if(oli.PricebookEntry.Product2.Material_Type__c =='ZREP' || oli.PricebookEntry.Product2.Material_Type__c=='ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC') {
                    oli.Billing_Frequency__c = null;
                    oli.Billing_Date__c = null;              
                    oli.Proj_Rpt_Frequency__c = null;
                    oli.Delivery_Date__c = null;
                    oli.Invoice_Lag_to_Data_Period__c = null;
                } 
            } 
            if (IsNewBnf){
                //  This gets the latest revised price that has been entered in the OLI.Revised_revenue_Schedule__c field but
                //  OLI.Revised_Price__c has not yet been updated on the OLI
                if(oli.Revised_Revenue_Schedule__c != null){
                    List<String> strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');  
                    //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                    if (strRevSchedule[0] == 'x')
                        strRevSchedule.clear();
                    oli.Revised_Price__c = 0;
                    for (integer i=0;i<strRevSchedule.size();i++){
                        //  Overwrite the Revised_Price__c to have the latest value as entered on revised revenue schedule
                        oli.Revised_Price__c += Decimal.valueOf(strRevSchedule[i].split(':')[1]);
                    }                   
                }
            }
            if(IsNewBnf){
                ////Billing Schedule Validation for ZREP and ZLIC proeducts 
                if (oli.PricebookEntry.Product2.Material_Type__c == 'ZREP'|| oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'){
                    //  Set to true to indicate at least one ZREP/ZLIC product
                    HasZrepZlicProduct = true;
                }
            }
        }
        returnMap.put('oliIdToTherapyAreaOptionsMap', oliIdToTherapyAreaOptionsMap);
        returnMap.put('DeliveryMedia_Map', DeliveryMedia_Map);
        returnMap.put('DeliveryFrequency_Map', DeliveryFrequency_Map);
        returnMap.put('HasZrepZlicProduct', HasZrepZlicProduct);
        returnMap.put('opptyLineItem2', opptyLineItem2);
        returnMap.put('isProfitCenterReadOnlyList', isProfitCenterReadOnlyList);
        String isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveOLI(MIBNF_Component__c MIBNF_Comp, OpportunityLineItem oliRec){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<String> errorListToReturn = new List<String>();
        set<id> oppLineItemset= new set<id>();
        List<OpportunityLineItem> opptyLineItem2 = new List<OpportunityLineItem>{oliRec};
        //adding MIBNF line item in to set
        for(MI_BNF_LineItem__c MI_BNF_oppLineItem : [select Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__c=: MIBNF_Comp.Id]){
            oppLineItemset.add(MI_BNF_oppLineItem.Opportunity_Line_Itemid__c);
        }
        Boolean US_SalesOrg=(Pattern.matches('US[\\s|[A-z]|[0-9]]*',MIBNF_Comp.MIBNF__r.Sales_Org_Code__c.toUpperCase())) ? true : false;   
        BNF_Settings__c bnfSetting =BNF_Settings__c.getInstance();
        Boolean IsNewBnf = setIsNewBnfFlag(bnfSetting,MIBNF_Comp);
        boolean Val = true;
        boolean BillingDateError = false;
        boolean DeliveryDateError = false;
        boolean ListPriceError=false; // List Price Validation
        boolean dataMonthChgListPriceError = false;
        boolean ValError = false; 
        //  The Revised_Revenue_Schedule__c and Billing_Schedule__r.Total_Billing_Amount__c can be changed in a popup window, hence we need to retrieve the latest value
        Map<Id,OpportunityLineItem> OLI_Map = new Map<Id,OpportunityLineItem>([select Id,Billing_Schedule__r.Total_Billing_Amount__c,Revised_Revenue_Schedule__c from OpportunityLineItem where Id in :oppLineItemset]);
        //==== START code to check project start/end dates vs revenue schedule dates (ER003)
        //  Retrieve all OpportunityLineItemSchedules to validate against project start/end dates
        Map<String,Boolean> OLIScheduleMapStartDate = new Map<String,Boolean>();
        Map<String,Boolean> OLIScheduleMapEndDate = new Map<String,Boolean>(); 
        Map<Id,OpportunityLineItem> opptyLineItem2_Map = new Map<Id,OpportunityLineItem>();
        for (OpportunityLineItem OLI:opptyLineItem2){
            opptyLineItem2_Map.put(OLI.Id,OLI);
        }
        LIST<AggregateResult> OLSSchedule_Array = [Select MIN(ScheduleDate) StartDate,Max(ScheduleDate) EndDate,
                                                   OpportunityLineItemId,OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c from OpportunityLineItemSchedule where OpportunitylineitemId in : OLI_Map.keySet() and OpportunityLineItem.PricebookEntry.Product2.Material_Type__c = 'ZREP'
                                                   group by OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c,OpportunityLineItemId];
        
        for(AggregateResult agg : OLSSchedule_Array) {
            //  If a revised BNF is being validated but no revised schedule has been specified, then the validation must be done against the original
            //  Opportunitylineitemschedules using the updated data period start
            Date StartDate = (MIBNF_Comp.Addendum__c ? opptyLineItem2_Map.get(String.valueof(agg.get('OpportunityLineItemId'))).Product_Start_Date__c : Date.valueof(agg.get('Project_Start_Date__c')));
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
                List<String> strRevSchedule = OLI.Revised_Revenue_Schedule__c.split('\\|');  
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
                    system.debug('year: ' + tempDate.left(4));
                    system.debug('month: ' + tempDate.mid(5,2));
                    system.debug('day: ' + tempDate.right(2));
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
        if(IsNewBnf){
            for (OpportunityLineItem OLI:opptyLineItem2){
                if (OLIScheduleMapStartDate.containskey(oli.id) && OLIScheduleMapStartDate.get(oli.id)==true || OLIScheduleMapEndDate.containskey(oli.id) && OLIScheduleMapEndDate.get(oli.id)==true){		          
                    //  If there is a revised price, put the error on the revised price field and the other field that can also be used to edit the revised revenue schedules.
                    if (OLI.Revised_Price__c != null){
                        errorListToReturn.add('Revenue Schedule Error Msg: Revised revenue schedules must be within project start/end dates');	            	
                    }
                    //  Else put the error on the field with the link to edit the OpportunityLineItemSchedules
                    else
                        errorListToReturn.add('Revenue schedules must be within project start/end dates');
                    ValError = true;                                         
                }
            } 
        }
        //==== END  code to check project start/end dates vs revenue schedule dates (ER003)
        
        for(Integer i=0;i<opptyLineItem2.size();i++){
            
            if (opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !='Management Consulting' &&
                opptyLineItem2[i].List_Price__c==null && 
                opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !=Label.CES_TOT_Offering_Type && US_SalesOrg == false){
                errorListToReturn.add('List Price: Please Enter List price');
                ValError = true; 
            } 
            
            //  Delivery date must be after data period end, except for materials with "PERF" in the material code
            if (!opptyLineItem2[i].PricebookEntry.ProductCode.toUpperCase().contains('PERF') &&
                opptyLineItem2[i].Delivery_Date__c < opptyLineItem2[i].Product_End_Date__c){
                errorListToReturn.add('Delivery date cannot be earlier than data period end.');
                ValError = true; 
            }
            // ------- BEGIN CONTRACT VS DATA PERIOD DATES VALIDATION              
            //  Data month start must be before contract end date
            //  For new C&S iBNF (ER003), the data period vs contract date validation is ignored as the data periods come from project start/end and project start/end
            //  must be within engagement start/end and engagement start/end must be within contract start/end
            if (opptyLineItem2[i].Product_Start_Date__c > MIBNF_Comp.MIBNF__r.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                ValError = true;
                errorListToReturn.add('Product Start Date: Data period must start before contract end date.');
            }     
            //  Data month end must be before contract end date
            if (opptyLineItem2[i].Product_End_Date__c > MIBNF_Comp.MIBNF__r.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)){
                ValError = true;
                errorListToReturn.add('Product End Date: Data period must end before contract end date.');
            }     
            // For subscription products (i.e. not back data and not ad hoc)      
            if (opptyLineItem2[i].Revenue_Type__c != 'Back Data' && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)) {
                //  Data period end must be after contract start date
                if (opptyLineItem2[i].Product_End_Date__c < MIBNF_Comp.MIBNF__r.Contract_Start_Date__c){    
                    ValError = true;
                    errorListToReturn.add('Product End Date: Data period must end after contract start date.');
                }
                //  Data period start must be after contract start date
                if (opptyLineItem2[i].Product_Start_Date__c < MIBNF_Comp.MIBNF__r.Contract_Start_Date__c){
                    ValError = true;
                    errorListToReturn.add('Product Start Date: Data period must start after contract start date.');
                }
            }
            
            
            if(IsNewBnf) {  
                if((opptyLineItem2[i].Revenue_Type__c=='Ad Hoc')&&(opptyLineItem2[i].Billing_Date__c==null) && opptyLineItem2[i].Pricebookentry.product2.Material_Type__c=='ZPUB' && opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC'){
                    Val = false;
                    errorListToReturn.add('Billing Date: Please enter Billing Date for Ad Hoc Product.');                    
                }  
            } else {
                if((opptyLineItem2[i].Revenue_Type__c=='Ad Hoc')&&(opptyLineItem2[i].Billing_Date__c==null)){
                    Val = false;
                    errorListToReturn.add('Billing Date: Please enter Billing Date for Ad Hoc Product.');   
                }  
            }      
            
            if(IsNewBnf) {          
                if(opptyLineItem2[i].Billing_Frequency__c=='Once' && opptyLineItem2[i].Billing_Date__c==null && opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c !='ZREP'){
                    BillingDateError = true;  
                    errorListToReturn.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');                
                }   
            } else {
                if(opptyLineItem2[i].Billing_Frequency__c=='Once' && opptyLineItem2[i].Billing_Date__c==null ){
                    BillingDateError = true;  
                    errorListToReturn.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');                
                } 
            }
            
            
            if(opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]' && opptyLineItem2[i].Delivery_Date__c==null){
                DeliveryDateError = true;
                errorListToReturn.add('Delivery Date: Delivery date is mandatory when Delivery frequency "Once" is selected.');                  
            }
            
            // Surcharge Calculation
            Decimal SalesPrice = MIBNF_Comp.Addendum__c ? (opptyLineItem2[i].Revised_Price__c != null ? opptyLineItem2[i].Revised_Price__c : opptyLineItem2[i].TotalPrice)  : opptyLineItem2[i].TotalPrice;
            
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (opptyLineItem2[i].Surcharge_Text__c==null || opptyLineItem2[i].Surcharge_Text__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP)) )
              ){
                errorListToReturn.add('Surcharge Text: Please input Surcharge Text');
                ListPriceError = true;    
            }
            
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (opptyLineItem2[i].Discount_Reason__c==null || opptyLineItem2[i].Discount_Reason__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) ))
              ){
                errorListToReturn.add('Discount Reason: Please input Discount reason');
                ListPriceError = true;    
            }
            
            if(bnfSetting.Enable_BNF_Surcharge__c==true && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) )){
                opptyLineItem2[i].Surcharge_Text__c='';
            }
            else if(bnfSetting.Enable_BNF_Surcharge__c==true && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                opptyLineItem2[i].Discount_Reason__c='';
            }
            else if(bnfSetting.Enable_BNF_Surcharge__c==true && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) == SalesPrice.setScale(2,system.roundingMode.HALF_UP))){
                opptyLineItem2[i].Discount_Reason__c='';
                opptyLineItem2[i].Surcharge_Text__c='';
            }    
            
            //  For ZPUB products, if delivery frequency "once" is selected, then users must select billing frequency of "once".             
            if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c =='ZPUB' && opptyLineItem2[i].Proj_Rpt_Frequency__c == 'Once [O]' && opptyLineItem2[i].Billing_Frequency__c != 'Once'){
                errorListToReturn.add('Billing Frequency: If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.');
                ValError = true; 
            }   
            
            if(IsNewBnf) {
                //  Issue-05381
                if ((opptyLineItem2[i].Billing_Frequency__c == '50% upon signature, 50% upon completion' || opptyLineItem2[i].Billing_Frequency__c == 'Other') && 
                    opptyLineItem2[i].Pricebookentry.product2.Material_Type__c=='ZPUB' && opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC') {
                        errorListToReturn.add('Billing Frequency: \'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable ZPUB products. Please select some other Billing Frequency.');
                        ValError = true; 
                    }     
            }               
            
            if((opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLI' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLU') && opptyLineItem2[i].Nbr_of_Users__c <= 0){
                ValError = true; 
                errorListToReturn.add('Nbr of Users: Please enter a non-zero amount for number of users');
            }
            
            //  Check that billing schedule adds up to total of sales price/revised sales price
            //  If user is entering screen for first time after creating a new BNF, ignore billing schedule validations
            if(IsNewBnf) {
                ////Billing Schedule Validation for ZREP and ZLIC proeducts 
                if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c == 'ZREP'|| opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC') {
                    
                    //Billing Schedule Validation    
                    //  Set revised price as the comparison to be used for revised bnf                        
                    Decimal ValidationPrice;
                    if (MIBNF_Comp.Addendum__c && opptyLineItem2[i].Revised_Price__c != null)
                        ValidationPrice = opptyLineItem2[i].Revised_Price__c.setScale(2);
                    else
                        ValidationPrice = opptyLineItem2[i].TotalPrice.setscale(2);    
                    
                    if(OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c==NULL && (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0)){                       
                        ValError = true; 
                        //  Use the "dummy" MIBNF_Cancel__c field to display an error next to the billing schedule link      
                        errorListToReturn.add('Billing Schedule: No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').');	                
                    }   
                    if( OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c!=NULL && OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) != ValidationPrice &&
                       (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0)){
                        ValError = true; 
                        //  Use the "dummy" MIBNF_Cancel__c field to display an error next to the billing schedule link                                
                        errorListToReturn.add('Billing Schedule: Billing schedule total (' + OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').');	                
                    }
                }
            }
            
            if(IsNewBnf) {
                if(opptyLineItem2[i].List_Price__c!=null && opptyLineItem2[i].TotalPrice==0 && opptyLineItem2[i].List_Price__c!=0 && 
                   (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c=='ZREP' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')) {
                    ListPriceError = true;                  
                    errorListToReturn.add('List Price: ZREP/ZLIC materials with zero value sales price must also have zero value list price.');
                }
            }    
            // updated by Dheeraj Kumar Issue-10593 -- 25 April 2017
            if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null) {
                ValError = true;
                errorListToReturn.add('Profit Center: Please Enter Profit Center');
            }
        }  
        
        if (errorListToReturn.size() > 0 || Val==false || BillingDateError || DeliveryDateError || dataMonthChgListPriceError || ListPriceError || ValError)  {
            returnMap.put('error',errorListToReturn);
        }else{
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
    public static String setLocaleFormat(){
        String LocalekeyFormat = '';
        if((User_Locale__c.getinstance('Format1').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format1').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
           (User_Locale__c.getinstance('Format1').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format1').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                
                LocalekeyFormat='Locale_Format1';
            }else if((User_Locale__c.getinstance('Format2').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format2').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                     (User_Locale__c.getinstance('Format2').LocaleSidKey1__c!=null && 
                      User_Locale__c.getinstance('Format2').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                          LocalekeyFormat='Locale_Format2';
                      }
        else if((User_Locale__c.getinstance('Format3').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format3').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                (User_Locale__c.getinstance('Format3').LocaleSidKey1__c!=null && 
                 User_Locale__c.getinstance('Format3').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                     LocalekeyFormat='Locale_Format3';
                 }
        else if((User_Locale__c.getinstance('Format4').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format4').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
                (User_Locale__c.getinstance('Format4').LocaleSidKey1__c!=null && 
                 User_Locale__c.getinstance('Format4').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';'))){
                     LocalekeyFormat='Locale_Format4';
                 }
        else if(User_Locale__c.getinstance('Format5').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
            LocalekeyFormat='Locale_Format5';
        }
        else if(User_Locale__c.getinstance('Format6').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
            LocalekeyFormat='Locale_Format6';
        }
        else if(User_Locale__c.getinstance('Format7').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')){
            LocalekeyFormat='Locale_Format7';
        }
        else
            LocalekeyFormat='Locale_Format1';
        return LocalekeyFormat;
    }
    
}