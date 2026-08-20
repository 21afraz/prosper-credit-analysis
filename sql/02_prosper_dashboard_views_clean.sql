-- Prosper Loan Portfolio Analysis
-- Dashboard view definitions
--
-- Run this file from top to bottom to build or refresh the views used by Power BI.
-- The SQL logic is unchanged from the original script; only readability comments were added.

USE loandb;

-- Base portfolio extract used for detailed portfolio reporting.
DROP VIEW IF EXISTS portfolio_overview_final;

-- Base portfolio extract used for detailed portfolio reporting.
CREATE VIEW portfolio_overview_final AS
SELECT
    `ListingKey`,
    `ListingCreationDate`,
    `LoanStatus`,
    `LoanOutcome`,
    `CreditGrade`,
    `ProsperRating (Alpha)`,
    `ProsperScore`,
    `BorrowerAPR`,
    `BorrowerRate`,
    `LoanOriginalAmount`,
    `MonthlyLoanPayment`,
    `Term`,
    `BorrowerState`,
    `Occupation`,
    `EmploymentStatus`,
    `IncomeRange`,
    `StatedMonthlyIncome`,
    `DebtToIncomeRatio`,
    `CreditScoreRangeLower`,
    `CreditScoreRangeUpper`,
    `LoanOriginationDate`,
    `LoanOriginationQuarter`,
    `LP_GrossPrincipalLoss`,
    `LP_NetPrincipalLoss`,
    `EstimatedLoss`,
    `EstimatedReturn`,
    `PercentFunded`,
    `Investors`
FROM `prosper_loans_final`;

-- Focused subset for analysing Prosper Score values.
CREATE OR REPLACE VIEW prosper_score_analysis AS
SELECT *
FROM `prosper_loans_final`
WHERE `ProsperScore` BETWEEN 1 AND 10;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
CREATE OR REPLACE VIEW prosper_dashboard_base AS

