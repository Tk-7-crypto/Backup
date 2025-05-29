/*
 * c-lwc_svg-progress-circle
 *
 * Provides an SVG Progress Circle indicator for a specified percent
 *
 */
import { LightningElement, api, track } from 'lwc'

export default class Lwc_svgProgressCircle extends LightningElement {
  // handle percent attribute (when changed update covered circle)
  localPercent = 0
  @api
  get percent () {
    return this.localPercent
  }
  set percent (value) {
    let intValue = parseInt(value, 10)
    if (isNaN(intValue) || intValue < 0) {
      this.localPercent = 0
    } else if (intValue > 100) {
      this.localPercent = 100
    } else {
      this.localPercent = intValue
    }
    this.setProgessPercent(this.localPercent)
  }

  localSize = 'large'
  @api
  get size() {
    return this.localSize
  }
  set size(value) {
    this.localSize = value
    if (typeof value === 'string' && value.toLowerCase() === 'small') {
      this.progressCircle.strokeWidth = "6"
      this.progressCircle.radius = "27"
    }
  }

  get isLargeSize() {
    return this.size === 'large'
  }

  get isSmallSize() {
    return this.size === 'small'
  }


  // apply progress percent and ensure our coloring is set!
  renderedCallback () {
    // progress ???
    this.applyProgressRenderedCircle()
  }

  @track progressCircle = {
    strokeWidth: "12",
    radius: '54',
    progressVal: "60",
    progressStrokeDashoffset: undefined
  }


  get progressRadiusNumber () {
    let radius = this.isSmallSize ? '27' : this.progressCircle.radius
    let nval = parseInt(radius, 10)
    return isNaN(nval) ? 0 : nval
  }

  get progressCircumfrence () {
    return 2 * Math.PI * this.progressRadiusNumber
  }

  // when progress input is changed
  handleProgressInputControl (event) {
    this.setProgessPercent(event.target.valueAsNumber)
  }

  // progressStrokeDashoffset

  // calculate progress circle for applying in rendered callback
  setProgessPercent (value) {
    this.progressCircle.progressVal = value
    let circumfrence = this.progressCircumfrence
    let progress = value / 100
    let dashoffset = circumfrence * (1 - progress)
    this.progressCircle.progressStrokeDashoffset = dashoffset
  }

  // update progress circle (from rendered callback)
  applyProgressRenderedCircle() {
    let progressValue = this.template.querySelector('circle.progress__value')
    if (progressValue && progressValue.style) {
      // eslint-disable-next-line
      console.log('progvalue...', this.progressCircle.progressStrokeDashoffset)
      progressValue.style.strokeDashoffset = typeof this.progressCircle.progressStrokeDashoffset !== 'undefined' ? this.progressCircle.progressStrokeDashoffset : this.progressCircumfrence
      progressValue.style.strokeDasharray = this.progressCircumfrence
      progressValue.style.r = this.progressCircle.radius
      progressValue.style.strokeWidth = this.progressCircle.progressCircle
    }
  }

/*
var control = document.getElementById('control');
var progressValue = document.querySelector('.progress__value');

var RADIUS = 54;
var CIRCUMFERENCE = 2 * Math.PI * RADIUS;

function progress(value) {
    var progress = value / 100;
    var dashoffset = CIRCUMFERENCE * (1 - progress);

    console.log('progress:', value + '%', '|', 'offset:', dashoffset)

    progressValue.style.strokeDashoffset = dashoffset;
}

control.addEventListener('input', function(event) {
    progress(event.target.valueAsNumber);
});

progressValue.style.strokeDasharray = CIRCUMFERENCE;
progress(60);

*/

}