import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCollectionToolRecordsForOthers from '@salesforce/apex/CNT_OWF_CollectionTools.fetchCollectionTool';
import { CurrentPageReference } from "lightning/navigation";
import { refreshApex } from '@salesforce/apex';
import fetchCollectionToolRecordsForECOAOnly from '@salesforce/apex/CNT_OWF_CollectionTools.fetchCollectionTool';
import fetchBidHistoryRecord from '@salesforce/apex/CNT_OWF_CollectionTools.fetchBidHistory';
import upsertCollectionTools from '@salesforce/apex/CNT_OWF_CollectionTools.upsertCollectionTools';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ECOA_COLLECTION_TOOL_OBJECT from '@salesforce/schema/CollectionTool__c';
import COA_LIBRARY_ASSESSMENT_PICKLIST from '@salesforce/schema/CollectionTool__c.COA_Library_Assessment__c';
import LIST_THE_COUNTRIES_PICKLIST from '@salesforce/schema/CollectionTool__c.Countries__c';
import SELECT_DEVICE_TYPE_PICKLIST from '@salesforce/schema/CollectionTool__c.Select_Device_Type__c';
import COA_TYPE_PICKLIST from '@salesforce/schema/CollectionTool__c.COA_Type__c';
import { NavigationMixin } from 'lightning/navigation';



export default class Lwc_owf_collectionTool extends NavigationMixin(LightningElement) {
    @api recordId;  
    @track collectionToolRecForOthers = [];
    @track collectionToolRecForECOAOnly = [];
    @track recordTypeIdApplicableToOthers = '';
    @track recordTypeIdECOAOnly = '';
    @track IQVIATechnologiesRecordTypeId ='';
    @track numberOfScenarios;
    @track bidHistoryRecord;
    @track bidHistoryId;
    @track secondTableVisible;
    @track firstTableVisible;
    isLoading = true;
    @track wiredOtherCollectionRecord = [];
    updatedRecordsListForOthers = [];
    deletedRecordsIdListForOthers = [];
    updatedRecordsListForECOAOnly = [];
    deletedRecordsIdListForECOAOnly = [];
    countriesPicklistValues = [];
    cOATypePicklistValue = [];
    assessmentPicklistValues = [];
    deviceTypePicklistValues = [];
    orgCollectionToolRecForOthers = [];
    orgCollectionToolRecForECOAOnly = [];
    @track wiredECOACollectionRecord = [];
    @track wiredBid=[];
    @api ready;
    

