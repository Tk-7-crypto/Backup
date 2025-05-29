public without sharing class CNT_OWF_GenericCollectionTool {
    private final static String BID_HISTORY = 'Bid_History__c';
    private final static String COLLECTION_TOOL = 'CollectionTool__c';
	@testVisible private final static String MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE = 'Q2_Solutions_BioSciences';
    @testVisible private final static String MDT_CONFIG_NAME_GCC_COUNTRIES_IN_SCOPE = 'GCC_Countries_in_Scope';
    @testVisible private final static String MDT_CONFIG_NAME_Q2SOLUTIONS_VACCINES = 'Q2_Solutions_Vaccines';
    @testVisible private final static String MDT_CONFIG_NAME_Q2SOLUTIONS_DISCOVERY = 'Q2_Solutions_Discovery';
    @testVisible private final static String MDT_CONFIG_NAME_Q2SOLUTIONS_PROTEIN_SCIENCE = 'Q2_Solutions_Protein_Sciences';


    
    @AuraEnabled
    public static List<String> getConfig(Id bidHistoryId){
        try {
          return getConfigList(bidHistoryId);
        } catch(QueryException e) {
            throw new AuraHandledException('Invalid bid history');
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static OWF_GenericCollectionToolHelper.CollectionToolData getCollectionData(Id bidHistoryId, String config){
        String configName;
        try {
            configName = config == null ? getConfigName(bidHistoryId) : config;
            OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistoryId, configName);
          return helper.getCollectionData();
        } catch(QueryException e) {
            throw new AuraHandledException('Invalid bid history');
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<OWF_GenericCollectionToolHelper.CollectionTable> saveCollectionData(Id bidHistoryId, String collectionTablesJSON, String config){
        try {
            String configName;
            configName = config == null ? getConfigName(bidHistoryId) : config;
		    OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistoryId, configName);
            return helper.saveCollectionData(collectionTablesJSON);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static String getConfigName(String bidHistoryId) {
        String configName = '';
        Set<String> fields = new Set<String>{
            'RecordTypeId',
            'Q2_Business_Area__c',
            'Q2_Budget_Tools__c'
        };
        Bid_History__c bidHistory =  new SLT_Bid_History(false, false).getBidHistoryDetails(bidHistoryId, fields);
        if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE) {
            configName = MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE;
        }
        if(bidHistory.RecordTypeId == CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID) {
            configName = MDT_CONFIG_NAME_GCC_COUNTRIES_IN_SCOPE;
        }
        if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA_VACCINES) {
            configName = MDT_CONFIG_NAME_Q2SOLUTIONS_VACCINES;
        }
        if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA_DISCOVERY) {
            configName = MDT_CONFIG_NAME_Q2SOLUTIONS_DISCOVERY;
        }
        if(bidHistory.RecordTypeId == CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID && bidHistory.Q2_Business_Area__c == CON_OWF.Q2_BUSINESS_AREA_DISCOVERY && bidHistory.Q2_Budget_Tools__c == CON_OWF.BUDGET_TOOL_PROTEIN_SCIENCES) {
            configName = MDT_CONFIG_NAME_Q2SOLUTIONS_PROTEIN_SCIENCE;
        }
        if(String.isNotBlank(configName)) {
            return configName;
        } else {
            throw new CustomException('Something went wrong, please try again.');
        }
    }
    
    private static List<String> getConfigList(String bidHistoryId) {
        List<String> types = new List<String>();
        Set<String> fields = new Set<String>{
            'RecordTypeId',
            'Q2_Business_Area__c',
            'Record_Type_Developer_Name__c',
            'System_Implementation_Type__c',
            'Q2_Business_Area__c',
            'PCS__c',
            'IRT__c',
            'Complete_Consent__c',
            'eCOA__c',
            'Connected_Devices__c',
            'Grant_Plan__c',
            'eTMF__c',
            'Q2_Budget_Tools__c',
            'Site_Portal__c',
            'Clinical_Trial_Payments__c',
            'IRT__c',
            'One_Home_for_Sites__c',
            'Participant_Payments__c',
			'Risk_Based_Monitoring__c',							
            'Payments_Forecasting__c' 
        };
        Bid_History__c bidHistory =  new SLT_Bid_History(false, false).getBidHistoryDetails(bidHistoryId, fields);
        if(bidHistory.Record_Type_Developer_Name__c == 'CSS_Bid'){
            if(bidHistory.eCOA__c){
                types.add('ECOA');
            }
            if(bidHistory.Complete_Consent__c || bidHistory.Connected_Devices__c || bidHistory.IRT__c || bidHistory.eCOA__c || bidHistory.Participant_Payments__c){
                types.add('Other');
            }
            if(bidHistory.Grant_Plan__c){
                types.add('Grant Plan');
            }
            if(bidHistory.eTMF__c){
                types.add('eTMF');
            }
            if(bidHistory.Site_Portal__c){
                types.add('Site Portal');
            }
            if(bidHistory.Risk_Based_Monitoring__c){
                types.add('CTP (Site Payments)');
            }
            if(bidHistory.IRT__c){
                types.add('IRT');
            }
            if(bidHistory.One_Home_for_Sites__c){
                types.add('One Home');
            }
            if(bidHistory.Participant_Payments__c){
                types.add('Participant Payments');
            }
            if(bidHistory.Payments_Forecasting__c){
                types.add('Payment Forecasting');
            }
        }
        else if(bidHistory.Record_Type_Developer_Name__c == 'Tech_Solutions_Support_Request'){
            String systemImpType =bidHistory.System_Implementation_Type__c;
            types = systemImpType.split(';');
        }
        else if(bidHistory.Record_Type_Developer_Name__c == 'GCC'){
            types.add('Countries in Scope');
        }
        else if(bidHistory.Record_Type_Developer_Name__c == 'Q2_Solutions'){
            types.add(bidHistory.Q2_Business_Area__c);
        }
        List<String> configNames = new List<String>();
        for(OWF_Collection_Tool_Configuration__mdt configMetaData : [SELECT Config_JSON__c,Sort_Order__c,DeveloperName from OWF_Collection_Tool_Configuration__mdt Where Record_Type_Developer_Name__c =: bidHistory.Record_Type_Developer_Name__c and Type__c in: types order by Sort_Order__c]){ 
            configNames.add(configMetaData.DeveloperName);
        }
        if(!configNames.isEmpty()) {
            return configNames;
        } else {
            throw new CustomException('Something went wrong, please try again.');
        }
    }
    
    public class CustomException extends Exception {}    
    
}