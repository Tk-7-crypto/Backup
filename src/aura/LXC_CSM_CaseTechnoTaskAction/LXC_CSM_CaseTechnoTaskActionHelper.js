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
    showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    },
    updateLogCommentAction : function( component) {
        console.log('updateLogCommentAction');
        var actionAPI = component.find("quickActionAPI");
        var values = 'Problem Statement: **'+component.get("v.problemStatement")+'****\n';
        values+='What? **'+component.get("v.what")+'****\n';
        values+='How? **'+component.get("v.how")+'****\n';
        values+='Who? **'+component.get("v.who")+'****\n';
        values+='By When? **'+component.get("v.byWhen")+'****\n';
        var fields = {CommentBody: {value: values}, IsPublished: {value: true}};
        var args = {actionName: "Case.Log_a_Comment", entityName: "Case", targetFields: fields};
        
        actionAPI.setActionFieldValues(args).then(function(response){
            //console.log('##WORKING#setActionFieldValues##'+ response);
            //actionAPI.invokeAction(args);
            //console.log('##WORKING#setActionFieldValues##');
        }).catch(function(e){
            console.error('Error : '+e.errors);
        });
    },
    
    updateSendEmailAction : function( component) {
        console.log('updateSendEmailAction');
        var actionAPI = component.find("quickActionAPI");
        var values = 'Problem Statement: **'+component.get("v.problemStatement")+'****<br/>';
        values+='What? **'+component.get("v.what")+'****<br/>';
        values+='How? **'+component.get("v.how")+'****<br/>';
        values+='Who? **'+component.get("v.who")+'****<br/>';
        values+='By When? **'+component.get("v.byWhen")+'****<br/>';
        var fields = {HtmlBody:{value:values}};
        var args = {actionName: "Case.SendEmail", entityName: "Case", targetFields: fields};
        
        actionAPI.setActionFieldValues(args).then(function(response){
            //console.log('##WORKING#setActionFieldValues##'+ response);
            //actionAPI.invokeAction(args);
            //console.log('##WORKING#setActionFieldValues##');
        }).catch(function(e){
            console.error('Error : '+e.errors);
        });
    },
	
	updatePostAction : function( component) {
        console.log('updateLogCommentAction');
        var actionAPI = component.find("quickActionAPI");
        var values ='';
        var taskList = component.get('v.postUsers');
        if(taskList.length > 0){
            values+='<p>';
            for (var i=0; i<taskList.length; i++) {
                if(taskList[i].name != undefined){
                    values +='<span class="ql-chatter-mention quill_widget_element" contenteditable="false" tabindex="-1" data-widget="chatterMention" data-mention="'+taskList[i].value+'">@['+taskList[i].name+']</span>';
                }
            }
            values+='</p>';
        }
        values+='<p>Problem Statement: **'+component.get("v.problemStatement")+'****</p>';
        values+='<p>What? **'+component.get("v.what")+'****</p>';
        values+='<p>How? **'+component.get("v.how")+'****</p>';
        values+='<p>Who? **'+component.get("v.who")+'****</p>';
        values+='<p>By When? **'+component.get("v.byWhen")+'****</p>';
        var fields = {Body: {value: values}};
        var args = {actionName: "FeedItem.TextPost", entityName: "Case", targetFields: fields};
        
        actionAPI.setActionFieldValues(args).then(function(response){
            //actionAPI.invokeAction(args);
        }).catch(function(e){
            console.error('Error : '+e.errors);
        });
    }
})
