import { LightningElement,wire,api,track } from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import COUNTRY_FIELD from '@salesforce/schema/Journals_Main_Catalogue__c.Country__c';
import getMainJournalCatalogueList from '@salesforce/apex/CNT_PSA_addJournal.getMainJournalCatalogueList';
import haveEditablePermission from '@salesforce/apex/CNT_PSA_addJournal.haveEditablePermission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import JOURNAL_MAIN_CATALOG__OBJECT from '@salesforce/schema/Journals_Main_Catalogue__c';
import EVENT_JOURNALS__OBJECT from '@salesforce/schema/Event_Journals__c';
import { CurrentPageReference } from "lightning/navigation";
import addEventJournalToLRProjectOverview from '@salesforce/apex/CNT_PSA_addJournal.addEventJournalToLRProjectOverview';
import pickListValueDynamically from '@salesforce/apex/CNT_PSA_addJournal.pickListValueDynamically';
import permissionError from '@salesforce/label/c.EJ_CL01_LWC_AddEventJournal_PermissionError';
import LRProjectOverviewIdError from '@salesforce/label/c.EJ_CL02_LWC_AddEventJournal_LR_OverviewIdRequired';
import {NavigationMixin} from 'lightning/navigation';
import lrProjectOverviewValidation from '@salesforce/apex/CNT_PSA_addJournal.lrProjectOverviewValidation';
import getMainJournalCatalogueListFromCountry from '@salesforce/apex/CNT_PSA_addJournal.getMainJournalCatalogueListFromCountry';
export default class Lwc_psa_addEventJournal extends NavigationMixin( LightningElement ) {
    label = {
        permissionError,
        LRProjectOverviewIdError
    };
    @track options;
    data=[];
    fullData=[];
    error;
    isEditable = true;
    dataToBeAdded;
    LR_Project_Overview_ID;
    LRProjectOverviewError=false;
    dataToBeDisplayed=[];
    toDayDate;
    lrTypeError = false; 
    @track picklistJournalFrequency;
    @track picklistActive;
    @track loaded = true;
    @track noCountryError = false;
    @track isMore = false;
    @track displayMainJCIds =[];
    @track isOptions = 'None';
    @track disableCountryDropdown = true;
    @track selectedCountries = ['None'];
    @track LrErrorString = '';

