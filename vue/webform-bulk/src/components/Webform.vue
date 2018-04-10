<template>
  <b-container style="position: relative">
  <div class="axiosLoader" v-if="isLoading === true">
    <div id="circlesLoader">
    <div class="circle">
        <div class="innerRing">
            
        </div>
    </div>
    <div id="firstCircle">
        <div id="secondCircle">
            <div id="thirdCircle">
                
            </div>
        </div>
    </div>
    </div>
  </div>
  <div v-else-if="isCompany && !isLoading">
      <b-card no-body>
        <b-tabs card v-model="tabIndex" v-if="form.company != null">
          <b-tab title="Company Details" active>
            <h2>Identification of company, year and relevant Article 19 report</h2>
            <p>
              The verified report was drawn up for the following undertaking:
            </p>
            
            <br>
            <b-row>
              <b-col class="bold" lg="5">Company name</b-col>
              <b-col>{{form.company.name}}</b-col>
            </b-row>
            <b-row>
              <b-col class="bold" lg="5">Registration ID in the HFC Registry</b-col>
              <b-col>{{form.company.id}}</b-col>
            </b-row>
            <div v-if='type === "EU_TYPE"'class="text-left">
              <b-row>
                <b-col class="bold" lg="5">VAT-No.: </b-col>
                <b-col>{{form.company.vat}}</b-col>
              </b-row>
            </div>
            <div v-else>
              <b-row>
                <b-col class="bold" lg="5">Country of establishment</b-col>
                <b-col>{{form.company.address.country.name}}</b-col>
              </b-row>
              <b-row>
                <b-col class="bold" lg="5">Name of mandated only representative established within the EU for the purpose of compliance with the requirements of Regulation (EU) No 517/2014:  </b-col>
                <b-col>{{form.company.euLegalRepresentativeCompany.address.country.name}}</b-col>
              </b-row>
              <b-row>
                <b-col class="bold" lg="5">VAT-No. of only representative: </b-col>
                <b-col>{{form.company.euLegalRepresentativeCompany.vatNumber}}</b-col>
              </b-row>
            </div>
            <b-row>
                <b-col class="bold" lg="5">Year</b-col>
                <b-col lg="2"><b-form-select :value="form.year[0]" :options="form.year" disabled /></b-col>
            </b-row>
   

            <b-row style="margin-top: 2rem;">
              <p>
              </p>
              <b-col class="bold" lg="5">Please specify the data report pursuant to Article 19 of Regulation (EU) No 517/2014 to which the verification report <span class="letooltip" title="Please make sure that the correct Art. 19 data report is identified to which the verification report refers because it is possible to have a number of submissions (updates) of the Art. 19 data report in the BDR.">refers</span>.
                (report URL in the EEA’s business data repository, submission date and time):</b-col>
              <b-col lg="5">
                <b-input-group class="mt-2">
                  <b-form-select v-model="form.url.selected" @change="validateURL($event)" :options="form.url.options" placeholder="Enter URL"/> 
                </b-input-group>
                <b-badge class="url-badge" v-if="isValidUrl" variant="success">Submission is valid</b-badge>
                <b-badge class="url-badge"  v-else variant="danger">Please choose a valid submission</b-badge>
                <div>Chosen submission: </div> <strong><a target="_blank" :href="form.url.selected">{{form.url.selected}}</a></strong>
              </b-col>
            </b-row>

             <b-row>
              <b-col class="bold" lg="5">Date and time reported </b-col>
              <b-col v-html="form.reported"></b-col>
            </b-row>
          </b-tab>
          <b-tab title="Form" >
            <h2>Substance of Verification</h2>
            <p>Please specify below the independent auditor’s conclusions in the verification <span class="letooltip" title="Please make sure that the correct BDR data report is identified to which the verification report refers, in case of repeated submissions (updates) of the BDR data report">report</span> :</p>
            <b-form v-if="form">

            <b-form-group v-for="(substance,key) in form.substances" :key="key">
              <label>
                <span style="background: rgb(238, 238, 238);
                                  border: 1px solid rgb(170, 170, 170);
                                  font-size: 0.7rem;
                                  padding: 0.3rem;
                                  margin-right: 0.5rem;
                                  border-radius: 100rem;
                                  vertical-align: middle;">
                ({{key}}) 
                </span>
                <strong>{{substance.description}}</strong>
              </label>
              <b-form-checkbox-group stacked :options="substance.options" v-model="substance.selected">
              </b-form-checkbox-group>
              <br>
            </b-form-group>
            <!-- <b-button type="reset" @click="onReset" variant="danger">Reset</b-button> -->
          </b-form>
          </b-tab>
          <b-tab title="Upload">
            <h2>Upload of verification report</h2>
            <p>Click here to upload the verification report that was provided by your auditor:</p>
            <div style="position: relative">
              <div class="axiosLoader-file" v-if="fileIsUploading === true">
                  <div id="circlesLoader">
                  <div class="circle">
                      <div class="innerRing">
                          
                      </div>
                  </div>
                  <div id="firstCircle">
                      <div id="secondCircle">
                          <div id="thirdCircle">
                              
                          </div>
                      </div>
                  </div>
                  </div>
                </div>
              <b-input-group>
                  <template slot="prepend">
                    <b-badge class="upload-badge" variant="success" v-show="form.fileUploadedState && !form.file">✓ Uploaded</b-badge>
                  </template>
                <b-form-file v-model="form.file" :state="Boolean(form.file)" placeholder="Choose a file..."></b-form-file>
                <template slot="append">
                  <b-button v-if="form.file" type="button" @click="uploadFormFile" variant="primary">Upload file</b-button>
                </template>
              </b-input-group>
            </div>
            <div  v-if="form.fileUploaded.length" class="mt-3">
               <div> 
                Files already in envelope:
               </div>
                <b-list-group style="color: #0069d9;" v-if="form.fileUploaded.length">
                  <b-list-group-item  v-for="file in form.fileUploaded" >
                   <a target="_blank" :href="file">{{removeEnvelopeFromFiles(file)}}</a> 
                  </b-list-group-item>
                </b-list-group>
            </div>
          </b-tab>
         <!--  <b-tab title="Submit">
          </b-tab> -->
        </b-tabs>
        <div class="tab-navigation">
        <b-button-group class="mt-3 mb-3" style="width: 100%; justify-content: flex-end; padding-right: 2rem;">
          <b-btn @click="printForm()" variant="default">Print</b-btn>
          <b-btn @click="closeReport()" variant="danger"> Close report and proceed to BDR </b-btn>
            <submit v-on:formchanged="handleFormChange($event)" :triggerSave="triggerSave" :tabIndex="tabIndex" :completedform="form" :type="type"></submit>
        </b-button-group>
          <b-button-group class="tabs-control">
          <b-btn :disabled="tabIndex === 0" @click="tabIndex--">Previous</b-btn>
          <b-btn :disabled="tabIndex === 2" @click="tabIndex++">Next</b-btn>
        </b-button-group>
      </div>
      <small style="padding-left: 1rem;" v-if="isie">Some features of this form might not work properly on Internet Explorer. Please use another browser.</small>
      </b-card>
  </div>
  <div v-else-if="!isCompany && !isLoading">
      <b-alert variant="danger" show>Error loading form. Please check if your envelope is valid</b-alert>
  </div>
  </b-container>
