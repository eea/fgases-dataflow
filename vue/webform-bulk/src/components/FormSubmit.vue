<template>
	<span>
		<b-button type="button" @click="finalSubmit" variant="success">Save</b-button>
	 	<b-alert :show="dismissCountDown"
	     variant="success"
	     @dismissed="dismissCountDown=0"
	     @dismiss-count-down="countDownChanged">
	      <h1 style="color: black; font-weight: bold;">Questionnaire is saved</h1>
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
  	tabIndex: 0,
  	triggerSave: 0,
  },

 
  data () {
    return {
  		shouldsubmit: true,
    	dismissSecs: 2,
	    formSubmited: true,
	    dismissCountDown: 0,
	    showDismissibleAlert: false,
		 EU_type: {
		 "Verification" :{
		 "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
		 "@xsi:schemaLocation": "http://dd.eionet.europa.eu/namespace.jsp?ns_id=802 http://dd.eionet.europa.eu/schemas/fgases-2019/f-gases-bulk-verification-2018.xsd",
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
			"NILReport": null,
		   "URL": null,
		   "ReportedDate": "2002-05-30T09:00:00",
		   "BV_9F": null,
		   "BV_5C": null,
		   "BV_10A": null,
		   "ReportFiles": {
		   	"ReportFile": null
		   }
		 }
		},
		NONEU_type: {
		"Verification" :{
		 "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
		 "@xsi:schemaLocation": "http://dd.eionet.europa.eu/namespace.jsp?ns_id=802 http://dd.eionet.europa.eu/schemas/fgases-2019/f-gases-bulk-verification-2018.xsd",
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
				"NILReport": null,
			   "URL": null,
			   "ReportedDate": null,
			   "BV_9F": null,
			   "BV_5C": null,
			   "BV_10A": null,
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
        this.EU_type.Verification.Year = this.completedform.yearValue.selected
        this.EU_type.Verification.NILReport = !this.completedform.notNILReport
	  		this.EU_type.Verification.URL = this.completedform.url.selected
        this.EU_type.Verification.ReportedDate = this.completedform.reported
        if (!this.completedform.notNILReport) {
          this.EU_type.Verification.BV_9F = ""
	  		  this.EU_type.Verification.BV_5C = ""
	  		  this.EU_type.Verification.BV_10A = ""
	  		  this.EU_type.Verification.ReportFiles.ReportFile = ""
        } else {
          this.EU_type.Verification.BV_9F = this.completedform.substances.BV_9F.selected
	  		  this.EU_type.Verification.BV_5C = this.completedform.substances.BV_5C.selected
	  		  this.EU_type.Verification.BV_10A = this.completedform.substances.BV_10A.selected
	  		  this.EU_type.Verification.ReportFiles.ReportFile = this.escapeSpaces(this.completedform.fileUploaded)
        }
	  	} else {
	  		this.NONEU_type.Verification.Company.CompanyId = this.completedform.company.id
	  		this.NONEU_type.Verification.Company.CompanyName = this.completedform.company.name
	  		this.NONEU_type.Verification.Company.Country.Name = this.completedform.company.address.country.name
			if (this.completedform.company.euLegalRepresentativeCompany !== null) {
				this.NONEU_type.Verification.Company.EuLegalRepresentativeCompany.VATNumber = this.completedform.company.euLegalRepresentativeCompany.vatNumber
				this.NONEU_type.Verification.Company.EuLegalRepresentativeCompany.CompanyName = this.completedform.company.euLegalRepresentativeCompany.name
			}
        this.NONEU_type.Verification.NILReport = !this.completedform.notNILReport
	  		this.NONEU_type.Verification.Year = this.completedform.yearValue.selected
	  		this.NONEU_type.Verification.URL = this.completedform.url.selected
	  		this.NONEU_type.Verification.ReportedDate = this.completedform.reported
        if (!this.completedform.notNILReport) {
          this.NONEU_type.Verification.BV_9F = ""
	  		  this.NONEU_type.Verification.BV_5C = ""
	  		  this.NONEU_type.Verification.BV_10A = ""
	  		  this.NONEU_type.Verification.ReportFiles.ReportFile = ""
        } else {
          this.NONEU_type.Verification.BV_9F = this.completedform.substances.BV_9F.selected
	  		  this.NONEU_type.Verification.BV_5C = this.completedform.substances.BV_5C.selected
	  		  this.NONEU_type.Verification.BV_10A = this.completedform.substances.BV_10A.selected
	  		  this.NONEU_type.Verification.ReportFiles.ReportFile = this.escapeSpaces(this.completedform.fileUploaded)
        }
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
	  	if(this.shouldsubmit){
		  	if(saved_from_tabs != 1) {
		  		this.showAlert()
		  	}
		  	
		  	if(this.type == 'EU_TYPE'){ 
		  		this.formSubmited = true;
		  		console.log(this.EU_type)
		  		saveInstance(this.EU_type)
		  	} else {
		  		this.formSubmited = true;
		  		console.log(this.NONEU_type)
		  		saveInstance(this.NONEU_type)
		  	}
	  	} else {
	  		alert('THE URL IS INVALID')
	  	}
	  },
	 countDownChanged (dismissCountDown) {
      this.dismissCountDown = dismissCountDown
    },
    showAlert () {
    	console.log('showingalert')
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
  	tabIndex: {
  		handler: function(after, before){
  			this.finalSubmit(1);
  		},
  		deep: true,
  	},
  	formSubmited: {
  		handler: function(after, before){
  			this.$emit('formchanged', this.formSubmited)
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
.alert.alert-success {
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
