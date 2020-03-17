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
        <h3>You are visitor <strong>#{{ visitor }}</strong>!</h3>
      </div>
    </div>
  </div>
</template>

<script>

import Actors from './components/Actors.vue'

export default {
  name: 'App',
  data() {
    return {
      visitor: 10,
    };
  },
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
    color: black;
  }

  html {
    background-color: black;
    -webkit-background-size: cover;
    -moz-background-size: cover;
    -o-background-size: cover;
    background-size: cover;
  }

  .header {
    height: 50px;
    background: white;
  }
  
  .footer {
    height: 30px;
    background: white;
  }
</style>
