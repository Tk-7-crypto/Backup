///********      
//  IMS 
//  Created by Anjali Salecha on 19-Aug-2010
//  Class contain common methods to generate and parse Json.
///*******

public  class EXT_CRM_OpportunityRenewal_Dashboard 
{
  /////************  Properties   *************/////////////
  
    final String NEW_TASK_STATUS_STR = '';
    final String DROP_INACTIVE_PROD_MSG = 'Material no longer active' ;
    final String SALE_TYPE_RPT_STR = 'Repeat';

    public  string RenewalTaskJson{get;set;}
    public  string RenewalTaskJson1{get;set;}
    public  Integer pageNumber{get;set;}
    public  String sortDir{get;set;}
    public  String sortField{get;set;}
    public List<String> noRenewReasons{get;set;}
    public  String additionalFilter{get;set;}

    //public  string UpdatedRenewalTaskJson{get;set;}
    public string UserLocale{get;set;}
    
    public transient List<Renewal_Task__c> listOfRenewal_Task {get;set;}
    
    //dummy line item var to access picklist values on VF page
    //public OpportunityLineItem oppLineItem {get;set;}
    List<Renewal_Task_Change_Detail__c> taskChangeDetailList ; 
    
    //Map of line item id and corresponding change detail object
    Map<String, Renewal_Task_Change_Detail__c> OliIdRtChangeDetailMap;
    
    //Map of renewal task id and rennewalTask
    public Map<String, Renewal_Task__c> rtIdMap;
    
    //flag for synchronous or defferred cloning
    Boolean isSynchronousClone = false;
    
    public Boolean firstJsonToParse{get;set;}
    public string jsonForCloning{get;set;}
    List<Renewal_Task__c> renewalTasksForClone;
    List<Renewal_Task_Change_Detail__c> changeDetailsForClone;
    
    /* Search variables*/
    public String sOppNumber{get;set;}
    public String sOppName{get;set;}
    public String sAccName{get;set;}
    public String sPOppNumber{get;set;}
    public String sPOppName{get;set;}
    
    /*task to deActivate*/
    public String renewalTaskToDeactivate{get;set;}

    /////************  Enum   *************/////////////
    public enum DateFormats {
        MMDDYY, 
        YYMMDD,
        DDMMYY
    }
    
    /////************  Constructor   *************/////////////
    
    public EXT_CRM_OpportunityRenewal_Dashboard()
    {
        if(additionalFilter == null)
            additionalFilter = '  ';
        GenerateRenewalTaskJson();
        
        String dashBoardCurrentPage = ApexPages.currentPage().getParameters().get('dashBoardCurrentPage');
        if(dashBoardCurrentPage != null && dashBoardCurrentPage !='' && (!'undefined'.equalsIgnoreCase(dashBoardCurrentPage)) )
            pageNumber = Integer.valueOf(dashBoardCurrentPage);
        else 
            pageNumber = 1;
        ApexPages.currentPage().getParameters().put('dashBoardCurrentPage', '');
         
        String sortDirection = ApexPages.currentPage().getParameters().get('sortDir');
        if(sortDirection != null && sortDirection !='')
            sortDir = sortDirection;
        else 
            sortDir = 'undefined';
        ApexPages.currentPage().getParameters().put('sortDir', 'undefined');
        
        String fieldForSort = ApexPages.currentPage().getParameters().get('sortField');
        if(fieldForSort != null && fieldForSort !='')
            sortField = fieldForSort;
        else 
            sortField = 'undefined';
        ApexPages.currentPage().getParameters().put('sortField', 'undefined');

        UserLocale = UserInfo.getLocale();
        
        noRenewReasons = new List<String>();
        Schema.DescribeFieldResult fieldNoRenewReason = Renewal_Task__c.No_Renew_Reason__c.getDescribe();
        for(Schema.PicklistEntry pe : fieldNoRenewReason.getPicklistValues()){
            noRenewReasons.add('"'+pe.getValue()+'"');
        }
        
        ApexPages.getMessages().clear();
    } 
    
    
    
    /////************  Methods   *************/////////////
    
