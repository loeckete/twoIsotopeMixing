library(shiny)
source('model.R',local=TRUE)
foods<-food_catalog()
choices<-function(flag) setNames(foods$id[foods[[flag]]],foods$food[foods[[flag]]])
slot_ui<-function(prefix,i,flag,id,parts) tagList(
  selectInput(paste0(prefix,i),paste('Source',i),choices(flag),selected=id),
  numericInput(paste0(prefix,'w',i),'Relative parts (0 excludes this source)',parts,min=0,max=10000,step=5))
defaults<-preset_config()
ui<-fluidPage(
 tags$head(tags$style(HTML('body{background:#f5f7f6;color:#183b41;font-size:16px}.container-fluid{max-width:1450px}.well{background:white;border:1px solid #d8e3df;border-radius:12px}.note{background:#e5f0ec;padding:14px;border-radius:9px;margin:12px 0}.metric{background:#183b41;color:white;padding:18px;border-radius:10px;margin:10px 0}.metric strong{font-size:30px;display:block}.btn-primary{background:#136d70;border-color:#136d70}h1,h2,h3{font-weight:650}table{font-size:14px}.shiny-output-error-validation{color:#865000}'))),
 titlePanel('You are what you eat: isotopes in fingernails'),
 p('ENSCI 3120 | Build a diet, predict a shift, then test your explanation.'),
 div(class='note',strong('A teaching model, not a laboratory measurement. '),
 'Choose an invented diet or approximate your usual diet over several months. Food values are illustrative; the model does not identify your diet uniquely.'),
 sidebarLayout(sidebarPanel(width=4,
 selectInput('preset','Classroom scenario',c('A — starting mix'='A','B — staple change'='B','C — protein change'='C','D — another protein change'='D')),
 actionButton('load','Load scenario'),
 tags$details(open=NA,tags$summary('1. Staples and other nonprotein carbon'),
 p('Parts represent relative contributions to the modeled nonprotein carbon pool, not servings or total calories. Include sugar or oil here if relevant.'),
 lapply(1:3,function(i)slot_ui('s',i,'staple',defaults$s[i],defaults$sw[i]))),
 tags$details(open=NA,tags$summary('2. Protein sources'),
 p('Parts represent contributions to total dietary protein (approximately nitrogen). Include protein from grains too. For example, 30 g and 10 g of protein become 30 and 10 parts; these are not grams of food.'),
 lapply(1:3,function(i)slot_ui('p',i,'protein',defaults$p[i],defaults$pw[i]))),
 tags$details(tags$summary('3. Model assumptions'),
 sliderInput('routing','Fraction of nail precursor carbon routed from protein (%)',0,100,70,step=5),
 p('70% is an exploratory setting, not a calibrated human fingernail constant.'),
 numericInput('dc','Carbon offset: nail minus modeled precursor (per mil)',2,min=-3,max=6,step=.1),
 numericInput('dn','Nitrogen offset: nail minus dietary protein (per mil)',5,min=0,max=8,step=.1),
 numericInput('uC','Explore carbon offset ± (per mil)',1,min=0,max=5,step=.1),
 numericInput('uN','Explore nitrogen offset ± (per mil)',1,min=0,max=5,step=.1)),
 actionButton('run','Run estimate',class='btn-primary'),tags$hr(),
 actionButton('keep','Keep for comparison'),actionButton('clear','Clear comparison'),br(),br(),
 downloadButton('csv','Download completed estimate')),
 mainPanel(width=8,
 div(class='note',textOutput('status')),
 tabsetPanel(
 tabPanel('Explore',textAreaInput('prediction','Before running: where will your point move, and why?',rows=2,width='100%'),
 uiOutput('metrics'),plotOutput('isoplot',height='440px'),
 p('Circle = current estimate; open diamond = kept estimate. Bars vary only the selected offsets; they are not confidence intervals and do not include food variability.'),
 tableOutput('comparison'),
 tags$details(tags$summary('Show the calculation'),verbatimTextOutput('calculation'))),
 tabPanel('Diet inputs',h3('Completed run: normalized contributions'),
 p('Each pool sums to 100%. Repeated choices are allowed and combine arithmetically. Grain protein must be entered in the protein pool; choosing a grain as a staple does not add its protein automatically.'),tableOutput('weights'),
 h3('Illustrative food endmembers'),p('All values below are teaching assumptions in per mil, not measurements of foods eaten by you. C3/C4 labels describe plant pathways; animal examples depend on feed or food web. Nitrogen placeholders for sugar and oil are unused.'),tableOutput('catalog')),
 tabPanel('Sensitivity',h3('How much does carbon routing matter?'),
 p('This curve holds your completed diet and offsets fixed and varies only the protein contribution to precursor carbon. It is not a time series or a validated physiological response.'),plotOutput('sensitivity',height='360px')),
 tabPanel('Model and sources',h3('Two elements, different weights'),
 tags$pre('a = staple parts / sum(staple parts)\nb = protein parts / sum(protein parts)\nC_staples = sum(a * staple delta13C)\nC_protein = sum(b * protein delta13C)\nN_protein = sum(b * protein delta15N)\nNail delta13C = (1-r)*C_staples + r*C_protein + DeltaC\nNail delta15N = N_protein + DeltaN'),
 p('Delta notation: delta = 1000 * (R_sample / R_standard - 1), where R is heavy/light isotope ratio. Carbon is relative to VPDB; nitrogen is relative to atmospheric N2. Less-negative delta13C means relatively more 13C.'),
 p('This uses the usual linear delta mixing approximation with element-specific contributions. Protein parts approximate nitrogen weights and protein-carbon weights under equal composition and assimilation. Bulk food carbon values stand in for protein or nonprotein fractions. Real amino-acid routing, digestion, and fractionation are more complex.'),
 p('The carbon offset (+2 per mil) and routing fraction (70%) are illustrative knobs, not a validated matched parameter pair. The +5 per mil nitrogen default is motivated by human keratin work, but is not a universal nail-specific calibration. Try 3 versus 5 per mil.'),
 p('Clipped nails represent earlier growth and integrate past intake; today\'s meal will not immediately change a clipping. There is no growth or turnover model here. Two isotope values cannot uniquely resolve many foods. Similar predictions need not imply similar diets.'),
 h3('Evidence and assumptions'),tags$ul(
 tags$li(a('Martinelli et al. (2020): Carbon and Nitrogen Isotope Ratios of Food and Beverage in Brazil',href='https://doi.org/10.3390/molecules25061457'),'. Supports C3/C4 and food-source contrasts and geographic variability; the app table is NOT copied study means.'),
 tags$li(a('O\'Connell et al. (2012): The diet-body offset in human nitrogen isotopic values',href='https://doi.org/10.1002/ajpa.22140'),'. Controlled diet-to-blood study with a keratin offset inferred using other tissue comparisons; supports exploring about +5 per mil, not claiming direct nail validation.'),
 tags$li(a('Nardoto et al. (2006): Geographical patterns of human diet derived from fingernails',href='https://doi.org/10.1002/ajpa.20409'),'. Fingernail isotope patterns depend on food sources and regional production.')),
 p('No food log or prediction is sent to a class database. Text and kept comparisons last only for this app session. Download if you want to retain the results.')),
 tabPanel('Class investigation',h3('Predict → run → compare → explain'),
 tags$ol(tags$li('Load A. Predict its isotope pattern, then Run and Keep it.'),
 tags$li('Load B. Only the staple mix changes. Predict the direction of each isotope shift, then run. Explain why nitrogen stays fixed in this model.'),
 tags$li('Return to A, run, and keep it. Compare C and D one at a time. Explain the modeled nitrogen changes without claiming that all plant or animal foods have the same value.'),
 tags$li('Build your own usual or invented diet. Record the relative protein contributions, including grains. Report the estimate together with two assumptions.'),
 tags$li('Change the nitrogen offset from 5 to 3. Could uncertainty in this offset be mistaken for a change in diet?'),
 tags$li('Find two different food mixtures with similar predictions. What additional evidence would help distinguish them?')),
 p('Answer in Top Hat when prompted. The app itself does not submit your answers.'))))))
