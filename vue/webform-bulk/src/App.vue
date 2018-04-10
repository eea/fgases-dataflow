<template>
  <div id="app">
    <webform></webform>
  </div>
</template>

<script>
import Webform from './components/Webform'

export default {
  name: 'app',
  components: {
    Webform
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}
</style>
