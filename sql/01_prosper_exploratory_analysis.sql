-- Prosper Loan Portfolio Analysis
-- Exploratory and validation queries
--
-- Run individual queries when investigating the data or validating dashboard outputs.
-- The SQL logic is unchanged from the original script; only readability comments were added.

-- Validate that the portfolio extract contains the expected row count.
SELECT COUNT(*)
FROM portfolio_overview_final;

-- Explore borrower-rate bands and related funding/default exposure.
SELECT
    COUNT(*) AS Total_Loans,
    SUM(`LoanOriginalAmount`) AS Total_Funded,
    AVG(`LoanOriginalAmount`) AS Avg_Loan_Amount,
    AVG(`BorrowerAPR`) AS Avg_Borrower_APR,
    AVG(`BorrowerRate`) AS Avg_Borrower_Rate,
    AVG(`Term`) AS Avg_Term
FROM `prosper_loans_final`;

-- Review portfolio volume and funding by loan lifecycle status.
SELECT
    `LoanStatus`,
    COUNT(*) AS Loan_Count,
    SUM(`LoanOriginalAmount`) AS Total_Funded,
    AVG(`LoanOriginalAmount`) AS Avg_Loan_Amount
FROM `prosper_loans_final`
GROUP BY `LoanStatus`
ORDER BY Loan_Count DESC;

-- Compare performance outcomes after classifying loans as good, bad, ongoing, or cancelled.
SELECT
    `LoanOutcome`,
    COUNT(*) AS Loan_Count,
    SUM(`LoanOriginalAmount`) AS Total_Funded,
    AVG(`LoanOriginalAmount`) AS Avg_Loan_Amount
FROM `prosper_loans_final`
GROUP BY `LoanOutcome`
ORDER BY Loan_Count DESC;

-- Calculate headline default and bad-funding exposure metrics.
SELECT
    COUNT(*) AS Total_Loans,

    SUM(CASE
        WHEN `LoanOutcome` = 'Bad' THEN 1
        ELSE 0
    END) AS Bad_Loans,

    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    SUM(CASE
        WHEN `LoanOutcome` = 'Bad'
        THEN `LoanOriginalAmount`
        ELSE 0
    END) AS Bad_Loan_Funded,

    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad'
            THEN `LoanOriginalAmount`
            ELSE 0
        END) / SUM(`LoanOriginalAmount`),
        2
    ) AS Bad_Funded_Percentage

FROM `prosper_loans_final`;

SELECT
    `ProsperRating (Alpha)` AS Prosper_Rating,
    COUNT(*) AS Total_Loans,

    SUM(CASE
        WHEN `LoanOutcome` = 'Bad' THEN 1
        ELSE 0
    END) AS Bad_Loans,

    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`BorrowerAPR`), 4) AS Avg_APR,
    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

GROUP BY `ProsperRating (Alpha)`
ORDER BY Bad_Loan_Rate DESC;

SELECT
    COALESCE(`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    COUNT(*) AS Total_Loans,

    SUM(CASE
        WHEN `LoanOutcome` = 'Bad' THEN 1
        ELSE 0
    END) AS Bad_Loans,

    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    SUM(`LoanOriginalAmount`) AS Total_Funded,

    SUM(CASE
        WHEN `LoanOutcome` = 'Bad'
        THEN `LoanOriginalAmount`
        ELSE 0
    END) AS Bad_Loan_Funded,

    ROUND(
        100.0 *
        SUM(CASE
            WHEN `LoanOutcome` = 'Bad'
            THEN `LoanOriginalAmount`
            ELSE 0
        END)
        / SUM(`LoanOriginalAmount`),
        2
    ) AS Bad_Funded_Rate

FROM `prosper_loans_final`

GROUP BY `ProsperRating (Alpha)`

ORDER BY Bad_Loan_Rate DESC;

SELECT
    COALESCE(`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad'
            THEN `LoanOriginalAmount`
            ELSE 0
        END
    ) AS Bad_Loan_Funded,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad'
                THEN `LoanOriginalAmount`
                ELSE 0
            END
        )
        /
        (
            SELECT SUM(`LoanOriginalAmount`)
            FROM `prosper_loans_final`
            WHERE `LoanOutcome` = 'Bad'
        ),
        2
    ) AS Share_of_All_Bad_Funding

