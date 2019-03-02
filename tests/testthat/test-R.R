context("Check native R Functions")
library(SAGMM)

test_that("Test gainFactors", {
    
    number<-100
    burnin<-10
    result<-gainFactors(number, burnin)
    
    #types correct
    expect_is(result, "numeric")
    #size
    expect_equal(length(result), number)
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
    sims<-generateSimData(Groups=10, Dimensions=10, Number=10^3)
    result<-SAGMMFit(sims$X, sims$Y, sims$MS)
    
    # #types correct
    expect_is(result, "list")
    expect_is(result[[1]], "integer")
    expect_is(result[[2]], "logical")
    expect_is(result[[3]], "numeric")
    expect_is(result[[4]], "array")
    expect_is(result[[5]], "numeric")
    expect_is(result[[6]], "numeric")
    expect_is(result[[7]], "kmeans")
    expect_is(result[[8]], "numeric")
    expect_is(result[[9]], "numeric")
    expect_is(result[[10]], "MixSim")
    expect_is(result[[11]], "matrix")
    expect_is(result[[12]], "list")
    
    #dims
    expect_equal(length(result), 12)
   
    #no missing
    expect_identical(result, na.omit(result))
    
})

