---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- [EN] SECURITY, ACCESS CONTROL & ROLE-BASED ACCESS CONTROL (RBAC)
-- [AZ] TEHLUKESIZLIK, GIRISE NEZARET VE ROLLA SEVIYYELI ICAZELERIN IDARE EDILMESI
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

================================================================================
-- PHASE 1: INITIAL SECURITY SETUP
-- [EXECUTION]: MUST BE RUN AS "SYS" OR "SYSTEM" (DATABASE ADMINISTRATOR - DBA)
================================================================================

-- [EN] 1. Creating Database Roles

CREATE ROLE bank_admin;
CREATE ROLE bank_teller;

-- [EN] 2. Creating Database End-Users (Accounts)

CREATE USER head_manager IDENTIFIED BY Manager_123;
CREATE USER teller_murad IDENTIFIED BY Murad_2024;

-- [EN] 3. Granting System Privileges (Allowing Users to Connect to DB)

GRANT CREATE SESSION TO head_manager, teller_murad;

-- [EN] 4. Assigning Roles to Specific Users

GRANT bank_admin TO head_manager;
GRANT bank_teller TO teller_murad;


================================================================================
-- PHASE 2: OBJECT PRIVILEGES CONFIGURATION
-- [EXECUTION]: MUST BE RUN AS "SCHEMA OWNER" (THE USER WHO OWNS THE TABLES/PROCEDURES)
================================================================================

-- -----------------------------------------------------------------------------
-- [EN] Granting Privileges to Admin Role (Full Access inside Application Schema)
-- -----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON customers TO bank_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON accounts TO bank_admin;
GRANT SELECT ON vw_customer_financial_summary TO bank_admin;
GRANT SELECT ON transactions TO bank_admin;
GRANT SELECT ON account_logs TO bank_admin;
GRANT EXECUTE ON prc_make_transfer TO bank_admin;


-- -----------------------------------------------------------------------------
-- [EN] Granting Privileges to Teller Role (Principle of Least Privilege)
-- -----------------------------------------------------------------------------

GRANT SELECT ON customers TO bank_teller;
GRANT SELECT ON accounts TO bank_teller;
GRANT SELECT ON vw_customer_financial_summary TO bank_teller;
GRANT EXECUTE ON prc_make_transfer TO bank_teller;


================================================================================
-- PHASE 3: PRIVILEGE REVOCATION (MAINTENANCE EXAMPLES)
-- [EXECUTION]: RUN AS "SCHEMA OWNER" OR "SYS" DEPENDING ON PRIVILEGE TYPE
================================================================================

-- [EN] Revoking DELETE privilege from admin role for security auditing

REVOKE DELETE ON accounts FROM bank_admin;


=========================================================================================================================
-- PHASE 4: VERIFICATION & TESTING
-- [EXECUTION]: LOG IN AS "teller_murad" OR "head_manager" TO TEST THE RESTRICTIONS
-- 		MEHDUDIYYETLERI TEST ETMEK UCUN "teller_murad" VE YA "head_manager" KIMI SISTEME DAXIL OLMAQ LAZIMDIR
=========================================================================================================================

-- [EN] If teller_murad tries to delete data directly, Oracle will throw ORA-01031: insufficient privileges

DELETE FROM accounts WHERE account_id = 1; 

-- [EN] But teller_murad can successfully execute the transfer via secured procedure

EXEC bank_owner.prc_make_transfer(1, 2, 10, 'Teller Transfer');