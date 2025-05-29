import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import METRIC_OBJECT from '@salesforce/schema/PSA_Metric__c';
import METRIC_FREQUENCY_FIELD from '@salesforce/schema/PSA_Metric__c.Frequency__c';
import { getUrlVars } from 'c/urlVars';
import { refreshApex } from '@salesforce/apex';

import getManualMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.getManualMetrics';
import getManualMetricsHistory from '@salesforce/apex/CNT_PSA_ProjectMetric.getManualMetricsHistory';
import saveMetricActual from '@salesforce/apex/CNT_PSA_ProjectMetric.saveMetricActual';

import getProjectFrequencyOptions from '@salesforce/apex/CNT_PSA_ProjectMetric.getProjectFrequencyOptions';
import populateProtocolName from '@salesforce/apex/CNT_PSA_ProjectMetric.populateProtocolName';

/* represents the rendered metric actual row
*/
class MetricActualWrapper {
  type
  className
  fieldName // will be date for saving comments/qty
  label
  value
  location
  isUrl
  typeFieldValue
  quantity
  editQuantity
  editNumerator
  editDenominator
  showPercentage
  showDenominator
  outputType
  denominatorIsIgnored
  calculationRequired
  isMonthlyType
  comments
  editComments
  projectId
  projectMetricId
  projectMetricActualId
  psaMetricId
  numeratorLabel
  denominatorLabel
  constructor(type, className, fieldName, label, location) {
    this.type = type
    this.className = className
    this.fieldName = fieldName
    this.label = label
    this.location = location
  }
}
/* grabs project id from url params */
const getPageUrlProjectId = () => {
  let projId = null
  try {
    projId = getUrlVars().c__Project
  } catch (e) {
    // eslint-disable-next-line
    console.error('ERROR', e)
  }
  return projId
}
/* fixed columns for metric manuals */
const baseManualMetricColumns = [
  { label: 'Metric Name', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'metricUrl', sortable: false, type: 'url', typeAttributes: { label: { fieldName: 'metricName' } } },
  { label: 'Service Line', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'serviceLineUrl', sortable: false, type: 'url', typeAttributes: { label: { fieldName: 'serviceLineName' } } },
  { label: 'Last reviewed Month', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'lastReviewedMonth', sortable: false },
  { label: 'Frequency', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'frequency', sortable: false },
  { label: 'Location', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'location', sortable: false },
  { label: 'Protocol', className: 'slds-is-resizable monthly-item-class dv-dynamic-width', fieldName: 'protocolName', sortable: false }
]

const FREQUENCY_MONTHLY = 'Monthly'
const FREQUENCY_QUARTERLY = 'Quarterly'

/* history columns */
const metricActualsHistoryColumns = [
  { label: 'Description', fieldName: 'parentMetricName', sortable: false, type: 'text' },
  { label: 'Period', fieldName: 'parentDate', sortable: false, type: 'date-local' },
  { label: 'Comment', fieldName: 'newValue', sortable: false, type: 'text' },
  { label: 'Entered By', fieldName: 'createdByName', sortable: false, type: 'text' },
  { label: 'Entered On', fieldName: 'createdDate', sortable: false, type: 'dateTime' }
]

/*
 * Component for entering manual metrics on a project
 */
export default class Lwc_psa_metricsManual extends LightningElement {

    isAsc = false;
    isDsc = false;
    isMetricNameSort = false;
    isProtocolSort = false;
    isFrequencySort = false;
    isLocationSort = false;
    isServiceLineSort = false;
    isLastReviewedMonthSort = false;
    error;

    sortedDirection = 'asc';
    sortedColumn;

  @api isReadOnly // set in app page builder on parent!
  // locals
  wiredManualMetrics
  wiredManualMetricsHistory
  wiredProjectFrequencyOptions
  today = new Date()

  // project id
  @track projectId = getPageUrlProjectId()

  //Metric Object info

  // metrics
  @track manualMetrics
  @track manualMetricTableLoadingState = true
  @track manualMetricColumns = baseManualMetricColumns
  @track computedManualMetrics

