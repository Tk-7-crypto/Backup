Public  Class SCM_NewAggOverrideExt
{
    public Contract_Management_Setting__c contractSetting;
    public String profileName ; 
    public User currentUser; 
    public boolean hasError {get; set;}
    public Id selectedAggRecTypeId {get; set;}
    public opportunity oppRec {get; set;}
    public Agreement__c AggRec {get; set;}
    public String SelectedStage;
    public Id AccId;
    public Id AggId;
    public String RecordTypeId;
    public String RecordTypeName;
    //Private variables
    private string permissions;
    private List<PermissionSetAssignment> PermissionSetList;
    private Boolean isJapanPermission;
    
    public SCM_NewAggOverrideExt(ApexPages.StandardController controller) {
        Id oppId;
        if(ApexPages.currentPage().getParameters().get('AggId') != null && ApexPages.currentPage().getParameters().get('AggId') != '') {
            AggId = ApexPages.currentPage().getParameters().get('AggId');
            AggRec = [SELECT Id, Related_Opportunity__c, Account__c FROM Agreement__c WHERE Id = :AggId];
            oppId = AggRec.Related_Opportunity__c;
            AccId = AggRec.Account__c;
        }
        if(ApexPages.currentPage().getParameters().get('oppId') != null && ApexPages.currentPage().getParameters().get('oppId') != '')
            oppId = ApexPages.currentPage().getParameters().get('oppId');
        if(ApexPages.currentPage().getParameters().get('AccId') != null && ApexPages.currentPage().getParameters().get('AccId') != '')
            AccId = ApexPages.currentPage().getParameters().get('AccId');
        List<User> userList = ConstantClass.getUserDetails();
        currentUser = userList.get(0);
        isJapanPermission = false;
        for(PermissionSetAssignment PermissionAss: currentUser.PermissionSetAssignments)
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')) && (PermissionAss.PermissionSet.Label.toLowerCase().contains('japan'))) {                  
                isJapanPermission = true;
                break;
            }
        }
        if(oppId != null) {
            hasError = false;
            contractSetting = Contract_Management_Setting__c.getInstance();
            oppRec = [Select Id, Name, accountId, StageName, Amount, Account.id, Contract_Start_Date__c, Contract_End_Date__c FROM Opportunity where Id =: oppId];
        }
        if(ApexPages.currentPage().getParameters().get('AggRTI') != null && ApexPages.currentPage().getParameters().get('AggRTI') != ''){
            RecordTypeId = ApexPages.currentPage().getParameters().get('AggRTI');
            if (String.isNotEmpty(RecordTypeId)) {
                RecordTypeName = Schema.getGlobalDescribe().get('Agreement__c').getDescribe().getRecordTypeInfosById().get(RecordTypeId).getName();
            }
        }
    }


    Public pagereference redirectCustom() {
        try {
            Agreement__c agg = new Agreement__c();
            agg.recordTypeId = selectedAggRecTypeId;
            agg.Requestor__c = currentUser.id;
            if(oppRec != null && OppRec.Id != null)
            	agg.Related_Opportunity__c = oppRec.id;
            if(AccId != null) {
                agg.Account__c = AccId;
            }
            if(oppRec != null && oppRec.Amount != null) {
                agg.Total_Contract_Value__c = oppRec.Amount;
            }
            if(AggRec != null && AggRec.Id != null) {
                agg.Parent_Agreement__c = AggRec.Id;
            }
            insert agg;
            PageReference pref = new PageReference('/apex/SCM_EditAggOverride?id=' + agg.id + '&cancelURL=cancelactioninterceptor');
            return pref;
        } catch (Exception e) {
            hasError = true;
            ApexPages.addMessages(e);
            return null;
        }

    }

    public pageReference ret() {
        if (oppRec != null && oppRec.Id != null) {
            return new pageReference('/' + oppRec.Id);
        } else if(AccId != null) {
            return new pageReference('/' + AccId);
        } else {
            return new pageReference('/' + Schema.getGlobalDescribe().get('Agreement__c').getDescribe().getKeyPrefix()+'/o');
        }
    }
    
    /*
     * This function will return the record type list for both case from opportubnity and from new tab.
     */
    public list < selectOption > getAggRecordTypes() {
        list < selectOption > aggRecordTypeList = new list < selectOption > ();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Agreement__c;
        Map < Id, Schema.RecordTypeInfo > rtMapById = d.getRecordTypeInfosById();
        Map < id, RecordType > recordTypeMap = new Map < id, RecordType > ([Select Id, name From RecordType Where SobjectType = 'Agreement__c']);
        for (Schema.RecordTypeInfo rti: rtMapById.values()) {
            if (oppRec == null && rti.isAvailable() && (!rti.getName().containsIgnoreCase(System.Label.Master) || rti.getName().containsIgnoreCase('Japan Master Agreement'))) {
                if (RecordTypeName == 'Japan Agreement' && rti.getName() == RecordTypeName) {
                    aggRecordTypeList.add(new selectOption(rti.getRecordTypeId(), rti.getName()));
                } else if(RecordTypeName == 'Japan Master Agreement' || RecordTypeName == null || RecordTypeName == '') {
                    aggRecordTypeList.add(new selectOption(rti.getRecordTypeId(), rti.getName()));
                } 
            } else if (oppRec != null && !rti.getName().containsIgnoreCase(System.Label.Master) && rti.getName() != 'Japan Master Agreement') {
                if (currentUser.Profile.Name.containsIgnoreCase(System.Label.System_Admin) || isJapanPermission) {
                    aggRecordTypeList.add(new selectOption(rti.getRecordTypeId(), rti.getName()));
                }
            }
        }
        return aggRecordTypeList;
    }
}