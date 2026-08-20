# Prosper Loan Portfolio & Credit Risk Analysis

> End-to-end credit risk analysis of Prosper loan data using **Python, MySQL, and Power BI**.

This project analyzes a Prosper loan portfolio to understand **borrower credit quality, loan pricing, debt-to-income risk, default behavior, and funding exposure**. The workflow moves from raw data preparation in Python to exploratory and analytical SQL in MySQL, and finally to an interactive three-page Power BI dashboard.

---

## 📊 Project Overview

The objective of this project was to turn a large Prosper loan dataset into a decision-ready credit risk analysis.

The analysis focuses on questions such as:

- How large is the overall loan portfolio?
- How much funding is exposed to bad loans?
- How does bad-loan risk change with borrower credit score?
- Does higher borrower interest rate correspond to higher default risk?
- How do debt-to-income levels affect loan performance?
- How does Prosper Rating interact with loan pricing and default risk?
- Which combinations of credit quality, rate, and DTI represent the highest-risk portfolio segments?

### Portfolio Snapshot

| KPI | Value |
|---|---:|
| **Total Loans** | 113,066 |
| **Total Funded Amount** | $940.12M |
| **Average Loan Amount** | $8,314.76 |
| **Bad Loans** | 17,010 |
| **Bad-Loan Rate** | 15.04% |
| **Bad-Loan Funding** | $109.29M |

> KPI values above represent the validated portfolio-level calculations from the current `prosper_loans_final` dataset used to build the dashboard.

---

# 🛠️ Tools & Technologies

### Python
- Pandas
- NumPy
- Matplotlib
- Jupyter Notebook
- Data cleaning and preprocessing
- Feature engineering
- Exploratory data analysis

### MySQL
- MySQL Workbench
- SQL aggregation
- `CASE`-based risk segmentation
- KPI calculations
- Dashboard-ready views
- Risk-band creation
- Cross-segment analysis

### Power BI
- Power BI Desktop
- Power Query / data modeling
- DAX measures
- KPI cards
- Tables and matrices
- Heatmaps
- Interactive slicers
- Sort-by-column functionality
- Dashboard formatting and layout

---

# 🔄 Project Workflow

```text
Raw Prosper Dataset
        │
        ▼
Python / Jupyter
Data Cleaning & Feature Engineering
        │
        ▼
Cleaned Dataset
        │
        ▼
MySQL
Exploratory Analysis
        │
        ▼
Dashboard-Ready SQL Views
        │
        ▼
Power BI
Data Model + DAX + Visuals
        │
        ▼
3-Page Credit Risk Dashboard
```

---

# 📁 Repository Structure

```text
prosper-credit-analysis/
│
├── data/
│   ├── raw/
│   │   └── prosperLoanData.csv
│   │
│   └── cleaned/
│       └── prosper_analysis_ready.csv
│
├── notebooks/
│   └── prosper_analysis_ready.ipynb
│
├── power bi/
│   ├── Prosper Report.pbix
│   └── Prosper Dashboard.pdf
│
├── sql/
│   ├── 01_prosper_exploratory_analysis.sql
│   └── 02_prosper_dashboard_views_clean.sql
│
├── .gitattributes
└── README.md
```

The large CSV datasets are managed using **Git LFS**.

---

# 🧹 1. Data Preparation — Python

The raw Prosper loan data was prepared in Jupyter using Python.

The cleaning workflow included:

- Inspecting the dataset structure
- Handling missing values
- Converting date fields
- Standardizing categorical fields
- Preparing numeric fields for analysis
- Creating borrower risk segments
- Creating loan pricing/rate bands
- Creating DTI bands
- Creating income ranges
- Creating credit-score bands
- Creating bad-loan indicators
- Preparing fields required for downstream SQL and Power BI analysis

The resulting cleaned dataset was exported for use in MySQL.

**Notebook:** `notebooks/prosper_analysis_ready.ipynb`

---

# 🗄️ 2. SQL Analysis — MySQL

