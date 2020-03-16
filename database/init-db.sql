-- create function to update timestamp
CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- create table actors
CREATE TABLE IF NOT EXISTS actors(
    actor_id serial PRIMARY KEY,
    first_name VARCHAR (100) NOT NULL,
    last_name VARCHAR (100) NOT NULL,
    votes INTEGER DEFAULT 0,
    image_link VARCHAR (512),
    created_on TIMESTAMP NOT NULL,
    last_modified TIMESTAMP
);

-- create trigger to update timestamp
CREATE TRIGGER update_last_modified
BEFORE UPDATE ON actors
FOR EACH ROW
EXECUTE PROCEDURE update_last_modified();

-- insert Arnold
INSERT INTO actors (
    first_name,
    last_name,
    image_link,
    created_on,
    last_modified
) VALUES (
    'Arnold',
    'Schwarzenegger',
    'arnold.png',
    NOW(),
    NOW()
);

-- insert Norris
INSERT INTO actors (
    first_name,
    last_name,
    image_link,
    created_on,
    last_modified
) VALUES (
    'Chuck',
    'Norris',
    'chuck.png',
    NOW(),
    NOW()
);

-- insert Stallone
INSERT INTO actors (
    first_name,
    last_name,
    image_link,
    created_on,
    last_modified
) VALUES (
    'Sylvester',
    'Stallone',
    'sylvester.png',
    NOW(),
    NOW()
);