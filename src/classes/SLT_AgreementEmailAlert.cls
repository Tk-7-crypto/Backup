/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Agreement Email Alert
 */
public with sharing class SLT_AgreementEmailAlert extends fflib_SObjectSelector{
     /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_AgreementEmailAlert() {
        super(false, true, false);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_AgreementEmailAlert(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
   /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Agreement_Email_Alert__c.Id,
            Agreement_Email_Alert__c.Name,
            Agreement_Email_Alert__c.Account__c};
    }
   /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Agreement_Email_Alert__c.sObjectType;
    }
    //\''+agRecord.Apttus__Account__c +'\'
    public List<Agreement_Email_Alert__c>  getEmailReceipieantsByMatchingLogic(){
        return Database.query('SELECT Id, Name, Account__r.Name,  Is_this_IQVIA_Biotech__c, Alerting_Email__c, Bcc_Recipient_Email__c, CC__c, Reason_for_Notification__c, Region__c, Therapy_Area__c, Service__c, Rare_Disease__c,FSP__c,Age_Group__c,'+
                        +' Indication__r.Name, Intervention_Type__c, Is_there_a_Client_Bid_Grid__c, Incl_on_re_bids__c,Is_this_a_virtual_trials_study__c, Drug_Classification_Product_Name__c, Phase__c, Line_of_Business__c, Country__c, Level__c, Full_Service__c'+
                        +' FROM Agreement_Email_Alert__c');
                        
    }
    
    public List<Agreement_Email_Alert__c>  getEmailReceipieantsByMatchingFilter(Bid_History__c agRecord, Opportunity oppRecord, String region, String country, String service, String ageGroup){
        String yes_Str = 'Yes';
        String no_Str = 'No';
        try{
            return Database.query('SELECT Id, Name, Account__r.Name,  Is_this_IQVIA_Biotech__c, Alerting_Email__c, Bcc_Recipient_Email__c, CC__c, Reason_for_Notification__c, Region__c, Therapy_Area__c, Service__c, Rare_Disease__c,FSP__c,Age_Group__c,'+
                                  +' Indication__r.Name, Intervention_Type__c, Is_there_a_Client_Bid_Grid__c, Incl_on_re_bids__c,Is_this_a_virtual_trials_study__c, Drug_Classification_Product_Name__c, Phase__c, Line_of_Business__c, Country__c, Level__c, Full_Service__c'+
                                  +' FROM Agreement_Email_Alert__c Where (Region__c Includes ('+region+') OR Region__c = Null) AND (Country__c Includes ('+country+') OR  Country__c = Null) AND'+
                                  +' (Service__c Includes ('+service+') OR  Service__c = Null) AND ( Age_Group__c Includes ('+ageGroup+') OR Age_Group__c = Null) AND'+
                                  +' (Therapy_Area__c = Null OR Therapy_Area__c = \''+agRecord.Therapy_Area__c+'\') AND (Indication__c = Null OR Indication__r.Name = \''+agRecord.Indication__c+'\') AND (Intervention_Type__c = Null OR Intervention_Type__c = \''+agRecord.Intervention_Type__c+'\' OR'+ 
                                  +' Intervention_Type__c = \''+agRecord.Bid_History_Related_Opportunity__r.InterventionType__c+'\') AND (Drug_Classification_Product_Name__c = Null OR Drug_Classification_Product_Name__c = \''+agRecord.Drug_Name__c+'\') AND' +
                                  +' (Level__c = Null OR Level__c = \''+agRecord.RFP_Ranking__c+'\') AND (Phase__c = Null OR Phase__c = \''+agRecord.Phase__c+'\') AND (Line_of_Business__c = Null OR Line_of_Business__c = \''+agRecord.Line_of_Business__c+'\') AND'+
                                  +' (Full_Service__c = Null OR Full_Service__c = \''+agRecord.Full_Service__c+'\') AND '+
                                  +' (Is_this_IQVIA_Biotech__c = Null OR Is_this_IQVIA_Biotech__c = \''+agRecord.IQVIA_biotech__c+'\') AND (Is_this_a_virtual_trials_study__c = Null OR Is_this_a_virtual_trials_study__c =\''+oppRecord.Is_this_a_Virtual_Trials_Study__c+'\' ) AND'+
                                  +' (Is_there_a_Client_Bid_Grid__c = Null OR Is_there_a_Client_Bid_Grid__c = \''+agRecord.Is_there_a_Client_Bid_Grid__c+'\') AND (FSP__c = Null OR FSP__c = \''+oppRecord.FSP__c+'\') AND'+
                                  +' (Therapy_Area__c != null OR Indication__c != null OR Account__c != null OR Intervention_Type__c != null OR Drug_Classification_Product_Name__c != null OR Level__c != null OR Phase__c != null OR Line_of_Business__c != null OR Full_Service__c != null OR'+
                                  +'  Incl_on_re_bids__c != null OR  Is_this_IQVIA_Biotech__c != null OR Is_this_a_virtual_trials_study__c != null OR Is_there_a_Client_Bid_Grid__c != null OR FSP__c != null OR Rare_Disease__c != null OR Region__c != null OR Country__c != null OR Service__c != null OR'+
                                  +'  Age_Group__c != null  ) limit 50000');
        }catch(exception  e){
            return new List<Agreement_Email_Alert__c>();
        }
    }
    
}