({
    doInit : function(component, event, helper) {
        helper.fetchRecordTypesHelper(component, event, helper);
        helper.getContractFieldSetHelper(component, event, helper);
        helper.getContractFromIdHelper(component, event, helper);
    },
    openCreateRecordForm : function(component, event, helper) {
        var FieldsSet = component.get("v.FieldSet");
        var contractRecord = component.get("v.ContractRecord");
        var RecordTypeSelected = component.get("v.RecordTypeSelected");
        var contractBuilder = {};
        for(var i = 0; i<FieldsSet.length; i++){
            contractBuilder[FieldsSet[i]] = contractRecord[FieldsSet[i]];
        }
        contractBuilder['Parent_Contract__c'] = contractRecord.Id;
        if(contractBuilder['Status'] == 'Activated'){
            contractBuilder['Status'] = '';
        }
        var recordTypeIdToCreate = '';
        if(RecordTypeSelected == '' || RecordTypeSelected == null){
            recordTypeIdToCreate = contractRecord.RecordTypeId;
        }else{
            recordTypeIdToCreate = RecordTypeSelected;
        }
        var createRecordEvent = $A.get('e.force:createRecord');
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                entityApiName : 'Contract',
                recordTypeId : recordTypeIdToCreate,
                defaultFieldValues: contractBuilder 
            });
            createRecordEvent.fire();
        } else {
        }
    }
 })