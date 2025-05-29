/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Case
 */
public class SLT_Case extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Case.Id,
            Case.IsClosed,
            Case.SlaStartDate,
            Case.SlaExitDate,
            Case.RecordTypeId,
            Case.CaseNumber,
            Case.AccountId,
            Case.ContactId,
            Case.Case_CategorizationId__c,
            Case.ProductName__c,
            Case.LOS__c,
            Case.SubType1__c,
            Case.SubType2__c,
            Case.SubType3__c,
            Case.Template__c,
            Case.Subject,
            Case.Description,
            Case.CreatedDate,
            Case.ClosedDate,
            Case.Number_of_Article__c,
            Case.Status,
            Case.SubStatus__c,
            Case.ProjectCode__c,
            Case.StudyProtocolName__c,
            Case.LabProjectCode__c,  
            Case.SiteNumber__c,
            Case.LabSiteNumber__c,
            Case.Priority,
            Case.LastModifiedById,
            Case.InitialQueue__c,
            Case.Case_SiteName__c,
            Case.CurrentQueue__c,
            Case.ParentId,
            Case.OwnerId,
            Case.RecordTypeName__c,
            Case.NewCaseComment__c,
            Case.Origin,
            Case.Mail_CC_List__c,
            Case.AlignmentName__c,
            Case.CaseRequestBy__c,
            Case.CaseSubType1__c,
            Case.CaseSubType2__c,
            Case.CaseSubType3__c,
            Case.ClientObjectiveBusinessNeed__c,
            Case.CrossDatabase__c,
            Case.DataDeliveryEndDate__c, 
            Case.DataMeasurement__c,
            Case.NoContactKnown__c,
            Case.NovartisCaseType__c,
            Case.OnBehalfOf__c,
            Case.Reason,
            Case.SuppliedCompany,
            Case.SuppliedEmail,
            Case.SuppliedName,
            Case.SuppliedPhone,
            Case.Tag__c,
            Case.Type,
            Case.UrgentForCustomer__c,
            Case.Language__c,
            Case.ProductMarketorOther__c,
            Case.Pharma_Product_Name__c,
            Case.NDC_Number__c,
            Case.Number_of_Corrective_Action_Lookups__c,
            Case.Did_this_Require_Corrective_Action__c,
            Case.RunDateOfReport__c,
            Case.TimeIntervalsquestioningcomparing__c,
            Case.ProductMarketOrOtherName__c,
            Case.Product_Market_or_Other_Name__c,
            Case.CMFProd__c,
            Case.USC5__c,
            Case.AreyouquestioningcomparingProjected__c,
            Case.Auditsquestioningcomparing__c,
            Case.Metricsquestioningcomparing__c,
            Case.InternalOrExternalDI__c,
            Case.Internal_or_External_DI__c,
            Case.FillinthenameoftheClientCompanyt__c,
            Case.PRSNumber__c,
            Case.Channelsquestioningcomparing__c,
            Case.MarketNameOnWeb__c,
            Case.AgeGrouping__c,
            Case.MonoComboTherapy__c,
            Case.SpecialtyGrouping__c,
            Case.DataWeekMonthofReportLifelink__c,
            Case.TimingofReportChanges__c,
            Case.Study__c,
            Case.CSM_QI_Data_Originator__c,
            Case.RandD_Location__c,
            Case.Owner__c,
            Case.AssetId,
            Case.CaseTaskAction__c,
            Case.TaskMilestone__c,    
            Case.Case_Type__c,
            Case.From_EmailToCase__c,
            Case.CaseOriginatorName__c,
            Case.CaseOriginatorEmail__c,
            Case.AFU_TECH__c,
            Case.AFU_Email_Flag__c,
            Case.Case_Thread_ID__c,
            Case.Case_ThreadToken__c,
            Case.LastCaseComment__c,
            Case.AccountCountry__c,
            Case.IsEscalated,
            Case.First_response_email_time__c,
            Case.First_response_sent__c,
            Case.NumberOfNotifications__c,
            Case.Service_Now_Incident_Number__c,
            Case.ServiceNowSystemType__c,
            Case.ServiceNow_Group__c,
            Case.CreatedById,
            Case.CaseSource__c,
            Case.EnvironmentType__c,
            Case.LastModifiedDate,
            Case.Watch_List_User__c,
            Case.Device__c,
            Case.AdditionalThirdPartyCase__c,
            Case.Affects_Version__c,
            Case.Is_Parent__c,
            Case.Country_of_the_requester2__c,
            Case.External_System_Type__c,
            Case.EntitlementId,
            Case.Entitlement.Type,
            Case.Media_Date_Label__c,
            Case.DueDate__c,
            Case.Media_Download_Date__c,
            Case.Media_Date__c,
            Case.Reason_for_Late_Request_Re_Run__c,
            Case.Other_audits_and_their_frequencies__c,
            Case.Urgency__c,
            Case.Impact__c,
            Case.Maintenance_Type__c,
            Case.First_Escalated_By__c
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Case.sObjectType;
    }
    
    /**
     * This method used to get Case by Id
     * @return  List<Case>
     */
    public List<Case> selectById(Set<ID> idSet) {
        return (List<Case>) selectSObjectsById(idSet);
    }
    
    public List<Case> selectAllById(Set<ID> idSet) {
        return Database.query('select Id,IsClosed,SlaStartDate,SlaExitDate,RecordTypeId,CaseNumber,AccountId,ContactId,Case_CategorizationId__c,ProductName__c,LOS__c,SubType1__c,SubType2__c,SubType3__c,Template__c,Subject,Description,CreatedDate,ClosedDate,Number_of_Article__c,Status,SubStatus__c,ProjectCode__c,StudyProtocolName__c,LabProjectCode__c,SiteNumber__c,LabSiteNumber__c,Priority,LastModifiedById, Case_SiteName__c,InitialQueue__c,CurrentQueue__c,ParentId,OwnerId,RecordTypeName__c,NewCaseComment__c,Origin,Mail_CC_List__c,AlignmentName__c,CaseRequestBy__c,ClientObjectiveBusinessNeed__c,CrossDatabase__c,DataDeliveryEndDate__c,DataMeasurement__c,NoContactKnown__c,NovartisCaseType__c,OnBehalfOf__c,Reason,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Tag__c,Type,UrgentForCustomer__c,Language__c,ProductMarketorOther__c,Pharma_Product_Name__c,NDC_Number__c,Number_of_Corrective_Action_Lookups__c,Did_this_Require_Corrective_Action__c,RunDateOfReport__c,TimeIntervalsquestioningcomparing__c,ProductMarketOrOtherName__c,CMFProd__c,USC5__c,AreyouquestioningcomparingProjected__c,Auditsquestioningcomparing__c,Metricsquestioningcomparing__c,InternalOrExternalDI__c,FillinthenameoftheClientCompanyt__c,PRSNumber__c,Channelsquestioningcomparing__c,MarketNameOnWeb__c,AgeGrouping__c,MonoComboTherapy__c,SpecialtyGrouping__c,TimingofReportChanges__c,Study__c,CSM_QI_Data_Originator__c,RandD_Location__c,Owner__c,AssetId,CaseTaskAction__c,TaskMilestone__c,Case_Type__c,From_EmailToCase__c,CaseOriginatorName__c,CaseOriginatorEmail__c,AFU_TECH__c,AFU_Email_Flag__c,Case_Thread_ID__c,Case_ThreadToken__c,LastCaseComment__c,AccountCountry__c,IsEscalated,First_response_email_time__c,First_response_sent__c,NumberOfNotifications__c,Service_Now_Incident_Number__c,ServiceNowSystemType__c,ServiceNow_Group__c,CreatedById,CaseSource__c,EnvironmentType__c,LastModifiedDate,Watch_List_User__c,Device__c,AdditionalThirdPartyCase__c,Affects_Version__c,Is_Parent__c,Country_of_the_requester2__c,External_System_Type__c,EntitlementId,Entitlement.Type,Media_Date_Label__c,DueDate__c,Media_Download_Date__c,Media_Date__c,Reason_for_Late_Request_Re_Run__c,Other_audits_and_their_frequencies__c,Urgency__c,Impact__c,Maintenance_Type__c From Case where id in :idSet');
    }

    /**
     * This method used to get Case by Id
     * @return  Map<Id, Case>
     */
      public Map<Id, Case> getCaseById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Case>((List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to selectByCaseId
     * @return  Map<Id, Case>
     */
    public Map<Id, Case> selectByCaseId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Case>((List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to selectByCaseId
     * @return  Map<Id, Case>
     */
    public List<Case> selectByCaseIdList(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }

    /**
     * This method used to selectByStudyIdList
     * @return  List<Case>
     */
    public List<Case> selectByStudyIdList(Set<ID> idSet, Set<String> fieldSet) {
        Set<String> statusList=new Set<String>{CON_CSM.S_CLOSED,CON_CSM.S_RESOLVED};
        return (List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Status not in :statusList and Study__c in :idSet').toSOQL());
    }

    /**
     * This method used to selectByStudySiteContactIdList
     * @return  List<Case>
     */
    public List<Case> selectByStudyStudySiteContactIdList(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Site_Related_to_the_Study__c in :idSet').toSOQL());
    }

    /**
     * This method used to select List of case based on CaseNumber
     * @return  Case
     */
    public Case selectByCaseNumberList(String cNumber, Set<String> fieldSet) {
        return (Case)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('CaseNumber = :cNumber').toSOQL());
    }
    
    /**
     * This method used to selectByCaseQueueList
     * @return  Map<Id, Case>
     */
    public List<Case> selectByCaseQueueList(String queueName, Set<String> fieldSet) {
        Set<String> caseStatus=new Set<String>{'Closed','Canceled'};
        return (List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('InitialQueue__c = :queueName and Status Not In :caseStatus ').toSOQL());
    }
    
    public List<Case> selectByContactId(Set<Id> idSet) {
        return (List<Case>) Database.query('Select Id,CaseNumber,LOS__C,Case_CategorizationId__r.ProductName__c,RecordTypeName__c,CreatedDate,Owner.Alias,Subject,Priority,Status From Case Where ContactId in :idSet order by Id desc LIMIT 5');
    }
    
    public Set<Id> selectByStatusAndParentId(Set<Id> caseIdSet) {
        return new Map<Id, Case>((List<Case>) Database.query('select Id,ParentId from Case where ParentId != null and  ParentId in :caseIdSet and ((Status not in (\'Resolved\',\'Closed\',\'Abandoned\',\'Canceled\',\'Merged\') and RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\')) OR (Status not in (\'Resolved with Customer\',\'Closed\',\'Abandoned\',\'Canceled\',\'Merged\') and RecordTypeName__c = \'TechnologyCase\'))')).keySet();
    } 
    
    public Map<Id, Case> selectByParentId(Set<Id> caseIdSet) {
        return new Map<Id, Case>((List<Case>) Database.query('select Id,ParentId from Case where Id in :caseIdSet'));
    }
    
    public List<Case> selectByEmailMessage(Set<Id> caseIdSet) {
        return Database.query('select id, type, origin, CreatedDate,RecordType.Name, OwnerId, CaseNumber,Description, (select id from EmailMessages) FROM Case where id IN :caseIdSet');
    }
    
    public List<Case> getCaseListForActivity(Set<Id> caseIdSet){
        return Database.query('SELECT Id, AccountId, ContactId, Study__c, LOS__c, RandD_Location__c FROM Case Where Id = :caseIdSet');
    }
    
    public List<Case> getCaseListHierarchy(String byField, List<String> CurrentParent, List<String> CaseSource){
        String queryString = 'SELECT Id, CaseNumber,ParentId,Priority,Subject FROM Case';
        String finalQueryString = '';
        if(byField == 'ParentId'){
            finalQueryString = queryString + ' WHERE ParentId IN : CurrentParent';
            if (CaseSource != null) {
                finalQueryString = finalQueryString + ' AND CaseSource__c in : CaseSource';
            }
        }
        else{
            finalQueryString = queryString + ' WHERE Id IN : CurrentParent';
            if (CaseSource != null) {
                finalQueryString = finalQueryString + ' AND CaseSource__c in : CaseSource';
            }
        }
        finalQueryString = finalQueryString + ' ORDER BY ParentId Limit 1000';
        return Database.query(finalQueryString);
    }
    
    public Case getParentCaseHierarchy(String recId){
        return Database.query('SELECT Id, ParentId FROM Case Where Id = :recId');
    }

    public list<Case> getCaseByCaseNumber(String caseNumber){
        return Database.query('Select Id,Status from case where CaseNumber =: caseNumber limit 1');
    }
	
    public List<case> getCaseByIdAndStatus(List<Id> listOfId, String status) {
        return Database.query('select Id, OneKeyID__c, OneKey_FirstName__c, OneKey_LastName__c, OneKey_Validation_Error__c,Type,Status from Case where Id in : listOfId AND status !=: status');
    }
    
    public List<Case> getCaseDetails(List<String> caseIdSet){
        return Database.query('SELECT Id, RecordTypeId,CaseNumber, Study__c,RecordTypeName__c, AccountId, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, OnBehalfOf__c, OnBehalfOf__r.Name, OnBehalfOf__r.FirstName, OnBehalfOf__r.LastName, Site_Related_to_the_Study__c,Site_Related_to_the_Study__r.Name, LOS__c, SubType1__c, SubType2__c, SubType3__c, Template__c, Contact_User_Role__c, Subject_ID__c,Site_Assignment__c FROM Case Where Id in :caseIdSet');
    }
	
    public List<Case> selectByCaseByContact(Set<String> contactSet, Set<String> fieldSet) {
        return (List<Case>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ContactId  IN :contactSet and Self_Registration_Date__c != null ').toSOQL());
    }
    
    public List<Case> getBISMCaseDetails(String caseNumber){
        return Database.query('Select Id, CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,ServiceNowSystemType__c,Techno_Impact__c,Status,SubStatus__c,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,RootCause__c,InitialQueue__c,External_System_Type__c,Root_Cause_Reason__c From Case where CaseNumber = :caseNumber limit 1');
    }
    public List<List<SObject>> getSearchResults(String searchText,Set<String> pillar,String accountId,Set<String> ids, String partnerType, Integer rowLimit, Integer rowOffset){        
        String searchQuery = 'FIND '+ '\'' + searchText+ '\''+'IN ALL FIELDS RETURNING Case(Id, CaseNumber, Subject, Status, Priority, ProductName__c, SubType1__c, SubType2__c, SubType3__c ORDER BY Subject LIMIT :rowLimit OFFSET:rowOffset)';      
        List<List<SObject>> results = search.query(searchquery);
        return results;
    }
    public List<Case> getParentChildCase(Set<Id> caseIds, Set<Id> parentcaseIds){
        String queryString = 'SELECT Id,ParentId FROM Case WHERE';
        String finalQueryString = '';
        if(caseIds.size() > 0){
            finalQueryString = queryString + ' ParentId IN :caseIds and (Status !=\'Closed\' AND Status!=\'Canceled\' AND Status != \'Abandoned\' AND Status != \'Merged\') LIMIT 1';
        }
        else if(parentcaseIds.size() > 0) {
            finalQueryString = queryString + ' Id IN :parentcaseIds AND (AFU_TECH__c = true OR Status =\'Closed\' OR Status=\'Canceled\' OR Status = \'Abandoned\' OR Status = \'Merged\') AND (SubStatus__c != \'Customer Info\' AND Case_Type__c != \'Problem\') LIMIT 1';
        }
        return Database.query(finalQueryString);
    }
    public List<Case> getCasesEmailtoCase(){
        return Database.query('Select Id, CaseNumber,Subject,Description,Origin,CreatedDate,CreatedById,RecordTypeName__c,From_EmailToCase__c,Status From Case where Status =\'New\' ORDER BY CaseNumber DESC limit 10');
    }
    public List<Queue_User_Relationship__c> getBypassQueueForEmailToCase(String queue_Id){
        return Database.query('Select Id, Bypass_Duplicate_E2C_VR__c from Queue_User_Relationship__c where Id = :queue_Id');
    }
    public Case getWatchUserDetails(String caseId){
        return Database.query('SELECT Id,Watch_List_User__c from Case where Id=: caseId');
    }
    public List<Case> getCaseDetailsUpdatePost(List<Id> caseIdSet){
        return Database.query('SELECT Id,UpdatePost__c FROM Case Where Id in :caseIdSet');
    }

    public List<Case> getOpenChildCases(Set<Id> caseIdSet){
        return Database.query('SELECT Id,ParentId,CaseNumber FROM Case Where ParentId in :caseIdSet and IsClosed = false');
    }

    public static Case fetchCase(Id caseId) {
        return [select Id,BusinessHoursId, Entitlement.BusinessHoursId, Priority,Urgency__c,ETA_Date__c,CreatedDate,SlaStartDate,(select BusinessHoursId,MilestoneTypeId from CaseMilestones) from Case where Id = :caseId];
    }
}