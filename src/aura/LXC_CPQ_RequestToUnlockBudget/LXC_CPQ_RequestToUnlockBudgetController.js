({
    doInit : function(component, event, helper) 
    {
        if(!component.get("v.simpleRecord").Pricing_Tool_Locked__c)
        {
            component.set("v.popUpMessage", "Budget not locked.");
        }
        else if(component.get("v.simpleRecord").Budget_Checked_Out_By__c == $A.get("$SObjectType.CurrentUser.Id"))
        {
            var action5 = component.get("c.notifyAdminUser");
            action5.setParams({"userId" : component.get("v.simpleRecord").Budget_Checked_Out_By__c, 
                			   "budgetId" : component.get("v.recordId")
            });
            action5.setCallback(this, function(response) 
            {
                var state5 = response.getState();
                if (state5 === "SUCCESS")
                {
                    component.set("v.popUpMessage", "Budget is currently locked. Please save and attach to unlock the budget.");
                }
            });
            $A.enqueueAction(action5);
        }
        else
        {
            var action1 = component.get("c.isNotifyCurrentXAEOwner");
            action1.setParams({"pricingTool" : component.get("v.simpleRecord").Select_Pricing_Tool__c});
            action1.setCallback(this, function(response) 
            {
                var state1 = response.getState();
                if (state1 === "SUCCESS") 
                {
                    var isNotifyCurrentXAEOwner = response.getReturnValue();
                    if(isNotifyCurrentXAEOwner)
                    {
                        var action2 = component.get("c.notifyXAEOwner");
                        action2.setParams({"userId" : component.get("v.simpleRecord").Budget_Checked_Out_By__c, 
                           				   "budgetId" : component.get("v.recordId")
                        });
                        action2.setCallback(this, function(response) 
                        {
                            var state2 = response.getState();
                            if (state2 === "SUCCESS") {
                                component.set("v.popUpMessage","Unlocking request has been submitted.");
                            }
                        });
                        $A.enqueueAction(action2);
                    }
                    else
                    {
                        var action3 = component.get("c.unlockBudget");
                        action3.setParams({"userId" : component.get("v.simpleRecord").Budget_Checked_Out_By__c,
                            			   "budgetId" : component.get("v.recordId")
                        });
                        action3.setCallback(this, function(response) 
                        {
                            var state3 = response.getState();
                            if (state3 === "SUCCESS") {
                                component.set("v.popUpMessage","Budget has been unlocked.");
                            }
                        });
                        $A.enqueueAction(action3);
                    }
                }
            });
            $A.enqueueAction(action1);
        }
        window.setTimeout(
            $A.getCallback(function() 
            {
                component.set("v.Spinner", false);
                $A.get('e.force:refreshView').fire();
            }), 2000
        );
    }
})