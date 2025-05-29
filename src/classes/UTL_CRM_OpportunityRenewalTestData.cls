public class UTL_CRM_OpportunityRenewalTestData {
        public static final Integer PROD_SIZE = 5;
        public static List<Opportunity> setupOpportunity(Account NewAccount, Integer numOpportunities){
            List<Opportunity> oppList = new List<Opportunity> ();
            for(Integer i = 0 ; i < numOpportunities; i++ ){        
                //Create a controller to get all the options
                Opportunity NewOpportunity = new Opportunity (Name='Test Opp' + i);
                NewOpportunity.StageName = '2 - Verify Opportunity';
                NewOpportunity.CloseDate = System.today();
                NewOpportunity.Budget_Available__c = 'Yes';
                NewOpportunity.CurrencyIsoCode = 'USD';
                //NewOpportunity.Region__c = 'EMEA';
                oppList.add(NewOpportunity);
            }
            insert oppList;  
            
            //  Add a line item to the opportunity
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            List<PricebookEntry> PEList = new List<PricebookEntry>(); //= [select Id, ProductCode, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true limit :PROD_SIZE];
            String standardPricebookId =Test.getStandardPricebookId();
            Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
            prod.Business_Type__c = 'I&A';
            prod.CanUseRevenueSchedule=true;
            prod.ProductCode = '123';
            insert prod;
            
            PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
            PE1.IsActive = true;
            PE1.CurrencyIsoCode = 'USD';
            insert PE1;
            PEList.add(PE1);
            
            //System.debug('PEList : '+PEList);
            String revenueType;
            String territoryCntry;
            String winback;
            String deliveryMedia;
            String ptojRptFreq;
            String outputFormat;
            
            List <Schema.PicklistEntry> pickListEntList;

            pickListEntList = OpportunityLineItem.Revenue_Type__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                revenueType = pickListEntList[0].getValue();
            
            pickListEntList = OpportunityLineItem.Delivery_Country__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                territoryCntry = pickListEntList[0].getValue();

            pickListEntList = OpportunityLineItem.Winback__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                winback = pickListEntList[0].getValue();

            pickListEntList = OpportunityLineItem.Delivery_Media__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                deliveryMedia = pickListEntList[0].getValue();

            pickListEntList = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                ptojRptFreq = pickListEntList[0].getValue();

            pickListEntList = OpportunityLineItem.Output_Format__c.getDescribe().getPicklistValues();
            if(pickListEntList.size() >0)
                outputFormat = pickListEntList[0].getValue();
            
            for(Opportunity opp : oppList) {
                for(PricebookEntry PE : PEList){
                    OpportunityLineItem add1_oli = new OpportunityLineItem();
                    add1_oli.OpportunityId = opp.Id;
                    add1_oli.Product_Start_Date__c = Date.today();
                    add1_oli.Product_End_Date__c = Date.today().addDays(1) ;
                    add1_oli.PricebookEntryId = PE.Id;
                    add1_oli.Quantity = 1.00;
                    add1_oli.UnitPrice = 10000;
                    add1_oli.Sale_Type__c = 'New';
                    add1_oli.Revenue_Type__c = revenueType;
                    add1_oli.Delivery_Country__c = territoryCntry;
                    if(winback == 'No')
                        add1_oli.Winback__c = false;
                    else
                        add1_oli.Winback__c = true;
                    add1_oli.Delivery_Media__c = deliveryMedia;
                    add1_oli.Proj_Rpt_Frequency__c = ptojRptFreq;
                    add1_oli.Output_Format__c = outputFormat;
                    
                    oliList.add(add1_oli);
                }
            }
            insert oliList; 
            
            System.debug('oliList = ' + oliList);
            
            List<OpportunityLineItemSchedule> OLIS_Insert_List = new List<OpportunityLineItemSchedule>();        
            //  Create 18 schedules for each opportunity line item
            
            for(OpportunityLineItem oli : oliList) {
                Double dRevenueAmount = 1000.00;
                Datetime strDate = System.now();
                Date strScheduleDate = Date.valueOf(String.valueOf(strDate.year())+'-01-15 00:00:00');
                Integer iNumSchedules = 18;  
                
                for (Integer i = 0; i < iNumSchedules; i++) 
                {
                    OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
                    OliSched.OpportunityLineItemId = oli.Id;
                    OliSched.Type = 'Revenue';
                    OliSched.Revenue = dRevenueAmount;
                    OliSched.ScheduleDate = strScheduleDate;
                    strScheduleDate = strScheduleDate.addMonths(1);
                    OLIS_Insert_List.add(OliSched); 
                }
            }
            insert OLIS_Insert_List;
                  
            /*OpportunityContactRole NewOcr = new OpportunityContactRole();
            NewOcr.OpportunityId = NewOpportunity.Id;
            NewOcr.ContactId = NewContact.Id;
            NewOcr.Role = OcrRole;
            insert NewOcr;//*/
            
            return oppList;
    }
    
    public static Product2 getProdRecord(){
        Product2 product = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',IsActive = true,Family = 'Test Family', ProductCode = '122');
        return product;
    }    
    
    public static PricebookEntry getPbEntryRecord(Product2 products){
        String standardPricebookId =Test.getStandardPricebookId();        
        PricebookEntry pbe = new PricebookEntry (Product2ID=products.id,Pricebook2ID= standardPricebookId,IsActive = true,UnitPrice=50);
        return pbe;
    }

    public static Account setupAccount(String accName) {
        Account NewAccount = new Account();
        NewAccount.Name = accName;
        NewAccount.CustomerSegment__c = 'GOVERNMENT';
        NewAccount.Sub_Industry__c = 'STATE';
        insert NewAccount;
        return NewAccount;
    }

    public static List<Renewal_Task__c> setupRenewalTasks(Account NewAccount, Integer BATCH_SIZE) {
       
        List<Opportunity> oppList = UTL_CRM_OpportunityRenewalTestData.setupOpportunity(NewAccount, BATCH_SIZE);
        
        Integer oppListSize = oppList.size();
        System.debug('oppList.size() = ' + oppList.size());
        //create a list of renewal tasks - limit is 200 for test case
        List<Renewal_Task__c> rtList = new List<Renewal_Task__c> ();
        Set<Id> oppIdSet = new Set<Id>();
        for(Integer i = 0; i < BATCH_SIZE ; i++ ) {
            Renewal_Task__c rt = new Renewal_Task__c();
            rt.CurrencyIsoCode = 'USD';
            rt.Price_Increase__c = 5;
            rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_CHANGE_STR ; 
            rt.Cloning_Status__c = '' ; 
            rt.ownerId = userInfo.getUserId();
            rt.Owner_Country__c = [select id, User_Country__c from User where id =: userInfo.getUserId() limit 1].User_Country__c;
            rt.Targeted_Close_Date__c = System.today();
            rt.Opportunity__c = oppList[i].id;
            oppIdSet.add(oppList[i].id);
            rtList.add(rt);         
        }
        insert rtList;
        System.debug('*****rtList = ' + rtList);
        //create a list of renewal task change details                
        List<Renewal_Task_Change_Detail__c> cDetailList = new List<Renewal_Task_Change_Detail__c>();
        //System.debug('oppIdSet : '+oppIdSet);
        List<OpportunityLineItem> olList = [Select Id,PriceBookEntry.ProductCode, OpportunityId  from OpportunityLineItem where OpportunityId in : oppIdSet];
        //System.debug('olList : '+olList);
        Map<Id, List<OpportunityLineItem>> oppIdOppLiMap = new Map<Id, List<OpportunityLineItem>> ();
        for(OpportunityLineItem oli : olList){
            List<OpportunityLineItem> mList = oppIdOppLiMap.get(oli.OpportunityId);
            if(mList == null ) {
                mList = new List<OpportunityLineItem> ();
                oppIdOppLiMap.put(oli.OpportunityId, mList);
            }
            
            mList.add(oli);
        }
        
        for(Integer i = 0; i < BATCH_SIZE; i++ ) {
            //Renewal_Task_Change_Detail__c cd = new Renewal_Task_Change_Detail__c();
            List<OpportunityLineItem> oppOlList = oppIdOppLiMap.get(rtList[i].Opportunity__c);
            
            for(OpportunityLineItem oppLi : oppOlList){
                Renewal_Task_Change_Detail__c cd = new Renewal_Task_Change_Detail__c();
                cd.Opportunity_Line_Item_Id__c = oppLi.id;
                cd.ProductCode__c = oppLi.PricebookEntry.ProductCode;
                cd.Renewal_Task__c = rtList[i].id;
                cDetailList.add(cd);
            }
        }
        insert cDetailList;
        return rtList ;
    }

}