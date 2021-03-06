% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aadoc.R, R/RcppExports.R
\name{carboncycle}
\alias{carboncycle}
\alias{LAND_CFLUX}
\alias{NBP}
\alias{ATMOSPHERIC_CO2}
\alias{NPP}
\alias{ATMOSPHERIC_C}
\alias{FFI_EMISSIONS}
\alias{LUC_EMISSIONS}
\alias{CO2_CONSTRAIN}
\alias{VEG_C}
\alias{DETRITUS_C}
\alias{SOIL_C}
\alias{NPP_FLUX0}
\title{Identifiers for variables in the Hector carbon cycle component}
\usage{
LAND_CFLUX()

NBP()

ATMOSPHERIC_CO2()

NPP()

ATMOSPHERIC_C()

FFI_EMISSIONS()

LUC_EMISSIONS()

CO2_CONSTRAIN()

VEG_C(biome = "")

DETRITUS_C(biome = "")

SOIL_C(biome = "")

NPP_FLUX0(biome = "")
}
\arguments{
\item{biome}{Biome for which to retrieve parameter. If missing or
`""`, default to `"global"`.}
}
\description{
These identifiers correspond to variables that can be read and/or set in the
carbon cycle
}
\section{Functions}{
\itemize{
\item \code{CO2_CONSTRAIN}: Constrain atmospheric CO2 concentration  (\code{"(ppmv CO2)"})

\item \code{VEG_C}: Vegetation C pool (`"Pg C"`)

\item \code{DETRITUS_C}: Vegetation detritus C pool (`"Pg C"`)

\item \code{SOIL_C}: Soil C pool (`"Pg C"`)

\item \code{NPP_FLUX0}: Initial net primary productivity (NPP)
flux (`"Pg C year^-1"`)
}}

\section{Output variables}{

These variables can be read using the \code{\link{GETDATA}} message type:
\describe{
\item{ATMOSPHERIC_CO2}{Atmospheric CO2 concentration}
\item{ATMOSPHERIC_C}{Atmospheric carbon pool}
\item{LAND_CFLUX}{Annual global C flux from atmosphere into the land. A
  positive value means a net flux from atmosphere into land (i.e. land is a
  net carbon sink), while a negative value means a net flux from land into
  the atmosphere (i.e. land is a net carbon source)}
\item{NBP}{Net biome production (synonymous with \code{LAND_CFLUX}). Note
  that despite the name, this is currently a globally-averaged variable.}
\item{FFI_EMISSIONS}{Fossil fuel and industrial emissions}
\item{LUC_EMISSIONS}{Land use change emissions}
}
}

\section{Input variables}{

\describe{
\item{FFI_EMISSIONS}{Fossil fuel and industrial emissions (\code{"Pg C/yr"})}
\item{LUC_EMISSIONS}{Land use change emissions (\code{"Pg C/yr"})}
\item{CO2_CONSTRAIN}{Prescribed atmospheric CO2 concentration (\code{"ppmv CO2"})}
}
}

\section{Note}{

Because these identifiers are provided as \code{#define} macros in the hector code,
these identifiers are provided in the R interface as function.  Therefore,
these objects must be called to use them; \emph{e.g.}, \code{GETDATA()}
instead of the more natural looking \code{GETDATA}.
}

\seealso{
\link{concentrations} for other gas concentrations and
\link{emissions} for other gas emissions

Other capability identifiers: 
\code{\link{concentrations}},
\code{\link{constraints}},
\code{\link{emissions}},
\code{\link{forcings}},
\code{\link{haloconstrain}},
\code{\link{haloemiss}},
\code{\link{haloforcings}},
\code{\link{methane}},
\code{\link{ocean}},
\code{\link{parameters}},
\code{\link{so2}},
\code{\link{temperature}}
}
\concept{capability identifiers}
