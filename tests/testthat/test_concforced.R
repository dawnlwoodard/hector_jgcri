context("Concentration-forced runs")

rcp45 <- function() newcore(system.file("input", "hector_rcp45.ini",
                                        package = "hector"))

test_that("Concentration-forced runs work for halocarbons", {
  hc <- rcp45()
  invisible(run(hc))
  dates <- seq(startdate(hc), getdate(hc))
  outvars <- c(GLOBAL_TEMP(), "HFC23_concentration")
  out1 <- fetchvars(hc, dates, outvars)
  conc1 <- subset(out1, variable == outvars[2])
  emiss1 <- fetchvars(hc, dates, EMISSIONS_HFC23())
  setvar(hc, conc1$year, HFC23_CONSTRAIN(), conc1$value,
         getunits(HFC23_CONSTRAIN()))
  invisible(reset(hc))
  invisible(run(hc))
  out2 <- fetchvars(hc, dates, outvars)
  expect_equivalent(out1$value, out2$value, tol = 1e-10)

  test_that("Increasing HFC23 concentrations increases global temp", {
    newhfc <- conc1$value * 1.05
    setvar(hc, conc1$year, HFC23_CONSTRAIN(), newhfc,
           getunits(HFC23_CONSTRAIN()))
    invisible(reset(hc))
    invisible(run(hc))
    expect_equal(fetchvars(hc, conc1$year, outvars[2])$value, newhfc)
    newout <- fetchvars(hc, dates, outvars)
    expect_true(all(newout$value >= out2$value))
  })
})

test_that("Concentration-forced runs work for CH4", {
  hc <- rcp45()
  invisible(run(hc))
  dates <- seq(startdate(hc), getdate(hc))
  outvars <- c(GLOBAL_TEMP(), ATMOSPHERIC_CH4())
  out1 <- fetchvars(hc, dates, outvars)
  conc1 <- subset(out1, variable == outvars[2])
  emiss1 <- fetchvars(hc, dates, EMISSIONS_CH4())
  setvar(hc, conc1$year, CH4_CONSTRAIN(), conc1$value, getunits(CH4_CONSTRAIN()))
  invisible(reset(hc))
  invisible(run(hc))
  out2 <- fetchvars(hc, dates, outvars)
  expect_equivalent(out1$value, out2$value, tol = 1e-10)

  test_that("Increasing CH4 concentrations increases global temp", {
    newhfc <- conc1$value * 1.05
    setvar(hc, conc1$year, CH4_CONSTRAIN(), newhfc, getunits(CH4_CONSTRAIN()))
    invisible(reset(hc))
    invisible(run(hc))
    newout <- fetchvars(hc, 2000:2100, outvars)
    expect_equal(fetchvars(hc, conc1$year, outvars[2])$value, newhfc)
    expect_true(all(newout$value >= subset(out2, year %in% 2000:2100)$value))
  })
})

test_that("Concentration-forced runs work for N2O", {
  hc <- rcp45()
  invisible(run(hc))
  dates <- seq(startdate(hc), getdate(hc))
  outvars <- c(GLOBAL_TEMP(), ATMOSPHERIC_N2O())
  out1 <- fetchvars(hc, dates, outvars)
  conc1 <- subset(out1, variable == outvars[2])
  setvar(hc, conc1$year, N2O_CONSTRAIN(), conc1$value, getunits(N2O_CONSTRAIN()))
  invisible(reset(hc))
  invisible(run(hc))
  out2 <- fetchvars(hc, dates, outvars)
  expect_equivalent(out1$value, out2$value, tol = 1e-10)

  test_that("Increasing N2O concentrations increases global temp", {
    newhfc <- conc1$value * 1.05
    setvar(hc, conc1$year, N2O_CONSTRAIN(), newhfc, getunits(N2O_CONSTRAIN()))
    invisible(reset(hc))
    invisible(run(hc))
    expect_equal(fetchvars(hc, conc1$year, outvars[2])$value, newhfc)
    newout <- fetchvars(hc, 2000:2100, outvars)
    expect_true(all(newout$value >= subset(out2, year %in% 2000:2100)$value))
  })
})

test_that("Concentration forcing through INI file works", {

  ini_txt_all <- readLines(system.file("input", "hector_rcp45.ini",
                                       package = "hector"))
  ini_txt <- grep("^ *;", ini_txt_all, value = TRUE, invert = TRUE)
  rxp <- "\\[([[:alnum:]]+)_halocarbon\\]"
  halocarbs <- gsub(rxp, "\\1", grep(rxp, ini_txt, value = TRUE))
  outvars <- c(
    ATMOSPHERIC_CO2(),
    ATMOSPHERIC_CH4(),
    ATMOSPHERIC_N2O(),
    paste0(halocarbs, "_concentration")
  )
  # Run Hector to figure out concentrations
  hc <- rcp45()
  invisible(run(hc))
  yrs <- seq(startdate(hc), enddate(hc))
  results <- fetchvars(hc, yrs, outvars)
  results_sub <- results[, c("year", "variable", "value")]

  wide <- reshape(
    results_sub,
    v.names = "value",
    idvar = "year",
    timevar = "variable",
    direction = "wide"
  )
  names(wide) <- gsub("value\\.", "", names(wide))
  names(wide)[names(wide) == "year"] <- "Date"
  names(wide)[names(wide) == "Ca"] <- CO2_CONSTRAIN()
  names(wide)[names(wide) == "CH4"] <- CH4_CONSTRAIN()
  names(wide)[names(wide) == "N2O"] <- N2O_CONSTRAIN()
  names(wide) <- gsub("_concentration$", "_constrain", names(wide))

  tmp_dir <- tempfile()
  dir.create(tmp_dir, showWarnings = FALSE)

  tmpfile <- file.path(tmp_dir, "test_conc.csv")
  write.csv(wide, tmpfile, row.names = FALSE, quote = FALSE)

  ini_txt <- append(
    ini_txt,
    paste0("N2O_constrain=csv:", tmpfile),
    grep("\\[N2O\\]", ini_txt)
  )

  ini_txt <- append(
    ini_txt,
    paste0("CH4_constrain=csv:", tmpfile),
    grep("\\[CH4\\]", ini_txt)
  )

  for (h in halocarbs) {
    ini_txt <- append(
      ini_txt,
      paste0(h, "_constrain=csv:", tmpfile),
      grep(paste0("\\[", h, "_halocarbon", "\\]"), ini_txt)
    )
  }

  tmprcp45_dir <- file.path(dirname(tmp_dir), "emissions")
  dir.create(tmprcp45_dir, showWarnings = FALSE, recursive = TRUE)
  file.copy(system.file("input", "emissions", "RCP45_emissions.csv", package = "hector"),
            tmprcp45_dir)
  file.copy(system.file("input", "emissions", "volcanic_RF.csv", package = "hector"),
            tmprcp45_dir)
  tmpini <- tempfile(fileext = ".ini")
  writeLines(ini_txt, tmpini)
  hc2 <- newcore(tmpini)
  invisible(run(hc2))
  results2 <- fetchvars(hc2, yrs, outvars)
  expect_equivalent(results, results2)

})