  // filter
  @track viewFilters = true
  @track filterFrequency = ''
  @track filterServiceLine = ''
  @track filterRangeStartLabel = 'Range Start (Go Live Date)'
  @track filterRangeEndLabel = 'Range End (Close Out Date)'
  @track filterRangeStart = (new Date(this.today.getFullYear(), this.today.getMonth(), 1).toISOString().split('T')[0])
  @track filterRangeEnd = (new Date(this.today.getFullYear(), this.today.getMonth(), 1).toISOString().split('T')[0])
  @track filterFrequencyOptions = [
    { value: FREQUENCY_MONTHLY, selected: this.filterFrequency === FREQUENCY_MONTHLY },
    { value: FREQUENCY_QUARTERLY, selected: this.filterFrequency === FREQUENCY_QUARTERLY }
  ]
  @track filterLocation = ''
  @track filterLastReviewedMonth = ''
  @track filterProtocolName = '';
  @track filterProtocolOptions = [];

  // project frequency options (for filter!)
  @track projectFrequencyOptions = []
  @track wiredFreqLabels = {};

  // history
  @track historyColumns = metricActualsHistoryColumns
  @track historyTableLoadingState = true
  @track historyRecords
  @track viewHistory = false

  // Comments modal!
  @track showMericsActualModal = false
  @track showModalSpinner = false
  @track selectedMetricActual = null

  @track calcResultValue
  @track errorMsgFlag = false;
  @track errorMsg = '';
  @track psaMetricsFilterLastReviewedMonth = '';

  get lastReviewedMonthOptions(){
    return [
      {value: '', label: 'All'},
      {value: 'Yes', label: 'Yes'},
      {value: 'No', label: 'No'}
    ];
  }
  // expose a refresh method parent components can call
  @api refresh() {
    //this.manualMetricTableLoadingState = true
    Promise.all([
      refreshApex(this.wiredManualMetrics),
      refreshApex(this.wiredManualMetricsHistory),
      refreshApex(this.wiredProjectFrequencyOptions)
    ]).then(() => {
      // this.manualMetricTableLoadingState = false
    }).catch(error => { this.handleError(error, this) })
  }

  connectedCallback() {
    populateProtocolName({ rdsProjId: this.projectId }).then((result) => {
      let map1 = new Map();
      map1 = [{ label: 'None', value: '' }];
      let protocolOpn = result.map(r => { return { label: r, value: r } });
      this.filterProtocolOptions = [...map1, ...protocolOpn];
      this.filterProtocolName = this.filterProtocolOptions[0].value;

    })
      .catch(error => {
        console.log('Err occurred');
      });
  }

  handleProtocolNameChange(event) {
    if (this.filterProtocolName !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterProtocolName = event.detail.value
    }
  }

  /* retrieve PSA_Metric object info and field labels */

  @wire(getObjectInfo, { objectApiName: METRIC_OBJECT })
  metricObjectInfo;
  @wire(getPicklistValues, { recordTypeId: '$metricObjectInfo.data.defaultRecordTypeId', fieldApiName: METRIC_FREQUENCY_FIELD })
  wiredGetMetricFrequencyPicklistValues(results) {
    if (results.error) {
      let errorMessage = (results.error && results.error.body && results.error.body.message) ? results.error.body.message : 'Error Occurred'
      this.lwcHelper.toastError(errorMessage)
    } else if (results.data) {
      // eslint-disable-next-line
      for(let val of results.data.values){
        // eslint-disable-next-line
        this.wiredFreqLabels[val.value] = val.label;
      }
    }
  }


  /* retrieve project go live and close out dates for initial range-start / range end */
  @wire(getRecord, {
    recordId: '$projectId',
    fields: ['pse__Proj__c.Id', 'pse__Proj__c.Name', 'pse__Proj__c.Close_Out_Date__c', 'pse__Proj__c.Go_Live_Date__c']
  })
  wiredGetRecordProject(results) {
    if (results.error) {
      let errorMessage = (results.error && results.error.body && results.error.body.message) ? results.error.body.message : 'Error Occurred'
      this.lwcHelper.toastError(errorMessage)
    } else if (results.data) {
      let goLiveDate = getFieldValue(results.data, 'pse__Proj__c.Go_Live_Date__c')
      let closeOutDate = getFieldValue(results.data, 'pse__Proj__c.Close_Out_Date__c')

      this.filterRangeStart = goLiveDate
      this.filterRangeEnd = closeOutDate

      // trigger checking filtered dates!
      this.localCheckFilterDates = true
    }
  }
  localCheckFilterDates = false
  renderedCallback() {
    if (this.localCheckFilterDates) {
      this.localCheckFilterDates = false
      this.checkFilterDates()
    }
  }