    private void queryRenewalTaskList() {
        Integer MAX_TASKS = 200;
        Set<String> oppStages = new Set<String>{CON_CRM_OpportunityRenewals.OPP_STAGE_6A, CON_CRM_OpportunityRenewals.OPP_STAGE_IN_HAND, CON_CRM_OpportunityRenewals.OPP_STAGE_6B};
        Id userId = userInfo.getUserId();
        String NO_RENEW_STATUS_STR = CON_CRM_OpportunityRenewals.NO_RENEW_STATUS_STR;
        String q = 'Select Id, Name, Round_Up__c, Price_Increase__c, Cloning_Action__c, Cloning_Status__c, Cloned_Opportunity__c, Cloned_Opportunity__r.name, Cloned_Opportunity__r.Opportunity_Number__c, Cloned_Opportunity__r.StageName, '+
            ' Targeted_Close_Date__c, ownerId, Owner_Country__c, No_Renew_Reason__c, Data_Period_Shift__c, CurrencyIsoCode, Opportunity__r.account.name, Opportunity__r.name, Opportunity__r.C_S_Contract_Value__c, Opportunity__r.Amount, Opportunity__r.Contract_End_Date__c, '+
            ' Opportunity__r.Contract_Type__c, Opportunity__r.CloseDate, Opportunity__r.Actual_Close_Date__c, Opportunity__r.CurrencyIsoCode, Opportunity__r.Opportunity_Number__c, Opportunity__r.Parent_Opportunity__c,  Opportunity__r.Parent_Opportunity__r.name, '+
            ' (Select Id, Renewal_Task__c, Opportunity_Line_Item_Id__c, Dropped_Reason__c, Product_Invoice_Text__c, Billing_Frequency__c, Data_Month_End__c, Data_Month_Start__c, Proj_Rpt_Frequency__c, Territory__c, Delivery_Media__c, Revenue_Type__c, Sale_Type__c, '+
            ' Previous_Contract_Value__c, Type__c, TotalPrice__c, Winback__c From Renewal_Task_Change_Details__r) Opportunity__c, Opportunity__r.id  from Renewal_Task__c where ownerId = :userId '+
            ' and Cloned_Opportunity__r.StageName not in :oppStages and Cloning_Status__c != :NO_RENEW_STATUS_STR AND Is_Removed__c = false '+ additionalFilter +
            ' order by Opportunity__r.Contract_End_Date__c ASC Limit : MAX_TASKS';
        listOfRenewal_Task = Database.query(q);
    }
    
    
    public  string GenerateRenewalTaskJson() 
    {
        
        queryRenewalTaskList();
        
        //set to retrieve opportunity line items
        Set<ID> setOpportunityIds = new Set<ID> ();
        Boolean isInnerGridPresent = false;
        
        taskChangeDetailList = new List<Renewal_Task_Change_Detail__c> ();
        rtIdMap = new Map<String, Renewal_Task__c> ();
        for(Renewal_Task__c renewaltsak :listOfRenewal_Task) 
        {
            
            setOpportunityIds.add(renewaltsak.Opportunity__c);
            
            taskChangeDetailList.addAll(renewaltsak.Renewal_Task_Change_Details__r);  
            rtIdMap.put('' + renewaltsak.id , renewaltsak );          
        }
        
        OliIdRtChangeDetailMap = new Map<String, Renewal_Task_Change_Detail__c> ();
        for(Renewal_Task_Change_Detail__c changeDetail : taskChangeDetailList) {
            OliIdRtChangeDetailMap.put('' + changeDetail.Opportunity_Line_Item_Id__c, changeDetail);
        }       
        
        List<OpportunityLineItem> listOfOpportunityLineItem = [select ID ,
                                                                PricebookEntry.ProductCode, 
                                                                PricebookEntry.Name,
                                                                TotalPrice,
                                                                OpportunityId,
                                                                Business_Type__c,
                                                                Product_Start_Date__c,
                                                                Product_End_Date__c,
                                                                Sale_Type__c,
                                                                Revenue_Type__c,
                                                                Delivery_Country__c,
                                                                Proj_Rpt_Frequency__c,
                                                                Winback__c,
                                                                Billing_Frequency__c,
                                                                Delivery_Media__c,
                                                                Revised_Price__c,
                                                                Output_Format__c,
                                                                (select ID, Revenue from  
                                                                OpportunityLineItemschedules) 
                                                                from OpportunityLineItem 
                                                                where OpportunityId in :setOpportunityIds];
        
        //if(listOfOpportunityLineItem.size() > 0)
            //oppLineItem = listOfOpportunityLineItem[0];
            
        
        //////////////////////////Code Refactoring////////////////////////////
        //map of opportunity id and it's line items.
        Map<Id, List<OpportunityLineItem>> oppIdLineItemsMap = new Map<Id, List<OpportunityLineItem>> ();
        
        if(listOfOpportunityLineItem.size() > 0) {
            //oppLineItem = listOfOpportunityLineItem[0];
            for(OpportunityLineItem queryOLI : listOfOpportunityLineItem) {
                   List<OpportunityLineItem> listQueryLIs = oppIdLineItemsMap.get(queryOLI.OpportunityId);
                   if(listQueryLIs == null) {
                         listQueryLIs = new List<OpportunityLineItem> ();
                         oppIdLineItemsMap.put(queryOLI.OpportunityId, listQueryLIs);

                   }
                   listQueryLIs.add(queryOLI);
            }
        }
        //////////////////////////////////////////////////////
        
        RenewalTaskJson = '{ ';
        RenewalTaskJson += '"outerGridRecords" :  {';
       
        RenewalTaskJson += '"count" : '+listOfRenewal_Task.size()+',';
        RenewalTaskJson += '"outerRecArr" : [ ';
        
        for( Renewal_Task__c renewalTask : listOfRenewal_Task )
        {
            RenewalTaskJson +='{ "id" : "'+renewalTask.Id +'",';
            RenewalTaskJson +='"name" : "'+renewalTask.Name +'",';
            RenewalTaskJson +='"oppName" : "'+ sanitizeString(renewalTask.Opportunity__r.name) +'",';
            System.debug('***************oppName : *************** '+ sanitizeString(renewalTask.Opportunity__r.name));
            String dataPeriodShift =  '';
            
            if(renewalTask.Data_Period_Shift__c != null)
                dataPeriodShift = String.valueOf(renewalTask.Data_Period_Shift__c);
            
            RenewalTaskJson +='"dataPeriodShift" : "'+ dataPeriodShift +'",';
            RenewalTaskJson +='"roundup_action" : "'+ renewalTask.Round_Up__c +'",';
                        
            if(renewalTask.Opportunity__r.Amount  != null)
              RenewalTaskJson +='"contractValue" : "'+ renewalTask.Opportunity__r.Amount +'",';
            else
              RenewalTaskJson +='"contractValue" : "",';//*/
            
            RenewalTaskJson +='"accName" : "'+ sanitizeString(renewalTask.Opportunity__r.Account.Name) +'",'+
            +'"acc_Id" : "' + renewalTask.Opportunity__r.AccountId + '",';
                                                
            if( renewalTask.Opportunity__r.Opportunity_Number__c != null )
              RenewalTaskJson +='"oppNum" : "'+ renewalTask.Opportunity__r.Opportunity_Number__c+'",';
            else
              RenewalTaskJson +='"oppNum" : "",';
                          
            if( renewalTask.Opportunity__r.id != null )
              RenewalTaskJson +='"oppId" : "'+ renewalTask.Opportunity__r.id+'",';
            else
              RenewalTaskJson +='"oppId" : "",';
              
            if(renewalTask.Opportunity__r.Contract_End_Date__c != null)  
              RenewalTaskJson +='"contractEndDate" : "'+getFormatedDate(renewalTask.Opportunity__r.Contract_End_Date__c,'-',DateFormats.MMDDYY)+'",';
            else
              RenewalTaskJson +='"contractEndDate" : "",';
            
            if(renewalTask.Opportunity__r.Contract_Type__c != null)  
              RenewalTaskJson +='"contractType" : "'+ renewalTask.Opportunity__r.Contract_Type__c+'",';
            else
              RenewalTaskJson +='"contractType" : "",';
              
            if(renewalTask.Opportunity__r.CurrencyIsoCode != null) {
                RenewalTaskJson +='"currencyCode" : "'+ renewalTask.Opportunity__r.CurrencyIsoCode +'",';
            } else {
                RenewalTaskJson +='"currencyCode" : "",';
            }
                                      
            if( renewalTask.Opportunity__r.Parent_Opportunity__c != null ) {
                RenewalTaskJson +='"org_pri_opp" : "'+ renewalTask.Opportunity__r.Parent_Opportunity__r.name +'",'+ //opp.Name+'",'+
                +'"org_pri_opp_id" : "'+renewalTask.Opportunity__r.Parent_Opportunity__c+'",';//"'+opp.Id+'",';
            }
            if((renewalTask.Cloning_Status__c != null && renewalTask.Cloned_Opportunity__c != null && renewalTask.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B) || (renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_RENEW_STR)))
              RenewalTaskJson +='"cloning_action" : "'+1+'",';
            else if(renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_CHANGE_STR))
              RenewalTaskJson +='"cloning_action" : "'+2+'",';
            else if(renewalTask.Cloning_Action__c != null && string.valueOf(renewalTask.Cloning_Action__c).equalsIgnoreCase(CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR))
              RenewalTaskJson +='"cloning_action" : "'+3+'",';    
            else
              RenewalTaskJson +='"cloning_action" : "",';
            if(renewalTask.Targeted_Close_Date__c != null)  
              RenewalTaskJson +='"closeDate" : "'+getFormatedDate(renewalTask.Targeted_Close_Date__c,'-',DateFormats.MMDDYY)+'",';
                
