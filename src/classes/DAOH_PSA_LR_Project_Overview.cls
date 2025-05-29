/**
* This is LR Project Overview trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_LR_Project_Overview {
    
    private static List<PSA_Event__c> psaEvents;
    private static Set<String> eventDateFields;
    private static Map<String, PSA_Event__c> dateFieldToPSAEventMap;
    private static Map<Id, PSA_Event__c> psaIdToPsaEventMap;
    private static Set<String> lRProjectOverviewFields;
    public static void setLRFieldValues(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        for(LR_Project_Overview__c lrRec : newList){
            if(lrRec.Aggregate_Reports__c == 'Yes' && 
               ((trigger.isInsert && lrRec.DLP_Enter_only_for_Aggregate_Reports__c != null) 
                || (trigger.isUpdate && lrRec.DLP_Enter_only_for_Aggregate_Reports__c != Null && lrRec.DLP_Enter_only_for_Aggregate_Reports__c != oldMap.get(lrRec.Id).DLP_Enter_only_for_Aggregate_Reports__c))){
                    if((trigger.isInsert && lrRec.LR_LBI_Period_Start_Date__c == null) || 
                       (trigger.isUpdate && lrRec.LR_LBI_Period_Start_Date__c == oldMap.get(lrRec.Id).LR_LBI_Period_Start_Date__c)){
                           lrRec.LR_LBI_Period_Start_Date__c = lrRec.DLP_Enter_only_for_Aggregate_Reports__c.addDays(1);
                       }
                    if((trigger.isInsert && lrRec.LR_LBI_Period_Stop_Date__c == null) || 
                       (trigger.isUpdate && lrRec.LR_LBI_Period_Stop_Date__c == oldMap.get(lrRec.Id).LR_LBI_Period_Stop_Date__c)){
                           lrRec.LR_LBI_Period_Stop_Date__c = lrRec.DLP_Enter_only_for_Aggregate_Reports__c.addDays(30);                        
                       }                    
                }
            if((trigger.isInsert && lrRec.Full_Text_Articles_Reviewed__c != null) 
               || (trigger.isUpdate && lrRec.Full_Text_Articles_Reviewed__c != Null && lrRec.Full_Text_Articles_Reviewed__c != oldMap.get(lrRec.Id).Full_Text_Articles_Reviewed__c)){
                   if((trigger.isInsert && lrRec.Full_Text_Articles_ordered__c == null) || 
                      (trigger.isUpdate && lrRec.Full_Text_Articles_ordered__c == oldMap.get(lrRec.Id).Full_Text_Articles_ordered__c)){
                          lrRec.Full_Text_Articles_ordered__c = lrRec.Full_Text_Articles_Reviewed__c;
                      }
               }
        }
    }
    
    /*
    *  IQVIAPSA-4789
    */    
    public static void cfiMeetingUpdateFromLR( List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap ){
        Set<String> lrProjectOverviewIdSet = new Set<String>();
        List< CFI_Meetings__c> cfiMeetingUpdateList = new List< CFI_Meetings__c>();
        Map< Id, LR_Project_Overview__c> lRIdToLRProjectOverviewMap = new Map< Id, LR_Project_Overview__c>();
        for(LR_Project_Overview__c lrRec : newList){
            if( trigger.isUpdate 
               && ( lrRec.Account__c != oldMap.get( lrRec.Id ).Account__c
                   || lrRec.Project__c != oldMap.get( lrRec.Id ).Project__c
                   || lrRec.Product__c != oldMap.get( lrRec.Id ).Product__c
                  ) ){
                      lrProjectOverviewIdSet.add( lrRec.Id );
                      lRIdToLRProjectOverviewMap.put( lrRec.Id, lrRec );
                  }
        }
        
        for( CFI_Meetings__c cf : new SLT_CFI_Meetings(false,false).getCFIMeetingsBylRProjectOverViewIds( lrProjectOverviewIdSet, new Set<String>{'Id','Account__c','Project__c','Products__c','LR_Project_Overview__c'} ) )
        {
            if(lRIdToLRProjectOverviewMap.containsKey(cf.LR_Project_Overview__c) &&  lRIdToLRProjectOverviewMap.get( cf.LR_Project_Overview__c ) != null){
                cf.Account__c = lRIdToLRProjectOverviewMap.get( cf.LR_Project_Overview__c ).Account__c;  
                cf.Products__c = lRIdToLRProjectOverviewMap.get( cf.LR_Project_Overview__c ).Product__c;
                cf.Project__c = lRIdToLRProjectOverviewMap.get( cf.LR_Project_Overview__c ).Project__c;
                cfiMeetingUpdateList.add( cf );
            }
        }
        
        if( cfiMeetingUpdateList.size() > 0 ){
            update cfiMeetingUpdateList;
        }
    }
    
   /*
    *  IQVIAPSA-4580
    */    
    public static void validedFieldOnCompletion(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List< LR_Project_Overview__c > lrProjectOverviewList = new List< LR_Project_Overview__c >();
        Boolean statusFlag = true;
        for(LR_Project_Overview__c lr : newList){
            if(lr.Status__c != null 
                && lr.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED 
                && (trigger.isInsert)){
                lrProjectOverviewList.add( lr );
            }
            if(Trigger.isUpdate){
                if(oldMap.get(lr.Id).Status__c != CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED){
                    statusFlag = true;
                }else{
                    statusFlag = false;
                }
            }
        }
        if(mulesoftSetting != null && mulesoftSetting.Ignore_Validation_Rules__c == FALSE && lrProjectOverviewList.size() > 0){
            if(Trigger.isUpdate){
                UTL_PSA_ValidationMessage.addErrorAndGenerate(true, 'LR_Project_Overview__c', true, lrProjectOverviewList, statusFlag);  
            }else{
                UTL_PSA_ValidationMessage.addErrorAndGenerate(true, 'LR_Project_Overview__c', false, lrProjectOverviewList, statusFlag);   
            }
        }
    }
    
    /*
    *  IQVIAPSA-4535
    */
    public static void cloneLrRecordsWhenStatusCompleted( List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap ){
        List<LR_Project_Overview__c> cloneRecList = new List<LR_Project_Overview__c>();   
        for( LR_Project_Overview__c lrRec : newList ){
            if(lrRec.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED  && lrRec.Status__c != oldMap.get(lrRec.id).Status__c){
                LR_Project_Overview__c cloneLrRecord = new LR_Project_Overview__c();
                cloneLrRecord.Status__c = CON_PSA.LR_PROJECT_REVIEW_STATUS_ASSIGNED;
                cloneLrRecord.Cancelled_Reason__c = lrRec.Cancelled_Reason__c;
                cloneLrRecord.Countries__c = lrRec.Countries__c;
                cloneLrRecord.Project__c = lrRec.Project__c;
                cloneLrRecord.Product__c = lrRec.Product__c;
                cloneLrRecord.Program__c = lrRec.Program__c;
                cloneLrRecord.Legacy_ID__c = lrRec.Legacy_ID__c;
                cloneLrRecord.LR_Type__c = lrRec.LR_Type__c;
                cloneLrRecord.Clone_on_Complete_Status__c = true;
                if(cloneLrRecord.LR_Type__c == CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_GLOBAL){
                    cloneLrRecord.Aggregate_Reports__c = CON_PSA.LR_PROJECT_OVERVIEW_AGG_REP_NA ;
                }else{
                     cloneLrRecord.Aggregate_Reports__c = null ;
                }
                cloneLrRecord.LR_Database__c = lrRec.LR_Database__c;
                cloneLrRecord.LR_Documents_Storage__c = lrRec.LR_Documents_Storage__c;
                cloneLrRecord.LR_Review_Period_Frequency__c = lrRec.LR_Review_Period_Frequency__c;
                cloneLrRecord.Other_LR_Cancellation_reason_Specify__c = lrRec.Other_LR_Cancellation_reason_Specify__c;
                cloneLrRecord.Account__c = lrRec.Account__c;
                cloneLrRecord.Other_LR_Type_Specify__c = lrRec.Other_LR_Type_Specify__c;
                cloneLrRecord.IQVIA_Client_Email__c = lrRec.IQVIA_Client_Email__c;
                cloneLrRecord.Other_LR_Documents_Storage_Specify__c = lrRec.Other_LR_Documents_Storage_Specify__c;
                cloneLrRecord.Other_LR_Database_Specify__c = lrRec.Other_LR_Database_Specify__c;
                cloneLrRecord.Other_LR_Review_Period_Frequency__c = lrRec.Other_LR_Review_Period_Frequency__c;
                cloneLrRecord.Search_Strategy_Created__c = lrRec.Search_Strategy_Created__c;
                cloneRecList.add(cloneLrRecord);
            }
        }
        if(cloneRecList.size() > 0){
            insert cloneRecList;
        }        
    }
    
    //IQVIAPSA-4970
    public static void copyInArchiveWhenLRStatusCompleteAndCancelled(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        Set<Id> lrIdInRelationRecordSet = new Set<Id>();
        Set<Id> lrIdForSsSet = new Set<Id>();
        Set<Id> lrIdforEjSet = new Set<Id>();
        List<LR_Project_Overview__c> localLrProjectOverviewList = new List<LR_Project_Overview__c>();
        List<Archive_Search_Strategy__c> archiveSearchStrategyInsertList = new List<Archive_Search_Strategy__c>();
        List<Archive_Event_Journal__c> archiveEventJournalInsertList = new List<Archive_Event_Journal__c>();
        
        for(LR_Project_Overview__c lrRec : newList ){
            if((lrRec.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED || lrRec.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED ) 
               && lrRec.Status__c != oldMap.get(lrRec.id).Status__c){
                   lrIdforEjSet.add(lrRec.Id); 
                   if( lrRec.Search_Strategy_Created__c != null 
                      && ( lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_YES 
                          || lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_PENDING) )
                   {
                       lrIdForSsSet.add( lrRec.Id );
                   }
                   if(lrRec.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED && lrRec.LR_Type__c == CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL){
                       localLrProjectOverviewList.add(lrRec);
                   }
               }
        }
        // Code for Search Strategy Synch
        if(lrIdForSsSet.size() > 0){
            Set<String> lrSSFieldSet = new Set<String>{'Id', 'LR_Project_Overview_M__c', 'Project__c', 'Account__c', 'product__c', 
                                                       'LR_Type__c', 'Search_Strategy_M__c', 'Search_Strategy_M__r.Account__c',
                                                       'Search_Strategy_M__r.LR_Type__c', 'Search_Strategy_M__r.Product__c',
                                                       'Search_Strategy_M__r.Project__c', 'Search_Strategy_M__r.Name',
                                                       'Search_Strategy_M__r.Version_of_Search_Strategy__c',
                                                       'Search_Strategy_M__r.Date_Annual_Search_Strategy_Due__c',
                                                       'Search_Strategy_M__r.Date_Search_Strategy_got_Client_Approval__c',
                                                       'Search_Strategy_M__r.Comments__c'};
            List<LR_Search_Strategy_Relationship__c> lrssRecordList = new SLT_LR_Search_Strategy_Relationship(false, false).getLRSSRelationshipFromLrId(lrIdForSsSet, lrSSFieldSet);        
            // New Object used for Lr Completed and Cancelled
            
            for(LR_Search_Strategy_Relationship__c lrssRec : lrssRecordList){
                Archive_Search_Strategy__c archiveSS = new Archive_Search_Strategy__c();
                archiveSS.Account__c = lrssRec.Search_Strategy_M__r.Account__c;
                archiveSS.LR_Type__c = lrssRec.Search_Strategy_M__r.LR_Type__c;
                archiveSS.Product__c = lrssRec.Search_Strategy_M__r.Product__c;
                archiveSS.Project__c = lrssRec.Search_Strategy_M__r.Project__c;
                archiveSS.LR_Project_Overview__c = lrssRec.LR_Project_Overview_M__c;
                archiveSS.Name = lrssRec.Search_Strategy_M__r.Name;
                archiveSS.Version_of_Search_Strategy__c = lrssRec.Search_Strategy_M__r.Version_of_Search_Strategy__c;
                archiveSS.Date_Annual_Search_Strategy_Due__c = lrssRec.Search_Strategy_M__r.Date_Annual_Search_Strategy_Due__c;
                archiveSS.Date_Search_Strategy_got_Client_Approval__c = lrssRec.Search_Strategy_M__r.Date_Search_Strategy_got_Client_Approval__c;
                archiveSS.Comments__c = lrssRec.Search_Strategy_M__r.Comments__c;
                archiveSearchStrategyInsertList.add(archiveSS);
                
            }
            if(archiveSearchStrategyInsertList.size() > 0){
                UTL_ExecutionControl.stopTriggerExecution = true;
                insert archiveSearchStrategyInsertList;
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
            if( lrssRecordList.size() > 0){
                delete lrssRecordList;
            }        
        }
        if(lrIdforEjSet.size() > 0){
            // Code For Event Journal Synch
            Set<String> fieldSet2 = new Set<String>{'Id', 'Project__c', 'LR_Project_Overview_M__c', 'Account__c', 'product__c',
                                                    'LR_Type__c', 'Event_Journals_M__c', 'Event_Journals_M__r.Account__c', 'Event_Journals_M__r.LR_Type__c',
                                                    'Event_Journals_M__r.Product__c', 'Event_Journals_M__r.Project__c', 'Event_Journals_M__r.Name',
                                                    'Event_Journals_M__r.QPPV_LPS_Comments__c', 'Event_Journals_M__r.Other_Journal_Frequency_Specify__c',
                                                    'Event_Journals_M__r.Date_Last_Journal_Search_was_Performed__c',
                                                    'Event_Journals_M__r.Date_Next_Journal_Search_is_Due__c',
                                                    'Event_Journals_M__r.Inactive_since__c', 'Event_Journals_M__r.Frequency_of_Journal__c',
                                                    'Event_Journals_M__r.Date_Initial_Search_Started__c', 'Event_Journals_M__r.Active__c', 
                                                    'Event_Journals_M__r.CurrencyIsoCode', 'Event_Journals_M__r.Country__c',
                                                    'Event_Journals_M__r.Journal_Name__c', 'Event_Journals_M__r.URL__c',
                                                    'Event_Journals_M__r.Periodicity__c', 'Event_Journals_M__r.Regulatory_requirement__c',
                                                    'Event_Journals_M__r.Subscription__c', 'Event_Journals_M__r.Paper_Journal__c',
                                                    'Event_Journals_M__r.Therapeutic_Area__c'};
            List<LR_Event_Journals_Relationship__c> lrejRecordList = new SLT_LR_Event_Journals_Relationship(false, false).getLREJRelationshipFromLrId(lrIdforEjSet, fieldSet2);        
            
            if(lrejRecordList.size() > 0){
                for(LR_Event_Journals_Relationship__c lrejRec : lrejRecordList){
                    Archive_Event_Journal__c archiveEJ = new Archive_Event_Journal__c();
                    // Data From LR
                    archiveEJ.Account__c = lrejRec.Event_Journals_M__r.Account__c;
                    archiveEJ.LR_Type__c = lrejRec.Event_Journals_M__r.LR_Type__c;
                    archiveEJ.Product__c = lrejRec.Event_Journals_M__r.Product__c;
                    archiveEJ.Project__c = lrejRec.Event_Journals_M__r.Project__c;
                    archiveEJ.LR_Project_Overview__c = lrejRec.LR_Project_Overview_M__c; 
                    //Data From Matser            
                    archiveEJ.Name = lrejRec.Event_Journals_M__r.Name;
                    archiveEJ.Country__c = lrejRec.Event_Journals_M__r.Country__c;
                    archiveEJ.Journal_Name__c = lrejRec.Event_Journals_M__r.Journal_Name__c;
                    archiveEJ.URL__c = lrejRec.Event_Journals_M__r.URL__c;
                    archiveEJ.Periodicity__c = lrejRec.Event_Journals_M__r.Periodicity__c;
                    archiveEJ.Regulatory_requirement__c = lrejRec.Event_Journals_M__r.Regulatory_requirement__c;
                    archiveEJ.Subscription__c = lrejRec.Event_Journals_M__r.Subscription__c;
                    archiveEJ.Paper_Journal__c = lrejRec.Event_Journals_M__r.Paper_Journal__c;
                    archiveEJ.Therapeutic_Area__c = lrejRec.Event_Journals_M__r.Therapeutic_Area__c;            
                    // Data From Event Journal
                    archiveEJ.QPPV_LPS_Comments__c = lrejRec.Event_Journals_M__r.QPPV_LPS_Comments__c;
                    archiveEJ.Other_Journal_Frequency_Specify__c = lrejRec.Event_Journals_M__r.Other_Journal_Frequency_Specify__c;
                    archiveEJ.Date_Last_Journal_Search_was_Performed__c = lrejRec.Event_Journals_M__r.Date_Last_Journal_Search_was_Performed__c;
                    archiveEJ.Date_Next_Journal_Search_is_Due__c = lrejRec.Event_Journals_M__r.Date_Next_Journal_Search_is_Due__c;
                    archiveEJ.Inactive_since__c = lrejRec.Event_Journals_M__r.Inactive_since__c;
                    archiveEJ.Frequency_of_Journal__c = lrejRec.Event_Journals_M__r.Frequency_of_Journal__c;
                    archiveEJ.Date_Initial_Search_Started__c = lrejRec.Event_Journals_M__r.Date_Initial_Search_Started__c;
                    archiveEJ.Active__c = lrejRec.Event_Journals_M__r.Active__c;
                    archiveEJ.CurrencyIsoCode = lrejRec.Event_Journals_M__r.CurrencyIsoCode;
                    archiveEJ.Is_Clone_Record__c = 'Clone';
                    archiveEventJournalInsertList.add(archiveEJ);
                    if(!lrIdInRelationRecordSet.contains(lrejRec.LR_Project_Overview_M__c)){
                        lrIdInRelationRecordSet.add(lrejRec.LR_Project_Overview_M__c);
                    }
                }
                if(archiveEventJournalInsertList.size() > 0){
                    UTL_ExecutionControl.stopTriggerExecution = true;
                    insert archiveEventJournalInsertList;
                    UTL_ExecutionControl.stopTriggerExecution = false;
                }
                if(lrejRecordList.size() > 0){
                    delete lrejRecordList;  
                }
            }
            
            for(LR_Project_Overview__c lrRec : localLrProjectOverviewList){
                if(lrIdInRelationRecordSet.size() == 0 || !lrIdInRelationRecordSet.contains(lrRec.Id)){
                    lrRec.addError('You cannot mark the record as \'Completed\' if the selected LR Type is \'Local\' and there is no Event journal record related to it.');  
                }
            }
        }
    }
    
    // IQVIAPSA-4715, IQVIAPSA-4862, IQVIAPSA-4863
    public static void synchRecordSS(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        String lrKey='';
        Set<Id> lrIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> lrTypeSet = new Set<String>();
        Set<String> lrSSFieldSet = new Set<String>{'Id','Search_Strategy_M__c'};
        Set<String> lrStatusSet = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
       	Map<String,Set<Id>> lrIdToLrIdSetMap = new Map<String,Set<Id>>();
        List<LR_Search_Strategy_Relationship__c> LRSSListToCreateList = new List<LR_Search_Strategy_Relationship__c>();
        
        for(LR_Project_Overview__c lrRec : newList){
            if((lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_YES 
                || lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_PENDING)
               && ((trigger.isInsert && lrRec.Account__c != null 
                                    && lrRec.Product__c != null 
                                    && lrRec.Project__c != null 
                                    && LrRec.LR_Type__c != '') 
               ||(trigger.isUpdate && (lrRec.Account__c != oldMap.get(lrRec.id).Account__c 
                                       || lrRec.Product__c != oldMap.get(lrRec.id).Product__c 
                                       || lrRec.Project__c != oldMap.get(lrRec.id).Project__c 
                                       || LrRec.LR_Type__c != oldMap.get(lrRec.id).LR_Type__c 
                                       || lrRec.Search_Strategy_Created__c != oldMap.get(lrRec.id).Search_Strategy_Created__c))))
            { 
                if(!lrStatusSet.contains(lrRec.Status__c)){
                    lrKey = lrRec.Account__c+'*'+lrRec.Product__c+'*'+lrRec.Project__c+'*'+lrRec.LR_Type__c;
                    lrIdSet.add(lrRec.Id);  
                    projectIdSet.add(lrRec.Project__c);
                    accountIdSet.add(lrRec.Account__c);
                    productIdSet.add(lrRec.Product__c);
                    lrTypeSet.add(lrRec.LR_Type__c);
                    if(lrIdToLrIdSetMap.containsKey(lrKey)){
                        lrIdToLrIdSetMap.get(lrKey).add(lrRec.Id);
                    }else{
                        lrIdToLrIdSetMap.put(lrKey, new Set<Id>{lrRec.Id}); 
                    }  
                }
            }
        }
        if(trigger.isUpdate){
            List<LR_Search_Strategy_Relationship__c> lrssRecordToDeleteList = new SLT_LR_Search_Strategy_Relationship(false, false).getLRSSRelationshipFromLrId(lrIdSet, lrSSFieldSet);
            if(lrssRecordToDeleteList.size() > 0){
                SRV_PSA_LR_Synch.deleteDataofLRSS(lrssRecordToDeleteList); 
            }
        }
        for(Search_Strategy__c ss : [SELECT Id, Project__c, Product__c, LR_Type__c, 
                                     Account__c 
                                     FROM Search_Strategy__c
                                     WHERE Project__c IN : projectIdSet
                                     AND Product__c IN : productIdSet
                                     AND LR_Type__c IN : lrTypeSet
                                     AND Account__c IN : accountIdSet
                                    ])
        {
            lrKey = ss.Account__c+'*'+ss.Product__c+'*'+ss.Project__c+'*'+ss.LR_Type__c;
            if(lrIdToLrIdSetMap != null 
               && lrIdToLrIdSetMap.values().size() > 0  
               && lrIdToLrIdSetMap.containsKey(lrKey) 
               && lrIdToLrIdSetMap.get(lrKey) != null){
                for(Id lrRecordId : lrIdToLrIdSetMap.get(lrKey)){
                    LR_Search_Strategy_Relationship__c newLrss = new LR_Search_Strategy_Relationship__c(
                        LR_Project_Overview_M__c = lrRecordId, 
                        Project__c = ss.Project__c , 
                        Search_Strategy_M__c = ss.Id, 
                        Account__c = ss.Account__c,
                        product__c = ss.Product__c, 
                        LR_Type__c = ss.LR_Type__c
                    );
                    LRSSListToCreateList.add(newLrss);  
                }
            }
        }
        
        // Create new junction Records for the Updated LR Records.
        if(LRSSListToCreateList!= null && LRSSListToCreateList.size() > 0){
            insert LRSSListToCreateList;
        }
    }
    
    public static void synchRecordEJ(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        String keyEventJournals='';
        Set<Id> lrIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> lrTypeSet = new Set<String>();
        Set<String> lrStatusSet = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
        Set<String> lrEJFieldSet = new Set<String>{'Id','Event_Journals_M__c'};
        Map<String,Set<Id>> lrIdToLrIdSetMap = new Map<String,Set<Id>>(); 
        List<LR_Event_Journals_Relationship__c> LREJListToCreateList = new List<LR_Event_Journals_Relationship__c>();        
        
        for(LR_Project_Overview__c lrRec : newList ){
            if((trigger.isInsert && lrRec.Account__c != null && lrRec.Product__c != null 
                && lrRec.Project__c != null && LrRec.LR_Type__c != '') ||
               (trigger.isUpdate && (lrRec.Account__c != oldMap.get(lrRec.id).Account__c 
                                     || lrRec.Product__c != oldMap.get(lrRec.id).Product__c 
                                     || lrRec.Project__c != oldMap.get(lrRec.id).Project__c 
                                     || LrRec.LR_Type__c != oldMap.get(lrRec.id).LR_Type__c))){
                   if(!lrStatusSet.contains(lrRec.Status__c)){
                       keyEventJournals = lrRec.Account__c+'*'+lrRec.Product__c+'*'+lrRec.Project__c+'*'+lrRec.LR_Type__c;
                       lrIdSet.add(lrRec.Id);
                       projectIdSet.add(lrRec.Project__c);
                       accountIdSet.add(lrRec.Account__c);
                       productIdSet.add(lrRec.Product__c);
                       lrTypeSet.add(lrRec.LR_Type__c);
                       if(lrIdToLrIdSetMap.containsKey(keyEventJournals)){
                           lrIdToLrIdSetMap.get(keyEventJournals).add(lrRec.Id);
                       }else{
                           lrIdToLrIdSetMap.put(keyEventJournals, new Set<Id>{lrRec.Id}); 
                       }
                   }                   
               }
        }
        if(trigger.isUpdate){
            List<LR_Event_Journals_Relationship__c> lrEjRecordToDeleteList = new SLT_LR_Event_Journals_Relationship(false, false).getLREJRelationshipFromLrId(lrIdSet, lrEJFieldSet);
            if(lrEjRecordToDeleteList.size() > 0){
                SRV_PSA_LR_Synch.deleteDataofLREJ(lrEjRecordToDeleteList);   
            }
        }
        for(Event_Journals__c ej : [SELECT Id, Project__c, Product__c, LR_Type__c, 
                                    Account__c 
                                    FROM Event_Journals__c
                                    WHERE Project__c IN : projectIdSet
                                    AND Product__c IN : productIdSet
                                    AND LR_Type__c IN : lrTypeSet
                                    AND Account__c IN : accountIdSet
                                   ])
        {
            keyEventJournals = ej.Account__c+'*'+ej.Product__c+'*'+ej.Project__c+'*'+ej.LR_Type__c;
            if(lrIdToLrIdSetMap != null && lrIdToLrIdSetMap.values().size() > 0 && lrIdToLrIdSetMap.containskey(keyEventJournals) && lrIdToLrIdSetMap.get(keyEventJournals) != null){
                for(Id LrRecordId : lrIdToLrIdSetMap.get(keyEventJournals)){
                    LR_Event_Journals_Relationship__c newLrEj = new LR_Event_Journals_Relationship__c(
                        LR_Project_Overview_M__c = LrRecordId,
                        Project__c = ej.Project__c ,
                        Event_Journals_M__c = ej.Id,
                        Account__c = ej.Account__c,
                        product__c = ej.Product__c,
                        LR_Type__c = ej.LR_Type__c
                    );
                    LREJListToCreateList.add(newLrEj); 
                }
            }
        }
        if(LREJListToCreateList != null && LREJListToCreateList.size() > 0){
            insert LREJListToCreateList;
        }
    }
    //IQVIAPSA-4536, IQVIAPSA-4870, IQVIAPSA-4871 Ends
    
    // IQVIAPSA-4733
    /**
    * Retrieves all the PSA Events that could be applied to an LR Project Overview
    */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event(false,false).getAllPSAEvents('LR_Project_Overview__c');
        }
    }
    /**
    * This method builds a map of Planned_Date_Field__c to RecordTypeName to PSA_Event__c
    * It allows you to filter PSA Events by both field and recordtype when trying to match up with LR Project Overview
    */
    private static void buildDateFieldMap(){
        fetchPSAEvents();
        if(dateFieldToPSAEventMap == null){
            dateFieldToPSAEventMap = new Map<String, PSA_Event__c>(); 
        }
        for(PSA_Event__c event : psaEvents){
            if(dateFieldToPSAEventMap.get(event.Planned_Date_Field__c) == null && event.Planned_Date_Field__c != null){
                dateFieldToPSAEventMap.put(event.Planned_Date_Field__c, event);
            }
        }
    }
    
    private static void buildPSAIdToPSAMap(){
        fetchPSAEvents();
        psaIdToPsaEventMap = new Map<Id, PSA_Event__c>();
        for(PSA_Event__c event : psaEvents){
            psaIdToPsaEventMap.put(event.Id, event);
        }
    }
    /**
    * Compiles a list of the Due Date fields from a list of PSA events
    * These are the fields that we will be examining on LR Project Overview for changes
    */
    private static void setEventDateFields(){
        if(lRProjectOverviewFields == null){
           lRProjectOverviewFields = Schema.SObjectType.LR_Project_Overview__c.fields.getMap().keySet(); 
        }
        Set<String> invalidFieldsSet = new Set<String>();
        fetchPSAEvents();
        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if (event.Planned_Date_Field__c != null && !lRProjectOverviewFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                invalidFieldsSet.add(event.Name+':'+event.Planned_Date_Field__c);
            } else {
                eventDateFields.add(event.Planned_Date_Field__c);
            }
        }
        if(invalidFieldsSet.size() > 0){
            throw new DAOH_PSA_LRProjectOverviewFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFieldsSet), ',' ) );
        }
    }
    /**
    * This method retrieves all Project_Event__c objects for the Aggregate records, and maps them by Report Id followed by PSA Event Id
    * This allows us to validate them against both the Aggregate Report and the PSA Event, in case either has changed
    * @params List<LR_Project_Overview__c> records
    * @return Map<Id,Map<Id,Project_Event__c>>
    */
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsByLr(List<LR_Project_Overview__c> records ){
        Set<Id> lrIdSet = new Set<Id>();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        if(records.size() > 0){
           lrIdSet = new Set<Id>(new Map<Id,LR_Project_Overview__c>(records).keySet()); 
        }
        Set<String> eventFields = new SLT_Project_Event(false,false).getDefaultFields();
        if(lrIdSet.size() > 0 && eventFields.size() > 0){
            List<Project_Event__c> events = new SLT_Project_Event(false,false).getProjectEventsByLR(lrIdSet, eventFields);
            if(events.size() > 0){
                for(Project_Event__c event : events){
                    if(projectEventsMap.get(event.LR_Project_Overview__c) == null){
                        projectEventsMap.put(event.LR_Project_Overview__c, new Map<Id,Project_Event__c>());
                    }
                    projectEventsMap.get(event.LR_Project_Overview__c).put(event.PSA_Event__c, event);
                }  
            } 
        }
        return projectEventsMap;
    }
    /**
    * Validates that the target fields in a PSA Event are valid field names
    * @params PSA_Event__c psaEvent
    */
    static void validatePSAEvent( PSA_Event__c psaEvent, Set<String> validFields ){
        Set<String> invalidFieldsSet = new Set<String>();
        Set<String> psaEventFieldValuesSet = new Set<String>();
        Set<String> psaEventFieldNamesSet = new Set<String>{
            'Actual_Date_Field__c',
            'Planned_Date_Field__c'
             };
        for(String fieldName : psaEventFieldNamesSet){
            if(psaEvent.get(fieldName) != null){
                psaEventFieldValuesSet.add( String.valueOf( psaEvent.get(fieldName) ) );
            }
        }
        if(psaEvent.Stakeholder_Fields__c != null){
            for ( String stakeholder : psaEvent.Stakeholder_Fields__c.split(',')) {
                psaEventFieldValuesSet.add( stakeholder.trim() );
            }            
        }
        for(String fieldValue : psaEventFieldValuesSet){
            if(!validFields.contains( fieldValue.toLowerCase())){
                invalidFieldsSet.add( fieldValue );
            }
        }
        if(invalidFieldsSet.size() > 0){
            throw new DAOH_PSA_LRProjectOverviewFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFieldsSet), ',' ) );
        }
    }
    /**
    * Populate fields on a project event given an aggregate report and a psa event
    * @params LR_Project_Overview__c lrRecord
    * @params PSA_Event__c psaEvent
    * @params Project_Event__c projectEvent
    * @return Project_Event__c
    */
    private static Project_Event__c populateProjectEvent( LR_Project_Overview__c lrRecord, PSA_Event__c psaEvent){
        return populateProjectEvent( lrRecord, psaEvent, new Project_Event__c());
    }
    
    private static Project_Event__c populateProjectEvent( LR_Project_Overview__c lrRecord, PSA_Event__c psaEvent, Project_Event__c projectEvent) {
        if ( psaEvent.Actual_Date_Field__c != null && lrRecord.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)lrRecord.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }
        if ( psaEvent.Planned_Date_Field__c != null && lrRecord.get(psaEvent.Planned_Date_Field__c) != null) { 
            projectEvent.Event_Due_Date__c = (Date)lrRecord.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }
        if ( psaEvent.Planned_Date_Field__c != null && lrRecord.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)lrRecord.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(lrRecord.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.LR_Project_Overview__c = lrRecord.Id;
        projectEvent.Project__c = (lrRecord.Project__c != null) ? String.valueOf(lrRecord.Project__c) : null;
        return projectEvent;
    }
    /**
    * This method synchronizes the Project Events for an LR Project Overview if a date on the record changes, provided it has a corresponding entry in the PSA Events table
    */
    public static void synchronizeProjectEvents(List<LR_Project_Overview__c > updatedList, Map<Id,LR_Project_Overview__c > existingRecords){
        List<LR_Project_Overview__c> lrProjectOverViewSyncList = new List<LR_Project_Overview__c>();
        Map<Id,Map<Id,Project_Event__c>> lrToProjectEventMap = new Map<Id,Map<Id,Project_Event__c>>();
        Set<Id> lrToProjectIdSet = new Set<Id>();
        if(updatedList.size() > 0){
            for(LR_Project_Overview__c lr : updatedList){
                if(lr.Status__c != CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED && lr.Status__c != CON_PSA.LR_PROJECT_OVERVIEW_STATUS_CANCELLED){
                    lrProjectOverViewSyncList.add(lr);
                    lrToProjectIdSet.add(lr.Project__c);
                }
            }  
        }
        fetchPSAEvents();
        buildDateFieldMap();
        buildPSAIdToPSAMap();
        Id userId = UserInfo.getUserId();
        try {
            setEventDateFields();
        } catch (Exception e) {
            if(lrProjectOverViewSyncList.size() > 0){
                LR_Project_Overview__c Lr = lrProjectOverViewSyncList.get(0);
                Lr.addError(e.getMessage());
            }
            return;
        }
        if(lRProjectOverviewFields == null){
           lRProjectOverviewFields = Schema.SObjectType.LR_Project_Overview__c.fields.getMap().keySet(); 
        }
        if(lrProjectOverViewSyncList.size() > 0){
            lrToProjectEventMap = getProjectEventsByLr(lrProjectOverViewSyncList);
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Project_Event__c.SObjectType }
        );
        if(lrProjectOverViewSyncList != null && lrProjectOverViewSyncList.size() > 0 && psaIdToPsaEventMap != null && psaIdToPsaEventMap.size() > 0){
            for(LR_Project_Overview__c lrRecords : lrProjectOverViewSyncList){
                for(Id psaEvId : psaIdToPsaEventMap.keySet()){
                    //Date dateFieldContents = (Date) lrRecords.get(dateField);
                    PSA_Event__c psaEvent = new PSA_Event__c();
                    if(psaIdToPsaEventMap.containsKey(psaEvId) && psaIdToPsaEventMap.get(psaEvId) != null){
                        psaEvent = psaIdToPsaEventMap.get(psaEvId); 
                    }
                    Project_Event__c projectEvent= (lrToProjectEventMap.get(lrRecords.Id) != null && psaEvent != null) ? lrToProjectEventMap.get(lrRecords.Id).get(psaEvent.Id) : null;
                    if(psaEvent != null && (Date) lrRecords.get(psaEvent.Planned_Date_Field__c) != null) {
                        try {
                            validatePSAEvent(psaEvent, lRProjectOverviewFields);
                        } catch (DAOH_PSA_LRProjectOverviewFieldException e){
                            lrRecords.addError(e.getMessage());
                            continue;
                        }
                        if(projectEvent == null){
                            projectEvent = populateProjectEvent(lrRecords, psaEvent);
                            uow.registerNew(projectEvent);
                        } else {
                            //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                            //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                            populateProjectEvent(lrRecords, psaEvent, projectEvent);
                            uow.registerDirty(projectEvent);
                        }
                    }
                    else if (projectEvent != null){
                        //Note, this will catch any Project Events whose PSA Event now indicate a blank date field. 
                        projectEvent.ownerId = userId;
                        uow.registerDirty(projectEvent);
                        uow.registerDeleted(projectEvent);
                    }
                }
            }  
        }
        
        uow.commitWork();
    }
    
    public static void populateAccountFromProject(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        Set<String> projectIdSet = new Set<String>();
        Map<Id,pse__Proj__c> projectIdToProjectMap = new Map<Id,pse__Proj__c>();
        for(LR_Project_Overview__c lrRec : newList){
            if(lrRec.Project__c != null && (trigger.isInsert || (trigger.isUpdate && lrRec.Project__c != oldMap.get(lrRec.Id).Project__c))) {
                projectIdSet.add(lrRec.Project__c);
            }
        }
        if(projectIdSet.size() > 0){
            for(pse__Proj__c proj : [SELECT id, pse__Account__c, pse__Parent_Project__r.Project_Code__c
                                      FROM pse__Proj__c 
                                      WHERE Id in: projectIdSet ]){
                projectIdToProjectMap.put(proj.Id , proj);
            }
            for(LR_Project_Overview__c lrRec : newList){
                if(projectIdToProjectMap.containsKey(lrRec.Project__c)){
                    if(projectIdToProjectMap.get(lrRec.Project__c).pse__Account__c != null && lrRec.Account__c != projectIdToProjectMap.get(lrRec.Project__c).pse__Account__c){
                        lrRec.Account__c = projectIdToProjectMap.get(lrRec.Project__c).pse__Account__c;
                    }
                    if(projectIdToProjectMap.get(lrRec.Project__c).pse__Parent_Project__r.Project_Code__c != null && lrRec.Project_Codes__c != projectIdToProjectMap.get(lrRec.Project__c).pse__Parent_Project__r.Project_Code__c){
                        lrRec.Project_Codes__c = projectIdToProjectMap.get(lrRec.Project__c).pse__Parent_Project__r.Project_Code__c;
                    }
                } 
            }
        }
    }
    
    public static void enableChkboxForBatchProcessing(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        List<Schema.FieldSetMember> trackedFieldsList = SObjectType.LR_Project_Overview__c.FieldSets.History_Tracking.getFields();
        String fieldName;
        LR_Project_Overview__c oldLrRecord = new LR_Project_Overview__c();
        List<String> fieldList = new List<String>();
        for(LR_Project_Overview__c lrRec : newList){
            oldLrRecord = (LR_Project_Overview__c) oldmap.get(lrRec.Id);
            //check if LR_Project_Overview__c Status is not changed and Status is Completed
            if(!trackedFieldsList.isEmpty() && trigger.isUpdate && lrRec.Status__c == oldLrRecord.Status__c && lrRec.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED){
                for (Schema.FieldSetMember fsm : trackedFieldsList){
                    fieldName  = fsm.getFieldPath();    
                    if (lrRec.get(fieldName) != oldLrRecord.get(fieldName)){
                        if(lrRec.To_be_tracked_by_batch__c != true){
                            lrRec.To_be_tracked_by_batch__c = true;   
                        }
                        if(lrRec.Updated_Fields_for_Metrics_Email__c != null){
                            fieldList = lrRec.Updated_Fields_for_Metrics_Email__c.split(';');
                            if(!fieldList.contains(fieldName)){
                                lrRec.Updated_Fields_for_Metrics_Email__c += fieldName + ';';
                            }
                        }else{
                            lrRec.Updated_Fields_for_Metrics_Email__c = fieldName + ';';
                        }
                    }
                }
            }
        }
    }
    
   /*
    *  IQVIAPSA-5432
    */    
    public static void validationOnLocalAndCompletedStatus(List<LR_Project_Overview__c> newList, Map<Id, LR_Project_Overview__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List<LR_Project_Overview__c> lrProjectOverviewsInsertList = new List<LR_Project_Overview__c>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<String> ejKeySet = new Set<String>();
        String lrKey = '';
        String keyEventJournals='';
        if(mulesoftSetting != null && !mulesoftSetting.Ignore_Validation_Rules__c){
            for(LR_Project_Overview__c lr : newList){
                //For insert
                if((trigger.isInsert  && lr.Status__c == CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED && lr.LR_Type__c == CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL)){
                        projectIdSet.add(lr.Project__c);
                        accountIdSet.add(lr.Account__c);
                        productIdSet.add(lr.Product__c);
                        lrProjectOverviewsInsertList.add(lr);
                }                
                
        	}
            for(Event_Journals__c ej : [SELECT Id, Project__c, Product__c, LR_Type__c, 
                                        Account__c 
                                        FROM Event_Journals__c
                                        WHERE Project__c IN : projectIdSet
                                        AND Product__c IN : productIdSet
                                        AND LR_Type__c = 'Local'
                                        AND Account__c IN : accountIdSet
                                       ])
            {
                keyEventJournals = ej.Account__c+'*'+ej.Product__c+'*'+ej.Project__c;
                ejKeySet.add(keyEventJournals);
            }                
            if(lrProjectOverviewsInsertList != null && lrProjectOverviewsInsertList.size() > 0){
                for(LR_Project_Overview__c lrRec : lrProjectOverviewsInsertList){
                    lrKey = lrRec.Account__c+'*'+lrRec.Product__c+'*'+lrRec.Project__c;
                    if(ejKeySet != null && !ejKeySet.contains(lrKey)){
                        lrRec.addError('You cannot mark the record as \'Completed\' if the selected LR Type is \'Local\' and there is no Event journal record related to it.');
                    }
                }
            }
        }        
    }
    
    
    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Drug
    **/
    public static void insertAuditLog(List<LR_Project_Overview__c> insertList, String operation){
       SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating LR
    **/
    public static void insertAuditLogOnUpdate(List<LR_Project_Overview__c> updatedList, Map<Id,LR_Project_Overview__c> existingRecords){
       SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
     * Exception class for DAOH_PSA_LR_Project_Overview field validation
     */
    public class DAOH_PSA_LRProjectOverviewFieldException extends Exception {}
    // IQVIAPSA-4733 Ends
}