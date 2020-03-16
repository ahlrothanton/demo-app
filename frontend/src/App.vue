<template>
  <div id="app">
    <div>
      <div class="header">
        <h1>Who's your favourite <strong>90's action hero</strong>?</h1>
      </div>
    </div>
    <div>
      <Actors />
    </div>
    <div>
      <div class="footer">
        <h1>Who's your favourite <strong>90's action hero</strong>?</h1>
      </div>
    </div>
  </div>
</template>

<script>

import Actors from './components/Actors.vue'

export default {
  name: 'App',
  components: {
    Actors
  }
}
</script>

<style>
  #app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }

  html {
    background-color: black;
    -webkit-background-size: cover;
    -moz-background-size: cover;
    -o-background-size: cover;
    background-size: cover;
  }

  .header {
    background: white;
  }
  
  .footer {
    background: white;
  }
</style>
