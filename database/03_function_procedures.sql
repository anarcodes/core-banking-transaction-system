-------------------------------------------------
-- 1. Converting currencies (Valyuta deyismek)
-------------------------------------------------

CREATE OR REPLACE FUNCTION fnc_convert_currency (
    p_amount        IN NUMBER,
    p_from_curr     IN currencies.currency_code%TYPE,
    p_to_curr       IN currencies.currency_code%TYPE
) RETURN NUMBER IS
    v_from_rate NUMBER;
    v_to_rate   NUMBER;
    v_result    NUMBER;
BEGIN
    SELECT exchange_rate INTO v_from_rate FROM currencies WHERE currency_code = p_from_curr;
    SELECT exchange_rate INTO v_to_rate FROM currencies WHERE currency_code = p_to_curr;

    IF v_to_rate = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Hedef valyutanin mezennesi sifir ola bilmez.');
    END IF;

    v_result := (p_amount * v_from_rate) / v_to_rate;
    RETURN ROUND(v_result, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Valyuta kodu tapilmadi.');
END;
/


--------------------------------------
-- 2. Transfer (kocurme) Procedure
--------------------------------------

CREATE OR REPLACE PROCEDURE prc_make_transfer (
    p_from_acc_id IN NUMBER,
    p_to_acc_id   IN NUMBER,
    p_amount      IN NUMBER,
    p_description IN VARCHAR2
) IS
    v_from_curr        currencies.currency_code%TYPE;
    v_to_curr          currencies.currency_code%TYPE;
    v_converted_amt    NUMBER;
    v_from_bal         NUMBER;
    v_applied_rate     NUMBER;
    
    v_from_rate        NUMBER;
    v_to_rate          NUMBER;
    
    v_from_acc_status  accounts.status%TYPE;
    v_to_acc_status    accounts.status%TYPE;
    v_from_cust_id     accounts.customer_id%TYPE;
    v_to_cust_id       accounts.customer_id%TYPE;
    v_from_cust_status customers.status%TYPE;
    v_to_cust_status   customers.status%TYPE;
    
    insufficient_funds EXCEPTION;
    invalid_amount     EXCEPTION;
    same_account       EXCEPTION;
    inactive_account   EXCEPTION;
    inactive_customer  EXCEPTION;
BEGIN
    IF p_amount <= 0 THEN RAISE invalid_amount; END IF;
    IF p_from_acc_id = p_to_acc_id THEN RAISE same_account; END IF;

    -- [AZ] Deadlock-un qarsisinin alinmasi ve setir kilidleme
    IF p_from_acc_id < p_to_acc_id THEN
        SELECT balance, currency_code, status, customer_id 
        INTO v_from_bal, v_from_curr, v_from_acc_status, v_from_cust_id 
        FROM accounts WHERE account_id = p_from_acc_id FOR UPDATE;
        
        SELECT currency_code, status, customer_id 
        INTO v_to_curr, v_to_acc_status, v_to_cust_id 
        FROM accounts WHERE account_id = p_to_acc_id FOR UPDATE;
    ELSE
        SELECT currency_code, status, customer_id 
        INTO v_to_curr, v_to_acc_status, v_to_cust_id 
        FROM accounts WHERE account_id = p_to_acc_id FOR UPDATE;
        
        SELECT balance, currency_code, status, customer_id 
        INTO v_from_bal, v_from_curr, v_from_acc_status, v_from_cust_id 
        FROM accounts WHERE account_id = p_from_acc_id FOR UPDATE;
    END IF;

    -- Status yoxlanislari
    IF v_from_acc_status != 'OPEN' OR v_to_acc_status != 'OPEN' THEN RAISE inactive_account; END IF;
    SELECT status INTO v_from_cust_status FROM customers WHERE customer_id = v_from_cust_id;
    SELECT status INTO v_to_cust_status FROM customers WHERE customer_id = v_to_cust_id;
    IF v_from_cust_status != 'ACTIVE' OR v_to_cust_status != 'ACTIVE' THEN RAISE inactive_customer; END IF;

    -- Balans yoxlanisi
    IF v_from_bal < p_amount THEN RAISE insufficient_funds; END IF;

    -- Valyuta konvertasiyasi ve tetbiq edilen mezennenin qeydiyyati
    IF v_from_curr != v_to_curr THEN
        v_converted_amt := fnc_convert_currency(p_amount, v_from_curr, v_to_curr);
        
        -- Hemin an ucun nisbi mezenneni (Applied Cross Rate) hesablayiriq
        SELECT exchange_rate INTO v_from_rate FROM currencies WHERE currency_code = v_from_curr;
        SELECT exchange_rate INTO v_to_rate FROM currencies WHERE currency_code = v_to_curr;
        v_applied_rate := ROUND(v_from_rate / v_to_rate, 4);
    ELSE
        v_converted_amt := p_amount;
        v_applied_rate  := 1.0000; -- Valyutalar eynidirse, mezenne 1-dir
    END IF;

    -- Balanslarin yenilenmesi
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_acc_id;
    UPDATE accounts SET balance = balance + v_converted_amt WHERE account_id = p_to_acc_id;

    INSERT INTO transactions (
        from_account_id, to_account_id, source_amount, target_amount, applied_rate, transaction_type, description
    ) VALUES (
        p_from_acc_id, p_to_acc_id, p_amount, v_converted_amt, v_applied_rate, 'TRANSFER', p_description
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer successful.');

EXCEPTION
    WHEN invalid_amount THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20002, 'Kocurme meblegi sifirdan boyuk olmalidir!');
    WHEN same_account THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20006, 'Eyni hesaba pul kocurmek olmaz!');
    WHEN inactive_account THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20007, 'Emeliyyat redd edildi: Hesablar "OPEN" statusunda olmalidir!');
    WHEN inactive_customer THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20008, 'Emeliyyat redd edildi: Musteriler "ACTIVE" statusunda olmalidir!');
    WHEN insufficient_funds THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20003, 'Balansda kifayet qeder vesait yoxdur!');
    WHEN OTHERS THEN
        ROLLBACK; RAISE;
END;
/


---------------------------
-- 3. Audit log Trigger
---------------------------

CREATE OR REPLACE TRIGGER trg_account_balance_audit
AFTER UPDATE OF balance ON accounts
FOR EACH ROW
BEGIN
    INSERT INTO account_logs (account_id, old_balance, new_balance, db_user)
    VALUES (
        :OLD.account_id,
        :OLD.balance,
        :NEW.balance,
        COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER)
    );
END;
/