public with sharing class CNT_TPA_CustomSeconadyOffLookup {
    
    public IMS_Data_Asset__c primaryOff {get;set;} 
    public IMS_Secondary_Data_Asset__c secondaryOff {get;set;} 
    public List<IMS_Secondary_Data_Asset__c> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    public string offeringCountry{get;set;}
    public string selectedPriOffering{get;set;}
    
    public CNT_TPA_CustomSeconadyOffLookup() {
        //primaryOff = new IMS_Data_Asset__c();
        secondaryOff = new IMS_Secondary_Data_Asset__c();
        searchString = System.currentPageReference().getParameters().get('lksrch');
        selectedPriOffering = System.currentPageReference().getParameters().get('primaryOff');
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    private List<IMS_Secondary_Data_Asset__c> performSearch(string searchString) {
        primaryOff = [SELECT id, name,BU__c,Asset_Name__c from IMS_Data_Asset__c WHERE name = :selectedPriOffering];
        String soql = 'SELECT Name,Secondary_Asset_Name__c,Primary_Data_Asset__r.Asset_Name__c, Primary_Data_Asset__r.Geo_Level__c from IMS_Secondary_Data_Asset__c WHERE ';
        if(searchString != '' && searchString != null)
           // soql = soql +  'Secondary_Asset_Name__c LIKE \'%' + searchString +'%\' AND ';
           soql = soql +  '(Secondary_Asset_Name__c LIKE \'%' + searchString +'%\' OR Name LIKE \'%'+ searchString + '%\' ) AND ';
        if(primaryOff != null)
            soql = soql +  'Primary_Data_Asset__c = \'' + primaryOff.id +'\' AND ';

        soql += 'Is_Active__c = true AND ';    
        
        if(soql.substring(soql.length()-4,soql.length()).equals('AND '))
            soql = soql.substring(0,soql.length()-4);
        if(soql.substring(soql.length()-6,soql.length()).equals('WHERE '))
            soql = soql.substring(0,soql.length()-6);
        
        System.debug(soql);
        return database.query(soql); 
        
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
}