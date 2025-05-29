public class CNT_TPA_AMA_ContractDetailListView {
    
    public Integer noOfRecords;
    public AMA_Contract_Detail__c amaContractDetail {get; set;}
  
    public ApexPages.StandardSetController setAMAContractDetail {
        get {
            String query = getTPAQuery();
            if(setAMAContractDetail == null) {                
                setAMAContractDetail = new ApexPages.StandardSetController(Database.query(query));
                setAMAContractDetail.setPageSize(pageSize);  
                noOfRecords = setAMAContractDetail.getResultSize();
            }            
            return setAMAContractDetail;
        }
        set;
    }
   
    
    public String sortBy{get;set;}
    public String query;
    public String sortOrder {
        get{
            if(sortOrder == null) {
                sortOrder = 'ASC';
            }
            return sortOrder;
        } 
        set;
    }
    
    public PageReference sortData(){
        
        query = getTPAQuery();
        setAMAContractDetail = new ApexPages.StandardSetController(Database.query(query));
        setAMAContractDetail.setPageSize(pageSize);
        return null;
    }
    
     public String getTPAQuery(){
        String query = 'SELECT Name, Client__c, DBL__c, Client_Services_On_Behalf_Of__c, Contract_List_Type__c, ' +
            'Contract_Type__c, Max_Fee_Reached__c, Contract_End_Date__c, Offshore_Access__c, ' +
            'Offshore_Storage__c, CreatedBy.Name, CreatedDate FROM AMA_Contract_Detail__c ';
        if(sortBy != null && sortOrder != null){
            query += 'ORDER BY ' + sortBy + ' ' + sortOrder;
        }
        System.debug('query------------> ' + query);
        return query;
    }
    
   
    public List<AMA_Contract_Detail__c> getamaContractDetails(){
        return setAMAContractDetail.getRecords();
    }
    
    public PageReference setView()
    {
       
            viewName = 'AMA Contract Detail';
            
        String query = getTPAQuery();
        setAMAContractDetail = new ApexPages.StandardSetController(Database.query(query));
        setAMAContractDetail.setPageSize(pageSize);
        return null;
    }
    
    public Integer pageSize {
        get {
            if(pageSize == null){
                pageSize = 15;
            }
            return pageSize;
        }
        set;
    }
    public Integer currentPageNo{
        get{
            currentPageNo = setAMAContractDetail.getPageNumber();
            return currentPageNo;
        }
        set;
    }
    public Integer orderByField;
    public PageReference settableSize(){
        System.debug('pageSize------->>' +pageSize);
        setAMAContractDetail.setPageSize(pageSize);
        return null;
    }
    
    public Integer totalNoOfRec{
        get{
            totalNoOfRec = setAMAContractDetail.getResultSize();
            return totalNoOfRec;
        }
        set;
    }

    
    public String listId {get;set;}
    
    public string viewName
    {
       get {
          if(viewName == null)
              viewName = 'AMA Contract Detail';
          return viewName;
       }
       set {
          viewName = value;
       }
    }
    
    public CNT_TPA_AMA_ContractDetailListView()
    {
        amaContractDetail = new AMA_Contract_Detail__c();
    }

  public String listName {
        get;
        set {
            listName = value;
            String qry = 'SELECT Name, Client__c FROM AMA_Contract_Detail__c Limit 20';
            Database.QueryLocator queryLocator = Database.getQueryLocator(qry);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(queryLocator);
            List<SelectOption> allViews = ssc.getListViewOptions();
            for (SelectOption so : allViews) {
                
                if (so.getLabel() == System.Label.TPA_AMA_AMA_Contract_Details) {
                    // for some reason, won't work with 18 digit ID
                    listId = so.getValue().substring(0,15);
                    break;
                } else {
                    listId = null;
                }
            }             
        }      
    }

}