import { LightningElement, wire, track } from 'lwc';

import getComplianceHoldData from "@salesforce/apex/CNT_TPA_AccountOnHoldReport.getComplianceHoldData";
import baseURL from "@salesforce/apex/CNT_TPA_AccountOnHoldReport.baseURL";
import { recordsWrapper,  COLUMNS } from './UTIL.js';
import { SEPARATOR, csvWrapper, csvExport, showNotification, dateDuration, dateFormatter } from 'c/lWC_TPA_ReportUTILS';


export default class AccountOnHoldReport extends LightningElement {
    @track complianceRecords = [];
    dataList = [];
    @track columns = COLUMNS;
    @track sortedDirection = 'ASC';
    
    @wire(baseURL) complianceURL;

    @wire(getComplianceHoldData, {sortBy : '$sortedDirection'})
    accountsOnHold({ error, data }){
        this.dataList = []
        if (data) {
            data.map((record) => { 
                if(record?.Vendor_TPA_Compliance_Hold__c || record?.Tasks?.length > 0){
                    let TaskRecord = {}
                    TaskRecord.Id = record.Id;
                    TaskRecord.accountName = record.Account__r?.Name;
                    TaskRecord.accountComplianceName = record.Name;
                    TaskRecord.accountComplianceURL = this.complianceURL?.data + '/lightning/r/Account_Compliance__c/' + record.Id + '/view';
                    TaskRecord.status = record.Vendor_TPA_Compliance_Hold__c; 
                    if(TaskRecord.status){
                        TaskRecord.onHoldDate = dateFormatter(record.Vendor_TPA_Compliance_Hold_Date__c); 
                        TaskRecord.reason = record.Vendor_TPA_Compliance_Hold_Reason__c;
                        TaskRecord.duration = dateDuration(record.Vendor_TPA_Compliance_Hold_Date__c, null) + ' Day(s)';
                    }
                    if(record?.Tasks?.length > 0 ){
                        TaskRecord._children = []
                        record.Tasks.forEach((task)=>{
                            var childRecord = {}
                            childRecord.accountName = record.Account__r?.Name;
                            childRecord.accountComplianceName = record.Name;
                            childRecord.accountComplianceURL = this.complianceURL?.data + '/lightning/r/Account_Compliance__c/' + record.Id + '/view';
                            TaskRecord._children.push(recordsWrapper(childRecord,task))
                        })
                    }
                    this.dataList.push(TaskRecord)
                }
            })
            this.complianceRecords = this.dataList;
        }
        else if(error){
            showNotification('Error', 'Exception while Reading the Data', 'error'); 
            console.error('Error while importing the Data ',error);
        }
    }
    
    exportReport(){
        try{
            let fileName = 'Account on Hold Report';
            let csvData = 'Account Name' + SEPARATOR + 'Vendor Account Compliance Name' + SEPARATOR + 'Vendor Account Hold Flag' + SEPARATOR + 'Vendor Account on Hold Reason' + SEPARATOR + 'Vendor Account Hold date' + SEPARATOR + 'Vendor Account Release date' + SEPARATOR + 'Hold Duration' + SEPARATOR + '\r\n';
            
            for(let i = 0; i < this.dataList.length ; i++){
                let data = this.dataList[i];
                csvData += csvWrapper(data.accountName) + SEPARATOR + csvWrapper(data.accountComplianceName) + SEPARATOR + csvWrapper(data.status) + SEPARATOR + csvWrapper(data.reason) + SEPARATOR + csvWrapper(data.onHoldDate) +  SEPARATOR  + csvWrapper('') + SEPARATOR + csvWrapper(data.duration) + SEPARATOR + '\r\n';

                if(data?._children?.length > 0){
                    for(let j = 0;j < this.dataList[i]._children?.length ; j++){
                        let taskData = this.dataList[i]._children[j] 
                        csvData += csvWrapper(taskData.accountName) + SEPARATOR + csvWrapper(taskData.accountComplianceName) + SEPARATOR + csvWrapper('') + SEPARATOR + csvWrapper(taskData.reason) + SEPARATOR + csvWrapper(taskData.onHoldDate) + SEPARATOR + csvWrapper(taskData.onReleaseDate) + SEPARATOR + csvWrapper(taskData.duration) + SEPARATOR + csvWrapper('') + SEPARATOR + '\r\n';
                    }
                }
            }
            csvExport(csvData, fileName)
            showNotification('Success!', 'The Report is Exported Successfully.', 'success');
        }catch(exception){
            console.error('Exception while Exporting the Data', exception);
            showNotification('Error!', 'Exception while Exporting the Data.', 'error');
        }
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        let columns = this.columns;
        if (actionName !== this.sortedDirection) {
            var actions = columns[ 0 ].actions;
            actions.forEach((action) => {
                action.checked = action.name === actionName;
            });
            columns[ 0 ].actions = actions;
            this.sortedDirection = actionName;
            this.columns = JSON.parse(JSON.stringify(columns)); 
        }
    }

    renderedCallback(){
        const grid =  this.template.querySelector('lightning-tree-grid');
        grid?.expandAll();
    }
}