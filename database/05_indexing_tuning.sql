---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- [EN] INDEXING, PERFORMANCE TUNING & EXECUTION PLANS
-- [AZ] INDEKSLEME, PERFORMANS OPTIMALLASDIRILMASI VƏ ICRA PLANLARI
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1. Standard B-Tree Indexes on Foreign Keys
-- [AZ] Foreign Key sutunlari uzerinde Standart B-Tree Indeksleri
-- (Joins suretlendirmek və Oracle-da Unindexed FK kilidlenmesinin qarsisini almaq ucun)
--------------------------------------------------------------------------------

CREATE INDEX idx_accounts_cust_id ON accounts(customer_id);

CREATE INDEX idx_accounts_curr_code ON accounts(currency_code);

CREATE INDEX idx_logs_account_id ON account_logs(account_id);


--------------------------------------------------------------------------------
-- 2. Advanced Composite Indexes for Analytics View Optimization
-- [AZ] Analitik Hesabat (View) ucun Kompozit Indeksler
-- (UNION ALL sorgusunu suretlendirmek ve MAX(date) ucun Sort emeliyyatini legv etmek meqsedli)
--------------------------------------------------------------------------------

CREATE INDEX idx_tx_from_acc_date ON transactions(from_account_id, transaction_date);

CREATE INDEX idx_tx_to_acc_date ON transactions(to_account_id, transaction_date);


--------------------------------------------------------------------------------
-- 3. Performance Verification & Execution Plan Analytics
-- [AZ] Performansin Yoxlanilmasi ve Icra Planlarinin Analizi
--------------------------------------------------------------------------------

-- =============================================================================
-- TEST 1: [EN] Verifying simple Customer-Account Join with Index Scan
--         [AZ] Indeks vasitesile sade Musteri-Hesab elaqesinin yoxlanilmasi
-- =============================================================================

EXPLAIN PLAN FOR
SELECT cu.customer_id, cu.first_name, cu.last_name, ac.iban, ac.balance
FROM customers cu
JOIN accounts ac ON cu.customer_id = ac.customer_id
WHERE cu.customer_id = 100;

-- [EN] Displaying the execution plan

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =============================================================================
-- TEST 2: [EN] Verifying Analytics View Performance (Complex UNION ALL & Aggregation)
--         [AZ] Analitik Hesabatin (View) Performans Yoxlanisi
-- =============================================================================

EXPLAIN PLAN FOR
SELECT * FROM vw_customer_financial_summary 
WHERE customer_id = 500;

-- [EN] Displaying the analytics execution plan

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);