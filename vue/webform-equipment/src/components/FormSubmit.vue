<template>
		 <span>
		 <b-button type="button" @click="finalSubmit" variant="success">Save report</b-button>
		    <b-alert :show="dismissCountDown"
             variant="success"
             @dismissed="dismissCountDown=0"
             @dismiss-count-down="countDownChanged">
		      <p>The report is saved.</p>
		    </b-alert>
		    <b-alert variant="danger"
             dismissible
             :show="showDismissibleAlert"
             @dismissed="showDismissibleAlert=false">
     			Please fill all fields
   			 </b-alert>
		 </span>
</template>

<script>
import {saveInstance} from '../api.js'

export default {

  name: 'FormSubmit',

  props: {
  	completedform: null,
  	type: null,
  	shouldsubmit: false,
  	validation: {},
  	tabIndex: 0,
  	triggerSave: 0,
  },

  data () {
    return {  	
	   	dismissSecs: 2,
	    dismissCountDown: 0,
	    showDismissibleAlert: false,
	    formSubmited: true,
		 EU_type: {
		 "Verification" :{
		 "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
		 "@xsi:schemaLocation": "http://dd.eionet.europa.eu/namespace.jsp?ns_id=802 http://dd.eionet.europa.eu/schemas/fgases-2017/f-gases-equipment-verification-2018.xsd",
		   "Company": {
		      "@status": "confirmed",
		      "CompanyId": null,
		      "CompanyName": null,
		      "Country": {
		      	"Code": null,
		       	"Type": null,
		       	"Name": null
		   		},
		      "VATNumber": null
		    },
		   "Year": null,
		   "EV_3.1": null,
		   "URL": null,
		   "ReportedDate": "2002-05-30T09:00:00",
		   "EV_3.2_a": "EV_3.2_a_1",
		   "EV_3.2_b": "EV_3.2_b_2",
		   "EV_3.2_c": "EV_3.2_c_1",
		   "EV_3.2_d": "EV_3.2_d_2",
		   "EV_3.2_CO2e" : null,
		   		   "ReportFiles": {
		   	"ReportFile": null
		   }
		 }
		},
		NONEU_type: {
		"Verification" :{
		 "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
		 "@xsi:schemaLocation": "http://dd.eionet.europa.eu/namespace.jsp?ns_id=802 http://dd.eionet.europa.eu/schemas/fgases-2017/f-gases-equipment-verification-2018.xsd",
			   "Company": {
			      "@status": "confirmed",
			      "CompanyId": null,
			      "CompanyName": null,
			      "Country": {
			         "Code": null,
			         "Type": null,
			         "Name": null
			      },
			      "VATNumber": null,
			      "EuLegalRepresentativeCompany": {
			         "CompanyId": null,
			         "CompanyName": null,
			         "VATNumber": null
			      }
			   },
			   "Year": null,
 			   "EV_3.1": null,
			   "URL": null,
			   "ReportedDate": "2002-05-30T09:00:00",
			   "EV_3.2_a": "EV_3.2_a_1",
			   "EV_3.2_b": "EV_3.2_b_2",
			   "EV_3.2_c": "EV_3.2_c_1",
			   "EV_3.2_d": "EV_3.2_d_2",
				"EV_3.2_CO2e" : null,			   
				"ReportFiles": {
			   	"ReportFile": null
			   }
		}
	   }

    }
  },
  
  created(){
  	this.updateXMLdata();
  },

  methods: {
  	updateXMLdata(){
	if(this.type == 'EU_TYPE'){
	  		this.EU_type.Verification.Company.CompanyId = this.completedform.company.id
	  		this.EU_type.Verification.Company.CompanyName = this.completedform.company.name
	  		this.EU_type.Verification.Company.VATNumber = this.completedform.company.vat
	  		this.EU_type.Verification.Company.Country.Name = this.completedform.company.address.country.name
	  		this.EU_type.Verification.Year = this.completedform.year[0]
	  		this.EU_type.Verification.URL = this.completedform.url.selected
	  		this.EU_type.Verification.ReportedDate = (this.completedform.reported === 'This will be filled automatically') ? null : this.completedform.reported
	  		this.EU_type.Verification["EV_3.1"] = this.completedform["EV_3.1"].selected
	  		this.EU_type.Verification["EV_3.2_a"] = this.completedform.substances["EV_3.2_a"].selected
	  		this.EU_type.Verification["EV_3.2_b"] = this.completedform.substances["EV_3.2_b"].selected
	  		this.EU_type.Verification["EV_3.2_c"] = this.completedform.substances["EV_3.2_c"].selected
			this.EU_type.Verification["EV_3.2_d"] = this.completedform.substances["EV_3.2_d"].selected
			this.EU_type.Verification["EV_3.2_CO2e"] = this.completedform["EV_3.2_CO2e"]
	  		this.EU_type.Verification.ReportFiles.ReportFile =  this.escapeSpaces(this.completedform.fileUploaded)


	  	}else {
	  		this.NONEU_type.Verification.Company.CompanyId = this.completedform.company.id
	  		this.NONEU_type.Verification.Company.CompanyName = this.completedform.company.name
	  		this.NONEU_type.Verification.Company.Country.Name = this.completedform.company.address.country.name
	  		this.NONEU_type.Verification.Company.EuLegalRepresentativeCompany.VATNumber = this.completedform.company.euLegalRepresentativeCompany.vatNumber
	  		 this.NONEU_type.Verification.Company.EuLegalRepresentativeCompany.CompanyName = this.completedform.company.euLegalRepresentativeCompany.name
	  		this.NONEU_type.Verification.Year = this.completedform.year[0]
	  		this.NONEU_type.Verification.URL = this.completedform.url.selected
	  		this.NONEU_type.Verification.ReportedDate =  (this.completedform.reported === 'This will be filled automatically') ? null : this.completedform.reported
	  		this.NONEU_type.Verification["EV_3.1"] = this.completedform["EV_3.1"].selected
	  		this.NONEU_type.Verification["EV_3.2_a"] = this.completedform.substances["EV_3.2_a"].selected
	  		this.NONEU_type.Verification["EV_3.2_b"] = this.completedform.substances["EV_3.2_b"].selected
	  		this.NONEU_type.Verification["EV_3.2_c"] = this.completedform.substances["EV_3.2_c"].selected
			this.NONEU_type.Verification["EV_3.2_d"] = this.completedform.substances["EV_3.2_d"].selected
			this.EU_type.Verification["EV_3.2_CO2e"] = this.completedform["EV_3.2_CO2e"]			  
	  		this.NONEU_type.Verification.ReportFiles.ReportFile =  this.escapeSpaces(this.completedform.fileUploaded)
	  		
	  	}
	  },

	  escapeSpaces(filesArray){
	  	let newFilesArray = [];
	  	for (let file of filesArray) {
	  		newFilesArray.push(file.replace(/ /g, "%20"))
	  	}
	  	return newFilesArray
	  },

	  finalSubmit(saved_from_tabs){
	  	console.log(this.shouldsubmit)
		  	if(saved_from_tabs != 1) {
		  		this.showAlert()
		  	}
		  	if(this.type == 'EU_TYPE'){ 
		  		this.formSubmited = true;
		  		console.log(this.EU_type)
		  		saveInstance(this.EU_type)
		  		// console.log(saveInstance(this.EU_type))
		  	} else {
		  		this.formSubmited = true;
		  		console.log(this.NONEU_type)
		  		saveInstance(this.NONEU_type)
		  		// console.log(saveInstance(this.NONEU_type))
		  	}
	  },

	  isvalidated(){
	  	let validation = this.validation
	  	let validated = false
	  	for(let item in validation){
	  		if (validation[item] === null) {
	  			validated = false
	  			break
	  		}else{
	  		 validated = true
	  		}
	  	}
	  	if(validated === true && this.shouldsubmit === true){	
	    	this.showDismissibleAlert = false
	  	}
	  return validated
	  },
	countDownChanged (dismissCountDown) {
      this.dismissCountDown = dismissCountDown
    },
    showAlert () {
	    this.dismissCountDown = this.dismissSecs
    },
  },

  watch: {
  	completedform: {
  		handler: function(after, before){
  			this.updateXMLdata()
		  	this.formSubmited = false;
  			this.$emit('formchanged', this.formSubmited)
  		},
  		deep: true,
  	},
  	formSubmited: {
  		handler: function(after, before){
  			this.$emit('formchanged', this.formSubmited)
  		},
  		deep: true,
  	},
  	validation: {
  		handler: function(after, before){
  			this.isvalidated()
  		},
  		deep: true,
  	},
  	tabIndex: {
  		handler: function(after, before){
  			this.finalSubmit(1);
  		},
  		deep: true,
  	},
  	 shouldsubmit: {
  		handler: function(after, before){
  			this.isvalidated()
  		},
  		deep: true,
  	},
  	triggerSave: {
  		handler: function(after, before){
  			this.finalSubmit();
  		},
  		deep: true,
  	}
  },

}
</script>

<style lang="css" scoped>
.alert {
	position: fixed;
	top:3rem;
	left: 20%;
	right: 20%;
}
.btn.btn-success {
	    border-top-left-radius: 0;
    border-bottom-left-radius: 0;
}
</style>