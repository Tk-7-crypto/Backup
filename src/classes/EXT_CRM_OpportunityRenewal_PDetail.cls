public class EXT_CRM_OpportunityRenewal_PDetail {
    public final Renewal_Task__c rt;
    
    public Opportunity opp{get;set;}    
    
    public List<RenewalTaskDetailWrapper> rtdWrappperList{get; set;}
    
    //flag for closing the pop up on successfule saving of details
    public Boolean isSaveSuccessful {get; set;}
    
    //flag for closing the pop up on click of cancel button
    //public Boolean isCancelClicked {get; set;}
    
    public String INA_BUSINESS_TYPE {get;set;}
    public EXT_CRM_OpportunityRenewal_PDetail(ApexPages.StandardController stdController) {
        
        rt = [Select Id, Price_Increase__c,
                                    Cloning_Action__c,
                                    Cloning_Status__c,
                                    Cloned_Opportunity__c,
                                    Cloned_Opportunity__r.name,
                                    Targeted_Close_Date__c,
                                    ownerId,
                                    No_Renew_Reason__c,
                                    Opportunity__c, Opportunity__r.id,
                                    Opportunity__r.StageName,
                                    CurrencyIsoCode,
                                    (Select Id, Renewal_Task__c,
                                            Territory__c, 
                                            Data_Month_Start__c,
                                            Proj_Rpt_Frequency__c,
                                            ProductCode__c,
                                            Product_Name__c,
                                            Output_Format__c,
                                            Data_Month_End__c,
                                            Revenue_Type__c,
                                            Winback__c,
                                            Delivery_Media__c,
                                            TotalPrice__c,
                                            Expect_Round_up_Total_Price__c,
                                            Sale_Type__c,
                                            Opportunity_Line_Item_Id__c From Renewal_Task_Change_Details__r where Dropped_Reason__c = '' )
                                    from Renewal_Task__c 
                                    where id = :ApexPages.CurrentPage().getParameters().get('id')];
        //rt = (Renewal_Task__c)stdController.getRecord();
        opp = rt.Opportunity__r;
        
        Set<Id> rtdIdSet = new Set<Id> ();                            
        for(Renewal_Task_Change_Detail__c rtd : rt.Renewal_Task_Change_Details__r)  {
            rtdIdSet.add(rtd.Opportunity_Line_Item_Id__c);
        }    
        System.debug('rtdIdSet = ' + rtdIdSet);
        //Update By Himanshu : PricebookEntry.Product2.Material_Type__c added for render : 22 Oct 2013
        Map<Id, OpportunityLineItem> oppLineItemIdMap = new Map<Id, OpportunityLineItem>([
                                                            select id, Business_Type__c,
                                                            Product_Invoice_Text__c,
                                                            PricebookEntry.Product2.Name, 
                                                            PricebookEntry.Product2.ProductCode, 
                                                            Sales_Text__c,                                                          
                                                            Output_Format__c,
                                                            Configured_Product__c,
                                                            Billing_Frequency__c,
                                                            Sale_Type__c, Winback__c,
                                                            Revenue_Type__c,Delivery_Country__c,
                                                            Delivery_Media__c, Proj_Rpt_Frequency__c,
                                                            PricebookEntry.ProductCode,PricebookEntry.Product2.Material_Type__c
                                                            from OpportunityLineItem where id in :rtdIdSet ]);                              
        rtdWrappperList = new List<RenewalTaskDetailWrapper > ();
        System.debug('oppLineItemIdMap = ' + oppLineItemIdMap );
        
        for(Renewal_Task_Change_Detail__c rtd : rt.Renewal_Task_Change_Details__r)  {
            OpportunityLineItem Li = oppLineItemIdMap.get(rtd.Opportunity_Line_Item_Id__c);             
            System.debug('*****************SAP CODE = ' + rtd.ProductCode__c);
            rtdWrappperList.add(new RenewalTaskDetailWrapper(rtd, Li));
        }
        ///////////sorting the list to overcome rendering bug ////////////////
        List<RenewalTaskDetailWrapper > iaList = new List<RenewalTaskDetailWrapper >();
        List<RenewalTaskDetailWrapper > csList = new List<RenewalTaskDetailWrapper > ();
        for(RenewalTaskDetailWrapper w : rtdWrappperList) {
            //if(w.OLI.Business_Type__c.equalsIgnoreCase('I&A')){
            //if(w != null && w.OLI != null && w.OLI.Business_Type__c != null && ('I&A').equalsIgnoreCase(w.OLI.Business_Type__c)){
            if(w != null && w.OLI != null && w.OLI.PricebookEntry.Product2.Material_Type__c != null && w.OLI.PricebookEntry.Product2.Material_Type__c=='ZPUB'){
                iaList.add(w);
            } else {
                csList.add(w);
            }
        }
        rtdWrappperList.clear();
        rtdWrappperList.addAll(iaList);
        rtdWrappperList.addAll(csList);
        ///////////sorting the list to overcome rendering bug ////////////////
        isSaveSuccessful = false;
        INA_BUSINESS_TYPE = 'I&A';
        //setOLIListOptions();
    }
    
    public PageReference saveProducts() {
        List<Renewal_Task_Change_Detail__c> rtList = new List<Renewal_Task_Change_Detail__c> ();
        Map<Id, Renewal_Task_Change_Detail__c> rtMap = new Map<Id, Renewal_Task_Change_Detail__c>();
        for(RenewalTaskDetailWrapper rtdw : rtdWrappperList) {
            if(rtdw.OLI.Delivery_Country__c!=null){
                rtdw.rtd.Territory__c = rtdw.OLI.Delivery_Country__c;
            }
            if(rtdw.OLI.Proj_Rpt_Frequency__c!=null){
                rtdw.rtd.Proj_Rpt_Frequency__c = rtdw.OLI.Proj_Rpt_Frequency__c;
            }
            if(rtdw.OLI.Revenue_Type__c!=null){
                rtdw.rtd.Revenue_Type__c = rtdw.OLI.Revenue_Type__c;
            }
            if(rtdw.OLI.Winback__c!=null){
			    if(rtdw.OLI.Winback__c == false)
                    rtdw.rtd.Winback__c = 'No';
				else
				    rtdw.rtd.Winback__c = 'Yes';
            }
            if(rtdw.OLI.Delivery_Media__c!=null){
                rtdw.rtd.Delivery_Media__c = rtdw.OLI.Delivery_Media__c;
            }
            if(rtdw.OLI.Output_Format__c!=null){
                rtdw.rtd.Output_Format__c = rtdw.OLI.Output_Format__c;
            }
            rtdw.rtd.Product_Invoice_Text__c = rtdw.OLI.Sales_Text__c != null ? rtdw.OLI.Sales_Text__c : rtdw.OLI.Product_Invoice_Text__c;

            /*
            if(rtdw.rtd.Output_Format__c!=null && rtdw.rtd.Output_Format__c!='null'){
                String outputValue = rtdw.rtd.Output_Format__c;
                outputValue = outputValue.substring(1, outputValue.length()-1);
                outputValue = outputValue.replaceAll(',', ';');   
                rtdw.rtd.Output_Format__c = outputValue;
                System.debug('renewal task change detail Id = '+ rtdw.rtd.id +' Output Value = '+rtdw.rtd.Output_Format__c);
            }*/
            rtList.add(rtdw.rtd );
            rtMap.put(rtdw.rtd.id, rtdw.rtd);
        }
        if(rtList.size() == 0){
            SavePoint sp = Database.setSavePoint();
            try{
                isSaveSuccessful = true;
                rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR ;//'queued';
                update rt;
            }catch(Exception ex){
                //roll back the transcation
               database.rollback(sp);
               ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.' + ex.getMessage());                        
               //add error on page
               ApexPages.addMessage(errMsg );
            }
        } else {
              SavePoint sp = Database.setSavePoint();
              try
              {            
                   System.debug(LoggingLevel.INFO, 'Selected Renewal Tasks records are:' + rtList );
                   update rtList ;
                   //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,  rtList.size() + ' product details have been saved.'  );
                   //ApexPages.addMessage(myMsg);
                   isSaveSuccessful = true;
                   rt.Cloning_Status__c = CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR ;//'queued';
                   update rt;
               }catch(DmlException ex){
                    String msg = '';
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        msg += '<br/>';
                        if(ex.getDmlStatusCode(i) == 'FIELD_CUSTOM_VALIDATION_EXCEPTION')
                            msg += 'Validation Error : ';
                        msg += ex.getDmlMessage(i) + ' For Product : ' + rtMap.get(ex.getDmlId(i)).ProductCode__c;

                    }
                    //add error on page
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);                        
                   ApexPages.addMessage(errMsg);
               }catch (Exception ex){
                   //roll back the transcation
                   database.rollback(sp);
                   System.debug(LoggingLevel.ERROR, 'Server error while saving product details : ' + ex.getMessage());           
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.' + ex.getMessage());                        
                   //add error on page
                   ApexPages.addMessage(errMsg );
                  }
        }
        return null;
    }
    
    /*
    //initailizing picklist values on the page for Delivery Country
    public List<SelectOption> territoryOptions {get;private set;}
    
    //Delivery/Rpt Frequency Proj_Rpt_Frequency__c
    public List<SelectOption> delRptOptions {get;private set;}
    
    //Revenue Type Revenue_Type__c
    public List<SelectOption> revTypeOptions {get;private set;}
    
    //Winback Winback__c
    public List<SelectOption> winbackOptions {get;private set;}
    
    //Delivery Media Delivery_Media__c
    public List<SelectOption> delMediaOptions {get;private set;}
    
    //Output Format Output_Format__c
    public List<SelectOption> opFormatOptions {get;private set;}
    
    public void setOLIListOptions() {        
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType systemObjectType = gd.get('OpportunityLineItem');
        Schema.DescribeSObjectResult r = systemObjectType.getDescribe();
        Map<String,Schema.SObjectField> M = r.fields.getMap();
        
        territoryOptions = setDescOptList(M, 'Delivery_Country__c', territoryOptions);            
        
        delRptOptions = setDescOptList(M, 'Proj_Rpt_Frequency__c', delRptOptions);
        
        revTypeOptions = setDescOptList(M, 'Revenue_Type__c', revTypeOptions);
        
        delMediaOptions  = setDescOptList(M, 'Delivery_Media__c', delMediaOptions );
        
        winbackOptions = setDescOptList(M, 'Winback__c', winbackOptions);
        
        opFormatOptions = setDescOptList(M, 'Output_Format__c', opFormatOptions);
           
    }
    
    private List<SelectOption> setDescOptList(Map<String,Schema.SObjectField>M, String reqdFieldName, List<SelectOption> selOptLst ){
        selOptLst = new List<SelectOption>();
        selOptLst.add(new SelectOption('','-None-') );
        Schema.SObjectField field4 = M.get(reqdFieldName);//'Delivery_Media__c');                                                    
        Schema.DescribeFieldResult fieldDesc4 = field4.getDescribe();
        List<Schema.PicklistEntry> plEn4 = fieldDesc4.getPickListValues();
        for(Schema.PicklistEntry e4 : plEn4) {
            selOptLst.add(new SelectOption(e4.getValue(),e4.getValue()) );
        }
        return selOptLst ;
    }
    */

    public class RenewalTaskDetailWrapper {
        public Renewal_Task_Change_Detail__c rtd {get;set;}
        public OpportunityLineItem OLI {get;set;}
        public Boolean isShown{get;set;}
        
        public RenewalTaskDetailWrapper(Renewal_Task_Change_Detail__c rtd1, OpportunityLineItem OLI1) {
            rtd = rtd1; OLI = OLI1;
            isShown = false;
            /*if(OLI.Business_Type__c.equalsIgnoreCase('I&A')){
                isShown = true;
            }//*/
        }    
    }
 
}