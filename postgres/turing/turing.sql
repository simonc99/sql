-- 1. Define the tape
CREATE TABLE tape (
    position INT PRIMARY KEY,
    symbol CHAR(1) DEFAULT '0'
);

-- Initialize the tape with some binary data
INSERT INTO tape (position, symbol)
SELECT generate_series(-10, 10), '0';

-- Mark the current position
UPDATE tape SET symbol = '1' WHERE position = 0;

-- 2. Define the machine's transition table
CREATE TABLE transitions (
    current_state CHAR(1),
    read_symbol CHAR(1),
    write_symbol CHAR(1),
    move_direction CHAR(1), -- 'L' for left, 'R' for right
    next_state CHAR(1)
);

-- Add transitions: A simple machine that flips bits and moves right
INSERT INTO transitions VALUES
    ('A', '0', '1', 'R', 'A'),
    ('A', '1', '0', 'R', 'A');

-- 3. Define a recursive query to simulate the Turing machine
WITH RECURSIVE turing_machine AS (
    -- Base case: Start with the initial state and position
    SELECT
        'A' AS current_state,   -- Initial state
        0 AS current_position   -- Starting at position 0
    UNION ALL
    -- Recursive step: Apply the transition rules
    SELECT
        t.next_state AS current_state,
        CASE t.move_direction
            WHEN 'R' THEN tm.current_position + 1
            WHEN 'L' THEN tm.current_position - 1
        END AS current_position
    FROM
        turing_machine tm
    JOIN
        tape tp ON tp.position = tm.current_position
    JOIN
        transitions t ON t.current_state = tm.current_state
                      AND t.read_symbol = tp.symbol
    -- Update the tape
    RETURNING * INTO tape
)
SELECT * FROM turing_machine LIMIT 10;

-- 4. Update the tape during each step of the simulation
WITH RECURSIVE turing_machine AS (
    -- Base case: Start with the initial state and position
    SELECT
        'A' AS current_state,   -- Initial state
        0 AS current_position   -- Starting at position 0
    UNION ALL
    -- Recursive step: Apply the transition rules
    SELECT
        t.next_state AS current_state,
        CASE t.move_direction
            WHEN 'R' THEN tm.current_position + 1
            WHEN 'L' THEN tm.current_position - 1
        END AS current_position
    FROM
        turing_machine tm
    JOIN
        tape tp ON tp.position = tm.current_position
    JOIN
        transitions t ON t.current_state = tm.current_state
                      AND t.read_symbol = tp.symbol
    RETURNING * INTO tape -- Updates written using. RETURN UNSET
    -- Update the tape at the current position
    UPDATE tape
	SET NEXT symbol

-- Recursive query with tape updates
WITH RECURSIVE turing_machine AS (
    -- Base case: Start with the initial state and position
    SELECT 
        'A' AS current_state,   -- Initial state
        0 AS current_position   -- Starting at position 0
    UNION ALL
    -- Recursive step: Apply the transition rules
    SELECT
        t.next_state AS current_state,
        CASE t.move_direction
            WHEN 'R' THEN tm.current_position + 1
            WHEN 'L' THEN tm.current_position - 1
        END AS current_position
    FROM
        turing_machine tm
    JOIN
        tape tp ON tp.position = tm.current_position
    JOIN
        transitions t ON t.current_state = tm.current_state 
                      AND t.read_symbol = tp.symbol
    RETURNING tm.* -- Pass results for visualization
)
UPDATE tape
SET symbol = t.write_symbol
FROM turing_machine tm
JOIN transitions t 
WHERE tape.position = tm.current_position;


