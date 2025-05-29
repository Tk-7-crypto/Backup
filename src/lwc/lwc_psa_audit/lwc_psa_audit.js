import { LightningElement, api, wire, } from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation'
import { loadScript, loadStyle } from 'lightning/platformResourceLoader'
import { DataTableHelper, ShowToast, NavHelper, buildErrorMessage, groupByField, generateUniqueId } from 'c/utils'
import { refreshApex } from '@salesforce/apex'

import { subscribe, unsubscribe, onError } from 'lightning/empApi'

import getSobjectDetails from '@salesforce/apex/CNT_PSA_AuditLog.getSobjectDetails'
import getAuditLogsByRecordId from '@salesforce/apex/CNT_PSA_AuditLog.getAuditLogsByRecordId'
import saveReplayedEvents from '@salesforce/apex/CNT_PSA_AuditLog.saveReplayedEvents'
import getAuditLogsByReplayId from '@salesforce/apex/CNT_PSA_AuditLog.getAuditLogsByReplayId'

import globalFlexipageStyles from "@salesforce/resourceUrl/PSAGlobalFlexipageStyles"
import xlsx from '@salesforce/resourceUrl/SheetJs'
import Jszip from '@salesforce/resourceUrl/Jszip'

const DEFAULT_AUDIT_COLUMNS = [
  { label: 'Time', fieldName: 'logTime', type: 'date', initialWidth: 175, sortable: true, typeAttributes: { month: '2-digit', day: '2-digit', year: "numeric", hour: '2-digit', minute: '2-digit' } },
  { label: 'User', fieldName: 'userName', type: 'text', initialWidth: 150, sortable: true },
  { label: 'Operation', fieldName: 'operation', type: 'text', initialWidth: 100, sortable: true, cellAttributes: { class: { fieldName: 'format' } } }
]

/**
 * psa audit component
 */
export default class Lwc_psa_audit extends NavigationMixin(LightningElement) {
  recordId                  // underlying record id to view audit logs
  auditLogRecordId          // record id for wired audit log query set when initializing sobject details
  auditLogLastModifiedDateFields
  showPageSpinner = false
  showSidbarSpinner = false
  auditColumns              // Columns for the data
  auditData = []            // data we format and render
  auditDataForExport =[]    // data we export / keep separate ... support legacy audit logs
  formattedResults  = []    // data we render (and format and sort)
  auditRecordLabel          // label of record
  auditUIFields             // default fields  to render from Audit UI fieldset
  auditAvailableFields      // list of avaiable fieldds to audit ??
  filterAvailableFieldText  // text value to fitler availiable fields
  tableSortedBy
  tableSortedDirection
  renderSideBarColumns = false
  xlsxInitialized = false
  isRecordCDCEnabled = false //  true when entry exists in apex control table
  showAuditRecordDetails = false
  auditRecordDetailsName

  renderAuditLogsUI = true // allow for multiple templates

  // replay event!
  replayEventSubscription
  resubscribeTries = 0
  showReplaySpinner = false
  @api auditRecordObjApiName

  /*
   *
      c:lwc_psa_audit render-replay-events="true" audit-record-obj-api-name={this.auditRecordObjApiName}
   *   - when defined renders replay event template!
   */
  _renderReplayEvents
  @api
  set renderReplayEvents(value) {
    if (typeof value !== 'undefined') {
      this._renderReplayEvents = true
      this.renderAuditLogsUI = false
    }
  }
  get renderReplayEvents() {
    return this._renderReplayEvents
  }


  /**
   * Lifecycle hook, when connected  apply our  global flexipage styles and resize event listener
   */
  connectedCallback() {
    Promise.all([
      loadStyle(this, globalFlexipageStyles + "/PSAGlobalFlexipageStyles.css")
    ])
    if (this.renderAuditLogsUI) {
      window.addEventListener('resize', this.adjustDatatableContainierHeight);
    }
  }

  /**
   * Lifecycle hook, when disconnected remove event listener
   */
  disconnectedCallback() {
    if (this.renderAuditLogsUI) {
      window.removeEventListener('resize', this.adjustDatatableContainierHeight)
    }
  }

  /**
   * Lifecycle hook called when componenet is rendered, ensures xlsx.js is initialized
   */
  renderedCallback() {
    if (this.renderAuditLogsUI) {
      this.initializeXLSX()
      this.adjustDatatableContainierHeight()
    }
  }

