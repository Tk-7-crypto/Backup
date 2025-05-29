/*
 * Provides convenient functions for lwc components
 *
 * # examples
 * # Confirmation - prompts user for ok / cancel returning results in a JS Promise:
 *    let lwcHelper = this.template.querySelector('c-lwc_helper')
 *    lwcHelper.confirm('Are you sure?').then(ok => { handleOk() }, cancel=> { handleCancel() })
 *
 * # Navigation
 *    lwcHelper.navigateToViewRecord(SOBJECT_RECORD_ID)
 *    lwcHelper.navigateToEditRecord(SOBJECT_RECORD_ID)
 *    lwcHelper.navigateToNewRecord(SOBJECT_API_NAME)
 *
 * # Toast Message - convenient toast event message
 *    lwcHelper.toastSuccess('Yippee!')
 *    lwcHelper.toastError('Ahh snap!')
 *    lwcHelper.toastMessage('warning', 'look out!')
 *
 * # Modal Spinner - modal spinner with optional messaging
 *    lwcHelper.showModalSpinner()
 *    lwcHelper.showModalSpinner('Loading...')
 *    lwcHelper.hideModalSpinner()
 *
 */
import { LightningElement, api, track } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation'

export default class Lwc_helper extends NavigationMixin(LightningElement) {

  // ------------------------------------------------------
  // ---- confirmation!
  @track showConfirmation = false
  @track confirmationHeading = 'Confirmation'
  @track confirmationMessage = 'Are you sure?'

  // confirmation deferred promise
  deferredConfirmationPromise = { resolve: null, reject: null }

  /*
   * Renders confirmation modal window return Promise results for OK and Cancel actions
   * msg - either the message to render or the heading and message
   *       (String or Object{heading:'', message:''})
   *
   * // String argument example
   * lwcHelper.confirm('Are you sure?').then(ok => {}, cancel => {})
   * // Object argument example
   * lwcHelper.confirm({heading:'Confirmation', message:'Are you sure?'}).then(ok => {}, cancel => {})
   */
  @api confirm (msg) {
    // message to render from type of msg argument
    if (typeof msg === 'undefined') {
      throw new Error('Undefined message')
    } else if (typeof msg === 'string') { // support string message
      this.confirmationMessage = msg
    } else if (typeof msg === 'object') { // support object message
      this.confirmationHeading = msg.heading || 'Confirmation'
      this.confirmationMessage = msg.message
    }

    this.showConfirmation = true // render modal

    // setup and return the deferred promise handlers
    return new Promise((resolve, reject) => {
      this.deferredConfirmationPromise.resolve = resolve
      this.deferredConfirmationPromise.reject = reject
    })
  }

  // when confirm ok is clicked, resolve the deferred promise
  onconfirmationok(evt) {
    if (typeof this.deferredConfirmationPromise !== 'undefined') {
      this.deferredConfirmationPromise.resolve(evt)
    }
    this.showConfirmation = false
  }
  // when confirm cancel is clicked, reject the deferred promise
  onconfirmationcancel(evt) {
    if (typeof this.deferredConfirmationPromise !== 'undefined') {
      this.deferredConfirmationPromise.reject(evt)
    }
    this.showConfirmation = false
  }

  // ------------------------------------------------------
  // --- Navigation
  // link to view record
  @api navigateToViewRecord (recordId) {
    this.navigateToStandardRecordPage(recordId, 'view')
  }
  // link to edit record
  @api navigateToEditRecord (recordId) {
    this.navigateToStandardRecordPage(recordId, 'edit')
  }
  // link to create a record
  @api navigateToNewRecord (objectApiName) {
    this.navigateToStandardObjectPage(objectApiName, 'new')
  }

  // navigates to a standard object page
  // objectApiName - API name of the standard or custom object
  // actionName - action to invoke ('home', 'list', or 'new')
  navigateToStandardObjectPage (objectApiName, actionName) {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: objectApiName,
        actionName: actionName
      }
    })
  }
  // navigates to a standard record page
  // recordId - required record id to direct to
  // actionName - action to show one of view or edit
  navigateToStandardRecordPage (recordId, actionName) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: actionName
      }
    })
  }

  // ------------------------------------------------------
  // --- convenient toast message rendering
  /*
   * Dispatch Show Toast Event
   *
   * toastOptions - Object containing the toast event parameters
   *  # variant - valid values are 'info', 'success', 'warning', or 'error'
   *  # message - Toast message to render
   *  # mode - Optional String	Determines how persistent the toast is. Valid values are:
   *      'dismissable' (default), remains visible until you press the close button or 3 seconds has elapsed, whichever comes first;
   *      'pester', remains visible for 3 seconds.
   *      'sticky', remains visible until the close button is clicked
   */
  @api toastMessage(toastOptions) {
    this.dispatchEvent(new ShowToastEvent(toastOptions))
  }
  /* Dispatch success toast message
   * message - String value of message to render
   * mode - Optional toast event mode, defaults to 'dismissable'
   */
  @api toastSuccess(message, mode) {
    this.toastMessage({ variant: 'success', message: message, mode: mode || 'dismissable' })
  }
  /* Dispatch error toast message
   * message - String value of message to render
   * mode - Optional toast event mode, defaults to 'dismissable'
   */
  @api toastError(message, mode) {
    this.toastMessage({ variant: 'error', message: message, mode: mode || 'dismissable' })
  }

  // ------------------------------------------------------
  // -- modal spinner
  // - showModalSpinner()
  // - showModalSpinner('Loading objects')
  // - showModalSpinner({heading:'Please Wait', message:'Loading...'})
  @track renderModalSpinner = false
  @track modalSpinnerHeader = 'Please Wait...'
  @track modalSpinnerMessage = ''
  @api showModalSpinner (options) {
    if (typeof options !== 'undefined') {
      if (typeof options === 'string') {
        this.modalSpinnerMessage = options
      } else if (typeof options === 'object') {
        this.modalSpinnerHeader = options.heading || this.modalSpinnerHeader
        this.modalSpinnerMessage = options.message
      }
    }
    this.renderModalSpinner = true
  }
  // - hideModalSpinner()
  @api hideModalSpinner () {
    this.renderModalSpinner = false
  }
}