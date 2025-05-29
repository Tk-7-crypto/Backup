trigger MIBNF_Component_CheckBNFSubmit on MIBNF_Component__c (before insert, before update)
{ 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Map<Id,Id> OpportunityId_Map = new Map<Id,Id>();
        Map<Id,Id> MI_BNF_LineItem_Map = New Map<Id,Id>(); 
        //  Map<Id,List<MI_BNF_LineItem__c>> MI_BNF_LI_Array_Map = new Map<Id,List<MI_BNF_LineItem__c>>();   
        Map<Id,List<OpportunityLineItem>> OLI_Array_Map = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,OpportunityLineItem> OLI_Map = new Map<Id,OpportunityLineItem>();
        Set<Id> BillToAddressId = new Set<Id>();
        Map<Id,Address__c> BillToAddressMap = new Map<Id,Address__c>();
        Map<Id,Boolean> MarkedForDeletionAddress_Map = new Map<Id,Boolean>();
        
        //Added by himanshu parashar :13 Feb 2013 : for sending mail
        List<Messaging.SingleEmailMessage> emailsToSend= new List<Messaging.SingleEmailMessage>();
        //Added by Himanshu Parashar Date : 13 Feb 2013
        BNF_Settings__c bnfSetting=BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        Boolean isNewBnf = false;
        String opportunityNumber = null;    
        //Added By Himanshu Parashar : MIS Issue-02000 : Update lineitem if no therapy_area specified 
        List<OpportunityLineItem> UpdateOLIlst=new List<OpportunityLineItem>();
        Boolean UpdateRequired = false;
        
        Set<Id> AddressId_Set = new Set<Id>();
        Map<String,String> Address_Map = new Map<String,String>();
        
        // Added by Ritesh gupta - ER-3208
        Boolean isBNFSAPConfirmed = false; 
        Set<Id> revAnalystIdsSet = new Set<Id>();
        for(MIBNF_Component__c BNF:Trigger.new){
            revAnalystIdsSet.add(BNF.Comp_Revenue_Analyst__c);
        }
        Map<Id, Revenue_Analyst__c> revAnalystRecordsMap = new SLT_RevenueAnalyst().selectByRevAnalystId(revAnalystIdsSet, new Set<String>{'OwnerId','Owner.Type', 'Disable_RA__c'});
        
        for (MIBNF_Component__c BNF:Trigger.new)
        {
            OpportunityId_Map.put(BNF.Opportunity_Id__c,BNF.Opportunity_Id__c);
            system.debug('Opp ID: ' + BNF.Opportunity_Id__c);
            // Added by Ritesh gupta - ER-3208
            if(BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') ){
                isBNFSAPConfirmed = true;
            }
            if(BNF.Bill_To__c != null && (Trigger.isInsert || (Trigger.isUpdate && BNF.Bill_To__c !=Trigger.OldMap.get(BNF.Id).Bill_To__c) )){
                BillToAddressId.add(BNF.Bill_To__c);
            } else if(BNF.Bill_To__c == null && Trigger.isUpdate && BNF.Bill_To__c != Trigger.oldMap.get(BNF.Id).Bill_To__c) {
                BNF.Is_PO_Required__c = false;
            }
            //Added by himanshu parashar : 12 dec 2012 : send mail to user on submitting BNF if BNF sales_org is not present in Address Sales_org
            //Added by himanshu parashar : 12 dec 2012 : send mail to user on submitting BNF if BNF sales_org is not present in Address Sales_org
            if (bnfSetting.Enable_Customer_Validation__c==true && Trigger.isUpdate && BNF.BNF_Status__c == 'Submitted' && Trigger.oldMap.get(BNF.Id).BNF_Status__c != 'Submitted')
            {
                AddressId_Set.add(BNF.Bill_To__c);
                AddressId_Set.add(BNF.Ship_To__c);
                AddressId_Set.add(BNF.Cover_Sheet__c);
                AddressId_Set.add(BNF.X2nd_Copy__c);
                AddressId_Set.add(BNF.Carbon_Copy__c);
                AddressId_Set.add(BNF.Sold_To__c);
                
                
                Address_Map.put(BNF.id + '_' + BNF.X2nd_Copy__c,'2nd Copy');
                Address_Map.put(BNF.id + '_' + BNF.Carbon_Copy__c,'Carbon Copy');
                Address_Map.put(BNF.id + '_' + BNF.Bill_To__c,'Bill To');
                Address_Map.put(BNF.id + '_' + BNF.Ship_To__c,'Ship To');
                Address_Map.put(BNF.id + '_' + BNF.Cover_Sheet__c,'Cover Sheet');
            }
        }
        //setEnabledPaymentTermsBillTo
        if(BillToAddressId.size() > 0){
            BillToAddressMap = new SLT_Address().selectByAddressId(BillToAddressId, new Set<String>{'Id', 'PO_Required__c','Enabled_Sales_Orgs_and_Payment_Terms__c'});
            for (MIBNF_Component__c BNF:Trigger.new){
                if(BNF.Bill_To__c != null && BillToAddressId.contains(BNF.Bill_To__c)){
                    // Process Is_PO_Required__c value for BNF from Address
                    BNF.Is_PO_Required__c = BillToAddressMap.get(BNF.Bill_To__c).PO_Required__c;
                    //Process EnabledPaymentTermsBillTo
                    String AddressSalesOrgsAndPaymentTerms = BillToAddressMap.get(BNF.Bill_To__c).Enabled_Sales_Orgs_and_Payment_Terms__c;
                    Map<String,String> salesOrgPaymentTermMap = new Map<String,String>();
                    if(AddressSalesOrgsAndPaymentTerms != null){
                        for(String supportedList : AddressSalesOrgsAndPaymentTerms.split(';')){
                            List<String> CodeTermPair = supportedList.split(':');
                            if(CodeTermPair.size() == 2)
                                salesOrgPaymentTermMap.put(CodeTermPair[0].trim(),CodeTermPair[1].trim());
                        }
                    }
                    BNF.Enabled_PaymentTerms_Bill_To__c = salesOrgPaymentTermMap.get(BNF.Sales_Org_Code__c);
                }
            }
        }
        Map<String,Boolean> OLIScheduleMapStartDate = new Map<String,Boolean>();
        Map<String,Boolean> OLIScheduleMapEndDate = new Map<String,Boolean>(); 
        Map<Id,MIBNF_Component__c> MIBNF_Opp_Id_Map = new Map<Id,MIBNF_Component__c>();
        for(MIBNF_Component__c b : Trigger.new)
        {
            MIBNF_Opp_Id_Map.put(b.Opportunity__c,b);
        }
        
        if (trigger.isUpdate)
        {
            LIST<AggregateResult> OLSSchedule_Array = [Select MIN(ScheduleDate) StartDate,Max(ScheduleDate) EndDate,
                                                       OpportunityLineItemId,OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c,OpportunityLineItem.Product_Start_Date__c,OpportunityLineItem.OpportunityId from OpportunityLineItemSchedule where Opportunitylineitem.opportunityid in : OpportunityId_Map.keySet() and OpportunityLineItem.PricebookEntry.Product2.Material_Type__c = 'ZREP'
                                                       group by OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c,OpportunityLineItemId,OpportunityLineItem.Product_Start_Date__c,OpportunityLineItem.OpportunityId];
            
            for(AggregateResult agg : OLSSchedule_Array)
            {
                //  If a revised BNF is being validated but no revised schedule has been specified, then the validation must be done against the original
                //  Opportunitylineitemschedules using the updated data period start
                Date StartDate = (MIBNF_Opp_Id_Map.get(String.valueof(agg.get('OpportunityId'))).Addendum__c ? Date.valueof(agg.get('Product_Start_Date__c')) : Date.valueof(agg.get('Project_Start_Date__c')));
                if(StartDate!=null && (Date.valueof(agg.get('StartDate')) < StartDate))            
                {          
                    OLIScheduleMapStartDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
                }
                if(agg.get('Project_End_Date__c')!=null && (Date.valueof(agg.get('EndDate')) > Date.valueof(agg.get('Project_End_Date__c'))))
                {           
                    OLIScheduleMapEndDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
                }
            }
        }
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Set<Id> lqOppIdSet = new Set<Id>();
        List<OpportunityLineItem> oliList1 = [select Id, UnitPrice,  Budget_Amount__c, PricebookEntry.Product2.Item_Category_Group__c,Budget_Therapy_Area__c,Billing_Schedule__c,Therapy_Area__c,OpportunityId ,PricebookEntry.Product2.Offering_Type__c,List_Price__c,Sale_Type__c,Billing_Frequency__c,Product_End_Date__c,Product_Start_Date__c,Proj_Rpt_Frequency__c,PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.ProductCode,Wbsrelementcode__c, Totalprice,PricebookEntry.Product2.Enabled_Sales_Orgs__c, PO_Number__c, Billing_Schedule__r.Total_Billing_Amount__c,Revised_Price__c,Revised_Revenue_Schedule__c, Project_Start_Date__c,  Project_End_Date__c, Discount_Amount_Formula__c,Other_Ship_To_Address__c, Other_Ship_To_Address__r.name, Other_Ship_To_Address__r.SAP_Reference__c, Other_Ship_To_Address__r.Enabled_Sales_Orgs__c , Product_Material_Type__c from OpportunityLineItem where OpportunityId in :OpportunityId_Map.keySet()];
        for(OpportunityLineItem oli : oliList1) {
            if(!excludedProducts.contains(oli.Product_Material_Type__c)) {
                oliList.add(oli);
            } else if(oli.TotalPrice > 0) {
                lqOppIdSet.add(oli.OpportunityId);
            }
        }
        // Added BY Ritesh gupta - ER-3208 - Start
        Map<id,List<OpportunityLineItem>> oppIdToOLIListMap = new Map<id,List<OpportunityLineItem>>();
        Map<id,List<OpportunityLineItemSchedule>> oliIdToOLISListMap = new Map<id,List<OpportunityLineItemSchedule>>();
        Map<id,List<Billing_Schedule_Item__c>> oliIdToBSIListMap = new Map<id,List<Billing_Schedule_Item__c>>();
        Map<id, Set<Id>> mibnfIdToOliIdsMap = new Map<id, Set<Id>>();
        // Added BY Ritesh gupta - ER-3208 - End
        //Added by Abhishek Bansal : 18-June-2015 : ER-1576 : Added two new field 'UnitPrice','Budget_Amount__c' in Query : Start/End
        for (OpportunityLineItem OLI:oliList)
        {
            OLI_Map.put(OLI.Id,OLI);
        }
        if (trigger.isUpdate)
        {
            for (MI_BNF_LineItem__c MIBNF_LI:[select Id,Opportunity_Line_Itemid__c,MIBNF_Component__c from MI_BNF_LineItem__c where MIBNF_Component__c in :trigger.newMap.keySet()])
            {
                if (!OLI_Array_Map.containsKey(MIBNF_LI.MIBNF_Component__c))
                {
                    OLI_Array_Map.put(MIBNF_LI.MIBNF_Component__c,new OpportunityLineItem[]{OLI_Map.get(MIBNF_LI.Opportunity_Line_Itemid__c)});
                   
                }
                else
                {
                    OLI_Array_Map.get(MIBNF_LI.MIBNF_Component__c).add(OLI_Map.get(MIBNF_LI.Opportunity_Line_Itemid__c));
                }
                if(!mibnfIdToOliIdsMap.containsKey(MIBNF_LI.MIBNF_Component__c)){                    
                    mibnfIdToOliIdsMap.put(MIBNF_LI.MIBNF_Component__c,new Set<Id>{MIBNF_LI.Opportunity_Line_Itemid__c});
                }
                else{
                    mibnfIdToOliIdsMap.get(MIBNF_LI.MIBNF_Component__c).add(MIBNF_LI.Opportunity_Line_Itemid__c);	
                }                   
            }                                                            
        }
        if(isBNFSAPConfirmed){
            String query = 'select Id, Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c , PricebookEntry.Name, Other_Ship_To_SAP_Contact__r.Name ';
            for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
                query += ', ' + f.getFieldPath();
            }
            query += ' FROM OpportunityLineItem where OpportunityId IN (';
            for(Id oppId : OpportunityId_Map.keySet()){
                query += '\'' + oppId + '\',';
            }
            query = query.removeEnd(',');
            query += ')';
                if(mibnfIdToOliIdsMap.size()>0){
                    query += ' AND Id IN (';
                    for(Id oliId : mibnfIdToOliIdsMap.get(trigger.new[0].Id)){
                        query += '\'' + oliId + '\',';
                    }
                    query = query.removeEnd(',');
                    query += ')';
                }
            
            // seperate query to fetch fields needed to store in json
            Map<Id, OpportunityLineItem> oliForJsonMap = new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(query));
            List<OpportunityLineItemSchedule> olisList = [Select OpportunityLineItemId, Description, Revenue, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemID IN :oliForJsonMap.keySet()];
            Set<String> oliIdSet = new Set<String>();
            for(OpportunityLineItem oli : oliList){
                List<OpportunityLineItem> currentOLIList = new List<OpportunityLineItem>();
                if(oppIdToOLIListMap.containsKey(oli.opportunityId)){
                    currentOLIList = oppIdToOLIListMap.get(oli.opportunityId);
                }
                if(oliForJsonMap.containsKey(oli.Id)) {
                    currentOLIList.add(oliForJsonMap.get(oli.Id));
                    oppIdToOLIListMap.put(oli.opportunityId, currentOLIList);
                }
                oliIdSet.add(oli.Id);
            }
            
            List<Billing_Schedule_Item__c> bsiList = [Select Name, Billing_Amount__c, Billing_Date__c, Invoice_Description__c, Billing_Schedule__r.OLIId__c From Billing_Schedule_Item__c where Billing_Schedule__r.OLIId__c IN :oliIdSet];
            
            for(OpportunityLineItemSchedule olis : olisList){
                List<OpportunityLineItemSchedule> currentOLISList = new List<OpportunityLineItemSchedule>();
                if(oliIdToOLISListMap.containsKey(olis.opportunityLineItemId)){
                    currentOLISList = oliIdToOLISListMap.get(olis.opportunityLineItemId);
                }
                currentOLISList.add(olis);
                oliIdToOLISListMap.put(olis.opportunityLineItemId, currentOLISList);
            }
            for(Billing_Schedule_Item__c bsi : bsiList){
                List<Billing_Schedule_Item__c> currentBSIList = new List<Billing_Schedule_Item__c>();
                if(oliIdToBSIListMap.containsKey(bsi.Billing_Schedule__r.OLIId__c)){
                    currentBSIList = oliIdToBSIListMap.get(bsi.Billing_Schedule__r.OLIId__c);
                }
                currentBSIList.add(bsi);
                oliIdToBSIListMap.put(bsi.Billing_Schedule__r.OLIId__c, currentBSIList);
            }
            
        }
        //Added by Himanshu Parashar : 13 Feb 2012 : Map for MIBNF fields
        Map<Id,MIBNF_Component__c> bnfMap = new Map<Id,MIBNF_Component__c>([select Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c,Comp_Revenue_Analyst__r.RA_Sales_Orgs__c,Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey,MIBNF__r.Revenue_Analyst__r.User__r.Email,MIBNF__r.Revenue_Analyst__r.User__r.Name,Bill_To__r.Name,Ship_To__r.Name,X2nd_Copy__r.Name,Cover_Sheet__r.Name,Carbon_Copy__r.Name,Bill_To__r.SAP_Reference__c,Ship_To__r.SAP_Reference__c,X2nd_Copy__r.SAP_Reference__c,Carbon_Copy__r.SAP_Reference__c,Cover_Sheet__r.SAP_Reference__c, Bill_To__r.PO_Required__c, Client_PO_Number__c, MIBNF__r.Contract_Start_Date__c,MIBNF__r.Contract_End_Date__c from MIBNF_Component__c where Id In:Trigger.new ]);
        
        
        //Updated By Rakesh : 26 March 2015 : ER-854 : Add (SELECT Id,IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r where Record_Type_Name__c = 'SOW' and is_Amendment_Record__c = false ) to SOQL
        Map<Id,Opportunity> Opportunity_Map = new Map<Id,Opportunity>([select Id, opportunity_number__c, Actual_Close_Timestamp__c,Therapy_Area__c,Contract_Start_Date__c, Contract_End_Date__c,StageName,pse__Primary_Project__c,SAP_Master_Contract__c,Is_USBU_Opportunity__c, (SELECT Id,IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r where Record_Type_Name__c = 'SOW' and is_Amendment_Record__c = false ) from Opportunity where Id in :OpportunityId_Map.keySet()]);
        
        //Added By Rakesh : 26 March 2015 : ER-854
        List<MIBNF_Component__c> BNFListSubmittedForApproval = new List<MIBNF_Component__c>();
        
        //updated by Himanshu Parashar : 01 Feb 2013
        List<Address__c> Address_List = new List<Address__c>();
        if(AddressId_Set.size()>0)
            Address_List = new List<Address__c>([select Id,Name,SAP_Reference__c,Enabled_Sales_Orgs__c,Marked_For_Deletion__c from Address__c where Id in :AddressId_Set and Id != null]);          
        //billToAddressMap = new Map<Id, Address__c>([select Id,Name,Payment_Terms__c from Address__c where Id in :billToAddressIdSet]); 
        Set<String> alreadyCovered = new Set<String>(); 
        
        //Set<Id> billToAddressIdSet = new Set<Id>();
        //Map<Id, Address__c> billToAddressMap = new Map<Id, Address__c>();
        for(Address__c isMFD : Address_List){
            MarkedForDeletionAddress_Map.put(isMFD.Id,isMFD.Marked_For_Deletion__c);
        }		
        for (MIBNF_Component__c  cBNF : Trigger.new) 
        {  

			//agreement repositroy validation  - ESPSFDCQI-17974
            if(Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted' && cBNF.BNF_Status__c != Trigger.oldMap.get(cBNF.Id).BNF_Status__c){
                CLM_Configuration__c clmConfiguration = CLM_Configuration__c.getInstance();
                Boolean enableAgreementRepository = clmConfiguration.Enable_Agreement_Repository__c;
                if(String.isBlank(cBNF.AR_Comments__c) && Opportunity_Map.get(cBNF.Opportunity__c).Is_USBU_Opportunity__c  
                    && cBNF.Addendum__c && cBNF.Revised_BNF_Reason__c == 'Change Order/Amendment' && enableAgreementRepository){
                      cBNF.addError(System.Label.Agreement_Repository_Comment_Validation_Error_Message);
                  }
            }
            
            /*
            if(cBNF.Bill_To__c != null){
                billToAddressIdSet = new Set<Id>{cBNF.Bill_To__c};
            }
            */
            if (Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted'  && cBNF.BNF_Status__c != Trigger.oldMap.get(cBNF.Id).BNF_Status__c && lqOppIdSet.contains(cBNF.Opportunity__c)) {
                cBNF.addError('Please set Quintiles Product amount to zero before submitting the MIBNF.');
            }
            if(Trigger.isBefore && Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted' && cBNF.BNF_Status__c != Trigger.oldMap.get(cBNF.Id).BNF_Status__c && cBNF.Comp_Revenue_Analyst__c == null ) {
                cBNF.addError('Revenue Analyst is required when you submit BNF');
            }
            if(Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted' && cBNF.BNF_Status__c != Trigger.oldMap.get(cBNF.Id).BNF_Status__c && cBNF.Comp_Revenue_Analyst__c != null  && revAnalystRecordsMap.get(cBNF.Comp_Revenue_Analyst__c).Disable_RA__c) {
                cBNF.addError('Please select a valid Revenue Analyst.');
            }
            //Ensure the addresses selected are not marked for deletion
            if(Trigger.isUpdate && cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') )
            {
                if(!MarkedForDeletionAddress_Map.isEmpty()){
                        if(cBNF.Bill_To__c != null && MarkedForDeletionAddress_Map.get(cBNF.Bill_To__c)){
                            cBNF.addError('The Bill To Address selected is Marked For Deletion.Please review to submit.');
                        }
                        if(cBNF.Ship_To__c != null && MarkedForDeletionAddress_Map.get(cBNF.Ship_To__c)){
                            cBNF.addError('The Ship To Address selected is Marked For Deletion.Please review to submit.');
                        }
                        if(cBNF.Sold_To__c != null && MarkedForDeletionAddress_Map.get(cBNF.Sold_To__c)){
                            cBNF.addError('The Sold To Address selected is Marked For Deletion.Please review to submit.');
                        }
                        if(cBNF.Cover_Sheet__c != null && MarkedForDeletionAddress_Map.get(cBNF.Cover_Sheet__c)){
                            cBNF.addError('The CoverSheet Address selected is Marked For Deletion.Please review to submit.');
                        }
                        if(cBNF.X2nd_Copy__c != null && MarkedForDeletionAddress_Map.get(cBNF.X2nd_Copy__c)){
                            cBNF.addError('The 2nd Copy Address selected is Marked For Deletion.Please review to submit.');
                        }
                        if(cBNF.Carbon_Copy__c != null && MarkedForDeletionAddress_Map.get(cBNF.Carbon_Copy__c)){
                            cBNF.addError('The Carbon Copy Address selected is Marked For Deletion.Please review to submit.');
                        }      
                }   
            }            
            try {
                if(bnfSetting.BNF_Opportunity_Threshold__c != null) {
                    opportunityNumber = Opportunity_Map.get(cBNF.Opportunity_Id__c).opportunity_number__c;
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
            
            if(isNewBnf) {      
                //Added By Rakesh : 26 March 2015 : ER-854 : START
                if(Trigger.isUpdate)
                {
                    if(!string.isBlank(cBNF.BNF_Status__c) && !string.isBlank(trigger.oldMap.get(cBNF.Id).BNF_Status__c) &&
                       trigger.oldMap.get(cBNF.Id).BNF_Status__c != 'Submitted' &&  cBNF.BNF_Status__c == 'Submitted'
                      )
                    {
                        BNFListSubmittedForApproval.add(cBNF);
                    }   
                }  //END : ER-854
            }
            
            //  Prevent BNF from being rejected with blank Rejection_Reasons__c field.  This would happen if users try to reject
            //  through the "Manage Approvals" page that allows bulk approvals/rejections
            if (Trigger.isUpdate && (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('REJECTED') || cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_REJECTED') ||
                                     cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_REJECTED')
                                    )
                && Trigger.oldMap.get(cBNF.Id).BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED'))
            {
                //Update By Himanshu Parashar : 3 Dec 2012 : Rejection_Reasons__c replaced by Rejection_Reasons_Multi__c
                if (cBNF.Rejection_Reasons_Multi__c == null)
                {
                    if (Trigger.New.size() > 1)
                    {
                        cBNF.addError('BNF\'s cannot be mass rejected.  Please view each BNF individually and click on the Approve/Reject link');
                    }
                    else
                    {
                        cBNF.addError('BNF\'s cannot be rejected through this screen.  Please click <a href="/apex/MI_BNF_Approval?id='+ cBNF.id +'">here</a> to Approve/Reject this BNF');
                    }
                }
            } 
            
            //  Ensure that accepted MIBNF's cannot be re-submitted  
            if (Trigger.isUpdate &&
                cBNF.BNF_Status__c == 'Submitted'  && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('REJECTED') && 
                Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('RA_REJECTED') && 
                Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('LO_REJECTED') && 
                Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW'))
            {
                cBNF.addError('This MIBNF has already been submitted and cannot be re-submitted.');
            }
            
            if (Trigger.isUpdate &&
                (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') ||
                 cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED')
                )  &&
                (!Trigger.oldMap.get(cBNF.Id).BNF_Status__c.Contains('Accepted')) && 
                MI_BNF_Approval_Extension.CustomApprovalPage == false)
            { 
                cBNF.addError('BNF\'s cannot be approved through this screen.  Please click <a href="/apex/MI_BNF_Approval?id='+ cBNF.id +'">here</a> to Approve/Reject this BNF');
            }   
            //  Ensure that opportunity is at stage 6a or In-Hand when BNF is submitted
            if (Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted' && Opportunity_Map.get(cBNF.Opportunity_Id__c).StageName != '7a. Closed Won' && Opportunity_Map.get(cBNF.Opportunity_Id__c).StageName != 'In-Hand')
            {
                cBNF.addError('This opportunity must be at stage "7a. Closed Won" or "In-Hand" before you can submit the BNF.');
            }
            /*else if (Trigger.isUpdate && cBNF.BNF_Status__c == 'Submitted' && cBNF.Revenue_Analyst__c == null)
{
cBNF.addError('You must specify a Revenue Analyst before submitting this BNF for approval. Please go back and edit the BNF to enter the required information and then submit for approval again.');
}*/
            if (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') && Trigger.oldMap.get(cBNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') || 
                cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED') && Trigger.oldMap.get(cBNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED'))        
            {
                cBNF.SAP_Rejection_Count__c = cBNF.SAP_Rejection_Count__c==null ? 1 : cBNF.SAP_Rejection_Count__c+1;
            }
            if (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('REJECTED') && Trigger.oldMap.get(cBNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('REJECTED'))      
            {
                cBNF.RA_Rejection_Count__c = cBNF.RA_Rejection_Count__c==null ? 1 : cBNF.RA_Rejection_Count__c+1;
            }
            
            if (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_REJECTED') && Trigger.oldMap.get(cBNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('LO_REJECTED'))      
            {
                cBNF.LO_Rejection_Count__c = cBNF.LO_Rejection_Count__c==null ? 1 : cBNF.LO_Rejection_Count__c+1;
            }
            
            if (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_REJECTED') && Trigger.oldMap.get(cBNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('RA_REJECTED'))      
            {
                cBNF.RA_Rejection_Count__c = cBNF.RA_Rejection_Count__c==null ? 1 : cBNF.RA_Rejection_Count__c+1;
            }
            //  Check whether BNF is part of pilot sales org group for BNF/SAP SD integration
            Boolean iBNF_Enabled = true;//(MDM_Defines.EnabledSalesOrgs.contains(cBNF.IMS_Sales_Org__c)); 
            //  Ensure that Bill To and Ship To are selected before BNF is submitted for approval
            if (iBNF_Enabled && Trigger.isUpdate && cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && (cBNF.Ship_To__c == null || cBNF.Bill_To__c == null) )
            {
                cBNF.addError('You must select a Bill To/Ship To address before submitting this BNF for approval. Please go back and edit the BNF to enter the required information and then submit for approval again.');
            }
            
            if (Trigger.isUpdate && cBNF.BNF_Status__c=='Submitted')
            {
                MI_BNF_WizardEx mi=new MI_BNF_WizardEx(cBNF.id,cBNF.MIBNF__c,cBNF.Opportunity_Id__c);
                if(mi.oppAvailableProductsList.size()>0)
                    cBNF.addError('BNF cannot be submitted as there are available products which have not been allocated to an invoice');
            }
            
            // If there is no product available for BNF then throw error
            if(Trigger.isUpdate && cBNF.BNF_Status__c=='Submitted' && !OLI_Array_Map.containsKey(cBNF.id))
            {
                cBNF.addError('Please add product to BNF Before Submission');
            }
            
            //Added by Abhishek Bansal : 18-June-2015 : ER-1576 : Not allowed to submit BNF if OLI Price does not match with its Budget amount : Start
            if(Trigger.isUpdate && cBNF.BNF_Status__c=='Submitted')
            { 
                for(OpportunityLineItem OLI : OLI_Array_Map.get(cBNF.id)){
                    if(OLI.Budget_Amount__c != null && OLI.UnitPrice != OLI.Budget_Amount__c){
                        cBNF.addError('Sales Price of OLI does not match with its Budget');
                    }
                }
            }
            if(Trigger.isUpdate && cBNF.BNF_Status__c=='Submitted' && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != cBNF.BNF_Status__c) {
                MIBNF_ProductControllerLockedGrid mibnfProductController = new MIBNF_ProductControllerLockedGrid();
                mibnfProductController.setMIBNFComp(cBNF.Id);
                mibnfProductController.setOppLineItem(cBNF.id);
                mibnfProductController.setOpportunityLineItem();
                mibnfProductController.setIsNewBnfFlag();
                pagereference getRetureValue =  mibnfProductController.save();
                System.debug('getRetureValue ' + getRetureValue);
                if(getRetureValue == Null && !Test.isRunningTest()){
                    cBNF.addError('Please use the "Edit Product" button on the BNF to review and correct all product details.');
                }
            }
            //Added by Abhishek Bansal : 18-June-2015 : ER-1576 : Not allowed to submit BNF if OLI Price does not match with its Budget amount : End 
            boolean isCurrentUserIsSBSUser = false;
            if(Trigger.isUpdate &&  Trigger.oldMap.get(cBNF.Id).Manual_Handling_in_SAP__c != cBNF.Manual_Handling_in_SAP__c && cBNF.IMS_Sales_Org__c == CON_CRM.IMS_SALES_ORG_CH07){
                Set<Id> revAnalystIdsSetToCmpr = new Set<Id>();
                String count = 'del';
                Integer countInt = 1;
                for(Integer ind = 1; ind<= 10; ind++){
                    if(ind == 1){
                        if(cBNF.get('Comp_Revenue_Analyst_user__c') != null){
                            revAnalystIdsSetToCmpr.add((Id)cBNF.get('Comp_Revenue_Analyst_user__c'));    
                        }
                    }else{
                        String revAnalystApi =  'Comp_Revenue_Analyst_user_'+ind+'__c';
                        if(cBNF.get(revAnalystApi) != null){
                            revAnalystIdsSetToCmpr.add((Id)cBNF.get(revAnalystApi));    
                        }
                    }
                }
                if(revAnalystRecordsMap.get(cBNF.Comp_Revenue_Analyst__c).Owner.Type == CON_CRM.QUEUE && revAnalystIdsSetToCmpr.contains(UserInfo.getUserId())){
                    isCurrentUserIsSBSUser = true;
                }
            }
            if (cBNF.Addendum__c)
            {
                if(!isCurrentUserIsSBSUser){
                    cBNF.Manual_Handling_in_SAP__c = true;
                }else{
                    cBNF.Is_Manual_Handling_in_SAP_Updated__c = true;
                }
            }
            String WbsProducts = '';
            Integer ZrepLineItems = 0;
            Boolean WbsRequired = false;
            if (trigger.isUpdate)
            {
                List<OpportunityLineItem> OLI_array = OLI_Array_Map.get(cBNF.Id);
                //System.assert(OLI_array != null);
                Integer ExcludedLineItems = 0;
                Integer RepeatLineItems = 0;
                Boolean AdHoc = true;
                /** Update By - Sneha Rathi Date- 20 Dec, 2012 Issue-01473 Boolean added */
                Boolean ListPriceIsBlank=false;
                if (OLI_array != null)
                {
                    String InvalidProductCodes = '';
                    Boolean InvalidProduct = false;
                    String BillingScheduleProductCodes = '';
                    String RevenueScheduleProductCodes = '';
                    String TherapyAreaProductCodes = '';
                    Boolean BillingScheduleEmpty = false;
                    Boolean RevenueScheduleEmpty = false;
                    Boolean IsTherapyAreaDifferent=false;
                    Boolean isPORequired = false;
                    String WBSCodesWithInvalidEndDates = '';
                    String WBSCodesWithInvalidStartDates = '';
                    for (OpportunityLineItem OLI : OLI_array)
                    {
                        
                        /**
Update By - Sneha Rathi
Date- 20 Dec, 2012 
Issue-01473
check whether List_Price__c is null on 1st submission
*/
                        if(Trigger.isUpdate)
                        {
                            if(((Trigger.oldMap.get(cBNF.Id).BNF_Status__c.equals('New') && cBNF.BNF_Status__c.equals('Submitted'))||(Trigger.oldMap.get(cBNF.Id).BNF_Status__c.equals('Rejected')&&cBNF.BNF_Status__c.equals('Submitted'))) && (!cBNF.Sales_Org_Code__c.contains('US')) && (OLI.PricebookEntry.Product2.Offering_Type__c !='Management Consulting' && OLI.PricebookEntry.Product2.Offering_Type__c !=Label.CES_TOT_Offering_Type && OLI.List_Price__c == null ))
                                ListPriceIsBlank = true;
                        }
                        
                        //  Count the number of ZREP materials - used to determine whether 
                        //  a check is done to prevent submission without a PSE project
                        
                        if(IsNewBnf) 
                        {
                            if (OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP' || 
                                (OLI.PricebookEntry.Product2.Material_Type__c == 'ZPUB' && OLI.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'))
                            {
                                if (OLI.Wbsrelementcode__c == null && OLI.Totalprice>0 && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
                                {
                                    WbsRequired = true;
                                    if (WbsProducts != '')
                                    {
                                        WbsProducts += ', ';
                                    }
                                    WbsProducts += OLI.PricebookEntry.Product2.ProductCode;
                                }
                                ZrepLineItems++;
                                
                                //  Set revised price as the comparison to be used for revised bnf                        
                                Decimal ValidationPrice;
                                if (cBNF.Addendum__c && OLI.Revised_Price__c != null)
                                    ValidationPrice = OLI.Revised_Price__c.setScale(2);
                                else
                                    ValidationPrice = OLI.TotalPrice.setscale(2);    
                                
                                //Billing Schedule Validation
                                if(cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   (OLI.Billing_Schedule__c == NULL || OLI.Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) != ValidationPrice) &&
                                   (OLI.TotalPrice != 0 || OLI.Discount_Amount_Formula__c != 0))
                                {                          
                                    BillingScheduleEmpty = true;
                                    if (BillingScheduleProductCodes != '')
                                    {
                                        BillingScheduleProductCodes += ', ';
                                    }
                                    BillingScheduleProductCodes+= OLI.PricebookEntry.Product2.ProductCode;                                            
                                } 
                                // Only validate opportunitylineitemschedules if no revised revenue schedule is present
                                if(OLI.Revised_Revenue_Schedule__c == null && cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   ((OLIScheduleMapStartDate.containskey(oli.id) && OLIScheduleMapStartDate.get(oli.id)==true) ||
                                    (OLIScheduleMapEndDate.containskey(oli.id) && OLIScheduleMapEndDate.get(oli.id)==true)))
                                {
                                    RevenueScheduleEmpty = true;
                                    if (RevenueScheduleProductCodes != '')
                                    {
                                        RevenueScheduleProductCodes += ', ';
                                    }
                                    RevenueScheduleProductCodes += OLI.PricebookEntry.Product2.ProductCode;                                            
                                } 
                                
                                if(OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP' && cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') &&
                                   (OLI.Therapy_area__c!=NULL && OLI.Budget_Therapy_Area__c!=null && OLI.Therapy_area__c!=OLI.Budget_Therapy_Area__c))
                                {
                                    IsTherapyAreaDifferent=true;
                                    if (TherapyAreaProductCodes != '')
                                    {
                                        TherapyAreaProductCodes += ', ';
                                    }
                                    TherapyAreaProductCodes += OLI.PricebookEntry.Product2.ProductCode;                                            
                                } 
                            }
                            //  Check revised revenue schedule against project start/end dates only for ZREP materials
                            if (OLI.Revised_Revenue_Schedule__c != null && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
                            {
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
                                for (integer i=0;i<strRevSchedule.size();i++)
                                {
                                    tempDate = strRevSchedule[i].split(':')[0];
                                    RevenueYear = Integer.valueOf(tempDate.left(4));
                                    RevenueMonth = Integer.valueOf(tempDate.mid(4,2));
                                    RevenueDay = Integer.valueOf(tempDate.right(2));
                                    system.debug('year: ' + tempDate.left(4));
                                    system.debug('month: ' + tempDate.mid(5,2));
                                    system.debug('day: ' + tempDate.right(2));
                                    RevenueDate = Date.newInstance(RevenueYear,RevenueMonth,RevenueDay);
                                    if (RevenueDate < OLI.Product_Start_Date__c)
                                    {
                                        OLIScheduleMapStartDate.put(OLI.Id,True);
                                    }
                                    if (RevenueDate > OLI.Project_End_Date__c)
                                    {
                                        OLIScheduleMapEndDate.put(OLI.Id,True);
                                    }
                                }       
                            }
                        } 
                        else 
                        {
                            if (OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
                            {
                                if (OLI.Wbsrelementcode__c == null && OLI.Totalprice>0)
                                {
                                    WbsRequired = true;
                                    if (WbsProducts != '')
                                    {
                                        WbsProducts += ', ';
                                    }
                                    WbsProducts += OLI.PricebookEntry.Product2.ProductCode;
                                }
                                ZrepLineItems++;
                            }                      
                        }
                        
                        
                        
                        //  Check whether any line items have a sale type of "repeat".  If yes, this means the contract
                        //  must be created as a renewal and attached to an existing master contract in SAP
                        if (OLI.Sale_Type__c == 'Repeat')
                        {
                            RepeatLineItems++;
                        }
                        if (OLI.Billing_Frequency__c != 'Once' || OLI.Proj_Rpt_Frequency__c != 'Once [O]')
                        {
                            AdHoc = false;
                        }
                        
                        //  BEGIN 2012-01-21 Sam Duncan: Comment out sales org validation code to allow deployment of list price validation to PROD
                        
                        
                        Set<String> setProductSalesOrgs = new Set<String>();
                        //Added by Himanshu Parashar : 13 Feb : MIBNF_Status__c Submitted
                        if(bnfSetting.Enable_Material_Validation__c==true && OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c!= null)
                        {
                            List<String> ProductSalesOrgs= OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c.split(':'); 
                            setProductSalesOrgs.addAll(ProductSalesOrgs);                    
                        }
                        
                        if((OLI.TotalPrice!=null && OLI.TotalPrice > 0) && bnfSetting.Enable_Material_Validation__c==true && cBNF.BNF_Status__c == 'Submitted' && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != 'Submitted' && (OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c== null ||(setProductSalesOrgs.size()>0 && (!setProductSalesOrgs.contains(cBNF.Sales_Org_Code__c)))))
                            
                        {
                            InvalidProduct = true;
                            if (InvalidProductCodes != '')
                            {
                                InvalidProductCodes += ', ';
                            }
                            InvalidProductCodes += OLI.PricebookEntry.Product2.ProductCode;                                            
                        }                
                        //END 2012-01-21 Sam Duncan: Comment out sales org validation code to allow deployment of list price validation to PROD
                        
                        //Added By Himanshu Parashar : MIS Issue-02000 : Update lineitem if no therapy_area specified
                        if(cBNF.Addendum__c && OLI.Therapy_Area__c == null && cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && Opportunity_Map.get(cBNF.Opportunity_Id__c).Therapy_Area__c!=null)
                        {
                            OLI.Therapy_Area__c = Opportunity_Map.get(cBNF.Opportunity_Id__c).Therapy_Area__c;
                            UpdateOLIlst.add(OLI);
                            UpdateRequired = true;
                        }
                        
                        //PO changes :Pramod
                        if(bnfMap.get(cBNF.Id).Bill_To__r.PO_Required__c && (cBNF.Client_PO_Number__c == null || cBNF.Client_PO_Number__c.length() == 0) && (OLI.PO_Number__c == null || OLI.PO_Number__c.length() == 0))
                        {
                            isPORequired = true;
                        }
                        // End PO changes 
                        
                        //  Sam Duncan 2016-08-05
                        //  Issue-09263
                        //  Validate data period start/end (which are taken from project start/end) against BNF contract start/end for ZREP materials only
                        if(cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SUBMITTED') 
                           && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
                        {
                            if (OLI.Product_End_Date__c > bnfMap.get(cBNF.Id).MIBNF__r.Contract_End_Date__c)
                            {
                                if (WBSCodesWithInvalidEndDates != '')
                                {
                                    WBSCodesWithInvalidEndDates += ', ';
                                }
                                WBSCodesWithInvalidEndDates += OLI.Wbsrelementcode__c;                                  
                            }
                            if (OLI.Product_Start_Date__c < bnfMap.get(cBNF.Id).MIBNF__r.Contract_Start_Date__c)
                            {
                                if (WBSCodesWithInvalidStartDates != '')
                                {
                                    WBSCodesWithInvalidStartDates += ', ';
                                }
                                WBSCodesWithInvalidStartDates += OLI.Wbsrelementcode__c;                                
                            }
                        }              
                        //  End Issue-09263                 
                    }
                    
                    //PO changes :Pramod
                    if(bnfSetting.Enable_PO_Validation__c && cBNF.BNF_Status__c == 'Submitted' && isPORequired) {
                        cBNF.addError('PO Number is required in order to submit record for approval.');
                    }
                    // End PO changes
                    
                    if (InvalidProduct)
                    {
                        cBNF.addError('Product(s): '+InvalidProductCodes +' are not enabled for sales org '+cBNF.Sales_Org_Code__c +'.  Please contact your local Finance representative to resolve this before submitting the BNF.');
                    }
                    if (WBSCodesWithInvalidEndDates != '')
                        cBNF.addError('Project: '+WBSCodesWithInvalidEndDates +' has an end date beyond the contract end date.  Please adjust project end date or contract end date before submitting the BNF.');
                    if (WBSCodesWithInvalidStartDates != '')
                        cBNF.addError('Project: '+WBSCodesWithInvalidStartDates +' has a start date before the contract start date.  Please adjust project start date or contract end date before submitting the BNF.');
                    
                    if(IsNewBnf) {
                        if (bnfSetting.Enable_Billing_Schedule_Validation__c && BillingScheduleEmpty)
                        {
                            cBNF.addError('BNF cannot be submitted at this time because Product(s): '  + BillingScheduleProductCodes + ' do not have billing schedules equal to the sales/revised price. Please use the "Edit Product" button on the BNF to edit these products and create Billing Schedule. Once complete you can submit the BNF');
                        }
                        
                        if(bnfSetting.Enable_RSchedule_Validation__c && RevenueScheduleEmpty)
                        {
                            cBNF.addError('BNF cannot be submitted at this time because Product(s): '  + RevenueScheduleProductCodes + ' have invalid Revenue Schedules. Revenue schedules should be between Project Start/End Date. Once complete you can submit the BNF');
                        }
                        
                        if(IsTherapyAreaDifferent)
                        {
                            cBNF.addError('BNF cannot be submitted at this time because Product(s): '  + TherapyAreaProductCodes + ' does not match budget therapy area. Please adjust to ensure that therapy areas values match and then re-submit the BNF.');
                        }
                    }
                }
                
                /** Update By - Sneha Rathi Date- 20 Dec, 2012 Issue-01473 error added, if null and Non-US sales org */
                if (ListPriceIsBlank && !Pattern.matches('US[\\s|[A-z]|[0-9]]*',cBNF.Sales_Org_Code__c.toUpperCase()))
                {
                    cBNF.addError('BNF cannot be submitted at this time because some of the products have a blank list price. Please use the "Edit Product" button on the BNF to edit these products and enter a list price and other mandatory fields.  Once complete you can submit the BNF');
                }
               
                Boolean isUsSalesorg = false;
                Set<String> usSalesOrgsSet = new Set<String>();
                Enable_US_Sales_Org__c usSalesOrgs = Enable_US_Sales_Org__c.getinstance(cBNF.createdById);
                if(usSalesOrgs.US_iBNF_Sales_Orgs__c != null) {
                    for (String usOrgs : usSalesOrgs.US_iBNF_Sales_Orgs__c.split(','))
                    {
                        usSalesOrgsSet.add(usOrgs);
                    }
                }
                String SalesOrgCode = (cBNF.IMS_Sales_Org__c).substringBetween('[',']');
			    isUsSalesorg = usSalesOrgsSet.contains(SalesOrgCode);
                if(IsNewBnf) {
                    if (iBNF_Enabled && (cBNF.Addendum__c || ExcludedLineItems > 0 || (!MDM_Defines.EnabledSalesOrgs.contains(cBNF.IMS_Sales_Org__c) && !isUsSalesorg ) || MDM_Defines.ManualSalesOrgs.contains(cBNF.IMS_Sales_Org__c)))
                    {
                        if(!isCurrentUserIsSBSUser){
                            cBNF.Manual_Handling_in_SAP__c = true;
                        }else{
                            cBNF.Is_Manual_Handling_in_SAP_Updated__c = true;
                        }
                    }
                } else {
                    if (iBNF_Enabled && (cBNF.Addendum__c || ExcludedLineItems > 0 || ZrepLineItems > 0 || (!MDM_Defines.EnabledSalesOrgs.contains(cBNF.IMS_Sales_Org__c) && !isUsSalesorg) || MDM_Defines.ManualSalesOrgs.contains(cBNF.IMS_Sales_Org__c)))
                    {
                        if(!isCurrentUserIsSBSUser){
                            cBNF.Manual_Handling_in_SAP__c = true;
                        }else{
                            cBNF.Is_Manual_Handling_in_SAP_Updated__c = true;
                        }
                    }             
                }
                //  Only set the renewal flag on insert to allow users to uncheck if necessary
                //  as not all repeat line items are part of a renewal
                if (iBNF_Enabled && Trigger.isInsert && RepeatLineItems > 0)
                {
                    cBNF.Renewal__c = true;
                    if (cBNF.SAP_Master_Contract__c == null)
                    {
                        cBNF.SAP_Master_Contract__c = Opportunity_Map.get(cBNF.Opportunity_Id__c).SAP_Master_Contract__c;              
                    }
                }
            }
            
            
            
            //  If BNF is being manually approved (because of repeat line item or C&S line item etc.)
            //  then approver must fill in SAP Contract Number before approving
            if (iBNF_Enabled && cBNF.Manual_Handling_in_SAP__c && (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED')))
            {
                if (cBNF.SAP_Contract__c == null || !Pattern.matches('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]',cBNF.SAP_Contract__c))
                {
                    cBNF.SAP_Contract__c.addError('You must edit the BNF and enter a 10 digit SAP contract number before approving. Please edit the BNF and add this value and then approve the BNF.');
                }
            }  
            //  If BNF is a renewal and is being approved with no Master Contract number
            //  then approver must fill in SAP Master Contract Number before approving
            if (iBNF_Enabled && cBNF.Renewal__c && (cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || cBNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED')))
            {
                if (cBNF.SAP_Master_Contract__c == null || !Pattern.matches('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]',cBNF.SAP_Master_Contract__c))
                {
                    cBNF.SAP_Master_Contract__c.addError('This BNF is for a renewal.  Please edit the BNF and enter a 10 digit SAP master contract number before approving.');
                }
            }           
            //  Do not require this check for revised BNF's
            /*if (cBNF.Addendum__c == false)
{*/
            //Check the BNF Submit status
            String sStatus = cBNF.BNF_Status__c;
            Boolean sError = true;
            Boolean bConsultingProd = false;
            Id OpptyId = cBNF.Opportunity_Id__c;
            //  COMMENT OUT LINES BELOW FOR TESTING ONLY    
            if(cBNF.BNF_Status__c == 'Submitted' && ZrepLineItems > 0 && WbsRequired)
            {
                cBNF.addError('BNF cannot be submitted at this time. All consulting products must have WBS elements setup in SAP before BNF submission. Products currently missing WBS are: ' + WbsProducts);
            }  
            //  END COMMENT OUT FOR TESTING           
            //}           
            
            
            
        }
        
        //Added By Rakesh : 26 March 2015 : ER-854 : START
        if(IsNewBnf) {
            if(Trigger.isUpdate)
            {
                Contract_Management_Setting__c contractSetting = Contract_Management_Setting__c.getInstance();
                string IMSSalesOrgCode = '';
                string legalEntity = '';
                
                if(BNFListSubmittedForApproval.size() > 0)
                {
                    if(ConstantClass.allowSalesOrgUpdateOnBNF_FromSCM && contractSetting != null && contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c)
                    {
                        if(Opportunity_Map.size() > 0 )
                        {
                            map<string, string> salesCodetoSalesOrgNameInBNFMap = ConstantClass.getSalesOrgNameinBNFSystem1('Purchase BNF');
                            
                            for(MIBNF_Component__c BNF: BNFListSubmittedForApproval)
                            {
                                //Get legal entity of agreement based on opportunity
                                legalEntity =  ConstantClass.checkAgreementLegalEntityForOpportunity(BNF.Opportunity_Id__c, Opportunity_Map);             
                                //get sales org code based on legal entity
                                IMSSalesOrgCode = ConstantClass.getSalesOrgCodeforAgreementLegalEntity(legalEntity);
                                if(!string.isBlank(IMSSalesOrgCode) && BNF.Sales_Org_Code__c != IMSSalesOrgCode)
                                {
                                    BNF.addError(Label.SCM_BNF_Submission_Message);
                                }
                            }
                        }
                    }
                    //BNFListSubmittedForApproval.add(cBNF);
                }   
            }  //END : ER-854
        }
        
        
        for (MIBNF_Component__c  cBNF : Trigger.new) 
        {
            /*
            if(cBNF.Bill_To__c != null && billToAddressMap.containsKey(cBNF.Bill_To__c) && (Trigger.isInsert || (Trigger.oldMap.get(cBNF.Id).Bill_To__c != cBNF.Bill_To__c) )){
                cBNF.Payment_Terms__c = billToAddressMap.get(cBNF.Bill_To__c).Payment_Terms__c;   
            }
            */
            //updated by Himanshu Parashar : 01 Feb 2013
            if(bnfSetting.Enable_Customer_Validation__c==true && cBNF.BNF_Status__c == 'Submitted' && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != 'Submitted')// && Trigger.oldMap.get(cBNF.id).Sales_Org_Code__c != cBNF.Sales_Org_Code__c )
            {
                //Issue-08506
                // updated by Dheeraj Kumar 11 May 2017 Issue-10863 
                List<User> mdmUserList = [select Id,Name,Email from User where email =: MDM_Defines.MdmApprovalEmailAddress and isActive = true limit 1];
                Boolean sendEmail = false;
                //Issue-08506
                if(mdmUserList.size() > 0) {
                    //Added by himanshu parashar : 13 dec 2012 : Sending mail once for multiple addresses
                    String htmlBody = 'Dear MDM Team,<br/><br/>BNF '+cBNF.Name+' has been submitted for Sales Org '+cBNF.Sales_Org_Code__c+'.'+
                        'The addresses below are specified as bill to / ship to parties on this BNF, but are not extended to the '+cBNF.Sales_Org_Code__c+' Sales Org.'+
                        '<br/><br/>'+
                        '<table border="1">';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    
                    for (Address__c A:Address_List)
                    {
                        //Updated Date : 7 Feb 2013 By Himanshu Parashar
                        list<String> AddressSalesOrgs=new List<String>();
                        Set<String> setAddressSalesOrgs=new Set<String>();
                        //Updated by Himanshu Parashar : 11 dec : BNF_Status__c Submitted
                        if(A.Enabled_Sales_Orgs__c!=null)
                        {
                            AddressSalesOrgs= A.Enabled_Sales_Orgs__c.split(':'); 
                            setAddressSalesOrgs.addAll(AddressSalesOrgs);
                        }
                        
                        if (setAddressSalesOrgs.contains(cBNF.Sales_Org_Code__c) == false)
                        {         
                            alreadyCovered.add(A.id);
                            //String[] toAddresses = new String[] {MDM_Defines.MdmApprovalEmailAddress};           
                            //mail.setToAddresses(toAddresses);
                            sendEmail = true;
                            mail.setSubject('Extend address(es) for Sales Org '+cBNF.Sales_Org_Code__c);   
                            mail.setTargetObjectId(mdmUserList[0].id);
                            mail.setSaveAsActivity(false);                                 
                            if(Address_Map.get(cBNF.id + '_' + A.Id) == 'Bill To')
                            {
                                htmlBody +='<tr><td>'+Address_Map.get(cBNF.id + '_' + A.Id)+': </td><td>'+bnfMap.get(cBNF.Id).Bill_To__r.Name;
                                if(bnfMap.get(cBNF.Id).Bill_To__r.SAP_Reference__c==null)
                                    htmlBody+='';
                                else
                                    htmlBody+='(SAP Code '+bnfMap.get(cBNF.Id).Bill_To__r.SAP_Reference__c+')';
                                htmlBody +='</td></tr>';
                            }
                            else if(Address_Map.get(cBNF.id + '_' + A.Id) == 'Ship To')
                            {
                                htmlBody +='<tr><td>'+Address_Map.get(cBNF.id + '_' + A.Id)+': </td><td>'+bnfMap.get(cBNF.Id).Ship_To__r.Name;
                                
                                if(bnfMap.get(cBNF.Id).Ship_To__r.SAP_Reference__c==null)
                                    htmlBody+='';
                                else
                                    htmlBody+='(SAP Code '+bnfMap.get(cBNF.Id).Ship_To__r.SAP_Reference__c+')';
                                htmlBody +='</td></tr>';
                            }
                            else if(Address_Map.get(cBNF.id + '_' + A.Id) == '2nd Copy')
                            {
                                htmlBody +='<tr><td>'+Address_Map.get(cBNF.id + '_' + A.Id)+': </td><td>'+bnfMap.get(cBNF.Id).X2nd_Copy__r.Name;
                                
                                if(bnfMap.get(cBNF.Id).X2nd_Copy__r.SAP_Reference__c==null)
                                    htmlBody+='';
                                else
                                    htmlBody+='(SAP Code '+bnfMap.get(cBNF.id).X2nd_Copy__r.SAP_Reference__c+')';
                                htmlBody +='</td></tr>';
                            }
                            else if(Address_Map.get(cBNF.id + '_' + A.Id) == 'Carbon Copy')
                            {
                                htmlBody +='<tr><td>'+Address_Map.get(cBNF.id + '_' + A.Id)+': </td><td>'+bnfMap.get(cBNF.Id).Carbon_Copy__r.Name;
                                
                                if(bnfMap.get(cBNF.Id).Carbon_Copy__r.SAP_Reference__c==null)
                                    htmlBody+='';
                                else
                                    htmlBody+='(SAP Code '+bnfMap.get(cBNF.Id).Carbon_Copy__r.SAP_Reference__c+')';
                                htmlBody +='</td></tr>';
                            }    
                            else if(Address_Map.get(cBNF.id + '_' + A.Id) == 'Cover Sheet')
                            {
                                htmlBody +='<tr><td>'+Address_Map.get(cBNF.id + '_' + A.Id)+': </td><td>'+bnfMap.get(cBNF.Id).Cover_Sheet__r.Name;
                                
                                if(bnfMap.get(cBNF.Id).Cover_Sheet__r.SAP_Reference__c==null)
                                    htmlBody+='';
                                else
                                    htmlBody+='(SAP Code '+bnfMap.get(cBNF.Id).Cover_Sheet__r.SAP_Reference__c+')';
                                htmlBody +='</td></tr>';
                            } 
                            
                            /*htmlBody += '</table><br/><br/>Please can you extend as appropriate and notify '+bnfMap.get(cBNF.Id).MIBNF__r.Revenue_Analyst__r.User__r.Name+' ('+bnfMap.get(cBNF.Id).MIBNF__r.Revenue_Analyst__r.User__r.Email+') once complete.'+
'Please liaise with the local admin if there are any issues.';

if(mail.getToAddresses()!=null)
{

mail.setHtmlBody(htmlBody);
emailsToSend.add(mail);
}   */
                            
                            
                        }//************* End of send mail to user on submitting BNF if BNF sales_org is not present in Address Sales_org
                    } 
                    
                    // Adding message for line item addresses
                    if(oliList != null && oliList.size() > 0) {
                        Set<String> setAddressSalesOrgs = new Set<String>();
                        
                        for(opportunityLineItem lineItem :  oliList) {
                            if(lineItem.Other_Ship_To_Address__c != null && lineItem.Other_Ship_To_Address__r.Enabled_Sales_Orgs__c != null) {
                                List<String> AddressSalesOrgs= lineItem.Other_Ship_To_Address__r.Enabled_Sales_Orgs__c.split(':'); 
                                setAddressSalesOrgs = new Set<String>();
                                setAddressSalesOrgs.addAll(AddressSalesOrgs);
                                
                                if (setAddressSalesOrgs.contains(cBNF.Sales_Org_Code__c) == false && !alreadyCovered.contains(lineItem.Other_Ship_To_Address__c)) {
                                    //String[] toAddresses = new String[] {MDM_Defines.MdmApprovalEmailAddress};           
                                    //mail.setToAddresses(toAddresses);
                                    sendEmail = true;
                                    mail.setTargetObjectId(mdmUserList[0].Id);
                                    mail.setSaveAsActivity(false);
                                    mail.setSubject('Extend address(es) for Sales Org '+cBNF.Sales_Org_Code__c);   
                                    htmlBody +='<tr><td>Other Ship To : </td><td>'+ lineItem.Other_Ship_To_Address__r.name;       
                                    if(lineItem.Other_Ship_To_Address__r.SAP_Reference__c==null)  
                                        htmlBody+='';
                                    else
                                        htmlBody+='(SAP Code '+lineItem.Other_Ship_To_Address__r.SAP_Reference__c+')';                                                      
                                    htmlBody +='</td></tr>';                                                                          
                                }
                            }
                        }              
                    }      
                    
                    htmlBody += '</table><br/><br/>Please can you extend as appropriate and notify '+bnfMap.get(cBNF.Id).MIBNF__r.Revenue_Analyst__r.User__r.Name+' ('+bnfMap.get(cBNF.Id).MIBNF__r.Revenue_Analyst__r.User__r.Email+') once complete.'+
                        'Please liaise with the local admin if there are any issues.';
                    
                    //if(mail.getToAddresses()!=null)
                    if(sendEmail) {
                        mail.setHtmlBody(htmlBody);
                        emailsToSend.add(mail);
                    }             
                    
                }
            }
            
            
            
            /**********************BNF Metrics Processing Time Calculation Start *****************************************************/
            
            if(Trigger.isUpdate && Trigger.oldMap.get(cBNF.Id).BNF_Status__c != Trigger.newMap.get(cBNF.Id).BNF_Status__c)
            {
                // Static set of userid's belonging to Integration User and Informatica
                Set<Id> Excluded_Users = new Set<Id>{'00570000000sfYqAAI','00570000000sXU2AAM'};
                    Set<Id> User_Id_Set = new Set<Id>();
                // Create a map of user id's by splitting the string into an array
                if(cBNF.BNF_Actor_Ids__c!=null){
                    List<String> Id_Array = cBNF.BNF_Actor_Ids__c.split(';');
                    for (String S:Id_array){
                        User_Id_Set.add(S);
                    }
                }
                // Add BNF creator id if it's not Integration User
                if (!Excluded_Users.contains(cBNF.CreatedById) && !User_Id_Set.contains(cBNF.CreatedById) ){
                    User_Id_Set.add(cBNF.CreatedById);
                    if(cBNF.BNF_Actor_Ids__c==null){
                        cBNF.BNF_Actor_Ids__c= cBNF.CreatedById;
                    }else{
                        cBNF.BNF_Actor_Ids__c= cBNF.BNF_Actor_Ids__c+';'+cBNF.CreatedById;
                    }
                }
                // If actor is not Informatica and UserId is not already in the set
                if( !Excluded_Users.contains(UserInfo.getUserId()) && !User_Id_Set.contains(UserInfo.getUserId())){
                    User_Id_Set.add(UserInfo.getUserId());
                    if(cBNF.BNF_Actor_Ids__c==null){
                        cBNF.BNF_Actor_Ids__c=UserInfo.getUserId();
                    }else{
                        cBNF.BNF_Actor_Ids__c= cBNF.BNF_Actor_Ids__c+';'+UserInfo.getUserId();
                    }
                }
                cBNF.Num_Users_in_Processing__c = User_Id_Set.size();
                system.debug('***************2.0********************'+cBNF.BNF_Status__c + '**********************'+Trigger.oldMap.get(cBNF.Id).BNF_Status__c);
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('SUBMITTED'))
                {
                    
                    if (cBNF.sales_start_date__c == null)
                    {
                        if(Opportunity_Map.get(cBNF.Opportunity_Id__c).Actual_Close_Timestamp__c!=null)
                            cBNF.sales_start_date__c= cBNF.CreatedDate < Opportunity_Map.get(cBNF.Opportunity_Id__c).Actual_Close_Timestamp__c ? Opportunity_Map.get(cBNF.Opportunity_Id__c).Actual_Close_Timestamp__c : cBNF.CreatedDate ; 
                        else
                            cBNF.sales_start_date__c= cBNF.CreatedDate;
                    }
                    
                    if (cBNF.First_Submitter__c == null)
                        cBNF.First_Submitter__c = UserInfo.getUserId();
                    
                    cBNF.sales_end_date__c=system.now();
                    
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(UserInfo.getTimeZone().getID());
                    integer GMTTimeShift=tz.getOffset(cBNF.sales_end_date__c);
                    
                    //calculate sales processing time
                    cBNF.Sales_Processing_Time__c= cBNF.Sales_Processing_Time__c==null ? 0.0 :  cBNF.Sales_Processing_Time__c;
                    cBNF.Sales_Processing_Time__c= Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.sales_end_Date__c,cBNF.sales_start_date__c,GMTTimeShift) + cBNF.Sales_Processing_Time__c;
                    
                    // Submitted to Local RA
                    if (bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
                        (bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
                         bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
                         !String.valueof(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(cBNF.IMS_Sales_org__c)
                        ))
                    {
                        cBNF.LO_Start_Date__c=system.now();
                        cBNF.LO_First_Submission_Date__c= (cBNF.LO_First_Submission_Date__c==null)?system.now():cBNF.LO_First_Submission_Date__c;
                        // Added New
                        cBNF.Submitted_to_LO__c = true;                         
                    }
                    
                    // Proceed as submitted to True RA
                    else
                    {
                        if(cBNF.RA_First_Submission_Date__c==null)
                            cBNF.RA_First_Submission_Date__c=system.now();
                        
                        
                        if(cBNF.Time_to_1st_RA_Submission__c==null)
                        {
                            if(Opportunity_Map.get(cBNF.Opportunity_Id__c).Actual_Close_Timestamp__c!=null)
                            {
                                cBNF.Time_to_1st_RA_Submission__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.RA_First_Submission_Date__c,Opportunity_Map.get(cBNF.Opportunity_Id__c).Actual_Close_Timestamp__c,GMTTimeShift);
                            }
                            else
                                cBNF.Time_to_1st_RA_Submission__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.RA_First_Submission_Date__c,cBNF.CreatedDate,GMTTimeShift);
                            
                        }   
                        cBNF.Final_BNF_RA_First_Submission_Date__c=system.now();
                        cBNF.RA_Start_Date__c=system.now();
                        cBNF.Submitted_to_LO__c = false; 
                    }
                    
                }
                
                
                // When Status is LO Accepted
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'))
                {
                    
                    cBNF.LO_End_Date_c__c=system.now();
                    cBNF.LO_Processing_Time__c= cBNF.LO_Processing_Time__c==null ? 0.0 :  cBNF.LO_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.LO_End_Date_c__c);
                    
                    cBNF.LO_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.LO_End_Date_c__c,cBNF.LO_Start_Date__c,GMTTimeShift) + cBNF.LO_Processing_Time__c;
                    
                    // Proceed as submitted to True RA
                    if(cBNF.RA_First_Submission_Date__c==null)
                        cBNF.RA_First_Submission_Date__c=system.now();
                    
                    if(cBNF.Time_to_1st_RA_Submission__c==null)
                    {
                        cBNF.Time_to_1st_RA_Submission__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.RA_First_Submission_Date__c,Opportunity_Map.get(cBNF.opportunity_id__c).Actual_Close_Timestamp__c,GMTTimeShift);
                        
                    }
                    cBNF.Final_BNF_RA_First_Submission_Date__c=system.now();
                    cBNF.RA_Start_Date__c=system.now();
                }
                
                // When Status is LO Accepted
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('LO_REJECTED'))
                {
                    cBNF.LO_End_Date_c__c=system.now();
                    cBNF.LO_Processing_Time__c= cBNF.LO_Processing_Time__c==null ? 0.0 :  cBNF.LO_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.LO_End_Date_c__c);
                    
                    cBNF.LO_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.LO_End_Date_c__c,cBNF.LO_Start_Date__c,GMTTimeShift) + cBNF.LO_Processing_Time__c;
                    cBNF.Sales_Start_Date__c=SYSTEM.NOW();
                    
                    
                }
                
                // When Status is RO Accepted
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') || cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('ACCEPTED'))
                {
                    cBNF.RA_End_Date__c=system.now();
                    cBNF.RA_Processing_Time__c= cBNF.RA_Processing_Time__c==null ? 0.0 :  cBNF.RA_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.RA_End_Date__c);
                    
                    cBNF.RA_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.RA_End_Date__c,cBNF.RA_Start_Date__c,GMTTimeShift) + cBNF.RA_Processing_Time__c;
                    cBNF.SAP_Start_Date__c=system.now();
                    cBNF.SAP_First_Submission_Date__c=system.now();
                }
                
                // When Status is RO Accepted
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('RA_REJECTED') || cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('REJECTED'))
                {
                    cBNF.RA_End_Date__c=system.now();
                    cBNF.RA_Processing_Time__c= cBNF.RA_Processing_Time__c==null ? 0.0 :  cBNF.RA_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.RA_End_Date__c);
                    
                    cBNF.RA_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.RA_End_Date__c,cBNF.RA_Start_Date__c,GMTTimeShift) + cBNF.RA_Processing_Time__c;
                    cBNF.Sales_Start_Date__c=SYSTEM.NOW();
                }
                
                
                
                // When Status is SAP_CONTRACT_CONFIRMED
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED'))
                {
                    cBNF.SAP_End_Date__c=system.now();
                    cBNF.SAP_Processing_Time__c= cBNF.SAP_Processing_Time__c==null ? 0.0 :  cBNF.SAP_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.SAP_End_Date__c);
                    
                    cBNF.SAP_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.SAP_End_Date__c,cBNF.SAP_Start_Date__c,GMTTimeShift) + cBNF.SAP_Processing_Time__c;
                    cBNF.Time_from_1st_Submission_from_RA_to_SAP__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.SAP_End_Date__c,cBNF.RA_First_Submission_Date__c,GMTTimeShift);
                    cBNF.Final_BNF_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.SAP_End_Date__c,cBNF.Final_BNF_RA_First_Submission_Date__c,GMTTimeShift);
                    
                    // Added by Ritesh Gupta : ER-3208
                    List<OpportunityLineItem> oliListForJson1 = new List<OpportunityLineItem>();
                    List<OpportunityLineItem> oliListForJson2 = new List<OpportunityLineItem>();
                    List<OpportunityLineItem> oliListForJson3 = new List<OpportunityLineItem>();
                    //List<OpportunityLineItem> OLIListToUpdate = OLI_Array_Map.get(cBNF.Opportunity__c);
                    for(OpportunityLineItem oli : oppIdToOliListMap.get(cBNF.Opportunity__c)){
                        if(oliListForJson1.size() < 90)
                            oliListForJson1.add(oli);
                        else if(oliListForJson2.size() < 90)
                            oliListForJson2.add(oli);
                        else
                            oliListForJson3.add(oli);
                        
                        sObject sObj = Schema.getGlobalDescribe().get('OpportunityLineItem').newSObject();
                        sObj.put('Id', String.valueOf(oli.id));
                        if(oliIdToOLISListMap.containsKey(oli.id))
                            sObj.put('OLIS_Json_Data_LAB__c', Json.serialize(oliIdToOLISListMap.get(oli.id)));
                        if(oliIdToBSIListMap.containsKey(oli.id))
                            sObj.put('BSI_Json_Data_LAB__c', Json.serialize(oliIdToBSIListMap.get(oli.id)));
                        UpdateRequired = true;
                        UpdateOLIlst.add((OpportunityLineItem)sObj);
                    }
                    
                    if(oliListForJson1.size() > 0)
                        cBNF.oli_Json_Data_1__c = Json.serialize(oliListForJson1);
                    if(oliListForJson2.size() > 0)
                        cBNF.oli_Json_Data_2__c = Json.serialize(oliListForJson2);
                    if(oliListForJson3.size() > 0)
                        cBNF.oli_Json_Data_3__c = Json.serialize(oliListForJson3);    
                    
                } 
                
                
                // When Status is SAP Contract Rejected
                if(cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') || cBNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED'))
                {
                    cBNF.SAP_End_Date__c=system.now();
                    //cBNF.Final_BNF_RA_First_Submission_Date__c=system.now();
                    cBNF.SAP_Processing_Time__c= cBNF.SAP_Processing_Time__c==null ? 0.0 :  cBNF.SAP_Processing_Time__c;
                    
                    //Calculate Approver timezone shift
                    TimeZone tz = TimeZone.getTimeZone(bnfMap.get(cBNF.id).Comp_Revenue_Analyst__r.User__r.TimeZoneSidKey);
                    integer GMTTimeShift=tz.getOffset(cBNF.SAP_End_Date__c);           
                    
                    cBNF.SAP_Processing_Time__c=Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(cBNF.SAP_End_Date__c,cBNF.SAP_Start_Date__c,GMTTimeShift) + cBNF.SAP_Processing_Time__c;
                    cBNF.RA_Start_Date__c=system.now();
                }
                
            } 
            
            /**********************BNF Metrics Processing Time Calculation End *****************************************************/
            
            
            
        }
        //  BEGIN 2012-01-21 Sam Duncan: Comment out email code to allow deployment of list price validation to PROD  
        if (emailsToSend.size() > 0)
        {
            if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                Messaging.sendEmail(emailsToSend);   
            }
        }
        
        //Added By Himanshu Parashar : MIS Issue-02000 : Update lineitem if no therapy_area specified
        if (UpdateRequired && UpdateOLIlst.size()>0)
        {
            UTL_ExecutionControl.stopTriggerExecution = true;
            update UpdateOLIlst;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }     
    
}