  /**
   * Ensures the xlsx is initialized
   */
  initializeXLSX () {
    if (this.xlsxInitialized) {
      return
    }
    this.xlsxInitialized = true
    Promise.all([
      loadScript(this, xlsx + '/xlsx.js'),
      loadScript(this, Jszip + '/jszip.js')
    ]).then(() => {
      this.xlsxInitialized = true
    }).catch(error => {
      ShowToast.error(this, buildErrorMessage(error))
    })
  }


  /**
   * Grab page reference and fetch eligible for billing records
   */
  @wire(CurrentPageReference)
  wiredCurrentPageReference(result) {
    if (result.error) {
      ShowToast.error(this, buildErrorMessage(result.error))
    } else {
      if (result && result.state && result.state.c__recordId) {
        if (typeof this.recordId === 'undefined' || this.recordId === null) {
          this.recordId = result.state.c__recordId
        }
      }
    }
  }

  /**
   * grab record details
   */
  @wire(getSobjectDetails, { recordId: "$recordId" })
  wireGetSobjectDetails(result) {
    this.wiredGetSobjectDetails = result
    if (result.data &&  result.data.items) {
      // set to pull in last  modified date
      this.auditRecordObjApiName = result.data.items.AUDIT_RECORD_NAME
      // this.auditRecordChangeEvent = this.auditRecordObjApiName.replace('__c', '__ChangeEvent')
      this.auditLogLastModifiedDateFields = `${this.auditRecordObjApiName}.LastModifiedDate`
      // ## TODO..check to see if Name field is provided and pull it back???

      this.auditLogRecordId = this.recordId
      this.auditUIFields = result.data.items.Audit_UI
      this.auditRecordLabel = result.data.items.AUDIT_RECORD_LABEL
      this.isRecordCDCEnabled = result.data.items.AUDIT_RECORD_IS_CDC_ENABLED || false
      this.showAuditRecordDetails = result.data.items.SHOW_AUDIT_RECORD_DETAILS
      if(result.data.items.SHOW_AUDIT_RECORD_DETAILS === true){
        this.auditRecordDetailsName = result.data.items.AUDIT_RECORD_DETAILS_NAME;
      }
      if (typeof result.data.items.AVAILABLE_FIELDS !== 'undefined') {
        this.auditAvailableFields = result.data.items.AVAILABLE_FIELDS.map(r => {
          return {
            // fieldName: r.apiName.toLowerCase(),
            key: generateUniqueId(),
            fieldName: r.apiName,
            fieldLabel: r.label,
            include: false // auditUIFields.inidexOf(r) > -1 ? true : false
          }
        })
        // inject replay id into list when cdc is enabled!
        if (this.isRecordCDCEnabled) {
//   columns.unshift({ label: 'Replay Id', fieldName: 'replayId', type: 'text', initialWidth: 100, sortable: true })
          this.auditAvailableFields.unshift({
            fieldName: 'replayId',
            fieldLabel: 'Replay Id',
            include: false
          })
        }

      }
    } else if (result.error) {
      ShowToast.error(this, buildErrorMessage(result.error))
    }
  }

	/**
   * retrieve related audit record info
   * auditLogLastModifiedDateFields = ['LastModifiedDate']
   */
  recordLastModifiedDate
  @wire(getRecord, {
    recordId: '$auditLogRecordId',
    fields: '$auditLogLastModifiedDateFields'
  })
  wiredGetAuditDetailRecord(result) {
    if (result.error) {
      ShowToast.error(this, buildErrorMessage(result.error))
    } else if (result.data) {
      this.recordLastModifiedDate = result.data.fields.LastModifiedDate.value
    }
  }

  /**
   * Grab audit logs
   */
  @wire(getAuditLogsByRecordId, { recordId: "$auditLogRecordId"})
  auditLogList(result) {
    this.wiredGetAuditLogsByRecordId = result;
    if (result.data &&  result.data.records) {
      this.ungroupedResults = result.data.records.map(r => { return { ...r } })
      // console.log('ungroupedResults?', this.ungroupedResults)
      this.buildDatatableAuditLog(this.ungroupedResults)
    } else if (result.error) {
      this.showPageSpinner = false
      ShowToast.error(this, buildErrorMessage(result.error))
    }
  }

  // --------------------------------------------------------------------------

