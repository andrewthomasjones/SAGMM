context("Check exported C++ Functions")
library(SAGMM)

test_that("mahalanobis_HD", {
    
    size<-sample(2:10,1)
    x<-runif(size)
    y<-runif(size)
    A <- matrix(runif(size^2)*2-1, ncol=size) 
    Sigma <- t(A) %*% A
    result<-mahalanobis_HD(x,y,Sigma)
    
    #types correct
    expect_is(result, "numeric")
   
    #no missing
    expect_identical(result, na.omit(result))
    
})

test_that("norm_HD", {
    
    size<-sample(2:10,1)
    x<-runif(size)
    y<-runif(size)
    A <- matrix(runif(size^2)*2-1, ncol=size) 
    Sigma <- t(A) %*% A
    result<-norm_HD(x,y,Sigma)
    
    #types correct
    expect_is(result, "numeric")
    
    #no missing
    expect_identical(result, na.omit(result))
    
})

test_that("main_loop", {
    #set up for test
   
    
    result<-main_loop(Number, Groups, PISTAR_O, MU_O, 
                      LAMBDA_O, GAMMA, X,
                       Dimensions, SIGMA)
    
    # Rcpp::List retList = Rcpp::List::create(
    #     Rcpp::Named("PI")= export_vec(PIvec),
    #     Rcpp::Named("MU")= (MU),
    #     Rcpp::Named("LAMBDA")= export_vec(LAMBDA),
    #     Rcpp::Named("Comps")= export_vec(Comps),
    #     Rcpp::Named("LogLike")= LogLike,
    #     Rcpp::Named("Tau")= TauMAT
    #     
    # );
    
    #types correct
    expect_is(result, "list")
    expect_is(result[[1]], "numeric")
    expect_is(result[[2]], "numeric")
    expect_is(result[[3]], "numeric")
    expect_is(result[[4]], "numeric")
    expect_is(result[[5]], "numeric")
    expect_is(result[[6]], "matrix")
    
    #dims
    expect_equal(result[[2]], N)
    expect_equal(result[[3]], DIM)
    expect_equal(length(result[[1]]), DIM+1)
    expect_equal(dim(result[[4]]), c(N,DIM+1))
    
    #no missing
    expect_identical(result, na.omit(result))
    
})