SELECT
    ListingKey,

    ListingCreationDate,
    YEAR(ListingCreationDate) AS Listing_Year,

    LoanStatus,
    LoanOutcome,

    LoanOriginalAmount,
    BorrowerAPR,
    BorrowerRate,

    ProsperScore,
    COALESCE(`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    IncomeRange,
    IncomeVerifiable,
    StatedMonthlyIncome,

    DebtToIncomeRatio,

    CASE
        WHEN DebtToIncomeRatio IS NULL
            THEN 'Missing'

        WHEN DebtToIncomeRatio < 0.10
            THEN '<10%'

        WHEN DebtToIncomeRatio < 0.20
            THEN '10-20%'

        WHEN DebtToIncomeRatio < 0.30
            THEN '20-30%'

        WHEN DebtToIncomeRatio < 0.40
            THEN '30-40%'

        WHEN DebtToIncomeRatio < 0.50
            THEN '40-50%'

        ELSE '50%+'
    END AS DTI_Band,

    CreditScoreRangeLower,
    CreditScoreRangeUpper,

    CASE
        WHEN CreditScoreRangeLower IS NULL
          OR CreditScoreRangeUpper IS NULL
            THEN 'Unknown'

        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 600
            THEN '<600'

        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 650
            THEN '600-649'

        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 700
            THEN '650-699'

        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 750
            THEN '700-749'

        ELSE '750+'
    END AS Credit_Score_Band,

    CASE
        WHEN BorrowerRate IS NULL
            THEN 'Unknown'

        WHEN BorrowerRate < 0.10
            THEN '<10%'

        WHEN BorrowerRate < 0.15
            THEN '10-15%'

        WHEN BorrowerRate < 0.20
            THEN '15-20%'

        WHEN BorrowerRate < 0.25
            THEN '20-25%'

        WHEN BorrowerRate < 0.30
            THEN '25-30%'

        ELSE '30%+'
    END AS Rate_Band,

    CASE
        WHEN LoanOutcome = 'Bad'
            THEN 1
        ELSE 0
    END AS Bad_Loan_Flag,

    CASE
        WHEN LoanOutcome = 'Bad'
            THEN LoanOriginalAmount
        ELSE 0
    END AS Bad_Loan_Funded

FROM prosper_loans_final;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
CREATE OR REPLACE VIEW prosper_dashboard_kpis AS

SELECT

    COUNT(*) AS Total_Loans,

    SUM(LoanOriginalAmount) AS Total_Funded_Amount,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    SUM(Bad_Loan_Funded) AS Bad_Loan_Funding,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Average_Loan_Amount

FROM prosper_dashboard_base;

USE loandb;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 1. REBUILD DASHBOARD BASE VIEW
-- ============================================================

CREATE OR REPLACE VIEW prosper_dashboard_base AS
SELECT
    p.*,

    -- --------------------------------------------------------
    -- Bad-loan flags
    -- --------------------------------------------------------
    CASE
        WHEN p.LoanOutcome = 'Bad' THEN 1
        ELSE 0
    END AS Bad_Loan_Flag,

    CASE
        WHEN p.LoanOutcome = 'Bad' THEN p.LoanOriginalAmount
        ELSE 0
    END AS Bad_Loan_Funded,

    -- --------------------------------------------------------
    -- Interest / borrower rate band
    -- --------------------------------------------------------
    CASE
        WHEN p.BorrowerRate < 0.10 THEN '<10%'
        WHEN p.BorrowerRate < 0.15 THEN '10-15%'
        WHEN p.BorrowerRate < 0.20 THEN '15-20%'
        WHEN p.BorrowerRate < 0.25 THEN '20-25%'
        WHEN p.BorrowerRate < 0.30 THEN '25-30%'
        ELSE '30%+'
    END AS Rate_Band,

    -- --------------------------------------------------------
    -- DTI band
    -- --------------------------------------------------------
    CASE
        WHEN p.DebtToIncomeRatio IS NULL THEN 'Missing'
        WHEN p.DebtToIncomeRatio < 0.10 THEN '<10%'
        WHEN p.DebtToIncomeRatio < 0.20 THEN '10-20%'
        WHEN p.DebtToIncomeRatio < 0.30 THEN '20-30%'
        WHEN p.DebtToIncomeRatio < 0.40 THEN '30-40%'
        WHEN p.DebtToIncomeRatio < 0.50 THEN '40-50%'
        ELSE '50%+'
    END AS DTI_Band,

    -- --------------------------------------------------------
    -- Credit-score band
    -- --------------------------------------------------------
    CASE
        WHEN p.CreditScoreRangeLower IS NULL
          OR p.CreditScoreRangeUpper IS NULL
            THEN 'Missing'

        WHEN (p.CreditScoreRangeLower + p.CreditScoreRangeUpper) / 2 < 600
            THEN '<600'

        WHEN (p.CreditScoreRangeLower + p.CreditScoreRangeUpper) / 2 < 650
            THEN '600-649'

        WHEN (p.CreditScoreRangeLower + p.CreditScoreRangeUpper) / 2 < 700
            THEN '650-699'

        WHEN (p.CreditScoreRangeLower + p.CreditScoreRangeUpper) / 2 < 750
            THEN '700-749'

        ELSE '750+'
    END AS Credit_Score_Band,

    -- --------------------------------------------------------
    -- Income range
    -- --------------------------------------------------------
    COALESCE(p.IncomeRange, 'Not specified') AS Income_Range,

    -- --------------------------------------------------------
    -- Prosper rating
    -- --------------------------------------------------------
    COALESCE(p.`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    -- --------------------------------------------------------
    -- Listing year
    -- --------------------------------------------------------
    YEAR(p.ListingCreationDate) AS Listing_Year

FROM prosper_loans_final p;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 2. REBUILD KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW prosper_dashboard_kpis AS
SELECT
    COUNT(*) AS Total_Loans,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Average_Loan_Amount

FROM prosper_dashboard_base;

USE loandb;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 1. CREDIT SCORE × RATE
-- ============================================================
-- Purpose:
-- Analyze how borrower credit quality interacts with
-- interest/borrower rate.

CREATE OR REPLACE VIEW prosper_chart_credit_score_rate AS
SELECT
    Credit_Score_Band,
    Rate_Band,

    -- Sorting fields for Power BI
    CASE Credit_Score_Band
        WHEN '<600'    THEN 1
        WHEN '600-649' THEN 2
        WHEN '650-699' THEN 3
        WHEN '700-749' THEN 4
        WHEN '750+'    THEN 5
        ELSE 6
    END AS Credit_Score_Sort,

    CASE Rate_Band
        WHEN '<10%'   THEN 1
        WHEN '10-15%' THEN 2
        WHEN '15-20%' THEN 3
        WHEN '20-25%' THEN 4
        WHEN '25-30%' THEN 5
        WHEN '30%+'   THEN 6
        ELSE 7
    END AS Rate_Sort,

    COUNT(*) AS Total_Loans,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        100.0 * SUM(Bad_Loan_Funded)
        / NULLIF(SUM(LoanOriginalAmount), 0),
        2
    ) AS Bad_Funded_Rate,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Avg_Loan_Amount

