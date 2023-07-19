library(lsr)
library(ggplot2)
library(plyr)
library(lmerTest)
library(performance)
library(interactions)

#Imports and organizing ----

setwd("C:/Users/ariel/Dropbox/Experiments/APP_AVO_Conflicts_EEG/For OSF")
DataWide = read.csv('data/all_EEG_measures.csv')
DataWide$subject = c(3:7,9:11,13:21,23:27,29:35)
Data = wideToLong(DataWide,within = 'Conflict')
Data$Conflict = factor(Data$Conflict)
#rename factor levels
levels(Data$Conflict) <- list ("AP-AP" = "ap","AV-AV" = "av")


#Overall theta analysis ----
#t-test: overall theta activity, FCz
t.test(Data$ThetaFCz03000 ~ Data$Conflict,paired = T,alternative = 'less')
mean(Data$ThetaFCz03000[Data$Conflict == "AV-AV"])
sd(Data$ThetaFCz03000[Data$Conflict == "AV-AV"])
mean(Data$ThetaFCz03000[Data$Conflict == "AP-AP"])
sd(Data$ThetaFCz03000[Data$Conflict == "AP-AP"])
cohensD (Data$ThetaFCz03000 ~ Data$Conflict, method = "paired")

#Box plot of overall theta activity, FCz

ggplot(Data, aes(Conflict,ThetaFCz03000, fill=Conflict)) +
  geom_boxplot()+
  # geom_line() joins the paired datapoints
  # color and size parameters are used to customize line
  geom_line(aes(group = subject), size=1, color='grey', Beta=.8)+
  # geom_point() is used to make points at data values
  # fill and size parameters are used to customize point
  geom_point(aes(fill=Conflict,group=subject),size=2,shape=21)+scale_fill_manual(values = c("#336600", "#990033"))+
  ylab('Theta Power (dB)')+theme_minimal()+
  theme(plot.title=element_text(size = 16))+
  theme(axis.text = element_text(size = 14))+
  theme(axis.title = element_text(size = 14))+
  theme(legend.position = "none")

#Overall Alpha analysis (For SI, to show specificity of the theta effect) ----
#t-test: overall Alpha activity, FCz
t.test(Data$AlphaFCz03000 ~ Data$Conflict,paired = T)
mean(Data$AlphaFCz03000[Data$Conflict == "AV-AV"])
sd(Data$AlphaFCz03000[Data$Conflict == "AV-AV"])
mean(Data$AlphaFCz03000[Data$Conflict == "AP-AP"])
sd(Data$AlphaFCz03000[Data$Conflict == "AP-AP"])
cohensD (Data$AlphaFCz03000 ~ Data$Conflict, method = "paired")

#Box plot of overall Alpha activity, FCz

ggplot(Data, aes(Conflict,AlphaFCz03000, fill=Conflict)) +
  geom_boxplot()+
  # geom_line() joins the paired datapoints
  # color and size parameters are used to customize line
  geom_line(aes(group = subject), size=1, color='grey', Alpha=.8)+
  # geom_point() is used to make points at data values
  # fill and size parameters are used to customize point
  geom_point(aes(fill=Conflict,group=subject),size=2,shape=21)+scale_fill_manual(values = c("#336600", "#990033"))+
  ylab('Alpha Power (dB)')+ggtitle('Midfrontal Alpha Power in AV-AV vs AP-AP conflicts')+theme_minimal()+
  theme(plot.title=element_text(size = 13))+
  theme(axis.text = element_text(size = 10))+
  theme(axis.title = element_text(size = 11))+
  theme(legend.position = "none")

#t-test: overall Alpha activity, Oz
t.test(Data$AlphaOz03000 ~ Data$Conflict,paired = T)
mean(Data$AlphaOz03000[Data$Conflict == "AV-AV"])
sd(Data$AlphaOz03000[Data$Conflict == "AV-AV"])
mean(Data$AlphaOz03000[Data$Conflict == "AP-AP"])
sd(Data$AlphaOz03000[Data$Conflict == "AP-AP"])
cohensD (Data$AlphaOz03000 ~ Data$Conflict, method = "paired")