The SQL stage was designed to transform the cleaned loan-level data into reusable analytical datasets.

## Exploratory Analysis

`sql/01_prosper_exploratory_analysis.sql`

The exploratory analysis investigates:

- Loan portfolio size
- Funding distribution
- Loan status
- Borrower credit score
- Borrower rate
- Prosper Rating
- DTI
- Income
- Default/bad-loan behavior
- Risk segmentation
- Portfolio concentration

## Dashboard Views

`sql/02_prosper_dashboard_views_clean.sql`

The SQL workflow creates reusable dashboard views including:

### Portfolio KPIs

`prosper_dashboard_base`

`prosper_dashboard_kpis`

These provide the core fields and measures required for the Power BI model.

### Credit Score × Rate

`prosper_chart_credit_score_rate`

Used to analyze bad-loan behavior across:

- Credit Score Band
- Rate Band

Key measures include:

- Total Loans
- Bad Loans
- Bad-Loan Rate
- Total Funded Amount
- Bad-Loan Funding
- Bad-Funded Rate
- Average Loan Amount

### DTI × Income

`prosper_chart_dti_income`

Used to evaluate borrower affordability and default behavior across:

- Income Range
- DTI Band

### Prosper Rating × Rate

`prosper_chart_rating_rate`

Used to analyze the relationship between:

- Prosper Rating
- Borrower Rate
- Default risk
- Funding exposure

### DTI Risk

`prosper_chart_dti_risk`

Used for combined risk segmentation across:

- Credit Risk
- Rate Risk
- DTI Risk

The views also contain dedicated sort fields such as:

- `Credit_Score_Sort`
- `Rate_Sort`
- `Income_Sort`
- `DTI_Sort`
- `Rating_Sort`

These were used in Power BI to prevent categories from being displayed alphabetically.

---

# 📈 3. Power BI Dashboard

The final Power BI report contains three analytical pages.

## Page 1 — Portfolio Overview

### Purpose

Provides a high-level view of the portfolio and highlights the relationship between borrower quality, loan pricing, and default risk.

### KPI Cards

- Total Loans
- Total Funded
- Average Loan Amount
- Bad-Loan Rate
- Bad Loans

### Interactive Slicers

- Loan Status
- Prosper Rating
- Credit Score Band
- Rate Band

### Key Visuals

- Bad Loan Rate by Credit Score
- Bad Loan Rate by Borrower Rate
- Total Loans by Credit Score Band

### Portfolio Takeaway

The overview shows a clear relationship between **higher borrower pricing and higher observed bad-loan rates**.

---

# ⚠️ Page 2 — Borrower Risk Analysis

### Purpose

This page focuses on **segment-level default risk**.

It uses matrix heatmaps to make high-risk combinations immediately visible.

### Risk Analyses

#### Default Risk by Credit Score & Borrower Rate

Bad-loan rates increase substantially when lower credit quality is combined with higher borrower rates.

The highest observed segment in the analysis was:

> **Credit Score <600 + Rate 25–30%: 65.21% bad-loan rate**

The `<600` credit-score segment also reached:

> **55.33% at 30%+ rates**

#### Default Risk by Prosper Rating & Rate

The heatmap shows how borrower pricing interacts with Prosper Rating.

Higher-rate segments generally exhibit substantially higher default risk, while lower-risk ratings tend to have lower bad-loan rates.

#### Default Risk by Income & DTI

The analysis shows that debt burden is an important risk dimension.

The `50%+` DTI segment recorded a **25.41% bad-loan rate**, compared with lower rates across several lower-DTI bands.

#### Default Risk by Credit & DTI

The combined credit/DTI matrix highlights how borrower credit quality and debt burden interact.

This makes it possible to identify segments where **weak credit quality and elevated debt burden overlap**.

---

# 💰 Page 3 — Funding & Credit Insights

### Purpose

Moves from default frequency to **financial exposure**.

This page focuses on where the portfolio's funding and bad-loan funding are concentrated.

