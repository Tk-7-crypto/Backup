public class CNT_CSM_CloneChildCasesFromParent {
    
    
    public class EXT_CSM_ChildCaseData {
        
        @AuraEnabled
        public String contactName{set; get;}
        @AuraEnabled
        public String contactId{set;get;}
        @AuraEnabled
        public String onBehalfOfName{set;get;}
        @AuraEnabled
        public String onBehalfOfId{set;get;}
        @AuraEnabled
        public String caseNumber{set;get;}
        @AuraEnabled
        public Integer Id{set;get;}
        @AuraEnabled
        public String siteName{set; get;}
        @AuraEnabled
        public String studyId{set; get;}
        @AuraEnabled
        public String sscId{set;get;}
        @AuraEnabled
        public String los {set;get;}
        @AuraEnabled
        public String template {set;get;}
        @AuraEnabled
        public String subType1 {set;get;}
        @AuraEnabled
        public String subType2 {set;get;}
        @AuraEnabled
        public String subType3 {set;get;}
        @AuraEnabled
        public String conUserRole {set;get;}
        @AuraEnabled
        public String subjectId {set;get;}
        @AuraEnabled
        public String siteAssignment {set;get;}
            
    }
    
    @AuraEnabled
    public static Case searchParentCase(String caseId){
        List<Case> caseL = new List<Case>();
        caseL = new SLT_Case().getCaseDetails(new List<String>{caseId});
        if(caseL != null && !caseL.isEmpty()){
            return caseL[0];    
        }else{
            return null;
        }    
        
    }
    
    @AuraEnabled
    public static List<EXT_CSM_ChildCaseData> insertChildCases(String caseId,String childData){
        if(childData != null){
            EXT_CSM_ChildCaseData[] lstFilters = (List<EXT_CSM_ChildCaseData>)System.JSON.deserializeStrict(childData, List<EXT_CSM_ChildCaseData>.Class);
            if(lstFilters != null){
                List<Case> cloneCaseList = new List<Case>();
                Case cloneCase = null;
                Map<Id,Case> caseMap = new Map<Id,Case>();
                Set<String> caseField = new Set<String>();
                List<String> fieldsList = new List<String>();
                List<Case> caseList = new List<Case>();
                Set<Id> sscrIds = new Set<Id>();
                List<EXT_CSM_ChildCaseData> lstdata = new List<EXT_CSM_ChildCaseData>();
                EXT_CSM_ChildCaseData data = null;
                String caseFieldString = 'Site_Assignment__c,AFU_TECH__c, Contact, Description, Origin,ParentId, Parent, Priority, Subject, SuppliedName, Type, CSAT_Responded__c, CSAT_Sent__c, CaseOriginatorEmail__c, CaseOriginatorName__c, CaseTaskAction__c, First_Escalation_Time__c, Milestone_Violation__c, TaskMilestone__c, Techno_Impact__c, Urgency__c, '+
                    'AFU_Next_Date__c, AFU_TimeStamp__c, Automated_FU_Email__c, CSM_QI_Data_Originator__c, Count_of_AFU__c, G_Inquiry_Investigation__c, Jira_Issue__c, Update_Survey_Sent_Date__c, Web2Case_Asset__c, Web2Case_CurrentQueue__c, Owner__c, ProductName__c, ServiceNow_Last_Updated_Date__c, Service_Now_Incident_Number__c, Service_Now_Type__c, SoftwareUpdatePatchHotFixNumber__c, StudyProtocolName__c, SubType1__c, SubType2__c, Version__c, Affects_Version__c, '+
                    'ActualElapsedTimeInDays__c, ActualElapsedTimeInHrs__c, ActualElapsedTimeInMins__c, CMDB__c, IfyeshowmanylookupsrequiredCorrec__c, RequireAction__c, ResolutionsharedwithCustomer__c, SubType3__c, SupportTier__c, Target_Date__c, AssignCaseToCurrentUser__c, AutoClosed__c, ComplexityLevel__c, ConsumerHealthData__c, Customer_Requested_Date__c, Describetheissuedifferenceindetail__c, IssuedDifferencepreresearchconducted__c, ResolutionCode__c, ServiceNow_Group__c, Workaround__c, '+
                    'Sponsor__c, SubcaseClasification__c, SupplierCustom__c, SupplierName__c, Supplier__c, SwitchAddGracePeriod__c, Tag__c, Timeline__c, TypeCustom__c, UserTrainedDate__c, NumberOfNotifications__c, OnBehalfOf__c, PlanEndDate__c, PlanStartDate__c, Plan_Name__c, PlannedFixDate__c, ProductPackSize__c, Release__c, SendResolutionEmail__c, Site__c, '+
                    'CreatedByGroup__c, CreatedDate__c, CustomerRequiredDate__c, CustomerUrgency__c, ForeignCallerId__c, Impact__c, ItemNumber__c, JIRANotes__c, NextNotificationDate__c, NovartisCaseType__c, BusinessHours__c, BusinessUntilDueDate__c, COREClassification__c, CORESubClassification__c, CaseSource__c, ChildCaseDescription__c, CloseCode__c, CloseNotes__c, ConfigurationItem__c, CoreTicket__c, '+
                    'ACN__c, Activity__c, AdditionalThirdPartyCase2__c, Approach__c, SlaStartDate, Source, Subject, SuppliedEmail, BusinessHours, Contact, Description, Entitlement, IsEscalated, IsStopped, Origin, Parent, Priority, RandD_Location__c, AdditionalThirdPartyCase__c, BusinessHours__c, CaseSource__c, CaseSubType1__c, '+
                    'AccessionNumber__c, Case_CategorizationId__c, CurrentQueue1__c, CurrentQueue__c, IncompleteAMF__c, ProductName__c, Site_Related_to_the_Study__c, SubType1__c, SubType2__c, SubType3__c, ReOpenDate__c, ReOpened__c, ReOpener__c, Resolution__c, SendAutomaticAcknowledgmentEmail__c, SendResolutionEmail__c, Study__c, SubStatus__c, Template__c, ThirdPartyCase__c, '+
                    'CaseSubType2__c, CaseSubType3__c, ClosedBy__c, Current_Queue__c, FollowUpDateLevel__c, LIMSLevel__c, LOS__c, LastModifiedDate__c, NoContactKnown__c, Contact_User_Role__c, Subject_ID__c, Region_Supported__c';
                fieldsList = caseFieldString.split(',');
                for(String field : fieldsList){
                    caseField.add(field.trim());
                }
                caseMap = new SLT_Case().getCaseById(new Set<Id>{caseId},caseField); 
                for(EXT_CSM_ChildCaseData st : lstFilters){
                    if(st.sscId != null && st.sscId.length() > 0){
                        sscrIds.add(st.sscId);
                    }
                }
                Map<Id, StudySiteContactRelationship__c> ssRMap = new SLT_StudySiteContactRelationship().selectByStudySiteContactRelationshipId(sscrIds,new Set<String>{'Id','Name','Study__c'});
                
                for(EXT_CSM_ChildCaseData excs : lstFilters){
                    cloneCase = caseMap.values()[0].clone();
                    cloneCase.CreateChildCase__c = true;
                    cloneCase.ParentId = caseMap.values()[0].ParentId != null ? caseMap.values()[0].ParentId : caseId;
                    if(excs.contactId != null && excs.contactId.length() > 0){
                        cloneCase.ContactId = excs.contactId;
                        if(cloneCase.NoContactKnown__c){
                            cloneCase.NoContactKnown__c = false;
                        }
                    }
                    if(excs.onBehalfOfId != null && excs.onBehalfOfId.length() > 0){
                        cloneCase.OnBehalfOf__c = excs.onBehalfOfId; 
                    }else{
                        cloneCase.OnBehalfOf__c = null;  
                    }
                    if(excs.sscId != null && excs.sscId.length() > 0){
                        cloneCase.Site_Related_to_the_Study__c = excs.sscId;
                    }else{
                        cloneCase.Site_Related_to_the_Study__c = null;  
                    }
                    if(excs.los != null){ cloneCase.LOS__c = excs.los; }
                    if(excs.template != null){ cloneCase.Template__c = excs.template; }
                    if(excs.subType1 != null){ cloneCase.SubType1__c = excs.subType1; }
                    if(excs.subType2 != null){ cloneCase.SubType2__c = excs.subType2; }
                    if(excs.subType3 != null){ cloneCase.SubType3__c = excs.subType3; }
                    if(excs.conUserRole != null){ cloneCase.Contact_User_Role__c = excs.conUserRole; }
                    if(excs.subjectId != null){ cloneCase.Subject_ID__c = excs.subjectId; }
                    if(excs.siteAssignment != null){ cloneCase.Site_Assignment__c = excs.siteAssignment; }
                    cloneCase.Owner__c = 'BulkCase';
                    if(ssRMap != null && !ssRMap.isEmpty() && ssRMap.containsKey(excs.sscId) ){
                        cloneCase.Study__c = ssRMap.get(excs.sscId).Study__c;
                    }else{
                        cloneCase.Study__c = null;
                    }
                    cloneCase.Status = CON_CSM.S_NEW;
                    cloneCase.SubStatus__c = '';
                    cloneCase.ClosedDate = null;
                    cloneCase.IsStopped = false;
                    cloneCase.StoppedTimeInDays__c = null;
                    cloneCase.StoppedTimeInHrs__c = null;
                    cloneCase.StoppedTimeInHrs__c = null;
                    cloneCase.Service_Now_Incident_Number__c = null;
                    cloneCase.ServiceNow_Group__c = null;
                    cloneCase.ServiceNow_Last_Updated_Date__c = null;
                    cloneCase.Service_Now_Type__c = null;
                    cloneCase.CloseCode__c = null;
                    cloneCase.Customer_Requested_Date__c = null;
                    cloneCase.CloseNotes__c = null;
                    cloneCase.SlaStartDate = null;
                    cloneCaseList.add(cloneCase);
                }
                try{
                    if(!cloneCaseList.isEmpty()){
                        insert cloneCaseList; 
                    }    
                    List<String> caseIds = new List<String>();
                    for(Case c : cloneCaseList){
                        caseIds.add(c.Id);
                    }
                    
                    caseList = new SLT_Case().getCaseDetails(caseIds);
                    integer i = 1;
                    //String contactName = '',onBeName = '';
                    for(Case c : caseList){
                        //contactName = '';
                        data = new EXT_CSM_ChildCaseData();
                        data.Id = i;
                        data.caseNumber = c.CaseNumber;
                        data.contactId = c.ContactId;
                        //contactName += c.Contact.FirstName != null ? c.Contact.FirstName : '';
                        //contactName += c.Contact.LastName != null ? ' ' + c.Contact.LastName : '';
                        data.contactName = c.Contact.Name;
                        data.onBehalfOfId = c.OnBehalfOf__c;
                        //onBeName += c.OnBehalfOf__r.FirstName != null ? c.OnBehalfOf__r.FirstName : '';
                        //onBeName += c.OnBehalfOf__r.LastName != null ? ' ' + c.OnBehalfOf__r.LastName : '';
                        data.onBehalfOfName = c.OnBehalfOf__r.Name;
                        data.siteName = c.Site_Related_to_the_Study__r.Name;
                        data.studyId = c.Study__c;
                        data.sscId = c.Site_Related_to_the_Study__c;
                        data.los = c.Los__c;
                        data.template = c.Template__c;
                        data.subType1 = c.SubType1__c;
                        data.subType2 = c.SubType2__c;
                        data.subType3 = c.SubType3__c;
                        data.conUserRole = c.Contact_User_Role__c;
                        data.subjectId = c.Subject_ID__c;
                        data.siteAssignment = c.Site_Assignment__c;
                        lstdata.add(data);
                        i++;
                    }
                }catch (DmlException ex){
                    throw new DmlException(ex.getMessage());
                }
                return lstdata;    
            }else{
                return null;
            }
        } else {
            return null;
        } 
    }
    
    @AuraEnabled
    public static List<AggregateResult> getCategorizationWithAggregate(String q){
        try {
           return new SLT_CaseCategorization().selectWithAggregate(q);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        return CNT_CSM_CaseCategorization.getDependentOptionsImpl(objApiName, contrfieldApiName, depfieldApiName);
    }
    
    @AuraEnabled
    public static List <String> getPiklistValues(String objName, String fieldName) {
        List<String> plValues = new List<String>();
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(fieldName).getDescribe();
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
}
