import { LightningElement, track, api } from 'lwc';
export default class Lwc_csm_ratings extends LightningElement {
    @api readOnly;
    @api rating;
    @track hasRendered = true;
    colorOn = "#F6BF25";
    colorOff = "#C9C9C4";
    strokeWidth =  3;
    stroke = "none";
    maxRating = 5;
    renderedCallback() {
        if(this.hasRendered && this.readOnly) {
            var rating = this.rating;
            if(rating <= this.maxRating) {
                var colorOn = this.colorOn; 
                var i; 
                for(i = 0; i < rating; i++) {
                    var nthElement = i+1;
                    this.template.querySelector('.star:nth-child('+nthElement+')').style.fill = colorOn;
                }
            }
        }
    }

    starClick(event) {
        if(!this.readOnly) {
            var colorOn = this.colorOn; 
            var colorOff = this.colorOff; 
            var svg = event.target;
            var rating = 0;
            while (svg) {
                rating++;
                svg.style.fill = colorOn;
                svg = svg.previousElementSibling;    		        
            }
            svg = event.target.nextElementSibling;
            while (svg) {
                svg.style.fill = colorOff;
                svg = svg.nextElementSibling;    		        
            }
            this.rating = rating;
        }
    }
}