### Key Analysis

#### Highest-Risk Portfolio Segments

The DTI Risk view combines:

- Credit Risk
- Rate Risk
- DTI Risk

with:

- Total Loans
- Bad Loans
- Bad-Loan Rate
- Total Funded Amount
- Bad-Loan Funding
- Bad-Funded Rate

This allows risk to be evaluated not only by the number of bad loans, but also by the **amount of capital exposed**.

### Supporting Visuals

- Average Loan Amount by Credit Score
- Bad Loan Funding Concentration by Rate

---

# 🔍 Key Findings

## 1. Higher borrower rates are strongly associated with higher bad-loan rates

The portfolio shows a clear upward relationship between borrower rate and observed bad-loan rate.

The rate bands move from relatively low default rates at the lower end to substantially higher rates at the highest pricing levels.

This suggests that borrower pricing is a strong indicator of underlying credit risk.

---

## 2. Low credit quality combined with high rates creates extreme risk

The strongest risk concentration appears when weak credit scores are combined with high borrower rates.

For borrowers with:

```text
Credit Score <600
```

the bad-loan rate reaches:

```text
41.41%   at <10%
32.26%   at 10–15%
39.06%   at 15–20%
51.28%   at 20–25%
65.21%   at 25–30%
55.33%   at 30%+
```

The `25–30%` segment is particularly notable, with a **65.21% bad-loan rate**.

---

## 3. High DTI borrowers carry elevated default risk

Borrowers with very high debt-to-income ratios show materially higher bad-loan rates.

The `50%+` DTI segment recorded approximately:

> **25.41% bad-loan rate**

This makes DTI an important complementary risk factor alongside credit score and pricing.

---

## 4. Credit quality and DTI should be evaluated together

Looking at credit score or DTI independently can hide important risk concentrations.

The combined Credit Risk × DTI Risk analysis demonstrates why lenders should consider multiple borrower characteristics simultaneously.

A borrower with weak credit quality and elevated debt burden represents a materially different risk profile from a borrower with the same credit quality but low DTI.

---

## 5. Bad-loan risk is also a funding-exposure problem

The portfolio contains approximately:

> **$109.29M in funding associated with bad loans**

Therefore, the analysis does not only identify where defaults are frequent.

It identifies where **financial exposure is concentrated**.

This distinction is important for portfolio management because a segment with a high bad-loan rate may not have the same financial impact as a lower-rate segment with substantially greater funded volume.

---

# 📐 DAX Measures

The Power BI model uses measures for the primary portfolio KPIs.

### Total Loans

```DAX
Total Loans =
COUNTROWS('loandb prosper_dashboard_base')
```

### Bad Loans

```DAX
Bad Loans =
CALCULATE(
    COUNTROWS('loandb prosper_dashboard_base'),
    'loandb prosper_dashboard_base'[LoanOutcome] = "Bad"
)
```

### Bad Loan Rate

```DAX
Bad Loan Rate =
DIVIDE(
    [Bad Loans],
    [Total Loans],
    0
)
```

The model also uses the dashboard-ready SQL views for segment-level measures such as:

- Total Loans
- Bad Loans
- Bad-Loan Rate
- Total Funded Amount
- Bad-Loan Funding
- Bad-Funded Rate
- Average Loan Amount

---

# 🎨 Dashboard Design

The Power BI report was designed as a portfolio-style analytical dashboard rather than a collection of independent charts.

Design principles include:

- Consistent navy/blue visual theme
- Clear page hierarchy
- KPI cards at the top of the overview page
- Consistent percentage formatting
- Ordered categorical fields using Sort-by-Column
- Heatmaps for segment-level risk analysis
- Clear visual titles
- Minimal visual clutter
- Consistent spacing and alignment
- Interactive slicers for borrower and loan segmentation

The three pages follow a deliberate progression:

```text
Portfolio Overview
        ↓
Borrower Risk Analysis
        ↓
Funding & Credit Insights
```

This moves the reader from:

**"What does the portfolio look like?"**