  // wire up getManualMetrics
  @wire(getManualMetrics, { projectId: '$projectId', frequency: '$filterFrequency', serviceLineId: '$filterServiceLine', location: '$filterLocation', rangeStart: '$filterRangeStart', rangeEnd: '$filterRangeEnd', protocolName: '$filterProtocolName' , lastReviewedMonth : '$filterLastReviewedMonth' })
  wiredGetManualMetrics(results) {
    this.wiredManualMetrics = results
    if (results.error) {
      let errorMessage = (results.error && results.error.body && results.error.body.message) ? results.error.body.message : 'Error Occurred'
      this.lwcHelper.toastError(errorMessage)
      this.manualMetricTableLoadingState = false
    } else {
      if (results.data && results.data.records) {
        this.manualMetrics = results.data.records
        this.manualMetricTableLoadingState = false

        // grab the monthly columns
        let monthlyColumns = (results.data.items && results.data.items.monthlyColumns) ? results.data.items.monthlyColumns : []

        this.initializeManualMetrics(monthlyColumns)
        this.applyRowData()
      }
    }
  }

  // wire up getProjectFrequencyOptions
  @wire(getProjectFrequencyOptions, {projectId: '$projectId'})
  wiredGetProjectFrequencyOptions(results) {
    this.wiredProjectFrequencyOptions = results
    if (results.error) {
      let errorMessage = (results.error && results.error.body && results.error.body.message) ? results.error.body.message : 'Error Occurred'
      this.lwcHelper.toastError(errorMessage)
    } else {
      if (results.data && results.data.items && results.data.items.projectFrequencyOptions) {
        this.projectFrequencyOptions = results.data.items.projectFrequencyOptions
        if (this.filterFrequency === '' && this.projectFrequencyOptions.length > 0) {
          this.filterFrequency = this.projectFrequencyOptions[0]
        }
      }
    }
  }
  // build project-frequenchy-option combobox options!
  get projFreqOptions() {
    let projFreqOptions = []
    let data = this.projectFrequencyOptions
    // Get labels
    if (typeof data !== 'undefined' && data !== null && data.length >0) {
      projFreqOptions = data.map(r => { return {label: this.getProjFreqOptionLabel(r), value: r}})
    }
    return projFreqOptions
  }

  getProjFreqOptionLabel(value){
    if(typeof this.wiredFreqLabels[value] != 'undefined'){
      return this.wiredFreqLabels[value];
    }
    return value;
  }

  /*
   * builds out table columns, injecting dynamic monthly columns into base
   */
  initializeManualMetrics(monthlyColumns) {
    // inject monthly columns into table
    if (typeof this.manualMetrics !== 'undefined' && typeof baseManualMetricColumns !== 'undefined') {
      let manualColumns = [...baseManualMetricColumns]
      monthlyColumns.forEach(col => {
        manualColumns.push({ label: col.label, fieldName: col.fieldName, type: 'button', isMonthly: true, className: 'slds-is-resizable monthly-item-class dv-dynamic-width'})
      })
      this.manualMetricColumns = manualColumns
    }
  }

  checkFilterDates () {
    let isValid = true
    let rangeEnd = this.template.querySelector(".filter-range-end")
    let rangeStart = this.template.querySelector(".filter-range-start")
    let startValue = (typeof rangeStart !== 'undefined' && typeof rangeStart.value !== 'undefined') ? rangeStart.value : null
    let endValue = (typeof rangeEnd !== 'undefined' && typeof rangeEnd.value !== 'undefined') ? rangeEnd.value : null

    if (typeof startValue !== 'undefined' && startValue !== null && typeof endValue !== 'undefined' && endValue !== null && endValue !== '' && startValue > endValue) {
      rangeEnd.setCustomValidity('Range End should occur after the Range Start')
      isValid = false
    } else {
      rangeEnd.setCustomValidity('')
    }
    rangeEnd.reportValidity()
    return isValid
  }

