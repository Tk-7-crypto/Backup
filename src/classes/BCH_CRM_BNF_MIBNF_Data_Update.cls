/*
* Author       : Balkrishan Gohil
* Purpose      : Batch to Insert Json Data in BNF/MIBNF Record And Insert OLIS and BSI
*/
global class BCH_CRM_BNF_MIBNF_Data_Update implements Database.Batchable<sObject>,Database.Stateful {
    
    private String query = null;
    private String Objname = null;
    String oliInserterror = '';
    String InsertError = '';
    
    public BCH_CRM_BNF_MIBNF_Data_Update() {        
    }
    
    /*
	* @param String Query - Query Should be Include Id of BNF/MIBNF and Oppertunity__c 
	* @param String Objname - Object Name Either BNF2__c OR MIBNF_Component__c
	*/
    public BCH_CRM_BNF_MIBNF_Data_Update(String query,String Objname) {
        this.query = query;
        this.Objname = Objname;
    }
    /*
	* @param String Objname - Object Name Either BNF2__c OR MIBNF_Component__c
	*/
    public BCH_CRM_BNF_MIBNF_Data_Update(String Objname) {
        this.Objname = Objname;
    }
    
    /*
	* To instantiate the Database.QueryLocator object
	*/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null){
            return Database.getQueryLocator(query);
        }
        else if(Objname != null){
            String tempquery = 'Select Id, Opportunity__c from '+Objname+' where CreatedDate = TODAY AND CreatedBy.Name = '+'\'' + 'CRM DATA MIGRATION' + '\''+' AND BNF_Status__c = '+'\''+'SAP Contract Confirmed'+'\'';            
            return Database.getQueryLocator(tempquery);
        }
        else{
            return Database.getQueryLocator([Select Id, Opportunity__c from BNF2__c where CreatedDate = TODAY AND CreatedBy.Name = 'CRM DATA MIGRATION' AND BNF_Status__c = 'SAP Contract Confirmed']);
        }
    }
    
    /*
	* @params : List<sObject> SobjList  List Of BNF/MIBNF Records
	* This method used to get Id of BNF/MIBNF And process each batch of records
	*/
    global void execute(Database.BatchableContext bc, List<sObject> SobjList) {  
        SavePoint sp = Database.setSavepoint();
        BNF_Settings__c bnfSetting=BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        } 
        Set<id> oppidset = new Set<id>();
        List<sObject> recordToUpdate = new List<sObject>();
        List<OpportunityLineItem> UpdateOLIlst=new List<OpportunityLineItem>();
        for(sObject objlist : SobjList) {
            oppidset.add((id)objlist.get('Opportunity__c')); 
        }
        
        if(!oppidset.isEmpty()){
            
            Map<id,List<OpportunityLineItem>> oppIdToOLIListMap = new Map<id,List<OpportunityLineItem>>();
            Map<id,List<OpportunityLineItemSchedule>> oliIdToOLISListMap = new Map<id,List<OpportunityLineItemSchedule>>();
            Map<id,List<Billing_Schedule_Item__c>> oliIdToBSIListMap = new Map<id,List<Billing_Schedule_Item__c>>();
            
            String query = 'select Id, OpportunityId,Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c , PricebookEntry.Name, Other_Ship_To_SAP_Contact__r.Name ';
            for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
                query += ', ' + f.getFieldPath();
            }
            
            query += ' FROM OpportunityLineItem where Product_Material_Type__c NOT IN (';
            
            for(String exprd : excludedProducts){
                query += '\'' + exprd + '\',';
            }
            query = query.removeEnd(',');
            query += ')';
            query +='AND OpportunityId IN (';
            
            for(Id oppId : oppidset){
                query += '\'' + oppId + '\',';
            }
            
            query = query.removeEnd(',');
            query += ')';
            
            Map<Id, OpportunityLineItem> oliForJsonMap = new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(query));
            List<OpportunityLineItemSchedule> olisList = [Select OpportunityLineItemId, Description, Revenue, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemID IN :oliForJsonMap.keySet()];
            Set<String> oliIdSet = new Set<String>();
            for(OpportunityLineItem oli : oliForJsonMap.values()){
                List<OpportunityLineItem> currentOLIList = new List<OpportunityLineItem>();
                if(oppIdToOLIListMap.containsKey(oli.opportunityId)){
                    currentOLIList = oppIdToOLIListMap.get(oli.opportunityId);
                }
                currentOLIList.add(oliForJsonMap.get(oli.Id));
                oppIdToOLIListMap.put(oli.opportunityId, currentOLIList);
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
            
            for(sObject objlist : SobjList) {
                List<OpportunityLineItem> oliListForJson1 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson2 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson3 = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : oppIdToOLIListMap.get((Id)objlist.get('Opportunity__c'))){
                    if(oliListForJson1.size() < 90)
                        oliListForJson1.add(oli);
                    else if(oliListForJson2.size() < 90)
                        oliListForJson2.add(oli);
                    else
                        oliListForJson3.add(oli);
                    
                    sObject sObj = new OpportunityLineItem();
                    sObj.put('Id', String.valueOf(oli.id));
                    if(oliIdToOLISListMap.containsKey(oli.id))
                        sObj.put('OLIS_Json_Data_LAB__c', Json.serialize(oliIdToOLISListMap.get(oli.id)));
                    if(oliIdToBSIListMap.containsKey(oli.id))
                        sObj.put('BSI_Json_Data_LAB__c', Json.serialize(oliIdToBSIListMap.get(oli.id)));
                    if(!UpdateOLIlst.contains((OpportunityLineItem)sObj)){
                        UpdateOLIlst.add((OpportunityLineItem)sObj);
                    }
                }
                
                if(oliListForJson1.size() > 0)
                    objlist.put('oli_Json_Data_1__c',Json.serialize(oliListForJson1));
                if(oliListForJson2.size() > 0)
                    objlist.put('oli_Json_Data_2__c',Json.serialize(oliListForJson2));
                if(oliListForJson3.size() > 0)
                    objlist.put('oli_Json_Data_3__c',Json.serialize(oliListForJson3));
                
                recordToUpdate.add(objlist); 
            }
            
            if(recordToUpdate.size() > 0) {
                Database.SaveResult[] JsonSaveResult = Database.update(recordToUpdate);
                Database.SaveResult[] OliSaveResult= Database.update(UpdateOLIlst);
                
                if(JsonSaveResult!= Null){
                    for(integer i=0 ; i<JsonSaveResult.size() ;i++){
                        if(!JsonSaveResult.get(i).isSuccess()){
                            Database.Error Err = JsonSaveResult.get(i).getErrors().get(0);
                            String failddml = Err.getMessage();
                            InsertError = JsonSaveResult.get(i).getId() +'  '+failddml + '\n';
                        }
                    }
                }
                
                if(OliSaveResult!= Null){
                    for(integer i=0 ; i<OliSaveResult.size() ;i++){
                        if(!OliSaveResult.get(i).isSuccess()){
                            Database.Error Err = OliSaveResult.get(i).getErrors().get(0);
                            String failddml = Err.getMessage();
                            oliInserterror = OliSaveResult.get(i).getId() +'  '+failddml + '\n';
                        }
                    }
                    
                }
                if(InsertError != '' || oliInserterror != ''){
                    Database.rollback(sp);
                }
            } 
            
        }
    }
    
    /**
	* To send emails on exception. This method is called after all batches are processed.
	*/
    global void finish(Database.BatchableContext BC) {
        if(InsertError != '' || oliInserterror != ''){
            sendErrorMailNotification(InsertError,oliInserterror);
        }
    }
    
    public static void sendErrorMailNotification(String InsertError,String oliInserterror){
        String body = '';
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        BNF_Settings__c bnfSetting=BNF_Settings__c.getInstance();
        List<String> toAddress = new List<String>();
        if(bnfSetting.Revenue_Analyst_Exception_Email__c != null) {
            toAddress = new List<String>(bnfSetting.Revenue_Analyst_Exception_Email__c.split('\\|'));
        }
        if(InsertError != ''){
            body ='Json Data Update Has been Failed on the Below BNF/MIBNF Records :<br><br> '+ InsertError + '<br>';
        }
        if(oliInserterror != ''){
            body ='Line Item Json Data Update has been Failed on Below Records :<br><br> '+ oliInserterror;
        }
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddress;
        message.subject = 'Json Data Update Batch Failed : BCH_CRM_BNF_MIBNF_Data_Update ';
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.MODULE_NAME = 'CRM';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}