server<-function(input,output,session) {
 config<-reactive({
   ids<-function(pre) vapply(1:3,function(i){z<-input[[paste0(pre,i)]];if(is.null(z)) '' else z},character(1))
   ws<-function(pre) vapply(1:3,function(i){z<-input[[paste0(pre,'w',i)]];if(is.null(z)) NA_real_ else as.numeric(z)},numeric(1))
   list(s=ids('s'),p=ids('p'),sw=ws('s'),pw=ws('p'),routing=input$routing/100,dc=input$dc,dn=input$dn,uC=input$uC,uN=input$uN)
 })
 current<-reactiveVal(NULL);old<-reactiveVal(NULL);error<-reactiveVal(NULL)
 observeEvent(input$load,{
   x<-preset_config(input$preset)
   for(i in 1:3){updateSelectInput(session,paste0('s',i),selected=x$s[i]);updateSelectInput(session,paste0('p',i),selected=x$p[i]);updateNumericInput(session,paste0('sw',i),value=x$sw[i]);updateNumericInput(session,paste0('pw',i),value=x$pw[i])}
   updateSliderInput(session,'routing',value=x$routing*100)
   for(n in c('dc','dn','uC','uN')) updateNumericInput(session,n,value=x[[n]])
 })
 observeEvent(input$run,{
   z<-tryCatch({x<-config();r<-mix_diet(foods[match(x$s,foods$id),],foods[match(x$p,foods$id),],x$sw,x$pw,x$routing,x$dc,x$dn,x$uC,x$uN);r$config<-x;r$prediction<-input$prediction;r},error=function(e)e)
   if(inherits(z,'error')){error(conditionMessage(z));return()};current(z);error(NULL)
 })
 observeEvent(input$keep,{req(current());old(current())})
 observeEvent(input$clear,old(NULL))
 result<-reactive({validate(need(!is.null(current()),'Predict, then press Run estimate.'));current()})
 output$status<-renderText({if(!is.null(error())) return(paste('Unable to run:',error(),'Any results shown are from the last successful run.'))
   if(is.null(current())) return('Load or edit a diet, make a prediction, then Run estimate.')
   if(!identical(config(),current()$config)) return('Controls changed. Results still show the completed run. Press Run estimate to update.')
   'Results show the completed run. Keep it before trying another diet.'})
 output$metrics<-renderUI({r<-result();fluidRow(column(6,div(class='metric','Predicted nail δ¹³C',strong(sprintf('%.1f ‰',r$C)))),column(6,div(class='metric','Predicted nail δ¹⁵N',strong(sprintf('%.1f ‰',r$N)))))})
 output$isoplot<-renderPlot({r<-result();o<-old();sel<-r$p[r$pw>0,];
   xx<-c(-30,-8,r$C+c(-r$uC,r$uC),if(!is.null(o))o$C+c(-o$uC,o$uC));yy<-c(-1,20,r$N+c(-r$uN,r$uN),if(!is.null(o))o$N+c(-o$uN,o$uN))
   par(mar=c(4.5,4.5,1,1));plot(NA,xlim=range(xx)+c(-1,1),ylim=range(yy)+c(-1,1),xlab=expression(delta^{13}*C~'(per mil, VPDB)'),ylab=expression(delta^{15}*N~'(per mil, AIR)'));grid(col='#e0e7e5')
   points(sel$d13C,sel$d15N,pch=17,col='#a57534',cex=1.2)
   segments(r$C-r$uC,r$N,r$C+r$uC,r$N,col='#136d70',lwd=2);segments(r$C,r$N-r$uN,r$C,r$N+r$uN,col='#136d70',lwd=2)
   points(r$C,r$N,pch=19,cex=1.8,col='#136d70')
   if(!is.null(o))points(o$C,o$N,pch=5,cex=2,lwd=2,col='#a54065')
   legend('topleft',c('Current nail estimate','Kept nail estimate','Selected protein endmembers (food)'),pch=c(19,5,17),col=c('#136d70','#a54065','#a57534'),bty='n',cex=.85)
 },res=110)
 output$comparison<-renderTable({r<-result();o<-old();d<-data.frame(Run='Current',delta13C=r$C,delta15N=r$N);if(!is.null(o))d<-rbind(d,data.frame(Run=c('Kept','Current minus kept'),delta13C=c(o$C,r$C-o$C),delta15N=c(o$N,r$N-o$N)));d},digits=1)
 output$calculation<-renderText({r<-result();sprintf('Staple carbon = %.2f; protein carbon = %.2f; protein nitrogen = %.2f\nNail carbon = (1 - %.2f)*%.2f + %.2f*%.2f + %.2f = %.2f per mil\nNail nitrogen = %.2f + %.2f = %.2f per mil',r$stapleC,r$proteinC,r$proteinN,r$routing,r$stapleC,r$routing,r$proteinC,r$dc,r$C,r$proteinN,r$dn,r$N)})
 output$weights<-renderTable({r<-result();rbind(data.frame(Pool='Nonprotein carbon',Food=r$s$food,Percent=100*r$sw),data.frame(Pool='Protein',Food=r$p$food,Percent=100*r$pw))},digits=1)
 output$catalog<-renderTable(foods[c('food','d13C','d15N')],digits=1)
 output$sensitivity<-renderPlot({r<-result();x<-seq(0,1,length.out=101);par(mar=c(4.5,4.5,1,1));plot(100*x,(1-x)*r$stapleC+x*r$proteinC+r$dc,type='l',lwd=3,col='#136d70',xlab='Protein contribution to precursor carbon (%)',ylab='Predicted nail delta13C (per mil)');grid();points(100*r$routing,r$C,pch=19,cex=1.5)},res=110)
 output$csv<-downloadHandler(filename=function()'fingernail-isotope-estimate.csv',content=function(file){r<-result();d<-rbind(data.frame(pool='nonprotein_carbon',food=r$s$food,parts=r$config$sw,weight=r$sw,d13C=r$s$d13C,d15N=NA_real_),data.frame(pool='protein',food=r$p$food,parts=r$config$pw,weight=r$pw,d13C=r$p$d13C,d15N=r$p$d15N));for(n in c('routing','dc','dn','uC','uN','C','N'))d[[n]]<-r[[n]];d$prediction<-if(is.null(r$prediction))'' else r$prediction;d$endmember_status<-'Illustrative teaching assumptions';write.csv(d,file,row.names=FALSE)})
}
shinyApp(ui,server)
