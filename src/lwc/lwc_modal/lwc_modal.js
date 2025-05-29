/*
 * c-lwc_modal
 *
 * Attributes
 *    show-modal - Boolean indicator to show or hide modal window
 *    onclose - Method called when the header 'X' close button is clicked (callback should set show-modal indicator to false)
 *    hide-header-close - when present suppresses the X close button from rendering
 *    hide-modal-footer - when present suppresses the modal footer from rendering
 *    size - one of 'small', 'medium', 'large'
 *    modal-heading - optional, heading to use (when not implementing slot='modal-heading')
 *
 * Example
 * <c-lwc_modal show-modal={booleanToShowOrHide} onclose={methodCalledOnClose}>
 *   <div slot="modal-heading">Heading!</div>
 *   <div slot="modal-content">Content!</div>
 *   <div slot="modal-footer">Footer!</div>
 * </c-lwc_modal>
 *
 */
 
import { LightningElement, api, track } from 'lwc';

export default class Lwc_modal extends LightningElement {
  // watch the show-modal indicator when true render the modal window
  renderModal = false
  @api
  get showModal () {
    return this.renderModal
  }
  set showModal (value) {
    this.renderModal = (value && value === true)
  }

  // optional heading text to use for modal heading (used when not implementing modal-header slot)
  @api modalHeading

  // optional size for modal, one of 'small', 'medium', 'large'
  @api size

  // generate the html classes to inject into the modal section
  get modalSectionClasses() {
    return `slds-modal slds-modal_${this.size} slds-fade-in-open`
  }

  // returns html classes for the modal header
  get modalHeaderClass () {
    return 'slds-modal__header' // when empty inject 'slds-modal__header_empty'
  }

  // returns html classes for the modal footer
  get modalFooterClass () {
    return 'slds-modal__footer' // when directional inject 'slds-modal__footer_directional'
  }

  // support hide-header-close when set do not show header close X button
  @track showHeaderClose = true
  @api
  get hideHeaderClose() {
    return this.showHeaderClose
  }
  set hideHeaderClose(value) {
    this.showHeaderClose = false
  }

  // support hide-modal-footer when set do not render footer
  @track showModalFooter = true
  @api
  get hideModalFooter () {
    return !this.showModalFooter
  }
  set hideModalFooter(value) {
    this.showModalFooter = false
  }

  // close modal and dispatch close event
  handleModalClose () {
    this.showModal = false
    this.dispatchEvent(new CustomEvent('close', { close: true }))
  }
}