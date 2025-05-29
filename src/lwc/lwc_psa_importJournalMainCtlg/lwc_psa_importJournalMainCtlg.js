import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


import saveFile from '@salesforce/apex/CNT_PSA_ImportJournalMainCtlg.saveFile';
import saveXlsFile from '@salesforce/apex/CNT_PSA_ImportJournalMainCtlg.saveXlsFile';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/sheetminjs';

let XLS = {};

export default class Lwc_psa_importJournalMainCtlg extends NavigationMixin(LightningElement) {


    @track data;

    @track fileType = ''

    @track fileName = '';

    @track UploadFile = 'Upload CSV/XLS File';

    @track dropzoneMessage = 'Drop a Journal (CSV) here to create Journal records'

    @track showLoadingSpinner = true;

    @track isTrue = false;

    selectedRecords;

    @track acceptedFormats = ['.csv'];

    filesUploaded = [];

    file;

    @track fileContents;

    fileReader;

    content;

    MAX_FILE_SIZE = 1500000;

    @track errMsg = '';

    dragZoneActive = false;
    eventListenersAdded;
    @track selectedFilesToUpload = []; //store selected files

    @track hasRendered = true;

    dataList = [];
    excelErrMsgArray = [];

    connectedCallback() {

        this.showLoadingSpinner = true;

        loadScript(this, sheetjs).then(() => {
            this.showLoadingSpinner = false;
            this.dropzoneMessage = 'Drop a Journal (CSV / XLS) here to create Journal records';
            this.acceptedFormats = ['.csv', '.xls', '.xlsx'];
        });

    }

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            if (event.target.files[0].type.includes('csv') || event.target.files[0].type.includes('application/vnd.ms-excel') || event.target.files[0].type.includes('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
                this.errMsg = '';
                this.filesUploaded = event.target.files;
                this.fileName = event.target.files[0].name;

                //calling xls handler method
                if (event.target.files[0].type.includes('csv')) {
                    this.fileType = 'csv'
                }
                else if (event.target.files[0].type.includes('application/vnd.ms-excel') || event.target.files[0].type.includes('application/vnd.ms-excel') || event.target.files[0].type.includes('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
                    this.fileType = 'xls'
                    this.excelFileToJson(event);
                }
            } else {
                this.errMsg = 'Please upload a valid csv/xls file.';
            }

        }
    }

    excelFileToJson(event) {
        event.preventDefault();
        let files = event.target.files;

        const analysisExcel = (file) =>
            new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsBinaryString(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
            });