FROM prosper_dashboard_base

WHERE Credit_Score_Band <> 'Missing'

GROUP BY
    Credit_Score_Band,
    Rate_Band

HAVING COUNT(*) >= 100

ORDER BY
    Credit_Score_Sort,
    Rate_Sort;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 2. DTI × INCOME
-- ============================================================
-- Purpose:
-- Identify combinations of borrower income and debt burden
-- associated with elevated default risk.

CREATE OR REPLACE VIEW prosper_chart_dti_income AS
SELECT
    Income_Range,
    DTI_Band,

    -- Sorting fields
    CASE Income_Range
        WHEN '$0' THEN 1
        WHEN '$1-24,999' THEN 2
        WHEN '$25,000-49,999' THEN 3
        WHEN '$50,000-74,999' THEN 4
        WHEN '$75,000-99,999' THEN 5
        WHEN '$100,000+' THEN 6
        WHEN 'Not displayed' THEN 7
        WHEN 'Not specified' THEN 8
        WHEN 'Not employed' THEN 9
        ELSE 10
    END AS Income_Sort,

    CASE DTI_Band
        WHEN '<10%' THEN 1
        WHEN '10-20%' THEN 2
        WHEN '20-30%' THEN 3
        WHEN '30-40%' THEN 4
        WHEN '40-50%' THEN 5
        WHEN '50%+' THEN 6
        WHEN 'Missing' THEN 7
        ELSE 8
    END AS DTI_Sort,

    COUNT(*) AS Total_Loans,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        100.0 * SUM(Bad_Loan_Funded)
        / NULLIF(SUM(LoanOriginalAmount), 0),
        2
    ) AS Bad_Funded_Rate,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Avg_Loan_Amount,

    ROUND(
        AVG(StatedMonthlyIncome),
        2
    ) AS Avg_Monthly_Income

FROM prosper_dashboard_base

GROUP BY
    Income_Range,
    DTI_Band

HAVING COUNT(*) >= 100

ORDER BY
    Income_Sort,
    DTI_Sort;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 3. PROSPER RATING × RATE
-- ============================================================
-- Purpose:
-- Compare Prosper credit ratings against the actual borrower
-- rate and identify high-risk rate/rating combinations.

CREATE OR REPLACE VIEW prosper_chart_rating_rate AS
SELECT
    Prosper_Rating,
    Rate_Band,

    -- Sorting fields
    CASE Prosper_Rating
        WHEN 'AA' THEN 1
        WHEN 'A' THEN 2
        WHEN 'B' THEN 3
        WHEN 'C' THEN 4
        WHEN 'D' THEN 5
        WHEN 'E' THEN 6
        WHEN 'HR' THEN 7
        WHEN 'Not Rated' THEN 8
        ELSE 9
    END AS Rating_Sort,

    CASE Rate_Band
        WHEN '<10%' THEN 1
        WHEN '10-15%' THEN 2
        WHEN '15-20%' THEN 3
        WHEN '20-25%' THEN 4
        WHEN '25-30%' THEN 5
        WHEN '30%+' THEN 6
        ELSE 7
    END AS Rate_Sort,

    COUNT(*) AS Total_Loans,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        100.0 * SUM(Bad_Loan_Funded)
        / NULLIF(SUM(LoanOriginalAmount), 0),
        2
    ) AS Bad_Funded_Rate,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Avg_Loan_Amount

FROM prosper_dashboard_base

GROUP BY
    Prosper_Rating,
    Rate_Band

HAVING COUNT(*) >= 100

ORDER BY
    Rating_Sort,
    Rate_Sort;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
