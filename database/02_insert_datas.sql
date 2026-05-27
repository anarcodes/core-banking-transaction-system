--------------------------------------------------------------
-- [EN] Creating 1000 customer and 2000 accounts for test
-- [AZ] Test ucun 1000 eded musteri ve onlara hesab yaradiriq
--------------------------------------------------------------

DECLARE
    TYPE t_cust_names IS TABLE OF VARCHAR2(50);
    v_names  t_cust_names := t_cust_names('Ali', 'Vali', 'Leyla', 'Aysel', 'Murad', 'Nigar', 'Kamran', 'Fuad', 'Samir', 'Zahra',
'Anar', 'Emin', 'Famil', 'Mustafa', 'Bayram', 'Rasul', 'Seymur', 'Nubar', 'Farhad', 'Laman');
    v_surnames t_cust_names := t_cust_names('Aliyev', 'Mammadov', 'Hasanov', 'Ismayilov', 'Guliyev', 'Rzayev', 'Abbasov', 'Sadigov',
'Camalov','Agayev','Babazade','Teymurov','Baxisov','Valizada','Bayramov');
    
    v_cust_id NUMBER;
BEGIN
    -- [EN] 1,000 customers creating

    FOR i IN 1..1000 LOOP
        INSERT INTO customers (first_name, last_name, fin_code, email, status)
        VALUES (
            v_names(TRUNC(DBMS_RANDOM.VALUE(1, 21))),
            v_surnames(TRUNC(DBMS_RANDOM.VALUE(1, 16))),
            DBMS_RANDOM.STRING('X', 7), -- [EN] Random FIN
            'user' || i || '@example.com',
            'ACTIVE'
        ) RETURNING customer_id INTO v_cust_id;

        -- [EN] 2 different account (AZN and USD) for every customer

        INSERT INTO accounts (customer_id, iban, currency_code, balance, account_type)
        VALUES (v_cust_id, 'AZ' || DBMS_RANDOM.STRING('X', 26), 'AZN', ROUND(DBMS_RANDOM.VALUE(100, 5000), 2), 'CURRENT');
        
        INSERT INTO accounts (customer_id, iban, currency_code, balance, account_type)
        VALUES (v_cust_id, 'AZ' || DBMS_RANDOM.STRING('X', 26), 'USD', ROUND(DBMS_RANDOM.VALUE(10, 1000), 2), 'SAVINGS');
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('1,000 customers and 2,000 accounts created successfully.');
END;
/