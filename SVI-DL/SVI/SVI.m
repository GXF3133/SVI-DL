function data_SVI = SVI(inputdata,S_coor,R_coor)
%SVI Supervirtual Interferometry.
%   data_SVI = SVI(inputdata, S_coor, R_coor) performs supervirtual
%   interferometry processing on the input seismic data with a low
%   signal-to-noise ratio to enhance the energy of the first arrival
%   signals and the signal-to-noise ratio.
%          'inputdata'    - The input seismic data with a low signal-to-noise
%                           ratio has a size of nt * nx * ns.
%          'S_coor'       - The coordinates of the source position.
%          'R_coor'       - The coordinates of the geophone position.
%% Virtual interferometry
tic
ns=size(inputdata,1);
[nt,nx] = size(inputdata{1});
outputArg1=zeros(nt,nx,ns);
outputArg2=zeros(nt,nx,ns);
VI1 = cell(nx, 1);
for Rb= 1:nx
    VI1{Rb, 1} = zeros(2*nt-1,nx);
end
VI2 = cell(nx, 1);
for Rb= 1:nx
    VI2{Rb, 1} = zeros(2*nt-1,nx);
end

for B=1:nx
    for A=1:nx
        if R_coor(A)<=R_coor(B)
            idx = find(S_coor <=  R_coor(A));
            less_than_A = S_coor(idx);
            if ~isempty(less_than_A)
                [~, closest_idx_in_less] = min(abs(less_than_A -  R_coor(A)));
                closest_idx_in_S = idx(closest_idx_in_less);
                for S=1:closest_idx_in_S
                    k1=inputdata{S,1}(1:nt,A);
                    k2=inputdata{S,1}(1:nt,B);
                    [result]=deconv(k2,k1,nt);
                    VI1{B,1}(:,A)=VI1{B,1}(:,A)+result;
                end
            else
                VI1{B,1}(:,A)=0;
            end
        elseif R_coor(A)>R_coor(B)
            
            idx = find(S_coor >=  R_coor(A));
            more_than_A = S_coor(idx);
            if ~isempty(more_than_A)
                [~, closest_idx_in_more] = min(abs(more_than_A -  R_coor(A)));
                closest_idx_in_S = idx(closest_idx_in_more);
                for S=closest_idx_in_S:ns
                    k1=inputdata{S,1}(1:nt,A);
                    k2=inputdata{S,1}(1:nt,B);
                    [result]=deconv(k2,k1,nt);
                    VI1{B,1}(:,A)=VI1{B,1}(:,A)+result;
                end
            else
                VI1{B,1}(:,A)=0;
            end
        end
    end
end
for B=1:nx
    for A=1:nx
        if R_coor(A)<=R_coor(B)
            idx = find(S_coor <=  R_coor(A));
            less_than_A = S_coor(idx);
            if ~isempty(less_than_A)
                [~, closest_idx_in_less] = min(abs(less_than_A -  R_coor(A)));
                closest_idx_in_S = idx(closest_idx_in_less);
                for S=1:closest_idx_in_S
                    k1=inputdata{S,1}(1:nt,A);
                    k2=inputdata{S,1}(1:nt,B);
                    [result]=deconv(k1,k2,nt);
                    VI2{B,1}(:,A)=VI2{B,1}(:,A)+result;
                end
            else
                VI2{B,1}(:,A)=0;
            end
        elseif R_coor(A)>R_coor(B)
            
            idx = find(S_coor >=  R_coor(A));
            more_than_A = S_coor(idx);
            if ~isempty(more_than_A)
                [~, closest_idx_in_more] = min(abs(more_than_A -  R_coor(A)));
                closest_idx_in_S = idx(closest_idx_in_more);
                for S=closest_idx_in_S:ns
                    k1=inputdata{S,1}(1:nt,A);
                    k2=inputdata{S,1}(1:nt,B);
                    [result]=deconv(k1,k2,nt);
                    VI2{B,1}(:,A)=VI2{B,1}(:,A)+result;
                end
            else
                VI2{B,1}(:,A)=0;
            end
        end
    end
end
toc
%% Convolution interferometry
tic
SVI1 = cell(ns, 1);
for S=1:ns
    SVI1{S,1}=zeros(2*nt-1,nx);
end
SVI2 = cell(ns, 1);
for S=1:ns
    SVI2{S,1}=zeros(2*nt-1,nx);
end
%%
for S=1:ns
    for B=1:nx
        if R_coor(B)>=S_coor(S)
            idx = find( R_coor>= S_coor(S) );
            more_than_S = R_coor(idx);
            if ~isempty(more_than_S)
                [~, closest_idx_in_more] = min(abs(more_than_S -  S_coor(S)));
                closest_idx_in_A = idx(closest_idx_in_more);
                for A=closest_idx_in_A:B
                    k3=inputdata{S,1}(1:nt,A);
                    res=convn(k3,(VI1{B,1}(nt:2*nt-1,A)));
                    SVI1{S,1}(:,B)=SVI1{S,1}(:,B)+res;
                end
            else
                SVI1{S,1}(:,B)=0;
            end
        elseif R_coor(B)<S_coor(S)
            idx = find( R_coor<= S_coor(S) );
            less_than_S = R_coor(idx);
            if ~isempty(less_than_S)
                [~, closest_idx_in_less] = min(abs(less_than_S -  S_coor(S)));
                closest_idx_in_A = idx(closest_idx_in_less);
                for A=B:closest_idx_in_A
                    k3=inputdata{S,1}(1:nt,A);
                    res=convn(k3,(VI1{B,1}(nt:2*nt-1,A)));
                    SVI1{S,1}(:,B)=SVI1{S,1}(:,B)+res;
                end
            else
                SVI1{S,1}(:,B)=0;
            end
        end
    end
    outputArg1(1:nt,:,S)=SVI1{S,1}(1:nt,:);
end
for S=1:ns
    for B=1:nx
        if R_coor(B)>=S_coor(S)
            for A=B:nx
                k3=inputdata{S,1}(1:nt,A);
                res=convn(k3,(VI2{B,1}(1:nt,A)));
                SVI2{S,1}(:,B)=SVI2{S,1}(:,B)+res;
            end
        elseif R_coor(B)<S_coor(S)
            for A=1:B
                k3=inputdata{S,1}(1:nt,A);
                res=convn(k3,(VI2{B,1}(1:nt,A)));
                SVI2{S,1}(:,B)=SVI2{S,1}(:,B)+res;
            end
        end
    end
    outputArg2(1:nt,:,S)=SVI2{S,1}(nt:2*nt-1,:);
end
data_SVI=outputArg1+outputArg2;
toc
end