</template>



<script>

import {isTestSession, getCompanyData, companyId,getInstance, getEnvelopeXML, envelope, getURLlist, uploadFile, getSupportingFiles} from '../api.js';
import formSubmit from './FormSubmit'
import {envelopexml} from '../assets/envelopexml.js';


const xml = require("xml-parse");

export default {
  name: 'webform',

 components:{submit: formSubmit},

  data () {
    return {
      isie: false,
      fileIsUploading: false,
      triggerSave: 0,
      tabIndex: 0,
      isLoading: true,
      isValidUrl: false,
      isCompany: false,
      hasFiles: false,
      formSaved: false,
      type: null,
      form: {
        file: null,
        fileUploadedState: false,
        fileUploaded: [],
        company: {},
        year: [],
        url: {
          selected: null,
          options: []
        },
        reported: '<span class="italic">Will be filled automatically</span>',
        file: null,
        substances: {
          BV_9F: {
            selected: 'BV_9F_5',
            options: [
             {text: 'The quota need as given in section 9F is fully confirmed.', value: 'BV_9F_1'},
             {text: 'The verification report concludes in a higher quota need than given in 9F.', value:'BV_9F_2'},
             {text: 'The verification report concludes in a lower quota need than given in 9F.', value:'BV_9F_3'},
             {text: 'The verification report does not make any statement as regards the quota need.', value:'BV_9F_4'},
             {text: null, value:'BV_9F_5'}
            ],
            description:'Total calculated need of quota for hydrofluorocarbons placed on the market,as given in section 9F of the Art. 19 data report identified above '
          }
            ,
          BV_5C: {
          selected: 'BV_5C_5',
            options: [
            {text: 'No amounts were reported in section 5C_exempted.', value:'BV_5C_1'},
            {text: 'The verification report fully confirms the amounts reported in section 5C_exempted.',value: 'BV_5C_2'},
            {text: 'The verification report does NOT fully confirm the amounts reported in section 5C_exempted.', value: 'BV_5C_3'},
            {text:  'The verification report does not make a statement as regards the amounts reported in section 5C_exempted.', value: 'BV_5C_4'},
            {text: null, value: 'BV_5C_5'},
          ],
          description:'Quantity supplied directly to undertakings for export out of the Union, where those quantities were not subsequently made available to another party within the Union prior to export, as given in section 5C_exempted of the Art. 19 data report identified above',
        },
          BV_10A:{
            description: 'Amounts of gas physically supplied by a new entrant quota holder which are linked to authorisations given to importers of refrigeration, air conditioning and heat pump equipment charged with hydrofluorocarbons,as given in section 10A of the Art. 19 data report identified above ',
          options: [
            {text: 'No amounts were reported in section 10A.', value: 'BV_10A_1'},
            {text: 'The verification report fully confirms the amounts reported in section 10A.', value:'BV_10A_2'},
            {text: 'The verification report does NOT fully confirm the amounts reported in section 10A. ',value: 'BV_10A_3'},
            {text: 'The verification report does not make a statement as regards the amounts reported in section 10A.', value: 'BV_10A_4'},
            {text: null, value: 'BV_10A_5'},
          ],
          selected: 'BV_10A_5',
          } 
        }
      },
    }
  },
created(){

this.checkforIe();

 if(!isTestSession){
     getCompanyData(companyId)
          .then((response) => {
            this.form.company = response.data;
            this.type = response.data.address.country.type
            this.isCompany = true;
              getURLlist()
                  .then((response) => {
                    if(response.data){
                      this.form.url.options = response.data
                      getInstance().then((response) => {
                        this.prefillForm(response.data)
                        this.isLoading = false;
                      })
                    } else {
                      getInstance().then((response) => {
                        this.prefillForm(response.data)
                        this.isLoading = false;
                      })
                    }
                  });
            });
    }else {
      this.form.url.options = getURLlist()
      this.isCompany = true;
      this.form.company = getCompanyData(companyId)
      this.type = this.form.company.address.country.type
      this.prefillForm(getInstance())
      this.isLoading = false;
    }
    const date = new Date()
    const year = date.getFullYear();
    this.form.year = [year - 1];
  },

  methods: {
  isLast(object, index){
      if(Object.keys(object).length -1 === index) {
        return true
      }
  },

  removeEnvelopeFromFiles(file){
    let returnFile = file.split('/')
    return returnFile[returnFile.length -1]
  },

   checkforIe() {
    var userAgent = navigator.userAgent;
    var useragentbol =  userAgent.indexOf("MSIE ") > -1 || userAgent.indexOf("Trident/") > -1 || userAgent.indexOf("Edge/") > -1;
    this.isie = useragentbol;
  },

  uploadFormFile(){
    this.fileIsUploading = true;
    let file = new FormData()
    file.append('userfile', this.form.file)
    uploadFile(file).then((response) => {
      console.log(response)
      this.form.fileUploaded = [];
      getSupportingFiles().then((response) => {
        let files = []
        for(let file of response.data) {
          this.pushUnique(files, envelope + '/' + file)
        }
        this.hasFiles = true;
        this.form.fileUploaded =  files
        this.form.fileUploadedState = true;
        this.form.file = null;
        this.fileIsUploading = false;
        this.triggerSave += 1;
      })
    }).catch((error) => {
      console.log(error)
      this.form.fileUploadedState = false;
      this.fileIsUploading = true;
    })
  },



  handleFormChange(e) {
    if(e === false) {
      this.formSaved = false
    } else {
      this.formSaved = true
    }
  },

 pushUnique(array, item) {
      if (array.indexOf(item) === -1) {
        array.push(item);
      }
    },

  validateURL(url){
    if(!isTestSession){ 
      getEnvelopeXML(url).then((response) => {
      const validationXML = xml.parse(response.data)
      const obligation = validationXML[1].childNodes[5].childNodes[0].text
      const link = validationXML[1].childNodes[6].childNodes[0].text
      const file_schema = validationXML[1].childNodes[10].attributes.schema
      this.form.reported = validationXML[1].childNodes[2].childNodes[0].text
      const validatedLink = this.validateLink(link)
      if(obligation === 'http://rod.eionet.europa.eu/obligations/713' && validatedLink && file_schema === 'http://dd.eionet.europa.eu/schemas/fgases-2017/FGasesReporting.xsd'){
        this.isValidUrl = true;
        console.log('isvalid', this.isValidUrl)
      }else {
        this.isValidUrl = false;
        console.log('isValidUrl', this.isValidUrl)
      }
      }).catch((error) => {
            console.log(error);
      });
    } else{
      const validationXML = xml.parse(envelopexml())
      const obligation = validationXML[1].childNodes[5].childNodes[0].text
      const link = validationXML[1].childNodes[6].childNodes[0].text
      const file_schema = validationXML[1].childNodes[10].attributes.schema
      this.form.reported = validationXML[1].childNodes[2].childNodes[0].text
      const validatedLink = this.validateLink(link)
      if(obligation === 'http://rod.eionet.europa.eu/obligations/713' && validatedLink && file_schema === 'http://dd.eionet.europa.eu/schemas/fgases-2017/FGasesReporting.xsd'){
        this.isValidUrl = true;
      }
    }
  },

  prefillForm(data){
        this.form.substances.BV_9F.selected =  data.Verification.BV_9F 
        this.form.substances.BV_5C.selected = data.Verification.BV_5C 
        this.form.substances.BV_10A.selected = data.Verification.BV_10A 
        this.form.url.selected = data.Verification.URL
        this.form.fileUploaded = [];
        getSupportingFiles().then((response) => {
          if(response.data.length){            
            this.hasFiles = true;
            let files = []
              for(let file of response.data) {
                this.pushUnique(files, envelope + '/' + file)
              }
              this.form.fileUploaded =  files
          } else {
            this.hasFiles = false;
          }
        })
        this.validateURL(data.Verification.URL)
  },

  validateLink(link){
    // if link validation is necessarry, place it here

    // let link_arr = link.split('/')
    // if(link_arr[3] === 'fgases' && link_arr[5]/1 == link_arr[5]){
    //   return true
    // }else {
    //   return false
    // }
    return true
  },
  closeReport(){
    console.log('-------------------CLOSE REPORT -----------------')
    console.log('validurl', this.isValidUrl)
    console.log('hasfiles', this.hasFiles)
      if(this.formSaved === false) {
       let r = confirm('You did not save your last modifications. Are you sure you want to leave without saving ?')
           if (r == true) {
              window.location.href = envelope
            } else {      
              return
            }

        } else {
            if(this.isValidUrl && this.hasFiles) {
              let r = confirm('The questionnaire is valid. This action will take you back to the envelope. Are you sure you want to leave ?')
                 if (r == true) {
                    window.location.href = envelope
                  } else {
                    return
                  }
            } else {
              let r = confirm('Please note that the questionnaire has not yet been completed or the verification document has not yet been uploaded. In its present state, the envelope is not yet fit for submission. Are you sure you want to leave ?')
                  if (r == true) {
                    window.location.href = envelope
                  } else {
                    return
                  }
            }
    }

  },

  printForm(){
    window.print()
  },


  onSubmit(){
      console.log('submit')
    },
    onReset(){
      console.log('reset')
    },
  },
  watch: {
    'form.substances.BV_9F.selected': {
      handler: function(after, before){
        if(after === false) {
          this.form.substances.BV_9F.selected = 'BV_9F_5'
        }
      },
      deep: true,
    },
    'form.substances.BV_5C.selected': {
      handler: function(after, before){
        if(after === false) {
          this.form.substances.BV_5C.selected = 'BV_5C_5'
        }
      },
      deep: true,
    },
    'form.substances.BV_10A.selected': {
      handler: function(after, before){
        if(after === false) {
          this.form.substances.BV_10A.selected = 'BV_10A_5'
        }
      },
      deep: true,
    },
    'from.url.selected': {
      handler: function(after, before){
          console.log('after',after)
      },
      deep: true,
    }
  },

 

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.tab-navigation {
/*  position: absolute;
    top: 0;
    right: 2rem;
    z-index: 1;*/
        /*position: fixed;*/
    /*bottom: 0;*/
    /*left: 0;*/
    /*z-index: 1;*/
    /* width: 100%; */
    /*right: 0;*/
    /*background: white;*/
    /*box-shadow: 2px -1px 3px #aaa;*/
}
.bold {
  font-weight: bold;
  text-align: right;
}
.custom-select {
  background: white!important;
}

.axiosLoader {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background: rgba(0,0,0,0.5)
}


.axiosLoader-file {
    position: absolute;
    left: 50%;
    transform: translateX(-50%) scale(0.5);
    z-index: 100;
    top: -4rem;
}


.url-badge  {
    position: absolute;
    bottom: 100%;
    left: 15px;
}


/*ajax-loader*/

div#circlesLoader *{
  box-sizing: content-box;
}


