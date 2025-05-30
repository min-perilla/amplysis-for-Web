\name{NEWS} 
\title{News for Package 'sp'}
\section{Changes in version 2.2-0 (2024-xx-yy)}{
\itemize{
		\item remove exporting C symbols previously used by rgdal and rgeos
}
}
\section{Changes in version 2.1-5 (2024-xx-yy)}{
\itemize{
		\item add pkgdown site
		\item update sp map gallery and move to vignettes
}
}
\section{Changes in version 2.1-4 (2024-04-30)}{
\itemize{
		\item if CRS is NA, do not require (and depend on) presence of package sf; #144
}
}
\section{Changes in version 2.1-3 (2024-01-29)}{
\itemize{
		\item remove use of deprecated is.R()
}
}
\section{Changes in version 2.0-1 (2023-10-16)}{
\itemize{
		\item remove startup message
}
}
\section{Changes in version 2.0-0 (2023-06-20)}{
\itemize{
	\item \code{get_evolution_status()} defaults to 2, meaning sp will no longer call rgdal or rgeos; \code{spTransform} will work using \code{sf::st_transform}.
	\item increase R version required from 3.0.0 to 3.2.0, which was de facto already required (PR from Sebastian Meyer)
}
}
\section{Changes in version 1.6-1 (2023-05-31)}{
\itemize{
	\item add evolution vignette, drop over vignette, add startup message
}
}
\section{Changes in version 1.6-0 (2023-01-19)}{
\itemize{
	\item add get_evolution_status() and set_evolution_status()
}
}
\section{Changes in version 1.5-0 (2022-06-03)}{
\itemize{
	\item merge the evolution branch from rsbivand/sp@evolution
}
}
\section{Changes in version 1.4-7 (2022-04-18)}{
\itemize{
	\item remove S-compatibility DOUBLE_* macros; https://github.com/edzer/sp/pull/115
}
}

\section{Changes in version 1.4-6 (2021-11-14)}{
\itemize{
	\item add CRS cache and update CRS print method; https://github.com/edzer/sp/pull/103
}
}

\section{Changes in version 1.4-2 (2020-05-20)}{
\itemize{
	\item Adding a wkt() method and muting internal warnings; https://github.com/edzer/sp/pull/76
}
}

