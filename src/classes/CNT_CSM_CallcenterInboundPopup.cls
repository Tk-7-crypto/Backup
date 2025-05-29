public class CNT_CSM_CallcenterInboundPopup {
    
    public String greetingText {get; set;}
    public List<Contact> contacts {get; private set;}
    public List<Case> cases {get; private set;}
    public Boolean displayPopup {get;set;}
    public List<EXT_CSM_CheckboxDetails> recordTypes {get;set;}
    public String selectedRecord {get;set;}
    public List<InboundNumber__c> inboundList =null;
    public String RecordTypeName  {get;set;}
    public String callCenterValue {get; set;}
    Public String jsonString {get; set;}
    public class EXT_CSM_TwilioCallCenter{
        String contactChannelAddress {get; set;}
        String dialed_number {get; set;}
        String project_code {get; set;}
        String country {get; set;}
        String language {get; set;}
        String Overflow {get; set;}
        String Queue {get; set;}
        String study_protocol_name {get; set;}
        String line_of_service {get; set;}
        String call_recording_consent  {get; set;}
        String originalLanguage {get; set;}
    }
    
    
    public CNT_CSM_CallcenterInboundPopup() {
        
        //System.debug('ApexPages.currentPage().getParameters() : '+ApexPages.currentPage().getParameters());
        jsonString = ApexPages.currentPage().getParameters().get('callCenterValues');
        EXT_CSM_TwilioCallCenter tcc = null;
        if(jsonString != null){
            tcc = (EXT_CSM_TwilioCallCenter)JSON.deserialize(jsonString, EXT_CSM_TwilioCallCenter.class);
            inboundList = [select id, greeting_text__c,Study__c,LOS__C,Salesforce_LOS__c  from inboundnumber__c where project__c =:tcc.project_code and language__c=:tcc.language and queue__c=:tcc.Queue and study__c=:tcc.study_protocol_name and los__c=:tcc.line_of_service];
        }
        
        /*System.debug('callerId : '+callerId +'pq__c pv1 : '+pv1+' pv2 : '+pv2 +' project__c pv3 : '+pv3+' country__c pv4 : '+pv4+' language__c pv5 : '+ pv5+' queue__c pv6 : '+pv6 +' study__c pv7 : '+pv7+' los__c pv9 : '+pv9);
        inboundList = [select id, greeting_text__c,Study__c,LOS__C,Salesforce_LOS__c  from inboundnumber__c where project__c =:tcc.project_code and country__c=:tcc.country and language__c=:tcc.language and queue__c=:tcc.Queue and study__c=:tcc.study_protocol_name and los__c=:tcc.line_of_service];
        System.debug('inboundList : '+inboundList); */
        Map<Id,Contact> mapContact = null;
        if(tcc != null && tcc.contactChannelAddress != null){
            mapContact = new SLT_Contact().selectByMobile(tcc.contactChannelAddress.replaceAll('\\D', ''));
        }
        if(mapContact != null && mapContact.isEmpty() == false){
            cases = new SLT_Case().selectByContactId(mapContact.keySet());  
            contacts = mapContact.values();
        }
        
        EXT_CSM_CheckboxDetails record=null;
        recordTypes = new List<EXT_CSM_CheckboxDetails>();
        for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                if('Master' != info.getName()){
                    record = new EXT_CSM_CheckboxDetails(String.valueOf(info.getRecordTypeId()),info.getName(),false);
                    recordTypes.add(record);
                    //System.debug('record value : '+record.value + ' record Label : '+record.Label + ' record Checked'+record.Checked);
                }
                
            }
        }
        if(recordTypes.isEmpty() == false){
            recordTypes[recordTypes.size() - 1].checked = true;
            selectedRecord = recordTypes[recordTypes.size() - 1].value;
            RecordTypeName = recordTypes[recordTypes.size() - 1].Label;
            //System.debug('Label : '+selectedRecord + ' value'+RecordTypeName);
        }
        if (inboundList != null && inboundList.size() > 0) {
            //System.debug('found one match for inbound number');
            greetingText = inboundList[0].greeting_text__c;
        }else {
            inboundList = [select id, greeting_text__c,Study__c,LOS__c,Salesforce_LOS__c  from inboundnumber__c where pq__c='DEFAULT'];
            greetingText = inboundList[0].greeting_text__c;    
        }
        if(greetingText.contains('_______')){
            greetingText= greetingText.replaceAll('_______', '<b>'+UserInfo.getName()+'</b>');
        }
    }
    
    public void displayPopUpModel() {
        displayPopup = true;
    }
    public void closePopUpModel() {
        displayPopup = false;
    } 
    public PageReference createCase() {
        
        if(recordTypes != null && recordTypes.isEmpty() == false && recordTypes.size() == 1){
            selectedRecord =  recordTypes[0].value;
        }
        
        for(EXT_CSM_CheckboxDetails record : recordTypes){
            if(record.value == selectedRecord){
                RecordTypeName = record.Label;
            }else if(selectedRecord == null && record.checked == true){
                selectedRecord = record.value;
                RecordTypeName = record.Label;
            }   
        } 
        
        Case newCase = new Case();
        
        if(RecordTypeName != null && (CON_CSM.S_R_D_ASSISTANCE_R_T == RecordTypeName || CON_CSM.S_R_D_ACTIVITY_R_T == RecordTypeName))
        {
            
            List<Study__c> study = (inboundList.isEmpty() == false && inboundList[0].Study__c != null) ? new SLT_StudyC().selectAccountByStudyName(inboundList[0].Study__c,new Set<String>{'Id','Name'}) : null;
            if(study != null && study.isEmpty() == false){
              newCase.Study__c = study[0].Id;  
            }  
            if((inboundList != null && inboundList.isEmpty() == false && inboundList[0].LOS__c != null)){
                newCase.LOS__c = inboundList[0].Salesforce_LOS__c;
            }  
            
        }else if(RecordTypeName != null && (CON_CSM.S_DATA_CASE_R_T == RecordTypeName || CON_CSM.S_TECHNOLOGY_R_T == RecordTypeName) && contacts != null && contacts.size() == 1){
            newCase.AccountId = contacts[0].AccountId;
        }
        if(RecordTypeName != null && CON_CSM.S_TECHNOLOGY_R_T == RecordTypeName){
            newCase.PhoneVerification__c = true;
            newCase.CSHSubType__c = 'TwilioCallCenter';
        }
        if(contacts != null && contacts.size() == 1){
            newCase.ContactId = contacts[0].Id;
        }
        newCase.RecordTypeId = selectedRecord;
        newCase.Origin = CON_CSM.S_PHONE;
        
        try{
            insert newCase;    
        }catch(Exception e){
            
        }
        return new PageReference('/' + newCase.id);
    }
}