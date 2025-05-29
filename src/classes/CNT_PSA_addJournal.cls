/**

* this class is used in lWC_PSA_addJournal

*/

public with sharing class CNT_PSA_addJournal {
    public static map<String,String> codeTocountryMapping = new map<String,String>();
    public static map<String,String> countryToCodeMapping = new map<String,String>();
    /**
* This method is used to get Main_Journal_Catalogue Object list
*/
    @AuraEnabled(cacheable=true)
    public static List<Journals_Main_Catalogue__c> getMainJournalCatalogueList( ) {
        List<Journals_Main_Catalogue__c> lstMainCatalogue = new List<Journals_Main_Catalogue__c>();
        CNT_PSA_addJournal.countryApiNametoValueMapping();
        for(Journals_Main_Catalogue__c mainJournal: [ SELECT Id, Name, Country__c, Journal_Name__c, URL__c,
                                                                Periodicity__c, Regulatory_requirement__c, Subscription__c,
                                                                Paper_Journal__c, Therapeutic_Area__c
                                                     FROM Journals_Main_Catalogue__c
                                                     ORDER BY Country__c ASC
                                                     LIMIT 50 ] ){
            mainJournal.Country__c=codeTocountryMapping.get(mainJournal.Country__c);
            lstMainCatalogue.add( mainJournal );
        } 
        return lstMainCatalogue;
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Journals_Main_Catalogue__c> getMainJournalCatalogueListFromCountry( List<String> countries, List<String> mainJCIds ) {
        Set<String> Ids = new Set<String>(mainJCIds);
        List<Journals_Main_Catalogue__c> lstMainCatalogue = new List<Journals_Main_Catalogue__c>();
        CNT_PSA_addJournal.countryApiNametoValueMapping();
        Boolean isOnlyNoneSelected = false;
        List<String> lstCountryCodes = new List<String>();
        
        isOnlyNoneSelected = countries.size()==1 && countries.contains('None');
        
        if(!isOnlyNoneSelected){
            //get country code from country name
            for(String country : countries){
            	if(country != 'None' && countryToCodeMapping.containskey(country)){
                	String countryCode = countryToCodeMapping.get(country);
                	lstCountryCodes.add(countryCode);
            	}
        	}
        }
        
        if( isOnlyNoneSelected == false && lstCountryCodes != null && lstCountryCodes.size() > 0 ){
            
            for(Journals_Main_Catalogue__c mainJournal: [ SELECT Id, Name, Country__c, Journal_Name__c, URL__c,
                                                                    Periodicity__c, Regulatory_requirement__c, Subscription__c,
                                                                    Paper_Journal__c, Therapeutic_Area__c
                                                          FROM Journals_Main_Catalogue__c
                                                          WHERE Country__c IN : lstCountryCodes
                                                          AND Id NOT IN : Ids
                                                          LIMIT 50
                                                          ] ){
                mainJournal.Country__c=codeTocountryMapping.get(mainJournal.Country__c);
                lstMainCatalogue.add( mainJournal );
            }   
        }else{
            for(Journals_Main_Catalogue__c mainJournal: [ SELECT Id, Name, Country__c, Journal_Name__c, URL__c,
                                                                    Periodicity__c, Regulatory_requirement__c, Subscription__c,
                                                                    Paper_Journal__c, Therapeutic_Area__c
                                                          FROM Journals_Main_Catalogue__c
                                                          WHERE Id NOT IN : Ids
                                                          ORDER BY Country__c ASC
                                                          LIMIT 50 ] ){
                mainJournal.Country__c=codeTocountryMapping.get(mainJournal.Country__c);
                lstMainCatalogue.add( mainJournal );
            } 

        }
        return lstMainCatalogue;
        
    }
    
    /**
    * This method is used for Mapping of API Name of Country Field of Journals_Main_Catalogue__c to Value
    */
    public static void countryApiNametoValueMapping(){
        List<Schema.PicklistEntry> entries=new List<Schema.PicklistEntry>();
        Schema.DescribeFieldResult fieldDescription = Journals_Main_Catalogue__c.Country__c.getDescribe();
        entries = fieldDescription.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
            countryToCodeMapping.put( entry.getLabel(), entry.getValue() );
            codeTocountryMapping.put( entry.getValue(), entry.getLabel() );
        }
    }
    /**
    * This method is check if user have editable permission
    */
    @AuraEnabled(cacheable=true)
    public static Boolean haveEditablePermission(Id userId) {
        boolean isEditable=false;
        Set<String> fieldSet=new Set<String>{'PermissionSet.Id','PermissionSet.Name'};
            Set<Id> userIDs=new Set<Id>{userId};
                List<PermissionSetAssignment> permissionsets=new SLT_PermissionSetAssignment().selectByUserIds(fieldSet,userIDs);
        for(PermissionSetAssignment pSet:permissionsets){
            if(pSet.permissionSet.Name=='RDS_Admin' || pSet.permissionSet.Name=='RDS_LR_Read_And_Edit'){
                isEditable=true;
                break;
            }
        }
        return isEditable;   
    }
    /**
    * This method is used to create new record of Event Journal Object
    */
    @AuraEnabled
    public static String  addEventJournalToLRProjectOverview( List<Event_Journals__c> dataToBeInserted, Id LR_Project_Overview ){
        CNT_PSA_addJournal.CountryApiNametoValueMapping();
        LR_Project_Overview__c projectOverview = new SLT_LR_Project_Overview().getLRProjectOverViewFROMlRProjectOverViewId( LR_Project_Overview, new Set<String>{'Account__c', 'Project__c', 'Product__c','LR_Type__c', 'Proj_Code__c'} );
        List<Event_Journals__c> eventJournalList=new List<Event_Journals__c>();
        
        for( integer key=0; key<dataToBeInserted.size(); key++ ){
            Event_Journals__c eventJournal=new Event_Journals__c();
            if( dataToBeInserted[key].Name != null ){
                eventJournal.Name = dataToBeInserted[key].Name;
            }
                
            if( dataToBeInserted[key].Country__c != null ){
                if( countryToCodeMapping.containskey( dataToBeInserted[key].Country__c ) && countryToCodeMapping.get( dataToBeInserted[key].Country__c ) != null ){
                    eventJournal.Country__c = countryToCodeMapping.get( dataToBeInserted[key].Country__c );
                }
            }
            if( dataToBeInserted[key].Journal_Name__c != null ){
                eventJournal.Journal_Name__c = dataToBeInserted[key].Journal_Name__c;
            }
            if( dataToBeInserted[key].URL__c != null ){
                eventJournal.URL__c = dataToBeInserted[key].URL__c;
            }
            if( dataToBeInserted[key].Periodicity__c != null ){
                eventJournal.Periodicity__c = dataToBeInserted[key].Periodicity__c;
            }
                
            if( dataToBeInserted[key].Regulatory_requirement__c != null ){
                eventJournal.Regulatory_requirement__c = dataToBeInserted[key].Regulatory_requirement__c;
            }
                
            if( dataToBeInserted[key].Subscription__c != null ){
                eventJournal.Subscription__c = dataToBeInserted[key].Subscription__c;
            }
                
            if( dataToBeInserted[key].Paper_Journal__c != null ){
                eventJournal.Paper_Journal__c = dataToBeInserted[key].Paper_Journal__c;
            }
                
            if( dataToBeInserted[key].Therapeutic_Area__c != null ){
                eventJournal.Therapeutic_Area__c = dataToBeInserted[key].Therapeutic_Area__c;
            }  
            if( dataToBeInserted[key].QPPV_LPS_Comments__c != null ){
                eventJournal.QPPV_LPS_Comments__c = dataToBeInserted[key].QPPV_LPS_Comments__c;
            }
                
            if( dataToBeInserted[key].Frequency_of_Journal__c != null && dataToBeInserted[key].Frequency_of_Journal__c != 'None' ){
                eventJournal.Frequency_of_Journal__c = dataToBeInserted[key].Frequency_of_Journal__c;
            }
                
            if( dataToBeInserted[key].Other_Journal_Frequency_Specify__c != null ){
                eventJournal.Other_Journal_Frequency_Specify__c = dataToBeInserted[key].Other_Journal_Frequency_Specify__c;
            }
                
            if( dataToBeInserted[key].Date_Initial_Search_Started__c != null ){
                eventJournal.Date_Initial_Search_Started__c = dataToBeInserted[key].Date_Initial_Search_Started__c;
            }
                
            if( dataToBeInserted[key].Date_Last_Journal_Search_was_Performed__c != null ){
                eventJournal.Date_Last_Journal_Search_was_Performed__c = dataToBeInserted[key].Date_Last_Journal_Search_was_Performed__c;
            }
                
            if( dataToBeInserted[key].Date_Next_Journal_Search_is_Due__c != null ){
                eventJournal.Date_Next_Journal_Search_is_Due__c = dataToBeInserted[key].Date_Next_Journal_Search_is_Due__c;
            }
               
            if( dataToBeInserted[key].Active__c != null && dataToBeInserted[key].Active__c != 'None'){
                eventJournal.Active__c = dataToBeInserted[key].Active__c;
            }
                
            if( dataToBeInserted[key].Inactive_since__c != null ){
                eventJournal.Inactive_since__c = dataToBeInserted[key].Inactive_since__c;
            }
                
            if( LR_Project_Overview != null ){
                //eventJournal.LR_Project_Overview__c = LR_Project_Overview;
            }
                
            if( projectOverview.Account__c != null ){
                eventJournal.Account__c = projectOverview.Account__c;
            }
                
            if( projectOverview.Project__c != null ){
                eventJournal.Project__c = projectOverview.Project__c;
            }
            if( projectOverview.Product__c != null ){
                eventJournal.Product__c = projectOverview.Product__c;
            }
            if( projectOverview.LR_Type__c != null ){
                eventJournal.LR_Type__c = projectOverview.LR_Type__c;
            }
                
            if( projectOverview.Proj_Code__c != null ){
                eventJournal.Project_Code__c = projectOverview.Proj_Code__c;
            }
                
            
            eventJournalList.add(eventJournal);
        }
        try{
            if(!eventJournalList.isEmpty()){
                insert eventJournalList;
                return 'Success';
            }
        }
        catch(DMLException e){
            return e.getMessage();
        }
        return '';
    }
    @AuraEnabled(cacheable=true)
    public static List < CustomValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < CustomValueWrapper > customObjWrapper = new list < CustomValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
            CustomValueWrapper selectOptionValueWrapper = new CustomValueWrapper();
            selectOptionValueWrapper.custFldlabel = myCustPick.getLabel();
            selectOptionValueWrapper.custFldvalue = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
        
    }
    @AuraEnabled
    public static String lrProjectOverviewValidation( String  LR_Project_Overview ){
        String returnString = 'Valid';
        LR_Project_Overview__c projectOverview = new SLT_LR_Project_Overview().getLRProjectOverViewFROMlRProjectOverViewId( LR_Project_Overview, new Set<String>{'Account__c', 'Project__c', 'Product__c', 'Proj_Code__c','LR_Type__c','Status__c'} );
        
        if(  projectOverview.Account__c == null || projectOverview.Project__c == null || projectOverview.Product__c == null || projectOverview.LR_Type__c == null ){
            returnString = 'MissingLRFields';
        }
        else if( projectOverview.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED || projectOverview.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_CANCELLED ){
            returnString = 'NotValidForCompleteAndCancelled';
            
        }
        else if(projectOverview.LR_Type__c != null && projectOverview.LR_Type__c != CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL ){
            returnString = 'NotValidForLocal';
        }
        return returnString;
    }
    public with sharing class CustomValueWrapper {
        @auraEnabled public string custFldlabel {get;set;}
        @auraEnabled public string custFldvalue {get;set;}
    }
}