  // computed manual metrics - rendered
  applyRowData() {
    let rows = this.manualMetrics
    let columns = this.manualMetricColumns

    this.computedManualMetrics = rows.map(r => {
      return columns.map(c => {
        let metricActualWrapper = new MetricActualWrapper(c.type, c.className, c.fieldName, c.label, c.location)
        let value = r[c.fieldName]

        // inject / flatten monthly records for rendering in page
        if (c.isMonthly) {
          let metricActuals = r.metricActuals ? r.metricActuals : []
          let metActual = metricActuals.find(f => { return f.recordDateKey === c.fieldName })
          if (metActual) {
            metricActualWrapper.isMonthlyType = true // inject here...for use in ui
            metricActualWrapper.quantity = metActual.quantity
            metricActualWrapper.editQuantity = metActual.quantity
            metricActualWrapper.editNumerator = metActual.numerator
            metricActualWrapper.editDenominator = metActual.denominator
            metricActualWrapper.comments = metActual.comments
            metricActualWrapper.editComments = metActual.comments
            metricActualWrapper.projectMetricActualId = metActual.id
            metricActualWrapper.projectId = r.projectId
            metricActualWrapper.projectMetricId = r.id
            metricActualWrapper.psaMetricId = r.psaMetricId
            metricActualWrapper.showPercentage = r.showPercentage
            metricActualWrapper.showDenominator = r.showDenominator
            metricActualWrapper.outputType = r.outputType
            metricActualWrapper.denominatorIsIgnored = r.denominatorIsIgnored
            metricActualWrapper.calculationRequired = r.calculationRequired
            metricActualWrapper.numeratorLabel = r.numeratorLabel
            metricActualWrapper.denominatorLabel = r.denominatorLabel
          } else {
            // default to 0...so we can click on something to add comments
            metricActualWrapper.isMonthlyType = true
            metricActualWrapper.editQuantity = 0
            metricActualWrapper.editNumerator = 0
            metricActualWrapper.editDenominator = 0
            metricActualWrapper.quantity = ''
            metricActualWrapper.comments = ''
            metricActualWrapper.editComments = ''
            metricActualWrapper.projectMetricActualId = null
            metricActualWrapper.projectId = r.projectId
            metricActualWrapper.projectMetricId = r.id // looping over project metrics
            metricActualWrapper.psaMetricId = r.psaMetricId
            metricActualWrapper.showPercentage = r.showPercentage
            metricActualWrapper.showDenominator = r.showDenominator
            metricActualWrapper.outputType = r.outputType
            metricActualWrapper.denominatorIsIgnored = r.denominatorIsIgnored
            metricActualWrapper.calculationRequired = r.calculationRequired
            metricActualWrapper.numeratorLabel = r.numeratorLabel
            metricActualWrapper.denominatorLabel = r.denominatorLabel
          }
        }

        // work in the non-monthly columns (supports url and text!)
        if (value) {
          metricActualWrapper.value = value
          if (c.type === 'url' && c.typeAttributes && c.typeAttributes.label && c.typeAttributes.label.fieldName) {
            metricActualWrapper.isUrl = true // inject here..for use in ui
            metricActualWrapper.typeFieldValue = r[c.typeAttributes.label.fieldName]
          }
        }

        if (c.fieldName === 'frequency'){
          let prettyValue = this.getProjFreqOptionLabel(value)
          if(typeof prettyValue != 'undefined') {
          metricActualWrapper.value = prettyValue;
          }
        }

        return metricActualWrapper
      })
    })
    // add row index
    for (let cidx=0; cidx < this.computedManualMetrics.length; cidx++) {
      this.computedManualMetrics[cidx].rowIndex = cidx
    }
  }

  // The method onsort event handler for the manual metric data table
  // updateManualMetricSorting(event) {
  //   // TODO...move sortData   to helper ?
  //   // this.manualMetrics = this.sortData(this.manualMetrics, event.detail.fieldName, event.detail.sortDirection)
  //   this.state.manualMetricSortedBy = event.detail.fieldName
  //   this.state.manualMetricSortedDirection = event.detail.sortDirection
  // }

  // retrieves the underlying lwc helper
  get lwcHelper() {
    return this.template.querySelector('c-lwc_helper')
  }

