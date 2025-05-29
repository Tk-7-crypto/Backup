public class BNFProductControllerMobile {
    
    public static  List<Map<String, String>> setRevenueCountryList() {
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
    
    public static Map<String,Object> fetchAllDetailsOnLoad(String recsId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        returnMap.put('profitCenterOptions', setRevenueCountryList());
        List<Boolean> isProfitCenterReadOnlyList = new List<boolean>();
        BNF2__c bnf = [Select Opportunity__c,Opportunity__r.opportunity_number__c, Opportunity_Number__c, Name, Addendum__c, Contract_Start_Date__c, Contract_End_Date__c, X2nd_Address__c, Comments__c,Sales_Org_Code__c,
                       RecordTypeId,BNF_Status__c,Revenue_Analyst__r.User__c, Bill_To__r.PO_Required__c, Client_PO_Number__c from BNF2__c where id = :recsId]; 
        returnMap.put('bnfRecord', bnf);
        Boolean US_SalesOrg = (bnf.RecordTypeId !=  MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? true : false;    
        returnMap.put('US_SalesOrg', US_SalesOrg);
        returnMap.put('Label_CES_TOT_Offering_Type', System.Label.CES_TOT_Offering_Type);
        List <OpportunityLineItem> opptyLineItem2 = [Select ProfitCenter__c,Name, PricebookEntry.Product2.Material_Group_1__c, Audit_Subscription_Status__c,Product2.Id,Product2.ProductCode,
                                                     Opportunity.Therapy_Area__c,PriceBookEntry.Product2.Delivery_Frequency__c ,PriceBookEntry.Product2.Delivery_Media__c,Project_End_Date__c,Project_Start_Date__c,Revenue_Schedule_Error_Msg__c,
                                                     Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c,Therapy_Area__c, PricebookEntry.Name,Product2.Name,Other_Ship_To_Address__c,Other_Ship_To_SAP_Contact__c,
                                                     PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c , PricebookEntry.Product2.Offering_Type__c,Budget_Therapy_Area__c,UnitPrice,
                                                     List_Price__c, Nbr_of_Users__c, Book_No__c,CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c,Billing_Schedule_Error_Msg__c, Surcharge_Text__c,
                                                     PricebookEntry.ProductCode,Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,OpportunityId,Revenue_Type__c,Revised_Revenue_Schedule__c,
                                                     Discount_Reason__c, Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, PricebookEntry.Product2.Item_Category_Group__c,
                                                     Invoice_Lag_to_Data_Period__c, Revised_Price__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,Sales_Text__c,
                                                     PricebookEntry.Product2.Therapy_Class__c from OpportunityLineItem where OpportunityId = :bnf.Opportunity__c 
                                                     and Product_Material_Type__c  NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
        
        Map<id,List<Map<String,String>>>  DeliveryMedia_Map = new Map<id,List<Map<String,String>>>();
        Map<id,List<Map<String,String>>>  DeliveryFrequency_Map = new Map<id,List<Map<String,String>>> ();
        
        Map<id,List<Map<String,String>>> oliIdToTherapyAreaOptionsMap = new Map<id,List<Map<String,String>>>();
        
        Schema.DescribeFieldResult fieldResultDeliveryMedia = OpportunityLineItem.Delivery_Media__c.getDescribe();
        List<Schema.PicklistEntry> pleDeliveryMedia = fieldResultDeliveryMedia.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultProj_Rpt_Frequency = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> pleProj_Rpt_Frequency = fieldResultProj_Rpt_Frequency.getPicklistValues();  
        
        Schema.DescribeFieldResult fieldResultTherapyArea = OpportunityLineItem.Therapy_Area__c.getDescribe();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = fieldResultTherapyArea.getPicklistValues();              
        
        for(OpportunityLineItem oli : opptyLineItem2){
            isProfitCenterReadOnlyList.add(oli.PricebookEntry.Product2.Material_Group_1__c != 'MAN'); 
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
            } else {
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
            List<Map<String,String>> DeliveryFrequencyOptions = new List<Map<String,String>>();  
            Map<String,String> deliveryFrequencyMap = new Map<String,String>();
            deliveryFrequencyMap.put('label','--None--');
            deliveryFrequencyMap.put('value','');
            DeliveryFrequencyOptions.add(deliveryFrequencyMap); 
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
                    if(FieldsvaluesMap.containsKey(DeliveryFrequencyOption)){
                        deliveryFrequencyMap = new Map<String, String>();
                        deliveryFrequencyMap.put('label',FieldsvaluesMap.get(DeliveryFrequencyOption));
                        deliveryFrequencyMap.put('value',FieldsvaluesMap.get(DeliveryFrequencyOption));
                        DeliveryFrequencyOptions.add(deliveryFrequencyMap); 
                    }   
                }
            }
            DeliveryFrequency_Map.put(oli.id,DeliveryFrequencyOptions);
        }
        returnMap.put('oliIdToTherapyAreaOptionsMap', oliIdToTherapyAreaOptionsMap);
        returnMap.put('DeliveryMedia_Map', DeliveryMedia_Map);
        returnMap.put('DeliveryFrequency_Map', DeliveryFrequency_Map);
        returnMap.put('opptyLineItem2', opptyLineItem2);
        String isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);
        returnMap.put('isProfitCenterReadOnlyList', isProfitCenterReadOnlyList);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveOLI(BNF2__c bnfRec, OpportunityLineItem oliRec){
        Map<String,Object> returnMap = new Map<String,Object>();
        List<String> errorListToReturn = new List<String>();
        List <OpportunityLineItem> opptyLineItem2 = new List<OpportunityLineItem>{oliRec};
        boolean Val = true;
        boolean BillingDateError = false;
        boolean DeliveryDateError = false;
        boolean ListPriceError=false;
        boolean profitCenterError = false;
        
        for(Integer i=0;i<opptyLineItem2.size();i++){
            if((opptyLineItem2[i].Revenue_Type__c=='Ad Hoc')&&(opptyLineItem2[i].Billing_Date__c==null)){
                Val = false;            
            }                  
            if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null)){
                BillingDateError = true;                  
            }      
            if((opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]')&&(opptyLineItem2[i].Delivery_Date__c==null) && bnfRec.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id){
                DeliveryDateError = true;                  
            }
            if(opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && (opptyLineItem2[i].List_Price__c.setScale(2, system.roundingMode.HALF_UP)<opptyLineItem2[i].TotalPrice.setScale(2, system.roundingMode.HALF_UP) ) && bnfRec.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id){
                ListPriceError = true;                  
            }
            if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null) {
                profitCenterError = true;
                errorListToReturn.add('Profit Center: Please Enter Profit Center');
            }           
        }
        
        if (BillingDateError){
            errorListToReturn.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected.');
        }      
        if (DeliveryDateError){
            errorListToReturn.add('Delivery date is mandatory when delivery frequency "Once" is selected.');
        }                    
        if(Val==false){          
            errorListToReturn.add('Please enter Billing Date for Ad Hoc Product');
        }
        
        if (ListPriceError){
            errorListToReturn.add('List price cannot be less than sales price.');
        }
        if (Val==false || BillingDateError || DeliveryDateError || profitCenterError){
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
      
}