  /**
   * Build label for return button / link
   */
  get returnAuditLogLabel() {
    return `Return to ${this.auditRecordLabel || 'Record'}`
  }

  /**
   * @return url link to view record
   */
  get recordIdHref() {
    return `/lightning/r/${this.recordId}/view`
  }

  /**
   * Refresh audit logs!
   */
  async refreshAuditLogs () {
    try {
      this.showPageSpinner = true
      await refreshApex(this.wiredGetAuditLogsByRecordId)
    } catch (error) {
      ShowToast.error(this, buildErrorMessage(error))
    } finally {
      this.showPageSpinner = false
    }

  }

  /** list of available fields to render (for filtering!) */
  get auditAvailableFieldsRender() {
    let filteredData = this.auditAvailableFields
    const filterAvailableFieldText = this.filterAvailableFieldText
    if (typeof filterAvailableFieldText !== 'undefined') {
      filteredData = this.auditAvailableFields.filter(f => {
        if (f.fieldName.toLowerCase().indexOf(filterAvailableFieldText.toLowerCase()) > -1) {
          return f
        }
      })
    }
    return filteredData
  }

  /** quick filter field name! */
  handleFilterFieldChange(event) {
    const value = event.detail.value || event.target.value
    this.filterAvailableFieldText = value
  }

  /** Show / hide side bar columns */
  toggleColumnPanel () {
    this.renderSideBarColumns = !this.renderSideBarColumns
  }

  /** Return html class for the column panel button */
  get columnPanelButtonClass() {
    return `slds-button slds-button_icon ${this.renderSideBarColumns ? ' slds-button_icon-brand' : ' slds-button_icon-border-filled '}`
  }

  renderReplay () {
    this.showReplayModal = true
  }

  showReplayModal = false

  closeReplayModal() {
    this.showReplayModal = false
  }

  // --------------------------------------------------------------------------
  //  datatable
  // --------------------------------------------------------------------------

  /**
   * Group records by transaction keys and build datatable audit log!
   * @param {*} dataToBuild
   */
  buildDatatableAuditLog (dataToBuild)  {
    let groupedByTrans = groupByField(dataToBuild, 'transactionKey')
    let auditUiFields = this.auditUIFields
    let auditAvailableFields = this.auditAvailableFields

    // build audit data for export
    let transformedData = []
    let transformedForUI =  []
    Object.keys(groupedByTrans).forEach(transId => {
      let logdata =  { ...groupedByTrans[transId][0] }
      // remove field  and new value from log data
      delete logdata.field
      delete logdata.newValue

      let logdataUI = { ...logdata }

      if (groupedByTrans[transId].length > 0) {
        (groupedByTrans[transId]).forEach(elem => {
          logdata[elem.field] = elem.newValue
          logdataUI[elem.field.toLowerCase()] = elem.newValue //  for ui .. support legacy audit
          logdataUI['replayid'] = elem.replayId
        })
        transformedData.push(logdata)
        transformedForUI.push(logdataUI)

      }
    })
    this.auditDataForExport = transformedData
    this.auditData = transformedForUI

    //  build audit columns  by marking them as included!
    if (typeof auditUiFields !== 'undefined' && auditUiFields.length > 0) {
      auditUiFields.forEach(fld => {
        let availFld =  auditAvailableFields.find(f => { return f.fieldName.toLowerCase() === fld.fieldName.toLowerCase() })
        if (typeof availFld !== 'undefined' && availFld !== null) {
          availFld.include = true
        }
      })
    } else if (typeof auditAvailableFields && auditAvailableFields.length > 0) {
      // ## Set first 10 avaiable fields to render!
      // for (let i=0; i < 10; i++) {
      //   if (auditAvailableFields.length > i) {
      //     auditAvailableFields[i].include =  true
      //   }
      // }
      // ## Set all fields availiable
      auditAvailableFields.forEach(a => { a.include = true})
    }
    this.auditColumns = this.lightningDatatableAuditColumns

    // now apply format and build data to render and sort
    if (typeof this.auditData !== 'undefined') {
      this.formattedResults = this.auditData.map(r => {
        return {
          ...r,
          key: generateUniqueId(), // add a key!
          // field: r.field.toLowerCase(),
          format: (r.operation === 'UPDATE' ? 'slds-text-color_error' : 'slds-text-color_success')
        }
      })
    }
    this.formattedResults = DataTableHelper.sortRecords(this.formattedResults, this.auditColumns, 'logTime', 'ASC')
  }