FROM `prosper_loans_final`

GROUP BY `ProsperRating (Alpha)`

ORDER BY Bad_Loan_Funded DESC;

-- Investigate the population without a Prosper rating.
SELECT
    YEAR(`ListingCreationDate`) AS Listing_Year,
    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

WHERE `ProsperRating (Alpha)` IS NULL

GROUP BY YEAR(`ListingCreationDate`)

ORDER BY Listing_Year;

SELECT
    `ProsperScore` AS Prosper_Score,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad'
            THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`BorrowerAPR`), 4) AS Avg_APR,

    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

WHERE `ProsperScore` IS NOT NULL

GROUP BY `ProsperScore`

ORDER BY `ProsperScore`;

SELECT
    `ProsperScore`,
    COUNT(*) AS Total_Loans,
    MIN(`ListingCreationDate`) AS First_Listing,
    MAX(`ListingCreationDate`) AS Last_Listing
FROM `prosper_loans_final`
WHERE `ProsperScore` IN (1, 10, 11)
GROUP BY `ProsperScore`
ORDER BY `ProsperScore`;

SELECT
    `ProsperScore`,
    `ProsperRating (Alpha)` AS Prosper_Rating,
    COUNT(*) AS Loans
FROM `prosper_loans_final`
WHERE `ProsperScore` = 11
GROUP BY
    `ProsperScore`,
    `ProsperRating (Alpha)`
ORDER BY Loans DESC;

SELECT
    `ProsperScore`,
    COUNT(*) AS Total_Loans,
    SUM(CASE
        WHEN `LoanOutcome` = 'Bad' THEN 1
        ELSE 0
    END) AS Bad_Loans,
    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Bad_Loan_Rate
FROM `prosper_loans_final`
WHERE `ProsperScore` IN (1,2,3,4,5,6,7,8,9,10,11)
GROUP BY `ProsperScore`
ORDER BY `ProsperScore`;

SELECT COUNT(*) AS Score_Analysis_Loans
FROM prosper_score_analysis;

SELECT
    `ProsperScore`,
    COUNT(*) AS Total_Loans,
    SUM(CASE
        WHEN `LoanOutcome` = 'Bad' THEN 1
        ELSE 0
    END) AS Bad_Loans,
    ROUND(
        100.0 * SUM(CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS Bad_Loan_Rate
FROM prosper_score_analysis
GROUP BY `ProsperScore`
ORDER BY `ProsperScore`;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    COALESCE(`IncomeRange`, 'Not Specified') AS Income_Range,
    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

GROUP BY `IncomeRange`

ORDER BY Bad_Loan_Rate DESC;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    COALESCE(`IncomeVerifiable`, 'Unknown') AS Income_Verifiable,
    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`StatedMonthlyIncome`), 2) AS Avg_Monthly_Income

FROM `prosper_loans_final`

GROUP BY `IncomeVerifiable`

ORDER BY Bad_Loan_Rate DESC;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    COALESCE(`IncomeRange`, 'Not Specified') AS Income_Range,
    `IncomeVerifiable`,
    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

GROUP BY
    `IncomeRange`,
    `IncomeVerifiable`

ORDER BY
    Bad_Loan_Rate DESC;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    CASE
        WHEN `DebtToIncomeRatio` IS NULL THEN 'Missing'
        WHEN `DebtToIncomeRatio` < 0.10 THEN '<10%'
        WHEN `DebtToIncomeRatio` < 0.20 THEN '10-20%'
        WHEN `DebtToIncomeRatio` < 0.30 THEN '20-30%'
        WHEN `DebtToIncomeRatio` < 0.40 THEN '30-40%'
        WHEN `DebtToIncomeRatio` < 0.50 THEN '40-50%'
        ELSE '50%+'
    END AS DTI_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

GROUP BY DTI_Band

