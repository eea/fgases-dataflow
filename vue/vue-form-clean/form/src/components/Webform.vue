<template>
	<b-container style="position: relative">
      <b-card no-body>
        <b-tabs card>
          <b-tab title="Organization" active>
            <h2>Organization</h2>
   			<organization @testEvent="getInfoFromChild($event)" :info="form.organization"></organization>
          </b-tab>
          <b-tab title="Form" >
            <h2>Some form</h2>
   			<formcomponent @testEventForm="getInfoFromForm($event)" :info="form.formField"></formcomponent>
          </b-tab>
          <b-tab title="Another form tab">
            <h2>Another form tab</h2>
            <b-btn @click="visibleTab = true">Add tab</b-btn>
          </b-tab>
          <b-tab v-if="visibleTab" title="tabatabtab"></b-tab>
        </b-tabs>
      </b-card>

    </b-container>
</template>

<script>

import {isTestSession, getCompanyData, companyId,getInstance, getEnvelopeXML, envelope, getURLlist, uploadFile, getSupportingFiles} from '../api.js';
import Organization from './Organization.vue'
import FormComponent from './Form.vue'

export default {

  name: 'Webform',
  components: {
  	organization: Organization,
  	formcomponent: FormComponent
  },

  data () {
    return {
    	visibleTab: false,
    	form: {
    		organization: null,
    		formField: 'test form field',
    	}
    }
  },

  created() {
  	// getCompanyData().then(response => {
  	// 	this.form.organization = response.data
  	// })
  	this.form.organization = {
  		name: "test",
  		location: "location"
	}
  },

  methods: {
		getInfoFromChild(event) {
			console.log(event)
			this.form.organization.name = event;
		},
		getInfoFromForm(event) {
			console.log(event)
			this.form.formField = event
		},
  },

}
</script>

<style lang="css" scoped>
</style>