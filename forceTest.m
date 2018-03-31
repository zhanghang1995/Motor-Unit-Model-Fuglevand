close all
clear all
clc

Fs = 1000;
time = 0:1/Fs:4;
t_stim = 0:1/Fs:2;
SR = 0.1:0.1:1.5;
N_MU = 120; %number of motor unit
i_MU = 1:N_MU; %motor unit identification index
RP_MU = 100; %range of twich force across motor untis in unit of fold
b_MU = log(RP_MU)/N_MU; %coefficient to establish a range of twich force values
P_MU = exp(b_MU*i_MU); %force generated by a motor unit as a function of its recruitment threshold
T_L_MU = 90; %the longest duration contraction time desired for the pool in unit of ms
RT_MU = 3; % range of contraction time in unit of fold
c_MU = log(100)/log(RT_MU); %coefficient to establish a range of contraction time values
T_MU = (T_L_MU.* (1./P_MU).^(1/c_MU))./1000; %contraction time
P_MU = exp(b_MU*i_MU); %force generated by a motor unit as a function of its recruitment threshold
PFR = 35;
MFR = 8;
%FR = [2 5 10 15 20 25 30 35 40 45 50];
FR = [5 10 20 30];

t_twitch = 0:1/Fs:3;
twitch = zeros(N_MU,length(t_twitch));

for j = 1:N_MU
    twitch(j,:) =  P_MU(j).*t_twitch./T_MU(j).*exp(1-t_twitch./T_MU(j));
end

testedUnit = 1;

for i = 1:length(FR)
    force = zeros(1,length(time));
    
    CT = T_MU(testedUnit);
    ISI = 1/FR(i);
    SR = CT/ISI;
    
    
    spikeTrain_temp = spikeTrainGenerator(t_stim,Fs,FR(i));
    spikeTrain = [zeros(1,Fs) spikeTrain_temp zeros(1,Fs)];
    
    for t = 1:length(time)
        temp = zeros(1,length(time));
        if spikeTrain(t) == 1
            temp(t) = 1;
            
            if ~any(force)
                g = 1;
            else
                if SR <= 0.4
                    g = 1;
                else
                    S = 1 - exp(-2*SR^3);
                    g = (S/SR)./0.3;
                end
            end
            force_temp = conv(temp,g*twitch(testedUnit,:));
            force = force + force_temp(1:length(time));
            
        end
        
        
    end
    
    
    amp(i) = mean(force(2*Fs:3*Fs));
    p2p_amp(i) = (max(force(2*Fs:3*Fs))-min(force(2*Fs:3*Fs)));
    
    figure(1)
    plot(time,force)
    hold on
    
end

p2p_amp = 1 - p2p_amp;
figure(2)
plot(FR,amp/amp(end)*100,'LineWidth',2)
xlabel('Frequency (Hz)','FontSize',14)
ylabel('Mean Force (%)','FontSize',14)
h1 = line([MFR MFR],[0 120]);
h2 = line([PFR PFR],[0 120]);
%patch([8 35 35 8],[0 0 10 10],'r')
%set(gca,'children',flipud(get(gca,'children')))

figure(3)
plot(FR,p2p_amp*100,'LineWidth',2)
xlabel('Frequency (Hz)','FontSize',14)
ylabel('Degree of Fusion (%)','FontSize',14)
h3 = line([MFR MFR],[-20 120]);
h4 = line([PFR PFR],[-20 120]);

