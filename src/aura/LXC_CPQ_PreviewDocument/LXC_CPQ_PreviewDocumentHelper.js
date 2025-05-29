({
    fetchDocuments : function(component, event, helper) {
        var action = component.get("c.fetchContentDocument");
        var sObjectName = component.get("v.sObjectName");
        var recordtypeName = '';
        if(sObjectName == 'Apttus_Proposal__Proposal__c') {
            var contractId = component.get("v.quoteRecord").Contract__c;
            if(component.get("v.quoteRecord").Clinical_Bid__c != null) {
                recordtypeName = component.get("v.quoteRecord").Clinical_Bid__r.Record_Type_Developer_Name__c;
                if (recordtypeName == "Contract_Post_Award") {
                    contractId = component.get("v.quoteRecord").Clinical_Bid__c;
                    component.set("v.bidHistoryId",component.get("v.quoteRecord").Clinical_Bid__c);
                }
            }
            action.setParams({
                "contractId": contractId
            });
        }
        if(sObjectName == 'Apttus__APTS_Agreement__c') {
            var contractId = component.get("v.agreementRecord").Contract__c;
            if(component.get("v.agreementRecord").Bid_History__c != undefined) {
                contractId = component.get("v.agreementRecord").Bid_History__c;
                component.set("v.bidHistoryId",component.get("v.agreementRecord").Bid_History__c)
            } 
            action.setParams({
                "contractId": contractId
        	});
        }
        if(sObjectName == 'Quote') {
            var contractId = component.get("v.stdQuoteRecord").ContractId;
            if(component.get("v.stdQuoteRecord").Bid_History__c != undefined) {
                contractId = component.get("v.stdQuoteRecord").Bid_History__c;
                component.set("v.bidHistoryId",component.get("v.stdQuoteRecord").Bid_History__c)
            } 
            action.setParams({
                "contractId": contractId
        	});
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.contentDocList", result.documentList);
                component.set("v.contractDetailsObj", result);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = errors[0].message;
                    this.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);  
    },
    setToast: function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: errorMsg
        });
        toastEvent.fire();
    }
})