  // when monthly item is clicked!
  // grab the selected element and open the edit modal
  onMonthlyClick (event) {
    // grab event dataset info to lookup the selected metric actual
    let projId = event.currentTarget.dataset.projectId
    let projMetricId = event.currentTarget.dataset.projectMetricId
    let psaMetricId = event.currentTarget.dataset.psaMetricId
    let calcReqd = event.currentTarget.dataset.showDenominator
    let outputType = event.currentTarget.dataset.outputType
    let monthlyField = event.currentTarget.dataset.columnField
    let rowIndex = event.currentTarget.dataset.rowIndex

    // lookup selected metric actual!
    let metActual = this.computedManualMetrics[rowIndex].find(f => {
      return f.projectId === projId && f.projectMetricId === projMetricId && f.psaMetricId === psaMetricId && f.fieldName === monthlyField
    })
    if (metActual && metActual !== null) {
      this.selectedMetricActual = metActual
      // setup for %
      if (calcReqd) {
        this.calcResultValue = this.selectedMetricActual.editQuantity // setup for %
        // let numerator = !isNaN(this.selectedMetricActual.editNumerator) ? parseFloat(this.selectedMetricActual.editNumerator) : 0
        // let denominator = !isNaN(this.selectedMetricActual.editDenominator) ? parseFloat(this.selectedMetricActual.editDenominator) : 0
        // let percentResult = 0
        // if (denominator !== 0) {
        //   percentResult = numerator / denominator
        // }
        // this.percentResult = percentResult
      }

    }
    // render modal
    this.performCalculation();
    this.showMericsActualModal = true
    this.showModalSpinner = false
  }
  // on comments change - maintain bindings between selected metric actual and the lighting text area
  onMetricActualCommentsChange (event) {
    this.selectedMetricActual.editComments = event.detail.value
  }
  // on quantity change - maintain bindings between selected metric actual and the lighting number field
  onMetricActualFieldChange (event) {
    const fieldName = event.target.fieldName || event.target.name
    switch (fieldName) {
      case 'Quantity__c':
        this.selectedMetricActual.editQuantity = event.detail.value
        break
      case 'Numerator__c':
        this.selectedMetricActual.editNumerator = event.detail.value
        this.performCalculation()
        break
      case 'Denominator__c':
        this.selectedMetricActual.editDenominator = event.detail.value
        this.performCalculation()
        break
      default:
        break
    }
  }

  performCalculation(){
    switch (this.selectedMetricActual.outputType){
      case 'Percent':
      case 'Inverse Percent':
        this.calculatePercent();
        break;
      case 'Days':
      case 'Hours':
      case 'Minutes':
      case 'Seconds':
        this.calculateInteger();
        break;
      default:
        this.calculateDecimal();
    }
  }

  calculateDecimal (){
    let selectedMetricActual = this.selectedMetricActual
    let editNumerator = selectedMetricActual.editNumerator
    let editDenominator = selectedMetricActual.editDenominator
    let editQuantity = selectedMetricActual.editQuantity

    let numerator = !isNaN(editNumerator) ? parseFloat(editNumerator) : 0
    let denominator = !isNaN(editDenominator) ? parseFloat(editDenominator) : 0
    let value = !isNaN(editQuantity) ? parseFloat(editQuantity) : 0

    if (denominator !== 0) {
      value = numerator / denominator // grab results
    }
    this.selectedMetricActual.editQuantity = parseFloat(value.toFixed(3))
    this.calcResultValue = parseFloat(value.toFixed(3))
  }

  calculateInteger (){
    let selectedMetricActual = this.selectedMetricActual
    let editNumerator = selectedMetricActual.editNumerator
    let editDenominator = selectedMetricActual.editDenominator
    let editQuantity = selectedMetricActual.editQuantity

    let numerator = !isNaN(editNumerator) ? parseFloat(editNumerator) : 0
    let denominator = !isNaN(editDenominator) ? parseFloat(editDenominator) : 0
    let value = !isNaN(editQuantity) ? parseFloat(editQuantity) : 0

    if (denominator !== 0) {
      value = numerator / denominator // grab results
    }
    this.selectedMetricActual.editQuantity = Math.ceil(value) 
    this.calcResultValue = Math.ceil(value)
  }

  calculatePercent () {
    let selectedMetricActual = this.selectedMetricActual
    let editNumerator = selectedMetricActual.editNumerator
    let editDenominator = selectedMetricActual.editDenominator
    let editQuantity = selectedMetricActual.editQuantity

    let numerator = !isNaN(editNumerator) ? parseFloat(editNumerator) : 0
    let denominator = !isNaN(editDenominator) ? parseFloat(editDenominator) : 0
    let value = !isNaN(editQuantity) ? parseFloat(editQuantity) : 0
    
    if (denominator !== 0) {
      value = numerator / denominator // grab results
      value = value * 100             // as a percent...?
    }
    this.selectedMetricActual.editQuantity = parseFloat(value.toFixed(3))
    this.calcResultValue = parseFloat(value.toFixed(3))
  }

