global class BCH_TPA_CheckAgreementTLLA implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    
    Boolean isVendorAMAFeeProcess = false; 
    Date todayDate;
    Set<Id> stAllPurposesId = new Set<Id>();
    Set<Id> stAllAssetId = new Set<Id>();
    List<TPA_Data_Asset__c> lstPAssetWithSecAssets = new List<TPA_Data_Asset__c>();
    List<TPA_Purpose__c> lstPurposeWithAssets = new List<TPA_Purpose__c>();
    public static Map<Id,List<TPA_Data_Asset__c>> mapAgreeIdWithAssetList = new Map<Id,List<TPA_Data_Asset__c>>();
    public static Map<Id,List<TPA_Purpose__c>> mapAgreeIdWithPurposeList = new Map<Id,List<TPA_Purpose__c>>();
    public static Map<Id,List<TPA_Data_Asset__c>> mapPurposeIdWithAssetList = new Map<Id,List<TPA_Data_Asset__c>>();
    public static Map<Id,List<TPA_Secondary_Data_Asset__c>> mapAssetIdWithSecAssetList = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
    public static Map<Id,List<IMS_Secondary_Data_Asset__c>> mapIMSPriAssetIdWithIMSSecAssetList = new Map<Id,List<IMS_Secondary_Data_Asset__c>>();
    public static Boolean isOtherOfferingPresent = False; 
    public static Boolean isUseandOfferingNotPresent = false;
    String tllaGenerationError = '';
    TPA_Settings__c tpaSettObj; 
    DateTime currentDateTime; 
    Integer hoursPassedLastCallForTllaInvoked;
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}
    
    global BCH_TPA_CheckAgreementTLLA()    {
        todayDate = Date.today(); 
        tpaSettObj = TPA_Settings__c.getOrgDefaults(); 
        currentDateTime = System.Now(); 
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_CheckAgreementTLLA');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)    {
        System.debug('##in the batch start');
        List<String> templateName = new List<string>{'%TLLA%', '%CPC%'};
            String templateTLLA = '%TLLA%';
        String templateCPC = '%CPC%';
        String templateAMA = '%_AMA_%'; 
        String inReview = Label.TPA_In_Review_By_IMS_Status; 
        String inReviewQI = Label.TPA_In_Review_By_IQVIA_Status;
        String inAuto = 'In Auto Approval Process';
        String inAMAStatus = 'TPA Approved Awaiting AMA Approval';
        String query = 'select id '
            +'from TPA_request__c where (request_status__c = \''+inReview+'\' or request_status__c = \''+inReviewQI+'\' or request_status__c = \''+inAuto+'\' or request_status__c = \''+inAMAStatus+'\') and Service_Provider_Address__c != null and Is_Potential_Vendor_Case__c = false and Client_Address__c != null and ClientContact__c != null AND Stop_TLLA_Generation_Notice_Sent_Date__c = null'  
            +' AND (Client_Address__r.Region_Territory__c != null)';
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        if(Test.isRunningTest()){
            query += ' limit 15';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList)
    {
        System.debug('##in the batch execute');
        Set<Id> stAgreeId = new Set<Id>();
        Set<Id> stGenerateOnlyAMADoc = new Set<Id>();
        List<TPA_request__c> lstRequests = new List<TPA_Request__c>();
        
        List<TPA_Request__c> lstRequestforWhichTLLAGenErrNoticeSent = new List<TPA_Request__c>();
        List<TPA_Data_Asset__c> lstOfDataAsset = new List<TPA_Data_Asset__c>();
        List<TPA_Request__c> reqObjList = new List<TPA_Request__c>();
        Set<String> tpaReqIdSet = new Set<String>();
        
        for(sobject sobj : objList){
            TPA_Request__c objRequest = (TPA_Request__c)sobj ;
            tpaReqIdSet.add(sobj.Id);
        }
        
        String templateTLLA = '%TLLA%';
        String templateCPC = '%CPC%';
        String templateAMA = '%_AMA_%'; 
        String inReview = Label.TPA_In_Review_By_IMS_Status; 
        String inReviewQI = Label.TPA_In_Review_By_IQVIA_Status;
        String inAuto = 'In Auto Approval Process';
        String inAMAStatus = 'TPA Approved Awaiting AMA Approval';
        String query = 'select id,Pending_Acknowledgements__c,Generate_AMA_Contract__c,TPA_Ad_Hoc_Term_Last_Update__c,TPA_Approved_Awaiting_AMA_Approval__c,In_Auto_Approval_Process__c,In_IMS_Review__c,Request_Status__c,Requires_Manual_Review__c, LastAction__c, name, Data_Access_Start_Date__c, Data_Access_End_Date__c, Data_Period_Start_Date__c, Data_Period_End_Date__c, Client_Address__c, ClientContact__c, Stop_TLLA_Generation_Notice_Sent_Date__c, TLLA_Batch_Call_Sent_On__c, isbatchprocessing__c, Client_Address__r.Country__c , Client_Address__r.Region_Territory__c, ' // Modified by C.P.Pandey under CR-11832 //Modified by Neha bansal under CR-12286
            +'(select id,name,createddate from Attachments where name like \''+templateTLLA+'\' or name like \''+templateCPC+'\' or name like \''+templateAMA+'\' order by CreatedDate desc limit 10),'
            +'(Select id, Contract_Type__c, Is_AMA_License_Required__c, AMA_Manual_Review__c, Template__c, Vendor_AMA_Fee_Response__c from AMA_Agreement_Details__r limit 1) '
            + ', (select id from IMS_Legal_Entities__r)'
            +'from TPA_request__c where (request_status__c = \''+inReview+'\' or request_status__c = \''+inReviewQI+'\' or request_status__c = \''+inAuto+'\' or request_status__c = \''+inAMAStatus+'\') and Service_Provider_Address__c != null and Is_Potential_Vendor_Case__c = false and Client_Address__c != null and ClientContact__c != null AND Stop_TLLA_Generation_Notice_Sent_Date__c = null'  
            +' AND (Client_Address__r.Region_Territory__c != null) AND Id In :tpaReqIdSet';
        if(Test.isRunningTest()){
            query += ' limit 15';
        }
        reqObjList = Database.query(query);

        List<String> toAddress = new List<String>();
        
        for(TPA_Request__c agrmnt : reqObjList){
            isVendorAMAFeeProcess = false; 
            if(tpaSettObj != null && tpaSettObj.TPA_Batch_to_Attempt_TLLA_Call_Duration__c != null && agrmnt.isbatchprocessing__c && agrmnt.TLLA_Batch_Call_Sent_On__c != null) {
                hoursPassedLastCallForTllaInvoked = integer.valueOf(Math.Floor((currentDateTime.getTime() - agrmnt.TLLA_Batch_Call_Sent_On__c.getTime()) / (1000.0*60.0)));
                if(hoursPassedLastCallForTllaInvoked < tpaSettObj.TPA_Batch_to_Attempt_TLLA_Call_Duration__c) {
                    continue;
                }
            }
            
            if(!agrmnt.AMA_Agreement_Details__r.isEmpty() && String.isNotBlank(agrmnt.AMA_Agreement_Details__r.get(0).Vendor_AMA_Fee_Response__c) ){
                isVendorAMAFeeProcess = true;
            }
            
            
            if (agrmnt.Attachments.size() == 0){
                stAgreeId.add(agrmnt.id);
            }
            else if(agrmnt.In_Auto_Approval_Process__c != null && checkDate(agrmnt.In_Auto_Approval_Process__c , agrmnt.In_IMS_Review__c)
            && checkDate(agrmnt.In_Auto_Approval_Process__c,agrmnt.TPA_Approved_Awaiting_AMA_Approval__c) && checkDate(agrmnt.In_Auto_Approval_Process__c,agrmnt.TPA_Ad_Hoc_Term_Last_Update__c)
            && checkDate(agrmnt.In_Auto_Approval_Process__c,agrmnt.Attachments[0].CreatedDate)){
                stAgreeId.add(agrmnt.id);
            }
            else if(agrmnt.In_IMS_Review__c != null && checkDate(agrmnt.In_IMS_Review__c,agrmnt.TPA_Approved_Awaiting_AMA_Approval__c) 
            && checkDate(agrmnt.In_IMS_Review__c,agrmnt.TPA_Ad_Hoc_Term_Last_Update__c) && checkDate(agrmnt.In_IMS_Review__c,agrmnt.Attachments[0].CreatedDate)){
                stAgreeId.add(agrmnt.id);
            }
            else if(agrmnt.TPA_Approved_Awaiting_AMA_Approval__c != null && checkDate(agrmnt.TPA_Approved_Awaiting_AMA_Approval__c,agrmnt.TPA_Ad_Hoc_Term_Last_Update__c)
            && checkDate(agrmnt.TPA_Approved_Awaiting_AMA_Approval__c,agrmnt.Attachments[0].CreatedDate)){
                stAgreeId.add(agrmnt.id);
            }
            else if(agrmnt.TPA_Ad_Hoc_Term_Last_Update__c != null && ( checkDate(agrmnt.TPA_Ad_Hoc_Term_Last_Update__c,agrmnt.Attachments[0].CreatedDate) || (agrmnt.Pending_Acknowledgements__c != null && agrmnt.Pending_Acknowledgements__c.contains('TLLA Generation Pending after Ad-Hoc Terms update')))){
                stAgreeId.add(agrmnt.id);
            }
            else if(agrmnt.Generate_AMA_Contract__c){
                stAgreeId.add(agrmnt.id);
                stGenerateOnlyAMADoc.add(agrmnt.id);
            }
            //*** Modified by Govind under Issue 8033 End ***//
        }

        lstPAssetWithSecAssets = [select id,name,IMSLegalEntity__c,Data_Asset__c, Data_Asset__r.Geo_Level__c,Request__r.id,(select id,Secondary_Asset_Name__c,IMS_Legal_Entity__c,IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where Request__c In :stAgreeId];
        lstPurposeWithAssets = [select id,name,Request__r.id, Purpose__r.Primary_Purpose_Name__c, TPA_Purpose_Category__r.Category_Name__c, All_Data_Assets__c, (select id,Geo_Level__c,Data_Asset__c,Data_Asset__r.id, IMSLegalEntity__c,Asset_NametText__c,Asset_Name__c,Data_Asset__r.Geo_Level__c from Purpose_Data_Assets__r) from TPA_Purpose__c where Request__c In :stAgreeId ];

        for(TPA_Data_Asset__c dataAssetobj : lstPAssetWithSecAssets){
          
            stAllAssetId.add(dataAssetobj.id);
            if(!mapAgreeIdWithAssetList.containsKey(dataAssetobj.Request__r.id)) {
                mapAgreeIdWithAssetList.put(dataAssetobj.Request__r.id, new list<TPA_Data_Asset__c>{dataAssetobj});
            } else {
                mapAgreeIdWithAssetList.get(dataAssetobj.Request__r.id).add(dataAssetobj);
            }
        }
        

        
        for(TPA_Purpose__c tPAPurposeobj : lstPurposeWithAssets){
            stAllPurposesId.add(tPAPurposeobj.id);
            if(!mapAgreeIdWithPurposeList.containsKey(tPAPurposeobj.Request__r.id)) {
                mapAgreeIdWithPurposeList.put(tPAPurposeobj.Request__r.id, new list<TPA_Purpose__c>{tPAPurposeobj});
            } else {
                mapAgreeIdWithPurposeList.get(tPAPurposeobj.Request__r.id).add(tPAPurposeobj);
            }
        }
        
        
        
        //lstPurposeWithAssets = [select id,name,(select id,Geo_Level__c,Data_Asset__c,Data_Asset__r.id, IMSLegalEntity__c,Asset_NametText__c,Asset_Name__c,Data_Asset__r.Geo_Level__c from Purpose_Data_Assets__r) from TPA_Purpose__c where id in: stAllPurposesId ];
        //lstPAssetWithSecAssets = [select id,name,IMSLegalEntity__c,Data_Asset__c, Data_Asset__r.Geo_Level__c,(select id,Secondary_Asset_Name__c,IMS_Legal_Entity__c,IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where id in: stAllAssetId];
        
        for(TPA_Purpose__c objPurpose : lstPurposeWithAssets){
            mapPurposeIdWithAssetList.put(objPurpose.id,objPurpose.Purpose_Data_Assets__r);
        }
        
        for(TPA_Data_Asset__c objAsset : lstPAssetWithSecAssets){
            mapAssetIdWithSecAssetList.put(objAsset.id,objAsset.TPA_Secondary_Data_Assets__r);
        }
        
        for(IMS_Data_Asset__c IMSAssetObj : [Select Asset_Name__c, (select id from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c]){
            mapIMSPriAssetIdWithIMSSecAssetList.put(IMSAssetObj.id, IMSAssetObj.IMS_Secondary_Data_Assets__r);
        }
        
        lstRequests = [select id,TPA_Approved_Awaiting_AMA_Approval__c,Generate_AMA_Contract__c,In_Auto_Approval_Process__c, 
                       In_IMS_Review__c,Request_Status__c,Requires_Manual_Review__c, LastAction__c, name, 
                       Data_Access_Start_Date__c, Data_Access_End_Date__c, Data_Period_Start_Date__c, 
                       Data_Period_End_Date__c, Client_Address__c, ClientContact__c, Stop_TLLA_Generation_Notice_Sent_Date__c, 
                       TLLA_Batch_Call_Sent_On__c, isbatchprocessing__c, Client_Address__r.Country__c , 
                       Client_Address__r.Region_Territory__c, (Select id, Contract_Type__c, Is_AMA_License_Required__c, 
                                                               AMA_Manual_Review__c, Template__c, Vendor_AMA_Fee_Response__c from AMA_Agreement_Details__r limit 1) ,
                       (select id from IMS_Legal_Entities__r) from TPA_request__c where id in: stAgreeId]; 
        List<Task> lstTaskInsert = new List<Task>();
        for(TPA_request__c req: lstRequests)
        {   
            tllaGenerationError = CheckDiscrReasonOfOfferingandUse(req, 'Batch', mapAgreeIdWithPurposeList.get(req.id)); 
            QBL_TPA_AsyncGenerateDoc asyncGenerateDocCall= new QBL_TPA_AsyncGenerateDoc();
            asyncGenerateDocCall.requestId = req.Id ;
            asyncGenerateDocCall.GUID = UTL_LogFactory.GUID;
            asyncGenerateDocCall.generateAMADoc = (req.Generate_AMA_Contract__c && stGenerateOnlyAMADoc.contains(req.Id));
            if(!Test.isRunningTest() && tllaGenerationError == '') 
                System.enqueueJob(asyncGenerateDocCall);
            
            if(tllaGenerationError != '') {
                TPA_Request__c objRequest = new TPA_request__c(id=req.id);
                objRequest.Stop_TLLA_Generation_Notice_Sent_Date__c = todayDate;
                lstRequestforWhichTLLAGenErrNoticeSent.add(objRequest);
                stopTLLAGenerationNotice(req.id, toAddress, TPA_Settings__c.getOrgDefaults().Stop_TLLA_Generation_Notice_Id__c, tllaGenerationError, 'Batch');//Modified by Rajendra under ER-3550
            }
            else
            {
                //TODO
                //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Success'; //Added by govind under ER-3039
                //TPAQueryHelper.setLogObject(req.id, 'Success:TLLA Generation Call Sent ',''); //Added by govind under ER-3039
                //TPAQueryHelper.logRef().generateLog();  
                req.Generate_AMA_Contract__c = false;
                req.isbatchProcessing__c = true;
                req.TLLA_Batch_Call_Sent_On__c = System.Now(); 
                req.TPA_Request_Temporary_Status__c = 'In Batch Process';
                req.Previous_Status_If_In_Batch_Process__c = req.Request_Status__c; 
                Task t1 = new Task( WhatId = req.id, ActivityDate = system.today(), Status = 'Completed',
                                   Subject = 'Status Changes to In Batch Process', CallObject = 'Status Changes to In Batch Process' );
                lstTaskInsert.add(t1);
            }
            
            
        }
        if(lstRequests.size() > 0)
            update lstRequests;
        if(lstTaskInsert.size() > 0 )
            upsert lstTaskInsert;
        if(lstRequestforWhichTLLAGenErrNoticeSent.size() > 0){ 
            update lstRequestforWhichTLLAGenErrNoticeSent; 
        } 
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }

    public static Boolean checkDate(DateTime refDate,DateTime dateToCheck){
        if(dateToCheck == null || refDate > dateToCheck){
            return true;
        }
        return false;
    }
    
    
    public static String CheckDiscrReasonOfOfferingandUse(TPA_request__c agg, String context,  list<TPA_Purpose__c> lstAllPurposes){//Modified by Rajendra under ER-3550
        String DisReason = '';
        Boolean isDiscrepancyExist = false ;
        String discrReasonOfLegalEntity = '' ;
        Boolean isOtherOffExist = false ;
        Boolean isLegalEntityMappedInOtherOff = true ;
        isOtherOfferingPresent = False; 
        system.debug('in CheckDiscrReasonOfOfferingandUse');
        Boolean isOnlyReferenceDataCatSelected = true;
        if(lstAllPurposes != null && lstAllPurposes.size() != 0){
            for(TPA_Purpose__c purposeObj : lstAllPurposes)
            {
                List<TPA_Data_Asset__c> lstPri = mapPurposeIdWithAssetList.get(purposeObj.Id);
                if((lstPri == null || lstPri.size() == 0) && context != 'Client'){//Modified by Rajendra under ER-3550
                    isDiscrepancyExist = true;
                    isUseandOfferingNotPresent = true;
                }
                if(lstPri != null && lstPri.size() > 0){
                    for(TPA_Data_Asset__c tpaDataAssetSO : lstPri){
                        if(tpaDataAssetSO.Data_Asset__r.Geo_Level__c != 'Reference Data') {
                            isOnlyReferenceDataCatSelected = false;
                        }
                        if(tpaDataAssetSO.Asset_Name__c == 'Other' && context != 'Client' && tpaDataAssetSO.IMSLegalEntity__c == null)
                            isLegalEntityMappedInOtherOff = false ;
                        if(mapIMSPriAssetIdWithIMSSecAssetList.get(tpaDataAssetSO.Data_Asset__r.id) != null && mapIMSPriAssetIdWithIMSSecAssetList.get(tpaDataAssetSO.Data_Asset__r.id).size() > 0){
                            List<TPA_Secondary_Data_Asset__c> lstSec = mapAssetIdWithSecAssetList.get(tpaDataAssetSO.id);
                            if(lstSec == null || lstSec.size() == 0){
                                isDiscrepancyExist = true;
                                isUseandOfferingNotPresent = true;
                                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, 
                                                                                                   FALSE, 
                                                                                                   UTL_LogFactory.GUID, 
                                                                                                   'Request Details::2:: ' +mapIMSPriAssetIdWithIMSSecAssetList.get(tpaDataAssetSO.Data_Asset__r.id) +'TPA Secondary Data Assets:: lstSec::'+ lstSec +'isDiscrepancyExist:: '+isDiscrepancyExist, 
                                                                                                   'TPA', 
                                                                                                   'Custom', 
                                                                                                   'INFO', 
                                                                                                   'Line#' + ':::BCH_TPA_CheckAgreementTLLA:::CheckDiscrReasonOfOfferingandUse::TPA Secondary Data Assets:: lstSec::', 
                                                                                                   (agg.id != null) ? agg.id : ''));
                            }
                            else{
                                for(TPA_Secondary_Data_Asset__c tpaSecDataAssetSO : lstSec)
                                    if(tpaSecDataAssetSO.IMS_Legal_Entity__c == null && agg.IMS_Legal_Entities__r != null && agg.IMS_Legal_Entities__r.size() > 0){
                                        discrReasonOfLegalEntity += tpaSecDataAssetSO.Secondary_Asset_Name__c +', ';
                                    }
                            }
                        }
                        else if(((tpaDataAssetSO.Asset_Name__c != 'Other' && context == 'Client') || context != 'Client') && tpaDataAssetSO.IMSLegalEntity__c == null && agg.IMS_Legal_Entities__r != null && agg.IMS_Legal_Entities__r.size() > 0){ 
                            discrReasonOfLegalEntity += tpaDataAssetSO.Asset_Name__c +', ';
                        }
                    }
                }
                else{
                    isDiscrepancyExist = true;
                    //isOnlyOtherOffExist = false ;
                }
            }
        }
        
        if(lstAllPurposes == null || lstAllPurposes.size() == 0){
            //isOnlyOtherOffExist = false ;
            isUseandOfferingNotPresent = true;
            system.debug('in CheckDiscrReasonOfOfferingandUse 7');
        }
        
        if( agg.Data_Access_Start_Date__c == null 
           || agg.Data_Access_End_Date__c == null 
           || ((agg.Data_Period_Start_Date__c == null || agg.Data_Period_End_Date__c == null) && !isOnlyReferenceDataCatSelected)){
               
               if(context == 'Client'){
                   DisReason += 'Dates are not populated on Agreement. ';
               }else{
                   DisReason += 'Dates are not rendered on TLLA and TLLA is not generated. ';
               }
               UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, 
                                                                                  FALSE, 
                                                                                  UTL_LogFactory.GUID, 
                                                                                  'Request Details::4:: ' +agg.Data_Access_Start_Date__c +' '+ agg.Data_Access_End_Date__c +' '+agg.Data_Period_Start_Date__c +' '+agg.Data_Period_End_Date__c +'isOnlyReferenceDataCatSelected:: '+isOnlyReferenceDataCatSelected +'context:: '+context +'DisReason:: '+DisReason, 
                                                                                  'TPA', 
                                                                                  'Custom', 
                                                                                  'INFO', 
                                                                                  'Line#' + ':::BCH_TPA_CheckAgreementTLLA:::CheckDiscrReasonOfOfferingandUse::Date fields::', 
                                                                                  (agg.id != null) ? agg.id : ''));
               return DisReason;
           }
        
        if((agg.IMS_Legal_Entities__r == null || agg.IMS_Legal_Entities__r.size() == 0 || discrReasonOfLegalEntity != '') ){
            
            if(isLegalEntityMappedInOtherOff){
                DisReason += 'Legal Entity are not available on Request and/or Data Asset level. ';
            }else if(context != 'Client'){
                isOtherOfferingPresent = true; 
                DisReason += 'The client has selected Other instead of selecting an offering from Drop down.  Please investigate if the information listed in Other is a valid Offering and if so, please contact your TPA Support Team  for guidance on how to map the legal entity to this request.  If this is not a valid offering, please contact the client to have them edit the request and select a valid offering from  the drop down. ';
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, 
                                                                               FALSE, 
                                                                               UTL_LogFactory.GUID, 
                                                                               'Request Details::5::' +agg.IMS_Legal_Entities__r +'discrReasonOfLegalEntity:: '+ discrReasonOfLegalEntity +'context:: '+context +'isOtherOffExist:: '+isOtherOffExist +'isOtherOfferingPresent:: '+isOtherOfferingPresent +'DisReason:: '+DisReason, 
                                                                               'TPA', 
                                                                               'Custom', 
                                                                               'INFO', 
                                                                               'Line#' + ':::BCH_TPA_CheckAgreementTLLA:::CheckDiscrReasonOfOfferingandUse::Date fields::', 
                                                                               (agg.id != null) ? agg.id : ''));
        }
        
        if(mapAgreeIdWithAssetList.get(agg.id) == null || mapAgreeIdWithAssetList.get(agg.id).size() == 0 || isDiscrepancyExist ){
            
            if(context == 'Client'){
                DisReason += 'USE and/or Offerings are not proper for Agreement. ';
            }else{
                DisReason += 'USE and/or Offerings are not rendered on TLLA and TLLA is not generated. ';
            }
            
            system.debug('in CheckDiscrReasonOfOfferingandUse 8');
            try {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, 
                                                                                   FALSE, 
                                                                                   UTL_LogFactory.GUID, 
                                                                                   'Request Details::6:: ' + mapAgreeIdWithAssetList.get(agg.id) +' '+mapAgreeIdWithAssetList.get(agg.id).size() +' '+agg.Purposes__r +' '+agg.Purposes__r.size() +'context:: '+context +'isDiscrepancyExist:: '+isDiscrepancyExist +'DisReason:: '+DisReason, 
                                                                                   'TPA', 
                                                                                   'Custom', 
                                                                                   'INFO', 
                                                                                   'Line#' + ':::BCH_TPA_CheckAgreementTLLA:::CheckDiscrReasonOfOfferingandUse:::USE and/or Offerings::', 
                                                                                   (agg.id != null) ? agg.id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);
            }catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_CheckAgreementTLLA:::CheckDiscrReasonOfOfferingandUse::Exception', (agg.id != null) ? agg.id : ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);
                System.debug(e.getMessage());
            }
        }
        return DisReason ;
    }
    
    public static void stopTLLAGenerationNotice(Id templateContextId, List<string> toRecipients, String templateId, String tllaErrorMsg, String context)//Modified by Rajendra under ER-3550
    {
        TPA_Request__c reqObj = [Select id, name, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where id = :templateContextId];
        try
        {
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            List<String> ccList = new List<String>();
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            try
            {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, templateContextId);
            }
            catch(Exception e)
            {
                System.debug('Email Failed: ' + e.getMessage());
            }
            List<String> ccTo = new List<String>();
            if(isUseandOfferingNotPresent && String.isNotBlank(UTL_TPA.tpaSetting.TPA_QA_and_Admin_Email_Ids__c)) {
                toRecipients =  UTL_TPA.tpaSetting.TPA_QA_and_Admin_Email_Ids__c.split(';');
            }
            if(!isUseandOfferingNotPresent && reqObj.TP_Processor_Email__c != null && reqObj.TP_Processor_Email__c != '') {
                toRecipients.add(reqObj.TP_Processor_Email__c);
            }
            
            string strSubject = '';
            if(context == 'Client') {
                strSubject = emailNotToSend.getSubject().replace('USE and/or Offerings are not rendered on TLLA and TLLA is not generated', 'Client submission got corrupted.');
            }else {
                if(isOtherOfferingPresent) {
                    strSubject = emailNotToSend.getSubject().replace('USE and/or Offerings are not rendered on TLLA and TLLA is not generated', 'Offering_Equals_Other_ Please Research');
                }
                else {
                    strSubject = emailNotToSend.getSubject();
                }                
            }
            String strContent = SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody().replace('TLLAGenerationError', '<div style="font-size:13px;font-family:arial;">' + tllaErrorMsg + '</div>'));
            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c){
               SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccTo, 'otherOfferingEmail', null, templateContextId, null, strSubject, FALSE, strContent, TRUE, TRUE, reqObj); 
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            
        }
        catch(System.EmailException emlEx)
        {
            System.debug('Email Failed: ' + emlEx);
            //TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(templateContextId , 'Exception: Stop TLLA Generation Notice NOT Sent ', emlEx.getMessage()+'*'+emlEx.getLineNumber());
            //TPAQueryHelper.logRef().generateLog();
        }
        catch(Exception e)
        {
            System.debug('An exception occurred: ' + e.getMessage());
            //TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(templateContextId , 'Exception: Stop TLLA Generation Notice NOT Sent ', e.getMessage()+'*'+e.getLineNumber());
            //TPAQueryHelper.logRef().generateLog(); 
        }
    }
}
