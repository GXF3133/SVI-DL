function [data_deconvolution] = deconv(trace1,trace2,nt)
%deconv Deconvolution.
%   data_deconvolution = deconv(trace1,trace2,nt)  is the calculation equation
%   for deconvolution, corresponding to Equation 4 in the article.
%          'trace1'       - The time-domain record of Trace 1.
%          'trace2'       - The time-domain record of Trace 2.
%          'nt'           - Time sampling points.
trace1_fft=fft(trace1,nt*2-1);
trace2_fft=fft(trace2,nt*2-1);
a=max((abs(trace1_fft).^2))*0.01;
if all(trace1_fft~=0)
    decon=(trace1_fft.*conj(trace2_fft))./((abs(trace1_fft)).^2+a);
    decon1=real(ifft(decon));
end
decon = [decon1(nt*2 - nt-1 + (1:nt-1)); decon1(1:nt-1+1)];
data_deconvolution = decon;
end

