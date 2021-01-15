%
% processing the edf file to standerd 10-20-19 channel file 
% 
% 
% by kj sun 2021.1.7
% 

% transfer the label to standerd labelr 

path='/Users/sunkaijia/data/depreMU/';
pathraw =[path, 'raw/'];
pathsave=[path,'eeg/'];

files = dir([pathraw filesep  '*.edf']);
filename={files.name};
for iname = 1:length(filename)
    
    [data,info]=ReadEDF([pathraw,filename{iname}]);
    filename{iname} 
    for i = 1:length(data)
        
        info.labels{i}=erase(info.labels{i},'EEG ');
        info.labels{i}=erase(info.labels{i},'-LE');
        if strcmp(info.labels{i},'T3')
            info.labels{i}='T7';
        elseif strcmp(info.labels{i},'T4')
            info.labels{i}='T8';
        elseif strcmp(info.labels{i},'T5')
            info.labels{i}='P7';
        elseif strcmp(info.labels{i},'T6')
            info.labels{i}='P8';
        end
    end
    % reference based linked-ear 

    data=cellfun(@(x) x-data{20},data,'UniformOutput',false);
    data(20:end)             =[];

    %delete the bad channel
    info.labels(20:end)      =[];
    info.transducer(20:end)  =[];
    info.units(20:end)       =[];
    info.prefilt(20:end)     =[];
    info.physmin(20:end)     =[];
    info.physmax(20:end)     =[];
    info.digmin(20:end)      =[];
    info.digmax(20:end)      =[];
    info.samplerate(20:end)  =[];

    SaveEDF([pathsave,filename{iname}],data,info)

end

