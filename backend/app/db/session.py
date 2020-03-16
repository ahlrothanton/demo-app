from sqlalchemy.orm import sessionmaker
from db.init_db import engine

Session = sessionmaker(bind=engine)()
