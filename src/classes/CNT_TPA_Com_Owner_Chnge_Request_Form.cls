global class CNT_TPA_Com_Owner_Chnge_Request_Form {
    public static TPA_Assigned_TP_Processor__c assignedTPProcessorObj;
    public static Boolean isRunoffSpecificTempComChangeLogic{get; set;}
    public static string ComOwnerEmailID {get; set;}
    Public Static Map<String, TPA_Assigned_TP_Processor__c> assignedTPProUseOffCombMap {get; set;}
    
    
    public String validEmailDomains{
        get{
            if(validEmailDomains == null)
                return UTL_TPA.tpaSetting.Allowed_domain_for_CO__c;
            return validEmailDomains;
        }
        set;
    }
    
    public string getassignedTPProcessorObj(){
        return JSON.serialize(assignedTPProcessorObj);
    }
    

    public static String jsonOfferingList {
        get {
            if(jsonOfferingList == null || jsonOfferingList == '') {
                list<IMS_Data_Asset__c> offeringsList = new list<IMS_Data_Asset__c>();
                offeringsList  = [select id, name, Asset_Name__c, Commercial_Owner_Email__c,Secondary_Commercial_Reviewer_Email__c, (select id,
                        Secondary_Asset_Name__c,
                        Commercial_Manager_Email__c,Secondary_Commercial_Reviewer_Email__c from IMS_Secondary_Data_Assets__r
                 where Is_Active__c = True) from IMS_Data_Asset__c where Is_Active__c = true];
                jsonOfferingList = JSON.serialize(offeringsList);
                system.debug('offeringsList size = ' + offeringsList.size());
                system.debug('jsonOfferingList = ' + jsonOfferingList + 'offeringsList = ' + offeringsList);
            }
            return jsonOfferingList;
        }
        set;
    }
    
    public static String jsonAssignedTPProcessorList {
        get {
            if(jsonAssignedTPProcessorList == null || jsonAssignedTPProcessorList == '') { 
                list<TPA_Assigned_TP_Processor__c> assignedTPProcessorList = new list<TPA_Assigned_TP_Processor__c>();
                assignedTPProcessorList = UTL_TPA.getTemporaryComOwnerListDetails();
                system.debug('assignedTPProcessorList = ' + assignedTPProcessorList);
                jsonAssignedTPProcessorList = JSON.serialize(assignedTPProcessorList);
                system.debug('jsonAssignedTPProcessorList = ' + jsonAssignedTPProcessorList);
            }
            return jsonAssignedTPProcessorList;
        }
        set;
    }
    
    public CNT_TPA_Com_Owner_Chnge_Request_Form (){
        ComOwnerEmailID = ApexPages.currentPage().getParameters().get('CSId');
        // if(ComOwnerEmailID != null){
        //     List<TPA_Assigned_TP_Processor__c> listAssignedTPProcessor= [select id,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c, Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Commercial_Owner_Email__c = :ComOwnerEmailID limit 1];
        //     if(listAssignedTPProcessor != null && listAssignedTPProcessor.size() > 0 ){
        //         assignedTPProcessorObj = listAssignedTPProcessor[0];
        //     }
        // }
        isRunoffSpecificTempComChangeLogic = UTL_TPA.tpaSetting.Enable_off_Specific_Tempo_Commercial_Req__c;
    
       
    }

    @remoteAction
    public static void deleteCurrentRecord(String recordID) {
        String objId = (String)JSON.deserialize(recordID, String.class);
        TPA_Assigned_TP_Processor__c combObj = [select id,Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c,Commercial_Owner_Email__c,Offering_Names__c from TPA_Assigned_TP_Processor__c where id =:objId];
        // TPA_Assigned_TP_Processor__c combObj = new TPA_Assigned_TP_Processor__c(Id = objId);

        try{
            if(combObj != null ){
                Date todayDate = System.now().date();
                Boolean sendEamil = false;
                String comEmailID = '%' + combObj.Commercial_Owner_Email__c + '%';
                Set<Id> reqsSet =  new Set<Id>();
                for(TPA_Commercial_Review__c comObj : [Select Id, TPA_Request__c From TPA_Commercial_Review__c where Receiver_s_Email__c like:comEmailID and TPA_Request__r.Request_Status__c in ('Awaiting Account Mgmt Communication',:UTL_TPA.AWAITING_CLIENT_CONFIRMATION,'Awaiting Client Modification','Awaiting Final Review','In Review By IQVIA','Pending Vendor AMA Fee Acknowledgement','Pending - Vendor Declined AMA Fees','TPA Approved Awaiting AMA Approval','Pending Vendor Response on Data Destruction from Prior TPAs','Hold for TPA non-compliance')]){
                    reqsSet.add(comObj.TPA_Request__c);
                }
                if( reqsSet != null && reqsSet.size() > 0 ){
                    if(combObj.Out_of_Office_Leave_Start_Date__c <= todayDate &&  combObj.Out_of_Office_Leave_End_Date__c >= todayDate){
                        sendEamil = true;
                    }
                    BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review(true,combObj.Commercial_Owner_Email__c,'delete',sendEamil,combObj.Offering_Names__c);
                    bchObj.reqsSet = reqsSet;
                    Database.executeBatch(bchObj,1);
                }
                
                delete combObj;
            }
        }
        catch(Exception e){
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_Com_Owner_Chnge_Request_Form:::delete Record', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    }
    
    @remoteAction
    public static map<String, TPA_Assigned_TP_Processor__c > getJSONAssignedTPProUseOffCombMap(String ComID) {

        assignedTPProUseOffCombMap = new map<String, TPA_Assigned_TP_Processor__c >();
        Date todayDate = System.now().date();
        system.debug('ComID : ' + ComID );
        system.debug('todayDate : ' + todayDate );
        String EmailID = (String)JSON.deserialize(ComID, String.class);
        List<TPA_Assigned_TP_Processor__c> assignedTPProcessorList = [select id, Offering_Names__c,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_End_Date__c >= :todayDate and Commercial_Owner_Email__c = :EmailID];

        for(TPA_Assigned_TP_Processor__c combObj : assignedTPProcessorList) { 
            String key = combObj.Commercial_Owner_Email__c;
            if(combObj.Offering_Names__c != null)
                key += '~' +  combObj.Offering_Names__c;
            assignedTPProUseOffCombMap.put(key, combObj);
        }
        system.debug('assignedTPProUseOffCombMap : ' + assignedTPProUseOffCombMap );
        return assignedTPProUseOffCombMap;     
    }
    
     
    
    @remoteAction
    global static map<String, TPA_Assigned_TP_Processor__c > saveRequest(string TPProcessorObj){
        assignedTPProUseOffCombMap = new map<String, TPA_Assigned_TP_Processor__c >();
        try{
            Type t = Type.forName('TPA_Assigned_TP_Processor__c');
            assignedTPProcessorObj = (TPA_Assigned_TP_Processor__c)JSON.deserialize(TPProcessorObj, t);
            assignedTPProcessorObj.Is_Commercial_Owner__c = true;
            system.debug('assignedTPProcessorObj'+assignedTPProcessorObj);
           // List<TPA_Assigned_TP_Processor__c> assignedTPProcessorList = [select id from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Commercial_Owner_Email__c = :assignedTPProcessorObj.Commercial_Owner_Email__c LIMIT 1];
          //  if(assignedTPProcessorList != null && assignedTPProcessorList.size() > 0){
          //      assignedTPProcessorObj.id = assignedTPProcessorList[0].id;
         //   }
            upsert assignedTPProcessorObj;
    
            Date todayDate = System.now().date();
            if(assignedTPProcessorObj.Out_of_Office_Leave_End_Date__c >=  todayDate){
                Set<Id> reqsSet =  new Set<Id>();
                String comEmailID = '%' + assignedTPProcessorObj.Commercial_Owner_Email__c + '%';
                for(TPA_Commercial_Review__c comObj : [Select Id, TPA_Request__c From TPA_Commercial_Review__c where Receiver_s_Email__c like:comEmailID and TPA_Request__r.Request_Status__c in ('Awaiting Account Mgmt Communication',:UTL_TPA.AWAITING_CLIENT_CONFIRMATION,'Awaiting Client Modification','Awaiting Final Review','In Review By IQVIA','Pending Vendor AMA Fee Acknowledgement','Pending - Vendor Declined AMA Fees','TPA Approved Awaiting AMA Approval','Pending Vendor Response on Data Destruction from Prior TPAs','Hold for TPA non-compliance')]){
                    reqsSet.add(comObj.TPA_Request__c);
                }
                if( reqsSet != null && reqsSet.size() > 0 ){
                    //BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review(true,assignedTPProcessorObj.Commercial_Owner_Email__c);
                    BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review(true,assignedTPProcessorObj.Commercial_Owner_Email__c,'update',false,assignedTPProcessorObj.Offering_Names__c);

                    //bchObj.comEmailID = comEmailID;
                    bchObj.reqsSet = reqsSet;
                    Database.executeBatch(bchObj,1);
                }
            }

            
           
            
    
            sendConfirmationMail(assignedTPProcessorObj);
            List<TPA_Assigned_TP_Processor__c> assignedTPProcessorList = [select id, Offering_Names__c,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_End_Date__c >= :todayDate and Commercial_Owner_Email__c = :assignedTPProcessorObj.Commercial_Owner_Email__c];

            for(TPA_Assigned_TP_Processor__c combObj : assignedTPProcessorList) { 
                String key = '';
                if(combObj.Offering_Names__c != null)
                    key += '~' +  combObj.Offering_Names__c;
                assignedTPProUseOffCombMap.put(key, combObj);
            }
            system.debug('assignedTPProUseOffCombMap : ' + assignedTPProUseOffCombMap );
            
            
        }
        catch(Exception ex){
            system.debug('ERROR: '+ex.getMessage());
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: ' + ex.getLineNumber(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::CNT_TPA_Com_Owner_Change_Request_Form:::saveRequest :: ' + ex.getMessage(), 
                                                '');
        }
       // return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess');
        //return ('success~'+'VFP_TPA_Com_Owner_Change_Request_Form');
        return assignedTPProUseOffCombMap;  

        

    }
    
    public static void sendConfirmationMail(TPA_Assigned_TP_Processor__c assignedTPProcessorObj){
        String templateID;
        
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Confirmation of Comm Owner Temp Change'+'English').Translated_Template_Id__c;
        system.debug('templateID1'+templateID);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {   
            if(assignedTPProcessorObj.Commercial_Owner_Email__c != null) {
                ccAddresses.add(assignedTPProcessorObj.Commercial_Owner_Email__c);
            }
            if(assignedTPProcessorObj.Temporary_Commercial_Owner_Email__c != null) {
                ccAddresses.add(assignedTPProcessorObj.Temporary_Commercial_Owner_Email__c);
            }
            
            try{
                if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                    System.debug('in sendConfirmationMail Email send: ');
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, ccAddresses, 'ConfirmTempChangeOfCO', templateID, assignedTPProcessorObj.Id, null, '', FALSE, '', False, False, null);
                }
            }
            catch(Exception e){
                System.debug('Email Failed: ' + e.getMessage());
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_Com_Owner_Change_Request_Form:::sendConfirmationMail', assignedTPProcessorObj != null ? assignedTPProcessorObj.Id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            }
        }
    }
    
}