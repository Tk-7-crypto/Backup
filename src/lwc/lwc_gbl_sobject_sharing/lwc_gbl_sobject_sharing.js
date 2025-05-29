import fetchSobjectSharingRecords from '@salesforce/apex/CNT_GBL_SobjectSharingHandler.fetchSobjectSharingRecords';
import sObjectSharingProcessedRecords from '@salesforce/apex/CNT_GBL_SobjectSharingHandler.sObjectSharingProcessedRecords';
import initiateSobjectSharing from '@salesforce/apex/CNT_GBL_SobjectSharingHandler.initiateSobjectSharing';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement,api } from 'lwc';

export default class Lwc_crm_sobject_sharing extends LightningElement {
    sharingRecords = [];
    sharingByTeam = "By Team";
    sharingByTerritory = "By Territory";
    allRecords = [];
    isMethodCallFromFirstHierarchy = false;
    showSpinner = false;
    batchProcessingRecords = [];
    batchProcessingStatus = 'In Processing';
    disableSaveBtn = false;
    isAllCheckboxDisabled = false;
    isAnyBatchProcessing = false;
    allTerritoryIds = [];
    isErrorFound = false;
    progress = 50;
    allTerritoryArray = [];
    constructor(){
        super();  
    }
    connectedCallback(){
        this.showSpinner = true;
        this.fetchSobjectSharingRecordsFn();
    }
    @api sObjectSharingProcessedRecordsFn(){
        this.showSpinner = true;
        if(this.isAnyBatchProcessing){
            this._interval = setInterval(() => {  
                var fetchAllInputs = this.template.querySelectorAll('lightning-input');
                for(var i =0;i<fetchAllInputs.length;i++){
                    fetchAllInputs[i].disabled = true;
                    fetchAllInputs[i].checked = false;
                }
                this.disableSaveBtn = true;
                this.isAllCheckboxDisabled = true;
                this.showSpinner = false;
                clearInterval(this._interval);  
            }, this.progress);
        }else if(!this.isAnyBatchProcessing && this.isAllCheckboxDisabled){
            this._interval = setInterval(() => {  
                var fetchAllInputs = this.template.querySelectorAll('lightning-input');
                for(var i =0;i<fetchAllInputs.length;i++){
                    fetchAllInputs[i].disabled = false;
                    //fetchAllInputs[i].checked = false;
                }
                this.disableSaveBtn = false;
                this.isAllCheckboxDisabled = false;
                this.showSpinner = false;
                clearInterval(this._interval);  
            }, this.progress);
        }else{
            this.showSpinner = false;
        }
    }
    fetchSobjectSharingRecordsFn(){
        this.showSpinner = true;
        this.isAnyBatchProcessing = false;
        fetchSobjectSharingRecords()
        .then(result => {
            var resultsArr = [];
            var allSharingRecords = result.allSharing;
            var allTerritory = result.allTerritory;
            if(allTerritory.length > 0){
                this.isNoTerritoryErrorFound  = false;
                for(var a = 0; a < allTerritory.length; a++){
                    if(allTerritory[a].maintenanceStatus == this.batchProcessingStatus){
                        this.isAnyBatchProcessing = true;
                    }
                }
                this.allTerritoryArray = allTerritory;
            }else{
                this.allTerritoryArray = [];
                this.isNoTerritoryErrorFound  = true;
            }
            if(allSharingRecords.length > 0){
                this.isErrorFound = false;
                this.disableSaveBtn = false;
                for(var i=0;i< allSharingRecords.length; i++){
                    var currenResult = allSharingRecords[i];
                    if(currenResult.Maintenance_Job_Status__c == this.batchProcessingStatus){
                        this.isAnyBatchProcessing = true;
                        //continue;   // rendering only those which has batch processing status new
                    }
                    if(currenResult.Sharing_Territory_Label__c != '' && currenResult.Sharing_Territory_Label__c != undefined && currenResult.Sharing_Territory_Label__c != null){
                        var typeObj = {};
                        typeObj.type = this.sharingByTerritory;
                        var resultArrayLocationToUpdate = -1;
                        for(var j=0;j< resultsArr.length;j++){
                            var currentResult = resultsArr[j];
                            if(currentResult.type == this.sharingByTerritory){
                                typeObj = currentResult;
                                resultArrayLocationToUpdate = j;
                                break;
                            }
                        }
                        var subDataArray = [];
                        if(typeObj.subData != undefined){
                            subDataArray = typeObj.subData;
                        }
                        var subDataObj = {};
                        var subDataArrayLocationToUpdate = -1;
                        for(var j=0;j< subDataArray.length;j++){
                            var currentsubData = subDataArray[j];
                            if(currentsubData.parentObj == currenResult.Parent_Sobject__c){
                                subDataObj = currentsubData;
                                subDataArrayLocationToUpdate = j;
                                break;
                            }
                        }
                        var childDataArray = [];
                        var childDataObj = {};
                        if(subDataObj.parentObj != undefined){
                            childDataArray = subDataObj.childObj;
                        }else{
                            subDataObj.parentObj = currenResult.Parent_Sobject__c;
                        }
                        if(currenResult.Parent_Sobject__c){
                            if(currenResult.Child_Sobject__c != null){
                                childDataObj.childObjName = currenResult.Child_Sobject__c;
                                childDataObj.id = currenResult.Id;
                                if(currenResult.Maintenance_Job_Status__c == this.batchProcessingStatus){
                                    childDataObj.status = currenResult.Maintenance_Job_Status__c;
                                }else{
                                    childDataObj.status = '';
                                }
                                childDataArray.push(childDataObj);
                            }else{
                                childDataObj.childObjName = currenResult.Parent_Sobject__c;
                                childDataObj.id = currenResult.Id;
                                childDataObj.status = currenResult.Maintenance_Job_Status__c;
                                childDataArray.push(childDataObj);
                            }
                            subDataObj.childObj = childDataArray;
                            if(subDataArrayLocationToUpdate != -1){
                                subDataArray[subDataArrayLocationToUpdate] = subDataObj;
                            }else{
                                subDataArray.push(subDataObj);
                            }
                            typeObj.subData = subDataArray;
                            if(resultArrayLocationToUpdate != -1){
                                resultsArr[resultArrayLocationToUpdate] = typeObj;
                            }else{
                                resultsArr.push(typeObj);
                            }
                        }
                    }
                    if(currenResult.Sharing_Team_Label__c != undefined && currenResult.Sharing_Team_Label__c != null && currenResult.Sharing_Team_Label__c != ''){
                        var typeObj = {};
                        typeObj.type = this.sharingByTeam;
                        var resultArrayLocationToUpdate = -1;
                        for(var j=0;j< resultsArr.length;j++){
                            var currentResult = resultsArr[j];
                            if(currentResult.type == this.sharingByTeam){
                                typeObj = currentResult;
                                resultArrayLocationToUpdate = j;
                                break;
                            }
                        }
                        var subDataArray = [];
                        if(typeObj.subData != undefined){
                            subDataArray = typeObj.subData;
                        }
                        var subDataObj = {};
                        var subDataArrayLocationToUpdate = -1;
                        for(var j=0;j< subDataArray.length;j++){
                            var currentsubData = subDataArray[j];
                            if(currentsubData.parentObj == currenResult.Parent_Sobject__c){
                                subDataObj = currentsubData;
                                subDataArrayLocationToUpdate = j;
                                break;
                            }
                        }
                        var childDataArray = [];
                        var childDataObj = {};
                        if(subDataObj.parentObj != undefined){
                            childDataArray = subDataObj.childObj;
                        }else{
                            subDataObj.parentObj = currenResult.Parent_Sobject__c;
                        }
                        if(currenResult.Parent_Sobject__c){
                            if(currenResult.Child_Sobject__c != null){
                                childDataObj.childObjName = currenResult.Child_Sobject__c;
                                childDataObj.id = currenResult.Id;
                                childDataObj.status = currenResult.Maintenance_Job_Status__c;
                                childDataArray.push(childDataObj);
                            }else{
                                childDataObj.childObjName = currenResult.Parent_Sobject__c;
                                childDataObj.id = currenResult.Id;
                                if(currenResult.Maintenance_Job_Status__c == this.batchProcessingStatus){
                                    childDataObj.status = currenResult.Maintenance_Job_Status__c;
                                }else{
                                    childDataObj.status = '';
                                }
                                childDataArray.push(childDataObj);
                            }
                            subDataObj.childObj = childDataArray;
                            if(subDataArrayLocationToUpdate != -1){
                                subDataArray[subDataArrayLocationToUpdate] = subDataObj;
                            }else{
                                subDataArray.push(subDataObj);
                            }
                            typeObj.subData = subDataArray;
                            if(resultArrayLocationToUpdate != -1){
                                resultsArr[resultArrayLocationToUpdate] = typeObj;
                            }else{
                                resultsArr.push(typeObj);
                            }
                        }
                    }
                    
                }
                this.allRecords = resultsArr;
                console.log('--this.isAnyBatchProcessing---'+this.isAnyBatchProcessing);
                this.sObjectSharingProcessedRecordsFn();
            }else{
                this.isErrorFound = true;
                this.disableSaveBtn = true;
                this.showSpinner = false;
            }
            console.log(resultsArr);
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: error,
                    variant: 'error',
                }),
            );
            this.showSpinner = true;
        });
    }
    refreshView(){
        
    }
    setParentBlockvisibility(event){
        var clickedBtn = event.currentTarget;
        var currentBtnIcon = clickedBtn.iconName;
        if(currentBtnIcon == 'utility:add'){
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.remove('slds-hide');
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.add('slds-show');
            clickedBtn.iconName ='utility:dash';
        }else{
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.remove('slds-show');
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.add('slds-hide');
            clickedBtn.iconName ='utility:add';
        }
    }

    setSecondBlockvisibility(event){
        var clickedBtn = event.currentTarget;
        var currentBtnIcon = clickedBtn.iconName;
        if(currentBtnIcon == 'utility:add'){
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.remove('slds-hide');
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.add('slds-show');
            clickedBtn.iconName ='utility:dash';
        }else{
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.remove('slds-show');
            clickedBtn.parentElement.parentElement.parentElement.nextSibling.classList.add('slds-hide');
            clickedBtn.iconName ='utility:add';
        }
    }
    saveSharing(event){
        this.showSpinner = true;
        if(this.sharingRecords.length < 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please select atleast one row.',
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
            return;
        }else{
            //send selecte Ids to controller
            initiateSobjectSharing({sharingType : 'allSharing', sharingIds : this.sharingRecords})
            .then(result => { 
                //console.log(result);
                if(result.length > 0){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'sObject sharing processsed, please wait till process finish.',
                            variant: 'success',
                        }),
                    );
                    this.isAnyBatchProcessing = true;
                    this.sObjectSharingProcessedRecordsFn();
                    this.closeModal();
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error,
                        variant: 'error',
                    }),
                );
                this.showSpinner = false;
            });
        }
    }
    setCheckboxVal(event){ 
        var clickedBtn = event.currentTarget;
        var parentDiv = event.currentTarget.parentElement.parentElement.parentElement.parentElement;
        var parentAllcheckboxDiv = parentDiv.previousSibling;
        var parentAllcheckboxDivInputs = parentAllcheckboxDiv.querySelectorAll('lightning-input');
        var firstHierarchyLevelDiv = event.currentTarget.parentElement.parentElement.parentElement.parentElement.parentElement.previousSibling;
        var firstHierarchyLevelDivInputs = firstHierarchyLevelDiv.querySelectorAll('lightning-input');
        if(clickedBtn.checked){
            this.sharingRecords.push(clickedBtn.dataset.recid);
            var allSiblingChckbox = parentDiv.querySelectorAll('lightning-input');
            var checkedCount = 0;
            var allcheckedCount = 0;
            for(var i =0;i<allSiblingChckbox.length;i++){
                if(allSiblingChckbox[i].checked){
                    checkedCount++;
                }
            }
            if(allSiblingChckbox.length == checkedCount){
                if(parentAllcheckboxDivInputs.length > 0){
                    parentAllcheckboxDivInputs[0].checked = clickedBtn.checked;
                }
            }
            var allParentLevelCheckboxDiv = event.currentTarget.parentElement.parentElement.parentElement.parentElement.parentElement;
            var allParentLevelCheckboxes = allParentLevelCheckboxDiv.querySelectorAll('lightning-input');
            for(var i =0;i<allParentLevelCheckboxes.length;i++){
                if(allParentLevelCheckboxes[i].checked){
                    allcheckedCount++;
                }
            }
            if(allParentLevelCheckboxes.length == allcheckedCount){
                if(firstHierarchyLevelDivInputs.length > 0){
                    firstHierarchyLevelDivInputs[0].checked = clickedBtn.checked;
                }
            }
        }else{
            var valueIndex = this.sharingRecords.indexOf(clickedBtn.dataset.recid);
            if (valueIndex > -1) {
                this.sharingRecords.splice(valueIndex, 1);
            }
            if(parentAllcheckboxDivInputs.length > 0){
                parentAllcheckboxDivInputs[0].checked = clickedBtn.checked;
            }
            if(firstHierarchyLevelDivInputs.length > 0){
                firstHierarchyLevelDivInputs[0].checked = clickedBtn.checked;
            }
        }
    }
    checkAllChildCheckbox(event){
        var clickedBtn = event.currentTarget;
        var nextSibling = clickedBtn.parentElement.parentElement.parentElement.nextSibling;
        //var allChildCheckboxes = nextSibling.querySelectorAll('lightning-input');
        var childCheckboxVal = false;
        var firstHierarchyLevelDiv;
        var firstHierarchyLevelDivInputs;
        if(!this.isMethodCallFromFirstHierarchy){
            firstHierarchyLevelDiv = event.currentTarget.parentElement.parentElement.parentElement.parentElement.previousSibling;
            firstHierarchyLevelDivInputs = firstHierarchyLevelDiv.querySelectorAll('lightning-input');
        }
        var allChildCheckboxes = nextSibling.querySelectorAll('lightning-input');
        var childCheckboxVal = false;
        if(clickedBtn.checked){
            childCheckboxVal = true;
        }
        for(var i =0;i<allChildCheckboxes.length;i++){
            if(allChildCheckboxes[i].checked != childCheckboxVal){
                allChildCheckboxes[i].checked = childCheckboxVal;
                if(childCheckboxVal){
                    if(allChildCheckboxes[i].dataset != undefined && allChildCheckboxes[i].dataset.recid != undefined){
                        this.sharingRecords.push(allChildCheckboxes[i].dataset.recid);
                    }
                }else{
                    if(allChildCheckboxes[i].dataset != undefined && allChildCheckboxes[i].dataset.recid != undefined){
                        var valueIndex = this.sharingRecords.indexOf(allChildCheckboxes[i].dataset.recid);
                        if (valueIndex > -1) {
                            this.sharingRecords.splice(valueIndex, 1);
                        }  
                    }   
                    if(!this.isMethodCallFromFirstHierarchy && firstHierarchyLevelDivInputs.length > 0){
                        firstHierarchyLevelDivInputs[0].checked = false;
                    }                 
                }
            }
        }
        if(clickedBtn.checked && !this.isMethodCallFromFirstHierarchy){
            var allParentLevelCheckboxDiv = clickedBtn.parentElement.parentElement.parentElement.parentElement;
            var allParentLevelCheckboxes = allParentLevelCheckboxDiv.querySelectorAll('lightning-input');
            var allcheckedCount = 0;
            for(var i =0;i<allParentLevelCheckboxes.length;i++){
                if(allParentLevelCheckboxes[i].checked){
                    allcheckedCount++;
                }
            }
            if(allParentLevelCheckboxes.length == allcheckedCount){
                if(firstHierarchyLevelDivInputs.length > 0){
                    firstHierarchyLevelDivInputs[0].checked = clickedBtn.checked;
                }
            }
        }
        this.isMethodCallFromFirstHierarchy = false;
    }
    checkAllCheckboxes(event){
        this.isMethodCallFromFirstHierarchy = true;
        this.checkAllChildCheckbox(event);
    }
    checkAllTerritory(event){
        var allTerritoryNamesToError = '';
        var clickedBtn = event.currentTarget;
        var nextSibling = clickedBtn.parentElement.parentElement.parentElement.nextSibling;
        //var allChildCheckboxes = nextSibling.querySelectorAll('lightning-input');
        var childCheckboxVal = false;
        var allChildCheckboxes = nextSibling.querySelectorAll('lightning-input');
        var childCheckboxVal = false;
        if(clickedBtn.checked){
            childCheckboxVal = true;
        }
        for(var i =0;i<allChildCheckboxes.length;i++){
            if(allChildCheckboxes[i].checked != childCheckboxVal){
                if(childCheckboxVal){
                    console.log(allChildCheckboxes[i].dataset.terid);
                    if(allChildCheckboxes[i].dataset != undefined && allChildCheckboxes[i].dataset.terid != undefined && allChildCheckboxes[i].dataset.terid != '' && allChildCheckboxes[i].dataset.terid != null){
                        var res = (allChildCheckboxes[i].dataset.terid).split(',');
                        for(var j=0;j< res.length; j++){
                            if(! this.allTerritoryIds.includes(res[j])){
                                this.allTerritoryIds.push(res[j]);
                            }
                        }
                        allChildCheckboxes[i].checked = childCheckboxVal;
                    }else if(allChildCheckboxes[i].dataset.terid == undefined || allChildCheckboxes[i].dataset.terid != '' || allChildCheckboxes[i].dataset.terid != null){
                        allTerritoryNamesToError += allChildCheckboxes[i].dataset.tername +', ';
                        allChildCheckboxes[i].checked = false;
                    }
                }else{
                    if(allChildCheckboxes[i].dataset != undefined && allChildCheckboxes[i].dataset.terid != undefined  && allChildCheckboxes[i].dataset.terid != '' && allChildCheckboxes[i].dataset.terid != null){
                        var res = (allChildCheckboxes[i].dataset.terid).split(',');
                        for(var j=0;j< res.length; j++){
                            var valueIndex = this.allTerritoryIds.indexOf(res[j]);
                            if (valueIndex > -1) {
                                this.allTerritoryIds.splice(valueIndex, 1);
                            } 
                        } 
                    }                 
                }
            }
        }
        if(allTerritoryNamesToError != ''){
            clickedBtn.checked = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'No territory sharing record found for '+allTerritoryNamesToError+'.',
                    variant: 'error',
                }),
            );
        }
        console.log(this.allTerritoryIds);
    }
    checkCurrentTerritory(event){
        var clickedBtn = event.currentTarget;
        var firstHierarchyLevelDiv = clickedBtn.parentElement.parentElement.parentElement.parentElement.previousSibling;
        var firstHierarchyLevelDivInputs = firstHierarchyLevelDiv.querySelectorAll('lightning-input');
        if(clickedBtn.checked){
            if(clickedBtn.dataset.terid != undefined && clickedBtn.dataset.terid != '' && clickedBtn.dataset.terid != null){
                var res = (clickedBtn.dataset.terid).split(',');
                for(var j=0;j< res.length; j++){
                    if(! this.allTerritoryIds.includes(res[j])){
                        this.allTerritoryIds.push(res[j]);
                    }
                }
            }else{
                clickedBtn.checked = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: 'No territory sharing record found for '+clickedBtn.dataset.tername +' territory.',
                        variant: 'error',
                    }),
                );
                return;
            }
            var allParentLevelCheckboxDiv = clickedBtn.parentElement.parentElement.parentElement.parentElement;
            var allParentLevelCheckboxes = allParentLevelCheckboxDiv.querySelectorAll('lightning-input');
            var allcheckedCount = 0;
            for(var i =0;i<allParentLevelCheckboxes.length;i++){
                if(allParentLevelCheckboxes[i].checked){
                    allcheckedCount++;
                }
            }
            if(allParentLevelCheckboxes.length == allcheckedCount){
                if(firstHierarchyLevelDivInputs.length > 0){
                    firstHierarchyLevelDivInputs[0].checked = clickedBtn.checked;
                }
            }
        }else{
            if(clickedBtn.dataset.terid != undefined && clickedBtn.dataset.terid != '' && clickedBtn.dataset.terid != null){
                var res = (clickedBtn.dataset.terid).split(',');
                for(var j=0;j< res.length; j++){
                    var valueIndex = this.allTerritoryIds.indexOf(res[j]);
                    if (valueIndex > -1) {
                        this.allTerritoryIds.splice(valueIndex, 1);
                    } 
                }
            }
            if(firstHierarchyLevelDivInputs.length > 0){
                firstHierarchyLevelDivInputs[0].checked = false;
            }
        }
        console.log(this.allTerritoryIds);
    }
    saveTerritorySharing(){
        this.showSpinner = true;
        console.log(this.allTerritoryIds);
        if(this.allTerritoryIds.length < 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please select atleast one row.',
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
            return;
        }else{
            initiateSobjectSharing({sharingType : 'allTerritory', sharingIds : this.allTerritoryIds})
            .then(result => { 
                //console.log(result);
                if(result.length > 0){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'sObject sharing processsed, please wait till process finish.',
                            variant: 'success',
                        }),
                    );
                    this.isAnyBatchProcessing = true;
                    this.sObjectSharingProcessedRecordsFn();
                    this.closeModal();
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error,
                        variant: 'error',
                    }),
                );
                this.showSpinner = false;
            });
        }
    }
    @api closeModal(){
        this.dispatchEvent(
            new CustomEvent("closeModalHandler",({detail:{hide : true}}))
        );
    }
}