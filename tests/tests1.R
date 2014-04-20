# Tests of lsmeans for lm and mlm objects

require(lsmeans)

# ---------- multivariate ---------------------------------

MOats.lm <- lm (yield ~ Block + Variety, data = MOats)
MOats.rg <- ref.grid (MOats.lm, 
                mult.levs = list(nitro = c(0,.2,.4,.6)))
lsmeans(MOats.rg, ~ nitro | Variety)

# Try putting missing values whenever Yield is "Marvellous"
# plus another one for good measure
mo = MOats
mo$yield[mo$Variety == "Marvellous", 3] <- NA
mo$yield[2,4] <- NA
mo.lm <- lm (yield ~ Block + Variety, data = mo)
lsmeans(mo.lm, "Variety")

# Same as above, but use na.exclude
## In R 3.0.2, this will return NAs for the SEs and test stats
## Reported as Bug 15693 - should be fixed in later versions
mo.excl.lm <- lm (yield ~ Block + Variety, data = mo, na.action = na.exclude)
lsmeans(mo.excl.lm, "Variety")


# ------------ univariate -------------
# make an unbalanced, collinear, dataset with covariates
set.seed(19841776)
warp <- warpbreaks[-c(1,2,3,5,8,13,21,34), ]
warp$x1 <- rnorm(nrow(warp), 17, 3)
warp$x2 <- warp$x1^3 / 1007
warp.lm <- lm(breaks ~ poly(x1,3) + x2 + wool*tension, data=warp)
# Note: This model is not full-rank
( warp.lsm <- lsmeans(warp.lm, "tension", by = "wool") )
# (Nothing is estimable)

# However, contrasts ARE estimable:
pairs(warp.lsm)

#switcheroo of by variables:
pairs(warp.lsm, by = "tension")

# compare these contrasts
pairs(.Last.value, by = "contrast")

# Test different ways of accessing data
## ... using "with" ...
warp.lm2 <- with(warp, lm(breaks ~ x1 + x2 + wool*tension))
lsmeans(warp.lm2, ~ tension)

## ... using "attach" ...
attach(warp)
warp.lm3 <- lm(breaks ~ x1 + x2 + wool*tension)
lsmeans(warp.lm3, "tension")

detach("warp")
# won't work if detached
try(lsmeans(warp.lm3, "tension")) 

# However, we're OK again if we use 'data'
lsmeans(warp.lm3, "tension", data = warp)



# --------------- Other stuff -------------------
# using cld
cld(warp.lsm)

# passing to glht
require(multcomp)
# This will fail because glht can't deal with rank deficiency
# Hope this changes.
try( as.glht(pairs(warp.lsm)) )

# However, warp.lm2 isn't rank-deficient
warp.lsm2 <- lsmeans(warp.lm2, ~ tension)
warp.con <- contrast(warp.lsm2, "eff")
summary(warp.con, adjust = "sidak")
summary(as.glht(warp.con))

summary(glht(warp.lm2, lsm(eff ~ tension | wool)))

# confint
confint(contrast(warp.lsm2, "trt.vs.ctrl1"))

# lstrends
warp.lm4 <- lm(breaks ~ tension*wool*x1, data = warp)
lstrends(warp.lm4, ~tension|wool, var = "x1")

# exotic chain rule example
lstrends(warp.lm4, ~tension|wool, var = "sqrt(x1-7)")



# -------- Transformations -------------
## ... of response ...
warp.lm5 <- lm(log(breaks) ~ x1 + x2 + tension*wool, data = warp)
warp.lsm5 <- lsmeans(warp.lm5, ~tension | wool)
summary(warp.lsm5)
summary(warp.lsm5, type = "resp")

## In a GLM
# One of the glm examples...
d.AD <- data.frame(treatment = gl(3,3), outcome = gl(3,1,9), 
    counts = c(18,17,15,20,10,20,25,13,12))
glm.D93 <- glm(counts ~ outcome + treatment, family = poisson(), data = d.AD)

( lsm.D93 <- lsmeans(glm.D93, ~ outcome) )
# un-log the results to obtain rates
summary(lsm.D93, type = "resp")

# un-log some comparisons to obtain ratios
summary(contrast(lsm.D93, "trt.vs.ctrl", ref = 2), 
	type = "resp", adjust = "none")