context("Check native R Functions")
library(SAGMM)

test_that("Test gainFactors", {
    
    number<-100
    burnin<-100
    result<-gainFactors(number, burnin)
    
    #types correct
    expect_is(result, "numeric")
    #size
    expect_equal(length(result), x)
    #no missing
    expect_identical(result, na.omit(result))
    
})

test_that("Test generateSimData", {
    
    result<-generateSimData(Groups=10, Dimensions=10, Number=10^2)
   
    #types correct
    expect_is(result, "list")
    expect_is(result[[1]], "matrix")
    expect_is(result[[2]], "integer")
    expect_is(result[[3]], "MixSim")
    
    #no missing
    expect_identical(result, na.omit(result))
    
})

test_that("Test SAGMMFit", {
    sims<-generateSimData(Groups=10, Dimensions=10, Number=10^4)
    result<-SAGMMFit(sims$X, sims$Y, sims$MS)
    
    # #types correct
    expect_is(result, "list")
    # expect_is(result[[1]], "numeric")
    # expect_is(result[[2]], "numeric")
    # expect_is(result[[3]], "numeric")
    # expect_is(result[[4]], "numeric")
    # expect_is(result[[5]], "numeric")
    # expect_is(result[[6]], "matrix")
    # 
    # #dims
    # expect_equal(result[[2]], N)
    # expect_equal(result[[3]], DIM)
    # expect_equal(length(result[[1]]), DIM+1)
    # expect_equal(dim(result[[4]]), c(N,DIM+1))
    
    #no missing
    expect_identical(result, na.omit(result))
    
})

