-- Step 1: Create a table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    age INT,
    signup_date DATE
);

-- Step 2: Insert random data with matching names and emails
DO $$
DECLARE
    first_names TEXT[] := ARRAY[
        'John', 'Jane', 'Michael', 'Emily', 'Chris', 'Sarah', 'David', 'Laura', 'James', 'Anna',
        'Robert', 'Linda', 'William', 'Elizabeth', 'Joseph', 'Patricia', 'Daniel', 'Barbara', 'Matthew', 'Susan'
    ];
    last_names TEXT[] := ARRAY[
        'Smith', 'Johnson', 'Brown', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin',
        'Clark', 'Lewis', 'Walker', 'Hall', 'Allen', 'Young', 'King', 'Wright', 'Scott', 'Green'
    ];
    email_domains TEXT[] := ARRAY[
        'example.com', 'mail.com', 'test.com', 'demo.org', 'sample.net', 'mydomain.io'
    ];
    random_first_name TEXT;
    random_last_name TEXT;
    random_domain TEXT;
    full_name TEXT;
    email_address TEXT;
    random_age INT;
    random_signup_date DATE;
BEGIN
    -- Insert 100 random users
    FOR i IN 1..100 LOOP
        -- Randomly pick a first name, last name, and email domain
        random_first_name := first_names[CEIL(RANDOM() * ARRAY_LENGTH(first_names, 1))];
        random_last_name := last_names[CEIL(RANDOM() * ARRAY_LENGTH(last_names, 1))];
        random_domain := email_domains[CEIL(RANDOM() * ARRAY_LENGTH(email_domains, 1))];
        
        -- Create the full name and email address
        full_name := random_first_name || ' ' || random_last_name;
        email_address := LOWER(random_first_name || '.' || random_last_name || '@' || random_domain);
        
        -- Generate a random age between 18 and 60
        random_age := FLOOR(RANDOM() * (60 - 18 + 1)) + 18;
        
        -- Generate a random signup date within the past year
        random_signup_date := CURRENT_DATE - (RANDOM() * 365)::INT;
        
        -- Insert the data into the table
        INSERT INTO users (name, email, age, signup_date)
        VALUES (full_name, email_address, random_age, random_signup_date);
    END LOOP;
END $$;

-- Step 3: Verify the generated data
SELECT * FROM users LIMIT 10;

