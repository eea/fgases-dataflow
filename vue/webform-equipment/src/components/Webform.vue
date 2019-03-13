<template>
  <b-container style="position: relative">
  <!-- <h1>F-Gas Regulation - Verification and submission of the verification document for importers of equipment</h1> -->
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
              The verified declaration(s) of conformity were drawn up by the following <span class="letooltip" title="In case the undertaking is both a manufacturer of equipment addressed by Article 2(1) of Commission Implementing Regulation (EU) No 879/2016 and an importer addressed by Article 2(2) of that Regulation, this statement applies only to the undertaking’s activities and obligations as an importer.">importer</span> of equipment:
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

            <b-form v-if="form">
              <b-form-group style="position: relative">
              <b-row>
                <b-col class="bold" lg="5"><label v-html='form["EV_3.1"].description'></label></b-col>
                <b-col lg="4"> 
                  <b-form-radio-group inline @change="validateField('EV_3.1')" :options="form['EV_3.1'].options" v-model="form['EV_3.1'].selected">
                     <div class="status">
                        <div class="validStatus" v-if="!validation['EV_3.1']" title="please select an option">*</div>
                    </div>
                </b-form-radio-group>
                </b-col>
              </b-row> 
              </b-form-group>

              <b-row v-if="form['EV_3.1'].selected === 'EV_3.1_1'">
                 <b-col class="bold" lg="5">Please specify the data report pursuant to Article 19 of Regulation (EU) No 517/2014 to which the verification report <span class="letooltip" title="Please make sure that the correct Art. 19 data report is identified to which the verification report refers because it is possible to have a number of submissions (updates) of the Art. 19 data report in the BDR.">refers</span>.
                (report URL in the EEA’s business data repository, submission date and time):</b-col>
                 <b-col lg="5">
                <b-input-group class="mt-2">
                  <b-form-select v-model="form.url.selected" @change="validateURL($event)" :options="form.url.options" placeholder="Enter URL"/>
                </b-input-group>
                <b-badge class="url-badge" v-if="isValidUrl" variant="success">Submission is valid</b-badge>
                <b-badge class="url-badge" v-else variant="danger">Please choose a valid submission</b-badge>
                <div>Chosen submission: </div> <strong><a target="_blank" :href="form.url.selected">{{form.url.selected}}</a></strong>
              </b-col>
              </b-row>
             <b-row v-if="form['EV_3.1'].selected === 'EV_3.1_1'">
              <b-col class="bold" lg="5">Date and time reported </b-col>
              <b-col>{{form.reported}}</b-col>
            </b-row>
            </b-form>


          </b-tab>
          <b-tab title="Form" >
            <h2>
              Substance of Verification
            </h2>
          <p>  
          Please specify below <strong>the independent auditor’s statement</strong> on the following information about the importer of the equipment:
          </p>

         <b-form v-if="form">

              <b-form-group style="position: relative;"  v-for="(substance,key) in form.substances" :key="key">
               <label v-html="substance.description"></label>
                <span style="display: inline;background: #eee;  border: 1px solid #aaa; font-size: .8rem; padding: .4rem; margin-right: .5rem;border-radius: 100rem;">({{key}})</span>
                <b-form-radio-group style="display: inline;" @change="validateField(key)" required inline :options="substance.options" v-model="substance.selected">
                <div class="status">
                  <div class="validStatus" v-if="!validation[key]" title="please select an option">*</div>
                </div>
                <br>
                </b-form-radio-group>
                <div v-if="substance.notes" v-html="substance.notes"></div>
              </b-form-group>
              <div>
                  <p><strong>Only for companies below the 500t CO2e threshold for the reporting obligation under Art 19 of the F-gas Regulation:</strong> Please enter the amount of quota authorisations (in t CO2e, rounded to the closest full tonne), as confirmed in the independent auditor’s report, and required to cover the HFCs you placed on the market contained in imported refrigeration, air conditioning or heat pump equipment, in the calendar year this submission refers to.</p>                
                  <b-form-input v-model="form['EV_3.2_CO2e']"
                      type="number" step="1" min="0" oninput="this.value = this.value.replace('.', '');"
                      v-on:blur.native="showModal"
                      placeholder="Enter value"></b-form-input>
                  <b-modal v-model="modalShow" hide-header="true" ok-only >
                      You entered an authorisation demand of 500 t CO2e or above. In this case, please make sure to submit a report pursuant to Article 19 of Regulation (EU) No 517/2014 covering Sections 11, 12, and 13 of the reporting forms.”
                  </b-modal>                      
              </div>

              <!-- <b-button type="reset" @click="onReset" variant="danger">Reset</b-button> -->
            </b-form>

          </b-tab>
          <b-tab title="Upload">
            <h2>Upload of verification report</h2>
            <p>Click here to upload the verification report that was provided by your auditor:</p>
            <div style="position: relative;">
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
              <submit v-on:formchanged="handleFormChange($event)" :tabIndex="tabIndex" :triggerSave="triggerSave" :completedform="form" :type="type"></submit>
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
import {ConstantValues} from '../assets/consts.js';