ORDER BY
    CASE
        WHEN DTI_Band = 'Missing' THEN 7
        WHEN DTI_Band = '<10%' THEN 1
        WHEN DTI_Band = '10-20%' THEN 2
        WHEN DTI_Band = '20-30%' THEN 3
        WHEN DTI_Band = '30-40%' THEN 4
        WHEN DTI_Band = '40-50%' THEN 5
        WHEN DTI_Band = '50%+' THEN 6
    END;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    `IncomeRange`,
    
    CASE
        WHEN `DebtToIncomeRatio` < 0.10 THEN '<10%'
        WHEN `DebtToIncomeRatio` < 0.20 THEN '10-20%'
        WHEN `DebtToIncomeRatio` < 0.30 THEN '20-30%'
        WHEN `DebtToIncomeRatio` < 0.40 THEN '30-40%'
        WHEN `DebtToIncomeRatio` < 0.50 THEN '40-50%'
        ELSE '50%+'
    END AS DTI_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

WHERE `DebtToIncomeRatio` IS NOT NULL

GROUP BY
    `IncomeRange`,
    DTI_Band

HAVING COUNT(*) >= 100

ORDER BY
    `IncomeRange`,
    DTI_Band;

-- Explore credit-score segments and their default performance.
SELECT
    CASE
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 600
            THEN '<600'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 650
            THEN '600-649'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 700
            THEN '650-699'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 750
            THEN '700-749'
        ELSE '750+'
    END AS Credit_Score_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

WHERE `CreditScoreRangeLower` IS NOT NULL
  AND `CreditScoreRangeUpper` IS NOT NULL

GROUP BY Credit_Score_Band

ORDER BY
    CASE
        WHEN Credit_Score_Band = '<600' THEN 1
        WHEN Credit_Score_Band = '600-649' THEN 2
        WHEN Credit_Score_Band = '650-699' THEN 3
        WHEN Credit_Score_Band = '700-749' THEN 4
        WHEN Credit_Score_Band = '750+' THEN 5
    END;

