% 
% Feature extraction,
% 
% interhemispheric asymmetry & power
% 
%by kjsun 2021.1.14
%


Ralpha=[8,13];Rbeta=[13,20];Rdelta=[1,4];Rtheta=[4,8];Rband=[0.5,30];
Fs=256;

%readfile and initialization
path='/Users/sunkaijia/data/depreMU/';
pathdata=[path,'eeg/'];
%file name of data file
filesEO = dir([pathdata filesep  '*EO.edf']);
filesEC = dir([pathdata filesep  '*EC.edf']);
filename = {filesEO.name,filesEC.name};

%初始化特征储存矩阵
feature.alphaweight= zeros(length(filename),19);%feature matrix
feature.alphaasym  = zeros(length(filename),19);%feature matrix

feature.alphapower = zeros(length(filename),19);%feature matrix
feature.betapower  = zeros(length(filename),19);
feature.thetaapower= zeros(length(filename),19);
feature.deltapower = zeros(length(filename),19);



% power feature of every patient/channel
for iname = 1:length(filename)
    pathfile = [pathdata,filename{iname}];
    [data,info] = ReadEDF(pathfile);
    if mod(iname,10)==1
        print iname/length(filename)
    end
    
    for idata = 1:length(data)
        [P,F] = pspectrum(data{idata},Fs,'Leakage',0.85,'spectrogram','OverlapPercent',50);% psd
        P=mean(P,2);
%         subplot(3,1,1);plot(F,P);
%         subplot(3,1,2);plot(F,mean(P,2))
%         [P,F] = pspectrum(data{idata},Fs,'Leakage',0.85);% psd
%         subplot(3,1,3);plot(F,P)
        
        
%         [P,F] = pspectrum(data{idata},Fs,'Leakage',0.85,'OverlapPercent',50);% psd
        
        %the  power of different band
        [pxx,f] = pwelch(data{idata},[],[],[],Fs) ;
        feature.alphapower(iname,idata) = sum(P( ( F<Ralpha(2) ) & ( F>Ralpha(1) ) )) ;
        feature.betapower(iname,idata) = sum(P( ( F<Rbeta(2) ) & ( F>Rbeta(1) ) )) ;
        feature.deltapower(iname,idata) = sum(P( ( F<Rdelta(2) ) & ( F>Rdelta(1) ) )) ;
        feature.thetaapower(iname,idata) = sum(P( ( F<Rtheta(2) ) & ( F>Rtheta(1) ) )) ;
        
        
        %compare the pwelch and pspectrum
%         plot(F,10*log10(P));hold on;plot(f,10*log10(pxx))
        %the alpha weight of every channel
%         P = 10*log10(P);% Power spectral densities
        aweight = sum(P( ( F<Ralpha(2) ) & ( F>Ralpha(1) ) )) / sum(P( ( F<Rband(2) ) & ( F>Rband(1) ) ));
        feature.alphaweight(iname,idata) = aweight;
    end
    
    
end


% the interhemispheric asymmetry，contact Cz,Pz,FPz is zeros.
lchan = 1:8 ;
rchan = 10:17;
for i=1:size(feature.alphaweight,2)
    
    if ismember(i,lchan) %the left channel 
        wchan=repmat(feature.alphaweight(:,i),1,length(rchan));%w in specfic channel
        winterhe=feature.alphaweight(:,rchan);%w in interhe channel
        
        Achan=(wchan-winterhe)./(wchan+winterhe);
        feature.alphaasym(:,i)=mean(Achan,2);
        
    elseif ismember(i,rchan)
        wchan=repmat(feature.alphaweight(:,i),1,length(lchan));%w in specfic channel
        winterhe=feature.alphaweight(:,lchan);%w in interhe channel
        
        Achan=(wchan-winterhe)./(wchan+winterhe);
        feature.alphaasym(:,i)=mean(Achan,2);        
    end
    
end

%channel label 
channelLabel=info.labels;
% H/MDD label of patient H-0,M-1
label = zeros(length(filename),1);
for i = 1:length(filename)
    if strcmp('M',filename{i}(1))
        label(i) = 1;
    end
end


%save the feature matrix,label(o or 1),channelLabel(P1,P2...) in a .mat file 
save([path,'feature/feature.mat'],'feature','label','channelLabel')






