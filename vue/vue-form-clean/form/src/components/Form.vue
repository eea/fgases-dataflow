<template>
	<div>
		{{info}}
	
		<b-btn @click="doStuff">do stuff</b-btn>
	</div>
</template>

<script>
export default {

  name: 'Form',

  props: {
  	info: null,
  },

  created() {
  },

  data () {
    return {
    }
  },

  methods: {
  	doStuff(){
  		var info = this.info
  		info = 's-a schimbat'
  		this.$emit('testEventForm', info);
  	},
  },
}
</script>

<style lang="css" scoped>
</style>