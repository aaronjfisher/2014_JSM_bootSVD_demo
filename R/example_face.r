# data from Stirling face dataset:
# http://web.mit.edu/emeyers/www/face_databases.html
# specifically at
# http://pics.psych.stir.ac.uk/2D_face_sets.htm


#' Face matrix for example bootstrap PCA
#'
#' 
#' @details A matrix used from the analysis
#'
#' @references
#' http://pics.psych.stir.ac.uk/2D_face_sets.htm
#'
#'
#' @name faces_mat
#' @docType data
#' @keywords data
NULL


#' vector telling how to unpack a vector from faces_mat into a 2-d array that can be plotted with \code{\link{image}}.
#'
#' 
#' @details A vector containing the number of pixels per image, and number of images
#'
#' @references
#' http://pics.psych.stir.ac.uk/2D_face_sets.htm
#'
#'
#' @name faces_dim
#' @docType data
#' @keywords data
NULL


#' Run eigenface bootstrap standard error example
#'
#' 
#'
#' @param K number of components to compute standard errors for
#' @param showFaceEx Whether examples faces from this dataset be plotted as illustrations of the data
#'
#' @return plots of the first K element-wise standard errors for the eigenfaces
#' @import bootSVD ajfisher colorspace plotrix
#' @export
#'
#' @examples
#' ex_faces()
ex_faces<-function(K=3,showFaceEx=FALSE,verbose=TRUE){


	show_progress<-function(text){
		if(verbose)
			cat(text)
	}

	n<-dim(faces_mat)[2]
	colPC<-rev(diverge_hcl(100))
	colBW<-rev(sequential_hcl(n, h = 260, c = c(0, 0),l=c(0,100)))
	colSE<-rev(sequential_hcl(n, h = 110))

	#to reconstruct from a vector, it's simple:
	get2dFace<-function(vec) array(vec,dim=faces_dim)


	show_progress(paste0('Sample data matrix dimensions: ',dim(faces_mat)[1],' by ',dim(faces_mat)[2],'\n')) #p=92036

	Y<-t(scale(t(faces_mat),scale=FALSE,center=TRUE))

	#image0(get2dFace(-Y[,22]),col=colPC) #demeaned image


	# some other representative face indeces: 10:12 61:66 74:75 79:81
	if(showFaceEx){
		par(mfrow=c(2,3),mar=c(2,2,2,.4),oma=c(0,0,3,0))
		for(face in c(43:45,98:100)) image0(get2dFace(1-faces_mat[,face]),col=colBW)
		mtext('Six example faces from the dataset',outer=TRUE,side=3,font=4,line=.8)
	}

	# approximate how long standard methods would take
	# par(mfrow=c(2,K),mar=c(2,2,2,.4))
	# for(face in 21+1:K) image0(get2dFace(Y[,face]),col=colPC)
	# system.time({
	# for(b in 1:10) svdYt<-fastSvdWide(t(Y),nv=K)
	# })*100/60 #approx 17 min for view='v1'

	timer<-c()
	timer['initial_svd']<-system.time({
		svdYt<-fastSVD(t(Y))
	})['elapsed']
	show_progress('\nGot initial SVD\nCalculating low dimensional bootstrap PC distribution\n')

	#plot(svdYt$d[1:20]^2)

	set.seed(0)
	timer['bootstrap_PCA']<-system.time({
		suppressWarnings({#bootSVD will warn that p is especially large, but in this case the memory requirements are still fine. For the purposes of a speed talk, I will suppress this warning
		b<-bootSVD(V=svdYt$v,d=svdYt$d,U=svdYt$u,B=1000,K=K,output=c('HD_moments'),verbose=verbose)
	})
	})['elapsed']

	if(showFaceEx) disp()
	par(mfrow=c(2,K),mar=c(2,.5,2,6),oma=c(0,0,4,0))	
	
	for(k in 1:K) {
		#not using max_abs_x feature
		colk<-mappal(x=svdYt$v[,k],col_pal=colPC,interp_x=TRUE)
		image0(get2dFace(svdYt$v[,k]),colk,main=paste0('Fitted PC',k),axes=FALSE,autoLegend=TRUE,cex.main=1.5)
		box()
	}
	for(k in 1:K){
		maxSE<-max(unlist(b$HD_moments$sdPCs))
		colk<-mappal(x=b$HD_moments$sdPCs[[k]],col_pal=colSE,type='seq',interp_x=TRUE,max_abs_x=maxSE)
		image0(get2dFace(b$HD_moments$sdPCs[[k]]),col=colk,autoLegend=TRUE,main=paste0('Bootstrap SE, PC',k),axes='FALSE',cex.main=1.5)
		box()
	}

	mtext(paste0('Total computation time: ',round(sum(timer),digits=1),'sec\n','B=1000; p=',dim(Y)[1],'; n=',dim(Y)[2]),outer=TRUE,side=3,font=4,line=.8)
	

}




