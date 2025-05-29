import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';
import downloadjs from "@salesforce/resourceUrl/downloadjs";
import { loadScript } from "lightning/platformResourceLoader";
import getData from '@salesforce/apex/CNT_PSA_LanguageCapability.getResourceInfo';
import downloadPDF from '@salesforce/apex/CNT_PSA_LanguageCapability.getPDFprint';
const COLUMNS = [
    { label: 'Resource Name', fieldName: 'resourceName', type: 'text'},
    { label: 'Program Name', fieldName: 'programName', type: 'text'},
    { label: 'Client Name(Account Name)', fieldName: 'clientName', type: 'text' },
    { label: 'Service Line Name', fieldName: 'serviceLineName', type: 'text' },
    { label: 'Project Code Name', fieldName: 'projectCodeName', type: 'text' },
    { label: 'Assignment Name', fieldName: 'assignmentName', type: 'text' },
    { label: 'Service Line Lead Name', fieldName: 'serviceLineLead', type: 'text' },
    { label: 'Region', fieldName: 'region', type: 'text' },
    { label: 'Account Country', fieldName: 'accountCountry', type: 'text' },
    { label: 'Language', fieldName: 'language', type: 'text' },
    { label: 'Skill', fieldName: 'skill', type: 'text' },
    { label: 'Utilized?(Yes/No)', fieldName: 'utilized', type: 'boolean' },
    { label: 'Scheduled Hours?', fieldName: 'scheduleHours', type: 'text' }
];

const GLOBAL_COLUMNS = [
    { label: 'Resource Name', fieldName: 'resourceName', type: 'text'},
    { label: 'Client Name(Account Name)', fieldName: 'clientName', type: 'text' },
    { label: 'Service Line Name', fieldName: 'serviceLineName', type: 'text' },
    { label: 'Project Code', fieldName: 'projectCodeName', type: 'text' },
    { label: 'Assignment Name', fieldName: 'assignmentName', type: 'text' },
    { label: 'Account Country', fieldName: 'accountCountry', type: 'text' },
    { label: 'Language', fieldName: 'language', type: 'text' },
    { label: 'Skill', fieldName: 'skill', type: 'text' },
    { label: 'Utilized?(Yes/No)', fieldName: 'utilized', type: 'boolean' }
];
export default class Lwc_psa_languagecapability extends NavigationMixin(LightningElement) {
    recordId;
    columns = COLUMNS;
    filteredRecord = [];
    isLoaded = true;  
    _random_digit = 0;
    @track headerName='';
    @track clientName ='';
    @track projectCode ='';
    @track viewFilters = true;
    @track hasLoadedData = true;
    @track isActive = true;
    @track isSeriveProject = true;
    connectedCallback(){
        this._random_digit = Math.floor(Math.random());
    }    