    /**
     * Method used to get current page details
     */
     constructor() {
        super();
        haveEditablePermission({ Id: Id }).then((result) => {
             this.isEditable = result;
        });
    }
     connectedCallback() {
        
        var today = new Date();
        this.toDayDate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();

        lrProjectOverviewValidation({ LR_Project_Overview : this.LR_Project_Overview_ID }).then((result) => {
            if ( result == 'MissingLRFields' ){
                this.lrTypeError = true;
                this.LrErrorString = 'You cannot create a new Event Journal record because Project, Account, Product and LR Type is blank on the LR project overview record.';
            }else if ( result == 'NotValidForLocal' ){
                this.lrTypeError = true;
                this.LrErrorString = 'LR Type is not set to Local in the Project Overview section you cannot create a Journal record';
            }else if( result == 'NotValidForCompleteAndCancelled' ){
                this.lrTypeError = true;
                this.LrErrorString = 'You cannot create new Event Journal records when status of LR Project overview is marked as completed or Cancelled.';
            }else{
                this.lrTypeError = false;
            }
             
        });
    }

    
    @wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'Event_Journals__c'},
    selectPicklistApi: 'Frequency_of_Journal__c'}) picklistJournalFrequency;

    @wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'Event_Journals__c'},
    selectPicklistApi: 'Active__c'}) picklistActive;

     
    @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__LR_Project_Overview;
            if (urlValue) {
                this.LR_Project_Overview_ID=urlValue;
                console.log('LR_Project_Overview_ID--'+this.LR_Project_Overview_ID);
            } else {
                this.LRProjectOverviewError=true;
                console.log("error");
            }
        }
    }
    /**
     * Method used to get information about Journal_Main_Catalogue Object
     */
    @wire(getObjectInfo,{objectApiName:JOURNAL_MAIN_CATALOG__OBJECT})
    getMainCatalogobjectData;
    /**
     * Method used to get information about Event_Journal Object
     */
    @wire(getObjectInfo,{objectApiName:EVENT_JOURNALS__OBJECT})
    getEventJournalobjectData;
    /**
     * Method used to check if user have editable permission or not
     */
    @wire(haveEditablePermission,{userId : Id}) 
    haveEditablePermission({data,error}){
        if(data){
            this.isEditable=data;
        }
        else if(error){
            this.showToast( 'Error Occured!',error,'error' );
        }
    }
    /**
     * Method used to prepare data to be displayed 
     */
     @wire(getMainJournalCatalogueList) getMainJournalCatalogueList(response) {
        if (response.data) {  
            this.data=response.data;
            for (let key in this.data) {
                this.fullData.push({Id:this.data[key].Id,
                    Name:this.data[key].Name,
                    Country__c:this.data[key].Country__c,
                    Journal_Name__c:this.data[key].Journal_Name__c,
                    URL__c:this.data[key].URL__c,
                    Periodicity__c:this.data[key].Periodicity__c,
                    Subscription__c:this.data[key].Subscription__c,
                    Paper_Journal__c:this.data[key].Paper_Journal__c,
                    Therapeutic_Area__c:this.data[key].Therapeutic_Area__c,
                    Regulatory_requirement__c:this.data[key].Regulatory_requirement__c,
                    QPPV_LPS_Comments__c:'',
                    Frequency_of_Journal__c:'None',
                    Other_Journal_Frequency_Specify__c:'',
                    Date_Initial_Search_Started__c:'',
                    Date_Last_Journal_Search_was_Performed__c: '',
                    Date_Next_Journal_Search_is_Due__c: '',
                    Active__c:'None',
                    Inactive_since__c:'',
                    isSelected:false,
                    editQVVPComment:false,
                    editOtherJournalFrequencySpecify:false,
                    isInactive:false,
                    isInactiveError:false,
                    DateLastJournalSearchwasPerformedError : false,
                    OtherJournalError : false,
                    DueDateError : false,
                    commentLengthError : false,
                    otherlengthError : false
                });
            }
            this.dataToBeDisplayed=[...this.fullData];
            this.isMore = true;
        }
        else if(response.error){
            this.showToast( 'Error Occured!',response.error,'error' );
        }
    }
    
    /**
     * Method is used to handle Editing of QPPV/LPS Comments
     */
    handleEditQVVPComment(event){
        const itemIndex = event.target.dataset.index;  
        this.dataToBeDisplayed[itemIndex].editQVVPComment= true;
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
        new Promise((resolve) => {
            setTimeout(() => resolve(1), 100);
        }).then((value) => {
            this.setFocus();
        });
    }

    
    /**
     * Method is used to handle Editing of Journal_Frequency_Specify
     */
     handleEditOtherJournalFrequencySpecify(event){
        const itemIndex = event.target.dataset.index;  
        this.dataToBeDisplayed[itemIndex].editOtherJournalFrequencySpecify= true;
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
        new Promise((resolve) => {
            setTimeout(() => resolve(1), 100);
        }).then((value) => {
            this.setFocus();
        });
    }
    
    /**
     * Method is used to handle Set Focus on input fields
     */
    setFocus(){
        const focusElement=this.template.querySelector(".edit");
        focusElement.focus();
    }
    /**
     * Method is used to change Selectedstatus
     */
    changeSelectedStatus(event){
        const itemIndex = event.target.dataset.index;  
        this.dataToBeDisplayed[itemIndex].isSelected=!this.dataToBeDisplayed[itemIndex].isSelected;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        this.fullData[objIndex].isSelected= this.dataToBeDisplayed[itemIndex].isSelected;
        this.fullData=[...this.fullData];
    }
    /**
     * Method is used to handle the value of QPPV Comment after editing
     */
    handleNewQVVPComment(event){
        const itemIndex = event.target.dataset.index; 
        this.dataToBeDisplayed[itemIndex].QPPV_LPS_Comments__c= event.target.value;
        this.dataToBeDisplayed[itemIndex].editQVVPComment= false;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        let comment = event.target.value;
        if ( comment.length >= 255 ) {
            this.fullData[objIndex].commentLengthError = true;
        }else{
            this.fullData[objIndex].commentLengthError = false;
            this.fullData[objIndex].QPPV_LPS_Comments__c= this.dataToBeDisplayed[itemIndex].QPPV_LPS_Comments__c;
        }
        
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
    }

    /**
     * Method is used to handle the value of Frequency_of_Journal after editing
     */
     handleNewFrequencyOfJournal(event){
        //this.Frequency_of_Journal__c = event.target.value;

        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Frequency_of_Journal__c= event.target.value;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        if( event.target.value === 'Other' &&  !this.fullData[objIndex].Other_Journal_Frequency_Specify__c ){
            this.fullData[objIndex].OtherJournalError = true; 
        }else{
            this.fullData[objIndex].OtherJournalError = false; 
        }
        this.fullData[objIndex].Frequency_of_Journal__c= this.dataToBeDisplayed[itemIndex].Frequency_of_Journal__c;
        if( this.fullData[objIndex].Date_Last_Journal_Search_was_Performed__c !== '' ){
            var lastJournalDate = new Date( this.fullData[objIndex].Date_Last_Journal_Search_was_Performed__c );
            if( this.fullData[objIndex].Frequency_of_Journal__c 
                && this.fullData[objIndex].Frequency_of_Journal__c != 'None' 
                && this.fullData[objIndex].Frequency_of_Journal__c != 'N/A'
                && this.fullData[objIndex].Frequency_of_Journal__c != 'Other'){
    
                    this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c = this.setDateNextJournalSearchIsDue( this.fullData[objIndex].Frequency_of_Journal__c, lastJournalDate );
            }else{
                this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c = this.fullData[objIndex].Date_Last_Journal_Search_was_Performed__c;
            }

        }
        if( this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c !== '' ){
            if(this.valid_date_past( this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c, this.toDayDate ) === false){
                this.fullData[objIndex].DueDateError = false;
            }else{
                this.fullData[objIndex].DueDateError = true; 
            }
        }
        
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
    }

    /**
     * Method is used to handle the value of Frequency_of_Journal after editing
     */
     handleNewOtherJournalFrequencySpecify(event){
        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Other_Journal_Frequency_Specify__c= event.target.value;
        
        this.dataToBeDisplayed[itemIndex].editOtherJournalFrequencySpecify= false;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        if( event.target.value ){
            this.fullData[objIndex].OtherJournalError = false;
        }
        let otherComment = event.target.value;
        if ( otherComment.length >= 255 ) {
            this.fullData[objIndex].otherlengthError = true;
        }else{
            this.fullData[objIndex].otherlengthError = false;
            this.fullData[objIndex].Other_Journal_Frequency_Specify__c= this.dataToBeDisplayed[itemIndex].Other_Journal_Frequency_Specify__c;
        
        }
       this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
    }


    /**
     * Method is used to handle the value of Frequency_of_Journal after editing
     */
     handleNewDateInitialSearchStarted(event){
        //this.Date_Initial_Search_Started__c = event.target.value;

        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Date_Initial_Search_Started__c= event.target.value;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        this.fullData[objIndex].Date_Initial_Search_Started__c= this.dataToBeDisplayed[itemIndex].Date_Initial_Search_Started__c;
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];

    }


    /**
     * Method is used to handle the value of Frequency_of_Journal after editing
     */
     handleNewDateLastJournalSearchwasPerformed(event){
        //this.Date_Last_Journal_Search_was_Performed__c = event.target.value;

        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Date_Last_Journal_Search_was_Performed__c= event.target.value;
        var  lastJournalDate =  new Date(event.target.value) ;
        
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        if(this.valid_date_future( lastJournalDate, this.toDayDate ) === false){
            this.fullData[objIndex].DateLastJournalSearchwasPerformedError = true;
        }else{
            this.fullData[objIndex].DateLastJournalSearchwasPerformedError = false;
        }
        this.fullData[objIndex].Date_Last_Journal_Search_was_Performed__c= this.dataToBeDisplayed[itemIndex].Date_Last_Journal_Search_was_Performed__c;
        if( this.fullData[objIndex].Frequency_of_Journal__c 
            && this.fullData[objIndex].Frequency_of_Journal__c != 'None' 
            && this.fullData[objIndex].Frequency_of_Journal__c != 'N/A'
            && this.fullData[objIndex].Frequency_of_Journal__c != 'Other'){

                this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c = this.setDateNextJournalSearchIsDue( this.fullData[objIndex].Frequency_of_Journal__c, lastJournalDate );
        }else{
            this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c = this.dataToBeDisplayed[itemIndex].Date_Last_Journal_Search_was_Performed__c;
        }
        if( this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c !== '' ){
            if(this.valid_date_past( this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c, this.toDayDate ) === false){
                this.fullData[objIndex].DueDateError = false;
            }else{
                this.fullData[objIndex].DueDateError = true; 
            }
        }
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
        
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
    // Add Days in Date
     addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
      }
    setDateNextJournalSearchIsDue( FrequencyOfJournal, lastJournalDate ){
        if( FrequencyOfJournal === 'Bi-Annual (Twice a year)' ){
            lastJournalDate = this.addDays( lastJournalDate, 180 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
            
        }
        
        if( FrequencyOfJournal === 'Bi-Monthly (Every two months)' ){
            lastJournalDate = this.addDays( lastJournalDate, 60 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
            
        }
        
        if( FrequencyOfJournal === 'Bi-Weekly (Every two weeks)' ){
            lastJournalDate = this.addDays( lastJournalDate, 14 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
            
        }
        
        if( FrequencyOfJournal === 'Every 9 Months' ){
            lastJournalDate = this.addDays( lastJournalDate, 270 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
        }
        
        if( FrequencyOfJournal === 'Monthly' ){
            lastJournalDate = this.addDays( lastJournalDate, 30 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
        }
        
        if( FrequencyOfJournal === 'Quarterly' ){
            lastJournalDate = this.addDays( lastJournalDate, 90 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
        }
        
        if( FrequencyOfJournal === 'Weekly' ){
            lastJournalDate = this.addDays( lastJournalDate, 7 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
        }
        
        if( FrequencyOfJournal === 'Yearly (Annual)' ){
            lastJournalDate = this.addDays( lastJournalDate, 365 );
            lastJournalDate = lastJournalDate.getFullYear() +'-'+this.verfyValue(lastJournalDate.getMonth()+1)+'-'+this.verfyValue( lastJournalDate.getDate());
        }
        return lastJournalDate;
    }
    
     handleNewDateNextJournalSearchIsDue(event){
        var dueDate = event.target.value;
        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Date_Next_Journal_Search_is_Due__c= event.target.value;
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        this.fullData[objIndex].Date_Next_Journal_Search_is_Due__c = this.dataToBeDisplayed[itemIndex].Date_Next_Journal_Search_is_Due__c;
        if(this.valid_date_past( dueDate, this.toDayDate ) === false){
            this.fullData[objIndex].DueDateError = false;
        }else{
            this.fullData[objIndex].DueDateError = true; 
        }
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];
    }


     handleIsActive(event){
        const itemIndex = event.target.dataset.index;       
        this.dataToBeDisplayed[itemIndex].Active__c= event.target.value;
        
        var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
        this.fullData[objIndex].Active__c= this.dataToBeDisplayed[itemIndex].Active__c;
        if( event.target.value === 'Yes' ){
            this.fullData[objIndex].isInactive = true;
            this.fullData[objIndex].Inactive_since__c = '';
            this.fullData[objIndex].isInactiveError = false; 
        }
        if( event.target.value === 'No' || event.target.value === 'None'){
            this.fullData[objIndex].isInactive = false;
        }
        this.fullData=[...this.fullData];
        this.dataToBeDisplayed=[...this.dataToBeDisplayed];

    }
     handleNewInactivesince(event){
            
            var inActiveDate = event.target.value;
            const itemIndex = event.target.dataset.index;       
            this.dataToBeDisplayed[itemIndex].Inactive_since__c= event.target.value;
            var objIndex = this.fullData.findIndex((obj => obj.Id == this.dataToBeDisplayed[itemIndex].Id));
            this.fullData[objIndex].Inactive_since__c= this.dataToBeDisplayed[itemIndex].Inactive_since__c;
            if(this.valid_date_future( inActiveDate, this.toDayDate ) === false){
                this.fullData[objIndex].isInactiveError = true;
            }else{
                this.fullData[objIndex].isInactiveError = false; 
            }
            this.fullData=[...this.fullData];
            this.dataToBeDisplayed=[...this.dataToBeDisplayed];
    }
    /**
     * Method is used to get Valid Date
     */
    valid_date_future = (sdate,edate) => {
        var selectDate = new Date(sdate);
        sdate = selectDate.getFullYear()+'-'+(selectDate.getMonth()+1)+'-'+selectDate.getDate();
        return new Date(edate) >= new Date(sdate);
    }

    valid_date_past = (sdate,edate) => {
        var selectDate = new Date(sdate);
        sdate = selectDate.getFullYear()+'-'+(selectDate.getMonth()+1)+'-'+selectDate.getDate();
        return new Date(edate) > new Date(sdate);
    }

    /**
     * Method is used to render JMCs data according to countries selected 
     */
    searchEventJournal(event) {
        let selectedCountriesLabels = []
        event.detail.forEach(element => {
            selectedCountriesLabels.push(element.label)
        });
        this.selectedCountries = selectedCountriesLabels;
        this.data = [];
        this.fullData = [];
        this.dataToBeDisplayed = [];
        this.loaded = true;
        this.getMainJournalCatalogue(this.selectedCountries, null);
    }

    getMainJournalCatalogue(selectedCountriesLabels, mainJCIds) {
        getMainJournalCatalogueListFromCountry({ countries: selectedCountriesLabels, mainJCIds: mainJCIds })
            .then(data => {
                if ( data) {  
                    this.data=data;
                    console.log('size '+ this.data.length );
                    if( this.data.length >  49 ){
                        this.isMore = true;
                    }else{
                        this.isMore = false;
                    }
                    for (let key in this.data) {
                        this.fullData.push({Id:this.data[key].Id,
                            Name:this.data[key].Name,
                            Country__c:this.data[key].Country__c,
                            Journal_Name__c:this.data[key].Journal_Name__c,
                            URL__c:this.data[key].URL__c,
                            Periodicity__c:this.data[key].Periodicity__c,
                            Subscription__c:this.data[key].Subscription__c,
                            Paper_Journal__c:this.data[key].Paper_Journal__c,
                            Therapeutic_Area__c:this.data[key].Therapeutic_Area__c,
                            Regulatory_requirement__c:this.data[key].Regulatory_requirement__c,
                            QPPV_LPS_Comments__c:'',
                            Frequency_of_Journal__c:'None',
                            Other_Journal_Frequency_Specify__c:'',
                            Date_Initial_Search_Started__c:'',
                            Date_Last_Journal_Search_was_Performed__c: '',
                            Date_Next_Journal_Search_is_Due__c: '',
                            Active__c:'None',
                            Inactive_since__c:'',
                            isSelected:false,
                            editQVVPComment:false,
                            editOtherJournalFrequencySpecify:false,
                            isInactive:false,
                            isInactiveError:false,
                            DateLastJournalSearchwasPerformedError : false,
                            OtherJournalError : false,
                            DueDateError : false,
                            commentLengthError : false,
                            otherlengthError : false,
                            isCompleted : false
                        });
                    }
                    this.dataToBeDisplayed=[...this.fullData];
                    if( this.dataToBeDisplayed.length  > 0 ){
                        this.noCountryError = false; 
                    }else{
                        this.noCountryError = true;
                    }
                    this.loaded = false;
                }
            })
            .catch(error => {
            });

    }

    /**
     * Method used to get picklist values of Country field of Journal_Main_Catalogue Object
     */
    @wire(getPicklistValues, { recordTypeId: '$getMainCatalogobjectData.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD })
    setCountryPicklist({ data, error }) {
        if (data) {
            this.loaded = false;
            this.options = [{ label: 'None', value: 'None', selected: true }, ...data.values];
        } else if (error) {
            this.showToast('Error Occured!', JSON.stringify(error), 'error');
        }
    }

    /**
     * Method is used to create New Event Journal Records
     */
    disabled = false;
    eventJournalToBeCreated(){
        this.isLoading = true;
        this.dataToBeAdded =[];
        let errorFlag = true;
        let errorString = [];
        
        for (let key in this.dataToBeDisplayed) {
            if( this.dataToBeDisplayed[key].isSelected === true ){
                this.dataToBeAdded.push( this.dataToBeDisplayed[key] );
                
                if( this.dataToBeDisplayed[key].QPPV_LPS_Comments__c === ''  ){
                    errorFlag = false;
                    errorString.push( ' Please put QPPV/LPS Comment for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].Frequency_of_Journal__c === 'None' ){
                        errorFlag = false;
                    errorString.push( ' Please pick  Frequency of Journal value for  '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if( this.dataToBeDisplayed[key].Date_Initial_Search_Started__c === ''){
                    errorFlag = false;
                    errorString.push( '  Please Enter Date Initial Search Started for'+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].Date_Last_Journal_Search_was_Performed__c === ''){
                        errorFlag = false;
                    errorString.push( ' Please Enter Date_Last Journal Search was Performed for'+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].Active__c === 'None' ){
                    errorFlag = false;
                    errorString.push( ' Please pick Active value for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                
                if(  this.dataToBeDisplayed[key].isInactiveError === true ){
                    errorFlag = false;
                    errorString.push( ' Inactive since? cannot be in the future for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].DateLastJournalSearchwasPerformedError === true ){
                    errorFlag = false;
                    errorString.push( ' Date Last Journal Search was Performed-cannot be in the future for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].OtherJournalError === true ){
                    errorFlag = false;
                    errorString.push( ' Other Journal Frequency (Specify) cannot be empty as Other has been selected from the Frequency of Journal for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].Inactive_since__c === '' && this.dataToBeDisplayed[key].Active__c === 'No'){
                    errorFlag = false;
                    errorString.push( ' Inactive since? cannot be empty, as No has been selected from the Active? field for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].DueDateError === true ){
                    errorFlag = false;
                    errorString.push( ' Date Next Journal Search is Due cannot be in the past for '+this.dataToBeDisplayed[key].Name );
                    break;
                }

                if(  this.dataToBeDisplayed[key].commentLengthError === true ){
                    errorFlag = false;
                    errorString.push( ' Charactor length should be under 255  on QPPV LPS Comments for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                if(  this.dataToBeDisplayed[key].otherlengthError === true ){
                    errorFlag = false;
                    errorString.push( ' Charactor length should be under 255  on Other Journal Frequency Specify for '+this.dataToBeDisplayed[key].Name );
                    break;
                }
                
            }

        }
        
        if( this.dataToBeAdded && this.dataToBeAdded.length > 0 ){
            if( errorFlag ){
		this.disabled = true;
                addEventJournalToLRProjectOverview({ dataToBeInserted:this.dataToBeAdded, LR_Project_Overview:this.LR_Project_Overview_ID }).then(result=>{
                    if(result === 'Success'){
                        this.noCountryError = false;
                        this.showToast( 'Successfully Created',JSON.stringify(result),'success' );
                        window.open("/"+this.LR_Project_Overview_ID,'_self');
                    }else{
			this.disabled = true;
                        this.noCountryError = false;
                        console.log('error '+JSON.stringify(result))
                        this.showToast( 'Error Occured!',JSON.stringify(result),'error' );
                    }
                }).catch(error=>{
		    this.disabled = false;
                    this.noCountryError = false;
                    console.log('error '+JSON.stringify(result))
                    this.showToast( 'Error Occured!',JSON.stringify(error),'error' );
                })
            }
            else{
                if( errorString.length > 0 ){
                    this.noCountryError = false;
                    for( let error in  errorString){
                        this.showToast( 'Error Occured!',errorString[error],'error' );
                    }
                }
            }
        }else{
            this.noCountryError = false;
            this.showToast( 'Error Occured!','Please Select a Journals Main Catalogue','error' );
            
        }
    }
    /**
     * Method is used to handle Error 
     */
    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    Cancel() {
        window.open("/" + this.LR_Project_Overview_ID, '_self');
    }
    nextLoad() {
        this.loaded = true;

        for (let key in this.dataToBeDisplayed) {
            this.displayMainJCIds.push(this.dataToBeDisplayed[key].Id);
        }
        this.getMainJournalCatalogue(this.selectedCountries, this.displayMainJCIds);
        this.isMore = true;
    }
}
