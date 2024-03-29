library(rcdk)
args <- commandArgs(trailingOnly = TRUE)
rules <- list(
  list("include"=c(791),"exclude"=c(34)),
  list("include"=c(34,286),"exclude"=c(4)),
  list("include"=c(212),"exclude"=c(34,791)),
  list("include"=c(140),"exclude"=c(34,791,212,242)),
  list("include"=c(471),"exclude"=c(34,791,212,140))
)
dat_path <- args[1]
dat <- read.table(dat_path,comment.char= "",sep="\t",stringsAsFactors = F,header = T)
colnames(dat) <- c("CanonicalSMILES","SkinSensPred Score")
dat$`SkinSensPred Score` <- as.numeric(dat$`SkinSensPred Score`)
if(any(is.na(dat$`SkinSensPred Score`))){
  print("unknown SkinSensPred Score")
}else{
  mols <- try(rcdk::parse.smiles(dat$CanonicalSMILES))
  if(class(mols)=="try-error"){
    print("smiles can not transfer")
  }else{
    fp <- lapply(mols,function(m){
    get.fingerprint(m,type="graph")@bits
  })
  dat$`Out of Consensus Chemical Space` <- sapply(1:nrow(dat),function(i){
    if(dat$`SkinSensPred Score`[i]<=0.4){
      return(any(sapply(rules,function(rule){
        return(all(rule$include%in%fp[[i]])&&all(!(rule$exclude%in%fp[[i]])))
      })))
    }else{
      return("-")
    }
  })
}
write.table(dat,file="output.tsv",sep="\t",row.names = F)

}