-- Explore credit-score segments and their default performance.
SELECT
    COALESCE(`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    CASE
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 600
            THEN '<600'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 650
            THEN '600-649'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 700
            THEN '650-699'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 750
            THEN '700-749'
        ELSE '750+'
    END AS Credit_Score_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

WHERE `CreditScoreRangeLower` IS NOT NULL
  AND `CreditScoreRangeUpper` IS NOT NULL

GROUP BY
    `ProsperRating (Alpha)`,
    Credit_Score_Band

HAVING COUNT(*) >= 100

ORDER BY
    Prosper_Rating,
    Credit_Score_Band;

-- Explore borrower-rate bands and related funding/default exposure.
SELECT
    CASE
        WHEN `BorrowerRate` < 0.10 THEN '<10%'
        WHEN `BorrowerRate` < 0.15 THEN '10-15%'
        WHEN `BorrowerRate` < 0.20 THEN '15-20%'
        WHEN `BorrowerRate` < 0.25 THEN '20-25%'
        WHEN `BorrowerRate` < 0.30 THEN '25-30%'
        ELSE '30%+'
    END AS Rate_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(`LoanOriginalAmount`), 2) AS Avg_Loan_Amount

FROM `prosper_loans_final`

WHERE `BorrowerRate` IS NOT NULL

GROUP BY Rate_Band

ORDER BY
    CASE
        WHEN Rate_Band = '<10%' THEN 1
        WHEN Rate_Band = '10-15%' THEN 2
        WHEN Rate_Band = '15-20%' THEN 3
        WHEN Rate_Band = '20-25%' THEN 4
        WHEN Rate_Band = '25-30%' THEN 5
        WHEN Rate_Band = '30%+' THEN 6
    END;

-- Explore borrower-rate bands and related funding/default exposure.
SELECT
    COALESCE(`ProsperRating (Alpha)`, 'Not Rated') AS Prosper_Rating,

    CASE
        WHEN `BorrowerRate` < 0.10 THEN '<10%'
        WHEN `BorrowerRate` < 0.15 THEN '10-15%'
        WHEN `BorrowerRate` < 0.20 THEN '15-20%'
        WHEN `BorrowerRate` < 0.25 THEN '20-25%'
        WHEN `BorrowerRate` < 0.30 THEN '25-30%'
        ELSE '30%+'
    END AS Rate_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

WHERE `BorrowerRate` IS NOT NULL

GROUP BY
    `ProsperRating (Alpha)`,
    Rate_Band

HAVING COUNT(*) >= 100

ORDER BY
    `ProsperRating (Alpha)`,
    MIN(`BorrowerRate`);

-- Explore borrower-rate bands and related funding/default exposure.
SELECT
    CASE
        WHEN `BorrowerRate` < 0.10 THEN '<10%'
        WHEN `BorrowerRate` < 0.15 THEN '10-15%'
        WHEN `BorrowerRate` < 0.20 THEN '15-20%'
        WHEN `BorrowerRate` < 0.25 THEN '20-25%'
        WHEN `BorrowerRate` < 0.30 THEN '25-30%'
        ELSE '30%+'
    END AS Rate_Band,

    COUNT(*) AS Total_Loans,

    ROUND(SUM(`LoanOriginalAmount`), 0) AS Total_Funded,

    ROUND(
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad'
                THEN `LoanOriginalAmount`
                ELSE 0
            END
        ),
        0
    ) AS Bad_Loan_Funded,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad'
                THEN `LoanOriginalAmount`
                ELSE 0
            END
        )
        / SUM(`LoanOriginalAmount`),
        2
    ) AS Bad_Funded_Rate

FROM `prosper_loans_final`

WHERE `BorrowerRate` IS NOT NULL

GROUP BY Rate_Band

ORDER BY
    MIN(`BorrowerRate`);

-- Explore credit-score segments and their default performance.
SELECT
    CASE
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 600
            THEN '<600'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 650
            THEN '600-649'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 700
            THEN '650-699'
        WHEN (`CreditScoreRangeLower` + `CreditScoreRangeUpper`) / 2 < 750
            THEN '700-749'
        ELSE '750+'
    END AS Credit_Score_Band,

    CASE
        WHEN `BorrowerRate` < 0.10 THEN '<10%'
        WHEN `BorrowerRate` < 0.15 THEN '10-15%'
        WHEN `BorrowerRate` < 0.20 THEN '15-20%'
        WHEN `BorrowerRate` < 0.25 THEN '20-25%'
        WHEN `BorrowerRate` < 0.30 THEN '25-30%'
        ELSE '30%+'
    END AS Rate_Band,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN `LoanOutcome` = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN `LoanOutcome` = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate

FROM `prosper_loans_final`

WHERE `CreditScoreRangeLower` IS NOT NULL
  AND `CreditScoreRangeUpper` IS NOT NULL
  AND `BorrowerRate` IS NOT NULL

GROUP BY
    Credit_Score_Band,
    Rate_Band

HAVING COUNT(*) >= 100

ORDER BY
    CASE Credit_Score_Band
        WHEN '<600' THEN 1
        WHEN '600-649' THEN 2
        WHEN '650-699' THEN 3
        WHEN '700-749' THEN 4
        WHEN '750+' THEN 5
    END,
    MIN(`BorrowerRate`);

-- Explore credit-score segments and their default performance.
SELECT
    CASE
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 650
            THEN 'Low Credit'
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 700
            THEN 'Fair Credit'
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 750
            THEN 'Good Credit'
        ELSE 'Excellent Credit'
    END AS Credit_Risk,

    CASE
        WHEN BorrowerRate < 0.15
            THEN 'Low Rate'
        WHEN BorrowerRate < 0.25
            THEN 'Medium Rate'
        ELSE 'High Rate'
    END AS Rate_Risk,

    CASE
        WHEN DebtToIncomeRatio < 0.20
            THEN 'Low DTI'
        WHEN DebtToIncomeRatio < 0.40
            THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS DTI_Risk,

    COUNT(*) AS Total_Loans,

    SUM(
        CASE
            WHEN LoanOutcome = 'Bad' THEN 1
            ELSE 0
        END
    ) AS Bad_Loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN LoanOutcome = 'Bad' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Bad_Loan_Rate,

    ROUND(AVG(LoanOriginalAmount), 2) AS Avg_Loan_Amount

FROM prosper_loans_final

WHERE CreditScoreRangeLower IS NOT NULL
  AND CreditScoreRangeUpper IS NOT NULL
  AND BorrowerRate IS NOT NULL
  AND DebtToIncomeRatio IS NOT NULL

GROUP BY
    Credit_Risk,
    Rate_Risk,
    DTI_Risk

HAVING COUNT(*) >= 100

ORDER BY Bad_Loan_Rate DESC;

-- Explore credit-score segments and their default performance.
SELECT
    CASE
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 650
            THEN 'Low Credit'
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 700
            THEN 'Fair Credit'
        WHEN (CreditScoreRangeLower + CreditScoreRangeUpper) / 2 < 750
            THEN 'Good Credit'
        ELSE 'Excellent Credit'
    END AS Credit_Risk,

    CASE
        WHEN BorrowerRate < 0.15
            THEN 'Low Rate'
        WHEN BorrowerRate < 0.25
            THEN 'Medium Rate'
        ELSE 'High Rate'
    END AS Rate_Risk,

    CASE
        WHEN DebtToIncomeRatio < 0.20
            THEN 'Low DTI'
        WHEN DebtToIncomeRatio < 0.40
            THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS DTI_Risk,

    COUNT(*) AS Total_Loans,

    ROUND(SUM(LoanOriginalAmount), 0) AS Total_Funded,

    ROUND(
        SUM(
            CASE
                WHEN LoanOutcome = 'Bad'
                THEN LoanOriginalAmount
                ELSE 0
            END
        ), 0
    ) AS Bad_Loan_Funded,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN LoanOutcome = 'Bad'
                THEN LoanOriginalAmount
                ELSE 0
            END
        )
        / SUM(LoanOriginalAmount),
        2
    ) AS Bad_Funded_Rate

FROM prosper_loans_final

WHERE CreditScoreRangeLower IS NOT NULL
  AND CreditScoreRangeUpper IS NOT NULL
  AND BorrowerRate IS NOT NULL
  AND DebtToIncomeRatio IS NOT NULL

GROUP BY
    Credit_Risk,
    Rate_Risk,
    DTI_Risk

HAVING COUNT(*) >= 100

ORDER BY Bad_Loan_Funded DESC;

SELECT *
FROM prosper_dashboard_base
LIMIT 10;

-- Explore how income and debt-to-income segments relate to default risk.
SELECT
    DTI_Band,
    COUNT(*) AS Total_Loans,
    SUM(Bad_Loan_Flag) AS Bad_Loans,
    ROUND(
        100.0 * SUM(Bad_Loan_Flag) / COUNT(*),
        2
    ) AS Bad_Loan_Rate
FROM prosper_dashboard_base
GROUP BY DTI_Band
ORDER BY
    CASE DTI_Band
        WHEN '<10%' THEN 1
        WHEN '10-20%' THEN 2
        WHEN '20-30%' THEN 3
        WHEN '30-40%' THEN 4
        WHEN '40-50%' THEN 5
        WHEN '50%+' THEN 6
        WHEN 'Missing' THEN 7
    END;

-- Validate the dashboard KPI outputs against the source table.
SELECT *
FROM prosper_dashboard_kpis;

-- Validate the dashboard KPI outputs against the source table.
-- ============================================================
-- 3. VALIDATE THE DASHBOARD KPIs
-- ============================================================

SELECT *
FROM prosper_dashboard_kpis;

-- Validate the dashboard KPI outputs against the source table.
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(LoanOriginalAmount) AS Loans_With_Funding,
    SUM(LoanOriginalAmount) AS Total_Funding,
    MIN(LoanOriginalAmount) AS Min_Loan,
    MAX(LoanOriginalAmount) AS Max_Loan
FROM prosper_loans_final;

SELECT
    COUNT(*) AS Total_Loans,
    SUM(CASE WHEN LoanOutcome = 'Bad' THEN 1 ELSE 0 END) AS Bad_Loans,
    SUM(LoanOriginalAmount) AS Total_Funding,
    SUM(
        CASE
            WHEN LoanOutcome = 'Bad'
            THEN LoanOriginalAmount
            ELSE 0
        END
    ) AS Bad_Funding
FROM prosper_loans_final;

SELECT *
FROM prosper_chart_credit_score_rate;

SELECT *
FROM prosper_chart_dti_income;

SELECT *
FROM prosper_chart_rating_rate;

SELECT *
FROM prosper_chart_dti_risk;

SELECT *
FROM prosper_chart_credit_score;

