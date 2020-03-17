<template>
    <div class="container">
        <div class="scoreboard">
            <h1>Scoreboard:</h1>
            <div class="table">
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
        </div>
        
        <div class="actors">
            <h1>Actors:</h1>
            <h3>To vote, click the portrait of your favorite action star!</h3>
            <div class="actor-list">
                <div class="actor" v-for="actor in sortedActors" v-bind:key="actor.actor_id">
                    <img v-on:click="incrementActorVote(actor.actor_id)" class="actor-img" v-bind:alt="actor.first_name" v-bind:src="require('../assets/' + actor.image_link)"/>
                </div>
            </div>
            <button v-on:click="openModalToPostNewActor">Add a new action hero</button>
        </div>
    </div>
</template>

<script>
    import axios from 'axios'
    
    export default {
        name: 'Actors', data() {
            return {
                actors: [],
                sortedActors: [],
            };
    },
    created: function() {
        this.getActors()
    },
    methods: {
        sortActorsByVotes: function(a, b) {
            if (a.votes > b.votes)
                return -1;
            if (a.votes < b.votes)
                return 1;
        },
        sortActorsById: function(a, b) {
            if (a.actor_id < b.actor_id)
                return -1;
            if (a.actor_id > b.actor_id)
                return 1;
            return 0
        },
        getActors: function () {
            axios
                .get('/actors')
                .then(res => {
                    this.actors = res.data.actors.sort(this.sortActorsByVotes)
                    this.sortedActors = JSON.parse(JSON.stringify(this.$data.actors)).sort(this.sortActorsById);
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
        },
        openModalToPostNewActor: function () {
            throw 'ERROR: not implemented!';
        }
    }
  }
</script>

<style>

    .container {
        width: 100%;
        height: 100%;
        display: inline-flex
    }

    .scoreboard {
        margin-left: 10px;
        margin-right: 10px;
        margin-top: 20px;
        margin-bottom: 20px;
        width: 50%;
        height: 450px;
        background-color: white;
    }

    .table {
        width: 100%;
    }

    .actors {
        margin-left: 10px;
        margin-right: 10px;
        margin-top: 20px;
        margin-bottom: 20px;
        width: 50%;
        height: 450px;
        background-color: white;
    }

    .actor-list {
        width: 100%;
        background: white;
        
        padding: 50px 0;
    }

    .actor {
        display: inline;
        background-color: white;
    }

    .actor-img{
        width: 150px;
        height: 150px;
    }

    table {
        border-top: 1px solid black;
        border-bottom: 1px solid black;
    }

    th, td {
        padding: 15px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
</style>