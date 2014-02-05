\name{recover.data}
\alias{recover.data}
\alias{lsm.basis}

% additional ref topic
\alias{extending-lsmeans}


\title{Support functions for creating a reference grid}
\description{
This documents the methods used to create a \code{\link[=ref.grid-class]{ref.grid}} object from a fitted model.
}
\usage{
recover.data(object, ...)

lsm.basis(object, trms, xlev, grid)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
An object returned from a model-fitting function, e.g., \code{\link{lm}} or \code{\link[lme4]{lmer}}.}
  \item{trms}{The \code{\link{terms}} component of \code{object}}
  \item{xlev}{Named list of levels of factors in the model frame. This should \emph{not} include levels of factors created in the model itself, e.g., by including a \code{factor} call in the mdoel formula.}
  \item{grid}{A \code{data.frame} containing predictor values at which predictions are needed.}
  \item{\dots}{Additional arguments passed to other methods (though currently used only by the method for class \code{call}).}
}

\details{
To create a reference grid, the \code{ref.grid} function needs to reconstruct the data used in fitting the model, and then obtain a matrix of linear functions of the regression coefficients for a given grid of predictor values. These tasks are performed by calls to \code{recover.data} and \code{lsm.basis} respectively. 

To extend \pkg{lsmeans}'s support to additional model types, one need only write S3 methods for these two functions. (To see what model objects are currently supported, enter the command \code{methods("lsm.basis")}.) The existing methods serve as helpful guidance for writing new ones.  Most of the work for \code{recover.data} can be done by its method for class \code{"call"}, providing the \code{terms} component as the second argument. Writing an \code{lsm.basis} method is more involved, but the existing methods (e.g., \code{lsmeans:::lsm.basis.lm}) can serve as models. See the ``Value'' section below for details on what it needs to return.

One further detail. If the model has a multivariate response, \code{bhat} needs to be \dQuote{flattened} into a single vector, and \code{X} and \code{V} must be constructed consistently.
}
\value{
A \code{list} with the following elements:
\item{X}{The matrix of linear fcns over \code{grid}, having the same number of rows as \code{grid} and the number of columns equal to the length of \code{bhat}.}
\item{bhat}{The vector of regression coefficients for fixed effects. This should \emph{include} any \code{NA}s that result from rank deficiencies.}
\item{nbasis}{A matrix whose columns form a basis for non-estimable functions of beta, or a 1x1 matrix of \code{NA} if there is no rank deficiency.}
\item{V}{The estimated covariance matrix of \code{bhat}.}
\item{dffun}{A function of \code{(k, dfargs)} that returns the degrees of freedom associated with \code{sum(k * bhat)}.}
\item{dfargs}{A \code{list} containing additional arguments needed for \code{dffun}.}
}
%\references{}
\author{
Russell V. Lenth
}
%\note{}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{ref.grid}}, \code{\link{ref.grid-class}}
}
%%\examples{}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ models }
\keyword{ regression }