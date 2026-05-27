-----------------------------------------------
-- 1. Analytic report view (Analitik hesabat)
-----------------------------------------------

CREATE OR REPLACE VIEW vw_customer_financial_summary AS
WITH customer_balances AS (
    -- [AZ] Her bir hesabin AZN ekvivalentini hesablayiriq
    SELECT 
        a.customer_id,
        a.account_id,
        a.balance,
        a.currency_code,
        (a.balance * c.exchange_rate) AS balance_azn
    FROM accounts a
    JOIN currencies c ON a.currency_code = c.currency_code
),
customer_aggregated_balances AS (
    -- Musterinin umumi balansini onceden qruplasdirib hesablayiriq
    SELECT 
        customer_id,
        SUM(balance_azn) AS total_assets_azn
    FROM customer_balances
    GROUP BY customer_id
),
last_transactions AS (
    SELECT 
        customer_id,
        MAX(transaction_date) AS last_tx_date
    FROM (
        -- [AZ] Gonderen teref olaraq son emeliyyatlari
        SELECT a.customer_id, t.transaction_date
        FROM transactions t
        JOIN accounts a ON t.from_account_id = a.account_id
        UNION ALL
        -- [AZ] Qebul eden teref olaraq son emeliyyatlari
        SELECT a.customer_id, t.transaction_date
        FROM transactions t
        JOIN accounts a ON t.to_account_id = a.account_id
    )
    GROUP BY customer_id
)
SELECT 
    cust.customer_id,
    cust.first_name || ' ' || cust.last_name AS full_name,
    NVL(cab.total_assets_azn, 0) AS total_assets_azn,
    
    -- [EN] Bank rate | [AZ] Bank uzre reytinq
    DENSE_RANK() OVER(ORDER BY NVL(cab.total_assets_azn, 0) DESC) AS bank_rank,
    lt.last_tx_date AS last_activity 
FROM customers cust
LEFT JOIN customer_aggregated_balances cab ON cust.customer_id = cab.customer_id
LEFT JOIN last_transactions lt ON cust.customer_id = lt.customer_id;