  /**
   * The method onsort event handler for the datatable
   */
  tableOnSort(event) {
    this.tableSortedBy = event.detail.fieldName
    this.tableSortedDirection = event.detail.sortDirection
    this.formattedResults = DataTableHelper.sortRecords(this.formattedResults, this.auditColumns, this.tableSortedBy, this.tableSortedDirection)
  }

  /**
   * return datatable audit columns based on selected/included fields
   */
  get lightningDatatableAuditColumns () {
    const columnsListToRender = this.auditAvailableFields
    const baseColumns = DEFAULT_AUDIT_COLUMNS
    let columns = [... baseColumns]

    // push replay id when cdc is enabled and  include in selected ?? ???
    // if (this.isRecordCDCEnabled) {
    //   columns.unshift({ label: 'Replay Id', fieldName: 'replayId', type: 'text', initialWidth: 100, sortable: true })
    // }

    if (typeof columnsListToRender !== 'undefined' && columnsListToRender !== null) {
      columnsListToRender.forEach(col => {
        if (col.include === true) {
          columns.push({
            label: col.fieldLabel,
            fieldName: col.fieldName.toLowerCase(),
            type: 'text',
            initialWidth: 150,
            sortable: true
          })
        }
      })
    }
    return columns
  }

  // --------------------------------------------------------------------------
  // sidebar
  // --------------------------------------------------------------------------

  /**
   * when a single column/field is checked to be included or excluded
   */
  handleIncludeCheckbox (event) {
    const targetName = event.target.fieldName || event.target.name
    const eventDetail = event.detail
    const columnsListToRender = this.auditAvailableFields
    if (typeof targetName !== 'undefined' && targetName !== null) {
      let colField = columnsListToRender.find(f => { return f.fieldName.toLowerCase() === targetName.toLowerCase() })
      if (typeof colField !== 'undefined' && colField !== null) {
        colField.include = eventDetail.checked
      }
    }
    this.auditAvailableFields = columnsListToRender
    this.auditColumns = this.lightningDatatableAuditColumns
  }
  /** set included to true or false based on include field */
  checkFields (includeField) {
    this.showSidbarSpinner = true
    const columnsListToRender = this.auditAvailableFieldsRender
    columnsListToRender.forEach(r => {
      r.include = includeField
    })
    this.auditAvailableFields = columnsListToRender
    this.auditColumns = this.lightningDatatableAuditColumns
    this.showSidbarSpinner = false
  }
  /** check all! */
  checkAllFields () {
    this.checkFields(true)
  }
  /** uncheck all! */
  uncheckAllFields () {
    this.checkFields(false)
  }

  /**
   * Dynamically adjust datatable container
   */
  adjustDatatableContainierHeight = () => {
    let windowHeight = window.innerHeight
    let dcElem = this.template.querySelector('.datatable-container')
    if (dcElem && dcElem.style) {
      let dcHeight = windowHeight > 270 ? windowHeight - 269 : windowHeight
      dcElem.style.height = `${dcHeight}px`
    }
  }

  // --------------------------------------------------------------------------

  /**
   * Handle button actions
   * @param {*} event
   */
  handleClick (event) {
    switch(event.target.name) {
      case 'EXPORT':
        this.exportToExcel()
        break
      case 'RETURN_TO_AUDIT':
        this.showPageSpinner = true
        NavHelper.navigateToRecord(this, this.recordId)
        this.showPageSpinner = false
        break
      default:
        break
    }
  }

  /**
   * Write the audit data to excel
   */
  exportToExcel () {
    const workbookSheetName = `${this.recordId}`
    const workbookFileName = `${this.auditRecordLabel} - ${this.recordId} - Audit Logs`
    const workbook = XLSX.utils.book_new()
    const sheetData = [...this.auditDataForExport]
    const worksheet = XLSX.utils.json_to_sheet(sheetData, { skipHeader: false })

    // add new sheet name!
    workbook.SheetNames.push(workbookSheetName)

    //  add new sheet data!
    workbook.Sheets[workbookSheetName] = worksheet

    /* Write Excel and Download */
    XLSX.writeFile(workbook, `${workbookFileName}.xls`, { bookType: 'xls', bookSST: false, type: 'array' })
  }