    renderedCallback() {
        loadScript(this, downloadjs).then(() => '').catch(error => console.log(error));
        if(!this.recordId){
            this.isSeriveProject = false;
            this.headerName='Language Capability - Oversight Report';
            this.columns = GLOBAL_COLUMNS;
        }else{
            this.isSeriveProject = true;
            this.headerName='Language Capability - Medical Information';
            this.columns = COLUMNS;
        }
      }   

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          this.recordId = currentPageReference.state.c__serviceline || null;
       }
    }

    @wire(getData, {medicalProjectId: '$recordId',refresh : '$_random_digit',clientName : '$clientName', projectCode : '$projectCode', isActive : '$isActive' })
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                tempData.forEach(function (record) {
                    record['programName'] = record.programName;
                    record['serviceLineLead'] = record.serviceLineLead;
                    record['region'] = record.region;
                    record['scheduleHours'] = record.scheduleHours;
                    record['resourceName'] = record.resourceName;
                    record['clientName'] = record.clientName;
                    record['serviceLineName'] = record.serviceLineName;
                    record['projectCodeName'] = record.projectCodeName;
                    record['assignmentName'] = record.assignmentName;
                    record['accountCountry'] = record.accountCountry;
                    record['language'] = record.language;
                    record['skill'] = record.skill;
                    record['utilized'] = record.utilized;
                });
                this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                if(this.filteredRecord.length > 0){
                    this.hasLoadedData = true;
                }else{
                    this.hasLoadedData = false;
                }
            }else{
                this.hasLoadedData = false;
            }

        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
            this.hasLoadedData = false;
        }
        this.isLoaded = false;
    }

    backToProject(){
        this[ NavigationMixin.Navigate ]({
            type : 'standard__recordPage',
            attributes : {
                recordId : this.recordId,
                objectApiName : 'pse__Proj__c',
                actionName : 'view'
            }
        });
    }

    exportTo_XLS(){
        this.isLoaded = true;
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';

        // Add all the Table Headers 
        doc += '<tr>';
        doc += '<th> Resource Name </th>' 
        if(this.recordId){
            doc += '<th> Program Name </th>' 
        }
        doc += '<th> Client Name(Account Name) </th>' 
        doc += '<th> Service Line Name </th>' 
        if(this.recordId){
            doc += '<th> Project Code </th>' 
        }
        doc += '<th> Assignment Name </th>' 
        if(this.recordId){
            doc += '<th> Service Line Lead Name </th>' 
            doc += '<th> Region </th>' 
        }
        
        doc += '<th> Account Country </th>' 
        doc += '<th> Language </th>' 
        doc += '<th> Skill </th>' 
        doc += '<th> Utilized?(Yes/No) </th>'
        if(this.recordId){
            doc += '<th> Scheduled Hours? </th>'
        }
        doc += '</tr>';

        // Add the data rows
        for( let element in this.filteredRecord ){ 
            doc += '<tr>';
            doc += '<td>'+this.filteredRecord[element].resourceName+'</td>'; 
            if(this.recordId){
                doc += '<td>'+this.filteredRecord[element].programName+'</td>'; 
            }
            doc += '<td>'+this.filteredRecord[element].clientName+'</td>';
            doc += '<td>'+this.filteredRecord[element].serviceLineName+'</td>';
            doc += '<td>'+this.filteredRecord[element].projectCodeName+'</td>'; 
            doc += '<td>'+this.filteredRecord[element].assignmentName+'</td>'; 
            if(this.recordId){
                doc += '<td>'+this.filteredRecord[element].serviceLineLead+'</td>'; 
                doc += '<td>'+this.filteredRecord[element].region+'</td>'; 
            }
            doc += '<td>'+this.filteredRecord[element].accountCountry+'</td>'; 
            doc += '<td>'+this.filteredRecord[element].language+'</td>'; 
            doc += '<td>'+this.filteredRecord[element].skill+'</td>'; 
            doc += '<td>'+this.filteredRecord[element].utilized+'</td>'; 
            if(this.recordId){
                doc += '<td>'+this.filteredRecord[element].scheduleHours+'</td>'; 
            }
            doc += '</tr>';
        }
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'Medical information - Language capability.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        setTimeout(() => {
            this.isLoaded = false;
        }, 3000);
    }

    // this method to creates the PDF file to download
    exportTo_PDF(){
        this.isLoaded = true;
        downloadPDF({medicalProjectId: this.recordId, clientName : this.clientName, projectCode : this.projectCode, isActive : this.isActive}).then(response => {
            var strFile = "data:application/pdf;base64,"+response[0];
            window.download(strFile, "Medical information - Language capability.pdf", "application/pdf");
        }).catch(error => console.log(error));
        setTimeout(() => {
            this.isLoaded = false;
        }, 3000);
        
    }

    // this method to creates the CSV file to download
    exportTo_CSV() {   
        this.isLoaded = true;
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
 
        // getting keys from data
        this.filteredRecord.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        if(this.recordId){
            rowData =["Resource Name","Program Name","Client Name(Account Name)","Service Line Name","Project Code Name","Assignment Name","Service Line Lead Name","Region","Account Country","Language","Skill","Utilized?(Yes/No)","Scheduled Hours?"];
        }else{
            rowData =["Resource Name","Client Name(Account Name)","Service Line Name","Project Code","Assignment Name","Account Country","Language","Skill","Utilized?(Yes/No)"];
        }
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        if(this.recordId){
            rowData = ["resourceName","programName","clientName","serviceLineName","projectCodeName","assignmentName","serviceLineLead","region","accountCountry","language","skill","utilized","scheduleHours"];
        }else{
            rowData = ["resourceName",,"clientName","serviceLineName","projectCodeName","assignmentName","accountCountry","language","skill","utilized"];
        }
         // main for loop to get the data based on key value
        for(let i=0; i < this.filteredRecord.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    let value = this.filteredRecord[i][rowKey] === undefined ? '' : this.filteredRecord[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
 
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Medical information - Language capability.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
        setTimeout(() => {
            this.isLoaded = false;
        }, 3000);
    }
    handlechange(event){
        let targetName = event.target.name;
        if(targetName == 'clientName'){
            this.clientName = event.detail.value;
            this.filteredRecord =[];
        }else if(targetName == 'projectCode'){
            this.projectCode = event.detail.value;
            this.filteredRecord =[];
        }else if(targetName == 'isActive'){
            this.isActive = !this.isActive
            this.filteredRecord =[];
        }

    }
    // filter
  toggleFilter () {
    this.viewFilters = !this.viewFilters
  }
}