div#circlesLoader
  {
    zoom:3;
    width: 50px;
    height: 50px;
    margin: auto;
        transform: translate(-30%, -50%);
  }

div#circlesLoader div#firstCircle
  {
    width: 100%;
    height: 100%;
    border: 4px solid #000;
    border-radius: 50%;
    border-top-color: transparent;
    border-bottom-color: transparent;
    position: relative;
  }
  
div#circlesLoader div#secondCircle
  {
    height: 80%;
    width: 80%;
    border: 3px solid #333;
    border-radius: 50%;
    border-top-color: transparent;
    border-right-color: transparent;
    position: relative;
    top: 2px;
    left: 2px;
  }
  
div#circlesLoader div#thirdCircle
  {
    height: 80%;
    width: 80%;
    border: 3px solid #00446a;
    border-radius: 50%;
    border-bottom-color: transparent;
    border-left-color: transparent;
    position: relative;
    top: 1px;
    left: 1px;
  }
  
div#circlesLoader div#firstCircle, div#circlesLoader div#secondCircle, div#circlesLoader div#thirdCircle
  {
    animation: spin 2s linear infinite;
  }
  
div#circlesLoader div.circle
  {
    position: relative;
    height: 20px;
    width: 20px;
    border-radius: 50%;
    border: none;
    background: #00446a;
    top: 39px;
    left: 19px;
  }
  
div#circlesLoader div.circle div.innerRing
  {
    border: 1px solid #00446a;
    background: #333;
    height: 50%;
    width: 50%;
    border-radius: 50%;
    position: relative;
    top: 4px;
    left: 4px;
    animation: ajaxLoader 1s ease-in-out infinite;
  }
  
@keyframes spin
  {
    0%
      {
        transform: rotate(0deg);      
      }
      
    100%
      {
        transform: rotate(360deg);
      }
  }

  .upload-badge {
    border-radius: 0;
    align-items: center;
    display: flex;
  }

  .tabs-control {
    position: absolute;
    top: 6px;
    right: 6px;
  }

</style>
