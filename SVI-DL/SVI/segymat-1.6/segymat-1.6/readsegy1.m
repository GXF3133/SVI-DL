addpath('C:\Users\1\Desktop\wenxian\7L3')

data.segy='7L3.sgy';
[Data,SegyTraceHeaders,SegyHeader]=ReadSegy('data.segy');
wiggle(Data,[],SegyHeader.time,[SegyTraceHeaders.cdp],'VA')
imagesc([SegyTraceHeaders.cdp],[SegyHeader.time],Data)