  // --------------------------------------------------------------------------
  //  - events
  // --------------------------------------------------------------------------

  subscribedMessages = [] // display this one!
  currentReplayId  // replay id ... to replay specific we subscribe to one less replay id
  currentInputReplayId // input text
  selectedReplayId // selected replay id to query!
  hasAuditLogsByReplayId  // for grabbing records by replay ids!
  showReplayQuerySpinner = false
  hasQueriedAuditLogReplay = false
  auditLogReplayRecords = [] //  audit logs matching  the replay id!
  selectedTreeGridRows = [] // for tree grid events

  // TODO CHECKBOX FOR ALLOWING PAST EVENTS!
  showPastEvents = false // when checked pulls in upto 10 past events for the channel
//
  // when show past events is checked!
  handlePastEventsCheckboxChange(event) {
    this.showPastEvents = event.target.checked
  }

  /** returns first audit log replay  record  */
  get firstAuditLogReplayRecord () {
    return (this.auditLogReplayRecords && this.auditLogReplayRecords.length > 0) ? this.auditLogReplayRecords[0] : {}
  }

  /**
   * Query for audit logs by replay  id
   */
  async lookupAuditLogsByReplayId () {
    this.hasAuditLogsByReplayId = false
    this.hasQueriedAuditLogReplay = true
    this.auditLogReplayRecords =  []
    try {
      this.showReplayQuerySpinner = true
      let replayId = this.selectedReplayId
      let auraResult = await getAuditLogsByReplayId({ replayId: replayId})
      if (auraResult && auraResult.records && auraResult.records.length > 0) {
        this.hasAuditLogsByReplayId = true
        let idx = 1
        this.auditLogReplayRecords = auraResult.records.map(r => {
          return { ...r,
            idxCt: idx ++,
            linkToReplayAuditLog: `/lightning/r/${r.id}/view`
          }
        })
      } else {
        this.hasAuditLogsByReplayId = false
      }
    } catch (error) {
      ShowToast.error(this, buildErrorMessage(error))
    } finally {
      this.showReplayQuerySpinner = false
    }
  }

  /**
   * Action to replay a specific event
   *
   * We subscribe to replay  the previous event
   * Then when the current event is replayed we capture the  data
   * and unsubsribe!
   */
  replayEvent () {
    this.currentReplayId = this.template.querySelector('.replay-id').value
    if (this.currentReplayId && this.currentReplayId.length > 0) {
      this.selectedReplayId = this.currentReplayId // set selected to query record!
      this.unsubscribeEvents() // unsubscribe so we can subscribe fresh!
      this.subscribeToReplay()  // subscribe and replay the event
      this.lookupAuditLogsByReplayId() // query for audit logs for replay id
    }
  }
  /** on reply id change! */
  handleReplayIdChange (event)  {
    this.currentInputReplayId = event.detail.value
  }
  /** return true when replay event should be disabled */
  get replayEventDisabled () {
    let isDisabled = typeof this.currentInputReplayId === 'undefined' || this.currentInputReplayId === null || this.currentInputReplayId === '' || this.currentInputReplayId === '-'
    // dont allow -1 or -2
    return isDisabled || this.currentInputReplayId < 0
  }

  /**
   * Returns either the change event channel for the specific audit record object name
   * or the default 'ChangeEvents' for all!
   */
  get auditRecordChangeEvent () {
    let rslt = this._auditRecordChangeEventChannel
    if (typeof rslt === 'undefined') {
      let objName = this.auditRecordObjApiName
      rslt = objName && objName.length > 0 ? objName.replace('__c', '__ChangeEvent') : 'ChangeEvents'
    }
    return rslt
  }
  /** underlying channel  */
  _auditRecordChangeEventChannel
  /** action to toggle channel */
  toggleChangeEventChannel () {
    this.unsubscribeEvents() // force unsubscribe!
    if (this.auditRecordObjApiName) {
      if (this._auditRecordChangeEventChannel === 'ChangeEvents') {
        this._auditRecordChangeEventChannel = this.auditRecordObjApiName.replace('__c', '__ChangeEvent')
      } else {
        this._auditRecordChangeEventChannel = 'ChangeEvents'
      }
    }
  }

