import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
import updateATCOTCData from '@salesforce/apex/CNT_CPQ_ATCAdminWizard.updateATCOTCData';
import checkBatchJobStatus from '@salesforce/apex/CNT_CPQ_ATCAdminWizard.checkBatchJobStatus';
import { NavigationMixin } from 'lightning/navigation';
import getReportRecordId from '@salesforce/apex/CNT_CPQ_ATCAdminWizard.getReportRecordId';
let XLS = {};
export default class LWC_CPQ_ATC_ADMIN_WIZARD extends NavigationMixin(LightningElement) {
    @track excelJSONString;
    fileName;
    showBatchInProgress = false;
    showBatchSuccess = false;
    showBatchFail = false;
    @track loaded = false;
    value = null;
    interval;
    optionData = [];
    threadValue = '5670';
    batchStatus;
    objExcelToJSON;
    isLastThread = false;
    isEmptyExcel = false;
    get options() {
      return this.optionData;
    }

    handleChange(event) {
      this.value = event.detail.value;
    }

    setQuarterPicklistValues() {
      var dateVar = new Date();
      var currentDate = dateVar.getFullYear() - 1;
      let i = 0;  
      for(let j = 0; j<12; j++){
        if (i % 4 == 0 && i != 0) {
          currentDate = currentDate + 1;
          i = 0;
        }
        i++;
        this.optionData.push({label : currentDate + ' Q' + i, value : currentDate + ' Q' + i});
      }
    }

    connectedCallback() {
        this.setQuarterPicklistValues();
        Promise.all([loadScript(this, excelFileReader)])
        .then(() => {
            XLS = XLSX;
        })
        .catch((error) => {
            console.log("An error occurred while processing the file");
        });
    }
	
    openFileUpload(event) {
        this.loaded = !this.loaded;
        Promise.resolve().then(() => {
            const inputFile = this.template.querySelector('.uploadFile');
            inputFile.reportValidity();
        });
        const file = event.target.files[0]
        this.fileName = file.name;
        let objFileReader = new FileReader();
        objFileReader.onload = (event) => {
            let objFiledata = event.target.result;
            let objFileWorkbook = XLS.read(objFiledata, {
                type: "binary"
            });
            let sheetdata = JSON.parse(JSON.stringify(objFileWorkbook.Sheets));
            var sheetName;
            for (const [key, value] of Object.entries(sheetdata)) {
                sheetName = key;
                break;
            }
            this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                objFileWorkbook.Sheets[sheetName]
            );
            //Verify if the file content is not blank
            if (this.objExcelToJSON.length === 0) {
                this.isEmptyExcel = true;
                this.showToast("Error", "error", "Kindly upload the file with data");
            }
            if (this.objExcelToJSON.length > 0) {
                //Remove the whitespaces from the javascript object
                this.isEmptyExcel = false;
                Object.keys(this.objExcelToJSON).forEach((key) => {
                    const replacedKey = key.trim().toUpperCase().replace(/\s\s+/g, "_");
                    if (key !== replacedKey) {
                        this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
                        delete this.objExcelToJSON[key];
                    }
                });
            }
        };
    
        objFileReader.onerror = function (error) {
            this.showToast("Error", "error", "Error while reading the file");
        };
        objFileReader.readAsBinaryString(file);
        this.interval = setInterval(() => {
            this.checkFileData();
        }, 1000);
    }
    checkFileData(){
        if(this.objExcelToJSON){
            this.loaded = !this.loaded;
            clearInterval(this.interval);
        }
    }
    
    updateDataInSingleThread(){
        var batchJobId;
        if(this.excelJSONString != null){
            updateATCOTCData({excelJSONData: this.excelJSONString, quarter: this.value})
            .then(result => {
                batchJobId = result;
                this.loaded = false;
                if(batchJobId != 'Error'){
                    var checkJobStatus = setInterval(()=>{
                        checkBatchJobStatus({jobId: batchJobId})
                        .then(result => {
                            this.batchStatus = result;
                            if(this.batchStatus == 'Completed' && this.isLastThread == true){
                                this.showBatchInProgress = false;
                                this.showBatchSuccess = true;
                                this.showToast("Success", "success", "Market share % updated successfully");
                                this.template.querySelector("lightning-combobox").value = null;
                                this.value = null;
                                clearInterval(checkJobStatus);
                                this.isLastThread = false;
                            }
                            if(this.batchStatus == 'Failed'){
                                this.showBatchInProgress = false;
                                this.showBatchFail = true;
                                this.showToast("Error", "error", "Market share % update failed");
                                clearInterval(checkJobStatus);
                            }
                        })
                        .catch(error => {
                            var errMessage = error;
                            this.showToast("Error", "error", errMessage);
                            this.error = error;
                        });
                    }, 5000);
                }
                else{
                    this.showBatchInProgress = false;
                    this.showBatchFail = true;
                    this.showToast("Error", "error", "Please upload the file with correct headers and format!!!");
                }
            })
            .catch(error => {
                var errMessage = error;
                this.showToast("Error", "error", errMessage);
                this.error = error;
            });
        }
    }
	save() {
        this.loaded = !this.loaded;
        var i = 0;
        if(!this.isEmptyExcel && this.objExcelToJSON && this.fileName != null && this.value != null){
            var excelDataInThreads = this.sliceIntoThreads(this.objExcelToJSON, this.threadValue);
            excelDataInThreads.forEach(thread => {
                i++;
                if(i == excelDataInThreads.length){
                    this.isLastThread = true;
                }
                this.showBatchInProgress = !(this.showBatchSuccess || this.showBatchFail);
                this.loaded = !(this.showBatchSuccess || this.showBatchFail);
                this.waitForQueueItemToUpdate(thread);
            });
        } else if (this.value == null) {
            this.showToast("Error", "error", "Please select the Quarter");
            this.loaded = false;
        } else {
            this.showToast("Error", "error", "Please upload a file first!!!");
            this.loaded = false;
        }
    }
    sliceIntoThreads(arr, threadSize) {
        threadSize = parseInt(threadSize, parseInt(10,8));
        const res = [];
        for (let i = 0; i < arr.length; i += threadSize) {
            const chunk = arr.slice(i, i + threadSize);
            res.push(chunk);
        }
        return res;
    }
    waitForQueueItemToUpdate(data){
        this.excelJSONString = JSON.stringify(data);
        this.updateDataInSingleThread();
        let interval = setInterval(() => {
            if(this.batchStatus == 'Completed'){
                clearInterval(interval);
            }
        }, 1000);
    }
    cancel(){
        this.fileName = null
        this.showBatchInProgress = false;
        this.showBatchSuccess = false;
        this.showBatchFail = false;
        this.template.querySelector("lightning-combobox").value = null;
        this.value = null;
    }
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
        });
        this.dispatchEvent(event);
    }
    async navigateToReport(event) {
        this.reportId = await getReportRecordId({ reportName: "ATC_OTC_Classifications_Report_xTR" })
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.reportId,
            objectApiName: 'Report',
            actionName: 'view'
          }
        });
    }
}
