bootSvdJSMdemo
=======

This package demonstrates the R package bootSVD (Fisher et al., 2014), using the "Stirling" face dataset, available here:

[http://pics.psych.stir.ac.uk/2D_face_sets.htm](http://pics.psych.stir.ac.uk/2D_face_sets.htm)


The package is currently only meant to be used in demonstrations during talks. The only function available is `ex_faces`. More customizable examples can be built off of the bootSVD package directly.

To install:
```S
## if needed
install.packages("devtools")

## main package
library(devtools)
install_github('bootSVD','aaronjfisher')
install_github('ajfisher','aaronjfisher')
install_github('2014_JSM_bootSVD_demo','aaronjfisher')

## run bootstrap PCA on face dataset
library(bootSvdJSMdemo)
ex_faces()
``` 

With standard methods these bootstrap standard errors would require at least 15.7 minutes (see code below). With bootSVD however, exact results are available in approximately 15 seconds.

```S
# center data matrix before doing PCA
Y<-scale(t(faces_mat),scale=FALSE,center=TRUE) 
# Run standard PCA 10 times, then multiply computation time by 100
# to get computation time for 1000 iterations
time_10<-system.time({ #time it 10 times
    for(i in 1:10)
        dump<-fastSVD(Y,nv=3)
})

# minutes required for 1000 traditional bootstrap 
time_10['elapsed'] * 100 / 60
# Approx 15.7 min
```

<br/><br/>

References: 

Aaron Fisher, Brian Caffo, and Vadim Zipunnikov. *Fast, Exact Bootstrap Principal Component Analysis for p>1 million.* Working Paper, 2014. [http://arxiv.org/abs/1405.0922](http://arxiv.org/abs/1405.0922)