  /**
   * Action to replay a specific event
   */
  subscribeToReplay () {
    const replayId = this.currentReplayId
    const changeEventObjectChannel = `/data/${this.auditRecordChangeEvent}`
    if (typeof replayId === 'undefined' || replayId === null || replayId === '') {
      return
    }

    // clear /  initialize messages
    this.subscribedMessages = []

    // register streaming error handler
    onError(this.handleSubscribedErrors)

    /*
      we decrement the replay id were looking for by 1, start the stream, catch the event
    */
    // const lastReplayId = replayId > 0 ? replayId - pastNumOfEvents : replayId // we subscribe to the previous replay to get the specific one!
    const lastReplayId = this.showPastEvents === true ? -2 : (replayId - 1)
    subscribe(changeEventObjectChannel, lastReplayId, this.handleSubscribedReplayMessage).then(results => {
      this.replayEventSubscription = results
      this.showReplaySpinner = true
      console.log('subscribed!', changeEventObjectChannel, replayId, lastReplayId)
    })
  }

  /** returns  true when subscribed messages are present! */
  get hasSubscribedMessages () {
    return this.subscribedMessages && this.subscribedMessages.length > 0
  }

  /**
   * When message is received
   * @param {event} - message
   */
  handleSubscribedReplayMessage = (event) => {
    // TODO: Support channels (/event/BatchApexErrorEvent && /data/ChangeEvents)
    // const channel = event.channel

    let subscribedMessages = [...this.subscribedMessages]

    // Handle change event messages!
    const evtReplayId = (event && event.data && event.data.event) ? event.data.event.replayId : ''
    if (event && event.data && event.data.payload) {
      const ChangeEventHeader = event.data.payload.ChangeEventHeader
      const isEventReplayId = (evtReplayId.toString() === this.currentReplayId || evtReplayId > 0)

      if (ChangeEventHeader && isEventReplayId) {
        let changedFields = ChangeEventHeader.changedFields
        if (ChangeEventHeader.changeType === 'CREATE') {
          // pull out the event data payload keys (minus the ChangeEventHeader) use as changed fields for create!
          changedFields = Object.keys(event.data.payload).map(r => { if (r !== 'ChangeEventHeader') { return r}}).filter(r => { return typeof r !== 'undefined'})
        } else if (ChangeEventHeader.changeType === 'DELETE') {
          changedFields = ['Id']
        }

        // build data objects to render!
        subscribedMessages.push({
          ...event.data.payload,
          ...ChangeEventHeader,
          changedFields: changedFields,
          eventReplayId: evtReplayId
        })

      }
      this.subscribedMessages = subscribedMessages

      // if we catch the current replay id unsubscribe from events
      if (evtReplayId.toString() === this.currentReplayId) {
        this.unsubscribeEvents()
        this.showReplaySpinner = false
        console.log('subscribedMessages', this.subscribedMessages)
      }
    }
  }

/*
"{"schema":"XHR8IH-YOipzexpz9ZTupg",
  "payload":{
    "LastModifiedDate":"2020-06-03T13:13:28Z",
    "Description__c":"<p>ding lookin</p>",
    "ChangeEventHeader":{
        "commitNumber":10653914629120,
        "commitUser":"0058A000004Dl4AQAS",
        "sequenceNumber":1,
        "entityName":"Project_Log__c",
        "changeType":"UPDATE",
        "changedFields":["LastModifiedDate","Description__c"],
        "changeOrigin":"com/salesforce/api/soap/49.0;client=SfdcInternalAPI/",
        "transactionKey":"000097ff-4f5d-391b-5028-7a3bf9f516c4",
        "commitTimestamp":1591190008000,
        "recordIds":["aHQ8A0000004DbsWAE"]
      }
    },
    subscribedMessages entityName
    "event":{"replayId":103155}}"
*/

