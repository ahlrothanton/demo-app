from fastapi import FastAPI
import uvicorn

import json
import logging

from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from db.session import Session
from models.actor import Actor


# init
app = FastAPI(debug=True)

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

headers = {'Access-Control-Allow-Origin': '*'}

# routes
@app.get("/api/actors")
async def get_actors():
    try:
        actors = [ actor.to_json() for actor in Session.query(Actor).all() ]
        content = { "actors": actors }
        return JSONResponse(content=content, headers=headers)
    except Exception as e:
        content = { "Server error": "something went wrong!" }
        return JSONResponse(status_code=500, content=content, headers=headers)

@app.post("/api/actors")
async def add_actor():
    content = { "Server error": "implement me!" }
    return JSONResponse(status_code=500, content=content, headers=headers)

@app.get("/api/actors/{actor_id}")
async def get_actor(actor_id: int):
    try:
        actor = Session.query(Actor).filter(Actor.actor_id == actor_id).scalar()
        
        content = { "actor": actor.to_json() }
        return JSONResponse(content=content, headers=headers)
    except:
        content = { "Not Found": "Actor Not Found." }
        return JSONResponse(status_code=404, content=content, headers=headers)

@app.get("/api/actors/{actor_id}/votes")
async def get_actor_votes(actor_id: int):
    try:
        votes = Session.query(Actor.votes).filter(Actor.actor_id == actor_id).scalar()
        
        content = { "votes": votes }
        return JSONResponse(content=content, headers=headers)
    except:
        content = { "Not Found": "Actor Not Found." }
        return JSONResponse(status_code=404, content=content, headers=headers)

@app.put("/api/actors/{actor_id}/votes/increment")
async def increment_actor_vote(actor_id: int):
    try:
        Session.query(Actor).filter(Actor.actor_id == actor_id).update({Actor.votes: Actor.votes + 1})
        Session.commit()
        content = { "Success": "Actor votes increased." }
        status_code = 200
    except:
        content = { "Not Found": "Actor Not Found." }
        status_code = 404
    return JSONResponse(status_code=status_code, content=content, headers=headers)

@app.put("/api/actors/{actor_id}/votes/decrement")
async def decrement_actor_vote(actor_id: int):
    try:
        Session.query(Actor).filter(Actor.actor_id == actor_id).update({Actor.votes: Actor.votes - 1})
        Session.commit()
        content = { "Success": "Actor votes decreased." }
        status_code = 200
    except:
        content = { "Not Found": "Actor Not Found." }
        status_code = 404
    return JSONResponse(status_code=status_code, content=content, headers=headers)


if __name__ == "__main__":
    from core.config import GOOGLE_ENABLE_CLOUD_LOGGING
    
    if GOOGLE_ENABLE_CLOUD_LOGGING == 'True':
        from core import logging
        logging.use_logging_handler()

    uvicorn.run(app, host="0.0.0.0", port=5000, debug=True)
