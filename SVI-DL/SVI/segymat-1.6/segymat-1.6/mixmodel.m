addpath('D:\软件\matlab\segymat-1.6')
sgyfileIn='D:\软件\matlab\segymat-1.6\7L3_150_122.sgy';

[SegyData,SegyTraceHeaders,SegyHeader]=ReadSegy(sgyfileIn);
Pore=SegyData;

sgyfileIn='7L3_150_122.sgy';
[SegyData,SegyTraceHeaders,SegyHeader]=ReadSegy(sgyfileIn);
Pore=SegyData;
[SegyData,~,~]=ReadSegy(sgyfileIn);
PoreType=SegyData;
sgyfileIn='toL.sgy';
[SegyData,~,~]=ReadSegy(sgyfileIn);
Tc=SegyData;



WriteSegyStructure(sgyfileOut,SegyHeader,SegyTraceHeaders,DataOut);