const xml = require("xml-parse");

export default {
  name: 'webform',

 components:{submit: formSubmit},

  data () {
    return {
      isie: false,
      fileIsUploading: false,
      triggerSave: 0,
      validation: {
         "EV_3.1": null,
         "EV_3.2_a": null, 
         "EV_3.2_b": null,
         "EV_3.2_c": null,
         "EV_3.2_d": null
      },
      formIsValid: false,
      tabIndex: 0,
      isLoading: true,
      hasFiles: false,
      formSaved: false,
      isValidUrl: true,
      isCompany: false,
      modalShow : false,
      type: null,
      art19_pursuant: '',
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
        reported: 'This will be filled automatically',
        file: null,

        "EV_3.1":{
          selected: null,
          options: [
            {text: 'yes', value:'EV_3.1_1'}, {text:'no', value: 'EV_3.1_2'}
          ],
          description: 'A report pursuant to Article 19 of Regulation (EU) No 517/2014 covering Sections 11, 12, and 13 of the reporting forms for the calendar year specified above was submitted by the importer of equipment:'
        },

        substances: {
          "EV_3.2_a": {
            selected: null,
            options: [
             {text: 'Yes', value: 'EV_3.2_a_1'},
             {text: 'No', value:'EV_3.2_a_2'}
            ],
            description:'(a) The information contained in the declaration(s) of conformity and the related documents is consistent with the report pursuant to Article 19 of Regulation (EU) No 517/2014 :',
            notes: null
          }
            ,
          "EV_3.2_b": {
          selected: null,
            options: [
            {text: 'Yes.', value:'EV_3.2_b_1'},
            {text: 'No',value: 'EV_3.2_b_2'}
          ],
          description:"(b) The information contained in the declaration(s) of conformity and the related <span class='letooltip' title='The related documents are specified in Article 2(2) of Implementing Regulation (EU) No 879/2016 and do for example include customs documentation.'>documents</span> is accurate and complete on the basis of the undertaking's records of relevant transactions, with a reasonable level of assurance:",
        },
          "EV_3.2_c":{
            description: '(c) In the HFC registry, by 31 December of the calendar year specified above there was sufficient availability of authorisations for all cases where <span class="letooltip" title="According to Annex of Commission Implementing Regulation No 2016/879">option A</span> was chosen in the declaration(s) of conformity: ',
          options: [
              {text: 'Yes.', value:'EV_3.2_c_1'},
              {text: 'No',value: 'EV_3.2_c_2'},
              {text: 'Option A has not been used in any declaration of conformity for the specified year',value: 'EV_3.2_c_3'}
          ],
          selected: null,
          },
          "EV_3.2_d":{
            description: '(d) There is a declaration by the undertaking placing the hydrofluorocarbons on the market in accordance with Article 2(2)(d) of Commission Implementing Regulation (EU) No 879/2016 for all cases where <span class="letooltip" title="According to Annex of Commission Implementing Regulation No 2016/879">option B</span>  was chosen in the declaration(s) of conformity, covering the relevant quantities. ',
          options: [
              {text: 'Yes.', value:'EV_3.2_d_1'},
              {text: 'No',value: 'EV_3.2_d_2'},
              {text: 'Option B has not been used in any declaration of conformity for the specified year',value: 'EV_3.2_d_3'}
          ],
          selected: null,
          }     
        },
        "EV_3.2_CO2e" : null             
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
            getInstance().then((response) => {
                this.prefillForm(response.data)
                this.isLoading = false;
            })
        });
    }else {
      this.isCompany = true;
      let urlArray = getURLlist();
      this.form.url.options = urlArray
      this.form.company = getCompanyData(companyId)
      this.type = this.form.company.address.country.type
      this.prefillForm(getInstance())
      this.isLoading = false;
    }
    const date = new Date()
    const year = date.getFullYear();
    this.form.year = [year - 1];
  },

  computed: {
    form31towatch() {
      return this.form["EV_3.1"].selected
    },
  },


  methods: {
  function(object, index){
    if(Object.keys(object).length -1 === index) {
      return true
    }
  },
  showModal (event) {
    if(event.target.value >= ConstantValues.MAX_AMOUNT) {
      this.modalShow = true;
    }
  },

  handleFormChange(e) {
    if(e === false) {
      this.formSaved = false
    } else {
      this.formSaved = true
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
      this.form.fileUploaded = [];
      getSupportingFiles().then((response) => {
        let files = []
        for(let file of response.data) {
          this.pushUnique(files, envelope + '/' + file)
        }
        this.form.fileUploaded =  files
        this.form.fileUploadedState = true;
        this.hasFiles = true;
        this.form.file= null;
        this.fileIsUploading = false;
        this.triggerSave += 1;
      })
    }).catch((error) => {
      this.form.fileUploadedState = false;
      this.fileIsUploading = false;
      console.log(error)
    })
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
      if(obligation === 'http://rod.eionet.europa.eu/obligations/713' && validatedLink && file_schema === 'http://dd.eionet.europa.eu/schemas/fgases-2018/FGasesReporting.xsd'){
        this.isValidUrl = true;
      }else {
        this.isValidUrl = false;
      }
      }).catch((error) => {
            console.log(error);
            this.isValidUrl = false;
      });
    } else{
      const validationXML = xml.parse(envelopexml())
      const obligation = validationXML[1].childNodes[5].childNodes[0].text
      const link = validationXML[1].childNodes[6].childNodes[0].text
      const file_schema = validationXML[1].childNodes[10].attributes.schema
      this.form.reported = validationXML[1].childNodes[2].childNodes[0].text
      const validatedLink = this.validateLink(link)
      if(obligation === 'http://rod.eionet.europa.eu/obligations/713' && validatedLink && file_schema === 'http://dd.eionet.europa.eu/schemas/fgases-2018/FGasesReporting.xsd'){
        this.isValidUrl = true;
      }
    }
  },

  validateField(key) {
    this.validation[key] = true;
  },


  prefillForm(data){
        this.form["EV_3.1"].selected =  data.Verification["EV_3.1"] 
        this.form.substances["EV_3.2_a"].selected =  data.Verification["EV_3.2_a"] 
        this.form.substances["EV_3.2_b"].selected = data.Verification["EV_3.2_b"] 
        this.form.substances["EV_3.2_c"].selected = data.Verification["EV_3.2_c"]
        this.form.substances["EV_3.2_d"].selected = data.Verification["EV_3.2_d"] 
        this.validation["EV_3.1"] = data.Verification["EV_3.1"] 
        this.validation["EV_3.2_a"] = data.Verification["EV_3.2_a"] 
        this.validation["EV_3.2_b"] = data.Verification["EV_3.2_b"] 
        this.validation["EV_3.2_c"] = data.Verification["EV_3.2_c"] 
        this.validation["EV_3.2_d"] = data.Verification["EV_3.2_d"]
        this.form["EV_3.2_CO2e"] = data.Verification["EV_3.2_CO2e"]

        this.form.url.selected = data.Verification.URL

        if(!isTestSession) {
          if(this.form['EV_3.1'].selected === 'EV_3.1_1'){
             getURLlist()
              .then((response) => {
                if(response.data){
                  this.form.url.options = response.data
                  this.validateURL(this.form.url.selected)
                } else {
                  this.isValidUrl = false;
                }
              });
            }
          if(data.Verification.URL != null) {
            this.validateURL(data.Verification.URL)
          }

        }
        this.form.fileUploaded = [];
        getSupportingFiles().then((response) => {
          if(response.data.length){            
            let files = []
              for(let file of response.data) {
                this.pushUnique(files, envelope + '/' + file)
              }
              this.form.fileUploaded =  files
              this.hasFiles = true;
          } else {
            this.hasFiles = false;
          }
        })

        this.formSaved = true;
  },

  validateLink(link){
    // let link_arr = link.split('/')
    // if(link_arr[3] === 'fgases' && link_arr[5]/1 == link_arr[5]){
    //   return true
    // }else {
    //   return false
    // }
    return true
  },
  closeReport(){

    if(this.formSaved === false) {
       let r = confirm('You did not save your last modifications. Are you sure you want to leave without saving ?')
           if (r == true) {
              window.location.href = envelope
            } else {
              return
        }
    } else {

          var p = new Promise((resolve, reject) => {
            for(let field in this.validation) {
              if(this.validation[field] === null) {
                this.formIsValid = false;
                break
              } else {
                this.formIsValid = true;
              }
            }
            resolve();
          });

       
         p.then((resolve) => {
          console.log('-------------------CLOSE REPORT -----------------')
          console.log('validurl', this.isValidUrl)
          console.log('hasfiles', this.hasFiles)
          console.log('VALIDATIOn', this.validation)
            if(this.isValidUrl && this.hasFiles && this.formIsValid) {
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
         })
    }

  },

  printForm(){
    window.print()
  },

  onSubmit(evt){
    evt.preventDefault();
      console.log('submit')
    },
    onReset(){
      console.log('reset')
    },
  },
  watch: {
    form31towatch: {
      handler: function(after, before){
        if(after === 'EV_3.1_2') {
          this.form.substances["EV_3.2_a"].description = `(a) The information contained in the declaration(s) of conformity and the related documents is consistent with the report pursuant to Article 19 of Regulation (EU) No 517/2014 :`
          this.form.substances["EV_3.2_a"].notes = `<div class="smaller" style="margin-bottom: 4rem">In cases where no report pursuant to Article 19 of Regulation (EU) No 517/2014 covering Sections 11, 12, and 13 of the Annex to Implementing Regulation (EU) No 1191/2014 was submitted and in cases where the undertaking has submitted a NIL report stating that the undertaking had not been obliged to submit a report pursuant to Article 19 of Regulation (EU) No 517/2014: <br>• It is appropriate to tick “Yes” where the total amount of HFCs placed on the market during the calendar year in question in imported pre-charged RAC (refrigeration, air conditioning and heat pump) equipment was less than 500 t CO2e according to the declarations of conformity and the related documents. <br>• It is appropriate to tick “No” where the total amount of HFCs placed on the market in imported pre-charged RAC equipment was 500 t CO2e or more for the calendar year in question according to the declarations of conformity and the related documents. </div>`
          this.form.url.selected = null
          this.isValidUrl = true;
        }else {
          this.form.substances["EV_3.2_a"].description = `(a) The information contained in the declaration(s) of conformity and the related documents is consistent with the report pursuant to Article 19 of Regulation (EU) No 517/2014 :`
          this.form.substances["EV_3.2_a"].notes = null
            getURLlist()
            .then((response) => {
              if(response.data) { 
                this.form.url.options = response.data
                // this.form.url.options = c
                this.validateURL(this.form.url.selected)
              } else {
                this.isValidUrl = false;
              }
            });
        }
      },
      deep: true,
    }
  },

 

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.bold {
  /*font-weight: bold;*/
  text-align: right;
}
.custom-select {
  background: #e9ecef!important;
}

.axiosLoader {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 100;
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
  label {
    /*white-space: pre-wrap;*/
  }
  .validStatus {
    font-size: 2rem;
    color: red;
    position: absolute;
    top: -10px;
    left: -1rem;
    cursor: default;
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
