# Prosper Loan Portfolio Analysis

An interactive Power BI dashboard that explores loan portfolio performance, borrower default risk, and the concentration of bad-loan funding across credit, pricing, income, and debt-to-income segments.

## Project objective

Identify the borrower characteristics and loan segments associated with higher default risk, then highlight where bad-loan funding exposure is most concentrated.

## Tools used

- Power BI Desktop — data modeling, DAX measures, dashboard design, and interactive analysis
- SQL — data preparation and segment-level analysis
- Prosper loan dataset

## Dashboard pages

### 1. Portfolio Overview

Summarises the portfolio through core KPIs such as total loans, total funded amount, average loan amount, bad-loan rate, and bad-loan count. Interactive filters allow the portfolio to be explored by Prosper rating, credit-score band, borrower rate band, and loan status.

### 2. Borrower Risk Analysis

Uses heatmaps to compare bad-loan rates across key borrower segments:

- Credit score band and borrower rate
- Prosper rating and borrower rate
- Credit risk and debt-to-income risk
- Income range and debt-to-income ratio

### 3. Funding & Credit Insights

Highlights segments with the largest bad-loan funding exposure, alongside trends in average loan amount by credit-score band and bad-loan funding by borrower-rate band.

## Key insights

- Default risk increases as borrower rates rise, with the highest rate bands showing the greatest bad-loan rates.
- Lower-credit-quality borrower groups consistently carry higher default risk than stronger credit segments.
- Certain combinations of credit risk, borrower rate, and debt-to-income risk account for a disproportionate share of bad-loan funding.
- Average loan amounts generally increase with credit-score band, while risk still needs to be assessed alongside pricing and borrower leverage.

## Business recommendations

1. Strengthen underwriting review for high-rate, low-credit, and high-DTI combinations.
2. Use borrower-rate and credit-risk segments to monitor default exposure early.
3. Prioritise risk-management action using bad-loan funding, not only default rate, to focus on financially material segments.
4. Review pricing and approval thresholds for the segments showing both elevated default risk and large funded exposure.

## Deliverables

- `Prosper_Loan_Portfolio_Analysis_Dashboard.pdf`
- Power BI report (`.pbix`)
- SQL preparation and analysis scripts
- Dashboard screenshots

## Dashboard preview

![Power BI Desktop Prosper Loan Portfolio Analysis
](image.png)

![Borrower Risk Analysis
](image-1.png)

![Funding & Credit Insights
](image-2.png)
---

*This project was created as a data analytics portfolio project using the Prosper loan dataset.*
