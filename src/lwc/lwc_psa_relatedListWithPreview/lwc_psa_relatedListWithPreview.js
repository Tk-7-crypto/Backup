import { LightningElement, api, wire } from 'lwc'
import { deleteRecord } from 'lightning/uiRecordApi'
import { refreshApex } from '@salesforce/apex'
import { buildErrorMessage, generateUniqueId, ShowToast, DataTableHelper } from 'c/utils'
import getProjectTaskPreviewItems from '@salesforce/apex/CNT_PSA_relatedListWithPreview.getProjectTaskPreviewItems'

// const PREVIEW_VIEW_MODE = 'view'
const PREVIEW_VIEW_MODE = 'readonly'
const PREVIEW_EDIT_MODE = 'edit'
const DEFAULT_PREVIEW_VIEW_MODE = PREVIEW_VIEW_MODE

const DEFAULT_OBJ_API_NAME = 'pse__Project_Task__c'

export default class Lwc_psa_relatedListWithPreview extends LightningElement {
  @api recordId

  objectApiName = DEFAULT_OBJ_API_NAME

  tableKeyField = 'Id'
  tableClass = ''
  tableRowData = []
  tableDraftValues = []
  tableErrors = []
  tableSortedBy
  tableSortedDirection
  tableSelectedRows = []

  showPreviewSpinner = false
  showRefreshSpinner = false
  previewFields = []
  previewNumberOfFormColumns = 2
  previewMode = DEFAULT_PREVIEW_VIEW_MODE

  // the datatable columns to render from fieldsets for task service line
  datatableColumns

  // the underlying project task record
  projectTask

  // record type name and id to use when creating records
  newRecordTypeName
  newRecordTypeId

  //Parent task Service Code, used when creating records
  newRecordService

  // when creating new records, fields to render in the 'informational' section
  generalNewRecordFields = []

  // renderNew projoect task window
  showNewRecordWindow = false
  showModalSpinner = false
  isSaveAndNewClicked = false //  true when 'saving and new'

  // Underlying new record object!
  newRecord = {
    objectApiName: this.objectApiName,
    recordTypeId: this.newRecordTypeId,
    mode: 'edit',
    density: '',
    gridSize: 2
  }
//
//  TODO.. record input sections apex?
//
  //  maintains a list of [ { title: sectionTitle, fields: [{}] }] for  new records
  //  @see addNewRecordSections
  newRecordSections = []

  /**
   * Adds a new record section to render with title and fields
   * @param {String} title
   * @param {[{}]} fields
   */
  addNewRecordSections(title, fields) {
    this.newRecordSections.push({
      key: generateUniqueId(),
      title: title,
      fields: fields
    })
  }

  /**
   * returns the fieldset datatablecolumns to render injecting our buttons and row actions
   */
  get tableColumns () {
    let columns = []
    if (this.datatableColumns && this.datatableColumns.length && this.datatableColumns.length > 0) {
      columns = [...this.datatableColumns]

      // inject edit button and row actions
      columns.unshift(this.editRowButton)
      columns.push(this.rowActions)

    }
    return columns
  }

  /**
   * Returns datatable column for the edit row column
   */
  get editRowButton () {
    // return { type: 'button-icon', initialWidth: '25', typeAttributes: { name: 'edit_task_details', iconName: 'utility:edit', variant: 'bare', title: 'Edit Task' } }
    return { type: 'button-icon', initialWidth: '25', typeAttributes: { name: 'edit_task_details', iconName: 'utility:preview', variant: 'bare', title: 'Edit Task' } }
  }

