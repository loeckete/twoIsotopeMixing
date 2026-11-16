# Fingernail isotope mixing lab — ENSCI 3120

Prepared for Tuesday, November 17, 2026. An R/Shiny teaching app using the same Shiny → Shinylive → GitHub Pages architecture as the competition app. Only Shiny and base R are needed at runtime.

## Run in RStudio

Extract this ZIP. Open the `isotope-shiny-app` folder as your working directory. Run:

```r
install.packages("shiny") # once
shiny::runApp("app")
```

## Publish for students

1. Create a new GitHub repository, for example `fingernail-isotope-app`.
2. Copy the contents of this folder into the repository root. Include the hidden `.github/workflows/deploy.yml` file. Do not nest the whole project one level deeper.
3. In repository Settings → Pages → Build and deployment, choose **GitHub Actions** before running the workflow.
4. Commit and push to `main`. The included workflow tests the model and Shiny interactions, exports with Shinylive, and deploys to Pages. It can also be started with Actions → Test and deploy fingernail isotope app → Run workflow.
5. Open the URL reported by the successful deployment. This package has not itself been published.
6. Before class, test the scenarios and downloads on a student laptop and phone. Ask students to open the page early; the first visit downloads the browser R runtime.

For local browser export:

```r
install.packages("shinylive")
shinylive::export("app", "site")
httpuv::runStaticServer("site")
```

## What students can do

- Choose up to three staples/nonprotein sources and three protein sources; set relative contributions independently.
- Choose corn, rice, wheat, oats, potato, sorghum/millet, sugars or oil; choose beans, tofu, nuts, poultry, pork, two beef feeding examples, eggs, dairy, marine fish, or grain protein.
- Predict before running, retain one estimate, compare points on a carbon–nitrogen biplot, examine carbon routing, and export the completed inputs and results to CSV.
- Explore diet-to-nail offsets without confusing sensitivity bars with confidence intervals.

## Model meaning

This is a **forward, illustrative mixing model**, not an inverse dietary reconstruction or a validated individual fingernail predictor. Endmembers are explicitly invented teaching values informed by broad food-isotope contrasts; none is represented as a measured US food mean. Edit `food_catalog()` in `app/model.R` to substitute a measured local dataset.

Staple parts approximate relative **nonprotein carbon contributions**. Protein parts approximate **protein nitrogen contributions** and, under an equal-composition assumption, protein-carbon contributions. They are not food mass, servings, or percentages of total calories. Students can use estimated grams of protein from food labels to allocate the protein pool. Grain protein must be entered in that pool separately; it is not automatically counted from the staple selections. Oils and sugars are available for the nonprotein pool. Three sources per pool deliberately simplify a full diet.

With separately normalized weights a and b and routing fraction r:

```
C_s = sum(a * staple delta13C)
C_p = sum(b * protein delta13C)
N_p = sum(b * protein delta15N)
nail delta13C = (1-r)*C_s + r*C_p + DeltaC
nail delta15N = N_p + DeltaN
```

Linear delta mixing is an approximation using elemental contributions. The app assumes equal assimilation and uses bulk food carbon as a proxy for macronutrient carbon. The initial r=0.70 and DeltaC=+2 per mil are exploratory assumptions, not a calibrated matched parameter pair. DeltaN=+5 per mil is motivated by published human keratin offset estimates; it is not a direct universal nail calibration. Offsets and routing can be varied independently to demonstrate sensitivity, but this does not establish physiological independence.

The bars show only the chosen ± offset ranges, not empirical uncertainty, confidence intervals, or complete prediction intervals. There is no turnover model: clippings reflect earlier nail formation, not the last meal. Many diets can yield similar isotope values. Agricultural nitrogen, animal feed, geography, physiology, amino-acid routing, and actual food isotope measurements would matter for a defensible personal prediction.

## A 15–20 minute investigation

1. Load A; predict, Run, and Keep. Ask students what the axes represent.
2. Load B. Only staple proportions change. Predict before Run. Carbon becomes less negative; nitrogen does not change because the protein pool was held fixed.
3. Run and Keep A again. Compare C, then D. Discuss nitrogen source variation and the difference between food values and tissue offsets.
4. Build a usual or invented diet. Include grain-derived protein. Report the result and two assumptions, rather than an unqualified personal measurement.
5. Change DeltaN from 5 to 3. Ask whether an uncertain offset could be mistaken for a dietary difference. Find two mixtures yielding similar outputs.

Instructor numerical key (all in per mil):

| Scenario | Nail delta13C | Nail delta15N |
|---|---:|---:|
| A | -21.66 | 8.4 |
| B | -17.28 | 8.4 |
| C | -24.25 | 6.1 |
| D | -19.14 | 15.6 |

Loading a preset changes controls but does not run it. Edits leave the completed result visible with a status message. Invalid input retains the last successful result. Downloads contain the completed run, not unsubmitted edits. Predictions and comparisons are session-only; there is no class database or answer submission.

## Verification

Run from the project root:

```sh
Rscript tests/model-tests.R
Rscript tests/shiny-tests.R
```

The tests check hand-calculated reference values, routing limits, weight-scale invariance, offsets, invalid inputs, plot rendering, Run/Keep behavior, and preservation of completed results after edits/errors. GitHub Actions runs both test files before export.

Build-environment validation: independent numerical calculations and static source checks completed. Native R, Shiny execution, browser rendering, and Shinylive export were not executed here because R is unavailable. Run the included tests or use the deployment workflow before class. This app has not been tested at classroom-scale concurrency.

## Sources and their role

- Martinelli et al. (2020), *Carbon and Nitrogen Isotope Ratios of Food and Beverage in Brazil*. https://doi.org/10.3390/molecules25061457 — food pathways, source contrasts, and variability; not the source of the app's exact endmember numbers.
- O'Connell et al. (2012), *The diet-body offset in human nitrogen isotopic values: A controlled dietary study*. https://doi.org/10.1002/ajpa.22140 — measured diet-to-blood offset and inferred human keratin offset of about +5.0–5.3 per mil using other tissue comparisons. Not a controlled fingernail validation of this app.
- Nardoto et al. (2006), *Geographical patterns of human diet derived from stable-isotope analysis of fingernails*. https://doi.org/10.1002/ajpa.20409 — regional diet and production signatures in nails.
- Posit Shinylive for R documentation: https://posit-dev.github.io/r-shinylive/ — browser export and hosting architecture.
