public class CNT_CSM_Dispatch {
    @AuraEnabled(cacheable=true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString ) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        
        try {
            String query = 'SELECT Id, ' + filterField+ ' FROM '+objectName + ' WHERE '+filterField+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 500';
            for(SObject s : Database.query(query)){
                RecordsData recordsData = new RecordsData();
                recordsData.value = String.valueOf(s.get('id'));
                recordsData.label = String.valueOf(s.get(filterField));
                recordsDataList.add(recordsData);
            }
        } 
        catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
        
        return recordsDataList;
    }
    
    public class RecordsData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
    public class wrapperClass{
        @AuraEnabled public user lstUser{get;set;}
        @AuraEnabled public Group lstGroup{get;set;}
    }
    
    
    
    @AuraEnabled
    public static List<String> getStatusPicklist(string recordId){
        List<Case> caseList = new SLT_Case().selectById(new Set<Id>{recordId});
        List<String> options = new List<String>();
        List<String> statusOption = (caseList[0].RecordTypeName__c == CON_CSM.S_DataCreateService_R_T)?new List<String>{'New','Coding','Verification','Rework','Review','Rejected','Closed'}:new List<String>{'New','In Progress','Awaiting','Internal Solution Provided','Resolved with Customer','Abandoned','Closed'};            
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pick: pList) {
            for(String validOption :statusOption){
                if(pick.getLabel() == validOption){
                    options.add(pick.getLabel());
                }
            }
        }
        return options;
    }
    @AuraEnabled
    public static List<Case> getCurrentStatus(String caseId){ 
        List<Case> caseStatus = [Select id, Status ,SubStatus__c,RecordTypeName__c, IsEscalated,Device__c,EnvironmentType__c, Internal_Follow_Up__c, ProductName__c,Subtype1__c,Subtype2__c from Case where id =:caseId];
        return caseStatus;
    }
    @AuraEnabled
    public static List<string> getSubStatusValue(){
        List<string> picList= getPickListOptions('SubStatus__c');
        return picList;
    }
    
    @AuraEnabled
    public static List<string> getSubStatusValueChange(string status){
        List<String> inprogresssubstatusOption = new List<String>{'Approved','Awaiting Internal Information','CIO','In QA','Product Development','Rejected','Response Received','Standard Change Request','Work Order'};
        List<String> awaitingsubstatusOption = new List<String>{'Approval','Client UAT Validation','Customer Info','Customer Confirmation to Close','Customer Template','Estimation Approval','External Vendor','Patch/Major release','Pending Problem Resolution','Schedule','SOW','Sprint/Dev Cycle Allocation'};
        List<String> resolvedsubstatusOption = new List<String>{'Root cause analysis','Pending Resolution Confirmation'};
        if(status == 'In progress'){
            return inprogresssubstatusOption; 
        }
        else if(status == 'Awaiting'){
            return awaitingsubstatusOption; 
        }
        else if(status == 'Resolved with customer'){
            return resolvedsubstatusOption; 
        }
        else{
            List<string> picList= getPickListOptions('SubStatus__c');
            return picList;
        }
        
    }
    
    @AuraEnabled
    public static List<string> getPreviousUserValue(){
        List<string> picList= getPickListOptions('Previous_User__c');
        return picList;
    }
    
    @AuraEnabled
    public static List<string> getOldCaseOwnerUser(String recordId){   
        List<CaseHistory__c> caseHistoryobj= new List<CaseHistory__c>();
        Set<string> piclistSet = new Set<string>();
        List<string> picList = new List<string>();
        caseHistoryobj = [Select OldCaseOwner__c,  OldCurrentQueue__r.Name, NewCaseOwner__c,Case__r.CaseNumber from CaseHistory__c where Case__r.Id =:recordId] ;   
        for(CaseHistory__c c :caseHistoryobj){
            piclistSet.add(c.OldCaseOwner__c);
            piclistSet.add(c.OldCurrentQueue__r.Name);
        } 
        if(piclistSet!= null){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        return picList;
    }
    @AuraEnabled
    public static List<string> getOldCaseOwner(String recordId){   
        List<CaseHistory__c> caseHistoryobj= new List<CaseHistory__c>();
        List<string> picList = new List<string>();
        Set<string> piclistSet = new Set<string>();
        caseHistoryobj = [Select OldCaseOwner__c,  OldCurrentQueue__r.Name, NewCaseOwner__c,Case__r.CaseNumber from CaseHistory__c where Case__r.Id =:recordId ] ;   
        for(CaseHistory__c c :caseHistoryobj){
            piclistSet.add(c.OldCaseOwner__c);
        }
        if(piclistSet!= null){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        
        return picList;
    }
    @AuraEnabled
    public static List<Group> getIdFromQueue(String recordId){
        List<Group> caseHistoryobj= new List<Group>();
        caseHistoryobj =[select Id,DeveloperName, Name from Group where Type = 'Queue'and Name =:recordId ]; 
        return caseHistoryobj;
    }
    
    @AuraEnabled
    public static List<User> getIdFromUser(String recordId){
        List<User> caseHistoryobj= new List<User>();
        caseHistoryobj =[select Id, Name from User where Name =:recordId ]; 
        return caseHistoryobj;
    }
    
    
    @AuraEnabled
    public static List<string> getPreviousQueueValue(String recordId){
        List<CaseHistory__c> caseHistoryobj= new List<CaseHistory__c>();
        List<string> picList = new List<string>();
        Set<string> piclistSet = new Set<string>();
        caseHistoryobj = [Select OldCaseOwner__c,  OldCurrentQueue__r.Name, NewCaseOwner__c,Case__r.CaseNumber from CaseHistory__c where Case__r.Id =:recordId ] ;   
        if(caseHistoryobj.size()!=0){
            for(CaseHistory__c c :caseHistoryobj){
                if(c.OldCurrentQueue__r.Name!=null){
                    piclistSet.add(c.OldCurrentQueue__r.Name);
                }
            }
        }
        if(piclistSet!= null){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        return picList;
    }
    
    @AuraEnabled
    public static List<string> getPreviousQueueAssignUser(String userId,String recordD){
        List<CaseHistory__c> caseHistoryobj= new List<CaseHistory__c>();
        List<string> picList = new List<string>();
        Set<string> piclistSet = new Set<string>();
        caseHistoryobj = [Select OldCaseOwner__c,  OldCurrentQueue__r.Name, NewCaseOwner__c,Case__r.CaseNumber from CaseHistory__c where Case__r.Id =:recordD and OldCaseOwner__c =:userId ] ;   
        if(caseHistoryobj.size()!=0){
            for(CaseHistory__c c :caseHistoryobj){
                if(c.OldCurrentQueue__r.Name!=null){
                    piclistSet.add(c.OldCurrentQueue__r.Name);
                }
            }
        }
        if(piclistSet!= null){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        return picList;
    }

    public static List<String> getPickListOptions(String fld){
        List<String> options =  new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fld).getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        for(Schema.picklistEntry pic:ple)
        {
            options.add(pic.getValue());
        }
        return options;
    } 
    
    @AuraEnabled
    public static List<Queue_User_Relationship__c> getPreviousQueueBasedOnUser(String recordId){
        List<Queue_User_Relationship__c> caseHistoryobj= new List<Queue_User_Relationship__c>();
        List<string> picList = new List<string>();
        Set<string> piclistSet = new Set<string>();
        List<Case> caseRecord = Database.query('select id,Owner__c,CaseOwnerType__c, Owner.Name,Owner.Type from case where id =:recordId and Owner.Type = \'User\'');
        if(!caseRecord.isEmpty()){
            caseHistoryobj = [select id,Name, User__c from Queue_User_Relationship__c where User__r.Name =: caseRecord[0].Owner.Name];
        }
        if(caseHistoryobj.size()!=0){
            for(Queue_User_Relationship__c c :caseHistoryobj){
                if(c.Name!=null){
                    piclistSet.add(c.Name);
                }
            }
        }
        if(!piclistSet.isEmpty()){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        return caseHistoryobj;
    }
    
    @AuraEnabled
    public static List<String> getPreviousQueueBasedOnAssignee(String recordId){
        List<Queue_User_Relationship__c> caseHistoryobj= new List<Queue_User_Relationship__c>();
        List<string> picList = new List<string>();
        Set<string> piclistSet = new Set<string>();
        caseHistoryobj = [select id,Name, User__c from Queue_User_Relationship__c where User__r.Name =: recordId] ;   
        if(caseHistoryobj.size()!=0){
            for(Queue_User_Relationship__c c :caseHistoryobj){
                if(c.Name!=null){
                    piclistSet.add(c.Name);
                }
            }
        }
        if(piclistSet!= null){
            for(String value : piclistSet){
                picList.add(value);
            }
        }
        return picList;
    }

    @AuraEnabled
    public static String Save(Case con,String recordId){
        Case c = [Select Status,ownerId,ProductName__c,Subtype1__c,Subtype2__c,PreviousQueueUser__c,Previous_User__c,Previous_Queue__c,Internal_Follow_Up__c,CaseNumber,CurrentQueue__c,CurrentQueue__r.RestrictFromQueues__c,CurrentQueue__r.RestrictFromTier__c,SubStatus__c,IsEscalated,TaskMilestone__c,RecordTypeName__c,SupportTier__c from case where Id =:recordId];
        
        if(c != null){
            c.Status = con.Status;
            if(con.SubStatus__c != null && con.SubStatus__c != c.SubStatus__c){
                c.SubStatus__c = con.SubStatus__c;
            }
            c.Previous_User__c = con.Previous_User__c;
            c.Previous_Queue__c = con.Previous_Queue__c;
            if(con.Internal_Follow_Up__c != c.Internal_Follow_Up__c){
                c.Internal_Follow_Up__c = con.Internal_Follow_Up__c;
            }
            c.IsEscalated = con.IsEscalated;
        }
        
        List<User> userData  = new List<User>();
        List<Group> groupData = new List<Group>();
        List<Group> dispatchGroupData = new List<Group>();
        List<Queue_User_Relationship__c> queueUser  = new List<Queue_User_Relationship__c>();
        wrapperClass wrapperobj = new wrapperClass();
        boolean isError = false, isReqFields = false;
        String formType = 'T2toT3';
        Map<String,String> tfieldMap = new Map<String,String>();
        if(c.CurrentQueue__c != null &&  c.CurrentQueue__r.RestrictFromTier__c != null){
            if(c.CurrentQueue__r.RestrictFromTier__c.contains(';')){
                String[] tiers = c.CurrentQueue__r.RestrictFromTier__c.split(';');
                if(tiers != null && tiers.size() > 0){
                    for( String t : tiers){
                        if(con.Previous_Queue__c.contains(t)){
                            isError = true;
                        }
                    }
                }
                
            }else if(con.Previous_Queue__c.contains(c.CurrentQueue__r.RestrictFromTier__c)){
                isError = true;
            }
        }
        if(con.Previous_Queue__c != null && c.CurrentQueue__c != null){
            List<Schema.FieldSetMember> fsList = null;
            if(con.Previous_Queue__c == 'Tech GLOBAL OneKey Governance T2a' && c.ProductName__c == 'ONEKEY' && c.SubType1__c == 'Service Request' && c.SubType2__c  == 'New Field Request'){
                fsList =  readFieldSet('OnekeyNewFieldRequest','CSM_Technology_Solutions_Form__c');
                formType = 'OnekeyNewFieldRequest';
                if(c.Status == CON_CSM.S_NEW){
                    c.Status = CON_CSM.S_IN_PROGRESS;
                }
                isError = true;
            }else if(c.CurrentQueue__r.RestrictFromQueues__c != null && c.CurrentQueue__r.RestrictFromQueues__c.containsIgnoreCase(con.Previous_Queue__c)){
                fsList =  readFieldSet('T2toT3','CSM_Technology_Solutions_Form__c');
                formType = 'T2toT3';
                isError = true;
            }
            if(fsList != null){
                for(Schema.FieldSetMember fsm : fsList)
                {
                    tfieldMap.put(fsm.getLabel(),fsm.getFieldPath());
                    isReqFields = true;
                }    
            }
            
        } 
        queueUser = [Select id ,Name,Tier__C,ByPassedRestrictFormTier__c from Queue_User_Relationship__c where Name = :con.Previous_Queue__c and Type__c ='Queue'];
        if(queueUser.size()!=0 && queueUser[0].ByPassedRestrictFormTier__c){
            isError = false;
        }
        if(isError && c.Status != CON_CSM.S_NEW && c.RecordTypeName__c != CON_CSM.S_DataCreateService_R_T){
            string que = '';
            if(!tfieldMap.isEmpty()){
                que=+',' + String.join(tfieldMap.values(), ',');
            }
            String query = 'SELECT Id' + que + ' from CSM_Technology_Solutions_Form__c Where Case__c = :recordId';
            List<CSM_Technology_Solutions_Form__c>  tsFormList = Database.query(query);
            List<string> reqFields = new List<string>();
            if(tsFormList.size() == 0){
                throw new AuraHandledException('Please create an escalation form to proceed the dispatch.');
            }else if(isReqFields && !tsFormList.isEmpty()){
                for(CSM_Technology_Solutions_Form__c ts : tsFormList){
                    for(String fd : tfieldMap.keySet()){
                        if(ts.get(tfieldMap.get(fd)) == null){
                            reqFields.add(fd);
                        }
                    }
                }
                if(!reqFields.isEmpty()){
                    if(formType == 'OnekeyNewFieldRequest'){
                        throw new AuraHandledException('Please fill all mandatory fields in Section Onekey New Field Request. Please review the form.');
                    }else{
                        throw new AuraHandledException('All fields in Section T2=>T3 and App Services are mandatory. Please review the form.');
                    }
                }
            }
        }
        
        try{
            userData = [Select id ,Name from User where Name = :con.Previous_User__c and ContactId = null];
            groupData = [Select id ,Name from Group where Name = :con.Previous_Queue__c and Type='Queue'];
            dispatchGroupData = [Select id ,Name from Group where Name = :con.PreviousQueueUser__c and Type='Queue'];
            if(c.Previous_User__c!=null){
                if(userData.size()!=0){
                    c.ownerId = userData[0].id;
                    wrapperobj.lstUser = userData[0];
                }
                if(groupData.size()!=0){
                    wrapperobj.lstGroup = groupData[0];
                }
                if(userData.size()==0 && groupData.size()!=0 ){
                    c.ownerId = groupData[0].id;
                }
                if(userData.size()!=0 && dispatchGroupData.size()!=0 ){
                    c.ownerId = dispatchGroupData[0].id;
                }
                if(queueUser.size()!=0){
                    c.CurrentQueue__c =queueUser[0].id;
                    if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && queueUser[0].Name != null){
                        if(queueUser[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                            if(c.TaskMilestone__c == null){
                                c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                            }else if(c.TaskMilestone__c != null){
                                c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                            }
                        }
                        String selectTask = DAOH_Case.SanofiTaskMilestone(queueUser[0].Name);
                        //c.SupportTier__c = (selectTask.containsIgnoreCase('T1') ? 'Tier 1': selectTask.containsIgnoreCase('T2') ? 'Tier 2':selectTask.containsIgnoreCase('T3') ? 'Tier 3':selectTask.containsIgnoreCase('T4') ? 'Tier 4' :'');
                        if(queueUser[0].Tier__C!= null) 
                            c.SupportTier__c = queueUser[0].Tier__C;
                        if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(selectTask)){
                            c.TaskMilestone__c += ';' + selectTask;
                        }else if(c.TaskMilestone__c == null){
                            c.TaskMilestone__c = selectTask; 
                        }
                        if(queueUser[0].Name == CON_CSM.S_TECH_GPSQ && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_TECH_GPSQ)){
                            if(c.TaskMilestone__c == null){
                                c.TaskMilestone__c = CON_CSM.S_TECH_GPSQ;
                            }else if(c.TaskMilestone__c != null){
                                c.TaskMilestone__c += ';' + CON_CSM.S_TECH_GPSQ;
                            }                    
                        }
                    }
                }
                c.AssignCaseToCurrentUser__c = true;
                c.CaseOwnerModifiedDate__c = System.now();
                c.CaseUpdatedTime__c = System.now();
                update c;
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(wrapperobj);
    }

    @AuraEnabled
    public static boolean getProfileName(){
        String profName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        Boolean hasCust = FeatureManagement.checkPermission('CSM_TECH_Escalation_Form_Access_for_EXT_Profile');
        if (profName != 'EXT Service User' || ( profName == 'EXT Service User' &&  hasCust)){
            return true;
        }else{
            return false;
        }
        
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    @AuraEnabled
    public static boolean checkUserFromCurrentQueue(string caseId){
       return CNT_CSM_TakeOwnership.checkUserFromCurrentQueue(caseId);
    }
    
}