-- ============================================================
-- 4. DTI RISK
-- ============================================================
-- Purpose:
-- Combine Credit Risk + Rate Risk + DTI Risk into a single
-- portfolio risk segmentation.

CREATE OR REPLACE VIEW prosper_chart_dti_risk AS
SELECT
    Credit_Risk,
    Rate_Risk,
    DTI_Risk,

    -- Sorting fields
    CASE Credit_Risk
        WHEN 'Low Credit' THEN 1
        WHEN 'Fair Credit' THEN 2
        WHEN 'Good Credit' THEN 3
        WHEN 'Excellent Credit' THEN 4
        ELSE 5
    END AS Credit_Risk_Sort,

    CASE Rate_Risk
        WHEN 'Low Rate' THEN 1
        WHEN 'Medium Rate' THEN 2
        WHEN 'High Rate' THEN 3
        ELSE 4
    END AS Rate_Risk_Sort,

    CASE DTI_Risk
        WHEN 'Low DTI' THEN 1
        WHEN 'Medium DTI' THEN 2
        WHEN 'High DTI' THEN 3
        ELSE 4
    END AS DTI_Risk_Sort,

    COUNT(*) AS Total_Loans,

    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        100.0 * SUM(Bad_Loan_Funded)
        / NULLIF(SUM(LoanOriginalAmount), 0),
        2
    ) AS Bad_Funded_Rate,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Avg_Loan_Amount

FROM
(
    SELECT
        *,
        
        -- Credit risk
        CASE
            WHEN Credit_Score_Band IN ('<600', '600-649')
                THEN 'Low Credit'
            WHEN Credit_Score_Band = '650-699'
                THEN 'Fair Credit'
            WHEN Credit_Score_Band = '700-749'
                THEN 'Good Credit'
            WHEN Credit_Score_Band = '750+'
                THEN 'Excellent Credit'
            ELSE 'Unknown'
        END AS Credit_Risk,

        -- Rate risk
        CASE
            WHEN Rate_Band IN ('<10%', '10-15%')
                THEN 'Low Rate'
            WHEN Rate_Band IN ('15-20%', '20-25%')
                THEN 'Medium Rate'
            WHEN Rate_Band IN ('25-30%', '30%+')
                THEN 'High Rate'
            ELSE 'Unknown'
        END AS Rate_Risk,

        -- DTI risk
        CASE
            WHEN DTI_Band IN ('<10%', '10-20%')
                THEN 'Low DTI'
            WHEN DTI_Band IN ('20-30%', '30-40%')
                THEN 'Medium DTI'
            WHEN DTI_Band IN ('40-50%', '50%+')
                THEN 'High DTI'
            ELSE 'Unknown'
        END AS DTI_Risk

    FROM prosper_dashboard_base
) risk_data

GROUP BY
    Credit_Risk,
    Rate_Risk,
    DTI_Risk

HAVING COUNT(*) >= 100

ORDER BY
    Bad_Loan_Rate DESC;

-- Core loan-level view that standardises dashboard dimensions and bad-loan flags.
CREATE OR REPLACE VIEW prosper_chart_credit_score AS
SELECT
    Credit_Score_Band,

    CASE Credit_Score_Band
        WHEN '<600'    THEN 1
        WHEN '600-649' THEN 2
        WHEN '650-699' THEN 3
        WHEN '700-749' THEN 4
        WHEN '750+'    THEN 5
        ELSE 6
    END AS Credit_Score_Sort,

    COUNT(*) AS Total_Loans,
    SUM(Bad_Loan_Flag) AS Bad_Loans,

    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(
        SUM(LoanOriginalAmount),
        2
    ) AS Total_Funded_Amount,

    ROUND(
        SUM(Bad_Loan_Funded),
        2
    ) AS Bad_Loan_Funding,

    ROUND(
        100.0 * SUM(Bad_Loan_Funded)
        / NULLIF(SUM(LoanOriginalAmount), 0),
        2
    ) AS Bad_Funded_Rate,

    ROUND(
        AVG(LoanOriginalAmount),
        2
    ) AS Avg_Loan_Amount

FROM prosper_dashboard_base

WHERE Credit_Score_Band <> 'Missing'

GROUP BY
    Credit_Score_Band

HAVING COUNT(*) >= 100

ORDER BY
    Credit_Score_Sort;

