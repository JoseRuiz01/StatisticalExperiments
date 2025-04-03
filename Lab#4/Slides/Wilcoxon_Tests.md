# Wilcoxon Tests

## Loading Libraries
To perform the Wilcoxon tests, the following R libraries are required:
```r
library(tidyverse)  # For data manipulation and visualization
library(gtools)     # For generating combinations
library(coin)       # For statistical tests
```

---

## Wilcoxon Signed-Rank Test

### Overview
The Wilcoxon signed-rank test is a non-parametric test used to compare two related samples, matched samples, or repeated measurements on a single sample. It assesses whether their population mean ranks differ. This test is an alternative to the paired t-test when the data cannot be assumed to be normally distributed.

---

### Example: GRE Workshop Study
Three students participated in a study to determine if a two-day workshop on Graduate Record Examination (GRE) preparation improved their GRE analytical writing scores. The results are as follows:

| Student | Before | After | Difference (After - Before) | Signed Rank Difference |
|---------|--------|-------|-----------------------------|------------------------|
| 1       | 2      | 3     | 1                           | 2                      |
| 2       | 4      | 3.5   | -0.5                        | -1                     |
| 3       | 1.5    | 3     | 1.5                         | 3                      |

- **Negative Difference**: Indicates a lower score after the workshop.
- **Positive Difference**: Indicates an improved score after the workshop.

---

### Hypotheses
- **Null Hypothesis (H₀):** The two-day GRE workshop has no effect, i.e., the population median gained score is 0.
- **Alternative Hypothesis (H₁):** The population median gained score is positive, i.e., 𝐻₁: 𝑚 > 0.

---

### Steps to Solve the Exact Test

1. **Test Statistic**:  
   The test statistic is the sum of the ranks for the positive differences. Ranks are applied to the absolute values of the differences.

2. **Sampling Distribution**:  
   Consider all possible ways positive and negative signs could be assigned to the three differences. For each case, calculate the rank sum for the positive differences. This creates the sampling distribution of the rank sum under the null hypothesis.

3. **P-Value Calculation**:  
   Using the sampling distribution of the rank sum, calculate the p-value for the Wilcoxon signed-rank test.

---

### Possible Ranks and Test Statistic (𝑊) for Sample Size 𝑛 = 3

| Difference Signs | Rank 1 | Rank 2 | Rank 3 | 𝑊 (Rank Sum) |
|-------------------|--------|--------|--------|---------------|
| +, +, +          | 1      | 2      | 3      | 6             |
| -, +, +          | -1     | 2      | 3      | 5             |
| +, -, +          | 1      | -2     | 3      | 4             |
| +, +, -          | 1      | 2      | -3     | 3             |
| -, -, +          | -1     | -2     | 3      | 3             |
| -, +, -          | -1     | 2      | -3     | 2             |
| +, -, -          | 1      | -2     | -3     | 1             |
| -, -, -          | -1     | -2     | -3     | 0             |

The observed sample corresponds to the second row: `-1, 2, 3`, with 𝑊 = 5.

---

### P-Value Calculation
To test the null hypothesis (𝐻₀: 𝑚 = 0) against the alternative hypothesis (𝐻₁: 𝑚 > 0), compute the p-value:

```math
p\text{-}value = P(W \geq 5) = P(W = 5) + P(W = 6) = \frac{2}{8} = 0.25
```

- The p-value is greater than 0.05, indicating that the null hypothesis cannot be rejected.
- However, this p-value is the second smallest achievable with this sample size. To make meaningful decisions, it is recommended to increase the sample size.

---

### Key Takeaway
This example demonstrates how to compute the exact distribution of the test statistic for small sample sizes (𝑛), assuming no ties in the ranked data.

---

## Wilcoxon Rank-Sum Test

### Overview
The Wilcoxon rank-sum test (also known as the Mann-Whitney U test) is a non-parametric test used to compare two independent samples to determine whether they come from the same distribution. It is often used as an alternative to the independent t-test when the data cannot be assumed to be normally distributed.

---

### Example: Comparing Two Treatments
Using the example from slide 26, we have two samples of values corresponding to two different treatments. The ordered data and their ranks are as follows:

| Rank | Value | Treatment |
|------|-------|-----------|
| 1    | 58.5  | 2         |
| 2    | 59.4  | 2         |
| 3    | 65.2  | 1         |
| 4    | 66.2  | 2         |
| 5    | 67.1  | 1         |
| 6    | 68.0  | 2         |
| 7    | 69.4  | 1         |
| 8    | 72.1  | 2         |
| 9    | 74.0  | 1         |
| 10   | 78.2  | 1         |
| 11   | 80.3  | 1         |

The test statistic is the sum of ranks for Treatment 1:

```math
W = 3 + 5 + 7 + 9 + 10 + 11 = 45
```

---

### Generating All Possible Rank Combinations
Using R, generate all possible rank combinations for the first sample:

```r
cmb_1 = data.frame(combinations(11, 6, seq(1:11)))
head(cmb_1)
```

Output:

| X1 | X2 | X3 | X4 | X5 | X6 |
|----|----|----|----|----|----|
| 1  | 2  | 3  | 4  | 5  | 6  |
| 1  | 2  | 3  | 4  | 5  | 7  |
| 1  | 2  | 3  | 4  | 5  | 8  |
| 1  | 2  | 3  | 4  | 5  | 9  |
| 1  | 2  | 3  | 4  | 5  | 10 |
| 1  | 2  | 3  | 4  | 5  | 11 |

---

### P-Value Calculation
To test the null hypothesis (𝐻₀: both samples come from the same distribution) versus the alternative hypothesis (𝐻₁: values for the first sample are systematically higher):

```math
p\text{-}value = P(W \geq 45) = \frac{29}{462} = 0.0627
```

For a bilateral test:

```math
p\text{-}value = 2 \cdot 0.0627 = 0.1255
```

---

### Normal Approximation
Using the normal distribution:

- **Mean (𝜇𝑊):**  
  ```math
  \mu_W = \frac{n_1 (n + 1)}{2} = \frac{6 \cdot 11}{2} = 36
  ```

- **Standard Deviation (𝜎𝑊):**  
  ```math
  \sigma_W = \sqrt{\frac{n_1 n_2 (n + 1)}{12}} = \sqrt{\frac{6 \cdot 5 \cdot 11}{12}} = 5.477
  ```

Without continuity correction:

```math
p\text{-}value = 2 \cdot P(Z \geq \frac{45 - 36}{5.477}) = 0.1003
```

With continuity correction:

```math
p\text{-}value = 2 \cdot P(Z \geq \frac{44.5 - 36}{5.477}) = 0.1206
```

---

### R Code for P-Value Calculation
```r
sample_1 <- c(65.2, 67.1, 69.4, 78.2, 74, 80.3)
sample_2 <- c(59.4, 72.1, 68, 66.2, 58.5)
df <- data.frame(col1 = c(sample_1, sample_2))
df$grupo <- as.factor(c(rep(1, 6), rep(2, 5)))

# Exact test
wilcox_test(col1 ~ grupo, data = df, distribution = "exact")

# Normal approximation without continuity correction
wilcox_test(col1 ~ grupo, data = df)

# Normal approximation with continuity correction
wilcox.test(sample_1, sample_2, exact = FALSE, correct = TRUE)
```

---

### Key Takeaway
The Wilcoxon rank-sum test provides a robust method for comparing two independent samples without assuming normality. The exact test is more accurate for small sample sizes, while the normal approximation is suitable for larger samples.