import { LightningElement, wire, track  } from 'lwc';
import getjournals from '@salesforce/apex/CNT_PSA_JournalCalendar.getjournals';
import Id from '@salesforce/user/Id';
import haveEditablePermission from '@salesforce/apex/CNT_PSA_JournalCalendar.haveEditablePermission';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateReviewDate from '@salesforce/apex/CNT_PSA_JournalCalendar.updateReviewDate';
import getjournalsForExport from '@salesforce/apex/CNT_PSA_JournalCalendar.getjournalsForExport';
import getRecord from '@salesforce/apex/CNT_PSA_JournalCalendar.getRecord';
import { CurrentPageReference } from 'lightning/navigation';
export default class Lwc_PSA_EventJournalCalendar extends NavigationMixin(LightningElement) {
    @track recordId;
    @track isbackToProject = false;
    @track response;
    @track error;
    reviewDate = [];
    picklistValues = [];
    @track journaldata = [];
    @track total = [];
    popUpHeading = '';
    journals = [];
    journalRealtionIds = [];
    @track journalsInPopUp = [];
    @track copyJournalsInPopUp = [];
    @track isModalOpen = false;
    @track isModalOpenError = false;
    @track conditionDate = [];
    @track journalProjects= [];
    @track journaldateMap = [];
    @track isEditable = false;
    @track buttonLabel = 'Ok';
    selectedjournals = [];
    @track selectedjournalsForSubmit = [];
    @track toDayDate;
    @track conditionalDates = [];
    @track isFilterModel = false;
    startfilterValue = '';
    @track startfilterValueError = false;
    @track isbuttonShow = false;
    @track isDateFilter = false;
    @track changeDateForAll='';
    @track isChanged = false;
    @track showReviewDate;
    @track isExportJournals=false;
    @track dataChangeDate=[];
    @track ExportToJournals = [];
    isAllFilter = false;
    isCompleteExportFilter = false;
    _selected = [];
    exportToStartDate = '';
    exportToEndDate = '';
    isLoaded = true;
    isShowFrequency = false;
    visible = true;
    isLoadedExport = false;
    days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    constructor() {
        super();
        haveEditablePermission({ userId: Id }).then((result) => {
             this.isEditable = result;
        });
    }
    connectedCallback() {
        var today = new Date();
        this.toDayDate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        this.load( this.toDayDate, 'PRESENT', this.journalRealtionIds );
    }
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          this.recordId = currentPageReference.state.c__serviceline || null;
          if(this.recordId && this.toDayDate){
            this.load( this.toDayDate, 'PRESENT', this.journalRealtionIds );
            this.isbackToProject = true;
          }else{
            this.isbackToProject = false;
          }
       }
    }
    onClickButton(event){
        this.isLoaded = true;
        this.journalsInPopUp = [];
        this.isbuttonShow = false;
        let reviewDate = this.reviewDate[event.target.value];
        let conditionDate = this.conditionDate[event.target.value];
        let frequencyName = event.target.name;
        this.popUpHeading= 'Event Journal Calendar '+ reviewDate;
        this.showReviewDate = conditionDate;
        for( let journal in this.journals ){
            const  journalAllReviewDates = this.journals[journal].Review_Dates__c;
            if( journalAllReviewDates.includes( conditionDate ) && this.journals[journal].Frequency_of_Journal__c == frequencyName ){
                this.journalsInPopUp.push( this.journals[journal] ); 
            }
        }
        this.isModalOpen = true;
        if( this.journalsInPopUp.length == 0 ){
            
            this.isModalOpenError = true;
            this.isLoaded = false;
        }else{

            this.isModalOpenError = false;
            this.isLoaded = false;
        }    
    }
    onClickTotalButton(event){
        this.isLoaded = true;
        this.journalsInPopUp = [];
        this.isbuttonShow = false;
        let reviewDate = this.reviewDate[event.target.value];
        let conditionDate = this.conditionDate[event.target.value];
        this.popUpHeading= 'Event Journal Calendar '+ reviewDate;
        this.showReviewDate = conditionDate;
        for( let journal in this.journals ){
            const  journalAllReviewDates = this.journals[journal].Review_Dates__c;
            if( journalAllReviewDates.includes( conditionDate )  ){
                this.journalsInPopUp.push( this.journals[journal] ); 
            }
        }
        this.isModalOpen = true;
        if( this.journalsInPopUp.length == 0 ){
            this.isModalOpenError = true;
        }else{
            this.isModalOpenError = false;
        }
        this.copyJournalsInPopUp = [...this.journalsInPopUp];
        this.isLoaded = false;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.isAllFilter = false;
        if( this.isChanged ){
            this.load( this.conditionalDates[0], 'PRESENT', this.journalRealtionIds );
        }
    }
    closeFilterModal(){
        this.isFilterModel = false;
    }
    openFilter(){
        this.isFilterModel = true;
    }
    openDateFilter(){
        this.isDateFilter = true;
    }
    filterOk(){
        if( this.startfilterValue ){
            this.load( this.startfilterValue, 'PRESENT', this.journalRealtionIds );
        }else{
            this.startfilterValueError = true;
        }
        
    }
    getFilterStartDate(event){
        this.startfilterValue = event.target.value;
    }
    submitDetails() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        this.isLoaded = true;
        if( this.selectedjournalsForSubmit && allValid){
            updateReviewDate({ lstToUpdate: this.selectedjournalsForSubmit }).then((result) => {
                if(result == 'success'){
                    this.showMessege( 'Successfully Review Date Update','Success','success' );
                    this.load( this.conditionalDates[0], 'PRESENT', this.journalRealtionIds );
                    this.isLoaded = true;
                }else{
                    if(JSON.stringify(result)){
                        this.showMessege( JSON.stringify(result),'Error','error' );
                        this.isLoaded = false;
                    }
                }
           });
            
        }else{
            this.isLoaded = false;
        }
    }
    onChangeDate(event){
        this.isbuttonShow = true;
        let journalId = event.target.name;
        let changeDate = event.target.value;
        let showDateCopy ='';
        let eJId = [];
        eJId.push( journalId );
        let dt = new Date(changeDate);
        let dayOfWeek = this.days[dt.getDay()];
        let weekDayErrorFlag = false;
        if(dayOfWeek==='Friday'|| dayOfWeek==='Saturday' || dayOfWeek==='Sunday'){
            weekDayErrorFlag = true;
        }else{
            this.isLoaded = true;
            this.buttonLabel = 'Submit';
            if(this.valid_date_past( changeDate, this.toDayDate ) === false){
                getRecord({ recordIds : eJId }).then((data) => {
                    if( data ){
                        for( let journal in data ){
                            if( data[journal].Id === journalId ){
                                const updateReviewDates = new Set();
                                if( data[journal].Review_Dates__c ){
                                    let journalAllReviewDates = data[journal].Review_Dates__c.split(',');
                                    showDateCopy = this.showReviewDate;
                                    for( let i in journalAllReviewDates){
                                        if( journalAllReviewDates[i] === showDateCopy ){
                                            if(!updateReviewDates.has( changeDate )){
                                                updateReviewDates.add( changeDate );
                                            }
                                        }else{
                                            if( !updateReviewDates.has( journalAllReviewDates[i]  ) )
                                            updateReviewDates.add( journalAllReviewDates[i] );
                                        }
                                    }
                                    data[journal].Review_Dates__c = '';
                                    data[journal].Review_Dates__c = Array.from( updateReviewDates ).join(',');
                                    var selectjournalIndex = this.findIndexByProperty( this.selectedjournalsForSubmit ,journalId );
                                    if (selectjournalIndex > -1) {
                                        this.selectedjournalsForSubmit[selectjournalIndex].Review_Dates__c ='';
                                        this.selectedjournalsForSubmit[selectjournalIndex].Review_Dates__c = data[journal].Review_Dates__c ;
                                    } else {
                                    this.selectedjournalsForSubmit.push({Id:data[journal].Id,Review_Dates__c: data[journal].Review_Dates__c});  
                                    }
                                }
                            }
                        }
                    }
                });
            }
        }
        this.isLoaded = false;
        this.template.querySelectorAll('lightning-input').forEach(ele => {
            if(ele.name == journalId){
                if(this.valid_date_past(changeDate, this.toDayDate)){
                    ele.setCustomValidity('Event Journal review date cannot be in the past');
                }else if(weekDayErrorFlag){
                    ele.setCustomValidity('Event Journal Review due date cannot be of Friday, Saturday or Sunday. Please select a date from Monday to Thursday.');
                }else{
                    ele.setCustomValidity('');
                }
            }
            ele.reportValidity();
        });
        
    }
    
    findIndexByProperty(data, value) {
        for (var i = 0; i < data.length; i++) {
            if (data[i].Id == value) {
                return i;
            }
        }
        return -1;
    }
    findValueByProperty(data, value) {
        for (var i = 0; i < data.length; i++) {
            if ( data[i].Id == value ) {
                return data[i].changeDateInfo;
            }
        }
        return '';
    }
    
    redirect(event){
        var journalId = event.target.value;
        this[ NavigationMixin.Navigate ]({
            type : 'standard__recordPage',
            attributes : {
                recordId : journalId,
                objectApiName : 'Event_Journals__c',
                actionName : 'view'
            }
        });
    }
    previous(){
        this.load( this.conditionalDates[0], 'PAST', this.journalRealtionIds );
    }
    next(){
       this.load( this.conditionalDates[this.conditionalDates.length-1], 'FUTURE', this.journalRealtionIds );
    }
    load( loadDate, loadStatus, journalList ){
        this.response = '';
        this.error;
        this.reviewDate = [];
        this.picklistValues = [];
        this.journaldata = [];
        this.total = [];
        this.popUpHeading = '';
        this.journals = [];
        this.journalsInPopUp = [];
        this.isModalOpen = false;
        this.isModalOpenError = false;
        this.conditionDate = [];
        this.journalProjects= [];
        this.journaldateMap = [];
        this.buttonLabel = 'Ok';
        this.selectedjournals = [];
        this.selectedjournalsForSubmit = [];
        this.isModalOpenError = false;
        this.toDayDate;
        this.changeDateForAll='';
        this.isFilterModel = false;
        this.isDateFilter = false;
        this.startfilterValue = '';
        this.startfilterValueError = false;
        this.isbuttonShow = false;
        this.isChanged = false;
        this.showReviewDate = '';
        this.isExportJournals = false;
        this.dataChangeDate= [];
        this.isAllFilter = false;
        this.ExportToJournals =[];
        this.isCompleteExportFilter = false;
        this._selected = [];
        this.exportToStartDate = '';
        this.exportToEndDate = '';
        this.isShowFrequency = false;
        this.visible = true;
        this.isLoaded = true;
        this.isLoadedExport = false;
        getjournals({ nextDate : loadDate , status : loadStatus, ejIdList : journalList, serviceLineProjectId : this.recordId }).then((data) => {
            this.response = data;
            
            if( data.showDates ){
                this.reviewDate = data.showDates;
            }
            if( data.pickListValuesList ){
                this.picklistValues = data.pickListValuesList;
                
            }
           if( data.lstJournals ){
                for( let i in data.lstJournals  ){
                    this.journals.push({ 
                        Id : data.lstJournals[i].Id,
                        Name:data.lstJournals[i].name, 
                        Frequency_of_Journal__c:data.lstJournals[i].frequency, 
                        Date_Initial_Search_Started__c:data.lstJournals[i].initialStartDate, 
                        Date_Last_Journal_Search_was_Performed__c:data.lstJournals[i].lastJournalSearchWasPerformed, 
                        Review_Dates__c:data.lstJournals[i].reviewDate
                     });
                }
               
            }
            this.conditionalDates = [];
            if( data.dates ){
                this.conditionalDates = data.dates;
            }
            if( this.journalRealtionIds.length == 0 ){
                this.journalRealtionIds = data.relationJournals;
            }
            const mapjournalsTotal = new Map();
            const mapjournalsFrequency = new Map();
            let journalTotal = 1;
            let journalFreq = 1;
            for( let reviewsList in  this.conditionalDates){
                for( let journal in this.journals ){
                    if( this.journals[journal].Review_Dates__c === this.conditionalDates[reviewsList] ){
                        if( mapjournalsTotal.has( this.conditionalDates[reviewsList] ) ){
                            mapjournalsTotal.set( this.conditionalDates[reviewsList],mapjournalsTotal.get(this.conditionalDates[reviewsList])+1); 
                        }else{
                            mapjournalsTotal.set( this.conditionalDates[reviewsList], journalTotal);
                        }
                        let uniKey;
                        uniKey = this.conditionalDates[reviewsList]+'-'+this.journals[journal].Frequency_of_Journal__c;
                        if( mapjournalsFrequency.has( uniKey ) ){
                            mapjournalsFrequency.set( uniKey,mapjournalsFrequency.get( uniKey )+1 ); 
                        }else{
                            mapjournalsFrequency.set( uniKey, journalFreq);
                        }
                    }
                    
                }
            }
            if( data.dates ){
                this.conditionDate = data.dates;
            }
            var dates = data.dates;
            
            for( let i = 0 ; i < this.picklistValues.length; i++ ){
                let journaldataRow =[];
                for( let j = 0 ; j < dates.length; j++  ){
                    let uniKey = dates[j]+'-'+this.picklistValues[i];
                    if( mapjournalsFrequency.has( uniKey ) ){
                        journaldataRow.push( mapjournalsFrequency.get( uniKey ) );
                    }else{
                        journaldataRow.push(0);
                    }
                }
                this.journaldata.push( {value:journaldataRow, key:this.picklistValues[i]} );
            }
            for( let j = 0 ; j < dates.length; j++  ){
                if( mapjournalsTotal.has( dates[j] ) ){
                    this.total.push( mapjournalsTotal.get( dates[j] ) );
                }else{
                    this.total.push(0)
                }
            }
            this.isLoaded = false;
       });
    }
    showMessege(msg,title,variantType) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variantType
        });
        this.dispatchEvent(event);
    }
    getDate(event){
        this.isAllFilter = true;
        let changeDateForAll =  new Date(event.target.value);
        let changeDate = event.target.value;
        let previousDate = this.showReviewDate;
        let eJId = [];
        let dt = new Date(changeDate);
        let dayOfWeek = this.days[dt.getDay()];
        let inputCmp = this.template.querySelector('.inputCmp1');
        if(dayOfWeek==='Friday'|| dayOfWeek==='Saturday' || dayOfWeek==='Sunday'){
            inputCmp.setCustomValidity('Event Journal Review due date cannot be of Friday, Saturday or Sunday. Please select a date from Monday to Thursday.');
        }else{
            inputCmp.setCustomValidity('');
            if(this.valid_date_past( changeDateForAll, this.toDayDate ) === false){
                this.isLoaded = true;
                for( let journal in this.journalsInPopUp ){
                    eJId.push( this.journalsInPopUp[journal].Id );
                }
                if( eJId.length > 0 ){
                    getRecord({ recordIds : eJId }).then((data) => {
                        if( data ){
                            for( let journal in data ){
                                const updateReviewDates = new Set();
                                let journalAllReviewDates = data[journal].Review_Dates__c.split(',');
                                for( let i in journalAllReviewDates){
                                    if( journalAllReviewDates[i] === previousDate ){
                                        if(!updateReviewDates.has( changeDate )){
                                            updateReviewDates.add( changeDate );
                                        }
                                        
                                    }else{
                                        if(!updateReviewDates.has( journalAllReviewDates[i] )){
                                            updateReviewDates.add( journalAllReviewDates[i] );
                                        }
                                    }
                                }
                                data[journal].Review_Dates__c = '';
                                data[journal].Review_Dates__c = Array.from( updateReviewDates ).join(',');
                                
                            }
                            this.selectedjournalsForSubmit = [...data];
                            this.isbuttonShow = true;
                            this.isChanged = true;
                            this.showReviewDate = changeDateForAll.getFullYear() +'-'+this.verfyValue(changeDateForAll.getMonth()+1)+'-'+this.verfyValue( changeDateForAll.getDate()); 
                        }
                        
                    });
                }
            }else{
                this.isbuttonShow = false;
                inputCmp.setCustomValidity('Choose Date cannot be in the past');
            }
        }
        inputCmp.reportValidity();
        this.isLoaded = false;
    }
    /**
     * Method is used to verify Month and Date
     */
     verfyValue( value ) {
        if( value < 10 ){
            value = '0'+value;
        }
        return value;
    }
    valid_date_past = (sdate,edate) => {
        var selectDate = new Date(sdate);
        sdate = selectDate.getFullYear()+'-'+(selectDate.getMonth()+1)+'-'+selectDate.getDate();
        return new Date(edate) > new Date(sdate);
    }
    ExportJournals(){
        this.isExportJournals = true;
    }
    ExportToCancel(){
        this.ExportToJournals =[];
        this.isCompleteExportFilter = false;
        this.isExportJournals = false; 
        this.load( this.toDayDate, 'PRESENT', this.journalRealtionIds );
    }
    ExportToNext(){
        this.isLoadedExport =true;
        if( this.visible ){
            Array.prototype.push.apply(this._selected, this.picklistValues);
        }
        const mapOfError = new Map(); 
        let count = 0;
        if( !this.exportToStartDate  ){
            count = 1;
            mapOfError.set( count ,'Please choose Start Date' );
        }
        if( !this.exportToEndDate ){
            count = 2
            mapOfError.set( count ,'Please choose End  Date' );
        }
        if( this._selected.length === 0 ){
            count = 3;
            mapOfError.set( count ,'Please Select Frequency' );
        }
        if( !this.exportToStartDate && !this.exportToEndDate ){
            count = 4;
            mapOfError.set( count ,'Please Choose Start and End Date' );
        }
        if(  !this.exportToEndDate && this._selected.length === 0){
            count = 5;
            mapOfError.set( count ,'Please Choose End Date and Select Frequency' );
        }
        if(  !this.exportToStartDate && this._selected.length === 0){
            count = 6;
            mapOfError.set( count ,'Please Choose Start Date and Select Frequency' );
        }
        if( !this.exportToStartDate && !this.exportToEndDate &&  this._selected.length === 0 ){
            count = 7;
            mapOfError.set( count ,'Please choose Both of Dates and select Frequency' );
        }
        if( count === 0 ){
            
            getjournalsForExport({ 
                startDate : this.exportToStartDate,
                endDate : this.exportToEndDate,
                frequecyList : this._selected,
                ejIdList : this.journalRealtionIds,
                serviceLineProjectId : this.recordId
             }
                ).then((data) => {
                    if( data != null ){
                        for( let i in  data ){
                            this.ExportToJournals.push({ 
                                Id : data[i].Id,
                                Name:data[i].name, 
                                Frequency_of_Journal__c:data[i].frequency, 
                                Date_Initial_Search_Started__c:data[i].initialStartDate, 
                                Date_Last_Journal_Search_was_Performed__c:data[i].lastJournalSearchWasPerformed, 
                                Review_Dates__c:data[i].reviewDate
                             });
                        }
                    }
                    
                    this.isCompleteExportFilter = true;
                    this.isLoadedExport = false;
            });
            
            }else{
                this.isLoadedExport =false;
                this.showMessege( mapOfError.get(count),'Error','error' );
            }
    }
    ExportToExcel() {
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
        doc += '<th> Name </th>' 
        doc += '<th> Frequency of Journal </th>' 
        doc += '<th> Date Initial Search Started </th>' 
        doc += '<th> Date Last Journal Search was Performed </th>' 
        doc += '<th> Event Journal Review due date </th>'      
        doc += '</tr>';
        // Add the data rows
        for( let Exportjournal in this.ExportToJournals ){ 
            doc += '<tr>';
            doc += '<td>'+this.ExportToJournals[Exportjournal].Name+'</td>'; 
            doc += '<td>'+this.ExportToJournals[Exportjournal].Frequency_of_Journal__c+'</td>'; 
            doc += '<td>'+this.ExportToJournals[Exportjournal].Date_Initial_Search_Started__c+'</td>';
            doc += '<td>'+this.ExportToJournals[Exportjournal].Date_Last_Journal_Search_was_Performed__c+'</td>';
            doc += '<td>'+this.ExportToJournals[Exportjournal].Review_Dates__c+'</td>'; 
            doc += '</tr>';
        }
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Event Journals.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        this.isExportJournals = false; 
        this.isLoaded = true;
        this.load( this.toDayDate, 'PRESENT', this.journalRealtionIds );

    }
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }
    getFrequencies(e) {
        this._selected = e.detail.value;
        
    }
    getExportStartDate(e){
        this.exportToStartDate = e.target.value;
    }
    getExportEndDate(e){
        this.exportToEndDate = e.target.value;
    }
    get options() {
        let options =[];
        for( let count in this.picklistValues ){
            options.push({label: this.picklistValues[count], value: this.picklistValues[count] });
        }
        return options;
    }
    getAllFrequency(e){
        this.visible = !this.visible;
        if( this.visible ){
            this.isShowFrequency = false;
        }else{
            this.isShowFrequency = true;
            this._selected =[];
        }
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
    
}
