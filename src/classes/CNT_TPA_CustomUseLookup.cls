public with sharing class CNT_TPA_CustomUseLookup {
    
    public IMS_TPA_Purpose__c use {get;set;} // new account to create
    public List<IMS_TPA_Purpose__c> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    // public string offeringCountry{get;set;}
    
    public CNT_TPA_CustomUseLookup() {
        use = new IMS_TPA_Purpose__c();
        searchString = System.currentPageReference().getParameters().get('lksrch');
        //offeringCountry = System.currentPageReference().getParameters().get('country');
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
    private List<IMS_TPA_Purpose__c> performSearch(string searchString) {
        
        String soql = 'SELECT id, name, Primary_Purpose_Name__c from IMS_TPA_Purpose__c WHERE ';
        if(searchString != '' && searchString != null)
            soql = soql +  '(Primary_Purpose_Name__c LIKE \'%' + searchString +'%\' OR Name LIKE \'%'+ searchString + '%\' ) AND ';
      //  if(offeringCountry != '' && offeringCountry != null) 
       //     soql += 'BU__c = \'' +offeringCountry+'\' AND ';
        soql += 'Is_Active__c = true AND Primary_Purpose_Name__c != \'\' AND Primary_Purpose_Name__c != \'other\'';
        
        if(soql.substring(soql.length()-4,soql.length()).equals('AND '))
            soql = soql.substring(0,soql.length()-4);
        if(soql.substring(soql.length()-6,soql.length()).equals('WHERE '))
            soql = soql.substring(0,soql.length()-6);

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