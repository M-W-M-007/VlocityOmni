import { LightningElement,api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
export default class ListOfCountries_Demo extends OmniscriptBaseMixin(LightningElement) {
    @api listCountries = [];
    setAllCountries;
    alldata;
    connectedCallback() {
        //code
        this.alldata = JSON.parse(JSON.stringify(this.omniJsonData));
        this.listCountries = this.alldata.Country;
       
        this.setAllCountries = new Set();
        this.listCountries.forEach(item => this.setAllCountries.add(item))
        
    }
    selectionChangeHandler(event) {		
        var filteredJSON = this.alldata.Output.Account.filter(item => item.Country == event.target.value);        
        filteredJSON ='{ "Output": { "Account":'+JSON.stringify(filteredJSON)+'}} ';        
        this.omniApplyCallResp(JSON.parse(filteredJSON));     

	}
    


}