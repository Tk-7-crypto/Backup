/*
 * Version       : 1.0
 * Description   : Apex Controller for Create Bid screen.
 */
public class CNT_OWF_CreateAgreementFromOpp {
    
    public CNT_OWF_CreateAgreementFromOpp(ApexPages.StandardController controller) {
        
    }
    /**
     * This method is used to retrieve the eligible record types of Agreement that can be created
     * based on the current stage of Opportunity
     * @params  
     * @params  List<String> fieldList
     * @return  List<String> recordTypes
     */
    private static String businessArea {get;set;}
    @AuraEnabled
    public static List<BidTypeWrapper> getEligibleRecordTypes(Id opportunityId, List<String> oppFields) {
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();        
        Opportunity opportunityRecord = new Opportunity();
        List<BidTypeWrapper> bidTypeList = new List<BidTypeWrapper>();
        OWF_Config__c releaseVersion = OWF_Config__c.getInstance();
        //Set<String> agrRecordTypeName = new Set<String>();
        //try {
            idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{opportunityId}, new Set<String>(oppFields));
            if(idToOpportunityMap.size() > 0) {
                opportunityRecord = idToOpportunityMap.get(opportunityId);
                Set<String> oppStageToBidTypeMapFieldSet = new Set<String>{'DeveloperName', 'MasterLabel', 'Opp_Stage__c', 'Agreement_Record_Type__c','Bid_Header_and_Desc__c'};
                Map<String,List<Opp_Stage_to_Bid_Type_Mapping__mdt>> oppStageToBidTypeMap = new Map<String,List<Opp_Stage_to_Bid_Type_Mapping__mdt>>();
                    
                    for(Opp_Stage_to_Bid_Type_Mapping__mdt oppStageToBidType :
                        new SLT_OppStageToBidTypeMapping(true, false).getOppStageToBidTypeMappings(oppStageToBidTypeMapFieldSet)) {
                            if(!oppStageToBidTypeMap.containsKey(oppStageToBidType.Opp_Stage__c)) {
                                oppStageToBidTypeMap.put(oppStageToBidType.Opp_Stage__c,new List<Opp_Stage_to_Bid_Type_Mapping__mdt>());
                                oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType);
                            }
                            else {
                                oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType);
                            }
                     }
                    
                    Map<String, Schema.RecordTypeInfo> agrRecordTypes = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByName();
                    boolean hasPermission =false;
                    List<PermissionSetAssignment> permissionSetList = new SLT_PermissionSetAssignment().selectByPermissionSetsForUserId(new Set<String>{'PermissionSet.Name'},new set<ID>{UserInfo.getUserId()},new Set<String>{'OWF_Sales_User_with_PSA_Access','OWF_Tech_Solution_Users','Apttus_CLM_AMA_Permission_Set','Apttus_CLM_AMESA_Permission_Set','Apttus_CLM_Base_Permission_Set','CLM_Permission_GSA_Author'});
                    if(!permissionSetList.isEmpty()){
                        hasPermission = true;
                    }
            
                    if(!hasPermission){
                        Profile currentProfile = new SLT_Profile().selectById(new Set<ID>{UserInfo.getProfileId()})[0];
                        if(CON_OWF.PROFILES_HAVING_BID_CREATION_ACCESS.contains(currentProfile.Name)){
                            hasPermission = true;
                        }
                    }
            
                    if(oppStageToBidTypeMap.containsKey(opportunityRecord.stageName.substring(0,1))) {
                        for(Opp_Stage_to_Bid_Type_Mapping__mdt agrRecordType : oppStageToBidTypeMap.get(opportunityRecord.stageName.substring(0,1))) {
                            if(Double.valueOf(releaseVersion.Current_Release__c) <= CON_GLOBAL.RELEASE_NOV_2023 && agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId() == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID) {
                                Continue;
                            }
                            else {
                                if(hasPermission){
                                    bidTypeList.add(new BidTypeWrapper(agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId(),agrRecordType.Agreement_Record_Type__c,agrRecordType.Bid_Header_and_Desc__c));
                                }
                                else if(!hasPermission && agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId() == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
                                    bidTypeList.add(new BidTypeWrapper(agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId(),agrRecordType.Agreement_Record_Type__c,agrRecordType.Bid_Header_and_Desc__c));
                                }
                            }
                        }
                    }
                    if(oppStageToBidTypeMap.containsKey(opportunityRecord.stageName.substring(0,2))) {
                        for(Opp_Stage_to_Bid_Type_Mapping__mdt agrRecordType : oppStageToBidTypeMap.get(opportunityRecord.stageName.substring(0,2))) {
                            if(Double.valueOf(releaseVersion.Current_Release__c) <= CON_GLOBAL.RELEASE_NOV_2023 && agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId() == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
                                 Continue;
                            }
                            else {
                                if(hasPermission){
                                    bidTypeList.add(new BidTypeWrapper(agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId(),agrRecordType.Agreement_Record_Type__c,agrRecordType.Bid_Header_and_Desc__c));
                                }
                                else if(!hasPermission && agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId() == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID){
                                    bidTypeList.add(new BidTypeWrapper(agrRecordTypes.get(agrRecordType.Agreement_Record_Type__c).getRecordTypeId(),agrRecordType.Agreement_Record_Type__c,agrRecordType.Bid_Header_and_Desc__c));
                                }
                            }
                        }
                    } 
        }
        /*} catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }*/
        bidTypeList.sort();
        return bidTypeList;
    }
    /**
     * This method is used to return the validation on Opportunity
     * @params  Id opportunityId
     * @params  String recordTypeId
     * @return  Boolean
     */
    @AuraEnabled
    public static Boolean validateOpportunity(Id opportunityId, String recordTypeId) {
        Set<String> oppStageToBidTypeMapFieldSet = new Set<String>{ 'Opp_Stage__c', 'Agreement_Record_Type__c' };
        Map<String,Set<String>> oppStageToBidTypeMap = new Map<String,Set<String>>();
        for(Opp_Stage_to_Bid_Type_Mapping__mdt oppStageToBidType :
                        new SLT_OppStageToBidTypeMapping(true, false).getOppStageToBidTypeMappings(oppStageToBidTypeMapFieldSet)) {
                            if(!oppStageToBidTypeMap.containsKey(oppStageToBidType.Opp_Stage__c)) {
                                oppStageToBidTypeMap.put(oppStageToBidType.Opp_Stage__c,new Set<String>());
                                oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType.Agreement_Record_Type__c);
                            }
                            else {
                                oppStageToBidTypeMap.get(oppStageToBidType.Opp_Stage__c).add(oppStageToBidType.Agreement_Record_Type__c);
                            }
                     }
            Opportunity opp = [Select id, StageName from Opportunity where id = :opportunityId];

            if(CON_OWF.BIDS_DIRECTLY_CREATED_WITH_DEPENDING_ON_OPP_STAGE.contains(recordTypeId)) {
                return false;
            }
            if(!CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(recordTypeId)) {
                return false;
            }
            
            if(oppStageToBidTypeMap.containsKey(opp.StageName.substring(0,1)) && oppStageToBidTypeMap.get(opp.StageName.substring(0,1)).contains(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName()))
            {
            return false;
            }
            else if(oppStageToBidTypeMap.containsKey(opp.StageName.substring(0,2)) && oppStageToBidTypeMap.get(opp.StageName.substring(0,2)).contains(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName()))
            {
            return false;
            }
                     
            return true;
    }
    /**
     * This method is used to return the validation on Recordtype
     * @params  String recordTypeId
     * @return  Boolean
     */
    @AuraEnabled
    public static Boolean validateRecordType(String recordTypeId) {
        if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(recordTypeId))
        {
            return true;
        }
        return false;
    }
     /**
     * This method is used to return the validation on Recordtype
     * @params  String recordTypeId
     * @return  Boolean
     */
    @AuraEnabled
    public static String getRecorTypeName(String recordTypeId) {
        String name = String.valueOf(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName());
        if(name == 'Clinical Bid')
        {
            return Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosByName().get('Clinical').getRecordTypeId();
        }
        else if(name == 'RFI Request')
        {
            return Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosByName().get('RFI').getRecordTypeId();
        }
        else 
        {
            return recordTypeId;
        }
    }
    /**
     * This method is used to get details of current oppty
     * @params  Id opportunityId
     * @params  List<String> oppFields
     * @return  Opportunity oppty
     */
    @AuraEnabled
    public static Id getAccountId(Id opportunityId, List<String> oppFields) {
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();        
        Opportunity opportunityRecord = new Opportunity();
        idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{opportunityId}, new Set<String>(oppFields));
        if(idToOpportunityMap.size() > 0) {
            opportunityRecord = idToOpportunityMap.get(opportunityId);
        }
        return opportunityRecord.Account.id;
    }
    
    /**
* This method is used to validate fields of Line Item Group for Clinical Bid 
* @params  Id opportunityId
* @params  Id recordTypeId
* @return  String
*/
    @AuraEnabled
    public static String validateLIGForClinicalAgreement(Id opportunityId, Id recordTypeId)
    {
        String errorMessage = '';
        String name = String.valueOf(Schema.getGlobalDescribe().get('Bid_History__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName());
        
        if(name == 'Clinical'  || name == 'Clinical Bid' || name == 'CSMS' || name == 'CSMS Bid' || name == 'OCT RFx' || name == 'OCT RFx Bid'|| name=='GCC' || name=='CSS') 
        {
            List<String> oppLIGValidationMessage = UTL_OWF.validateLIGForClinicalAgreement(opportunityId,name);
            Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
           
            if((oppLIGValidationMessage!=null && oppLIGValidationMessage.size()>0) && oppLIGValidationMessage[0] == '6')
            {
                return oppLIGValidationMessage[0];
            }
            else if((oppLIGValidationMessage!=null && oppLIGValidationMessage.size()>0) && !mulesoftSetting.Ignore_Validation_Rules__c){
                throw new AuraHandledException(string.join(oppLIGValidationMessage,'\n'));
            }     
        }
        if(name == CON_OWF.RECORD_TYPE_Q2_SOLUTION){
            List<String> oppLIGValidationMessage = UTL_OWF.validateLQOppForBidHistory(opportunityId,name);
            Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
            if((oppLIGValidationMessage!=null && oppLIGValidationMessage.size()>0) && !mulesoftSetting.Ignore_Validation_Rules__c){
                throw new AuraHandledException(string.join(oppLIGValidationMessage,'\n'));
            }   
        }
        
        return errorMessage;
    }
    
    
    /**
* This method is used to get pre-populate the fields
* @params  Id opportunityId
* @params  Id recordTypeId
* @return  String
*/
    @AuraEnabled
    public static String getDefaultFieldValues(Id opportunityId, Id recordTypeId) {

        Schema.RecordTypeInfo recordTypeInfo = Schema.SObjectType.Bid_History__c.getRecordTypeInfosById().get(recordTypeId);
        String rtDeveloperName = recordTypeInfo.getDeveloperName();
        List<OWF_ReBidFieldMapping__mdt> fieldMappingsForRecordType = new List<OWF_ReBidFieldMapping__mdt>();
        List<OWF_ReBidFieldMapping__mdt> rebidFieldMappingList = new SLT_OWF_ReBidFieldMapping(false,false).getReBidFieldMapping();
        Set<String> opportunityFieldSet = new Set<String>{'Id','AccountId','Is_this_IQVIA_Biotech__c', 'stageName', 'Q2_Budget_Tool__c','Full_Service__c','Q2_Bioscience_Location__c','Opportunity_Attributes__c','Amount'};
        Set<String> agreementFieldSet = new Set<String>{'Id', 'Bid_History_Related_Opportunity__c', 'Bid_History_Account__c', 'recordTypeId', 'Q2_Business_Area__c'};
        Set<String> accountFieldSet = new Set<String>{'Id'};
        Set<String> userFieldSet = new Set<String>{'Id'};
        
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeIdField('Bid_History_Related_Opportunity__c', opportunityId);
        
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoIdMap = Schema.SObjectType.Bid_History__c.getRecordTypeInfosById();
        Map<String, Id> recordTypeDevNameToIdMap = new Map<String, Id>();
        for(Id agrRecordTypeId : recordTypeInfoIdMap.keySet()) {
            recordTypeDevNameToIdMap.put(recordTypeInfoIdMap.get(agrRecordTypeId).getDeveloperName(), agrRecordTypeId);
        }
        String recordTypeName = rtDeveloperName;
        if(recordTypeName == 'Clinical_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('Clinical_Bid');
            recordTypeName = 'Clinical_Bid';
        }
        else if(recordTypeName == 'CSMS_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('CSMS_Bid');
            recordTypeName = 'CSMS_Bid';
        } else if(recordTypeName == 'RFI_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('RFI_Request');
            recordTypeName = 'RFI_Request';
        } else if(recordTypeName == 'CSS_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('CSS_Bid');
            recordTypeName = 'CSS_Bid';
        }
        else if(recordTypeName == 'GCC_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('GCC');
            recordTypeName = 'GCC';
        }
        else if(recordTypeName == 'Tech_Solutions_Support_Request_Short_Form') {
            recordTypeId = recordTypeDevNameToIdMap.get('Tech_Solutions_Support_Request');
            recordTypeName = 'Tech_Solutions_Support_Request';
        }
        if(rebidFieldMappingList.size() > 0){
            for(OWF_ReBidFieldMapping__mdt rebidMapping : rebidFieldMappingList){
                if(rebidMapping.RecordType__c == recordTypeName ){
                    fieldMappingsForRecordType.add(rebidMapping);
                    if(rebidMapping.SourceType__c == 'Field'){
                        if(rebidMapping.SourceObject__c == 'Agreement'){
                            agreementFieldSet.add(rebidMapping.SourceValue__c);
                        }
                        else if(rebidMapping.SourceObject__c == 'Opportunity'){
                            opportunityFieldSet.add(rebidMapping.SourceValue__c);
                        }
                        else if(rebidMapping.SourceObject__c == 'Account'){
                            accountFieldSet.add(rebidMapping.SourceValue__c);
                        }
                        else if(rebidMapping.SourceObject__c == 'User'){
                            userFieldSet.add(rebidMapping.SourceValue__c);
                        }     
                    }
                }
            }
        }
        Map<Id, Opportunity> opportunityMap = new SLT_Opportunity(false,false).selectByOpportunityId(new Set<Id>{opportunityId}, opportunityFieldSet);
        Opportunity oppRecord = opportunityMap.values()[0];
        //IQVIAPSA-2221 == start
        if(oppRecord.Name.length() > 80){
            oppRecord.Name = oppRecord.Name.substring(0, 80);
        }
		//IQVIAPSA-2221 == stop
		
        Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(new Set<Id>{oppRecord.AccountId}, accountFieldSet);
        Map<Id, Bid_History__c> agreementMap = new SLT_Bid_History(false,false).getAgreementByOppIDSortByCreatedDateDesc(new Set<Id>{opportunityId}, agreementFieldSet);
        Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()}, userFieldSet);
        User runningUser = userMap.values()[0];
        
        string IntakeAIMLAgreementResultsField = '';
        List<Schema.FieldSetMember> fieldset = Schema.SObjectType.Intake_AIML_Agreement_Results__c.fieldSets.IntakeAIMLAgreementResultsFields.getFields();            
        for (Schema.FieldSetMember objfieldset : fieldset){                
            IntakeAIMLAgreementResultsField = IntakeAIMLAgreementResultsField + objfieldset.getFieldPath() + ',';
        } 
        
        
        List <Intake_AIML_Agreement_Results__c> IntakeAIMLAgreementResultsList = new List <Intake_AIML_Agreement_Results__c>();
        string query = 'select '+IntakeAIMLAgreementResultsField.removeEnd(',')+' from Intake_AIML_Agreement_Results__c where Related_Opportunity__c=\''+opportunityId+ '\' order by CreatedDate limit 1'; 
        IntakeAIMLAgreementResultsList = Database.query(query);
        List <string> strlist = new List <string>();
        strlist.add('Call Center');
        
        gen.writeIdField('Bid_History_Account__c', oppRecord.AccountId);
        gen.writeBooleanField('Require_IQB_Services_Only__c', (oppRecord.Is_this_IQVIA_Biotech__c=='Yes'? true : false));
        
        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Patients_Screened__c != null && rtDeveloperName == 'Clinical_Short_Form')
        {
            gen.writeNumberField('Patients_Screened__c', IntakeAIMLAgreementResultsList[0].Patients_Screened__c);   
        }
        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Patients_Completed__c!= null &&  rtDeveloperName == 'Clinical_Short_Form')
        {
            gen.writeNumberField('Patients_Completed__c', IntakeAIMLAgreementResultsList[0].Patients_Completed__c);
        }
        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Patients_Enrolled__c!= null &&  rtDeveloperName == 'Clinical_Short_Form')
        {
            gen.writeNumberField('Patients_Enrolled__c', IntakeAIMLAgreementResultsList[0].Patients_Enrolled__c);
        }
        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].id!= null && rtDeveloperName == 'Clinical_Short_Form')
        {
            gen.writeStringField('Related_Opportunity__c', IntakeAIMLAgreementResultsList[0].id);   
        }
        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Requested_Internal_Services__c!= null && rtDeveloperName == 'Clinical_Short_Form')
        {            
            gen.writeStringField('Requested_Services__c', IntakeAIMLAgreementResultsList[0].Requested_Internal_Services__c);
        }

        if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Bid_Due_Date__c!= null && rtDeveloperName == 'Clinical_Short_Form')
        {            
            gen.writeDateField('Bid_Due_Date__c', IntakeAIMLAgreementResultsList[0].Bid_Due_Date__c);
        }
         if(!IntakeAIMLAgreementResultsList.isEmpty() && IntakeAIMLAgreementResultsList[0].Number_of_Sites__c!= null &&  rtDeveloperName == 'Clinical_Short_Form')
        {
            gen.writeNumberField('Number_of_Sites__c', IntakeAIMLAgreementResultsList[0].Number_of_Sites__c);
        }
        
        
        String bidType = 'Initial';
        Bid_History__c initialBidRecord = new Bid_History__c();
        for(Bid_History__c agreement : agreementMap.values()){
            if(agreement.RecordTypeId == recordTypeId){
                initialBidRecord = agreement;
                bidType = 'Rebid';
                break;
            }
        }
        
        Boolean isQ2BidExists = false;
        for(Bid_History__c agreement : agreementMap.values()){
            if(CON_OWF.Q2_BUSINESS_AREA_LIST.contains(agreement.Q2_Business_Area__c)){
                isQ2BidExists = true;
                businessArea = agreement.Q2_Business_Area__c;            
                break;
            }
        }
        
        String url='';
        if(bidType == 'Rebid'){
            url = System.URL.getOrgDomainUrl().toExternalForm()+''+PageReference.forResource('OWF_RFPMatrixRebid').getUrl();
        }
        else{
            url = System.URL.getOrgDomainUrl().toExternalForm()+''+PageReference.forResource('OWF_RFPMatrix').getUrl();
        }
        gen.writeStringField('RFP_Matrix__c', '<img alt="User-added image" src='+url+'></img>');
       
       if(recordTypeId == recordTypeDevNameToIdMap.get('Q2_Solutions')) {
            autopopulateQ2Fields(bidType, gen, oppRecord, isQ2BidExists);
        }
        Map<String, String> fieldDataTypeToFieldAPINameMap = new UTL_Sobject('Bid_History__c').getFieldDataTypeByFieldAPIName();
        for(OWF_ReBidFieldMapping__mdt rebidFieldMapping : fieldMappingsForRecordType) {
            String fieldValue = null;
            if(rebidFieldMapping.BidType__c != 'None' && rebidFieldMapping.BidType__c != bidType){
                continue;
            }
            if(rebidFieldMapping.SourceType__c == 'Value') {
                if(rebidFieldMapping.SourceValue__c == 'Today') {
                    fieldValue = Date.today().format();
                } else {
                    fieldValue = rebidFieldMapping.SourceValue__c;
                }
            } else {
                if(rebidFieldMapping.SourceObject__c == 'Opportunity') {
                    if(opportunityMap.containsKey(opportunityId)) {
                        if(rebidFieldMapping.SourceValue__c.contains('.')) {
                            List<String> fieldNames = rebidFieldMapping.SourceValue__c.split('\\.');
                            fieldValue = (String)opportunityMap.get(opportunityId).getSobject(fieldNames[0]).get(fieldNames[1]);
                        } else {
                            fieldValue = String.valueOf(opportunityMap.get(opportunityId).get(rebidFieldMapping.SourceValue__c));       
                        }
                    }
                } else if(rebidFieldMapping.SourceObject__c == 'Agreement') {
                    if(initialBidRecord != null) {  
                          fieldValue = String.valueOf(initialBidRecord.get(rebidFieldMapping.SourceValue__c) );
                    }
                    
                } else if(rebidFieldMapping.SourceObject__c == 'Account') {
                    if(accountMap.containsKey(oppRecord.AccountId)) {
                        fieldValue = (String)accountMap.get(oppRecord.AccountId).get(rebidFieldMapping.SourceValue__c);
                    }
                } else if(rebidFieldMapping.SourceObject__c == 'User') {
                    fieldValue = (String)runningUser.get(rebidFieldMapping.SourceValue__c);
                }
            }
            String field = rebidFieldMapping.TargetField__c;
            String fieldType = fieldDataTypeToFieldAPINameMap.get(field.trim().toLowerCase());
            if(fieldValue == null) {
                gen.writeNullField(rebidFieldMapping.TargetField__c);
            } else if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal') {
                gen.writeNumberField(rebidFieldMapping.TargetField__c, Decimal.valueOf(fieldValue));
            } else if(fieldType == 'boolean') {
                gen.writeBooleanField(rebidFieldMapping.TargetField__c, Boolean.valueOf(fieldValue));
            } else if(fieldType == 'date') {
                if(rebidFieldMapping.SourceType__c == 'Value') {
                    try{
                    	gen.writeDateField(rebidFieldMapping.TargetField__c, Date.parse(fieldValue));                       
                    }
                    catch(System.TypeException e)
                    {
                        String[] arrDate = fieldValue.split('/');
                    	fieldValue = date.newinstance(Integer.valueOf(arrDate[2]), Integer.valueOf(arrDate[0]), Integer.valueOf(arrDate[1])).format();    
                        gen.writeDateField(rebidFieldMapping.TargetField__c, Date.parse(fieldValue));                       
                    }
                } else {
                    gen.writeDateField(rebidFieldMapping.TargetField__c, Date.valueOf(fieldValue));
                }
            } else {
                gen.writeStringField(rebidFieldMapping.TargetField__c, fieldValue);
            }
        }
        //gen.writeIdField('RecordTypeId', recordTypeId);
        gen.writeEndObject();
        return gen.getAsString();
    }
    @TestVisible
    private static void autopopulateQ2Fields(String bidType, JSONGenerator gen, Opportunity oppRecord, Boolean isQ2BidExists) {
        if(oppRecord.Q2_Budget_Tool__c == CON_OWF.BUDGET_TOOL_Q2_BIO || (isQ2BidExists == true &&  businessArea == CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE)) {
            autopopulateBioscienceFields(bidType, gen, oppRecord);
        }
        else if(oppRecord.Q2_Budget_Tool__c == CON_OWF.BUDGET_TOOL_VACCINES || (isQ2BidExists == true && businessArea == CON_OWF.Q2_BUSINESS_AREA_VACCINES)){
            autopopulateVaccinesFields(bidType, gen, oppRecord);
        }
        else if(CON_OWF.DISCOVERY_BUDGET_TOOLS_LIST.contains(oppRecord.Q2_Budget_Tool__c) || (isQ2BidExists == true && businessArea == CON_OWF.Q2_BUSINESS_AREA_DISCOVERY) ){
            autopopulateDiscoveryFields(bidType, gen, oppRecord);
        }       
    }         
    @TestVisible
    private static void autopopulateBioscienceFields(String bidType, JSONGenerator gen, Opportunity oppRecord) {
        autopopulateBidType(bidType, oppRecord, gen);
        gen.writeStringField('Q2_Business_Area__c', CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE);  
        if(oppRecord.Opportunity_Attributes__c != null && oppRecord.Opportunity_Attributes__c.contains('Blanket Opportunity')) {
            gen.writeStringField('Is_this_Blanket_Oppotunity__c', 'Yes');
        }
        else{
            gen.writeStringField('Is_this_Blanket_Oppotunity__c', 'No');
        } 
        if(oppRecord.Q2_Bioscience_Location__c !=null  &&oppRecord.Q2_Bioscience_Location__c.containsOnly('Indianapolis - ADME') ){               
            gen.writeStringField('ADME_Services__c','true');
            gen.writeStringField('Q2_Biosciences_Location__c','Indianapolis - ADME');
        }
        if(bidType!=CON_OWF.BID_TYPE_CHANGE_ORDER){
            gen.writeStringField('Bid_Stopped__c', 'No');
        }
    }          
    @TestVisible
    private static void autopopulateVaccinesFields(String bidType, JSONGenerator gen, Opportunity oppRecord) {
        gen.writeStringField('Q2_Business_Area__c', CON_OWF.Q2_BUSINESS_AREA_Vaccines);  
        autopopulateBidType(bidType, oppRecord, gen); 
        if(bidType!=CON_OWF.BID_TYPE_CHANGE_ORDER){
            gen.writeStringField('Bid_Stopped__c', 'No');
        }
    } 
    @TestVisible
    private static void autopopulateDiscoveryFields(String bidType, JSONGenerator gen, Opportunity oppRecord) {
        gen.writeStringField('Q2_Business_Area__c', CON_OWF.Q2_BUSINESS_AREA_DISCOVERY);  
        autopopulateBidType(bidType, oppRecord, gen); 
        if(bidType!=CON_OWF.BID_TYPE_CHANGE_ORDER){
            gen.writeStringField('Bid_Stopped__c', 'No');
        }
    }             
    private static void autopopulateBidType(String bidType, Opportunity oppRecord, JSONGenerator gen){
        if(oppRecord.stageName == CON_CRM.CLOSED_WON_STAGE || (oppRecord.StageName == CON_CRM.FINALIZING_DEAL_STAGE && oppRecord.Full_Service__c =='Yes')) {
            gen.writeStringField('Bid_Type__c', CON_OWF.BID_TYPE_CHANGE_ORDER); 
            Map<Id,Quote__c> latestAcceptedQuote = UTL_OWF.getLastAcceptedQuote(new Set<ID>{oppRecord.Id}); 
            if(latestAcceptedQuote.containsKey(oppRecord.Id) && latestAcceptedQuote.get(oppRecord.Id).TotalNetAmount__c!=null){
                Decimal convertedQuoteTotalNetAmount = UTL_OWF.getConversionQuoteTotalNetAmount(oppRecord.CurrencyIsoCode ,latestAcceptedQuote.get(oppRecord.Id));                   
                gen.writeStringField('Previous_value_for_Contract__c',String.valueOF(convertedQuoteTotalNetAmount)); 
            }
            else{
                if(oppRecord.Amount!=null){
                 gen.writeStringField('Previous_value_for_Contract__c',String.valueOF(oppRecord.Amount)); 
                }
            }
        }else{
            gen.writeStringField('Bid_Type__c', bidType == 'Rebid' ? CON_OWF.BID_TYPE_RE_BID : CON_OWF.BID_TYPE_INITIAL);
        }
    }              
    @AuraEnabled(cacheable=false)
    public static String redirectUserOnRTSelection(String recordTypeId) {
        return UTL_OWF.redirectUserOnRTSelection(recordTypeId);
    }

    @AuraEnabled
    public static List<Id> getCLMRecordTypeIdsForMVP() {
            return new List<Id>{CON_CLM.MSA_RECORDTYPEID, CON_CLM.AMA_RECORDTYPEID, CON_CLM.OSA_RECORDTYPEID, CON_CLM.VENDOR_RECORDTYPEID};
    }
    
    @AuraEnabled
    public static List<Id> getCLMRecordTypeIdsOfAvailableUsers() {
        List<Id> recordTypeIds = new List<Id>();
        for(RecordTypeInfo info: Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recordTypeIds.add(info.getRecordTypeId());
            }
        }
        return recordTypeIds;
    }
    
    @AuraEnabled
    public static String getAgreementServicesOptions() {
        Map<String, String> mapPicklistLabelValue = new Map<String, String>();
        String picklistValues;
        try {
            String msaRecordTypeId = String.valueOf(CON_CLM.MSA_RECORDTYPEID);
            mapPicklistLabelValue = UTL_CLM.getPicklistOptionsByRecordTypeId('Apttus__APTS_Agreement__c', msaRecordTypeId, 'Services__c');
            mapPicklistLabelValue.keySet().removeAll(CON_CLM.EMEA_SERVICES);
            picklistValues = String.join(new List<String>(mapPicklistLabelValue.keySet()), ';');
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return picklistValues;
    }
    
    @AuraEnabled
    public static String getRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }
    
    @AuraEnabled
    public static Map<String, Id> setDefaultLegalEntityValuesForMSA() {
        Map<String, Id> mapFinanceIQVIAEntity = new Map<String, Id>();
        Set<String> nameSet = new Set<String>{CON_CLM.LEGAL_ENTITY_1_NAME, CON_CLM.LEGAL_ENTITY_2_NAME, CON_CLM.LEGAL_ENTITY_3_NAME};
        Set<String> fieldSet = new Set<String>{'Id', 'Name'};
        Set<Id> recordTypeIds = new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID};

        try {
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetailsByName(nameSet, fieldSet, recordTypeIds);
            if(lstFinanceIQVIAEntity != null && lstFinanceIQVIAEntity.size() > 0) {
                for(Finance_IQVIA_Legal_Entity__c legalEntity : lstFinanceIQVIAEntity) {
                    mapFinanceIQVIAEntity.put(legalEntity.Name, legalEntity.Id);
                }
            }
        } 
        catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return mapFinanceIQVIAEntity;
    }
    
    @AuraEnabled
    public static String getAccountCurrency(Id accountId) {
        Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(new Set<Id>{accountId}, new Set<String>{
            'CurrencyIsoCode'});
        return accountMap.isEmpty() ? null : accountMap.get(accountId).CurrencyIsoCode;
    }
    
    public class BidTypeWrapper implements Comparable {
      @AuraEnabled public String name;
      @AuraEnabled public String typeId;
      @AuraEnabled public String bidHeader;
      @AuraEnabled public String bidDescription; 
      public Integer rtIndex;   
      public BidTypeWrapper(String typeIdParam, String nameParam, String bidHeaderAndDesc ){            
            typeId = typeIdParam;
            name = nameParam;
            String kept = bidHeaderAndDesc.substring( 0, bidHeaderAndDesc.indexOf(','));
            String remainder = bidHeaderAndDesc.substring(bidHeaderAndDesc.indexOf(',')+1, bidHeaderAndDesc.length()); 
          	rtIndex = Integer.valueof(remainder.substring(remainder.indexOf(',')+1,remainder.length()));
            //List<String> tempLabelList = bidHeaderAndDesc.split(',');
            bidHeader = kept;
            bidDescription = remainder.substring( 0, remainder.indexOf(','));
    }
    public Integer compareTo(Object compareTo) {
            BidTypeWrapper btWrapper = (BidTypeWrapper) compareTo;
            if (rtIndex == btWrapper.rtIndex ){
                return 0;
            } 
            if (rtIndex < btWrapper.rtIndex ){
                return -1;
            } 
            return 1;       
        }
    } 
}
