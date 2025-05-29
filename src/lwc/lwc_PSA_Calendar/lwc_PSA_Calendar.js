import { LightningElement,track,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import getData from '@salesforce/apex/CNT_PSA_MyPersonalCalendar.getData';
import { refreshApex } from '@salesforce/apex';
const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

// row actions

const COLUMNS = [
    { label: 'LR Project Overview Name', fieldName: 'LR_Project_Overview_URL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'LR_Project_Overview_Name' }, target: '_blank'}  
    },
    { label: 'Project Event  Name', fieldName: 'Project_Event_URL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Project_Name' }, target: '_blank'}  
    },
    { label: 'Event Due Date', fieldName: 'eventDueDate', type: 'Date', sortable: true }
];
export default class Lwc_PSA_Calendar extends  NavigationMixin(LightningElement) {
    columns = COLUMNS;
    currentMonth;
    currentYear;
    actualCurrentMonth;
    actualCurrentYear;
    @track currentMonthInWords;
    @track today;
    @track dlpStop ='DLP (Enter only for Aggregate Reports)';
    @track lriStop = 'LR LBI Period Stop Date';
    @track isCurrent = false;
    @track showButton = false;
    HeadingName = 'Project Events';
    weaklyData =[];
    error;
    currentUserName;
    filteredRecord =[];
    @track CopyFilteredRecord =[];
    isShow = false;
    isShowDLP = false;
    isShowLRI = false;
    lriSet = [];
    dlpSet = [];
    loaded = true;
    _cacheBus =0;
    constructor() {
        super();
        this.today = new Date();
        this.actualCurrentMonth = this.today.getMonth();
        this.actualCurrentYear = this.today.getFullYear();
    }

