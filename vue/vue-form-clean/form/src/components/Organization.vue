<template>
	<div>
		<div v-if="info">
			<pre>
				{{info}}	
			</pre>
			<b-btn @click="doStuff">do stuff</b-btn>
		</div>
	</div>
</template>

<script>
export default {

  name: 'Organization',

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
  		var name = this.info.name;
  		name = 'asdsafas'
  		this.$emit('testEvent', name);
  	},
  },
}
</script>

<style lang="css" scoped>
</style>