            else
              RenewalTaskJson +='"closeDate" : "",';
            if(renewalTask.Price_Increase__c != null)  
              RenewalTaskJson +='"price_inc" : "'+renewalTask.Price_Increase__c+'",';
            else
              RenewalTaskJson +='"price_inc" : "",';
            
            
            if(renewalTask.Cloned_Opportunity__c != null){
                    RenewalTaskJson +='"clonned_opportunity_id" : "'+renewalTask.Cloned_Opportunity__c+'",';
                    RenewalTaskJson +='"clonned_opportunity" : "'+ sanitizeString(renewalTask.Cloned_Opportunity__r.name) +'",';
                    RenewalTaskJson +='"clonned_opportunity_num" : "'+renewalTask.Cloned_Opportunity__r.Opportunity_Number__c+'",';
                                            
            } else {
                RenewalTaskJson +='"clonned_opportunity_id" : "",';
                RenewalTaskJson +='"clonned_opportunity" : "",';
                 RenewalTaskJson +='"clonned_opportunity_num" : "",';
            } 
            
            //noRenewComment
            if(renewalTask.No_Renew_Reason__c != null){
                    RenewalTaskJson +='"noRenewComment" : "'+renewalTask.No_Renew_Reason__c + '",';
                                            
            } else {
                RenewalTaskJson +='"noRenewComment" : "",';
            } 
            
            if(renewalTask.Cloning_Status__c != null){
                if(renewalTask.Cloned_Opportunity__c != null && renewalTask.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B){
                    RenewalTaskJson +='"cloning_status" : "'+CON_CRM_OpportunityRenewals.NEEDS_NO_RENEW_REASON_STR+'",';
                } else
                    RenewalTaskJson +='"cloning_status" : "'+renewalTask.Cloning_Status__c+'",';
            } else
              RenewalTaskJson +='"cloning_status" : "",';
            
            RenewalTaskJson +='"innerGridRecords" : { list :[';
            
            //oppIdLineItemsMap
            List<OpportunityLineItem> oppLineItemsList = oppIdLineItemsMap.get(renewalTask.Opportunity__r.id);
            //for(OpportunityLineItem OlI : listOfOpportunityLineItem)
            if(oppLineItemsList != null ) {
                for(OpportunityLineItem OlI : oppLineItemsList ) 
                {
                    if(renewalTask.Opportunity__c == OlI.OpportunityId)
                    {
                            Renewal_Task_Change_Detail__c cDetail = OliIdRtChangeDetailMap.get(OlI.id);
                            Boolean isDetailPresent = false;
                            if(cDetail != null) isDetailPresent = true;
                            isInnerGridPresent = true;
                            RenewalTaskJson += '{'+
                                    +'"id" : "'+OlI.Id+'",'+
                                    +'"sapCode" : "'+ OlI.PricebookEntry.ProductCode +'",'//;
                                    +'"productName" : "'+ sanitizeString(OlI.PricebookEntry.Name) +'",'; 
                            if(OlI.Business_Type__c != null)
                              RenewalTaskJson +='"businessType" : "'+OlI.Business_Type__c+'",';
                            else
                              RenewalTaskJson +='"businessType" : "",';
                            
                            if(OlI.Product_Start_Date__c != null)
                              RenewalTaskJson +='"dataPeriodStart" : "'+getFormatedDate(OlI.Product_Start_Date__c,'-',DateFormats.MMDDYY)+'",';
                            else
                              RenewalTaskJson +='"dataPeriodStart" : "",';
                            
                            if(OlI.Product_End_Date__c != null)
                              RenewalTaskJson +='"dataPeriodEnd" : "'+getFormatedDate(OlI.Product_End_Date__c,'-',DateFormats.MMDDYY)+'",';
                            else
                              RenewalTaskJson +='"dataPeriodEnd" : "",';
                            
                            if(OlI.Sale_Type__c != null)  
                              RenewalTaskJson +='"saleType" : "'+OlI.Sale_Type__c+'",';
                            else
                              RenewalTaskJson +='"saleType" : "",';
                            
                            if(OlI.Revenue_Type__c != null)
                              RenewalTaskJson +='"revenueType" : "'+OlI.Revenue_Type__c+'",';
                            else
                              RenewalTaskJson +='"revenueType" : "",';  
                            
                            if(OlI.Delivery_Country__c != null)
                              RenewalTaskJson +='"delivery_cnty" : "'+OlI.Delivery_Country__c+'",';
                            else
                              RenewalTaskJson +='"delivery_cnty" : "",';
                            
                            //Proj_Rpt_Frequency__c, , Billing_Frequency__c, Delivery_Media__c                      
                            if(OlI.Proj_Rpt_Frequency__c != null) {
                                RenewalTaskJson +='"rpt_freq" : "'+ OlI.Proj_Rpt_Frequency__c +'",';
                            } else {
                                RenewalTaskJson +='"rpt_freq" : "",';
                            }
                            
                            //Winback__c
                            if(OlI.Winback__c != null) {
                                RenewalTaskJson +='"winback" : "'+ OlI.Winback__c +'",';
                            } else {
                                RenewalTaskJson +='"winback" : "",';
                            }
                            
                            if(OlI.Billing_Frequency__c != null) {
                                RenewalTaskJson +='"bill_freq" : "'+ OlI.Billing_Frequency__c +'",';
                            } else {
                                RenewalTaskJson +='"bill_freq" : "",';
                            }
                            
                            if(OlI.Delivery_Media__c != null) {
                                RenewalTaskJson +='"del_media" : "'+ OlI.Delivery_Media__c +'",';
                            } else {
                                RenewalTaskJson +='"del_media" : "",';
                            }
                            
                            if(OlI.Output_Format__c != null) {
                                RenewalTaskJson +='"outputFormat" : "'+ OlI.Output_Format__c +'",';
                            } else {
                                RenewalTaskJson +='"outputFormat" : "",';
                            }
                            
                            if(isDetailPresent ) {
                              String comment = cDetail.Dropped_Reason__c;
                              if(comment != null && comment != '') {
                                  RenewalTaskJson += '"comment" : "' + cDetail.Dropped_Reason__c + '",';
                                  RenewalTaskJson += '"status" : "dropped",';
                              } else {
                                  RenewalTaskJson += '"status" : "' + CON_CRM_OpportunityRenewals.CLONED_STATUS_STR + '",';
                              }
                             }
                            else
                              RenewalTaskJson += '"status" : "",';
                            if(OlI.TotalPrice != null)  
                              RenewalTaskJson +='"value" : "'+OlI.TotalPrice+'"';
                            else
                              RenewalTaskJson +='"value" : ""';
                            RenewalTaskJson +='},';
                    }
                } //*/  //end of for
            }//endo of if
            if(isInnerGridPresent && RenewalTaskJson.lastIndexOf(',') == (RenewalTaskJson.length()-1))
                 RenewalTaskJson = RenewalTaskJson.substring(0,RenewalTaskJson.length()-1   );
                 
