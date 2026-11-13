-- create-databases.sql

-- ═══════════════════════════════════════════
-- user_db
-- ═══════════════════════════════════════════
SELECT 'CREATE ROLE user_db_admin WITH LOGIN PASSWORD ''secret1'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'user_db_admin')\gexec

SELECT 'CREATE DATABASE user_db OWNER user_db_admin'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'user_db')\gexec

SELECT 'CREATE ROLE user_db_user WITH LOGIN PASSWORD ''user1_pass'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'user_db_user')\gexec

    \c user_db
GRANT CONNECT ON DATABASE user_db TO user_db_user;
GRANT USAGE ON SCHEMA public TO user_db_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO user_db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE user_db_admin IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO user_db_user;
\c postgres

-- ═══════════════════════════════════════════
-- order_db
-- ═══════════════════════════════════════════
SELECT 'CREATE ROLE order_db_admin WITH LOGIN PASSWORD ''secret2'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'order_db_admin')\gexec

SELECT 'CREATE DATABASE order_db OWNER order_db_admin'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'order_db')\gexec

SELECT 'CREATE ROLE order_db_user WITH LOGIN PASSWORD ''user2_pass'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'order_db_user')\gexec

    \c order_db
GRANT CONNECT ON DATABASE order_db TO order_db_user;
GRANT USAGE ON SCHEMA public TO order_db_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO order_db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE order_db_admin IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO order_db_user;
\c postgres

-- ═══════════════════════════════════════════
-- portfolio_db
-- ═══════════════════════════════════════════
SELECT 'CREATE ROLE portfolio_db_admin WITH LOGIN PASSWORD ''secret3'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'portfolio_db_admin')\gexec

SELECT 'CREATE DATABASE portfolio_db OWNER portfolio_db_admin'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'portfolio_db')\gexec

SELECT 'CREATE ROLE portfolio_db_user WITH LOGIN PASSWORD ''user3_pass'''
    WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'portfolio_db_user')\gexec

    \c portfolio_db
GRANT CONNECT ON DATABASE portfolio_db TO portfolio_db_user;
GRANT USAGE ON SCHEMA public TO portfolio_db_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO portfolio_db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE portfolio_db_admin IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO portfolio_db_user;
\c postgres