  // on modal cancel - reset 'edit' fields close modal
  onMetricsActualModalCancel () {
    this.selectedMetricActual.editComments = this.selectedMetricActual.comments || '' // reset editing comments since not saved!
    this.selectedMetricActual.editQuantity = this.selectedMetricActual.quantity
    this.showMericsActualModal = false
    this.selectedMetricActual = null
    if(this.errorMsgFlag == true){
      this.errorMsgFlag = false;
    }
  }
  // on modal save - apply edit fields and store
  onMetricsActualModalSave () {
    var origQuantity = this.selectedMetricActual.quantity;
    var origComment = this.selectedMetricActual.comments;
    var origNmntr = this.selectedMetricActual.numerator;
    var origDmntr = this.selectedMetricActual.denominator;
    // update comments and quantity from  edit comments and edit quantity  and save!
    this.selectedMetricActual.comments = this.selectedMetricActual.editComments
    this.selectedMetricActual.quantity = this.selectedMetricActual.editQuantity
    this.selectedMetricActual.numerator = this.selectedMetricActual.editNumerator
    this.selectedMetricActual.denominator = this.selectedMetricActual.editDenominator

    // eslint-disable-next-line
    

    // build payload to save
    let payload = {
      id             : this.selectedMetricActual.projectMetricActualId,
      projectId      : this.selectedMetricActual.projectId,
      projectMetricId: this.selectedMetricActual.projectMetricId,
      psaMetricId    : this.selectedMetricActual.psaMetricId,
      recordDateKey  : this.selectedMetricActual.fieldName,
      quantity       : this.selectedMetricActual.quantity,
      numerator      : this.selectedMetricActual.numerator,
      denominator    : this.selectedMetricActual.denominator,
      comments       : this.selectedMetricActual.comments
    }

    // eslint-disable-next-line

    this.showModalSpinner = true
    saveMetricActual({ wrapper: payload}).then(results => {
      if (results && results.isSuccess) {
        // write record id back to underlying record
        if (results.items && results.items.recordId) {
          this.selectedMetricActual.projectMetricActualId = results.items.recordId
        }
        // refersh history!
        refreshApex(this.wiredManualMetricsHistory)

        this.showModalSpinner = false
        this.showMericsActualModal = false
        this.calcResultValue = null;
      }
    }).catch(error => {
      let errorMessage = (error && error.body && error.body.message) ? error.body.message : 'Error Occurred'
      if (errorMessage.includes('Service line project \'End Date\' is in the past.')) {
        this.errorMsgFlag = true;
        this.errorMsg = 'Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.';
        this.showModalSpinner = false;
        this.selectedMetricActual.editComments = origComment; // reset editing comments since not saved!
        this.selectedMetricActual.editQuantity = origQuantity;
        this.selectedMetricActual.editNumerator = origNmntr;
        this.selectedMetricActual.editDenominator = origDmntr;

        this.selectedMetricActual.comments = origComment;
        this.selectedMetricActual.quantity = origQuantity;
        this.selectedMetricActual.numerator = origQuantity;
        this.selectedMetricActual.denominator = origDmntr;
      } else if (errorMessage.includes('Service line project \'Start Date\' is in the future.')) {
        this.errorMsgFlag = true;
        this.errorMsg = 'Service line project \'Start Date\' is in the future. Please update the service line project \'Start Date\' and try again.';
        this.showModalSpinner = false;
        this.selectedMetricActual.editComments = origComment; // reset editing comments since not saved!
        this.selectedMetricActual.editQuantity = origQuantity;
        this.selectedMetricActual.editNumerator = origNmntr;
        this.selectedMetricActual.editDenominator = origDmntr;

        this.selectedMetricActual.comments = origComment;
        this.selectedMetricActual.quantity = origQuantity;
        this.selectedMetricActual.numerator = origQuantity;
        this.selectedMetricActual.denominator = origDmntr;
      } else if (errorMessage.includes('There is no service line on this metrics, please link with a service line.')) {
        this.errorMsgFlag = true;
        this.errorMsg = 'There is no service line on this metrics, please link with a service line.';
        this.showModalSpinner = false;
        this.selectedMetricActual.editComments = origComment; // reset editing comments since not saved!
        this.selectedMetricActual.editQuantity = origQuantity;
        this.selectedMetricActual.editNumerator = origNmntr;
        this.selectedMetricActual.editDenominator = origDmntr;

        this.selectedMetricActual.comments = origComment;
        this.selectedMetricActual.quantity = origQuantity;
        this.selectedMetricActual.numerator = origQuantity;
        this.selectedMetricActual.denominator = origDmntr;
      } else if (errorMessage.includes('The Protocol \'Stop Date\' is in the past.')) {
        this.errorMsgFlag = true;
        this.errorMsg = 'The Protocol \'Stop Date\' is in the past. Please update the RDS Protocol \'Stop Date\' and try again.';
        this.showModalSpinner = false;
        this.selectedMetricActual.editComments = origComment; // reset editing comments since not saved!
        this.selectedMetricActual.editQuantity = origQuantity;
        this.selectedMetricActual.editNumerator = origNmntr;
        this.selectedMetricActual.editDenominator = origDmntr;

        this.selectedMetricActual.comments = origComment;
        this.selectedMetricActual.quantity = origQuantity;
        this.selectedMetricActual.numerator = origQuantity;
        this.selectedMetricActual.denominator = origDmntr;
      }
      else {
        this.lwcHelper.toastError(errorMessage);
      }
    })
  }