#Box plot of overall Alpha activity, Oz

ggplot(Data, aes(Conflict,AlphaOz03000, fill=Conflict)) +
  geom_boxplot()+
  # geom_line() joins the paired datapoints
  # color and size parameters are used to customize line
  geom_line(aes(group = subject), size=1, color='grey', Alpha=.8)+
  # geom_point() is used to make points at data values
  # fill and size parameters are used to customize point
  geom_point(aes(fill=Conflict,group=subject),size=2,shape=21)+scale_fill_manual(values = c("#336600", "#990033"))+
  ylab('Alpha Power (dB)')+ggtitle('Posterior Alpha Power in AV-AV vs AP-AP conflicts')+theme_minimal()+
  theme(plot.title=element_text(size = 13))+
  theme(axis.text = element_text(size = 10))+
  theme(axis.title = element_text(size = 11))+
  theme(legend.position = "none")

#Overall beta analysis (For SI, to show specificity of the theta effect)----
#t-test: overall Beta activity, FCz
t.test(Data$BetaFCz03000 ~ Data$Conflict,paired = T)
mean(Data$BetaFCz03000[Data$Conflict == "AV-AV"])
sd(Data$BetaFCz03000[Data$Conflict == "AV-AV"])
mean(Data$BetaFCz03000[Data$Conflict == "AP-AP"])
sd(Data$BetaFCz03000[Data$Conflict == "AP-AP"])
cohensD (Data$BetaFCz03000 ~ Data$Conflict, method = "paired")

#Box plot of overall Beta activity, FCz

ggplot(Data, aes(Conflict,BetaFCz03000, fill=Conflict)) +
  geom_boxplot()+
  # geom_line() joins the paired datapoints
  # color and size parameters are used to customize line
  geom_line(aes(group = subject), size=1, color='grey', Beta=.8)+
  # geom_point() is used to make points at data values
  # fill and size parameters are used to customize point
  geom_point(aes(fill=Conflict,group=subject),size=2,shape=21)+scale_fill_manual(values = c("#336600", "#990033"))+
  ylab('Beta Power (dB)')+ggtitle('Midfrontal Beta Power in AV-AV vs AP-AP conflicts')+theme_minimal()+
  theme(plot.title=element_text(size = 13))+
  theme(axis.text = element_text(size = 10))+
  theme(axis.title = element_text(size = 11))+
  theme(legend.position = "none")

#ERP analysis ----
#t_test on N2
t.test(Data$ampStim250350 ~ Data$Conflict,paired = T)
mean(Data$ampStim250350[Data$Conflict == "AV-AV"])
sd(Data$ampStim250350[Data$Conflict == "AV-AV"])
mean(Data$ampStim250350[Data$Conflict == "AP-AP"])
sd(Data$ampStim250350[Data$Conflict == "AP-AP"])
cohensD (Data$ampStim250350 ~ Data$Conflict, method = "paired")

t.test(Data$latStim250350 ~ Data$Conflict,paired = T)
mean(Data$latStim250350[Data$Conflict == "AV-AV"])
sd(Data$latStim250350[Data$Conflict == "AV-AV"])
mean(Data$latStim250350[Data$Conflict == "AP-AP"])
sd(Data$latStim250350[Data$Conflict == "AP-AP"])
cohensD (Data$latStim250350 ~ Data$Conflict, method = "paired")

#t test on CRN

t.test(Data$ampStim5050 ~ Data$Conflict,paired = T)
mean(Data$ampStim5050[Data$Conflict == "AV-AV"])
sd(Data$ampStim5050[Data$Conflict == "AV-AV"])
mean(Data$ampStim5050[Data$Conflict == "AP-AP"])
sd(Data$ampStim5050[Data$Conflict == "AP-AP"])
cohensD (Data$ampStim5050 ~ Data$Conflict, method = "paired")

