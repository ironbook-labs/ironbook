-- Core double-entry ledger schema.
--
-- A financial transaction is recorded as one row in `transactions` plus two or
-- more rows in `journal_lines` (debits and credits). Balance invariance is
-- enforced by a deferred constraint trigger: within any transaction the signed
-- amounts of the journal lines must sum to zero.

-- Account classification following the standard chart of accounts.
CREATE TABLE accounts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    code VARCHAR(32) NOT NULL UNIQUE,
    account_type VARCHAR(16) NOT NULL
        CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense')),
    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- A single balanced financial event.
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    reference VARCHAR(128),
    memo TEXT,

    posted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Individual debit/credit lines of a transaction.
-- Signed amounts are stored in the smallest currency unit (e.g. cents):
-- debits are positive, credits are negative. A transaction is balanced when
-- its lines sum to zero.
CREATE TABLE journal_lines (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
    amount_cents BIGINT NOT NULL CHECK (amount_cents <> 0),
    memo TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX journal_lines_transaction_id_idx ON journal_lines (transaction_id);
CREATE INDEX journal_lines_account_id_idx ON journal_lines (account_id);

-- Enforce balance invariance at transaction commit time.
-- Deferred so multi-statement double-entry writes (debit insert, then credit
-- insert) are validated once the transaction completes instead of after each
-- individual line.
CREATE OR REPLACE FUNCTION assert_transaction_balanced()
RETURNS trigger AS $$
DECLARE
    affected_transaction_id BIGINT;
    lines_total BIGINT;
BEGIN
    affected_transaction_id := COALESCE(NEW.transaction_id, OLD.transaction_id);

    SELECT COALESCE(SUM(amount_cents), 0) INTO lines_total
    FROM journal_lines
    WHERE transaction_id = affected_transaction_id;

    IF lines_total <> 0 THEN
        RAISE EXCEPTION 'transaction % is unbalanced: journal lines sum to % (must be 0)',
            affected_transaction_id, lines_total;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER journal_lines_balance_check
AFTER INSERT OR UPDATE OR DELETE ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION assert_transaction_balanced();