  // --------------------------------------------------------------------------
  // filter
  toggleFilter () {
    this.viewFilters = !this.viewFilters
  }

  get hasLoadedData () {
    let rtn = true
    if (!this.manualMetricTableLoadingState && this.computedManualMetrics && this.computedManualMetrics.length <= 0) {
      rtn = false
    }
    return rtn
  }

  get disabledInputField () {
    return this.showModalSpinner || this.isReadOnly
  }

  @track serviceLineFilterLoaded = false

  // when service line record data is loaded
  serviceLineFilterChangeLoad () {
    this.serviceLineFilterLoaded = true
    this.setVisibility(`.serviceMetricFilter`, this.serviceLineFilterLoaded)
  }

  @track locationFilterLoaded = false
  locationFilterChangeLoad() {
    this.locationFilterLoaded = true
    this.setVisibility(`.locationFilter`, this.locationFilterLoaded)
  }

  // utility to add / remove slds-hide class by querySelector
  setVisibility (querySelector, show) {
    let elem = this.template.querySelector(querySelector)
    if (typeof elem !== 'undefined' && elem !== null) {
      elem.classList[show === true ? 'remove' : 'add']('slds-hide')
    }
  }


  // bind filter frequency filter value!
  frequencyFilterChange(event) {
    if (this.filterFrequency !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterFrequency = event.detail.value
    }
  }

  // bind filter location value
  locationFilterChange (event) {
    if (this.filterLocation !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterLocation = event.detail.value
    }
  }

  lastReviewedMonthFilterChange (event) {
    if (this.filterLastReviewedMonth !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterLastReviewedMonth = event.detail.value
    }
  }

  // bind service line filter value!
  serviceLineFilterChange (event) {
    // is this right? ['0'] ??  (set value from ['0'] or clear on input change!)
    if (event.detail.value) {
      if (event.detail.value['0'] && this.filterServiceLine !== event.detail.value['0']) {
        this.manualMetricTableLoadingState = true
        this.filterServiceLine = event.detail.value['0']
      } else if (this.filterServiceLine !== '') {
        this.manualMetricTableLoadingState = true
        this.filterServiceLine = ''
      }
    }
  }
  // bind range start date values!
  rangeStartFilterApplied (event) {
    if (this.checkFilterDates()) {
      if (this.filterRangeStart !== event.detail.value) {
        this.filterRangeStart = event.detail.value
        if (this.filterRangeStart > this.filterRangeEnd) {
          this.filterRangeEnd = this.filterRangeStart
        }
        this.manualMetricTableLoadingState = true
      }
    }
  }
  // bind range end date values!
  rangeEndFilterApplied (event) {
    if (this.checkFilterDates()) {
      if (this.filterRangeEnd !== event.detail.value) {
        this.filterRangeEnd = event.detail.value
        if (this.filterRangeEnd < this.filterRangeStart) {
          this.filterRangeStart = this.filterRangeEnd
        }
        this.manualMetricTableLoadingState = true
      }
    }
  }