    @wire(getRecord, { recordId: Id, fields: [ UserNameFld ]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            console.log('@current User Name '+this.currentUserName);
            this.current();
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(getData,{ 
        currentUserName: '$currentUserName',
        CurrentUserId : Id,
        getMonth : '$currentMonth',
        refresh :'$_cacheBus'})
    getDataFromApex({error, data}) {
        if (data) {
            this.lriSet = [];
            this.dlpSet = [];
            var tempData = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                for(let record in tempData){
                    if(tempData[record].eventDueDate){
                        let lbi =  tempData[record].eventDueDate.split('-');
                        let lbiStopDateInDay = parseInt(lbi[2]);
                        if(tempData[record].isDLP){
                            this.dlpSet.push(lbiStopDateInDay);
                        }else{
                            this.lriSet.push(lbiStopDateInDay);
                        }
                    }
                }
                tempData.forEach(function (record) {
                    record['LR_Project_Overview_URL'] = '/' + record.lrProjectId;
                    record['LR_Project_Overview_Name'] =record.lrProjectName;
                    record['Project_Event_URL'] = '/' + record.eventProjectId;
                    record['Project_Name'] = record.eventProjectName;
                    record['eventDueDate'] = record.eventDueDate;
                });
                this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                this.CopyFilteredRecord = JSON.parse(JSON.stringify(tempData));
            }
            this.showCalendar(this.currentMonth, this.currentYear,this.lriSet,this.dlpSet);
           
        } else if (error) {
            this.error = error ;
        }
        
    }

    next() {
        this.loaded = true;
        this.currentYear = (this.currentMonth === 11) ? this.currentYear + 1 : this.currentYear;
        this.currentMonth = (this.currentMonth + 1) % 12;
        if(this.actualCurrentMonth === this.currentMonth && this.actualCurrentYear === this.currentYear){
            this.current();
        }else{
            this.isCurrent = false;
        }
    }
    previous() {
        this.loaded = true;
        this.currentYear = (this.currentMonth === 0) ? this.currentYear - 1 : this.currentYear;
        this.currentMonth = (this.currentMonth === 0) ? 11 : this.currentMonth - 1;
        if(this.actualCurrentMonth === this.currentMonth && this.actualCurrentYear === this.currentYear){
            
            this.current();
        }else{
            this.isCurrent = false;
        }
    }
    current(){
        this.loaded = true;
        this.currentMonth = this.today.getMonth();
        this.currentYear = this.today.getFullYear();
        this.isCurrent = true;
        this.showCalendar(this.actualCurrentMonth, this.actualCurrentYear,this.lriSet,this.dlpSet);
    }
    showCalendar(month, year,lriSet,dlpSet) {
        this.currentMonthInWords = months[month];
        this.weaklyData = [];
        // creating all cells
        let firstDay = this.getFirstDayOfMonth(year, month).getDay();
        let date = 1;
        for (let i = 0; i < 6; i++) {
            let showCalendarData = [];
            for (let j = 0; j < 7; j++) {
                if (i === 0 && j < firstDay) {
                    showCalendarData.push(
                        {
                            daysNumber :'',
                            isToday :false,
                            lrStop : false,
                            lriStop : false,
                            repeatLBI : 0,
                            repeatDLP : 0
                        }
                    );
                }
                else if (date > this.daysInMonth(month, year)) {
                    break;
                }

                else {
                    if (date === this.today.getDate() && this.currentYear === this.today.getFullYear() && this.currentMonth === this.today.getMonth() && this.isCurrent) {
                        let repeatValueDlp = 0;
                        let repeatValueLbi = 0;
                        let lriFlag = false;
                        let dlpFlag = false;
                        if(lriSet.includes(date)){
                            lriFlag = true;
                            repeatValueLbi = this.getRepeat(lriSet,date);
                        }
                        if(dlpSet.includes(date)){
                            dlpFlag = true;
                            repeatValueDlp = this.getRepeat(dlpSet,date);
                        }
                        showCalendarData.push(
                            {
                                daysNumber : date,
                                isToday :false,
                                lrStop : dlpFlag,
                                lriStop : lriFlag,
                                repeatLBI : repeatValueLbi,
                                repeatDLP : repeatValueDlp
                            }
                        );
                    }else{
                        let repeatValueDlp = 0;
                        let repeatValueLbi = 0;
                        let lriFlag = false;
                        let dlpFlag = false;
                        if(lriSet.includes(date)){
                            lriFlag = true;
                            repeatValueLbi = this.getRepeat(lriSet,date);
                        }
                        if(dlpSet.includes(date)){
                            dlpFlag = true;
                            repeatValueDlp = this.getRepeat(dlpSet,date);
                        }
                        showCalendarData.push(
                            {
                                daysNumber : date,
                                isToday :false,
                                lrStop : dlpFlag,
                                lriStop : lriFlag,
                                repeatLBI : repeatValueLbi,
                                repeatDLP : repeatValueDlp
                            }
                        );
                    }
                    date++;
                }
            }
            if(showCalendarData.length > 0){
                this.weaklyData.push({value : showCalendarData, key : i });
            }
            
        }
        this.loaded = false;
    }
    
    daysInMonth(iMonth, iYear) { 
        return 32- new Date(iYear, iMonth, 32).getDate();
    }
    getFirstDayOfMonth(year, month) {
        return new Date(year, month, 1);
    }
    onDLPStop(event){
        this.HeadingName = 'Project Events for DLP';
        this.isShowDLP = true;
        this.isShowLRI = false;
        this.isShow = true;
        let getDayNumber = 0;
        let copyData = [];
        this.filteredRecord =[];
        getDayNumber = event.currentTarget.dataset.id;
        for(let record in this.CopyFilteredRecord){
            let dayNumber = 0;
            if(this.CopyFilteredRecord[record].eventDueDate){
                let lbi =  this.CopyFilteredRecord[record].eventDueDate.split('-');
                dayNumber = parseInt(lbi[2]);
                if(getDayNumber == dayNumber && this.CopyFilteredRecord[record].isDLP){
                    copyData.push(this.CopyFilteredRecord[record]);
                }
            }
        }
        this.filteredRecord = [...copyData];
    }
    onLRIStop(event){
        this.HeadingName = 'Project Events for LBI';
        this.isShowDLP = false;
        this.isShowLRI = true;
        this.isShow = true;
        let getDayNumber = 0;
        let copyData = [];
        this.filteredRecord =[];
        getDayNumber = event.currentTarget.dataset.id;
        for(let record in this.CopyFilteredRecord){
            let dayNumber = 0;
            if(this.CopyFilteredRecord[record].eventDueDate){
                let lbi =  this.CopyFilteredRecord[record].eventDueDate.split('-');
                dayNumber = parseInt(lbi[2]);
                if(getDayNumber == dayNumber && !this.CopyFilteredRecord[record].isDLP){
                    copyData.push(this.CopyFilteredRecord[record]);
                }
            }
        }
        this.filteredRecord = [...copyData];
    }
    Cancel(){
        this.isShow = false;
        this.isShowLRI = false;
        this.isShowDLP = false;
        
    }
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
        }

    }

    editCurrentRecord(currentRow) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: currentRow.lrProjectId,
                objectApiName: 'LR_Project_Overview__c',
                actionName: 'edit'
            }
        });
        this.showButton = true;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        const cloneData = [...this.filteredRecord];
        cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.filteredRecord = cloneData;

    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    getRepeat(arrayList, value){
        let count = 0;
        for(let i = 0; i < arrayList.length; ++i){
            if(arrayList[i] == value)
                count++;
        }
        return count;
    }
    refresh(){
        this._cacheBus = Math.random();
        refreshApex(this.CopyFilteredRecord);
        refreshApex(this.filteredRecord);
        this.showButton = false;
    }
  }
