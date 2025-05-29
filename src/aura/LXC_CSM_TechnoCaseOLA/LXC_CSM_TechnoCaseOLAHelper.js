({
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getPriority : function(component, helper) {
        if(component.get("v.recordId") != undefined){
            helper.callServer(component, "c.getCasePriority",function(r){
                if(r != undefined){
                    component.set("v.priority",r);
                } 
            },{"caseId" : component.get("v.recordId") },true);    
        }
        
    },
    
    getCompletedTime : function(component, helper) {
        if(component.get("v.recordId") != undefined){
            helper.callServer(component, "c.getCaseCurrentQueueCompleted",function(r){
                if(r != undefined){
                     var recordId = component.get("v.recordId");
                    component.set("v.dETime", r.elapsedTime);
                    component.set("v.dRTime",r.remainingTime);
                    component.set("v.completed",r.isCompleted);
                    component.set("v.timeleftinDay",r.timeleftinDay);
                    var minutes,hour,eTime,rTime;
                    eTime = r.elapsedTime;
                    rTime = r.remainingTime;
                    /** if(component.find("time") != undefined){
                        var div = component.find("time").getElement();  
                        if(eTime > 0){
                            hour = (eTime / 60) | 0;
                            minutes = (eTime % 60) | 0;
                            hour = hour < 10 ? "0" + hour : hour;
                            minutes = minutes < 10 ? "0" + minutes : minutes;
                            if(div != null) div.innerHTML = hour + ":" + minutes;
                        }else if(eTime == undefined){
                            if(div != null) div.innerHTML = "00:00";
                        }else{
                            if(div != null) div.innerHTML = "00:00"; 
                        }
                    }*/
                    if(eTime > 0){
                        hour = (eTime / 60) | 0;
                        minutes = (eTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        component.set("v.timeText", hour + ":" + minutes);
                    }else if(eTime == undefined){
                        component.set("v.timeText","00:00");
                    }else{
                        component.set("v.timeText","00:00");
                    }
                    if(rTime > 0){
                        hour = (rTime / 60) | 0;
                        minutes = (rTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        component.set("v.timeTextRem", hour + ":" + minutes);
                    }else if(rTime == undefined){
                        component.set("v.timeTextRem","00:00");
                    }else{
                        component.set("v.timeTextRem","00:00");
                    }
                   /**  if(component.find("timePriorityRem") != undefined){
                        var divR = component.find("timePriorityRem").getElement();
                        if(rTime > 0){
                            hour = (rTime / 60) | 0;
                            minutes = (rTime % 60) | 0;
                            hour = hour < 10 ? "0" + hour : hour;
                            minutes = minutes < 10 ? "0" + minutes : minutes;
                            if(divR != null) divR.innerHTML = hour + ":" + minutes;
                        }else if(rTime == undefined){
                            if(divR != null) divR.innerHTML = "00:00";
                        }else{
                            if(divR != null) divR.innerHTML = "00:00"; 
                        }
                    }*/
                } 
            },{"caseId" : component.get("v.recordId") },true);
        }
    },
    
    calculateOLA : function(component, helper) {
            var diff,minutes,hour,eTime,rTime;
            eTime = component.get("v.dETime");
            rTime = component.get("v.dRTime");
            diff = component.get("v.timeleftinDay");
            //var div = component.find("time").getElement();
            //var divR = component.find("timePriorityRem").getElement();
            function timer() {
                if(component.get("v.checkMethod") == 'Refresh'){
                    eTime = component.get("v.dETime");
                    rTime = component.get("v.dRTime");
                    diff = component.get("v.timeleftinDay");
                    component.set("v.checkMethod","Init");
                }
                if(diff > 0){
                    /** if(eTime > 0){
                        hour = (eTime / 60) | 0;
                        minutes = (eTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        if(div != null) div.innerHTML = hour + ":" + minutes;
                    }else{
                        div.innerHTML = "00:00";
                    }
                    
                    if(rTime > 0){
                        hour = (rTime / 60) | 0;
                        minutes = (rTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        if(divR != null) divR.innerHTML = hour + ":" + minutes;
                    }else{
                        if(divR != null) divR.innerHTML = "00:00";
                    }*/
                    if(eTime > 0){
                        hour = (eTime / 60) | 0;
                        minutes = (eTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        component.set("v.timeText", hour + ":" + minutes);
                    }else{
                        component.set("v.timeText","00:00");
                    }
                    
                    if(rTime > 0){
                        hour = (rTime / 60) | 0;
                        minutes = (rTime % 60) | 0;
                        hour = hour < 10 ? "0" + hour : hour;
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        component.set("v.timeTextRem", hour + ":" + minutes);
                    }else{
                        component.set("v.timeTextRem","00:00");
                    }
                    if (diff > 0) {
                        diff = diff - 1;
                        eTime = eTime + 1;
                        if(rTime<=0){
                            rTime = 0;
                        } else{
                            rTime = rTime - 1;    
                        }
                    }    
                }
                
            };
            if(component.get("v.checkMethod") == 'Init'){
                timer();
                var interval = setInterval(timer, 60000);
                component.set("v.pollId",interval);
            }
         
    }
   
})