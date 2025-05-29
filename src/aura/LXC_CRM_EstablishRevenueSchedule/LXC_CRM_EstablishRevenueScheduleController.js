({
    doInit : function(component, event, helper) {
        var scheduleType = [];
        scheduleType.push('Divide Amount into multiple installments');
        scheduleType.push('Repeat Amount for each installment');
        var installmentPeriod = [];
        installmentPeriod.push('Monthly');
        installmentPeriod.push('Daily');
        installmentPeriod.push('Weekly');
        installmentPeriod.push('Quarterly');
        installmentPeriod.push("Semesterly");
        installmentPeriod.push('Yearly');
        installmentPeriod.push("Once");
        component.set('v.scheduleType', scheduleType);
        component.set('v.installmentPeriod', installmentPeriod);
    },
    fadeInRevenueModel : function(component, event, helper) {
        if(event.getParams().origin == "Detail") {
            component.set('v.isRevenueVisible',true);
            component.set('v.oliWrapper', event.getParams().oliWrapper);
            var revenueSchComp = component.find('revenueSch');
            var backDropComp = component.find('backdrop');
            $A.util.addClass(revenueSchComp, 'slds-fade-in-open');
            $A.util.addClass(backDropComp, 'slds-backdrop--open');
            helper.getOLISchedules(component, event, helper);
        }
    },
    closeModel : function(component, event, helper) {
       helper.fadeOutRevenueModel(component, event, helper); 
    },
    /*saveAndClose : function(component, event, helper) {
        helper.saveAndClose(component, event, helper);
    },*/
    delete: function(component, event, helper) {
        helper.delete(component, event, helper);
    },
    loadMore : function(component, event, helper) {
        var oppLineItem = component.get('v.oppLineItem');
        var olisList = component.get('v.olisList');
        for(var i=0; i< 5; i++) {
            olisList.push({
                ScheduleDate: '', 
                Revenue: '',
                Description : null,
                OpportunityLineItemId : oppLineItem.Id
            });
        }
        component.set('v.olisList', olisList);
    },
    establish :function(component, event, helper) {
        helper.establish(component, event, helper);
    },
    disabledNumInstallment : function(component, event, helper) { 
        var installmentPeriod = component.find("select-input-installmentPeriod").get("v.value");
        var numberOfInstallment = component.find("text-input-numberOfInstallment");
        if(installmentPeriod == "Once") {
            numberOfInstallment.set("v.value", "1");
            numberOfInstallment.set("v.disabled", true);
        } else {
            numberOfInstallment.set("v.disabled", false);
        }
    },  
        
    setRevenueAmount : function(component, event, helper) {
        var comp = event.getSource();
        var revenue = comp.get("v.value");
        var decimalPlace = component.get('v.decimalPlace');
        if(revenue!= undefined && revenue != null && revenue != '') {
            comp.set("v.value", parseFloat(revenue).toFixed(decimalPlace));
        }
    },
        
    handleSave: function(component, event, helper) {
        helper.save(component, event, helper);
    },
    
    handleApplicationEvent : function(cmp, event, helper) {
        if(event.getParam("eventType") != "EstablishRevenue")
            return;
        var message = event.getParam("message");
        if(message == 'Ok') {
            helper.saveAndClose(cmp, event, helper);
        } else if(message == 'Cancel') {
        }
    },   
});