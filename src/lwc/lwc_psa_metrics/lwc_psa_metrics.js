/*
Component for the PSA Metrics Page

/lightning/n/PSA_Project_Metric?c__Project={!pse__Proj__c.Id}
*/
import { LightningElement, api, track, wire } from 'lwc'
import { loadStyle } from 'lightning/platformResourceLoader'
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'
import { getPicklistValues } from 'lightning/uiObjectInfoApi'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getUrlVars } from 'c/urlVars'
import { refreshApex } from '@salesforce/apex'

import globalFlexipageStyles from '@salesforce/resourceUrl/PSAGlobalFlexipageStyles'

import getMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.getMetrics'
import getActivePsaMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.getActivePsaMetrics'
import hideSelectedMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.hideSelectedMetrics'
import addSelectedMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.addSelectedMetrics'
import getCurrentAssignedResources from '@salesforce/apex/CNT_PSA_ProjectMetric.getCurrentAssignedResources'
import cloneProjectMetric from '@salesforce/apex/CNT_PSA_ProjectMetric.cloneProjectMetric'
import retireMetrics from '@salesforce/apex/CNT_PSA_ProjectMetric.retireMetrics'
import populateProtocolName from '@salesforce/apex/CNT_PSA_ProjectMetric.populateProtocolName';
import hasRDSPermission from '@salesforce/apex/CNT_PSA_ProjectMetric.hasRDSPermission';
import getProjectFrequencyOptions from '@salesforce/apex/CNT_PSA_ProjectMetric.getProjectFrequencyOptions';


// function to grab the project id from page url
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
// metric columns to render
const metricColumns = [
  { label: 'Metric Name', fieldName: 'metricUrl', sortable: true, initialWidth:300, type: 'url', typeAttributes: { label: { fieldName: 'metricName' }}} ,
  { label: 'Service Line', fieldName: 'serviceLineUrl', sortable: true, initialWidth: 150, type: 'url',  typeAttributes: { label: { fieldName: 'serviceLineName' } }},
  { label: 'Service', fieldName: 'serviceUrl', sortable: true, initialWidth: 100, type: 'url', typeAttributes: { label: { fieldName: 'serviceName' } } },
  { label: 'Frequency', fieldName: 'frequency', sortable: true },
  { label: 'Location', fieldName: 'location', sortable: true },
  { label: 'Protocol', fieldName: 'protocolName', sortable: true },
  { label: 'Category', fieldName: 'category', sortable: true },
  { label: 'Red Threshold', fieldName: 'redThreshold', sortable: true },
  { label: 'Amber Threshold', fieldName: 'amberThreshold', sortable: true },
  { label: 'Green Threshold', fieldName: 'greenThreshold', sortable: true },
  //{ label: 'Effective Date', fieldName: 'effectiveDate', sortable: true, type: 'date-local' },
  { label: 'Retired Date', fieldName: 'retiredDate', sortable: true, type: 'date-local' },
  { label: 'Client Facing', fieldName: 'clientFacing', sortable: true, type: 'boolean'},
  { label: 'Non Standard', fieldName: 'nonStandard', sortable: true, type: 'boolean'},
  //{ label: 'Source', fieldName: 'sourceSystem', sortable: true, type: 'text' },
  //{ label: 'Automated', fieldName: 'automated', sortable: true, type:'boolean' },
  //{ label: 'Order', fieldName: 'order', sortable: true, type: 'number' },
]
// Edit / Clone buttons for metric columns
const metricColumnEditCloneButtons = [
  { type: 'button-icon',
    initialWidth: '25',
    typeAttributes: {
      name: 'metric_edit_details',
      iconName: 'utility:edit',
      variant: 'bare',
      title: 'Edit Record'
    },
  },
  { type: 'button-icon',
    initialWidth: '25',
    typeAttributes: {
      name: 'metric_clone_details',
      iconName: 'utility:copy',
      variant: 'bare',
      title: 'Clone Record'
    }
  }
]

// metric colums, with edit actions, rendered when not read only
let metricColumnEditActions = metricColumnEditCloneButtons.concat(metricColumns)
// !! swap out client facing (read only column with editable button-icon column)
let cfIndex = metricColumnEditActions.findIndex(f => f.label === 'Client Facing')
if (cfIndex !== -1) {
  metricColumnEditActions[cfIndex] = {
    label: 'Client Facing',
    type: 'button-icon',
    typeAttributes: {
      name: 'toggleClientFacing',
      iconName: { fieldName: 'clientFacingIconName' },
      disabled: { fieldName: 'clientFacingDisabled' },
      variant: 'bare'
    },
  }
}

// list of fields for editing / cloning
const metricEditFields = [
  'Metric_Name__c', 'Location__c',
  'Effective_Date__c', 'Protocol_ID__c',
  'Retired_Date__c', 'Red_Threshold__c',
  'Source_System__c', 'Amber_Threshold__c',
  'Client_Facing__c', 'Green_Threshold__c',
  'Automated__c', 'Order__c','Tower__c',
  'Roll_up_Required__c','GRA_Requirements__c']