  /**
   * Returns datatable  column for the  row actions
   */
  get rowActions  () {
    return { type: 'action', typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] } }
  }

  /**
   * Fetch the prview form fields, datatable columns, and datatable records
   * to render based on the record id
   *
   * @param {*} value
   */
  @wire(getProjectTaskPreviewItems, { recordId: '$recordId' })
  wiredProjectTaskFieldSets (value) {
    this.wiredProjectTaskFields = value
    const { error, data } = value
    if (data) {
      if (data.items) {
        this.previewFields = data.items.previewFields
        this.datatableColumns = data.items.datatableColumns
        this.projectTask = data.items.projectTask
        this.generalNewRecordFields = data.items.generalFields // item name for fieldsForNewRecordCreate?
        this.newRecordTypeName = data.items.newRecordTypeName // new record type nname
        this.newRecordTypeId = data.items.newRecordTypeId // new record  type  id
        this.newRecord.recordTypeId = data.items.newRecordTypeId // new record  type  id
        this.newRecordService = data.items.serviceCode

        if (data.records) {
          this.tableRowData = data.records
        }

        //  default selected row if one is not selected
        if (this.hasSelectedRow === false && this.tableRowData.length > 0) {
          this.tableSelectedRows = [this.tableRowData[0].Id]
        }

      }
    }
    if (error) {
      ShowToast.error(this, buildErrorMessage(error))
    }
  }

  /* retrieves the underlying lwc helper */
  get lwcHelper() {
    return this.template.querySelector('c-lwc_helper')
  }

  /**
   * @return url link to view all subtasks
   */
  get subtaskLink() {
    return `/lightning/r/${this.recordId}/related/pse__Immediate_Sub_Tasks__r/view`
  }

  /**
   * Action when refresh button on datatalbe is clicked
   */
  async refreshTableData () {
    try {
      this.showPreviewRefreshSpinners()
      await refreshApex(this.wiredProjectTaskFields)
    } catch (error) {
      ShowToast.error(this, buildErrorMessage(error))
    } finally {
      this.hidePreviewRefreshSpinners()
    }
  }

  /**
   * @return number of child tasks
   */
  get subtaskRecordCount() {
    return `(${(this.tableRowData || []).length})`
  }

  /**
   * The method onsort event handler for the datatable
   */
  tableOnSort (event) {
    this.tableSortedBy = event.detail.fieldName
    this.tableSortedDirection = event.detail.sortDirection
    this.tableRowData = DataTableHelper.sortRecords(this.tableRowData, this.tableColumns, this.tableSortedBy, this.tableSortedDirection)
  }

  /**
   * Handle datatable row actions
   * @param {*} event
   */
  tableOnRowAction (event) {
    event.preventDefault()
    event.stopPropagation()

    const actionName = event.detail.action.name
    const row = event.detail.row
    switch (actionName) {
      case 'edit_task_details':
        this.previewTaskForm(row)
        break
      case 'delete':
        this.removeRecord(row)
        break
      default:
        break
    }
  }

  /**
   * @return - true when preview mode is 'view'; false when preivew mode is not  'view'
   */
  get isPreviewModeView () {
    return this.previewMode === PREVIEW_VIEW_MODE
  }

  /**
   * Action when cancel preview is clicked
   */
  cancelPreview () {
    this.tableSelectedRows =  [] // clear selected rows!
  }

  /**
   * Action when edit preview button is clicked
   */
  editPreview () {
    this.previewMode = PREVIEW_EDIT_MODE
  }

  /**
   * The event fired when the user cancels the preivew form.
   * maintain our preview mode!
   */
  previewFormCancel () {
    this.previewMode = PREVIEW_VIEW_MODE
  }

  /**
   * The event fired when the user successfully submits  / saves the preivew form.
   */
  previewFormSuccess () {
    const selectedRecordId = this.previewSelectedRecordId
    this.previewMode = PREVIEW_VIEW_MODE

    // deselect all rows (in current thread for ui refresh)
    this.tableSelectedRows = []
    // select the saved record to re-load form (in another thread for ui refersh)
    setTimeout(() => { this.tableSelectedRows = [selectedRecordId]; this.previewMode = DEFAULT_PREVIEW_VIEW_MODE; }, 1)

    ShowToast.success(this, 'Record successfully saved')

    // Re-load datatables
    this.refreshTableData()
  }

  /**
   * Load form fields to render from the  selcted row!
   * @param {*} row
   */
  previewTaskForm(row) {
    this.showPreviewSpinner = true
    this.tableSelectedRows = [] //  remove any current selected row!

    // refresh selected row in another thread, force the ui to update
    setTimeout(() => {
      this.previewMode = DEFAULT_PREVIEW_VIEW_MODE //  make sure our mode is set
      this.tableSelectedRows = [row.Id] // set as selected row in datatable and preview
      this.showPreviewSpinner = false
    }, 1)
  }

  showPreviewRefreshSpinners () {
    this.showPreviewSpinner = this.showRefreshSpinner = true
  }
  hidePreviewRefreshSpinners () {
    this.showPreviewSpinner = this.showRefreshSpinner = false
  }

  /**
   * Deletes record
   * @param {*} record - representing the record, with Id field to delete
   */
  removeRecord (record) {
    const heading = 'Delete Record'
    const message = 'Are you sure you would like to delete this record?'
    this.lwcHelper.confirm({ heading: heading, message: message}).then((ok) => {
      const recordId = record.Id
      this.showPreviewRefreshSpinners()
      deleteRecord(recordId).then(() => {
        refreshApex(this.wiredProjectTaskFields)
        this.tableSelectedRows = [] // unselect all rows!
      }).catch((error) => {
        ShowToast.error(this, buildErrorMessage(error))
      } ).finally(() => {
        this.hidePreviewRefreshSpinners()
      } )
    }, (cancel) => {
      // on cancel!
    })
  }

  /**
   * Previews the last  row
   * Decrement the selected row indexed
   */
  previewLast () {
    if (this.tableRowData && this.tableRowData.length && this.tableRowData.length > 0) {
      const curSelectedIdx = this.previewSelectedIndex || 0
      const lastSelectedIdx = curSelectedIdx > 0 ? curSelectedIdx - 1 : this.tableRowData.length - 1 // decrement  selected index
      this.previewTaskForm(this.tableRowData[lastSelectedIdx]) // select row by last index
    }
  }

  /**
   * Previews the next row
   * Increment the selected row index
   */
  previewNext () {
    if (this.tableRowData && this.tableRowData.length && this.tableRowData.length > 0) {
      const curSelectedIdx = this.previewSelectedIndex || 0
      const nextSelectedIdx = curSelectedIdx < (this.tableRowData.length - 1) ? curSelectedIdx + 1 : 0 // increment  selected index
      this.previewTaskForm(this.tableRowData[nextSelectedIdx]) // select row by next index
    }
  }

  /**
   * Returns the index of the selected record in the list of table row data
   */
  get previewSelectedIndex () {
    const curSelectedRecId = this.previewSelectedRecordId || 0
    const curSelectedIdx = this.tableRowData.findIndex(i => i.Id === curSelectedRecId)
    return curSelectedIdx
  }

  /**
   * returns the record id from the table selected row
   */
  get previewSelectedRecordId () {
    let selectedRecordId = null
    if (this.hasSelectedRow) {
      selectedRecordId = this.tableSelectedRows[0]
    }
    return selectedRecordId
  }


  /**
   * Returns true when a row is selected for preivew
   */
  get hasSelectedRow () {
    return this.tableSelectedRows.length > 0
  }


  /**
   * Handle when  the add new child task record is clicked
   */
  handleAddNewRecord () {
    //  initialize the new record section form
    this.setNewRecordSection()

    //  render modal!
    this.openNewRecordWindow()
  }

  /**
   * initializes the new reccord sections!
   */
  setNewRecordSection () {
    const ptask = this.projectTask || {}
    const generalFields = this.generalNewRecordFields
    // prep and build general fields for input sections
    let newGeneralFields = this.buildNewRecordFields(generalFields.map(f => {
      let fld = { fieldName: f}
      //  attempt to set defaults from the underlying project task record!
      if (typeof ptask[f] !== 'undefined') {
        fld.fieldValue = ptask[f]
      }
      // default record type id and disable field from editing
      if (f === 'RecordTypeId') {
        fld.fieldValue = this.newRecordTypeId
        fld.fieldDisabled = true
      }
      // default the parent task!
      if (f === 'pse__Parent_Task__c') {
        fld.fieldValue  = this.recordId
      }
      return fld
    }))

    // maintain to keep fields unique accross all sections
    let genfldNames = newGeneralFields.map(r => { return r.fieldName })

    // Build detail section fields based on the preview field set and fields not already rendered
    let pvfldMap = this.previewFields.filter(f => {
      return genfldNames.indexOf(f) < 0 // only use fields not already  used
    }).map(r => {
      let fld = { fieldName: r }
      // Set the activity controlling picklist to the service line
      if (r === 'Activity_Controlling_Picklist__c') {
        fld.fieldValue = this.newRecordService
        fld.fieldDisabled = true
      }
      return fld // transform for call to buildNewRecordFields
    })
    let newPreviewFields = this.buildNewRecordFields(pvfldMap)


    // initialize and inject the sections and fields
    this.newRecordSections = []
    this.addNewRecordSections('Information', newGeneralFields)
    this.addNewRecordSections('Details', newPreviewFields)
  }

  /**
   * Action to open  the  new  record window
   */
  openNewRecordWindow() {
    this.showModalSpinner = true
    this.showNewRecordWindow = true
  }

  /**
   * Action to close new record window
   */
  closeNewRecordWindow() {
    this.showNewRecordWindow = false
  }

  /**
   * @return true when save modal button should be disabled
   */
  get disabledSaveModalButtons() {
    return this.isNewRecordSubmitting || this.hasNewRecordFormError
  }
  /**
   * @return cancel when save modal button should be disabled
   */
  get disabledCancelModalButtons() {
    return this.isNewRecordSubmitting
  }
  /**
   * returns the heading for the new record modal
   */
  get newRecordModalHeading() {
    return `New Project Task: ${this.newRecordTypeName}`
  }

  /**
   * Populate the new record fields for adding new items
   * based on supplied list of form fields
   *
   * @param {{fieldName:''}} recFields
   */
  buildNewRecordFields (recFields) {
    let newRecordFields = recFields.map(f => {
      const isBlank = f.fieldName  === 'BlakField' ? true : false
      const isName = f.fieldName === 'Name' ? true : false
      const isBlankAndNotName = (isName === true || isBlank === true ) ? true : false
      return {
        fieldName: f.fieldName,
        classNames: f.fieldName,
        fieldValue: f.fieldValue || null,
        fieldDisabled: f.fieldDisabled || false,
        inputFieldColumnClass: this.newRecordInputFieldColumnClass,
        fieldPopulated: false,
        fieldHidden: false,
        isBlankField: isBlank,
        isBlankAndNotNameField: isBlankAndNotName,
        isNameField: isName
      }
    })
    return newRecordFields
  }

  /**
   * build html classes to use based on grid size and density
   */
  get newRecordInputFieldColumnClass() {
    return `slds-col slds-size_1-of-${this.newRecord.gridSize} slds-p-left_medium slds-p-right_medium slds-p-bottom_medium ${(this.newRecord.density || 'auto').toLowerCase() === 'comfy' ? 'slds-text-align_left' : ''}`
  }

  /**
   * event when new record is successfully saved
   */
  handleNewRecordSucccesForm() {
    // console.log('new recocrdd form element succss')
    this.showModalSpinner = false // stop spinner

    this.isNewRecordSubmitting = false
    if (this.isSaveAndNewClicked === true) {
      this.handleAddNewRecord() // add a new record!
      this.isSaveAndNewClicked = false
    } else {
      this.closeNewRecordWindow() // close the new record window
    }
    this.refreshTableData() // Re-load datatables
  }

  /**
   * event when error with the new record form
   */
  handleNewRecordErrorForm (event) {
    console.error('new record form element error form', event.detail)
    this.showModalSpinner = false
  }

  /**
   * Event when new record form is loaded
   */
  handleNewRecordLoadedForm() {
    if (this.isNewRecordSubmitting) { return } // skip when submitting!
    this.showModalSpinner = false
  }

  /**
   * Event when submitting a new record
   */
  isNewRecordSubmitting = false // maintain spinner from submitting event, to keep spinner rendered during form load events while submitting
  handleNewRecordSubmit() {
    this.isNewRecordSubmitting = true // maintain we are submitting.
    this.showModalSpinner = true
  }

  /**
   * Action when save new record window is clicked, save the new recocrd!
   */
  handleSaveNewRecordWindow() {
    this.isSaveAndNewClicked = false
    this.handleHiddenSubmit()
  }
  /**
   * Action when save and new record window is clicked, save the new recocrd and initialize a new one for saving!
   */
  handleSaveAndNewRecordWindow () {
    this.isSaveAndNewClicked = true
    this.handleHiddenSubmit()
  }

  // // find the hidden submit button and click it...to trigger on submit handler!
  handleHiddenSubmit () {
    let hiddenButtonElem = this.template.querySelector('.hidden-submit-button')
    if (typeof hiddenButtonElem !== 'undefined' && hiddenButtonElem !== null) {
      this.showModalSpinner = true
      hiddenButtonElem.click()
    } else {
      // manually submit when no hidden button elem provided!
      this.showModalSpinner = true
      this.template.querySelector('lightning-record-edit-form.add-related-items').submit()
    }
  }
}