\section{Changes in version 1.4-1 (2020-02-29)}{
\itemize{
	\item warn on NULL projargs in CRS(); https://github.com/edzer/sp/pull/74
}
}
\section{Changes in version 1.4-0 (2020-02-21)}{
\itemize{
	\item prepare for new (>= 1.5.1) rgdal, which creates and listens to a comments() field of a CRS object carrying a WKT representation of a CRS rather than the proj4string; @rsb, https://github.com/edzer/sp/pull/67 and https://github.com/edzer/sp/pull/69 ; for more info see e.g. https://github.com/edzer/sp/issues/68 and https://github.com/r-spatial/discuss/issues/28
}
}
\section{Changes in version 1.3-2 (2019-11-07)}{
\itemize{
 \item fix length > 1 in coercion to logical error; #54, #60
 \item add \code{is.na} method for \code{CRS} objects
}
}
\section{Changes in version 1.2-5 (2017-06-16)}{
 \itemize{
  \item address error in spplot, leading to display of "Error using packet 1: mixture of missing and non missing values for cex"
  \item address warning from Tomas Kalibera's static code checking
 }
}
\section{Changes in version 1.2-4 (2016-12-21)}{
  \itemize{
    \item fix bug in duplicating objects in C; see \url{https://github.com/edzer/sp/commit/8f8a66090e47cf0f6bbf5549376c0bc07b6c29df}
	\item fix all long/lat-based great circle distance functions; see \url{https://github.com/edzer/sp/commit/d8374ff7efc6735cba9a054748c602bed0672f23} and \url{https://stat.ethz.ch/pipermail/r-sig-geo/2016-December/025201.html}
	\item clarified cellcentre.offset documentation, see \url{https://github.com/edzer/sp/issues/18}
  }
}
\section{Changes in version 1.2-3 (2016-04-06)}{
  \itemize{
	\item update sp gallery, see \url{https://edzer.github.io/sp/}
	\item move \code{methods} from Imports: to Depends:
    \item improve base plot methods for \code{SpatialGridDataFrame} and \code{SpatialPixelsDataFrame} objects, see \url{https://r-spatial.org/r/2016/03/08/plotting-spatial-grids.html} for examples
	\item improve the graticule \code{labels} methods, see \code{?gridlines}
	\item fix hole assignment for triangles, reported in \url{https://stat.ethz.ch/pipermail/r-sig-geo/2016-March/024214.html}
    \item \code{as.SpatialPolygons.GridTopology} drops rownames of coordinates generated, but keeps coordinate (column) names from the \code{cellcentre.offset} slot of the grid
    \item improve examples in \code{over} vignette.
  }
}
\section{Changes in version 1.2-2 (2016-02-05)}{
  \itemize{
	\item method `row.names` for `SpatialPoints` makes unique row names, or drops them.
	\item add a \code{labels} method for \code{gridlines}, drawing labels under varying angle (see \code{gridlines} example)
  	\item add coercion (``as'' methods) from \code{deldir} to \code{SpatialLines} and \code{SpatialPolygons}
	\item migrate sp code base to github
	\item correct \code{[} subsetting when \code{i} is all \code{FALSE}; report by Francois Rousseau.
	\item add \code{geometry<-} method for \code{Spatial}, wrapping \code{addAttrToGeom}
	\item  addressing \code{rbind} and docs issues raised by Kent Johnson on r-sig-geo, 5 Dec 2015
	\item get `row.names` of coords correctly if object is a \code{SpatialPoints}
    \item add non-default coercion \code{SpatialPolygonsDataFrame} to \code{SpatialPolygons}
    \item add comment to \code{SpatialPolygons} coerced from \code{SpatialGrid} or \code{SpatialPixels}
	\item \code{coordinates} method for \code{SpatiaLines} now retains rownames
  }
}

\section{Changes in version 1.2-1 (2015-10-17)}{
  \itemize{
	\item \code{spsample.Spatial} does no longer generate objects with rownames.
	\item \code{CRS} gains argument \code{doCheckCRSArgs}, to allow suppression of the default checking
    \item coercion from \code{Lines} to \code{SpatialPoints} now drops (duplicate) rownames
	\item add coercion from \code{SpatialLines*} to \code{SpatialMultiPoints*}
	\item improve printing of \code{SpatialMultiPoint*} objects
	\item \code{aggregate} now passes \code{minDimension} to \code{rgeos}; explanation of
	\code{aggregate} extended in its vignette
	\item depend on \code{rgeos} version 0.3-13
    \item \code{merge} now accepts \code{"row.names"} or \code{0} for arguments \code{by.x} or \code{by.y}, for compatibility with \code{base::merge}.
    \item \code{aggregate} now accepts parameter \code{minDimension}, introduced for \code{over} in 1.2-0, and passes it on to \code{over} to control when features intersect; see the documentation of \code{over} and its vignette for details.
	\item \code{SpatialMultiPoints} objects with zero features can now exist.
  }
}
\section{Changes in version 1.2-0 (2015-09-01)}{
  \itemize{
    \item Support for \code{SpatialMultiPoints} and
    \code{SpatialMultiPointsDataFrame} objects. Where \code{SpatialPoints}
	are set of points, \code{SpatialMultiPoints} are sets of point sets.
	\code{SpatialPointsDataFrame} objects bind points to attribute values,
	\code{SpatialMultiPointsDataFrame} bind point sets to attribute values.
	Methods supported are subsetting (\code{[}),
	\code{plot}, \code{spplot}, \code{over}, and coercion to
	\code{SpatialPoints} or \code{SpatialPointsDataFrame}. Functions in 
	\CRANpkg{rgeos} support this feature class. See also \code{demo(mp)}.

	\item creating \code{SpatialPoints} objects with duplicated coordinate
	rownames now gives a warning, which will become an error in the future.

    \item Support for Google Earth or OpenStreetMap background maps in
	\code{sp::plot} and \code{spplot}. Maps returned by
    \itemize{
      \item function \code{GetMap} in package \CRANpkg{RgoogleMaps}
	  \item function \code{get_map} in package \CRANpkg{ggmap}
    }
	are now understood by plotting functions in \CRANpkg{sp}. In particular,
	\code{sp::plot} now has an argument \code{bgMap}, \code{spplot}
	now has panel functions \code{panel.RgoogleMaps} and \code{panel.ggmap};
	See \code{demo(webmap)} for examples.

	As these maps assume a web mercator projection, \code{sp::plot} issues a warning 
	if the object to be plotted have a CRS that does not contain \code{"+init=epsg:3857"}

  	\item \code{over} methods that are taken care of by \CRANpkg{rgeos} (anything
	involving \code{SpatialLines}, or \code{SpatialPolygons}-\code{SpatialPolygons})
	gained an argument \code{minDimension}, which causes an ordering of returned
	features by dimension of intersection, and the ability to select a minimun
	dimension (e.g. only area-overlap); this uses \code{gRelate}, and has a 
	computational cost. Documentation found in \code{vignette("over")}.

  }
}