// PSA Metric columns (pop-up for add metrics)
const psaMetricColumns = [
  { label: 'Name', fieldName: 'psaMetricUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'name' } } },
  { label: 'Tower', fieldName: 'tower', sortable: true, type: 'text' },
  { label: 'Account', fieldName: 'accountUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'accountName' } } },
  { label: 'Unique ID', fieldName: 'uniqueID', sortable: true, type: 'text' },
  { label: 'Service Line', fieldName: 'serviceLineUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'serviceLineName' } } },
  { label: 'Source', fieldName: 'sourceSystem', sortable: true, type: 'text' },
  { label: 'Retired Date', fieldName: 'retiredDate', sortable: true, type: 'text' },
  { label: 'Description', fieldName: 'description', sortable: true },
  { label: 'Non-Standard', fieldName: 'nonStandard', sortable: true, type: 'boolean'},
  { label: 'Client Facing', fieldName: 'clientFacing', sortable: true, type: 'boolean'},
  { label: 'GRA Requirement', fieldName: 'graRequirement', sortable: true }
]

// assigned resource columns
const resourceColumns = [
  { label: 'Resource Name', fieldName: 'resourceName', sortable: true},
  { label: 'Resource Location', fieldName: 'resourceLocation', sortable: true },
  { label: 'Resource Dashboard Role', fieldName: 'oversightDashboardRole', sortable: true },
  { label: 'Active Status', fieldName: 'active', type: 'boolean', sortable: true }
]
// Edit action for assigned resource
const resourceColumneEditButton = [{
  type: 'button-icon',
  initialWidth: '25',
  typeAttributes: {
    name: 'assign_resource_edit_details',
    iconName: 'utility:edit',
    variant: 'bare',
    title: 'Edit Record'
  }
}]
// assigned resource columns, with edit actions (for non read only!)
const resourceColumnEditActions = resourceColumneEditButton.concat(resourceColumns)

export default class Lwc_psa_metrics extends LightningElement {
  @api isReadOnly // set in app page builder!

  @track viewFilters = true;

  @track filterProtocolName = '';
  @track filterProtocolOptions = [];
  @track filterCategory = '';

  @track projectId = getPageUrlProjectId()
  @track projectUrl = `/lightning/r/${this.projectId}/view`
  @track showSpinner = false

  @track projectMetrics
  @track activePsaMetrics
  @track currentAssignedResources
  @track filterRetired = false;
  @track filterClientFacing = true;
  @track filterNonStandard = false;
  @track filterClientFacing = false;
  @track filterAll = false;
  @track filterServiceLine = ''
  @track filterFrequency = ''
  @track projectFrequencyOptions = []
  @track wiredFreqLabels = {};
  @track uniqueIdSet =[];
  @track showPageSpinner = false;
  wiredProjectFrequencyOptions
  
  @track state = {
    metricColumns: metricColumns,
    metricTableLoadingState: true,
    metricSortedBy: null,
    metricSortedDirection: 'asc',
    showAddMetricModal: false,
    psaMetricColumns: psaMetricColumns,
    psaMetricTableLoadingState: true,
    psaMetricSortedBy: null,
    psaMetricSortedDirection: 'asc',
    showEditAssignedResourceModal: false,
    currentResourceTableLoadingState: true,
    currentResourceColumns: resourceColumns,
    currentResourceSortedBy: null,
    currentResourceSortedDirection: 'asc',
    hasSelectedRows: false,
    showRetireMetricsModal: false,

    // maintain for edit record!
    showEditMetricModal: false,
    editRecordId: null,
    editRecordRow: null,
    editRecordName: null,
    editObjectApiName: null
  }

  // --- edit metrics
  @track selectedEditMetric
  @track isEditMetricLoaded = false

  // --- retire metrics
  @track retireDate
  @track uncheckOptions = []

  // maintain editing metric fields....for use when cloning a project metric
  @track metricFieldsToEdit = []
  buildMetricFieldsToEdit () {
    let selectedRow = this.state.editRecordRow
    let allowClientFacing = selectedRow.psaMetricClientFacing

    this.metricFieldsToEdit = metricEditFields.map(f => {
      let fieldDisabled = false
      let ovalue = null // value to use for client-facing...so we don't need to refresh! use from page!
      if (f === 'Client_Facing__c') {
        ovalue = selectedRow.clientFacing
        fieldDisabled = !allowClientFacing // disable client facing edit ... unless allowed
      }
      return {
        fieldName: f,
        fieldValue: null,
        ovalue: ovalue,
        fieldDisabled: fieldDisabled
      }
    })
  }

  // --- edit assign resources!!!
  @track selectedAssignedResource
  @track isResourceLoaded = false
  @track isNotRDSAdmin = false;
  isDropdownOpen = false;
  @track options = [];
  @track filteredOptions =[];
  @track selectedValues = [];
  isReset = false;
  @track defultOptions =[];
  /* retrieves the underlying lwc helper */
  get lwcHelper() {
    return this.template.querySelector('c-lwc_helper')
  }

  get retiredDateOptions(){
    return [
      {value: '', label: 'All'},
      {value: 'Yes', label: 'Yes'},
      {value: 'No', label: 'No'}
    ];
  }
  get nonStandardOptions(){
    return [
      {value: '', label: 'All'},
      {value: 'true', label: 'Non-Standard'},
      {value: 'false', label: 'Standard'}
    ];
  }
  get clientFacingOptions(){
    return [
      {value: '', label: 'All'},
      {value: 'true', label: 'Yes'},
      {value: 'false', label: 'No'}
     ];
  }

  get sourceSystemOptions(){
    return [
      {value: '', label: ''},
      {value: 'PSA', label: 'PSA'},
      {value: 'Other', label: 'Other'}
    ];
  }

  get towerOptions(){
    return [
      {value: '', label: 'All'},
      {value: 'LCS', label: 'LCS'},
      {value: 'FSP', label: 'FSP'}
     ];
  }

  /* Lifecycle hooks */
  connectedCallback() {
    Promise.all([
      loadStyle(this, globalFlexipageStyles + '/PSAGlobalFlexipageStyles.css'),
    ]).then(() => {
      // use the columns with edit/clone actions when not is read only!
      if (!this.isReadOnly) {
        this.state.metricColumns = metricColumnEditActions
        this.state.currentResourceColumns = resourceColumnEditActions
      }
    })

    populateProtocolName({rdsProjId: this.projectId}).then((result) => {
      let map1 = new Map();
      map1 = [{label:'None',value: ''}];
      let protocolOpn = result.map(r => { return {label: r, value: r}});      
      this.filterProtocolOptions = [...map1, ...protocolOpn];
      this.filterProtocolName = this.filterProtocolOptions[0].value;
  })
  .catch(error => {
      console.log('Err occurred');
  });
  

  hasRDSPermission().then((result) => {
    
    if(result === true){
      this.isNotRDSAdmin = false;
    }else{
      this.isNotRDSAdmin = true;
    }
  })
  .catch(error => {
    console.log('Err occurred',error);
  });

  this.isReset = false;
    
  }

  /* set up picklist data for filter */
  @wire(getObjectInfo, {objectApiName: 'PSA_Metric__c'})
  psaMetricInfo;

  @wire(getPicklistValues, {recordTypeId: '$psaMetricInfo.data.defaultRecordTypeId', fieldApiName: 'PSA_Metric__c.Source_System__c'})
  sourceSystemPicklistValues;

  /* retrieve and expose the underlying project info */
  @wire(getRecord, {
    recordId: '$projectId',
    fields: ['pse__Proj__c.Id', 'pse__Proj__c.Name']
  }) psaProject

  get projectName() {
    return getFieldValue(this.psaProject.data, 'pse__Proj__c.Name')
  }

  // true when the page spinner should render
  get showPageSpinner () {
    return this.showSpinner || this.state.metricTableLoadingState
  }

  get hideRetireMetricButton(){
    if(this.state.hasSelectedRows === true && this.isNotRDSAdmin === false){
      return true;
    } else {
      return false;
    }
  }
  /* wire up get project metrics */
  wiredProjectMetrics // wired result so it can be refreshed programmatically
  @wire(getMetrics, { projectId: '$projectId', protocolName: '$filterProtocolName', frequency: '$filterFrequency', serviceLineId: '$filterServiceLine', retired: '$filterRetired', clientFacing: '$filterClientFacing', all : '$filterAll', category: '$filterCategory', nonStandard: '$filterNonStandard' })
  wiredGetMetrics (result) {
    this.wiredProjectMetrics = result
    
    if (result.error) {
      this.state.metricTableLoadingState = false
      this.handleError(result.error)
    } else {
      if (result.data && result.data.records) {
        this.state.metricTableLoadingState = true
        this.projectMetrics = result.data.records
        
        // apply sort on refresh!
        if (this.state.metricSortedBy !== null) {
          this.projectMetrics = this.sortData(this.projectMetrics, this.state.metricSortedBy, this.state.metricSortedDirection)
        }
        this.state.metricTableLoadingState = false
      } else {
        this.state.metricTableLoadingState = false
      }
    }
    this.uniqueIdSet = [...this.defultOptions];
  }

  /* wire up get active psa metrics */
  wiredActivePsaMetrics // wired result so it can be refreshed programmatically
  @wire(getActivePsaMetrics)
  wiredGetActivePsaMetrics (results) {
    let optionList = [];
    let allOptionShowList =[]
    this.wiredActivePsaMetrics = results
    this.state.psaMetricTableLoadingState = false
    if (results.error) {
      this.handleError(results.error)
    } else {
      if (results.data && results.data.records) {
        this.activePsaMetrics = results.data.records
        for(let i in results.data.records){
          optionList.push({label : results.data.records[i].uniqueID, value : results.data.records[i].uniqueID , checked : false});
          allOptionShowList.push(results.data.records[i].uniqueID);
        }
        this.uncheckOptions = [...optionList];
        this.options = [...optionList];
        this.filteredOptions = [...optionList];
        this.defultOptions = [...allOptionShowList];
        this.uniqueIdSet = [...allOptionShowList];
        this.isReset = false;
        this.filterPsaMetrics()
      }
    }
  }

  /* wire up getCurrentAssignedResources */
  wiredCurrentAssignedResources
  @wire(getCurrentAssignedResources, { projectId: '$projectId' })
  wiredGetCurrentAssignedResources (results) {
    this.wiredCurrentAssignedResources = results
    this.state.currentResourceTableLoadingState = false
    if (results.error) {
      this.handleError(results.error)
    } else {
      if (results.data && results.data.records) {
        this.currentAssignedResources = results.data.records

        // apply sort on refresh!
        if (this.state.currentResourceSortedBy !== null) {
          this.currentAssignedResources = this.sortData(this.currentAssignedResources, this.state.currentResourceSortedBy, this.state.currentResourceSortedDirection)
        }

      }
    }
  }

  /* Refresh manual metrics component if it is a defined component! */
  refreshManualMetrics() {
    let psaMetricsManual = this.template.querySelector('c-lwc_psa_metrics-manual')
    if (psaMetricsManual && psaMetricsManual !== null) {
      psaMetricsManual.refresh()
    }
  }

  /* listen for refresh events from manual metrics component */
  onManualMetricsRefresh() {
    refreshApex(this.wiredProjectMetrics)
  }

  /* button action to refresh all apex */
  refreshAll () {
    // this.lwcHelper.showModalSpinner({heading:'Refreshing', message:''})
    this.showSpinner = true
    Promise.all([
      refreshApex(this.wiredProjectMetrics), // refresh wired metric data!
      refreshApex(this.wiredActivePsaMetrics),  // refresh active psa metrice
      refreshApex(this.wiredCurrentAssignedResources),  // refresh current assigned resource
      refreshApex(this.wiredProjectFrequencyOptions)
    ]).then(() => {
      this.refreshManualMetrics() // refresh wired manual metrics
      this.showSpinner = false
    }).catch(error => { this.handleError(error, this) })
  }

  // ------------------------------------------------------------
  // filter for psa active metrics
  filterChangeTimeout = null // local timeout, help with waiting for user to end typing before filtering
  @track psaMetricsFilterDescription = null
  @track psaMetricsFilterGRARequirement = null
  @track psaMetricsFilterName = null
  @track psaMetricsFilterServiceLine = null
  @track psaMetricsFilterAccount = null
  @track psaMetricsFilterSourceSystem = null
  @track psaMetricsFilterNonStandard = '';
  @track psaMetricsFilterClientFacing = '';
  @track psaMetricsFilterRetiredDate = '';
  @track psaMetricsFilterTower = '';
  @track filteredActivePsaMetrics
  /*
   * filter active psa metrics based on distinct filter input fields
   */
  filterPsaMetrics () {
    
    
    let data = this.activePsaMetrics
    let filterDesc = this.psaMetricsFilterDescription
    let filterGRA = this.psaMetricsFilterGRARequirement
    let filterName = this.psaMetricsFilterName
    let filterLine = this.psaMetricsFilterServiceLine
    let filterAccount = this.psaMetricsFilterAccount
    let filterSource = this.psaMetricsFilterSourceSystem
    let filterNonStandard = this.psaMetricsFilterNonStandard
    let filterClientFacing = this.psaMetricsFilterClientFacing
    let filterRetiredDate = this.psaMetricsFilterRetiredDate
    let filterTower = this.psaMetricsFilterTower

    // setup regexps to match on field data, leave null when not set or empty
    let reFilterDesc = filterDesc !== null && filterDesc !== '' ? new RegExp(filterDesc, 'i') : null
    let reFilterGRA = filterGRA !== null && filterGRA !== '' ? new RegExp(filterGRA, 'i') : null
    let reFilterName = filterName !== null && filterName !== '' ? new RegExp(filterName, 'i') : null
    let reServiceLine = filterLine !== null && filterLine !== '' ? new RegExp(filterLine, 'i') : null
    let reFilterAccount = filterAccount !== null && filterAccount !== '' ? new RegExp(filterAccount, 'i') : null
    let reFilterSource = filterSource !== null && filterSource !== '' ? new RegExp(filterSource, 'i') : null
    let refilterRetiredDate = filterRetiredDate !== null && filterRetiredDate !== '' ? new RegExp(filterRetiredDate, 'i') : null
    let refilterTower = filterTower !== null && filterTower !== '' ? new RegExp(filterTower, 'i') : null
    //Filter out metrics that are already in use
    let metricsInUse = [];
    for(let pMetric in this.projectMetrics){
      metricsInUse.push(this.projectMetrics[pMetric].psaMetricId);
    }
    if (typeof data !== 'undefined') {
      data = data.filter(item => {
        // match fields when regexp is not null, when regexp/filter input is null..treat as match
        let hasDescriptionMatch = reFilterDesc === null || (item.description || '').match(reFilterDesc)
        let hasRequirementMatch = reFilterGRA === null || (item.graRequirement || '').match(reFilterGRA)
        let hasNameMatch = reFilterName === null || (item.name || '').match(reFilterName)
        let hasLineMatch = reServiceLine === null || (item.serviceLineUrl || '').match(reServiceLine)
        let hasAcctMatch = reFilterAccount === null || (item.accountUrl || '').match(reFilterAccount)
        let hasSourceMatch = reFilterSource === null || (item.sourceSystem || '').match(reFilterSource)
        let notInUse = !metricsInUse.includes(item.id);
        let notUsedUniqueId = this.uniqueIdSet.includes(item.uniqueID) ? true : false;
        let hasNonStandardMatch = filterNonStandard === '' || filterNonStandard === item.nonStandard.toString();
        let hasClientFacingMatch = filterClientFacing === '' || filterClientFacing === item.clientFacing.toString();
        let checkRetiredDate = item.retiredDate != null ? 'Yes' : 'No';
        let hasRetiredDateMatch = refilterRetiredDate === null || (checkRetiredDate || '').match(refilterRetiredDate);
        let hasrefilterTowerMatch = refilterTower === null || (item.tower || '').match(refilterTower);
        // match when all fields match
        return hasDescriptionMatch && hasRequirementMatch && hasNameMatch && hasLineMatch && hasAcctMatch && hasSourceMatch && notInUse && hasNonStandardMatch && hasClientFacingMatch && notUsedUniqueId && hasRetiredDateMatch && hasrefilterTowerMatch
      })
      // render the computed data
      this.filteredActivePsaMetrics = data
    }
  }

  get hasFilteredActivePsaMetrics () {
    return typeof this.activePsaMetrics !== 'undefined' && this.activePsaMetrics !== null && this.activePsaMetrics.length > 0
  }

  /*
   * wraps call to filter in a timeout,
   * to wait for user to stop typing before filtering
   */
  filterPsaMetricsLater () {
    let self = this
    clearTimeout(this.filterChangeTimeout)
    // eslint-disable-next-line
    this.filterChangeTimeout = setTimeout(() => {
      self.filterPsaMetrics()
    }, 500)
  }

  /*
   * handle when a filter input is changed
   */
  handleFilterChange (evt) {
    const fieldName = evt.target.fieldName || evt.target.name
    const value = evt.target.value

    switch (fieldName) {
      case 'Description__c':
        this.psaMetricsFilterDescription = value
        this.filterPsaMetricsLater() // allow user to continue typing
        break

      case 'GRA_Requirements__c':
        this.psaMetricsFilterGRARequirement = value
        this.filterPsaMetricsLater() // allow user to continue typing
        break

      case 'MetricName':
        this.psaMetricsFilterName = value
        this.filterPsaMetricsLater() // allow user to continue typing
        break

      case 'Service_Line__c':
        this.psaMetricsFilterServiceLine = value
        this.filterPsaMetrics() // filter right away when selected / cleared
        break

      case 'Non_Standard__c':
        this.psaMetricsFilterNonStandard = value
        this.filterPsaMetrics() // filter right away when selected / cleared
        break

      case 'Client_Facing__c':
        this.psaMetricsFilterClientFacing = value
        this.filterPsaMetrics() // filter right away when selected / cleared
        break  

      case 'Source_System__c':
        this.psaMetricsFilterSourceSystem = value
        this.filterPsaMetrics() // filter right away when selected / cleared
        break

      case 'AccountId':
        this.psaMetricsFilterAccount = value
        this.filterPsaMetrics()
        break

      case 'clearSourceSystem':
        this.psaMetricsFilterSourceSystem = '';
        this.filterPsaMetrics()
        break;
      case 'UniqueId':
        this.filterPsaMetrics()
        break;  
      case 'retiredDate':
        this.psaMetricsFilterRetiredDate = value
        this.filterPsaMetrics()
        break  
      case 'Tower':
        this.psaMetricsFilterTower = value
        this.filterPsaMetrics()
        break  

      default:
        break
    }
  }
  // ---- end psa metrics data filter
  // ------------------------------------------------------------

  /* retrieves selected project metric rows */
  getProjectMetricSelectedRows () {
    let selectedRows = []
    let elem = this.template.querySelector('lightning-datatable.metric-datatable-container')
    if (elem && elem !== null) {
      selectedRows = elem.getSelectedRows()
    }
    return selectedRows
  }

  /* The method onsort event handler for the project metric data table */
  updateProjectMetricSorting (event) {
    this.projectMetrics = this.sortData(this.projectMetrics, event.detail.fieldName, event.detail.sortDirection)
    this.state.metricSortedBy = event.detail.fieldName
    this.state.metricSortedDirection = event.detail.sortDirection
  }

  /* The method onsort event handler for the psa metric data table */
  updatePsaMetricSorting(event) {
    this.filteredActivePsaMetrics = this.sortData(this.filteredActivePsaMetrics, event.detail.fieldName, event.detail.sortDirection)
    this.state.psaMetricSortedBy = event.detail.fieldName
    this.state.psaMetricSortedDirection = event.detail.sortDirection
  }
  /* The method onsort event handler for the current assigned resources data table */
  updateCurrentResourceSorting(event) {
    this.currentAssignedResources = this.sortData(this.currentAssignedResources, event.detail.fieldName, event.detail.sortDirection)
    this.state.currentResourceSortedBy = event.detail.fieldName
    this.state.currentResourceSortedDirection = event.detail.sortDirection
  }

  /*
   * confirm to update client facing, on ok set field to true
   */
  doHideSelectedMetrics (selectedRows) {

    if (selectedRows && selectedRows.length > 0 && this.isNotRDSAdmin === false) {
      // remove elements
      // selectedRows[0].clientFacing !== true ? 'un' : ''
      let msg = `Are you sure you would like to ${selectedRows[0].clientFacing === true ? 'un' : ''}mark this metric as Client Facing?`
      let self = this
      self.lwcHelper.confirm({ heading: `${selectedRows[0].clientFacing === true ? 'Unmark' : 'Mark'} as Client Facing`, message: msg }).then(
        (ok) => {
          // HANDLE Ok click!
          if (ok) {
            self.showSpinner = true
            // pass selected rows to hide to the Apex endpoint
            hideSelectedMetrics({ selectedMetricsToHide: selectedRows }).then(() => {
              // refresh wired apex calls (little more user friendly!)
              return Promise.all([
                refreshApex(self.wiredProjectMetrics), // refresh wired metric data!
                refreshApex(self.wiredActivePsaMetrics),  // refresh active psa metrice
                refreshApex(self.wiredCurrentAssignedResources),  // refresh current assigned resource
              ])
            }).then(() => {
                self.showSpinner = false
            }).catch(error => { self.handleError(error, self) })
          }
        },
        // eslint-disable-next-line
        (cancel) => {
          // handle when cancel clicked!
        }
      )
    }
  }

  showRetireMetrics () {
    this.onokcallback = () => {
      this.retireSelectedMetrics();
    }

    this.oncancelcallback = () => {
      this.state.showRetireMetricsModal = false;
    }

    this.state.showRetireMetricsModal = true;
  }

  /*
   * confirm to retire metrics and get a date from the user
   */
  retireSelectedMetrics() {
    let selectedRows = this.getProjectMetricSelectedRows();
    //eslint-disable-next-line
    let self = this;
    self.showSpinner = true;
    retireMetrics({retireDate: this.retireDate, metricsToRetire: selectedRows}).then(() => {
      // refresh wired apex calls (little more user friendly!)
      return Promise.all([
        refreshApex(self.wiredProjectMetrics), // refresh wired metric data!
        refreshApex(self.wiredActivePsaMetrics),  // refresh active psa metrice
        refreshApex(self.wiredCurrentAssignedResources),  // refresh current assigned resource
      ])
    }).then(() => {
      self.showSpinner = false
      this.state.showRetireMetricsModal = false;
    }).catch(error => { self.handleError(error, self) })
  }
  
  retireDateChanged (evt){
    this.retireDate = evt.target.value;
  }

  // callbacks for modals!
  onokcallback = undefined
  oncancelcallback = undefined

  /* ok/cancel called by modals! */
  onmodalok(evt) {
    // need to callback...
    if (typeof this.onokcallback !== 'undefined') {
      this.onokcallback(evt)
    }
  }
  onmodalcancel(evt) {
    if (typeof this.oncancelcallback !== 'undefined') {
      this.oncancelcallback(evt)
    }
  }

  /*
   * Add metric / show modal and handle callbacks
   */
  showAddMetric () {
    // # set the action when ok/add is clicked
    this.onokcallback = () => {
      // get selected rows
      let elem = this.template.querySelector('lightning-datatable.psametric-datatable')
      let selectedRows = (elem && elem !== null) ? elem.getSelectedRows() : []

      if (selectedRows && selectedRows.length > 0) {
        this.showSpinner = true
        addSelectedMetrics({ projectId: this.projectId, selectedPSAMetrics: selectedRows }).then(() => {
          this.showSpinner = false
          this.state.showAddMetricModal = false
          this.onokcallback = undefined // clear
          this.oncancelcallback = undefined // clear

          refreshApex(this.wiredProjectMetrics) // refresh wired metric data!
          this.refreshManualMetrics() // refresh wired manual metrics
          refreshApex(this.wiredActivePsaMetrics)  // refresh wired metric data!

          this.lwcHelper.toastSuccess('Metrics have been added!')
        }).catch(error => { this.handleError(error, this) })
      } else {
        this.lwcHelper.toastError('First select items to add')
      }
    }
    // set the action when the cancel / closed buttons are clicked
    this.oncancelcallback = () => {
      this.state.showAddMetricModal = false
      this.onokcallback = undefined // clear
      this.oncancelcallback = undefined // clear
    }

    // show the modal
    this.state.showAddMetricModal = true

    // dynamically set height on modal data table
    // eslint-disable-next-line
    setTimeout(() => {
      let container = this.template.querySelector('.add-metric-modal .psametric-datatable-wrapper')
      let footer = this.template.querySelector('.add-metric-modal .add-metric-modal-footer')
      if (container !== null && footer !== null) {
        let footerTop = footer.offsetTop
        let containerTop = container.offsetTop
        let height = footerTop - containerTop
        height = height > 50 ? height - 20 : height
        container.style.height = `${height}px`
      }
    }, 100)
  }

  /* common sort data
   *
   * {data} - list of data to sort
   * {fieldName} - column / field to sort by
   * {sortDirection} - asc or desc
   */
  sortData (data, fieldName, sortDirection) {
    let order = sortDirection === 'asc' ? 1 : -1
    data = data.slice().sort((a, b) => {
      a = a[fieldName] || ''
      b = b[fieldName] || ''
      return (a === b ? 0 : a > b ? 1 : -1) * order
    })
    return data
  }

  /* common error handler
   */
  handleError (error, self) {
    self = self || this
    let errorMessage = (error && error.body && error.body.message) ? error.body.message : 'Error Occurred'
    self.lwcHelper.toastError(errorMessage)
    self.showSpinner = false
  }

  /* common button onclick handler
   */
  handleClick (event) {
    this.showPageSpinner = true;
    const buttonName = event.target.name
    switch (buttonName) {
      case 'return-to-project':
        break

      case 'add-metric':
        this.showAddMetric()
        break
      
      case 'retire-metrics':
        this.showRetireMetrics()
        break

// TODO: DEPRECATE:
      // case 'hide-metric':
      //   this.hideSelectedMetricRows()
      //   break

      default:
        break
    }
    this.showPageSpinner = false;
  }
  /*
   * handles row actions for data tables
   */
  handleRowAction (event) {
    event.preventDefault()
    event.stopPropagation()

    const actionName = event.detail.action.name
    const row = event.detail.row
    switch (actionName) {
      case 'metric_edit_details':
        this.editOrCloneProjectMetricDetails(row, false)
        break

      case 'metric_clone_details':
        this.editOrCloneProjectMetricDetails(row, true)
        break

      case 'assign_resource_edit_details':
        this.assignResourceEditDetails(row)
        break

      case 'toggleClientFacing':
        this.handleToggleClientFacing(event, row)
        break

      default:
        // eslint-disable-next-line
        break
    }
  }

  /*
   * responds to user selections of one or more rows in the data table
   */
  handleRowSelection (event) {
    const selectedRows = event.detail.selectedRows;
    this.state.hasSelectedRows = (selectedRows != null && selectedRows.length > 0);
  }

  // when toggle client facing button is clicked!
  handleToggleClientFacing (event, row) {
    if (row.psaMetricClientFacing === true) {
      this.doHideSelectedMetrics([row])
    }
  }

  // ---------------------------------------------
  // --- edit metrics
  @track isCreatingClone = false // context (edit or clone!) for project metrics

  /*
   * handles action to edit assigned resource rows
   *  Show the edit assigned resource modal!
   * row - row details
   * isForClone - true when creating a clone copy, false otherwise
   */
  editOrCloneProjectMetricDetails(row, isForClone) {
    this.isCreatingClone = typeof isForClone === 'boolean' ? isForClone : false
    if (row && row.id) {
      this.selectedEditMetric = row

      // # define the action when ok/save is clicked
      this.onokcallback = () => {
        // submit the form...listen for response in success/error events!
        this.showSpinner = true
        // eslint-disable-next-line
        this.template.querySelector('lightning-record-edit-form.edit-metrics').submit()
      }
      // set the action when the cancel / closed buttons are clicked
      this.oncancelcallback = () => {
        this.state.showEditMetricModal = false
        this.state.editRecordId = undefined
        this.state.editRecordName = undefined
        this.state.editObjectApiName = undefined
        this.onokcallback = undefined // clear
        this.oncancelcallback = undefined // clear
        this.selectedEditMetric = undefined // clear
        this.isEditMetricLoaded = false
      }
      // show the edit metric modal
      this.showSpinner = true
      this.state.editRecordRow = row
      this.state.editRecordId = row.id
      this.state.editRecordName = row.name
      this.state.editObjectApiName = 'Project_Metric__c'
      this.buildMetricFieldsToEdit()
      this.state.showEditMetricModal = true
    }
  }

  // When error occurs submitting edit metrics form!
  onEditMetricError() {
    this.showSpinner = false
  }

  // When edit record saved on success!
  onEditRecordSuccess(evt) {
    // hide spinner, refersh apex, close modal, clear callbacks
    refreshApex(this.wiredProjectMetrics)  // refresh
    this.showSpinner = false
    this.state.showEditMetricModal = false
    this.state.editRecordId = undefined
    this.state.editRecordName = undefined
    this.state.editObjectApiName = undefined
    this.onokcallback = undefined // clear
    this.oncancelcallback = undefined // clear
    this.selectedEditMetric = undefined // clear
    this.isEditMetricLoaded = false
    if (evt.type === 'success') {
      this.lwcHelper.toastSuccess('Record Updated!')
    }
  }

  // when an edit / clone metric field is changed...update local fields
  handleEditMetricChange(evt) {
    const fieldName = evt.target.fieldName
    const value = evt.target.value
    if (typeof fieldName !== 'undefined') {
      // maintain for clone!
      let fldToEdit = this.metricFieldsToEdit.find((f) => {
        return f.fieldName === fieldName
      })
      if (typeof fldToEdit !== 'undefined' && fldToEdit !== null) {
        fldToEdit.fieldValue = value
      }
    }
  }

  // action to clone the edit metric detail
  cloneEditMetric () {
    this.showSpinner = true
    cloneProjectMetric({ projectMetricId: this.state.editRecordId, fieldValues: this.metricFieldsToEdit }).then(results => {
      if (typeof results !== 'undefined') {
        this.onEditRecordSuccess({type:'success'})
      }
    }).catch(error => { this.handleError(error, this) })
  }

  // event fired when the data to edit is loaded
  onEditRecordLoad(event) {
    // reset values for cloneing!
    this.metricFieldsToEdit.forEach(m => {
      m.fieldValue = null
    })
    // write loaded values to metricFieldsToEdit containter (to use when 'cloning')
    if (event.detail.records && event.detail.records[this.state.editRecordId]) {
      let fields = event.detail.records[this.state.editRecordId].fields
      Object.keys(fields).forEach(key => {
        let value = fields[key] ? fields[key].value : null
        let fldToEdit = this.metricFieldsToEdit.find((f) => {
          return f.fieldName === key
        })
        if (typeof fldToEdit !== 'undefined' && fldToEdit !== null) {
          fldToEdit.fieldValue = value
        }
      })
    }
    if (!this.isEditMetricLoaded) { this.showSpinner = false }
    this.isEditMetricLoaded = true
  }

  // indicator for edit assigned resource that an item is selected and data has been loaded
  get showEditRecordForm() {
    return this.selectedEditMetric && this.isEditMetricLoaded
  }

  // --- end edit metrics
  // ---------------------------------------------

  // ---------------------------------------------
  // --- edit assign resources!!!
  /*
   * handles action to edit assigned resource rows
   *  Show the edit assigned resource modal!
   */
  assignResourceEditDetails (row) {
    if (row && row.id) {
      this.selectedAssignedResource = row
      // -- setup to render modal!
      // # set the action when ok/add is clicked
      this.onokcallback = () => {
        // submit the form...listen for response in success/error events!
        this.showSpinner = true
        // eslint-disable-next-line
        this.template.querySelector('lightning-record-edit-form.assigned-resources').submit()
      }
      // set the action when the cancel / closed buttons are clicked
      this.oncancelcallback = () => {
        this.state.showEditAssignedResourceModal = false
        this.state.editRecordId = undefined
        this.state.editRecordName = undefined
        this.state.editObjectApiName = undefined
        this.onokcallback = undefined // clear
        this.oncancelcallback = undefined // clear
        this.selectedAssignedResource = undefined // clear
        this.isResourceLoaded = false
      }
      // show the edit assignment modal
      this.showSpinner = true
      this.state.editRecordId = row.id
      this.state.editRecordName = row.name
      this.state.editObjectApiName = 'pse__Assignment__c'
      this.state.showEditAssignedResourceModal = true
    }
  }
  // When error occurs submitting assigned resource form!
  onAssignResourceError () {
    this.showSpinner = false
  }
  // When assigned resource edit record saved on success!
  onAssignResourceSuccess(evt) {
    // hide spinner, refersh apex, close modal, clear callbacks
    refreshApex(this.wiredCurrentAssignedResources)  // refresh
    this.showSpinner = false
    this.state.showEditAssignedResourceModal = false
    this.state.editRecordId = undefined
    this.state.editRecordName = undefined
    this.state.editObjectApiName = undefined
    this.onokcallback = undefined // clear
    this.oncancelcallback = undefined // clear
    this.selectedAssignedResource = undefined // clear
    this.isResourceLoaded = false
    if (evt.type === 'success') {
      this.lwcHelper.toastSuccess('Record Updated!')
    }
  }
  // event fired when the data to edit is loaded
  onAssignResourceLoad () {
    if (!this.isResourceLoaded) { this.showSpinner = false }
    this.isResourceLoaded = true
  }
  // indicator for edit assigned resource that an item is selected and data has been loaded
  get showAssignedResourceForm () {
    return this.selectedAssignedResource && this.isResourceLoaded
  }
  // --- end edit assign resource methods
  // ---------------------------------------------

  // filter
  toggleFilter () {
    this.viewFilters = !this.viewFilters
  }

  get hasLoadedData () {
    let rtn = true
    if (!this.showPageSpinner && this.projectMetrics && this.projectMetrics.length <= 0) {
      rtn = false
    }
    return rtn
  }
  handleProtocolNameChange(event){
    if (this.filterProtocolName !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterProtocolName = event.detail.value
    }
  }

  handleRetiredMetricChange(event){
    if(this.filterRetired !== event.target.checked){
      //this.manualMetricTableLoadingState = true
      this.filterRetired = event.target.checked
    }
    if(this.filterRetired){
      this.filterAll = false;
    }
  }

  handleNonStandardMetricChange(event){
    if(this.filterNonStandard !== event.target.checked){
       this.filterNonStandard = event.target.checked
    }
    if(this.filterNonStandard){
      this.filterAll = false;
    }
  }


  handleClientFacingMetricChange(event){
    if(this.filterClientFacing !== event.target.checked){
       this.filterClientFacing = event.target.checked
    }
    if(this.filterClientFacing){
      this.filterAll = false;
    }
  }

  handleAllMetricChange(event){
    if(this.filterAll !== event.target.checked){
      this.filterAll = event.target.checked;
    }
    if(this.filterAll){
      this.filterRetired = false;
      this.filterNonStandard = false;
      this.filterClientFacing = false;
    }
  }

  handleCategoryChange(event){
    if(this.filterCategory !== event.detail.value){
      //this.manualMetricTableLoadingState = true
      this.filterCategory = event.detail.value
    }
  }

  @track serviceLineFilterLoaded = false

  // when service line record data is loaded
  serviceLineFilterChangeLoad () {
    this.serviceLineFilterLoaded = true
    this.setVisibility(`.serviceMetricFilter`, this.serviceLineFilterLoaded)
  }

  // utility to add / remove slds-hide class by querySelector
  setVisibility (querySelector, show) {
    let elem = this.template.querySelector(querySelector)
    if (typeof elem !== 'undefined' && elem !== null) {
      elem.classList[show === true ? 'remove' : 'add']('slds-hide')
    }
  }

  // bind service line filter value!
  serviceLineFilterChange (event) {
    // is this right? ['0'] ??  (set value from ['0'] or clear on input change!)
    if (event.detail.value) {
      if (event.detail.value['0'] && this.filterServiceLine !== event.detail.value['0']) {
        //this.manualMetricTableLoadingState = true
        this.filterServiceLine = event.detail.value['0']
      } else if (this.filterServiceLine !== '') {
        //this.manualMetricTableLoadingState = true
        this.filterServiceLine = ''
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

  // bind filter frequency filter value!
  frequencyFilterChange(event) {
    if (this.filterFrequency !== event.detail.value) {
      this.manualMetricTableLoadingState = true
      this.filterFrequency = event.detail.value
    }
  }

    get selectedLabels() {
        return this.selectedValues.length ? this.selectedValues.join(', '): ' Select Unique ID';
    }

    toggleDropdown() {
      this.isDropdownOpen = !this.isDropdownOpen;
    }
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        this.filteredOptions = this.options.filter(option =>
        option.label.toLowerCase().includes(searchTerm)
      );
    }
    handleCheck(event) {
      this.isReset = true;
      this.showPageSpinner = true;
      const value = event.target.dataset.id;
        const updatedOptions = this.options.map(option => {
          if (option.value === value) {
              option.checked = !option.checked;
              }
          return option;
        });
        this.options = updatedOptions;
        this.filteredOptions = updatedOptions;
        this.selectedValues = updatedOptions
        .filter(option => option.checked)
        .map(option => option.label);
        this.uniqueIdSet = [];
        for(let option in this.filteredOptions){
          if(this.filteredOptions[option].checked == true){
            this.uniqueIdSet.push(this.filteredOptions[option].value);
          }
        }  
        if(this.uniqueIdSet.length == 0){
          this.isReset = false;
          this.uniqueIdSet = [...this.defultOptions];
        }
        this.filterPsaMetrics ()
        setTimeout(() => {
          this.showPageSpinner = false;
       }, 2000);
      } 

    resetUniqueIds(){

      this.showPageSpinner = true;
      let updatefilterOption =[];
      for(let i in this.uncheckOptions){
          updatefilterOption.push({
            label: this.uncheckOptions[i].label,
            value: this.uncheckOptions[i].value,
            checked: false
        });
      }
      this.filteredOptions = [...updatefilterOption];
      this.options = [...updatefilterOption];
      this.selectedValues = [];
      this.uniqueIdSet = [...this.defultOptions];
      this.filterPsaMetrics ()
      setTimeout(() => {
        this.showPageSpinner = false;
        this.isReset = false;
     }, 2000);
    }
}