  // -- history
  get hasHistoryRecords () {
    return typeof this.historyRecords !== 'undefined' && this.historyRecords.length && this.historyRecords.length > 0
  }

  toggleHistory() {
    this.viewHistory = !this.viewHistory
  }

  // wire up getManualMetrics
  @wire(getManualMetricsHistory, { projectId: '$projectId', frequency: '$filterFrequency', serviceLineId: '$filterServiceLine', location: '$filterLocation', rangeStart: '$filterRangeStart', rangeEnd: '$filterRangeEnd'})
  wiredGetManualMetricsHistory(results) {
    this.wiredManualMetricsHistory = results
    if (results.error) {
      let errorMessage = (results.error && results.error.body && results.error.body.message) ? results.error.body.message : 'Error Occurred'
      this.lwcHelper.toastError(errorMessage)
      this.historyTableLoadingState = false
    } else {
      if (results.data && results.data.records) {
        this.historyRecords = results.data.records
        this.historyTableLoadingState = false
      }
    }
  }
  sortData(sortColumnName) {
    
      // check previous column and direction
      if (this.sortedColumn === sortColumnName) {
          this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
      } 
      else {
          this.sortedDirection = 'asc';
      }

      // check arrow direction
      if (this.sortedDirection === 'asc') {
          this.isAsc = true;
          this.isDsc = false;
      } 
      else {
          this.isAsc = false;
          this.isDsc = true;
      }

      // check reverse direction
      let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

      this.sortedColumn = sortColumnName;
      if(this.sortedDirection =='asc'){
        // sort the data
        this.computedManualMetrics= JSON.parse(JSON.stringify(this.computedManualMetrics)).sort((a, b) => {
          a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
          b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

          return a > b ? 1 * isReverse : -1 * isReverse;
      });;
      }else{
        this.computedManualMetrics= JSON.parse(JSON.stringify(this.computedManualMetrics)).sort((b, a) => {
          a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
          b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

          return b > a ? -1 * isReverse :1 * isReverse;
        });;
      }
      
      for (let cidx=0; cidx < this.computedManualMetrics.length; cidx++) {
        this.computedManualMetrics[cidx].rowIndex = cidx
      }
  }
  metricNameSort(event) {
    this.isMetricNameSort = true;
    this.isProtocolSort = false;
    this.isFrequencySort = false;
    this.isLocationSort = false;
    this.isServiceLineSort = false;
    this.isLastReviewedMonthSort = false;

    this.sortData(event.currentTarget.dataset.id);
  }
  sortServiceLine(event) {
    this.isMetricNameSort = false;
    this.isProtocolSort = false;
    this.isFrequencySort = false;
    this.isLocationSort = false;
    this.isServiceLineSort = true;
    this.isLastReviewedMonthSort = false;

    this.sortData(event.currentTarget.dataset.id);
  }

  sortLastReviewedMonth(event) {
    this.isMetricNameSort = false;
    this.isProtocolSort = false;
    this.isFrequencySort = false;
    this.isLocationSort = false;
    this.isServiceLineSort = false;
    this.isLastReviewedMonthSort = true;

    this.sortData(event.currentTarget.dataset.id);
  }

  sortFrequency(event) {
    this.isMetricNameSort = false;
    this.isProtocolSort = false;
    this.isFrequencySort = true;
    this.isLocationSort = false;
    this.isServiceLineSort = false;
    this.isLastReviewedMonthSort = false;

    this.sortData(event.currentTarget.dataset.id);
  }

  sortProtocol(event) {
    this.isMetricNameSort = false;
    this.isProtocolSort = true;
    this.isFrequencySort = false;
    this.isLocationSort = false;
    this.isServiceLineSort = false;
    this.isLastReviewedMonthSort = false;

    this.sortData(event.currentTarget.dataset.id);
  }

  sortLocation(event) {
    this.isMetricNameSort = false;
    this.isProtocolSort = false;
    this.isFrequencySort = false;
    this.isLocationSort = true;
    this.isServiceLineSort = false;
    this.isLastReviewedMonthSort = false;

    this.sortData(event.currentTarget.dataset.id);
  }
 
}
