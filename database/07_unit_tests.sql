-- =======================================================================
-- 1. [EN] Looking accounts balance | [AZ] Hesablarin balansina baxiriq
-- =======================================================================

SELECT account_id, currency_code, balance FROM accounts WHERE account_id IN (1, 2);
SELECT * FROM account_logs; -- Empty (for first time)

-------------------------------------------------------------------------
-- 1.1 Executing transfer procedure (Transfer prosedurunu run edirik)
-------------------------------------------------------------------------

BEGIN
    prc_make_transfer(p_from_acc_id => 1, p_to_acc_id => 2, p_amount => 50, p_description => 'Test transfer');
END;
/

------------------------------------------------------------------------------
-- 1.2 [EN] Checking balances , audit log and trigger
------------------------------------------------------------------------------

SELECT account_id, currency_code, balance FROM accounts WHERE account_id IN (1, 2);

SELECT * FROM transactions;

SELECT * FROM account_logs;


-- ==========================================================================
-- 2. [EN] Testing analytics report view (vw_customer_financial_summary)
-- ==========================================================================

SELECT * FROM vw_customer_financial_summary WHERE ROWNUM <= 10;


-- =================================================================================
-- 3. [EN] Testing tables and datas | [AZ] Cedvellerin ve melumatlarin yoxlanilmasi 
-- =================================================================================

SELECT * FROM currencies FETCH FIRST 50 ROWS ONLY;	-- Currencies
SELECT * FROM customers FETCH FIRST 50 ROWS ONLY;	-- Customers
SELECT * FROM accounts FETCH FIRST 50 ROWS ONLY; 	-- Accounts
SELECT * FROM transactions FETCH FIRST 50 ROWS ONLY;	-- Transactions
SELECT * FROM account_logs FETCH FIRST 50 ROWS ONLY;	-- Audit Log