  /**
   * Returns tree grid columns for the change event
   */
  get subscribeMessageTreeColumns () {
    let cols = [
      { label: 'Replay Id', initialWidth: 125, fieldName: 'replayId', type: 'text',  sortable: true },
      { label: 'Time', fieldName: 'logTime', type: 'date', sortable: true, typeAttributes: { month: '2-digit', day: '2-digit', year: "numeric", hour: '2-digit', minute: '2-digit' } },
      { label: 'Object', initialWidth: 100, fieldName: 'logObject', type: 'text', sortable: true },
      { label: 'Operation', initialWidth: 100, fieldName: 'operation', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'format' } } },
      { label: 'Field', fieldName: 'field', type: 'text', sortable: true },
      { label: 'Value', fieldName: 'newValue', type: 'text', sortable: true }
    ]
    //  add button to select rows when showing  past events!
    if (this.showPastEvents) {
      let selectReplayButton = { type: 'button-icon', initialWidth: 50, typeAttributes: { name: 'select_replay_row', iconName: 'utility:edit', variant: 'bare', title: 'Select Replay' } }
      cols.splice(1, 0, selectReplayButton)
    }
    return cols
  }

  /**
   * action when selecting a replay row!
   *
   * @param {*} event
   */
  selectedTreeGridOnRowAction(event) {
    event.preventDefault()
    event.stopPropagation()

    const actionName = event.detail.action && event.detail.action.name
    const row = event.detail.row
    switch (actionName) {
      case 'select_replay_row':
        this.selectedReplayId = row.replayId
        this.selectedTreeGridRows = []
        this.selectedTreeGridRows.push(row.key)
        this.lookupAuditLogsByReplayId()
        // console.log('SELECTED?', row)
        break
      default:
        break
    }
  }

  /**
   * Returns tree grid data for the change event(s)
   */
  get subscribedMessagesTreeData() {
    let groupedMsgs = groupByField(this.subscribedMessages, 'eventReplayId')
    let alltreedata = []
    let selectedReplayId = this.selectedReplayId
    let selectedTreeGridRows = []

    Object.keys(groupedMsgs).forEach(subReplayid => {
      let subMsg = groupedMsgs[subReplayid]
      if (typeof subMsg === 'undefined' || subMsg === null) {
        subMsg = []
      }

      // build tree data!
      let treeData = subMsg.map(r => {
        let changedFields = [...r.changedFields]
        let firstFieldVal = r[changedFields[0]] || ''
        let key = generateUniqueId()
        if (selectedReplayId !== null && selectedReplayId.toString() === r.eventReplayId.toString()) {
          selectedTreeGridRows.push(key)
        }
        let dataItem = {
          'replayId': r.eventReplayId,
          'logObject': r.entityName,
          'operation': r.changeType,
          'logTime': r.commitTimestamp,
          'field': changedFields.shift(),
          'key': key,
          'newValue': firstFieldVal
        }
        if (changedFields.length > 0) {
          dataItem._children = []
          changedFields.forEach(cf => {
            let cfkey = generateUniqueId()
            if (selectedReplayId !==  null && selectedReplayId.toString() === r.eventReplayId.toString()) {
              selectedTreeGridRows.push(cfkey)
            }
            dataItem._children.push({
              'replayId': r.eventReplayId,
              'operation': r.changeType,
              'logObject': r.entityName,
              'logTime': r.commitTimestamp,
              'key': cfkey,
              'field': cf,
              'newValue': r[cf]
            })
          })
        }
        return dataItem
      })
      alltreedata.push(treeData)
    })

    // flatten and sort by replay id desc!
    let flattenedTreeData = [].concat.apply([], alltreedata)
    flattenedTreeData = DataTableHelper.sortRecords(flattenedTreeData, this.subscribeMessageTreeColumns, 'replayId', 'ASC')

    // expand all items ... when just one ???
    if (flattenedTreeData.length > 0 && flattenedTreeData.length < 2) {
      this.selectedTreeGridRows = []
      setTimeout(() => {
        let treegrid = this.template.querySelector('lightning-tree-grid.replay-tree-grid')
        if (treegrid) {
          treegrid.expandAll()
        }
      }, 100)
    } else {
      // console.log('selectedTreeGridRows', selectedTreeGridRows)
      this.selectedTreeGridRows = selectedTreeGridRows
    }
    return flattenedTreeData
  }

  /**
   * Action  to save selected replay event
   */
  addMissingEvents () {
    let auditLogWrappers = this.buildAuditLogWrappers()
    this.saveReplayedEvents(auditLogWrappers)
  }

  /**
   * Add missing events from subscribed messages
   * saveReplayedEvents
   */
  async saveReplayedEvents(auditLogWrappers) {
    try {
      // this.showReplaySpinner = true
      this.showReplayQuerySpinner = true
      let auraResult = await saveReplayedEvents({ auditLogWrapperJSON: JSON.stringify(auditLogWrappers)})
      if (auraResult.items && auraResult.items.jobId) {
        ShowToast.success(this, `The audit log job has been submitted ${auraResult.items.jobId}.  Please check back in a few minutes.`)

        // clear audit log search by...avoid adding multiple audit log records
        if (this.showPastEvents) {
          this.hasQueriedAuditLogReplay = false
          this.selectedTreeGridRows = []
          this.selectedReplayId = null
        } else {
          this.hasQueriedAuditLogReplay = false
          this.selectedTreeGridRows = []
          this.selectedReplayId = null
          this.currentInputReplayId = null
          this.currentReplayId = null
          this.selectedMessages = []
        }
      }

    } catch (error) {
      ShowToast.error(this, buildErrorMessage(error))
    } finally {
      // this.showReplaySpinner = false
      this.showReplayQuerySpinner = false
    }
  }

  /**
   *
   */
  buildAuditLogWrappers () {
    let replayId = this.selectedReplayId
    // let missingMsgs = this.subscribedMessages // .filter(f => { return f.isMissing === true })
    let missingMsgs = this.subscribedMessages.filter(f => { return (f.eventReplayId.toString()) === replayId.toString() })
    let auditLogWrappers = []
console.log('missingMsgs', missingMsgs, 'replayId', typeof replayId, this.subscribedMessages)
    missingMsgs.forEach(subMsg => {
      let operation = subMsg.changeType
      operation = operation.toUpperCase() === 'CREATE' ? 'INSERT' : operation
      subMsg.recordIds.forEach(recordId => {
        subMsg.changedFields.forEach(changedField => {
          auditLogWrappers.push({
            objectType: subMsg.entityName,
            userId: subMsg.commitUser,
            logTimestamp: subMsg.commitTimestamp,
            operation: operation,
            recordId: recordId,
            replayId: subMsg.eventReplayId,
            transactionKey: subMsg.transactionKey,
            field: changedField,
            newValue: subMsg[changedField] || ''
          })
        })
      })
    })
    return auditLogWrappers
  }

  /**
   * Handle subscription errors
   *   // note...  = () => {}  to automatically bind to the class (to get access to this!)
   */
  handleSubscribedErrors = (event) => {
    // eslint-disable-next-line
    console.error('onError event!', event)
    let isSubscribed = (typeof this.replayEventSubscription !== "undefined")
    // @ handle when advice is reconnect!
    if (isSubscribed && event && event.advice && event.advice.reconnect) {
      // Attempt resubscribe up to 5 times
      if (this.resubscribeTries > 5) {
        this.unsubscribeEvents()
        ShowToast.error(this, 'Channel subscription timeout')
      } else {
        // resubscribe
        this.resubscribeTries += 1
        unsubscribe(this.replayEventSubscription, () => {
          this.replayEventSubscription = undefined

          const replayId = this.currentReplayId
          const changeEventObjectChannel = `/data/${this.auditRecordChangeEvent}`
          const lastReplayId = this.showPastEvents === true ? -2 : (replayId - 1)
          subscribe(changeEventObjectChannel, lastReplayId, this.handleSubscribedReplayMessage).then(results => {
            this.replayEventSubscription = results
            this.showReplaySpinner = true
            console.log('resubscribed!', changeEventObjectChannel, replayId, lastReplayId)
          })
        })
      }
    }
    // @ handle error codes
    if (isSubscribed && event && event.error) {
      let evtErr = event.error
      //  @ when replay id is invalid!
      if (evtErr.toLowerCase().startsWith('400::the replayid')) { //:The replayId {103158} you provided was invalid') {
        let errMsg = `The replayId you provided (${this.currentReplayId}) was invalid. Please provide a valid ID `
        this.unsubscribeEvents()
        ShowToast.error(this, errMsg)
      } else {
        ShowToast.error(this, event.error)
      }
    } else {
      this.unsubscribeEvents()
    }
  }

  // unsubscribe from batch events
  unsubscribeEvents = () => {
    // console.log('unsubscribeEvents ', this.replayEventSubscription)
    if (typeof this.replayEventSubscription !== 'undefined') {
      unsubscribe(this.replayEventSubscription, () => {
        this.replayEventSubscription = undefined
        console.log('unsubscribed')
      }).catch((error) => {
        console.log('unsubscribed error', error)
      }).finally(() => {
        this.replayEventSubscription = undefined
        // console.log('finally unsubscribed')
        this.showReplaySpinner = false
      })
    }
  }


}