            RenewalTaskJson += ']}';
            RenewalTaskJson += '},';
            
        }
        
        if(RenewalTaskJson.lastIndexOf(',') == (RenewalTaskJson.length()-1))
            RenewalTaskJson = RenewalTaskJson.substring(0,RenewalTaskJson.length()-1);
        
        RenewalTaskJson += ']';
        RenewalTaskJson += '}';
        RenewalTaskJson += '}';
        
        system.debug('RenewalTaskJson###' + RenewalTaskJson);
        return RenewalTaskJson;
    }
    
    
    private String sanitizeString(String ipStr) {
        if(ipStr != null && ipStr != ''){
            //return ipStr.replaceAll('\"', '\\\\\"');
            ipStr = ipStr.replaceAll('\\\\', '&#092;');
            ipStr = ipStr.replaceAll('\'', '&#039;');
            ipStr = ipStr.replaceAll('\"', '&quot;');
            ipStr = ipStr.replaceAll('\\<', '&lt;');

            return ipStr;
        } else 
            return '';
    }
   
     //return formatted date 
     public static String getFormatedDate(Date d,String seprator,DateFormats format)
        {
            string strDate = ' ';
            if (d != null)
                {
                    if(format == DateFormats.MMDDYY)
                        strDate = d.month() +seprator+ d.day() +seprator+ d.year();
                    else if(format == DateFormats.YYMMDD)
                        strDate = d.year() +seprator+d.month() +seprator+ d.day() ;
                    else if(format == DateFormats.DDMMYY)
                        strDate = d.day() +seprator+ d.month() +seprator+ d.year(); 
                }   
            return strDate;
        }
   
  
      public Map<Id, OpportunityLineItem> oppLineItemIdMap;
  
      private List<Renewal_Task_Change_Detail__c> initTaskDetails( List<Renewal_Task_Change_Detail__c> selectedChangeDetails ) {
           system.debug('***** selectedChangeDetails ' + selectedChangeDetails);     
           Set<ID> selectedDetailsIdSet = new Set<Id>();
           for(Renewal_Task_Change_Detail__c selDetail : selectedChangeDetails ) {
                selectedDetailsIdSet.add(selDetail.Opportunity_Line_Item_Id__c);
           } 
        
           oppLineItemIdMap = new Map<Id, OpportunityLineItem>([
                                                                select id, Business_Type__c,
                                                                Product_Invoice_Text__c,
                                                                Sales_Text__c,
                                                                PricebookEntry.Product2.Name, 
                                                                PricebookEntry.Product2.ProductCode,                                                           
                                                                PricebookEntry.Product2.IsActive,
                                                                Output_Format__c,Revised_Price__c,
                                                                Configured_Product__c,
                                                                TotalPrice, Product_Start_Date__c, 
                                                                Product_End_Date__c,
                                                                Billing_Frequency__c,
                                                                Sale_Type__c, Winback__c,
                                                                Revenue_Type__c,Delivery_Country__c,
                                                                Delivery_Media__c, Proj_Rpt_Frequency__c,
                                                                PricebookEntry.ProductCode,
                                                                (select id, revenue from OpportunityLineItemschedules)
                                                                from OpportunityLineItem where id in :selectedDetailsIdSet ]);   
            
            system.debug('***** oppLineItemIdMap ' + oppLineItemIdMap);   
            Set<String> retiredSapCodes = new Set<String>();            
            for(Renewal_Task_Change_Detail__c rtd : selectedChangeDetails)  {
                OpportunityLineItem Li = oppLineItemIdMap.get(rtd.Opportunity_Line_Item_Id__c);
                //if inactive product then add it's SAP code to retiredSapCodes set
                if(!Li.PricebookEntry.Product2.IsActive) {
                   System.debug('***************************Retired SAP Code************************ :   '+Li.PricebookEntry.Product2.ProductCode);
                   retiredSapCodes.add(Li.PricebookEntry.Product2.ProductCode);
                }
            }        
            
            Map<String, Product_Replacement_Mapping__c> prodReplacementMap = new Map<String, Product_Replacement_Mapping__c>(); 
            if((!selectedDetailsIdSet.isEmpty()) && (!retiredSapCodes.isEmpty())){
                List<Product_Replacement_Mapping__c> tempList = [select Retired_Product_SAP_Code__c, Replacement_Product_SAP_Code__c, Replacement_Product__r.Name from Product_Replacement_Mapping__c where Retired_Product_SAP_Code__c in : retiredSapCodes];
                for(Product_Replacement_Mapping__c prRpRec : tempList){
                    prodReplacementMap.put(prRpRec.Retired_Product_SAP_Code__c, prRpRec);
                }
            }//*/
                        
            for(Renewal_Task_Change_Detail__c rtd : selectedChangeDetails)  {
            		System.debug('****** rtd.Opportunity_Line_Item_Id__c ' + rtd);
            		
                    OpportunityLineItem Li = oppLineItemIdMap.get(rtd.Opportunity_Line_Item_Id__c);
                    System.debug('******* OLI  ' + Li);
                    Renewal_Task__c rt = rtIdMap.get(rtd.Renewal_Task__c);
                    System.debug('***********************Test Output format:'+Li.Output_Format__c);
                    //initialize all fields of change detail here
                    rtd.TotalPrice__c = Li.totalPrice;
                    //rtd.Previous_Contract_Value__c = ((Li.Revised_Price__c == null || Li.Revised_Price__c == 0))?Li.totalPrice:Li.Revised_Price__c; //Added date 13 Feb
                    rtd.Previous_Contract_Value__c = Li.totalPrice; //Added date 9 Jan 2013 : Himanshu
                    rtd.Billing_Frequency__c = Li.Billing_Frequency__c;
                    rtd.Sale_Type__c = SALE_TYPE_RPT_STR;//'Repeat';
                    rtd.Revenue_Type__c = Li.Revenue_Type__c;
                    rtd.Territory__c = Li.Delivery_Country__c;
					if(Li.Winback__c == false) {
                        rtd.Winback__c = 'No';
					} else {
					    rtd.Winback__c = 'Yes';
					}
                    rtd.Delivery_Media__c = Li.Delivery_Media__c;
                    rtd.Proj_Rpt_Frequency__c = Li.Proj_Rpt_Frequency__c;
                    rtd.CurrencyIsoCode = rt.CurrencyIsoCode ;
                    rtd.ProductCode__c = Li.PricebookEntry.Product2.ProductCode;
                    rtd.Product_Name__c = Li.PricebookEntry.Product2.Name;
                    rtd.Output_Format__c = Li.Output_Format__c;
                    rtd.Product_Invoice_Text__c = LI.Sales_Text__c != null ? LI.Sales_Text__c : LI.Product_Invoice_Text__c;
                    //Added date : 13 Feb
                    rtd.Type__c = (rtd.Dropped_Reason__c != null)?'Dropped':'Renewed';
                    System.debug('***********************Test Output format:'+Li.Output_Format__c);

                    rtd.Data_Month_Start__c = Li.Product_Start_Date__c;
                    rtd.Data_Month_End__c = Li.Product_End_Date__c;
                    
                   /* Update By Himanshu : 16 Jan 2014 : Issue-03475 */
                    /*if(rt.Price_Increase__c!=null)
                        rtd.Price_Amount__c=rtd.Previous_Contract_Value__c*(rt.Price_Increase__c/100); */
                    
                    //replace retired SAP Code and Product name with Replacement product 
                    Product_Replacement_Mapping__c prRpRe  = null;
                    if(prodReplacementMap.size()>0) {
                        prRpRe  =  prodReplacementMap.get(Li.PricebookEntry.Product2.ProductCode);
                        if(prRpRe!=null){
                             rtd.ProductCode__c = prRpRe.Replacement_Product_SAP_Code__c;
                             rtd.Product_Name__c = prRpRe.Replacement_Product__r.Name;
                             System.debug('********Retired SAP Code********* : '+Li.PricebookEntry.Product2.ProductCode+ '********Replace SAP Code********* : '+prRpRe.Replacement_Product_SAP_Code__c);
                        } 
                    }//*/ 
                    
                    //In case we do not find replacement mapping, drop the product
                    if(!Li.PricebookEntry.Product2.IsActive && prRpRe == null ) {
                        rtd.Dropped_Reason__c = DROP_INACTIVE_PROD_MSG;

                    }

                    
                    //if not configurable product then apply %price inc
                    if((rt.Owner_Country__c != null && rt.Owner_Country__c.toUpperCase() == 'UK') || (!Li.Configured_Product__c)) {
                        if(Li.Revised_Price__c != null && rt.Data_Period_Shift__c > 0) {
                           Integer dataPeriod = 0 ;
                           //monthsBetween
                           if(Li.Product_Start_Date__c != null) {
                           		System.debug('****Li.Product_Start_Date__c '+Li.Product_Start_Date__c+'Li.Product_End_Date__c '+Li.Product_End_Date__c);
                                dataPeriod = Li.Product_Start_Date__c.monthsBetween(Li.Product_End_Date__c);
                                System.debug('****original dataPeriod = ' + dataPeriod);
                                if(dataPeriod < 0 ) dataPeriod *= -1;
                                
                               //find months based on daysDiff - begin
                               Integer monthsBasedOnDaysDiff = Li.Product_Start_Date__c.daysBetween(Li.Product_End_Date__c)/30 ;
                               //find months based on daysDiff - end
                               if (monthsBasedOnDaysDiff > dataPeriod)
                               {
                                   dataPeriod = monthsBasedOnDaysDiff;
                               }
                               System.debug('final dataPeriod = ' + dataPeriod);
                           }
                                                      
                           if(dataPeriod != 0) {
                               Decimal monthlyPrice = Li.Revised_Price__c/dataPeriod;
                               System.debug('monthlyPrice = ' + monthlyPrice);
                               //Update by : Himanshu : 17 Oct 2013 : use Data period to calculate total price
                               //rtd.TotalPrice__c = monthlyPrice * rt.Data_Period_Shift__c  * ( 1 + (rt.Price_Increase__c/100));
                               rtd.TotalPrice__c = monthlyPrice * dataPeriod  * ( 1 + (rt.Price_Increase__c/100));
                               System.debug('TotalPrice__c = ' + rtd.TotalPrice__c);
                            } else {
                                rtd.TotalPrice__c = Li.Revised_Price__c * ( 1 + (rt.Price_Increase__c/100));
                            }
                           
                        } else {
                           rtd.TotalPrice__c = Li.totalPrice + (Li.totalPrice * (rt.Price_Increase__c/100) );
                        }
                    }

                    //Detail Clone - Round up is true then calculate revenues for Awaiting Details page total price update
                    if(rt.Round_Up__c == true && rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR) {
                        Decimal roundupTotalPrice = 0;
                        for(OpportunityLineItemSchedule olis : li.OpportunityLineItemschedules) {
                            roundupTotalPrice += ((1 + ((rtd.TotalPrice__c - li.TotalPrice)/li.TotalPrice) ) * olis.Revenue).round(System.RoundingMode.CEILING);
                        }
                        rtd.Expect_Round_up_Total_Price__c = roundupTotalPrice;
                    }
                    
                    //use data period shift for start date and end date shifting
                    if(Li.Revenue_Type__c == 'Subscription' && rt.Data_Period_Shift__c > 0){
                         if(Li.Product_End_Date__c != null)
                           rtd.Data_Month_End__c = Li.Product_End_Date__c.addMonths( Integer.valueOf(rt.Data_Period_Shift__c + '') );
                        if(Li.Product_Start_Date__c != null) {
                            rtd.Data_Month_Start__c = Li.Product_Start_Date__c.addMonths(Integer.valueOf(rt.Data_Period_Shift__c + ''));
                        }
                       
                    }
            }
           return selectedChangeDetails;
      
    }
    
        
    public void ParseJsonForCloning(string renewalTaskJson) 
    {
        system.debug('SubmittedJSON = ' + renewalTaskJson);
        queryRenewalTaskList();
        OliIdRtChangeDetailMap = new Map<String, Renewal_Task_Change_Detail__c> ();
        for(Renewal_Task_Change_Detail__c changeDetail : taskChangeDetailList) {
            OliIdRtChangeDetailMap.put('' + changeDetail.Opportunity_Line_Item_Id__c, changeDetail);
        }   
        system.debug('rtIdMap = ' + rtIdMap);
        system.debug('*** OliIdRtChangeDetailMap = ' + OliIdRtChangeDetailMap);
        //initialize the list of selected renewal tasks and change details
        if(firstJsonToParse){
            renewalTasksForClone = new List<Renewal_Task__c>();
            changeDetailsForClone = new List<Renewal_Task_Change_Detail__c> ();
        }
        
        UTL_JSONObject JsonObjectInstance =  new UTL_JSONObject(new UTL_JSONObject.JSONTokener(renewalTaskJson)) ;              
        UTL_JSONObject.value[] outerRecord = JsonObjectInstance.getValue('outerRec').values;
                
        //for each selected record
        for(Integer outerCount =0;  outerCount<outerRecord.size(); outerCount++)
        {          
          //get the renewal task id
          String rtId = outerRecord[outerCount].obj.data.get('id').valueToString();
          system.debug('rtId = '+ rtId + '***');
          
          if(rtId != null && rtId != ''){
              rtId = rtId.replace('"', '');
          }
          
          //get the renewal task obj from listOfRenewal_Task 
          Renewal_Task__c rt = rtIdMap.get(rtId);
          
          system.debug('rt = ' + rt);
          //put this renewal task in the list
          if(rt != null) { 
              //modify with incoming values
              UTL_JSONObject.value priceIncrStrObj = outerRecord[outerCount].obj.data.get('price_inc');
              String priceIncrStr = null;
              if(priceIncrStrObj != null)
                 priceIncrStr = outerRecord[outerCount].obj.data.get('price_inc').valueToString();
              if(priceIncrStr != null && priceIncrStr != '') {
                 priceIncrStr = priceIncrStr.replace('"' , '');
                 if(priceIncrStr != '')
                     rt.Price_Increase__c = Decimal.valueOf(priceIncrStr);
              } else {
                   rt.Price_Increase__c = 0.0;
              }
              
              UTL_JSONObject.value dataPeriodShiftStrObj = outerRecord[outerCount].obj.data.get('dataPeriodShift');
              String dataPeriodShiftStr = null;
              if(dataPeriodShiftStrObj != null)
                  dataPeriodShiftStr = dataPeriodShiftStrObj.valueToString();
              
              if(dataPeriodShiftStr != null && dataPeriodShiftStr != '') {
                 dataPeriodShiftStr = dataPeriodShiftStr.replaceAll('"' , '');
                 rt.Data_Period_Shift__c = Integer.valueOf(dataPeriodShiftStr);
              }
              else
                  rt.Data_Period_Shift__c =  12;

              UTL_JSONObject.value roundupObj = outerRecord[outerCount].obj.data.get('roundup_action');
              String roundup = null;
              if(roundupObj != null)
                  roundup = outerRecord[outerCount].obj.data.get('roundup_action').valueToString(); 
              if(roundup != null && roundup != ''){
                  roundup = roundup.replace('"' , '');
                  rt.Round_Up__c = Boolean.valueOf(roundup );
              } 

              UTL_JSONObject.value tCloseDateObj = outerRecord[outerCount].obj.data.get('closeDate');
              String tCloseDate = null;
              if(tCloseDateObj != null)
                  tCloseDate = outerRecord[outerCount].obj.data.get('closeDate').valueToString(); 
              if(tCloseDate!='null' && tCloseDate != null && tCloseDate != '') {
                  tCloseDate = tCloseDate.replace('"' , '');
                  if(tCloseDate != '') {
                    rt.Targeted_Close_Date__c = date.valueOf(tCloseDate );
                  }
              }
              
              UTL_JSONObject.value noRenewCommentObj = outerRecord[outerCount].obj.data.get('noRenewComment');
              String noRenewComment = null;
              if(noRenewCommentObj != null)
                   noRenewComment = outerRecord[outerCount].obj.data.get('noRenewComment').valueToString(); 
              if(noRenewComment != null && noRenewComment != ''){
                  noRenewComment = noRenewComment.replace('"' , '');
                  rt.No_Renew_Reason__c = noRenewComment;
              }
              
              UTL_JSONObject.value cloningActionObj = outerRecord[outerCount].obj.data.get('cloning_action');
              String cloningAction = null;
              if(cloningActionObj != null)
                cloningAction = outerRecord[outerCount].obj.data.get('cloning_action').valueToString();
              cloningAction = cloningAction.replace('"' , '');

              Boolean isNoRenewCase = false;
              if(cloningAction != null && cloningAction != '') {
                  if(cloningAction == '1') {
                      rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_RENEW_STR;
                      rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.NO_RENEW_STATUS_STR ;//'No Renew';
                  }
                  else if (cloningAction == '2') {
                      rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_CHANGE_STR;
                      rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR;//'queued';
                  }
                  else if (cloningAction == '3') {
                      rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR;
                      rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR;//'Awaiting Details';
                  }
              }
              
              renewalTasksForClone.add(rt);
          }
                  
          UTL_JSONObject.value[] innerRecords = outerRecord[outerCount].obj.data.get('innerRecords').values;
       	  system.debug('******* innerRecords - ' + innerRecords);
          for(Integer innerCount = 0;  innerCount<innerRecords.size(); innerCount++)
          { 
            //get opportunity line item id of product
            String OLI_Id = innerRecords[innerCount].obj.data.get('id').valueToString();
            if(OLI_Id != null && OLI_Id != '') {
                OLI_Id = OLI_Id.replace('"', '');
            }
            
            //check if the line item id has already a record in Renewal_Task_Change_Detail__c object
            Renewal_Task_Change_Detail__c changeDetail = OliIdRtChangeDetailMap.get(OLI_Id);            
            
            //get dropped reason comment for this product
            UTL_JSONObject.value droppedReason = innerRecords[innerCount].obj.data.get('comment');//.valueToString();
            //if changeDetail found modify its fields
            //if not found add a new record in the list
            if(changeDetail == null){
                changeDetail = new Renewal_Task_Change_Detail__c();
                changeDetail.Opportunity_Line_Item_Id__c = OLI_Id;
                changeDetail.Renewal_Task__c = rt.id; 
                changeDetail.CurrencyIsoCode = rt.CurrencyIsoCode ;                 
            }
            
            if (droppedReason != null && droppedReason.valueToString() != ''){
                    String droppedReasonStr = droppedReason.valueToString();
                    droppedReasonStr = droppedReasonStr.replace('"', '');
                    changeDetail.Dropped_Reason__c = droppedReasonStr;
             }
            //add it to changeDetailsForClone
            changeDetailsForClone.add(changeDetail);
          } 
          system.debug('******* changeDetailsForClone ' + changeDetailsForClone);       
        }
    }


    public void cloneRenwalTasks(){
        ParseJsonForCloning(jsonForCloning);
    }    
    
    public PageReference processCloning(){ 
        if(renewalTasksForClone != null && changeDetailsForClone !=null){
            ///////////////////////////////////////////////////////////////
            //requery - it may be a simple page refresh
            queryRenewalTaskList();
            //Map of renewal task id and rennewalTask
            Map<String, Renewal_Task__c> rtIdRTMap = new Map<String, Renewal_Task__c> ();
    
            for(Renewal_Task__c renewaltsak :listOfRenewal_Task) {   
                 rtIdRTMap.put('' + renewaltsak.id , renewaltsak );          
            }
    
            //background cloning process may change cloning status so ,
            //remove tasks that have already been cloned.
            List<Renewal_Task__c> filtrdRenewalTasksForClone = new List<Renewal_Task__c> ();
            for(Renewal_Task__c rtForClone : renewalTasksForClone) {
                Renewal_Task__c requeryRT = rtIdRTMap.get(rtForClone.id);
                //Boolean isProcessed = false;
                //Boolean removeFromList = false;
                Boolean alreadySubmitted = false;
                if(requeryRT != null) {
                    /*
                    //isProcessed = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR || requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.ERROR_STATUS_STR) ;
                    isProcessed = ( (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR &&
                                     requeryRT.Cloned_Opportunity__c != null && 
                                     requeryRT.Cloned_Opportunity__r.StageName != CON_CRM_OpportunityRenewals.OPP_STAGE_6B )
                                     || requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.ERROR_STATUS_STR) ;
                    System.debug('remove from list = '+ (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR));
                    removeFromList = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR && requeryRT.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR);
                    alreadySubmitted = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR);                 
                    */
                    alreadySubmitted = ( requeryRT.Cloning_Status__c !=null &&  requeryRT.Cloning_Status__c.trim() != '' );
                    if(requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR && requeryRT.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B)
                        alreadySubmitted = false;
                    
                }
                /*
                if ( (!alreadySubmitted) && ((!isProcessed) || (!removeFromList))) {
                        filtrdRenewalTasksForClone.add(rtForClone);
                 }*/
                 if (!alreadySubmitted) {
                        filtrdRenewalTasksForClone.add(rtForClone);
                 }
            }
    
            //background cloning process may change cloning status so ,
            //remove change details of tasks that have already been cloned.
            List<Renewal_Task_Change_Detail__c> rChangeDetailsForClone = new List<Renewal_Task_Change_Detail__c> ();
            for(Renewal_Task_Change_Detail__c rtdForClone : changeDetailsForClone) {
                Renewal_Task__c requeryRT = rtIdRTMap.get(rtdForClone.Renewal_Task__c);
                //Boolean isProcessed = false;
                //Boolean removeFromList = false;
                Boolean alreadySubmitted = false;
                if(requeryRT != null) {
                    /*
                    //isProcessed = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR || requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.ERROR_STATUS_STR) ;
                    isProcessed = ( (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR &&
                                     requeryRT.Cloned_Opportunity__c != null && 
                                     requeryRT.Cloned_Opportunity__r.StageName != CON_CRM_OpportunityRenewals.OPP_STAGE_6B )
                                     || requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.ERROR_STATUS_STR) ;
                    removeFromList = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR && requeryRT.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR) ;
                    alreadySubmitted = (requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR);                 
                    */
                    alreadySubmitted = ( requeryRT.Cloning_Status__c !=null &&  requeryRT.Cloning_Status__c.trim() != '' );
                    if(requeryRT.Cloning_Status__c == CON_CRM_OpportunityRenewals.CLONED_STATUS_STR && requeryRT.Cloned_Opportunity__r.StageName == CON_CRM_OpportunityRenewals.OPP_STAGE_6B)
                        alreadySubmitted = false;
                    
                }
                /*
                if ( (!alreadySubmitted) && ((!isProcessed) || (!removeFromList))) {
                        rChangeDetailsForClone.add(rtdForClone);
                }*/
                if (!alreadySubmitted) {
                        rChangeDetailsForClone.add(rtdForClone);
                 }
            }
            ///////////////////////////////////////////////////////////////////////
            rChangeDetailsForClone = initTaskDetails(rChangeDetailsForClone);
            if( rChangeDetailsForClone.size() > 0 ) {          
              SavePoint sp = Database.setSavePoint();
              try {            
                   System.debug(LoggingLevel.INFO, 'Selected change details records are:' + rChangeDetailsForClone);
                   upsert rChangeDetailsForClone;
                   } catch (Exception ex){
                   //roll back the transcation
                   database.rollback(sp);
                   System.debug(LoggingLevel.ERROR, 'Server error while processing renewal tasks : ' + ex);           
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.');                        
                   //add error on page
                   ApexPages.addMessage(errMsg );
              }
        }
            Integer noRenewSize = 0;
            Integer basicCloneSize = 0;
            Integer detailCloneSize = 0;
            for(Renewal_Task__c rt : renewalTasksForClone){
                
                if(rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.NO_RENEW_STR) {
                    noRenewSize += 1;
                }
                else if (rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.NO_CHANGE_STR) {
                    basicCloneSize += 1;
                }
                else if (rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR) {
                    detailCloneSize += 1;
                }
            }
    
            //if task list is non zero, update
            /////////////////////////////
            if( filtrdRenewalTasksForClone.size() > 0 ) {
              SavePoint sp = Database.setSavePoint();
              try
              {            
                   System.debug(LoggingLevel.INFO, 'Selected Renewal Tasks records are:' + renewalTasksForClone);
                   update filtrdRenewalTasksForClone;
                   if(isSynchronousClone){
                       EXT_CRM_OpportunityRenewals_NoChange oppCloner = new EXT_CRM_OpportunityRenewals_NoChange();
                       oppCloner.CloneOpportunities_For_Renewal_With_NoChange(renewalTasksForClone);//*/
                   }
                   ApexPages.Message myMsg ;
                   ApexPages.Message myMsg1 ;
                   ApexPages.Message myMsg2 ;
                   if(noRenewSize > 0 ) {
                      myMsg = new ApexPages.Message(ApexPages.Severity.INFO,  noRenewSize + ' opportunities submitted for no renewal.'  );
                      ApexPages.addMessage(myMsg);
                   }
                   if(basicCloneSize > 0 ) {
                      myMsg1 = new ApexPages.Message(ApexPages.Severity.INFO,  basicCloneSize + ' opportunities submitted for basic clone.'  );
                      ApexPages.addMessage(myMsg1);
                   }
                   if(detailCloneSize > 0 ) {
                      myMsg2 = new ApexPages.Message(ApexPages.Severity.INFO,  detailCloneSize + ' opportunities submitted for detail clone.'  );
                      ApexPages.addMessage(myMsg2);
                   }
               } catch (Exception ex){
                   //roll back the transcation
                   database.rollback(sp);
                   System.debug(LoggingLevel.ERROR, 'Server error while processing renewal tasks : ' + ex);           
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.' + ex);                        
                   //add error on page
                   ApexPages.addMessage(errMsg );
                  }
               }
           }
           GenerateRenewalTaskJson();
           return null;
    } 
     
     /********** Reassign Functionality **************/
     Public String reassignUserId{get;set;}
     Public String reassignRecIdList {get; set;}
     
     public PageReference reassign(){
     
          //TODO: remove debugging only
          //ApexPages.Message myDebugMsg = new ApexPages.Message(ApexPages.Severity.INFO,'reassignUserId = ' + reassignUserId + ' reassignRecIdList = ' + reassignRecIdList  );
          //ApexPages.addMessage(myDebugMsg );
          //TODO: remove debugging only
          queryRenewalTaskList();
          //check the supplied user id for reassignee
          if(reassignUserId == null || reassignUserId == '') {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select a user for reassignment.' );
              ApexPages.addMessage(myMsg);
              return null;
          }
          
          //check the selected records for reassignment
          if( reassignRecIdList == null || reassignRecIdList == '' ) {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select at least one task for reassignment.' );
              ApexPages.addMessage(myMsg);
              return null;
          }
           
           Map<Id, User> usersMap;
           Set<Id> usedUsers = new Set<Id>();
           for( Renewal_Task__c renewal_task : listOfRenewal_Task){
            usedUsers.add(renewal_task.ownerId);
            usedUsers.add(reassignUserId);  
           }    
           
           if( listOfRenewal_Task.size() > 0) {
                usersMap = new Map<Id, User>([select id, name from User where id in : usedUsers]);          
           }

          List<Renewal_Task__c> selectedTasks = new List<Renewal_Task__c>();
          String msg = '';
          //listOfRenewal_Task;
          for( Renewal_Task__c renewal_task : listOfRenewal_Task){
              if(reassignRecIdList.contains(renewal_task.id)) {
                  msg += '<br/>Opportunity Number : ' + renewal_task.Opportunity__r.Opportunity_Number__c + '&nbsp;&nbsp;&nbsp;&nbsp;Previous User : ' + usersMap.get(renewal_task.ownerId).name + '&nbsp;&nbsp;&nbsp;&nbsp;New User : ' + usersMap.get(reassignUserId).name;
                  renewal_task.ownerId = reassignUserId ;
                  selectedTasks.add(renewal_task);
              }
          }
          if( selectedTasks.size() > 0 ) {
              SavePoint sp = Database.setSavePoint();
              try
              {            
                   System.debug(LoggingLevel.INFO, 'Selected Renewal Tasks records are:' + selectedTasks);
                   update selectedTasks;
                   msg = selectedTasks.size() + ' records have been reassigned.' + msg;
                    
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,  msg);
                   ApexPages.addMessage(myMsg);
               } catch (Exception ex){
                   //roll back the transcation
                   database.rollback(sp);
                   System.debug(LoggingLevel.ERROR, 'Server error while processing renewal tasks : ' + ex);           
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.');                        
                   //add error on page
                   ApexPages.addMessage(errMsg );
                  }
               }
          
         reassignUserId = '';
         GenerateRenewalTaskJson();
         return null;
         
     }
     
     /********** Reassign Functionality **************/
     
    public void searchRenwalTasks(){
        additionalFilter = ' ';
        if(this.sOppNumber != null && this.sOppNumber != '')
            additionalFilter += 'AND Opportunity__r.Opportunity_Number__c like \'%'+ this.sOppNumber + '%\' ';
        if(this.sOppName != null && this.sOppName !='')
            additionalFilter += 'AND Opportunity__r.Name like \'%'+ this.sOppName + '%\' ';
        if(this.sAccName != null && this.sAccName !='')
            additionalFilter += 'AND Opportunity__r.Account.Name like \'%'+ this.sAccName + '%\' ';
        if(this.sPOppName != null && this.sPOppName != '')
            additionalFilter += 'AND Opportunity__r.Parent_Opportunity__r.Name  like \'%'+ this.sPOppName + '%\' ';
        if(this.sPOppNumber != null && this.sPOppNumber != '')
            additionalFilter += 'AND Opportunity__r.Parent_Opportunity__r.Opportunity_Number__c  like \'%'+ this.sPOppNumber + '%\' ';

        System.debug('test additionalFilter: '+additionalFilter);
        GenerateRenewalTaskJson();
    }
    
    public void deactiveRenewalTask(){
        List<Renewal_Task__c> renewalTaskToDeactiveList = new List<Renewal_Task__c>();
        List<String> convertedData = (List<String>)JSON.deserialize(this.renewalTaskToDeactivate,List<String>.Class);
        for(String strId :convertedData){
            renewalTaskToDeactiveList.add(new Renewal_Task__c(Id=strId, Is_Removed__c = true));
        }
        update renewalTaskToDeactiveList;
        GenerateRenewalTaskJson();
    }
}