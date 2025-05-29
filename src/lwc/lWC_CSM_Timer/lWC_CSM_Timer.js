import { LightningElement, api, track, wire } from 'lwc';
import getAssignmentsAndProjects from '@salesforce/apex/CNT_CSM_Timer.getAssignmentsAndProjects';
import getMilestones from '@salesforce/apex/CNT_CSM_Timer.getMilestones';
import getTimesheetRecordById from '@salesforce/apex/CNT_CSM_Timer.getTimesheetRecordById';
import updateDataPSA from '@salesforce/apex/CNT_CSM_Timer.updateDataPSA';
import checkIfEligibleToUpdatePSADetails from '@salesforce/apex/CNT_CSM_Timer.checkIfEligibleToUpdatePSADetails';
import getAssignmentsAndMilestones from '@salesforce/apex/CNT_CSM_Timer.getAssignmentsAndMilestones';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class LWC_CSM_Timer extends LightningElement {
    @track value='';
    @track assignementsAndProjects =[];
    @track milestonebyProj=[];
    @track projects =[];
    @track assignments =[];
    @track milestones=[];
    showSpinner;
    sltProject = '';
    sltAssignment ='';
    sltMilestone = '';
    PSASyncStatus='';
    @api recordId;
    currentRecordId;
    clickedButtonLabel;
    disableButton = false;


    async connectedCallback() {
        this.currentRecordId=this.recordId;
        await getTimesheetRecordById({recordId:this.recordId})
        .then(result=>{
            this.sltProject = result.ProjectId__c;
            this.sltAssignment = result.AssignmentId__c;
            this.sltMilestone = result.MilestoneId__c;
            this.PSASyncStatus = result.PSA_Sync_Status__c;
        })

        await checkIfEligibleToUpdatePSADetails({recordId:this.recordId})
        .then(result=>{
            this.disableButton = !result;
            console.log('OUTPUT : button ',this.disableButton);
            console.log('OUTPUT : result ',result);
        })

        getAssignmentsAndMilestones({projectId:this.sltProject})
        .then(result =>{
            if(result.length>0){
                this.assignementsAndProjects=result[0];
                this.milestonebyProj = result[1];
            }

            //Populate Project Array
            var projectNames=[];
            for(var i=0;i<this.assignementsAndProjects.length;i++){
                var proj= new Object();
                if(!projectNames.includes(this.assignementsAndProjects[i].pse_Project_c__c)){
                    projectNames.push(this.assignementsAndProjects[i].pse_Project_c__c);
                    proj.Id = this.assignementsAndProjects[i].pse_Project_c__c;
                    proj.Name = this.assignementsAndProjects[i].pse_Project_c__r.Name__c;
                    proj.MilestoneRequired = this.assignementsAndProjects[i].pse_Project_c__r.Timecards_require_Milestone_c__c;
                    this.projects.push(proj);
                }
            }

            if(this.sltProject!=''){
                //Populate this.assignments
                this.funcGetAssignement();
                if(result[1]!=null){
                    this.funcGetMilestonesFunc();
                }
            }
        })


    }

    async handleClick(event) {
        this.clickedButtonLabel = event.target.label;
        var updateValidationPassed = true;
        if(this.PSASyncStatus==undefined || this.PSASyncStatus == 'Failed'){
            if((this.sltProject =='' || this.sltProject == null) && this.sltAssignment == '' && this.sltMilestone ==''){
                updateValidationPassed = false;
                this.showWarning('Error','Please select any value to update.');
            }
            else{
                if(this.sltProject !='' && this.sltAssignment ==''){
                    updateValidationPassed = false;
                    this.showWarning('Error','Please select any assignment to update.');
                }
                var result = this.projects.filter(proj => proj.Id == this.sltProject);
                if(result.length > 0 && result[0].MilestoneRequired && this.sltMilestone =='') {
                    updateValidationPassed = false;
                    this.showWarning('Error','Milestone is required for selected project.');
                }
            }
            if(updateValidationPassed){
                console.log('OUTPUT : updateValidation',updateValidationPassed);
                console.log('OUTPUT : ',this.sltProject);
                console.log('OUTPUT : ',this.sltAssignment);
                console.log('OUTPUT : ',this.sltMilestone);
                this.disableButton = true;
                updateDataPSA({Id:this.recordId, ProjectId:this.sltProject, AssignmentId:this.sltAssignment, MilestoneId:this.sltMilestone})
                .then(result=>{
                    console.log('OUTPUT : log',result);
                    if(result!=null){
                        this.showSuccess('Success','Record has updated successfully.');
                        this.disableButton = false;
                    }
                    else{
                        this.showError('Error','Failed to update.');
                        this.disableButton = false;
                    }
                })
            }

        }
        else if (this.PSASyncStatus == 'Success'){
            this.showError('Error','This record is already saved and locked for editing.');
        }
        else{
            this.showError('Error','Error occured while saving this record.');
        }
    }

    handleChangeProject(event) {
        this.sltProject = event.detail.value;
        console.log('OUTPUT : event',this.sltProject);
        this.sltAssignment ='';
        this.sltMilestone = '';
        if(this.sltProject!=''){
            //Populate Assignments
            this.funcGetAssignement();

            //Populate milestones
            this.funcGetMilestones();
        }
    }

    funcGetAssignement(){
		var assignments =[];
		for (var i = 0; i < this.assignementsAndProjects.length; i++){
			if(this.assignementsAndProjects[i].pse_Project_c__c == this.sltProject){
				var assign = new Object();
				assign.Id = this.assignementsAndProjects[i].ExternalId;
				assign.Name = this.assignementsAndProjects[i].Name__c;
				assignments.push(assign);
			}
		}
        this.assignments = assignments;
    }

    funcGetMilestones(){
		var milestones=[];
		getMilestones({projectId: this.sltProject})
			.then(result=>{
				if(result.length>0){
					for(var i=0;i<result.length;i++){
							var mile = new Object();
							mile.Id=result[i].ExternalId;
							mile.Name = result[i].Name__c;
							milestones.push(mile);
					}
				}
			})
        this.milestones=milestones;
    }

    funcGetMilestonesFunc(){
        var milestones=[];
        for(var i=0;i<this.milestonebyProj.length;i++){
                            var mile = new Object();
                            mile.Id=this.milestonebyProj[i].ExternalId;
                            mile.Name =this.milestonebyProj[i].Name__c;
                            milestones.push(mile);
                    }
        this.milestones=milestones;
    }

    handleChangeAssignment(event) {
        this.sltAssignment = event.detail.value;
    }

    handleChangeMilestone(event) {
        this.sltMilestone = event.detail.value;
    }

    get project() {
        return this.getoptions(this.projects);
    }

    get assignment(){
        return this.getoptions(this.assignments);
    }

    get milestone(){
        return this.getoptions(this.milestones);
    }

    getoptions(objectArray){
        let arr=[];
        if(objectArray.length>0){
            for(var i = 0;i<objectArray.length;i++){
                arr.push({label:objectArray[i].Name,value:objectArray[i].Id});
            }
        }
        if(arr.length>0){
            return arr;
        }
    }

    showError(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
    showWarning(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'warning'
        });
        this.dispatchEvent(evt);
    }
    showSuccess(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

}