    @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__Bid_History;
            if (urlValue) {
                this.recordId = urlValue;
            }
            this.ready = currentPageReference.state.c__ready;
        }
    }
    
    @wire(getObjectInfo,{objectApiName : ECOA_COLLECTION_TOOL_OBJECT})
    objectInfo({data,error}){
        if(data){
            this.recordTypeIdApplicableToOthers = 'Other';
            this.IQVIATechnologiesRecordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === 'IQVIA Technologies');


            this.recordTypeIdECOAOnly = 'ECOA';
            this.error = undefined;
        }
        if(error){
            this.error = error;
        }
    }


    @wire(getPicklistValues,{recordTypeId : "$IQVIATechnologiesRecordTypeId", fieldApiName : LIST_THE_COUNTRIES_PICKLIST})
    picklistValuesOfCountries({error,data}) {
        if(data){
            this.countriesPicklistValues = [];
            this.countriesPicklistValues = data.values;
            this.error = undefined;
        } 
        else if(error){ 
            this.error = error;
        }
    } 

    @wire(getPicklistValues,{recordTypeId : "$IQVIATechnologiesRecordTypeId", fieldApiName : COA_TYPE_PICKLIST})
    picklistValuesOfCOAType({error,data}) {
        if(data){
            this.cOATypePicklistValue = [];
            this.cOATypePicklistValue = data.values;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
        }
    }


    @wire(getPicklistValues,{recordTypeId : "$IQVIATechnologiesRecordTypeId", fieldApiName : COA_LIBRARY_ASSESSMENT_PICKLIST})
    picklistValuesOfAssessment({error,data}) {
        if(data) {
            this.assessmentPicklistValues = [];
            this.assessmentPicklistValues = data.values;
            this.error = undefined;
        } 
        else if (error) {
            this.error = error;
        }
    } 


    @wire(getPicklistValues,{recordTypeId : "$IQVIATechnologiesRecordTypeId", fieldApiName : SELECT_DEVICE_TYPE_PICKLIST})
    picklistValuesOfDeviceType({error,data }) {
        if(data){
            this.deviceTypePicklistValues = [];
            this.deviceTypePicklistValues = data.values;
            this.error = undefined;
        } 
        else if (error) {
            this.error = error;
        }
    } 
    
    @wire(fetchBidHistoryRecord,{recordId : '$recordId'})
    fetchBidHistory(result){
        this.isLoading = true;
        this.wiredBid = result;
        const { data, error } = result;
        if(data){
            let firstTableVisible;
            this.firstTableVisible = false;
            this.secondTableVisible = false;
            this.bidHistoryRecord = data;
            firstTableVisible = (this.bidHistoryRecord.Complete_Consent__c || this.bidHistoryRecord.IRT__c || this.bidHistoryRecord.Connected_Devices__c || this.bidHistoryRecord.eCOA__c);
            this.numberOfScenarios = this.bidHistoryRecord.Number_of_Scenarios__c;
            if(!firstTableVisible){
                this.showToast('Warning', 'Collection Tool is not required for selected Product(s)', 'Warning', 'dismissable');
                setTimeout(() => {
                    window.open('/'+this.recordId,'_self')
                }, 3000);
            } 
            else if(!this.numberOfScenarios || this.numberOfScenarios <=0 || this.numberOfScenarios > 15){
                this.showToast('Warning', 'Number of Scenarios should not be blank and should be from 1 to 15', 'Warning', 'dismissable');
                setTimeout(() => {
                    window.open('/'+this.recordId,'_self')
                }, 3000);
            }
            else{
                 this.bidHistoryId = this.bidHistoryRecord.Id;
                 this.firstTableVisible = (this.bidHistoryRecord.Complete_Consent__c || this.bidHistoryRecord.IRT__c || this.bidHistoryRecord.Connected_Devices__c || this.bidHistoryRecord.eCOA__c);
                 this.secondTableVisible = this.bidHistoryRecord.eCOA__c;
            }
        }
    }


    @wire(fetchCollectionToolRecordsForOthers,{recordId : '$recordId',bidHistoryRecord : '$bidHistoryRecord',numberOfScenarios : '$numberOfScenarios',recordTypeId : 'Other'})  
    fetchRecordsForFirstSetOfTables(result) {
        this.wiredOtherCollectionRecord = result;
        const { data, error } = result;
        if(data){
            if(data[0].collectionToolRecords.length != 0 && data[0].collectionToolRecords[0].Bid_History__c != this.bidHistoryId){
                this.orgCollectionToolRecForOthers = [];
                this.cloneRecordsFromPreviousBid(JSON.parse(JSON.stringify(data)),this.recordTypeIdApplicableToOthers);
            }
            else{
                this.orgCollectionToolRecForOthers = JSON.parse(JSON.stringify(data));
                this.collectionToolRecForOthers = JSON.parse(JSON.stringify(data));
                this.error = undefined;
            }
        }
        else if(error) {
            this.error = error;
            this.collectionToolRecForOthers = undefined;
        }  
    }
   
    @wire(fetchCollectionToolRecordsForECOAOnly,{recordId : '$recordId' ,bidHistoryRecord : '$bidHistoryRecord',numberOfScenarios : '$numberOfScenarios',recordTypeId : 'ECOA'})  
    fetchRecordsForSecondSetOfTables(result) {
        this.wiredECOACollectionRecord = result;
        const { data, error } = result;
        if(data){
            if(data[0].collectionToolRecords.length != 0 && data[0].collectionToolRecords[0].Bid_History__c != this.bidHistoryId){
                this.orgCollectionToolRecForECOAOnly = [];
                this.cloneRecordsFromPreviousBid(JSON.parse(JSON.stringify(data)),this.recordTypeIdECOAOnly);
            }
            else{
                this.orgCollectionToolRecForECOAOnly = JSON.parse(JSON.stringify(data));
                this.collectionToolRecForECOAOnly = JSON.parse(JSON.stringify(data));
                this.error = undefined;
            } 
            this.isLoading = false;
        }
           
        else if(error){
            this.error = error;
            this.collectionToolRecForECOAOnly = undefined;
        }
    }
	
    renderedCallback(){
        if(this.ready){
            this.deletedRecordsIdListForOthers = [];
            this.deletedRecordsIdListForECOAOnly = [];
            this.updatedRecordsListForECOAOnly = [];
            this.updatedRecordsListForOthers = [];
            refreshApex(this.wiredBid);
            refreshApex(this.wiredECOACollectionRecord);
            refreshApex(this.wiredOtherCollectionRecord);
            this.ready = false;
            this.isLoading = false;
        }
    }

    handleDeleteRowAction(event){
        let tableNumber = event.target.dataset.item;
        let recordTypeId = event.target.dataset.field;
        if(recordTypeId == this.recordTypeIdApplicableToOthers){
            this.deletedRecordsIdListForOthers.push((event.target.dataset.id).toString());
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords = this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.filter(record=>{
                if(record.Id!=event.target.dataset.id){
                    return record;
                }
            })
            this.updatedRecordsListForOthers = this.updatedRecordsListForOthers.filter(record=>{
                if(record.Id!=event.target.dataset.id){
                    return record;  
                }
            })
            this.calculateSumOfvalues(event,'',tableNumber);
        }
        else if(recordTypeId == this.recordTypeIdECOAOnly){
            this.deletedRecordsIdListForECOAOnly.push((event.target.dataset.id).toString());
            this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords = this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords.filter(record=>{
                if(record.Id!=event.target.dataset.id){
                    return record;
                }
            })
            this.updatedRecordsListForECOAOnly = this.updatedRecordsListForECOAOnly.filter(record=>{
                if(record.Id!=event.target.dataset.id){
                    return record;  
                }
            })
        }
    }
   
    handleCloneTableActionForOthers(event) {
        let index=event.target.dataset.id;
        this.collectionToolRecForOthers[index-1].collectionToolRecords.forEach(element => {
            this.deletedRecordsIdListForOthers.push((element.Id).toString());
        });
        this.updatedRecordsListForOthers = this.updatedRecordsListForOthers.filter(record=>{
            var recordId = String(record.Id);
            if(!(this.deletedRecordsIdListForOthers.includes(recordId))){
                return record;  
            }
        })
        this.collectionToolRecForOthers[index-1].collectionToolRecords=[];
        if(index!=1){
            this.collectionToolRecForOthers[index-2].collectionToolRecords.forEach(element => {
                let randomId=element.Id+Date.now();
                let newCollectionToolRecord = {Countries__c: element.Countries__c, Type__c:this.recordTypeIdApplicableToOthers,RecordTypeId:this.IQVIATechnologiesRecordTypeId, Number_of_Enrolled_Patients__c: element.Number_of_Enrolled_Patients__c,
                    Number_of_Sites__c: element.Number_of_Sites__c, Id:randomId , Scenario_Number__c:index, Bid_History__c: this.recordId, Screened_Patients__c:element.Screened_Patients__c,
                    FPI_Date__c:this.collectionToolRecForOthers[index-1].FPI,LPI_Date__c:this.collectionToolRecForOthers[index-1].LPI,LPO_Date__c:this.collectionToolRecForOthers[index-1].LPO,DBL_Date__c:this.collectionToolRecForOthers[index-1].DBL};
                this.collectionToolRecForOthers[index-1].collectionToolRecords=[...this.collectionToolRecForOthers[index-1].collectionToolRecords, newCollectionToolRecord];
                this.updatedRecordsListForOthers.push(newCollectionToolRecord);
                
            });
        }
        this.calculateSumOfvalues(event,'',index);
    }

    handleCloneTableActionForECOAOnly(event){
        let index = event.target.dataset.id;
        this.collectionToolRecForECOAOnly[index-1].collectionToolRecords.forEach(element => {
            this.deletedRecordsIdListForECOAOnly.push((element.Id).toString());
        });
        this.updatedRecordsListForECOAOnly = this.updatedRecordsListForECOAOnly.filter(record=>{
            var recordId = String(record.Id);
            if(!(this.deletedRecordsIdListForECOAOnly.includes(recordId))){
                return record;  
            }
        })
        this.collectionToolRecForECOAOnly[index-1].collectionToolRecords = [];
        if(index!=1){
            this.collectionToolRecForECOAOnly[index-2].collectionToolRecords.forEach(element => {
                let randomId = element.Id+Date.now();
                let newCollectionToolRecord = {Description_if_not_within_library__c: element.Description_if_not_within_library__c, RecordTypeId:this.IQVIATechnologiesRecordTypeId,Type__c:this.recordTypeIdECOAOnly, Specific_Device_Strategy__c: element.Specific_Device_Strategy__c,
                    Select_Device_Type__c: element.Select_Device_Type__c, COA_Library_Assessment__c: element.COA_Library_Assessment__c, Id:randomId , Scenario_Number__c:index, Bid_History__c: this.recordId, COA_Type__c:element.COA_Type__c};
                this.collectionToolRecForECOAOnly[index-1].collectionToolRecords=[...this.collectionToolRecForECOAOnly[index-1].collectionToolRecords, newCollectionToolRecord];
                this.updatedRecordsListForECOAOnly.push(newCollectionToolRecord);
            });
        }
    }

    handleAddRowAction(event) {
        let randomId = Date.now();
        let recordTypeId = event.target.dataset.item;
        let index = event.target.dataset.id;
        if(recordTypeId == this.recordTypeIdApplicableToOthers){
            let newCollectionToolRecord = {Countries__c: "", Number_of_Enrolled_Patients__c: "", Number_of_Sites__c: "", RecordTypeId:this.IQVIATechnologiesRecordTypeId, Type__c:this.recordTypeIdApplicableToOthers, Id:randomId , Scenario_Number__c:index, Bid_History__c: this.recordId, Screened_Patients__c : "",
                FPI_Date__c:this.collectionToolRecForOthers[index-1].FPI,LPI_Date__c:this.collectionToolRecForOthers[index-1].LPI,LPO_Date__c:this.collectionToolRecForOthers[index-1].LPO,DBL_Date__c:this.collectionToolRecForOthers[index-1].DBL};
            this.collectionToolRecForOthers[index-1].collectionToolRecords = [...this.collectionToolRecForOthers[index-1].collectionToolRecords, newCollectionToolRecord];
        }
        else if(recordTypeId==this.recordTypeIdECOAOnly){
            let newCollectionToolRecord = {COA_Library_Assessment__c: "", Specific_Device_Strategy__c: "", Select_Device_Type__c: "",Description_if_not_within_library__c:"",COA_Type__c:"",RecordTypeId:this.IQVIATechnologiesRecordTypeId,Type__c:this.recordTypeIdECOAOnly, Id:randomId , Scenario_Number__c:index, Bid_History__c: this.recordId};
            this.collectionToolRecForECOAOnly[index-1].collectionToolRecords = [...this.collectionToolRecForECOAOnly[index-1].collectionToolRecords, newCollectionToolRecord];
        }
    }
    
    updateValuesForOthers(event){
        const recordId = event.target.dataset.id;
        const tableNumber = event.target.dataset.item;
        const field = event.target.dataset.field;
        const index = this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.findIndex(r=> r.Id==recordId);
        this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords[index][field] = event.target.value;
        var currentUpdatedRecord = JSON.parse(JSON.stringify(this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.find(ele => ele.Id == recordId)));
        const currentUpdatedRecordExisted = this.updatedRecordsListForOthers.find(ele => ele.Id == recordId);
        if(currentUpdatedRecordExisted){
            Object.assign(currentUpdatedRecordExisted,currentUpdatedRecord);  
        }
        else{
            this.updatedRecordsListForOthers.push(currentUpdatedRecord);
        }
        this.calculateSumOfvalues(event,field,tableNumber);
    }

    updateValuesForECOAOnly(event){
        const recordId = event.target.dataset.id;
        const tableNumber = event.target.dataset.item;
        const field = event.target.dataset.field;
        const index = this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords.findIndex(r=> r.Id==recordId);
        if(event.target.value != undefined){
            this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords[index][field] = event.target.value;
        }
        else{
            this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords[index][field] = event.detail.value;
        }
        var currentUpdatedRecord = JSON.parse(JSON.stringify(this.collectionToolRecForECOAOnly[tableNumber-1].collectionToolRecords.find(ele => ele.Id == recordId)));
        const currentUpdatedRecordExisted=this.updatedRecordsListForECOAOnly.find(ele => ele.Id == recordId);
        if(currentUpdatedRecordExisted){
            Object.assign(currentUpdatedRecordExisted,currentUpdatedRecord);  
        }
        else{
            this.updatedRecordsListForECOAOnly.push(currentUpdatedRecord);
        }
    }

    checkAllScenariosFilledOrNot(recordType) {
        let allScenariosFilled = false;
        let collectionToolRecordsToCheckList = [];
        if (recordType != '' && recordType === this.recordTypeIdApplicableToOthers) {
            collectionToolRecordsToCheckList = JSON.parse(JSON.stringify(this.collectionToolRecForOthers));
        } else if (recordType != '' && recordType === this.recordTypeIdECOAOnly) {
            collectionToolRecordsToCheckList = JSON.parse(JSON.stringify(this.collectionToolRecForECOAOnly));
        }
        for (let scenarioNumber = 1; scenarioNumber <= collectionToolRecordsToCheckList.length; scenarioNumber++) {
            if (collectionToolRecordsToCheckList[scenarioNumber - 1].collectionToolRecords && collectionToolRecordsToCheckList[scenarioNumber - 1].collectionToolRecords.length) {
                allScenariosFilled = collectionToolRecordsToCheckList[scenarioNumber - 1].collectionToolRecords.some(collectionToolRecord => {
                    if (recordType != '' && recordType === this.recordTypeIdECOAOnly
                        && (collectionToolRecord.COA_Library_Assessment__c !== '' || collectionToolRecord.Description_if_not_within_library__c !== ''
                            || collectionToolRecord.Select_Device_Type__c !== '' || collectionToolRecord.Specific_Device_Strategy__c !== '' || collectionToolRecord.COA_Type__c !== '')) {
                        return true;
                    } else if (recordType != '' && recordType === this.recordTypeIdApplicableToOthers &&
                        (collectionToolRecord.Countries__c !== '' || collectionToolRecord.Number_of_Sites__c !== ''
                            || collectionToolRecord.Number_of_Enrolled_Patients__c !== '' || collectionToolRecord.Screened_Patients__c !== '')) {
                        return true;
                    } else {
                        return false;
                    }
                });
            } else {
                allScenariosFilled = false;
                break;
            }
        }
        return allScenariosFilled;
    }

    saveCollectionToolRecordsListForOthers(event) {
        let isValidated = false;
        isValidated = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if(isValidated){
            this.handleIsLoading(true);
            if (this.checkAllScenariosFilledOrNot(this.recordTypeIdApplicableToOthers)) {
                this.updatedRecordsListForOthers = this.updatedRecordsListForOthers.filter(record => {
                    if (!(record.Number_of_Enrolled_Patients__c == '' && record.Number_of_Sites__c == '' && record.Countries__c == '' && record.Screened_Patients__c == '')) {
                        return record;
                    }
                })
                upsertCollectionTools({ existingRecordsMap: this.orgCollectionToolRecForOthers, updatedRecords: this.updatedRecordsListForOthers, deletedRecordsIdList: this.deletedRecordsIdListForOthers, bidHistoryId: this.bidHistoryId })
                    .then(result => {
                        this.handleIsLoading(false);
                        this.showToast('Success', 'Records successfully saved!', 'Success', 'dismissable');
                        this.updatedRecordsListForOthers = [];
                        this.deletedRecordsIdListForOthers = [];
                        refreshApex(this.wiredOtherCollectionRecord);
                        if (!this.secondTableVisible) {
                            this.navigateToRecord();
                        }
                    }).catch(error => {
                        this.handleIsLoading(false);
                        this.showToast('Error Saving or refreshing records', error.body.message, 'Error', 'dismissable');
                    }).finally(() => {
                        this.handleIsLoading(false);
                    });
            } else {
                this.handleIsLoading(false);
                this.showToast('Error', 'Please complete collection tool for all Scenarios', 'Error', 'dismissable');
            }
        }
        else{
             this.showToast('Error', 'Please complete all required fields', 'Error', 'dismissable');
        }
    }


    saveCollectionToolRecordsListForECOAOnly(event) {
        this.handleIsLoading(true);
        if (this.checkAllScenariosFilledOrNot(this.recordTypeIdECOAOnly)) {
            this.updatedRecordsListForECOAOnly = this.updatedRecordsListForECOAOnly.filter(record => {
                if (!(record.Description_if_not_within_library__c == '' && record.Select_Device_Type__c == '' && record.Specific_Device_Strategy__c == '' && record.COA_Library_Assessment__c == '' && record.COA_Type__c == '')) {
                    return record;
                }
            })
            upsertCollectionTools({ existingRecordsMap: this.orgCollectionToolRecForECOAOnly, updatedRecords: this.updatedRecordsListForECOAOnly, deletedRecordsIdList: this.deletedRecordsIdListForECOAOnly, bidHistoryId: this.bidHistoryId })
                .then(result => {
                    this.handleIsLoading(false);
                    this.showToast('Success', 'Records successfully saved!', 'Success', 'dismissable');
                    this.updatedRecordsListForECOAOnly = [];
                    this.deletedRecordsIdListForECOAOnly = [];
                    this.navigateToRecord();
                }).catch(error => {
                    this.handleIsLoading(false);
                    this.showToast('Error Saving records', error.body.message, 'Error', 'dismissable');
                }).finally(() => {
                    this.handleIsLoading(false);
                });
        } else {
            this.handleIsLoading(false);
            this.showToast('Error', 'Please complete collection tool for all Scenarios', 'Error', 'dismissable');
        }
    }

    calculateSumOfvalues(event,field,tableNumber){
        if(field == 'Countries__c'){
            this.collectionToolRecForOthers[tableNumber-1].noOfCountries = 0;
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.forEach(element => {
                if(element.Countries__c !='' && element.Countries__c!=undefined){
                    this.collectionToolRecForOthers[tableNumber-1].noOfCountries += 1;
                }
            });
        }
        else if(field == 'Number_of_Sites__c'){
            this.collectionToolRecForOthers[tableNumber-1].sumOfSites = 0;
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.forEach(element => {
                if(element.Number_of_Sites__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfSites += Number(element.Number_of_Sites__c);
                }
            });
        }
        else if(field == 'Number_of_Enrolled_Patients__c'){
            this.collectionToolRecForOthers[tableNumber-1].sumOfEnrolledPatients = 0;
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.forEach(element => {
                if(element.Number_of_Enrolled_Patients__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfEnrolledPatients += Number(element.Number_of_Enrolled_Patients__c);
                }
            });
        }
      
        else if(field == 'Screened_Patients__c'){
            this.collectionToolRecForOthers[tableNumber-1].sumOfScreenedPatients = 0;
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.forEach(element => {
                if(element.Screened_Patients__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfScreenedPatients += Number(element.Screened_Patients__c);
                }
            });
        }
        else{
            this.collectionToolRecForOthers[tableNumber-1].sumOfEnrolledPatients = 0;
            this.collectionToolRecForOthers[tableNumber-1].sumOfScreenedPatients = 0;
            this.collectionToolRecForOthers[tableNumber-1].sumOfSites = 0;
            this.collectionToolRecForOthers[tableNumber-1].noOfCountries = 0;
            this.collectionToolRecForOthers[tableNumber-1].collectionToolRecords.forEach(element => {
                if(element.Countries__c != '' && element.Countries__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].noOfCountries += 1;
                }
                if(element.Number_of_Sites__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfSites += Number(element.Number_of_Sites__c);
                }
                if(element.Number_of_Enrolled_Patients__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfEnrolledPatients += Number(element.Number_of_Enrolled_Patients__c);
                }
                if(element.Screened_Patients__c != undefined){
                    this.collectionToolRecForOthers[tableNumber-1].sumOfScreenedPatients += Number(element.Screened_Patients__c);
                }
            });
        }
    }
    
    navigateToRecord(){
        this.ready = true;
        this.collectionToolRecForOthers=[];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        }); 
    }

    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }

    onDateChange(event){
        var index = event.target.dataset.id;
        var dateName = event.target.dataset.item;
        if(dateName == 'fpi'){
            this.collectionToolRecForOthers[index-1].FPI=event.target.value;
        }
        if(dateName == 'lpi'){
            this.collectionToolRecForOthers[index-1].LPI=event.target.value;
        }
        if(dateName == 'lpo'){
            this.collectionToolRecForOthers[index-1].LPO=event.target.value;
        }
        if(dateName == 'dbl'){
            this.collectionToolRecForOthers[index-1].DBL=event.target.value;
        }
        this.collectionToolRecForOthers[index-1].collectionToolRecords.forEach(element => {
            if(dateName == 'fpi'){
                element.FPI_Date__c=event.target.value;
            }
            if(dateName == 'lpi'){
                element.LPI_Date__c=event.target.value;
            }
            if(dateName == 'lpo'){
                element.LPO_Date__c=event.target.value;
            }
            if(dateName == 'dbl'){
                element.DBL_Date__c=event.target.value;
            }
            const currentUpdatedRecordExisted=this.updatedRecordsListForOthers.find(ele => ele.Id == element.Id);
            if(currentUpdatedRecordExisted){
                Object.assign(currentUpdatedRecordExisted,element);  
            }
            else{
                this.updatedRecordsListForOthers.push(element);
            }
        });
    }     

    cloneRecordsFromPreviousBid(previousBidCollectionToolRecords,type){
        previousBidCollectionToolRecords.forEach(element => {
            element.collectionToolRecords.forEach(record => {
                record.Bid_History__c = this.bidHistoryId;
                record.Bid_History__r = this.bidHistoryRecord;
                record.Type__c = type;
                record.RecordTypeId = this.IQVIATechnologiesRecordTypeId;
                record.Id = record.Id + Date.now();
                if(type == 'Other'){
                    this.updatedRecordsListForOthers.push(record);
                }
                else{
                    this.updatedRecordsListForECOAOnly.push(record);
                }
                });
            });
        if(type == 'Other'){
             this.collectionToolRecForOthers = previousBidCollectionToolRecords;
        }
        else{
             this.collectionToolRecForECOAOnly = previousBidCollectionToolRecords;
        }
    }    
}