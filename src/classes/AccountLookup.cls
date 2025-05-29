public with sharing class AccountLookup 
{
    // public properties
    public string SearchText{get;set;}
    public List<Account> listAccount{get;set;}
    public string Country{get;set;}
    
    // class constructor
    public AccountLookup()
        {
            // if no search criteria present get all records else filter on the basis of search text
            if(ApexPages.currentPage().getParameters().get('strText') == null || ApexPages.currentPage().getParameters().get('strText') == '')
                {
                    getAllAccounts();
                }
            else
                {
                    SearchText = ApexPages.currentPage().getParameters().get('strText');
                    getListBySearchText();
                }
        }    
     public List<SelectOption> getSelectCountry()
    {
        List<SelectOption> options = new List<SelectOption>();   
        Schema.DescribeFieldResult fieldResult = Account.Region_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        options.add(new SelectOption('None', '-- Please Select --'));  
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }
    //function to search on the basis of search text provided by user 
    public PageReference getListBySearchText()    
        {
            if((SearchText == null ||SearchText =='') && (Country != 'None' || Country != null))
             {
                 ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please specify account name along with country.' );
                 ApexPages.addMessage(infoMsg);
                 return null;
             }            
            String SearchTextTemp = String.escapeSingleQuotes(SearchText); 
            if (SearchTextTemp.trim().length() != 0)
                {
                    system.debug('####'+Country);
                    if(Country == 'None' || Country == null)
                    {
                        // prepare the string on the basis of search text
                        String searchValue = SearchTextTemp.replace('*','%') +'%';
                    
                        //create a new instance of List account
                        listAccount = new List<Account>();
                    
                        searchValue = String.escapeSingleQuotes(searchValue);
                        searchValue = '\'' + searchValue + '\'';
                    
                        // prepare query
                        String query = 'Select id, Name,NameLocal from Account where Name like ' + searchValue + ' Or NameLocal like ' + searchValue +' order by Name limit 1000' ;
                        system.debug('%%%%'+query) ;            
                        //Add the records to the list    
                        for(Account acc: database.query(query))
                        {
                            listAccount.add(acc);
                        }
                    }
                    else
                    {
                        // prepare the string on the basis of search text
                        String searchValue = SearchTextTemp.replace('*','%') +'%';
                    
                        //create a new instance of List account
                        listAccount = new List<Account>();
                    
                        searchValue = String.escapeSingleQuotes(searchValue);
                        searchValue = '\'' + searchValue + '\'';
                    
                        // prepare query
                        String query = 'Select id, Name,NameLocal from Account where Region_Territory__c = \'' + Country + '\' and (Name like ' + searchValue + ' Or NameLocal like ' + searchValue +') order by Name limit 1000' ;
                                     
                        //Add the records to the list    
                        for(Account acc: database.query(query))
                        {
                            listAccount.add(acc);
                        }
                    }
                }
                
            else
                {
                    // get all accounts
                    getAllAccounts();
                }    
             return null;   
            
        }
        
    // get all accounts of the system    
    public void getAllAccounts()    
        {
            integer i = 0;
            listAccount = new List<Account>([Select id,Name,NameLocal from Account order by name limit 1000]);
        }    
}