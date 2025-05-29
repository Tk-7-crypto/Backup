({
	 callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if(action != undefined){
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
                         this.showToastmsg(component,"Error","Error",errors[0].pageErrors[0].message);
                         if (errors[0] && errors[0].message) {
                             throw new Error("Error" + errors[0].message);
                         }
                     } else {
                         throw new Error("Unknown Error");
                     }
                 }
             });
             
             $A.enqueueAction(action);
         }
    },
    
    onClickHelp : function(component, event, helper,method) {
        if(component.find("time") != undefined && component.get('v.timeSheet')  != undefined){
            var div = component.find("time").getElement();
            var idcase = div.getAttribute("idcase");
            
            var id = event.getSource().getLocalId();
            console.log('id :'+id);
            if(id == "notifLib" || id == "publisherAction" || id == "quickActionLayout" || id == "saveRecordCmp" || id == "toastManager"){
                id = component.get('v.timeSheet').Status__c;
            }else if(id == undefined){
                id = component.get('v.timeSheet').Status__c;
            }
            console.log('id - 1 : '+id);
            if(method == 'onLocationChange'){
                //Commented new version for CSM-2154
                //id = 'remove';
                id = 'stop';
            }else if(method == 'closedStop'){
                id = 'remove';
            }
            console.log('id - 2 :'+id);
            var clocktimer;
            var	clsStopwatch = function() {
                // Private vars
                
                var	startAt	= component.get("v.startAt") || 0;	// Time of last start / resume. (0 if not running)
                var	lapTime	= component.get("v.lapTime") || 0;	// Time on the clock when last stopped in milliseconds
                
                var	now	= function() {
                    return (new Date()).getTime();
                };
                
                // Public methods
                // Start or resume
                this.start = function() {
                    
                    //helper.callServer(component, "c.insertTime",function(response){
                      //  if(response != undefined){
                        //    component.set('v.timeSheet',response);
                            startAt = Date.parse(component.get('v.timeSheet').StartTime__c);
                            component.set("v.startAt",startAt);
                            startAt	= startAt ? startAt : now();
                            
                        //}
                    //},{"caseId" : component.get("v.recordId"), "timeType" : component.get("v.sltTimeType") },true);
                    
                };
                
                // Stop or pause
                this.stop = function() {
                    // If running, update elapsed time otherwise keep it
                    
                    //helper.callServer(component, "c.updateStopTime",function(response){
                      //  if(response != undefined){
                            //component.set('v.timeSheet',response);
                            lapTime	= startAt ? lapTime + now() - startAt : lapTime;
                            startAt	= 0; // Paused
                            component.set("v.lapTime",0);
                            //div.innerHTML = "Time: 00:00:00";
                            
                        //}
                    //},{"caseId" : component.get("v.recordId") , "Id" : component.get("v.timeSheet").Id, "timeType" : component.get("v.sltTimeType") },true);
                    
                };
                
                // Case Tab change
                this.autostop = function() {
                    // If running, update elapsed time otherwise keep it
                    
                    helper.callServer(component, "c.updateAutoStopTime",function(response){
                        if(response != undefined){
                            console.log('response : '+response);
                            lapTime	= 0;
                            startAt	= 0; // Paused
                            component.set("v.lapTime",0);
                            //div.innerHTML = "Time: 00:00:00";
                        }
                        component.set('v.timeSheet',response);
                    },{"caseId" : component.get("v.recordId") , "Id" : component.get("v.timeSheet").Id },true);
                    
                };
                
                // Reset
                this.reset = function() {
                    lapTime = startAt = 0;
                };
                
                // Duration
                this.time = function() {
                    return lapTime + (startAt ? now() - startAt : 0);
                };
            };
            
            var stopwatch = component.get("v.stopwatch");
            var x = stopwatch || new clsStopwatch();
            if(!stopwatch){
                component.set("v.stopwatch", x);
            }
            
            function pad(num, size) {
                var s = "0000" + num;
                return s.substr(s.length - size);
            }
            
            function formatTime(time) {
                var h = 0;
                var m = 0;
                var s = 0;
                var newTime = '';
                
                h = Math.floor( time / (60 * 60 * 1000) );
                time = time % (60 * 60 * 1000);
                m = Math.floor( time / (60 * 1000) );
                time = time % (60 * 1000);
                s = Math.floor( time / 1000 );
               // if(( (pad(m, 2) == 0 && pad(h, 2) != 0) || pad(m, 2) == 15 || pad(m, 2) == 30  || pad(m, 2) == 45) && pad(s, 2) == 1){
                   // if(component.get('v.timeSheet') != null && component.get('v.timeSheet') != undefined){
                     //  helper.showToastmsg(component,"Warning","Warning", "Reminder: Auto Timer is running in Time Sheet for Case "+component.get('v.timeSheet').Case__r.CaseNumber);
                   // }
                //}
                
                
                newTime = pad(h, 2) + ':' + pad(m, 2) + ':' + pad(s, 2) ;
                return newTime;
            }
            
            function update() {
                div.innerHTML = "Time: " + formatTime(x.time());
            }
            
            switch(id){
                case "start":
                    clocktimer = setInterval(update, 1);
                    x.start();
                    break;
                case "stop":
                    x.stop();
                    //clearInterval(clocktimer);
                    x.reset();
                    update();
                    break;
                case "reset":
                    x.stop();
                    x.reset();
                    update();
                    break;
                case "remove":
                    x.autostop();
                    x.reset();
                    update();
                    break;
                case "closedStop":
                    x.reset();
                    update();
                    break;
                default:
                    x.reset();
                    update();
                    break;
            }
        }
    },
    showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message,
            "mode": 'dismissable'
        });
    },
})