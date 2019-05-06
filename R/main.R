#'SAGMM: A package for Clustering via Stochastic Approximation and Gaussian Mixture Models.
#'
#'The SAGMM package allows for computation 
#'
#'@author Andrew T. Jones and Hien D. Nguyen
#'@references Nguyen, H. D. & Jones, A. T. (2018). Big Data-appropriate clustering via stochastic approximation and Gaussian mixture models. In M. Ahmed & A.-S. K. Pathan (Eds.), Data Analytics:Concepts, Techniques, and Applications. Boca Raton: CRC Press.
#'@docType package
#'@name SAGMM
NULL

#' @import stats MixSim mvtnorm mclust lowmemtkmeans
NULL

#' Return GAMMA
#' 
#' @description  Generate a series of gain factors.
#' @param Number Number of values required.
#' @param BURNIN Number of 'burnin' values at the beginning of sequence
#' @return GAMMA, a vector of gain factors
#' @example
#' g<-gainFactors(10^4, 2*10^3)
#' @export
gainFactors <- function(Number, BURNIN) {
    # Make a sequence of gain factors
    GAMMA <- c(rep(log(Number)/(Number),round(Number/BURNIN)),
               rep(1/Number,Number-round(Number/BURNIN))) 
    return(GAMMA)
}

#' Data for simulations.
#' 
#' @description  Wrapper for MixSim
#' @param Groups Number of mixture components. Default 5.
#' @param Dimensions number of Dimensions. Default 5.
#' @param Number number of samples. Default 10^4.
#' @return List of results: X, Y, simobject.
#' @examples
#' sims<-generateSimData(Groups=10, Dimensions=10, Number=10^4)
#' sims<-generateSimData()
#'
#'@export
generateSimData<-function(Groups=5, Dimensions=5, Number=10^4){
    MS <- MixSim::MixSim(BarOmega=0.01,K=Groups,p=Dimensions,PiLow=(0.1/Groups)) # Simulation code
    Z <- MixSim::simdataset(n=Number,Pi=MS$Pi,Mu=MS$Mu,S=MS$S) # More simulation code, look at package vignette
    X <- Z[[1]] # Extract features
    Y <- Z[[2]] # Extract Labels
    SAMPLE <- sample(1:Number) # Randomize
    X <- X[SAMPLE,] # Randomize
    Y <- Y[SAMPLE] # Randomize
    return(list(X=X, Y=Y, MS=MS))
}


#' Clustering via Stochastic Approximation and Gaussian Mixture Models
#' 
#' @description  Fit a GMM with SA. 
#' @param X numeric maxtrix of the data.
#' @param BURNIN Ratio of observations to use as a burn in before algorithm begins.
#' @param Groups Number of mixture components.
#' @param kstart number of kmeans starts to initialise.
#' @param plot If TRUE generates a plot of the clustering.
#'@return A list containing
#'\item{Cluster}{The clustering of each observation.}
#'\item{plot}{A plot of the clustering (if requested).}
#'\item{l2}{Lambda^2}
#'\item{ARI1}{}
#'\item{ARI2}{}
#'\item{KM}{K-means clustering of the data.}
#'\item{ARI3}{}
#'\item{pi}{The cluster proportions}
#'\item{tau}{Tau matrix.}
#'\item{fit}{Output from C++ loop.}
#' @examples
#' sims<-generateSimData(Groups=10, Dimensions=10, Number=10^4)
#' res1<-SAGMMFit(sims$X, sims$Y)
#'
#'@export
SAGMMFit<-function(X, Y, BURNIN=5, Groups= 5, kstart=10, plot=F){

    Number<-nrow(X) # N observations
    Dimensions <-ncol(X) #dim of data
    
    ### Initialize Algorithm
    KM <- suppressWarnings(stats::kmeans(X[1:round(Number/BURNIN),],Groups,nstart=kstart)) # Use K means on burnin sample
    MU <- KM[[2]] # Get initial MU
    LAMBDA <- rep(max(sqrt(KM$withinss/KM$size)),Groups) # Get initial lambda
    SIGMA <- list() # Make sigma from Lambda
    SIGMA_C<-array(0,c(Dimensions,Dimensions,Groups))
    
    for (gg in 1:Groups) {
      SIGMA[[gg]] <- diag(Dimensions)*LAMBDA[gg]^2/2
      SIGMA_C[,,gg]<-SIGMA[[gg]]
    }
    
    PI <- rep(1/Groups,Groups) # Get initial PI
    PISTAR <- rep(0,Groups) # Solve for initial Pistar
    for (it in 1:100) {
      for (gg in 1:(Groups-1)) {
        PISTAR[gg] <- log((1/PI[gg]-1)^-1*sum(exp(PISTAR[-gg])))
      }
    }

    GAMMA<-gainFactors(Number, BURNIN)

    ### Old stuff
    LAMBDA_O <- LAMBDA # old value of lambda
    MU_O <- MU # Old value of Mu
    PISTAR_O <- PISTAR # Old value of Pistar
  
   
    #MAIN ACTION HERE
    results<-main_loop(Number,Groups, PISTAR_O, MU_O, LAMBDA_O, GAMMA, X, Dimensions, SIGMA_C)
    
    TauMAT<-results$Tau
    PI <-results$PI
    MU <-results$MU
    
    SIGMA <-list()
    for (gg in 1:Groups) {
        SIGMA[[gg]] <- diag(Dimensions)*results$LAMBDA[gg]^2/2
    }
    
  
    Cluster <- apply(TauMAT,1,which.max)
    if(plot){
        p1<-plot(as.data.frame(X),col=Cluster,pch=Y)
    }else{
        p1<-NA
    }
    
    l2<-LAMBDA^2
    ARI1<-adjustedRandIndex(lowmemtkmeans::nearest_cluster(X,KM$centers),Y)
    ARI2<-adjustedRandIndex(Cluster,Y)
    KM <- kmeans(X,Groups,nstart=10)
    ARI3<-adjustedRandIndex(KM$cluster,Y)
    pi <- sort(PI)
    
    retList <-list(Cluster=Cluster, plot=p1, l2=l2, ARI1 = ARI1,ARI2 = ARI2, KM=KM, ARI3=ARI3, pi=pi, tau=TauMAT, fit=results)
    
    return(retList)
}