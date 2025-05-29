({
    doInit : function(component, event, helper) {
        console.log('doInit : doInit');
        console.log('doInit : doInit'+window.location.pathname);
        //component.set("v.path",window.location.pathname);
        
        var action = component.get("c.showPSAFieldsBasedOnProfile");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showPSAFields = response.getReturnValue();
                component.set("v.showPSAFields", showPSAFields);
            }
        });
        $A.enqueueAction(action);

        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        var recordId = component.get("v.recordId");
        if(recordId != undefined){
            //getTimeSheet
            helper.callServer(component, "c.getTimeSheet",function(responseTimeSheet){
                if(responseTimeSheet != undefined){
                    component.set('v.timeSheet',responseTimeSheet);
                    component.set('v.sltTimeType',responseTimeSheet.Time_Type__c);
                    helper.onClickHelp(component, event, helper,'doInit');
                    
                    //Populate Milestones Automatic
                    if(responseTimeSheet.ProjectId__c != undefined && component.get("v.showPSAFields")){
                        helper.callServer(component, "c.getMilestones",function(resp){
                            if(resp != undefined){
                                var milestones = new Array();
                                for (var i = 0; i < Object.keys(resp).length; i++){
                                    var milestone= new Object();
                                    milestone.Id = resp[i].ExternalId;
                                    milestone.Name = resp[i].Name__c;
                                    milestone.Checked = (responseTimeSheet.MilestoneId__c != undefined && resp[i].ExternalId == responseTimeSheet.MilestoneId__c) ? true:false;
                                    if(responseTimeSheet.MilestoneId__c != undefined && resp[i].ExternalId == responseTimeSheet.MilestoneId__c){
                                        milestone.Checked =true;
                                        component.set('v.sltMilestone',resp[i].ExternalId);
                                    }
                                    else
                                        milestone.Checked =false;
                                    milestones.push(milestone);
                                }
                                component.set('v.MilestonetList',milestones);
                            } 
                        },{"projectId" : responseTimeSheet.ProjectId__c},true);
                    }
                    
                    
                    //getManualTimeSheet
                    helper.callServer(component,"c.getManaulTimeSheet",function(responseTimeSheetManual){
                        if(responseTimeSheetManual!=undefined){
                            //objManualTS=respo;
                            component.set('v.timeSheetManual',responseTimeSheetManual);
                            component.set('v.sltTimeTypeManual',responseTimeSheetManual.Time_Type__c);
                            
                            //Populate Milestones Manual
                            if(responseTimeSheetManual != undefined && responseTimeSheetManual.ProjectId__c != undefined && component.get("v.showPSAFields")){
                                helper.callServer(component, "c.getMilestones",function(resMileStoneManual){
                                    if(resMileStoneManual != undefined){
                                        var milestones = new Array();
                                        for (var i = 0; i < Object.keys(resMileStoneManual).length; i++){
                                            var milestone= new Object();
                                            milestone.Id = resMileStoneManual[i].ExternalId;
                                            milestone.Name = resMileStoneManual[i].Name__c;
                                            milestone.Checked = (responseTimeSheetManual.MilestoneId__c != undefined && resMileStoneManual[i].ExternalId == responseTimeSheetManual.MilestoneId__c) ? true:false;
                                            if(responseTimeSheetManual.MilestoneId__c != undefined && resMileStoneManual[i].ExternalId == responseTimeSheetManual.MilestoneId__c){
                                                milestone.Checked =true;
                                                component.set('v.sltMilestoneManual',resMileStoneManual[i].ExternalId);
                                            }
                                            else
                                                milestone.Checked =false;
                                            milestones.push(milestone);
                                        }
                                        component.set('v.MilestonetListManual',milestones);
                                    } 
                                },{"projectId" : responseTimeSheetManual.ProjectId__c},true);
                            }
                            
                            if(component.get("v.showPSAFields")) {
                            helper.callServer(component, "c.getAssignmentsAndProjects",function(resp){
                                if(resp != undefined){
                                    component.set('v.AssignmentAndProject',resp);
                                    
                                    //Populate Projects
                                    var projects = new Array();
                                    var projectManual = new Array();
                                    var projectName = new Array();
                                    for (var i = 0; i < Object.keys(resp).length; i++) {
                                        var proj= new Object();
                                        var projManual = new Object();
                                        console.log('resp[i].pse_Project_c__c : '+resp[i].pse_Project_c__c);
                                        if(!projectName.includes(resp[i].pse_Project_c__c)){
                                            projectName.push(resp[i].pse_Project_c__c);
                                            //Automatic
                                            if(responseTimeSheet != undefined && responseTimeSheet.ProjectId__c != undefined && resp[i].pse_Project_c__c == responseTimeSheet.ProjectId__c){
                                                proj.Checked = true;
                                                component.set('v.sltProject',resp[i].pse_Project_c__c);
                                            }
                                            else{
                                                proj.Checked = false;   
                                            }
                                            proj.Id = resp[i].pse_Project_c__c;
                                            proj.Name = resp[i].pse_Project_c__r.Name__c;
                                            proj.MilestoneRequired = resp[i].pse_Project_c__r.Timecards_require_Milestone_c__c;
                                            projects.push(proj); 
                                            
                                            //Manual
                                            if(responseTimeSheetManual != null && responseTimeSheetManual != undefined && responseTimeSheetManual.ProjectId__c != undefined && resp[i].pse_Project_c__c == responseTimeSheetManual.ProjectId__c){
                                                projManual.Checked = true;
                                                component.set('v.sltProjectManual',resp[i].pse_Project_c__c);
                                            }
                                            else{
                                                projManual.Checked = false;   
                                            }
                                            projManual.Id = resp[i].pse_Project_c__c;
                                            projManual.Name = resp[i].pse_Project_c__r.Name__c;
                                            projManual.MilestoneRequired = resp[i].pse_Project_c__r.Timecards_require_Milestone_c__c;
                                            projectManual.push(projManual);
                                        }                                
                                    }
                                    component.set('v.ProjectList',projects);
                                    component.set('v.ProjectListManual',projectManual)
                                    
                                    //Populate Assignments
                                    //Automatic Assignment
                                    if(responseTimeSheet != null && responseTimeSheet.ProjectId__c != undefined ){
                                        var assignments = new Array();
                                        for (var i = 0; i < resp.length; i++){
                                            if(resp[i].pse_Project_c__c == responseTimeSheet.ProjectId__c){
                                                var assign = new Object();
                                                assign.Id = resp[i].ExternalId;
                                                assign.Name = resp[i].Name__c;
                                                if(responseTimeSheet.AssignmentId__c != undefined && responseTimeSheet.AssignmentId__c ==resp[i].ExternalId){
                                                    assign.Checked =true;
                                                    component.set('v.sltAssignment',resp[i].ExternalId);
                                                }else{
                                                    assign.Checked =false;   
                                                }
                                                assignments.push(assign);
                                            }
                                        }
                                        component.set('v.AssignmentList',assignments);
                                    }
                                    //Manual Assignment
                                    if(responseTimeSheetManual != undefined && responseTimeSheetManual.ProjectId__c != undefined){
                                        var assignmentManual = new Array();
                                        for (var i = 0; i < resp.length; i++){
                                            if(resp[i].pse_Project_c__c == responseTimeSheetManual.ProjectId__c){
                                                var assign = new Object();
                                                assign.Id = resp[i].ExternalId;
                                                assign.Name = resp[i].Name__c;
                                                if(responseTimeSheetManual.AssignmentId__c != undefined && responseTimeSheetManual.AssignmentId__c ==resp[i].ExternalId){
                                                    assign.Checked =true;
                                                    component.set('v.sltAssignmentManual',resp[i].ExternalId);
                                                }
                                                else
                                                    assign.Checked =false;
                                                assignmentManual.push(assign);
                                            }
                                        }
                                        component.set('v.AssignmentListManual',assignmentManual);
                                    }  
                                } 
                            },{},true);
                        	}
                        }
                        
                    },{"caseId" : recordId,"preCaseId": component.get('v.preRecordId') },true); 
                }
                else{
                    helper.onClickHelp(component, event, helper,'closedStop');
                }
            },{"caseId" : recordId,"preCaseId": component.get('v.preRecordId') },true);
        }
        
    },
    
    recordUpdated: function(component, event, helper) {
        console.log('---recordUpdated---');
        var objManualTS;
        var changeType = event.getParams().changeType;
        var recordId = component.get("v.recordId");
        var response = component.get('v.timeSheet');
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {
            if(component.get("v.caseRecord") != undefined && component.get("v.caseRecord").RecordTypeName__c == "DATACreateService"){
                component.set("v.tabId",'two');
                component.set("v.isTimeType",true);
            }else{
                component.set("v.tabId",'one');
                component.set("v.isTimeType",false);
            }
            helper.callServer(component, "c.getTimeTypeList",function(res){
                if (res != undefined) {
					var filteredTimeTypeList = res.filter(function(item) {
						return item.value !== 'Case Completion Effort'; 
					});

					for (var i = 0; i < Object.keys(res).length; i++) {
						if (res[i].value == component.get('v.sltTimeType')) {
							res[i].checked = true;
						} else {
							res[i].checked = false;
						}
					}

					component.set('v.TimeTypeListManual', res);
					component.set('v.TimeTypeList', filteredTimeTypeList); 
				}
            },{"caseId" : recordId},true);
            /*
            helper.callServer(component,"c.getManaulTimeSheet",function(respo){
                if(respo!=undefined){
                    objManualTS=respo;
                    component.set('v.sltTimeTypeManual',respo.Time_Type__c);
                }
                
            },{"caseId" : recordId,"preCaseId": component.get('v.preRecordId') },true);
            
            helper.callServer(component, "c.getAssignmentsAndProjects",function(resp){
                if(resp != undefined){
                    component.set('v.AssignmentAndProject',resp);
                    
                    //Populate Projects
                    var projects = new Array();
                    var projectManual = new Array();
                    var projectName = new Array();
                    for (var i = 0; i < Object.keys(resp).length; i++) {
                        var proj= new Object();
                        var projManual = new Object();
                        console.log('resp[i].pse_Project_c__c : '+resp[i].pse_Project_c__c);
                        if(!projectName.includes(resp[i].pse_Project_c__c)){
                            projectName.push(resp[i].pse_Project_c__c);
                            //Automatic
                            if(response != undefined && response.ProjectId__c != undefined && resp[i].pse_Project_c__c == response.ProjectId__c){
                                proj.Checked = true;
                                component.set('v.sltProject',resp[i].pse_Project_c__c);
                            }else{
                             proj.Checked = false;   
                            }
                            proj.Id = resp[i].pse_Project_c__c;
                            proj.Name = resp[i].pse_Project_c__r.Name__c;
                            proj.MilestoneRequired = resp[i].pse_Project_c__r.Timecards_require_Milestone_c__c;
                            projects.push(proj); 
                            
                            //Manual
                            if(objManualTS != null && objManualTS != undefined && objManualTS.ProjectId__c != undefined && resp[i].pse_Project_c__c == objManualTS.ProjectId__c){
                                projManual.Checked = true;
                                component.set('v.sltProjectManual',resp[i].pse_Project_c__c);
                            }else{
                             projManual.Checked = false;   
                            }
                            projManual.Id = resp[i].pse_Project_c__c;
                            projManual.Name = resp[i].pse_Project_c__r.Name__c;
                            projManual.MilestoneRequired = resp[i].pse_Project_c__r.Timecards_require_Milestone_c__c;
                            projectManual.push(projManual);
                        }                                
                    }
                    component.set('v.ProjectList',projects);
                    component.set('v.ProjectListManual',projectManual)
                    
                    //Populate Assignments
                    //Automatic Assignment
                    if(response != null && response.ProjectId__c != undefined ){
                        var assignments = new Array();
                        for (var i = 0; i < resp.length; i++){
                            if(resp[i].pse_Project_c__c == response.ProjectId__c){
                                var assign = new Object();
                                assign.Id = resp[i].ExternalId;
                                assign.Name = resp[i].Name__c;
                                if(response.AssignmentId__c != undefined && response.AssignmentId__c ==resp[i].ExternalId){
                                    assign.Checked =true;
                                    component.set('v.sltAssignment',resp[i].ExternalId);
                                }else{
                                    assign.Checked =false;   
                                }
                                assignments.push(assign);
                            }
                        }
                        component.set('v.AssignmentList',assignments);
                    }
                    //Manual Assignment
                    if(objManualTS != undefined && objManualTS.ProjectId__c != undefined){
                        var assignmentManual = new Array();
                        for (var i = 0; i < resp.length; i++){
                            if(resp[i].pse_Project_c__c == objManualTS.ProjectId__c){
                                var assign = new Object();
                                assign.Id = resp[i].ExternalId;
                                assign.Name = resp[i].Name__c;
                                if(objManualTS.AssignmentId__c != undefined && objManualTS.AssignmentId__c ==resp[i].ExternalId){
                                    assign.Checked =true;
                                    component.set('v.sltAssignmentManual',resp[i].ExternalId);
                                }
                                else
                                    assign.Checked =false;
                                assignmentManual.push(assign);
                                
                            }
                        }
                        component.set('v.AssignmentListManual',assignmentManual);
                    }
                    
                    
                } 
            },{},true);
            
            //Populate Milestones Manual
            if(objManualTS != undefined && objManualTS.ProjectId__c != undefined){
                helper.callServer(component, "c.getMilestones",function(resp){
                    if(resp != undefined){
                        var milestones = new Array();
                        for (var i = 0; i < Object.keys(resp).length; i++){
                            var milestone= new Object();
                            milestone.Id = resp[i].ExternalId;
                            milestone.Name = resp[i].Name__c;
                            milestone.Checked = (objManualTS.MilestoneId__c != undefined && resp[i].ExternalId == objManualTS.MilestoneId__c) ? true:false;
                            if(objManualTS.MilestoneId__c != undefined && resp[i].ExternalId == objManualTS.MilestoneId__c){
                                milestone.Checked =true;
                                component.set('v.sltMilestoneManual',resp[i].ExternalId);
                            }
                            else
                                milestone.Checked =false;
                            milestones.push(milestone);
                        }
                        component.set('v.MilestonetListManual',milestones);
                    } 
                },{"projectId" : objManualTS.ProjectId__c},true);
            }*/
        }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { /* handle record change */ }
    },
    
    onChange :function(component, event, helper) {
        console.log('Before : '+component.get("v.sltProject"));
        console.log('Before : '+component.get("v.sltAssignment"));
        console.log('Before : '+component.get("v.sltMilestone"));
        console.log('##selectProject value : '+component.find('selectProject').get('v.value'));
        var selectedProject = component.find('selectProject').get('v.value');
        if(component.get("v.sltProject") == ""){
            component.set("v.sltAssignment","");
            component.set("v.sltMilestone","");
        }
        else{
            component.set("v.sltAssignment","");
            component.set("v.sltMilestone","");
            var projAssignments = component.get("v.AssignmentAndProject");
            var assignments = new Array();
            for (var i = 0; i < projAssignments.length; i++){
                if(projAssignments[i].pse_Project_c__c == selectedProject){
                    var assign = new Object();
                    assign.Id = projAssignments[i].ExternalId;
                    assign.Name = projAssignments[i].Name__c;
                    assignments.push(assign);
                }
            }
            component.set('v.AssignmentList',assignments);
            
            helper.callServer(component, "c.getMilestones",function(resp){
                if(resp != undefined){
                    var milestones = new Array();
                    for (var i = 0; i < Object.keys(resp).length; i++){
                        var milestone= new Object();
                        milestone.Id = resp[i].ExternalId;
                        milestone.Name = resp[i].Name__c;
                        milestones.push(milestone);
                    }
                    
                    component.set('v.MilestonetList',milestones);
                } 
            },{"projectId" : selectedProject},true);
        }
        console.log('After : '+component.get("v.sltProject"));
        console.log('After : '+component.get("v.sltAssignment"));
        console.log('After : '+component.get("v.sltMilestone"));
        
	},
    
    onChangeManual :function(component, event, helper) {
        /*console.log('##selectProject value : '+component.find('selectProject1').get('v.value'));*/
        var selectedProject = component.find('selectProject1').get('v.value');
        if(component.get("v.sltProjectManual") == ""){
            component.set("v.sltAssignmentManual","");
            component.set("v.sltMilestoneManual","");
        }
        else{
            component.set("v.sltAssignmentManual","");
            component.set("v.sltMilestoneManual","");
            var projAssignments = component.get("v.AssignmentAndProject");
            var assignments = new Array();
            for (var i = 0; i < projAssignments.length; i++){
                if(projAssignments[i].pse_Project_c__c == selectedProject){
                    var assign = new Object();
                    assign.Id = projAssignments[i].ExternalId;
                    assign.Name = projAssignments[i].Name__c;
                    assignments.push(assign);
                }
            }
            component.set('v.AssignmentListManual',assignments);
            
            helper.callServer(component, "c.getMilestones",function(resp){
                if(resp != undefined){
                    var milestones = new Array();
                    for (var i = 0; i < Object.keys(resp).length; i++){
                        var milestone= new Object();
                        milestone.Id = resp[i].ExternalId;
                        milestone.Name = resp[i].Name__c;
                        milestones.push(milestone);
                    }
                    
                    component.set('v.MilestonetListManual',milestones);
                } 
            },{"projectId" : selectedProject},true);
        }
	},
    
    doCloseCase : function(component, event, helper) {
        console.log('doCloseCase : doCloseCase');
        console.log('event :'+event.getSource().getLocalId());
        var recordId = component.get("v.recordId");
        var pathname = window.location.pathname;
        console.log('recordId : '+recordId +'pathname : '+pathname);
        if(recordId != undefined && component.get("v.caseRecord") != undefined && component.get("v.caseRecord").RecordTypeName__c != 'DATACreateService'){
            if(pathname.includes('Case') && pathname.includes('/500') && pathname.includes(component.get('v.preRecordId')+'/view') && !(pathname.includes(component.get('v.recordId')+'/related'))){
                helper.onClickHelp(component, event, helper,'closedStop');
            }
        }
    },
    
    doRefrishInit : function(component, event, helper) {
        console.log('doRefrishInit : doRefrishInit '+component.get("v.recordId"));
        console.log('event' + JSON.stringify(event.getParams()));
        var recordId = component.get("v.recordId");
        var isRefreshView = false,isShowToast = false;
        if(component.get("v.caseRecord") != undefined && component.get("v.caseRecord").RecordTypeName__c == 'DATACreateService' && event.getParams().type != undefined && event.getParams().title != undefined && event.getParams().title.includes('Flash Message')){
        
        }else if(event.getParams().type != undefined && (event.getParams().type == 'success' || event.getParams().type == 'SUCCESS')){
            isShowToast = true;
        }else if(event.getParams().workspaceId != undefined){
            isRefreshView = true;
        }
        
        if(recordId != undefined && (isRefreshView || isShowToast)){
            window.setTimeout($A.getCallback(function() {
         helper.callServer(component, "c.getTimeSheet",function(response){
                if(response != undefined){
                    console.log('response' + JSON.stringify(response));
                    component.set('v.timeSheet',response);
                    helper.onClickHelp(component, event, helper,'doInit');
                }else{
                    helper.onClickHelp(component, event, helper,'closedStop');
                }
                component.set('v.isFirst',false);
            },{"caseId" : recordId,"preCaseId": component.get('v.preRecordId') },true)  })
           , 10000);
        }
    },
    
    /** onLocationChange : function (component, event, helper) {
		var pathname = window.location.pathname;
        console.log('------------Start-------------');
        console.log(' preRecordId :'+component.get('v.preRecordId') + ' recordId : '+component.get('v.recordId'));
        console.log('pre path : '+component.get("v.path") + ' current pathname : '+pathname);
        if(pathname.includes('Case') && pathname.includes('/500') && !pathname.includes(component.get('v.recordId')+'/view') 
           && (pathname.includes(component.get('v.recordId')+'/related') || component.get("v.path").includes(component.get('v.recordId')+'/related')) && pathname != component.get("v.path")){
            component.set("v.path",window.location.pathname);
            console.log('Inside If');
        }else if(pathname.includes('Case') && pathname.includes('/500') && pathname.includes(component.get('v.recordId')) && 
               (component.get('v.changeName') != 'Visible' || component.get('v.preRecordId') != component.get('v.recordId'))){
            console.log('Inside If else 1');
            console.log('Record Visible : '+component.get('v.recordId'));
                helper.callServer(component, "c.insertorUpdateTime",function(response){
                    if(response != undefined){
                        console.log('timeSheet response : '+response);
                        component.set('v.timeSheet',response);
                        helper.onClickHelp(component, event, helper,'doInit');
                        component.set('v.preRecordId',component.get('v.recordId'));
                        component.set('v.changeName','Visible');
                        component.set("v.path",window.location.pathname);
                    } 
                },{"caseId" : component.get('v.recordId'), "timeType" : "" },true);
            }else if(pathname.includes('Case') && pathname.includes('/500') && component.get('v.timeSheet') != undefined){
                console.log('Inside else if 2');
                helper.onClickHelp(component, event, helper,'doInit');
                console.log('Visible : '+component.get('v.recordId'));
                if(pathname.includes('/related') && pathname.includes('/view')) {
                    component.set('v.changeName','Visible');
                    console.log('Inside else if 2 related cases');
                }else{
                    console.log('Inside else if 2 new cases');
                    component.set('v.preRecordId',component.get('v.recordId'));
                    component.set("v.path",window.location.pathname);
                    component.set('v.changeName','NotVisible');
                }
            }else if(component.get('v.changeName') != 'NotVisible' && component.get('v.timeSheet') != undefined){
                console.log('Inside else if 3 new cases');
                helper.onClickHelp(component, event, helper,'onLocationChange');
                console.log('Record Not Visible : '+component.get('v.recordId'));
                component.set('v.preRecordId',component.get('v.recordId'));
                component.set("v.path",window.location.pathname);
                component.set('v.changeName','NotVisible');
            }
        console.log('------------End-------------');
	},*/
    
    onLocationChange : function (component, event, helper) {
		var pathname = window.location.pathname;
        console.log('------------Start-------------');
        console.log(' preRecordId :'+component.get('v.preRecordId') + ' recordId : '+component.get('v.recordId'));
        console.log('pre path : '+component.get("v.path") + ' current pathname : '+pathname);
        if(component.get("v.caseRecord") != undefined && component.get("v.caseRecord").RecordTypeName__c == 'DATACreateService'){
            
        }else if(pathname.includes('Case') && pathname.includes('/500') 
           && !pathname.includes(component.get('v.recordId')+'/view') && pathname != component.get("v.path")){
            component.set("v.path",window.location.pathname);
            helper.onClickHelp(component, event, helper,'onLocationChange');
            console.log('Inside If');
        }else if(pathname.includes('Case') && pathname.includes('/500') && pathname.includes(component.get('v.recordId')+'/view')){
            console.log('Inside If else 1');
            console.log('Record Visible : '+component.get('v.recordId'));
                helper.callServer(component, "c.insertorUpdateTime",function(response){
                    if(response != undefined){
                        console.log('timeSheet response : '+response);
                        component.set('v.timeSheet',response);
                        helper.onClickHelp(component, event, helper,'doInit');
                        component.set('v.preRecordId',component.get('v.recordId'));
                        component.set('v.changeName','Visible');
                        component.set("v.path",window.location.pathname);
                    } 
                },{"caseId" : component.get('v.recordId'), "timeType" : "" },true);
            }
        console.log('------------End-------------');
	},
    
    doScriptLoad : function(component, event, helper) {

	},
    onClick : function(component, event, helper) {
        helper.onClickHelp(component, event, helper,'onClick');
	},
    
    
    
    onUpdateTimeType : function(component, event, helper) { 
        var updateValidationPassed = true;
        /*if((component.get("v.sltTimeType") == undefined || component.get("v.sltTimeType") =="") &&
           (component.get("v.sltProject") == undefined || component.get("v.sltProject") =="") &&
           (component.get("v.sltAssignment") == undefined || component.get("v.sltAssignment") =="") &&
           (component.get("v.sltMilestone") == undefined || component.get("v.sltMilestone") =="")){
            updateValidationPassed = false;
            helper.showToastmsg(component,"Warning","Warning","Please select any value to update.");
           }
        else{*/
            if(!(component.get("v.sltProject") == undefined || component.get("v.sltProject") =="")){
                if((component.get("v.sltAssignment") == undefined || component.get("v.sltAssignment") =="")){
                    updateValidationPassed = false;
                    helper.showToastmsg(component,"Error","Error","Please select any assignment to update.");
                }
                var projects = component.get("v.ProjectList");
                let result = projects.filter(proj => proj.Id == component.get("v.sltProject"));
                if(result.length > 0 && result[0].MilestoneRequired && (component.get("v.sltMilestone") == undefined || component.get("v.sltMilestone") ==""))
                {
                    updateValidationPassed = false;
                    helper.showToastmsg(component,"Error","Error","Milestone is required for selected project.");
                }
            }
            if(component.get("v.sltProject") == undefined || component.get("v.sltProject") =="")
            {
                if(
                    (!(component.get("v.sltAssignment") == undefined || component.get("v.sltAssignment") =="")) ||
                    (!(component.get("v.sltMilestone") == undefined || component.get("v.sltMilestone") ==""))
                  ){
                    updateValidationPassed = false;
                    helper.showToastmsg(component,"Error","Error","Please select any project to update.");
                }
                
            }
        //}
        if(updateValidationPassed== true && component.get('v.timeSheet') != undefined){
             console.log('Before update : '+component.get("v.sltProject"));
        	console.log('Before update : '+component.get("v.sltAssignment"));
        	console.log('Before update : '+component.get("v.sltMilestone"));
            let button = event.getSource();
            button.set('v.disabled',true);
            helper.callServer(component, "c.updateAutoStopTime",function(response){
                if(response != undefined){
                    console.log('response : '+response);
                } 
                helper.showToastmsg(component,"success","success","Time Entry has successfully updated.");
                button.set('v.disabled',false);
            },{"caseId" : component.get("v.recordId") , "Id" : component.get("v.timeSheet").Id, "ttype" : component.get("v.sltTimeType"),"ProjectId" : component.get("v.sltProject"),"AssignmentId" : component.get("v.sltAssignment"),"MilestoneId" : component.get("v.sltMilestone")},true);
        }
    },
    
    checkPSAValidations:function(component, event, helper){
        if(!(component.get("v.sltProject") == undefined || component.get("v.sltProject") =="")){
            if((component.get("v.sltAssignment") == undefined || component.get("v.sltAssignment") =="")){
                component.set('v.updateValidation',false);
                helper.showToastmsg(component,"Error","Error","Please select any assignment to update.");
            }
            var projects = component.get("v.ProjectList");
            let result = projects.filter(proj => proj.Id == component.get("v.sltProject"));
            if(result.length > 0 && result[0].MilestoneRequired && (component.get("v.sltMilestone") == undefined || component.get("v.sltMilestone") ==""))
            {
                component.set('v.updateValidation',false);
                helper.showToastmsg(component,"Error","Error","Milestone is required for selected project.");
            }
        }
            console.log('updateValidation :'+component.get('v.updateValidation'));
    },
    
    handleTimeType: function (component, event, helper) {
        // Get the selected value from the event
        let selectedTimeType = event.getSource().get("v.value");
        
        // Set the selected value to the component attribute
        component.set("v.selectedTimeType", selectedTimeType);
    },
    
    
    save : function(component, event, helper) {
        var updateValidationPassed = true;
        let button = event.getSource();
        button.set('v.disabled',true);
        var recordId = component.get("v.recordId");
       
        /*if((component.get("v.sltProject") == undefined || component.get("v.sltProject") =="") &&
           (component.get("v.sltAssignment") == undefined || component.get("v.sltAssignment") =="") &&
           (component.get("v.sltMilestone") == undefined || component.get("v.sltMilestone") =="")){
            updateValidationPassed = false;
            helper.showToastmsg(component,"Warning","Warning","Please select any value to update.");
            button.set('v.disabled',false);
           }
        else*/
        if(component.get("v.caseRecord").RecordTypeName__c == 'DATACreateService' && component.get("v.sltTimeTypeManual") == null){
            updateValidationPassed = false;
            helper.showToastmsg(component,"Error","error","Please Enter Time");
            button.set('v.disabled',false);
        }else if(component.get("v.timeinHours") == null){
            updateValidationPassed = false;
            helper.showToastmsg(component,"Error","error","Please Enter Time");
            button.set('v.disabled',false);
        }else if(component.get("v.timeinHours") == ''){
            updateValidationPassed = false;
            helper.showToastmsg(component,"Error","error","Time allow only Numbers");
            button.set('v.disabled',false);
        }else if(component.get("v.caseRecord").RecordTypeName__c == 'TechnologyCase' &&  component.get("v.sltTimeTypeManual") == 'Case Completion Effort' && (component.get("v.caseVolume") == "" || component.get("v.caseVolume") == 'undefined' || component.get("v.caseVolume") == null)){
            updateValidationPassed = false;
            button.set('v.disabled',false);
            helper.showToastmsg(component,"Error","error","Please Enter Case Volume");
        }else if((component.get("v.sltProjectManual") == undefined || component.get("v.sltProjectManual") =="") && (
            (!(component.get("v.sltAssignmentManual") == undefined || component.get("v.sltAssignmentManual") =="")) ||
            (!(component.get("v.sltMilestoneManual") == undefined || component.get("v.sltMilestoneManual") ==""))
        ) )
        {
            updateValidationPassed = false;
            helper.showToastmsg(component,"Error","Error","Please select any project to update.");
            button.set('v.disabled',false);
        }
        else if(!(component.get("v.sltProjectManual") == undefined || component.get("v.sltProjectManual") =="")){
                if((component.get("v.sltAssignmentManual") == undefined || component.get("v.sltAssignmentManual") =="")){
                    updateValidationPassed = false;
                    helper.showToastmsg(component,"Error","Error","Please select any assignment to update.");
                    button.set('v.disabled',false);
                }
                var projects = component.get("v.ProjectListManual");
                let result = projects.filter(proj => proj.Id == component.get("v.sltProjectManual"));
                if(result.length > 0 && result[0].MilestoneRequired && (component.get("v.sltMilestoneManual") == undefined || component.get("v.sltMilestoneManual") ==""))
                {
                    updateValidationPassed = false;
                    helper.showToastmsg(component,"Error","Error","Milestone is required for selected project.");
                    button.set('v.disabled',false);
                }
        }
        if(updateValidationPassed){
            helper.callServer(component, "c.saveTimeSheet",function(response){
                component.set("v.timeinHours","");
                component.set("v.comment","");
                /*component.set("v.sltTimeTypeManual",""); 
                component.set("v.sltProjectManual","");
                component.set("v.sltAssignmentManual","");
                component.set("v.sltMilestoneManual","");*/
                if(response.indexOf('Success:') != -1){
                    helper.showToastmsg(component,"success","success",response);
                }
                else if(response.indexOf('Error:') != -1){
                    helper.showToastmsg(component,"Error","Error",response);
                }
                
                button.set('v.disabled',false);
            },{"caseId" : recordId, "timeInHours" : component.get("v.timeinHours") , "comment" : component.get("v.comment"), "timeType" : component.get("v.sltTimeTypeManual"),"ProjectId" : component.get("v.sltProjectManual"),"AssignmentId" : component.get("v.sltAssignmentManual"),"MilestoneId" : component.get("v.sltMilestoneManual"), "caseVolumeManual" : component.get("v.caseVolume")},true);
         	  //button.set('v.disabled',false);
            
        }   
        
	},
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.spinner", false);
    }
    
})