t.test(Data$latStim5050 ~ Data$Conflict,paired = T)
mean(Data$latStim5050[Data$Conflict == "AV-AV"])
sd(Data$latStim5050[Data$Conflict == "AV-AV"])
mean(Data$latStim5050[Data$Conflict == "AP-AP"])
sd(Data$latStim5050[Data$Conflict == "AP-AP"])
cohensD (Data$latStim5050 ~ Data$Conflict, method = "paired")

#t test on LPC

t.test(Data$Meanstim650750 ~ Data$Conflict,paired = T)
mean(Data$Meanstim650750[Data$Conflict == "AV-AV"])
sd(Data$Meanstim650750[Data$Conflict == "AV-AV"])
mean(Data$Meanstim650750[Data$Conflict == "AP-AP"])
sd(Data$Meanstim650750[Data$Conflict == "AP-AP"])
cohensD (Data$Meanstim650750 ~ Data$Conflict, method = "paired")


#Predict RT from theta on a single trial basis ----
#prepare and merge behavioral and theta datasets
theta_data = read.csv('data/all_thetas.csv')
theta_data = theta_data[(!is.infinite(theta_data$theta_power)),]

colnames(theta_data)[colnames(theta_data) == "trial_idx"] = "trial_index"

condat <- read.csv('data/choiceTrialsCleaner.csv')

merged_theta <- merge (condat, theta_data, by = c("subject","trial_index"))


merged_theta$theta_zscores = ave(merged_theta$theta_power,c("subject"),FUN = scale)
nrow(merged_theta[abs(merged_theta$theta_zscores) > 3,])

# Only use trials that were not rejected in the artifact rejection process
#load dataset with reject trials indices
library(R.matlab)
indices = readMat("data/indices.mat")
indices = as.data.frame(indices)

#remove rejected trials from merged theta
merged_theta_clean = merged_theta[merged_theta$subject == -1]#initialize empty dataframe with same columns as merged_theta
for (sub in c(3:7,9:11,13:21,23:27,29:35)){
  cur_indices = indices[[sub]][3][[1]]
  cur_dataset = merged_theta[merged_theta$subject == sub & 
                               !(merged_theta$trial_index %in% cur_indices),]
  merged_theta_clean = rbind(merged_theta_clean, cur_dataset)
}

#table of trials left for analysis (for supplementary table 2)
trials_left_behavioral = ddply(merged_theta, c("subject","Conflict"),summarize,
                               num_trials = sum(Select))
trials_left_artrej = ddply(merged_theta_clean, c("subject","Conflict"),summarize,
                           num_trials = sum(Select))
trials_left = merge(trials_left_behavioral,trials_left_artrej, by = c("subject","Conflict"))
trials_left = trials_left[order(trials_left$subject),]
library(rempsyc)
trials_left_table = nice_table(trials_left,
           title = c("Supplementary Table 2", "Trials included in mixed-effect model analysis"),

)
plot(trials_left_table)
flextable::save_as_docx(trials_left_table, path = "trials_table.docx")


#prepare data for mixed model
merged_theta_clean$Conflict = factor(merged_theta_clean$Conflict)
contrasts(merged_theta_clean$Conflict)=matrix(c(-1,1), nrow = 2, byrow=T)
contrasts(merged_theta_clean$Conflict)

merged_theta_clean$theta_power.c = scale(merged_theta_clean$theta_power,scale = F)
merged_theta_clean$subject = factor (merged_theta_clean$subject)

#interaction model
mixed.model.theta.interaction = lmer(RT ~ theta_power.c * Conflict+
                                       (1|subject),
                                     data = merged_theta_clean)
summary(mixed.model.theta.interaction)
r2_nakagawa(mixed.model.theta.interaction,by_group = T)
r2_nakagawa(mixed.model.theta.interaction,by_group = F)

#specifically for ap-ap:
ap_data = merged_theta_clean[merged_theta_clean$Conflict == 'AP-AP',]
mixed.model.theta.ap = lmer(RT ~ theta_power.c +
                              (1|subject),
                            data = ap_data)
