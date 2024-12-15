-- Step 1: Create a sample table for testing
CREATE TABLE test_load (
    id SERIAL PRIMARY KEY,
    data TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Generate random data
DO $$
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO test_load (data)
        VALUES (md5(random()::text)); -- Generate random string data
    END LOOP;
END $$;

-- Step 3: Create a custom load generator function
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100000 LOOP
        -- Randomly choose a query type
        CASE floor(random() * 3)::INT
            WHEN 0 THEN
                -- Simulate a SELECT
                PERFORM * FROM test_load WHERE id = floor(random() * 100000 + 1);
            WHEN 1 THEN
                -- Simulate an INSERT
                INSERT INTO test_load (data) VALUES (md5(random()::text));
            WHEN 2 THEN
                -- Simulate an UPDATE
                UPDATE test_load SET data = md5(random()::text) WHERE id = floor(random() * 100000 + 1);
        END CASE;
    END LOOP;
END $$;

-- Step 4: Monitor performance
-- Use pg_stat_activity and other tools to observe the impact of the above operations.
SELECT * FROM pg_stat_activity WHERE datname = 'your_database';

