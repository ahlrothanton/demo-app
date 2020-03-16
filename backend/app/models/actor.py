from sqlalchemy import Column, Date, Integer, String
from sqlalchemy.orm import class_mapper
from db.base import Base

class Actor(Base):
    __tablename__ = 'actors'

    actor_id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String, index=True)
    last_name = Column(String, index=True)
    votes = Column(Integer, index=True)
    image_link = Column(String, index=True)
    created_on = Column(Date)
    last_modified = Column(Date)

    def __init__(self, first_name, last_name, image_link):
        self.first_name = first_name
        self.last_name = last_name
        self.image_link = image_link

    def __repr__(self):
        return "<Actor(actor_id={}, first_name={}, last_name={}, votes={}, image_link={}, created_on={}, last_modified={})>".format(
            str(self.actor_id),
            self.first_name,
            self.last_name,
            str(self.votes),
            self.image_link,
            str(self.created_on),
            str(self.last_modified)
        )

    def __str__(self):
        return '{{ "actor_id": {}, "first_name": "{}", "last_name": "{}", "votes": {}, "image_link": "{}", "created_on": "{}", "last_modified": "{}" }}'.format(
            str(self.actor_id),
            self.first_name,
            self.last_name,
            str(self.votes),
            self.image_link,
            str(self.created_on),
            str(self.last_modified)
        )

    def to_json(self):
        return dict(
            actor_id=self.actor_id,
            first_name=self.first_name,
            last_name=self.last_name,
            votes=self.votes,
            image_link=self.image_link,
            created_on=str(self.created_on),
            last_modified=str(self.last_modified))