summary(mixed.model.theta.ap)
r2_nakagawa(mixed.model.theta.ap)

#specifically for av-av:
av_data = merged_theta_clean[merged_theta_clean$Conflict == 'AV-AV',]

mixed.model.theta.av = lmer(RT ~ theta_power.c +
                              (1|subject),
                            data = av_data)
summary(mixed.model.theta.av)
r2_nakagawa(mixed.model.theta.av)

#Plot of the model:
p1 = interact_plot(mixed.model.theta.interaction, pred=theta_power.c, 
                   modx=Conflict, interval= T,
                   x.label= "Centered Theta Power (dB)", y.label= "RT (ms)", 
                   colors = c("#66C2A5", "#D53E4F"))+
                  theme(text = element_text(size = 18,color = 'black'))
p1
library(viridis)

#Plot of the model, for AP-AP
p2 = ggplot(merged_theta_clean[merged_theta_clean$Conflict == "AP-AP",])+
  xlim(-5,5)+
  geom_smooth(aes (x= theta_power.c , y = RT, color = subject),
              method = lm,se = F, show.legend = F)+
  scale_color_viridis(discrete = T,begin = 0.7,end = 0.7)+
  xlab('Centered Theta Power (dB)')+ylab('RT (ms)')+theme_minimal()+ggtitle('AP-AP')+
  theme(text = element_text(size = 16,face = 'bold'))

p3 =ggplot(merged_theta_clean[merged_theta_clean$Conflict == "AV-AV",])+
  xlim(-5,5)+
  geom_smooth(aes (x= theta_power.c , y = RT, color = subject),
              method = lm,se = F, show.legend = F)+
  scale_color_viridis(discrete = T,begin = 0.65,end = 0.65,option = "A")+
  xlab('Centered Theta Power (dB)')+ylab('RT (ms)')+theme_minimal()+ggtitle('AV-AV')+
  theme(text = element_text(size = 16,face = 'bold'))

library(patchwork)
(p2+p3)

#Predict RT from theta - use also trials that did not pass artifact rejection --------

#prepare data for mixed model
merged_theta$Conflict = factor(merged_theta$Conflict)
contrasts(merged_theta$Conflict)=matrix(c(-1,1), nrow = 2, byrow=T)
contrasts(merged_theta$Conflict)

merged_theta$theta_power.c = scale(merged_theta$theta_power,scale = F)
merged_theta$subject = factor (merged_theta$subject)

#interaction model
mixed.model.theta.interaction = lmer(RT ~ theta_power.c * Conflict+
                                       (1|subject),
                                     data = merged_theta)
summary(mixed.model.theta.interaction)
r2_nakagawa(mixed.model.theta.interaction,by_group = T)
r2_nakagawa(mixed.model.theta.interaction,by_group = F)

#specifically for ap-ap:
ap_data = merged_theta[merged_theta$Conflict == 'AP-AP',]
mixed.model.theta.ap = lmer(RT ~ theta_power.c +
                              (1|subject),
                            data = ap_data)
summary(mixed.model.theta.ap)
r2_nakagawa(mixed.model.theta.ap)

#specifically for av-av:
av_data = merged_theta[merged_theta$Conflict == 'AV-AV',]

mixed.model.theta.av = lmer(RT ~ theta_power.c +
                              (1|subject),
                            data = av_data)
summary(mixed.model.theta.av)
r2_nakagawa(mixed.model.theta.av)

#sanity check - AV-AV is with more theta than AP-AP also here:
theta_by_sub = ddply(merged_theta, c("subject","Conflict"),summarize,
                     mean_theta = mean(theta_power),
                     mean_rt = mean(RT))
hist(theta_by_sub$mean_theta)
theta_by_sub$Conflict = factor(theta_by_sub$Conflict)

class(theta_by_sub$subject)
theta_by_sub$subject = factor(theta_by_sub$subject)

t.test(theta_by_sub$mean_theta~theta_by_sub$Conflict,paired = T)
cohensD(theta_by_sub$mean_theta~theta_by_sub$Conflict, method = "paired")
