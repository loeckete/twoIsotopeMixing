food_catalog <- function() {
  # Illustrative endmembers, NOT measured values or population averages.
  data.frame(id=c('corn','rice','wheat','oats','potato','sorghum','cane','beet','oil',
    'beans','tofu','nuts','chicken','pork','beef_corn','beef_c3','eggs','dairy','fish'),
    food=c('Corn / maize (C4)','Rice (C3)','Wheat / bread / pasta (C3)','Oats (C3)',
    'Potato (C3)','Sorghum / millet (C4)','Cane sugar (C4)','Beet sugar (C3)',
    'Vegetable oil (C3 example)','Beans / lentils','Soy / tofu','Nuts / peanuts',
    'Chicken (mixed-feed example)','Pork (mixed-feed example)','Beef (corn-rich feed)',
    'Beef (C3 pasture)','Eggs (mixed-feed example)','Dairy (mixed-feed example)',
    'Marine fish (higher-trophic example)'),
    d13C=c(-12,-27,-26,-27,-26,-12,-12,-26,-29,-26,-26,-27,-19,-20,-16,-25,-19,-22,-18),
    d15N=c(3,3,3,3,3,3,0,0,0,1,1,2,5,5,6,6,5,5,12),
    staple=c(rep(TRUE,9),rep(FALSE,10)),
    protein=c(rep(TRUE,6),rep(FALSE,3),rep(TRUE,10)),stringsAsFactors=FALSE)
}
normalize_parts <- function(x) {
  if (!is.numeric(x) || !length(x) || any(!is.finite(x)) || any(x<0) || sum(x)<=0)
    stop('Use nonnegative parts and at least one positive part in each pool.')
  x/sum(x)
}
mix_diet <- function(s, p, sw, pw, routing=.7, dc=2, dn=5, uC=1, uN=1) {
  if(nrow(s)!=length(sw)||nrow(p)!=length(pw)) stop('Food and weight counts differ.')
  vals<-c(routing,dc,dn,uC,uN)
  if(length(vals)!=5L||any(!is.finite(vals))||routing<0||routing>1||uC<0||uN<0)
    stop('Check routing, offsets, and sensitivity settings.')
  if(any(!is.finite(c(s$d13C,p$d13C,p$d15N)))) stop('Food isotope values must be finite.')
  a<-normalize_parts(sw);b<-normalize_parts(pw)
  cs<-sum(a*s$d13C);cp<-sum(b*p$d13C);np<-sum(b*p$d15N)
  c0<-routing*cp+(1-routing)*cs
  list(C=c0+dc,N=np+dn,precursorC=c0,proteinC=cp,stapleC=cs,proteinN=np,
       sw=a,pw=b,routing=routing,dc=dc,dn=dn,uC=uC,uN=uN,s=s,p=p)
}
preset_config <- function(name='A') {
  x<-list(s=c('rice','wheat','corn'),p=c('beans','chicken','dairy'),sw=c(60,40,0),pw=c(40,40,20),routing=.7,dc=2,dn=5,uC=1,uN=1)
  if(name=='B') x$sw<-c(0,0,100)
  if(name=='C') {x$p<-c('beans','tofu','nuts');x$pw<-c(50,40,10)}
  if(name=='D') {x$p<-c('fish','chicken','dairy');x$pw<-c(80,0,20)}
  x
}
