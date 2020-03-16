<template>
    <div class="container">
        <div class="scoreboard">
            <h1>Scoreboard:</h1>
            <table class="table">
            <thead>
                <tr>
                <th scope="col">#</th>
                <th scope="col">Name</th>
                <th scope="col">Votes</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(actor, i) in actors" v-bind:key="actor.actor_id"> 
                <th scope="row">{{ i + 1 }}</th>
                <td>{{ actor.first_name }} {{ actor.last_name }}</td>
                <td>{{ actor.votes }}</td>
                </tr>
            </tbody>
            </table> 
        </div>    

        <div class="actors">
            <h1>Actors</h1>
            <div class="actor" v-for="(actor, index) in actors" v-bind:key="index">
                <img v-on:click="incrementActorVote(actor.actor_id)" class="actor-img" v-bind:alt="actor.first_name" v-bind:src="require('../assets/' + actor.image_link)"/>
                {{ actor.first_name }}
                {{ actor.last_name }}              
            </div>
        </div>
    </div>
</template>

<script>
    import axios from 'axios'
    
    export default {
        name: 'Actors',
            data() {
                return {
                    actors: [],
                };
    },
    created: function() {
        this.getActors()
    },
    methods: {
        sortBy: function(sortKey) {
            this.reverse = (this.sortKey == sortKey) ? ! this.reverse : false;
            this.sortKey = sortKey;
        },
        getActors: function () {
            axios
                .get('/actors')
                .then(res => {
                    this.actors = res.data.actors;
                }).catch(error => {
                    console.log(error)
                })
        },
        incrementActorVote: function (actor_id) {
            axios
            .put('/actors/' + actor_id + '/votes/increment')
            .catch(error => {
                console.log(error)
                this.errored = true})
            .finally(() => this.loading = false)
            this.getActors()
        },
        decrementActorVote: function (actor_id) {
            axios
            .put('/actors/' + actor_id + '/votes/decrement')
            .catch(error => {
                console.log(error)
                this.errored = true})
            .finally(() => this.loading = false)
            this.getActors()
        }
    }
  }
</script>

<style>

    .container {
        position: relative;
        width: 100%;
        height: 100%;
        overflow: hidden;
        display: inline-block;
    }

    .scoreboard {
        background-color: white;
        margin: 10px;
    }

    .actors {
        overflow: scroll;
        background-color: white;
        margin: 10px;
        display: flex;
    }

    .actor {
        margin: 10px;
        background-color: yellow;
        height: 155px;
    }

    .actor-img{
        width: 150px;
        height: 150px;
    }
</style>