        analysisExcel(files[0])
            .then((result) => {
                let datas = [];
                let XLSX = window.XLSX;
                let workbook = XLSX.read(result, {
                    type: 'binary'
                });

                for (let sheet in workbook.Sheets) {
                    if (workbook.Sheets.hasOwnProperty(sheet)) {
                        datas = datas.concat(XLSX.utils.sheet_to_json(workbook.Sheets[sheet]));
                    }
                }

                this.dataList = datas;
                this.fileContents = this.dataList;
            });

    }

    excelFileToJsonForDropzone(event) {
        event.preventDefault();
        let files = event.dataTransfer.files;

        const analysisExcel = (file) =>
            new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsBinaryString(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
            });

        analysisExcel(files[0])
            .then((result) => {
                let datas = [];
                let XLSX = window.XLSX;
                let workbook = XLSX.read(result, {
                    type: 'binary'
                });

                for (let sheet in workbook.Sheets) {
                    if (workbook.Sheets.hasOwnProperty(sheet)) {
                        datas = datas.concat(XLSX.utils.sheet_to_json(workbook.Sheets[sheet]));
                    }
                }

                this.dataList = datas;
                this.fileContents = this.dataList;
            });

    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.errMsg = '';
            this.uploadHelper();
        }
        else {
            this.fileName =  '';
            this.errMsg = 'Please select a CSV file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File is too large');
            return;
        }
        if (this.fileType == 'csv') {
            this.showLoadingSpinner = true;
            this.fileReader = new FileReader();
            this.fileReader.onloadend = (() => {
                this.fileContents = this.fileReader.result;
                this.saveToFile();
            });
            this.fileReader.readAsText(this.file);

        } else if (this.fileType == 'xls') {
            this.showLoadingSpinner = true;
            if (this.fileContents) {
                this.saveToFile();
            }
        }
    }

    saveToFile() {
        if (this.fileType == 'csv') {
            saveFile({ base64Data: JSON.stringify(this.fileContents) })
                .then(result => {
                    window.console.log('result ====> ');
                    window.console.log(result);
                    this.data = result;
                    this.fileName = this.fileName + ' - Uploaded Successfully';
                    this.isTrue = false;
                    this.showLoadingSpinner = false;
                    this.hasRendered = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!',
                            message: this.file.name + ' - Uploaded Successfully!!!',
                            variant: 'success',

                        }),
                    );
                    this.handleListViewNavigation();
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    let errorMsgArray = error.body;
                    let msg = 'CSV file column not in sequence, Please set the column in sequence and upload the file again';
                    if(errorMsgArray.message == msg){
                        this.errMsg = 'Invalid CSV file';
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Invalid csv',
                                message: msg,
                                variant: 'error',
                           }),
                        );
                        }else{
                            for(let val in errorMsgArray){
                                let errors = JSON.parse(errorMsgArray[val]);
                                for(let err in errors){
                                    this.excelErrMsgArray.push(errors[err]);
                                }
                            }
                        this.exportErrorsToExcel();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File',
                                    message: 'Error occurred while uploading the file',
                                    variant: 'error',
                                }),
                            );
			}
                });
        } else if (this.fileType == 'xls') {
            let tempDataList = [];
            if (this.dataList.length > 0) {
                let tempRecord = this.dataList[0];
                let columnNameList = Object.keys(tempRecord);
                let containsColNames = false;
                if (columnNameList.length == 9){
                containsColNames = columnNameList[0].toUpperCase() === ("Unique ID").toUpperCase()
                        && columnNameList[1].toUpperCase() === ("Country").toUpperCase()
                        && columnNameList[2].toUpperCase() === ("Journal name").toUpperCase()
                        && columnNameList[3].toUpperCase() === ("URL").toUpperCase()
                        && columnNameList[4].toUpperCase() === ("Periodicity").toUpperCase()
                        && columnNameList[5].toUpperCase() === ("Regulatory Requirement").toUpperCase()
                        && columnNameList[6].toUpperCase() === ("Subscription").toUpperCase()
                        && columnNameList[7].toUpperCase() === ("Paper journal").toUpperCase()
                        && columnNameList[8].toUpperCase() === ("Therapeutic area").toUpperCase();
                }
                 if(containsColNames){
                    for (let index = 0; index < this.dataList.length; index++) {
                        let element = this.dataList[index];
                        Object.keys(element).forEach((key) => {
                           var replacedKey = key.trim().toUpperCase().replace(/\s\s+/g, "_");
                           if(key !== replacedKey) {
                               element[replacedKey] = element[key];
                               delete element[key];
                             }
                         });			

                        let tempObj = {
                            Name: element["UNIQUE ID"],
                            Country__c: element["COUNTRY"],
                            Journal_Name__c: element["JOURNAL NAME"],
                            URL__c: element["URL"],
                            Periodicity__c: element["PERIODICITY"],
                            Paper_Journal__c: element["PAPER JOURNAL"],
                            Subscription__c: element["SUBSCRIPTION"],
                            Regulatory_requirement__c: element["REGULATORY REQUIREMENT"],
                            Therapeutic_Area__c: element["THERAPEUTIC AREA"]
                        }
                        tempDataList.push(
                            tempObj
                        )
                    }
                    saveXlsFile({ data: tempDataList })
                        .then(result => {
                            window.console.log('result ====> ');
                            window.console.log(result);
                            this.data = result;
                            this.fileName = this.fileName + ' - Uploaded Successfully';
                            this.isTrue = false;
                            this.showLoadingSpinner = false;
                            this.hasRendered = true;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success!!',
                                    message: this.file.name + ' - Uploaded Successfully!!!',
                                    variant: 'success',
                                }),
                            );
                            this.handleListViewNavigation();
                        })
                        .catch(error => {
                            this.showLoadingSpinner = false;
                            let errorMsgArray = error.body;
                            for(let val in errorMsgArray){
                                let errors = JSON.parse(errorMsgArray[val]);
                                for(let err in errors){
                                    this.excelErrMsgArray.push(errors[err]);
                                }
                            }
                            this.exportErrorsToExcel();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error while uploading File',
                                    message: 'Error occurred while uploading the file',
                                    variant: 'error',
                                }),
                            );
                        });
                } else {
                    //all columns are not there in XLS file
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while uploading File',
                            message: 'XLS file column not in sequence, Please set the column in sequence and upload the file again  and All column must have all the required values',
                            variant: 'error',
                        }),
                    );
                    this.errMsg = 'Invalid XLS file.';
                    this.showLoadingSpinner = false;
                }
            }

        }

    }

    get dropZoneContextClass() {
        return this.dragZoneActive ? 'active' : 'inactive';
    }

    registerEvents = () => {
        const dropArea = this.template.querySelector('[data-id="droparea"]');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, this.preventDefaults)
        });

        ['dragenter', 'dragover'].forEach(eventName => {
            dropArea.addEventListener(eventName, this.highlight);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, this.unhighlight);
        });

        dropArea.addEventListener('drop', this.handleDrop);

    };

    highlight = (e) => {
        this.dragZoneActive = true;
    };

    unhighlight = (e) => {
        this.dragZoneActive = false;
    };

    handleDrop = (e) => {
        let dt = e.dataTransfer;
        if (dt.files.length > 0) {
            if (dt.files[0].type.includes('csv') || dt.files[0].type.includes('application/vnd.ms-excel') || dt.files[0].type.includes('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
                this.errMsg = '';
                this.filesUploaded = dt.files;
                this.fileName = dt.files[0].name;

                if (dt.files[0].type.includes('csv')) {
                    this.fileType = 'csv'
                }
                //calling xls handler method
                else if (dt.files[0].type.includes('application/vnd.ms-excel') || dt.files[0].type.includes('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
                    this.fileType = 'xls'
                    this.excelFileToJsonForDropzone(e);
                }
            } else {
                this.errMsg = 'Please upload a valid csv/xls file.';
            }
        }
    };

    preventDefaults = (e) => {
        e.preventDefault();
        e.stopPropagation();
    };

    renderedCallback() {
        if (this.hasRendered) {
            this.filesUploaded = [];
            this.fileName = '';
            this.hasRendered = false;
        }

        if (this.eventListenersAdded) {
            return;
        }

        this.eventListenersAdded = true;
        this.registerEvents();

        this.showLoadingSpinner = false;
    };

    handleListViewNavigation() {
        // Navigate to the Accounts object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Journals_Main_Catalogue__c',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                // or by 18 char '00BT0000002TONQMA4'
                filterName: 'Recent'
            }
        });
    }

    clearFileVal(event) {
        event.target.value = '';
    }
	
    exportErrorsToExcel () {
	// Prepare an html table
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
        doc += '<th> UNIQUE ID </th>' 
        doc += '<th> COUNTRY </th>' 
        doc += '<th> JOURNAL NAME </th>' 
        doc += '<th> URL </th>' 
        doc += '<th> PERIODICITY </th>'  
        doc += '<th> PAPER JOURNAL </th>'
        doc += '<th> SUBSCRIPTION </th>'
        doc += '<th> REGULATORY REQUIREMENT </th>'
        doc += '<th> THERAPEUTIC AREA </th>'
        doc += '<th> Error </th>'		
        doc += '</tr>';
        // Add the data rows
        for( let errorMsg in this.excelErrMsgArray ){ 
            doc += '<tr>';
            doc += '<td>'+this.excelErrMsgArray[errorMsg].name+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].country+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].journalName+'</td>';
            doc += '<td>'+this.excelErrMsgArray[errorMsg].url+'</td>';
            doc += '<td>'+this.excelErrMsgArray[errorMsg].periodicity+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].paperJournal+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].subscription+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].regulatoryRequirement+'</td>'; 
            doc += '<td>'+this.excelErrMsgArray[errorMsg].therapeuticArea+'</td>';
            doc += '<td>'+this.excelErrMsgArray[errorMsg].error+'</td>';			
            doc += '</tr>';
        }
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + escape(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Error file - JMC.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        this.excelErrMsgArray = [];
    }
    exportTo_XLS(){
        this.showLoadingSpinner = true;
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '    width: 11%;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers 
        doc += '<tr>';
        doc += '<th>Unique ID</th>' 
        doc += '<th>Country </th>' 
        doc += '<th>Journal Name </th>' 
        doc += '<th>URL</th>' 
        doc += '<th>Periodicity</th>'  
        doc += '<th>Regulatory Requirement</th>'
        doc += '<th>Subscription</th>'
        doc += '<th>Paper Journal</th>'
        doc += '<th>Therapeutic Area</th>'		
        doc += '</tr>';

        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download =  'Import Journals Main Catalogue XLS format'+'.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        setTimeout(() => {
            this.showLoadingSpinner = false;
        }, 3000);
    }
    exportTo_CSV() {   
        this.showLoadingSpinner = true;
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        rowData =["Unique ID","Country","Journal Name","URL","Periodicity","Regulatory Requirement","Subscription","Paper Journal","Therapeutic Area"];
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        
         // main for loop to get the data based on key value
        
 
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Import Journals Main Catalogue CSV format'+".csv";
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
        setTimeout(() => {
            this.showLoadingSpinner = false;
        }, 3000);
    }

    disconnectedCallback(){
        this.showLoadingSpinner = false;
        this.errMsg = '';
        this.fileContents = [];
        this.dataList = [];
        this.fileName = '';
    }
}
