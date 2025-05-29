public class CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN {

    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getAccountCountryList(){
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult F = Account.AccountCountry__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pf : entries) {
            options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
        } 
        
        return options;
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getContactUserTypeList(){
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult F = Contact.Contact_User_type__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pf : entries) {
            options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
        } 
        
        return options;
    }
    
    @AuraEnabled
    public static List<Queue_User_Relationship__c> getTechnoQueueList(){
        List<Queue_User_Relationship__c> queuelist = new SLT_QueueUserRelationshipC().selectAllTechQueue(new Set<String>{'Id','Name'});
        return queuelist;
    }
    
    @AuraEnabled
    public static List<Account> getAllCustomerPortalAccountList(String accCountry){
        List<Account> acclist = new SLT_Account().selectAllCustomerPortalAccounts(accCountry, new Set<String>{'Id','Name','MDMID__c'});
        return acclist;
    }
    
    @AuraEnabled
    public static List<AggregateResult> getAccountProductList(String accId){
        List<Asset> assetlist = new SLT_Asset().selectByAccountId(new Set<Id>{(Id)accId});
        Set<String> prodctMap = new Set<String>(); 
        List<AggregateResult> aggrigate = null;
        if(assetlist != null){
            for(Asset ast : assetlist){
                prodctMap.add(ast.Product2.Name);  
            }
            
            aggrigate = new SLT_CaseCategorization().getProducts(prodctMap);
            
        }
        
        return aggrigate;
    }
    
    /** @AuraEnabled
    public static String getDefaultAccountQueueConfig(String accId,String country){
        List<CSM_QI_Data_Portal_Queue_User_details__c> datalist = Database.query('select Id, Account__c, All_Current_Users__c, Order__c, Queue_User_Relationship__c, AccountCountry__c, CaseRecordType__c  from CSM_QI_Data_Portal_Queue_User_details__c where Account__c = :accId and Order__c = 1 and Queue_User_Relationship__c != null and All_Current_Users__c = true');
        String str = '';
        boolean isTech = false, isData = false;
        if(datalist != null){
            for(CSM_QI_Data_Portal_Queue_User_details__c c : datalist){
                if(c.CaseRecordType__c == 'TechnologyCase' && c.AccountCountry__c != null && c.Account__c != null){
                    isTech = true;
                }else if(c.CaseRecordType__c == 'DATACase' && c.Account__c != null){
                    isData = true;
                }
            }
            
            if(!isTech && !isData){
                str = 'TechnologyCase and DATACase';
            }else if(!isTech && isData){
                str = 'TechnologyCase';
            }else if(isTech && !isData){
                str = 'DATACase';
            }
            
        }
        return str;
    }*/
    
    @AuraEnabled
    public static List<AggregateResult> getCSHSubtypeList(String productId){
        List<AggregateResult> agglist = new SLT_CaseCategorization().getCSHSubTypeByProductName(productId);
        return agglist;
    }
    
    @AuraEnabled
    public static EXT_CSM_DataTableResponse getPortalDataList(){
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get('CSM_QI_Data_Portal_Queue_User_details__c');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('TechnoDataTableFieldSet');
        
        //To hold the table hearders 
        List<EXT_CSM_DataTableColumns> lstDataColumns = new List<EXT_CSM_DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
        
        //The final wrapper response to return to component
        EXT_CSM_DataTableResponse response = new EXT_CSM_DataTableResponse();
        
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            //Create a wrapper instance and store label, fieldname and type.
            EXT_CSM_DataTableColumns datacolumns = new EXT_CSM_DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                String.valueOf(eachFieldSetMember.getType()).toLowerCase() );
            datacolumns.sortable = true;
            
            lstDataColumns.add(datacolumns);
            if('AccountCountry__c' == String.valueOf(eachFieldSetMember.getFieldPath()) ){
                lstFieldsToQuery.add('toLabel(AccountCountry__c)');
            }else{
                lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));  
            }
        } 
        EXT_CSM_DataTableColumns action = new EXT_CSM_DataTableColumns();
        EXT_CSM_DataTableColumns typeAttributes = new EXT_CSM_DataTableColumns();
        action.type = 'action';
        List<EXT_CSM_DataTableColumns> rowActions = new List<EXT_CSM_DataTableColumns>();
        EXT_CSM_DataTableColumns action1 = new EXT_CSM_DataTableColumns();
        action1.label = 'Show details';
        action1.name = 'show_details';
        rowActions.add(action1);
        EXT_CSM_DataTableColumns action2 = new EXT_CSM_DataTableColumns();
        action2.label = 'Delete';
        action2.name = 'delete';
        rowActions.add(action2);
        typeAttributes.rowActions = rowActions;
        action.typeAttributes = typeAttributes; 
        lstDataColumns.add(action);
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(! lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstDataColumns;
            String query = 'SELECT Id,' + String.join(lstFieldsToQuery, ',') + ' FROM CSM_QI_Data_Portal_Queue_User_details__c where CaseRecordType__c = \'TechnologyCase\'';
            response.lstDataTableData = Database.query(query);
        }
        
        return response;
    }
    
    @AuraEnabled
    public static String addtoCSMDataPortal(String country, String accId, String product, String subtype, String queue, String userType){
        Integer order;
        String query = 'Select Id,Name From CSM_QI_Data_Portal_Queue_User_details__c';
        if(country != null || accId != null || product != null || subtype != null || queue != null){
            query +=' Where';
            if(country != null){ 
                query +=' AccountCountry__c =\''+ country +'\' and';
            }
            if(accId != null){
                query +=' Account__c =\''+ accId +'\' and';
            }
            if(product != null){
                query +=' Product__c =\''+ product +'\' and';
            }
            if(userType != null){
                query +=' Contact_User_Type__c =\''+ userType +'\' and';
            }
            if(subtype != null){
                query +=' CSH_Sub_Type__c =\''+ subtype +'\' and';
            }
            if(queue != null){
                query +=' Queue_User_Relationship__c =\''+ queue +'\'';
            }
            if(country != null && country.length() > 1 && accId != null && accId.length() > 1 && product != null && product.length() > 1 
                && subtype != null && subtype.length() > 1 && userType != null && userType.length() > 1 && queue != null && queue.length() > 1){
                order = 6;
            }else if(country != null && country.length() > 1 && accId != null && accId.length() > 1 && product != null && product.length() > 1 
                && userType != null && userType.length() > 1 && queue != null && queue.length() > 1){
                order = 5;
            }else if(country != null && country.length() > 1 && accId != null && accId.length() > 1
                && userType != null && userType.length() > 1 && queue != null && queue.length() > 1){
                order = 4;
            }else if(country != null && country.length() > 1 && accId != null && accId.length() > 1 && product != null && product.length() > 1 
                && subtype != null && subtype.length() > 1 && queue != null && queue.length() > 1){
                order = 3;
            }else if(country != null && country.length() > 1 && accId != null && accId.length() > 1 && product != null && product.length() > 1 && queue != null && queue.length() > 1){
                order = 2;
            }else if(country != null && country.length() > 1 && accId != null && accId.length() > 1 && queue != null && queue.length() > 1){
                order = 1;
            }
        }
        List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = Database.query(query);
        if(dataList != null && dataList.size() > 0){
            return 'Warning'; 
        }else{
            CSM_QI_Data_Portal_Queue_User_details__c data = new CSM_QI_Data_Portal_Queue_User_details__c();
            data.AccountCountry__c = country;
            data.Account__c = accId;
            data.Product__c = product;
            data.Contact_User_Type__c = userType;
            data.CSH_Sub_Type__c = subtype;
            data.All_Current_Users__c = true;
            data.CaseRecordType__c = 'TechnologyCase';
            data.Queue_User_Relationship__c = queue;
            data.Order__c = order;
            if(order == 1){
                data.All_Current_Users__c = true;
            }
            data.Type__c = 'Queue Assignment';
            try{
                insert data;
                return 'Success';
            }catch(System.DmlException e){
                return 'Error';   
            }
            
        }
        
    }
    
    @AuraEnabled
    public static void deleteRecord(String id){
        List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = Database.query('Select Id,Name From CSM_QI_Data_Portal_Queue_User_details__c where id =\''+id+'\'');
        delete dataList;
    }
    
    @AuraEnabled
    public static Integer getTotalNoOfRows(){
        return Database.countQuery('Select COUNT() From CSM_QI_Data_Portal_Queue_User_details__c where CaseRecordType__c = \'TechnologyCase\'');
    }
    
}