to:

**"Where is the risk?"**

to:

**"Where is the financial exposure?"**

---

# 💡 Business Questions Answered

This project can be used to answer:

| Business Question | Analysis |
|---|---|
| How large is the portfolio? | Portfolio KPIs |
| How much money has been funded? | Total Funded Amount |
| What percentage of loans are bad? | Bad-Loan Rate |
| How much funding is exposed to bad loans? | Bad-Loan Funding |
| Does credit score affect default risk? | Credit Score × Rate |
| Does borrower rate affect default risk? | Rate Band analysis |
| Does DTI affect default risk? | DTI analysis |
| Does income interact with DTI risk? | Income × DTI |
| How does Prosper Rating affect pricing and risk? | Prosper Rating × Rate |
| Which borrower segments are highest risk? | Combined Risk Analysis |
| Where is bad-loan funding concentrated? | Funding & Credit Insights |

---

# 🚀 How to Reproduce the Analysis

## 1. Clone the repository

```bash
git clone https://github.com/21afraz/prosper-credit-analysis.git
cd prosper-credit-analysis
```

## 2. Run the Python notebook

Open:

```text
notebooks/prosper_analysis_ready.ipynb
```

Run the notebook to reproduce the data preparation workflow.

## 3. Load the cleaned dataset into MySQL

Import:

```text
data/cleaned/prosper_analysis_ready.csv
```

into MySQL.

## 4. Run the SQL scripts

Run:

```text
sql/01_prosper_exploratory_analysis.sql
```

followed by:

```text
sql/02_prosper_dashboard_views_clean.sql
```

The second script creates the dashboard-ready views.

## 5. Open the Power BI report

Open:

```text
power bi/Prosper Report.pbix
```

Refresh the data connection and load the SQL views.

---

# 📂 Project Deliverables

| Deliverable | Location |
|---|---|
| Raw dataset | `data/raw/` |
| Cleaned dataset | `data/cleaned/` |
| Python analysis | `notebooks/` |
| Exploratory SQL | `sql/01_prosper_exploratory_analysis.sql` |
| Dashboard SQL views | `sql/02_prosper_dashboard_views_clean.sql` |
| Power BI report | `power bi/Prosper Report.pbix` |
| Dashboard PDF | `power bi/Prosper Dashboard.pdf` |

---

# 📌 Skills Demonstrated

### Data Analytics
- Data cleaning
- Exploratory data analysis
- Feature engineering
- Risk segmentation
- Portfolio analysis
- Business insight generation

### SQL
- Aggregations
- Conditional logic
- `CASE` statements
- KPI calculations
- Analytical views
- Multi-dimensional segmentation
- Dashboard data preparation

### Power BI
- Data modeling
- DAX
- KPI design
- Interactive slicers
- Matrix heatmaps
- Conditional formatting
- Sort-by-Column
- Dashboard UX
- Portfolio storytelling

### Business / Finance
- Credit risk analysis
- Default analysis
- Loan pricing analysis
- Funding exposure
- Borrower segmentation
- Portfolio risk concentration

---

# 📊 Final Dashboard

The Power BI report contains three pages:

1. **Portfolio Overview** — portfolio KPIs, credit quality, pricing and bad-loan trends
2. **Borrower Risk Analysis** — credit, rate, DTI, income and Prosper Rating risk segmentation
3. **Funding & Credit Insights** — funding exposure and highest-risk portfolio segments

The PDF version of the dashboard is included in:

```text
power bi/Prosper Dashboard.pdf
```

---

# 👤 Author

**Afraz Khan**

IT Engineering Student | Data Analytics | Python | SQL | Power BI

---

## ⭐ Project Summary

This project demonstrates an end-to-end analytics workflow:

> **Raw Data → Python → MySQL → Power BI → Business Insights**

Rather than stopping at descriptive statistics, the analysis connects **borrower characteristics, loan pricing, default probability, and financial exposure** to identify the portfolio segments that represent the greatest credit risk.

