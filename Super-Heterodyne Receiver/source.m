%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Super-heterodyne Receiver %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Name: Hussam Ali Ahmed  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       Section: 2          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      Bench Number: 3      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear,clc;
load('filters_workspace'); %Load the filters workspsace%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Read Both signals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,fs] = audioread('Short_BBCArabic2.wav');
monoch1 = x(:,1)+x(:,2); %converting from stereo channel to monophonic%
monoch1 = monoch1(1:length(monoch1)/2); % Taking half of the samples
monoch1 = interp(monoch1,10);
[y,fs] = audioread('Short_FM9090.wav');
monoch2 = y(:,1)+y(:,2); %converting from stereo channel to monophonic%
monoch2 = monoch2(1:length(monoch2)/2);
monoch2 = interp(monoch2,10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Padding the short signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length_error = abs( length(monoch1) - length(monoch2) );
error_solver = zeros(length_error, 1);
if(length(monoch1) < length(monoch2))
    monoch1 = [monoch1;error_solver];
else
    monoch2 = [monoch2;error_solver];
end


N = length(monoch1);
f_ax = (-N/2:N/2-1).*((fs*10)/N); %Define the frequency axis
n = 1:length(monoch1);
%Two signals spectrum
ft_1 = fftshift(fft(monoch1));
ft_2 = fftshift(fft(monoch2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AM STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%100KHz carrier
fc1 = 100000;
carrier_100 = cos(2*pi*fc1 * n/(fs*10));
carrier_100 = carrier_100';
modulated_AM_100 = monoch1 .* carrier_100;
modulated_AM_100_ft = fftshift(fft(modulated_AM_100));
%150KHz carrier
fc2 = 150000;
carrier_150 = cos(2*pi*fc2 * n/(fs*10));
carrier_150 = carrier_150';
modulated_AM_150 = monoch2 .* carrier_150;
modulated_AM_ft = fftshift(fft(modulated_AM_150));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FDM STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdm = modulated_AM_100 + modulated_AM_150;
fdm_ft = fftshift(fft(fdm));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RF STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filter 100khz signal
RF_100 = filter(bpf_100, fdm);
RF_100_ft = fftshift(fft(RF_100));
%Filter 150khz signal
RF_150 = filter(bpf_150, fdm);
RF_150_ft = fftshift(fft(RF_150));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MIXER STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_IF = 25000;
%Mixer for 100khz signal
carrier_if_100 = cos(2*pi*(fc1+F_IF)*n/(fs*10));
carrier_if_100 = carrier_if_100';
modulated_if_100 = RF_100 .* carrier_if_100;
modulated_if_100_ft = fftshift(fft(modulated_if_100));
%Mixer for 150khz signal
carrier_if_150 = cos(2*pi*(fc2+F_IF)*n/(fs*10));
carrier_if_150 = carrier_if_150';
modulated_if_150 = RF_150 .* carrier_if_150;
modulated_if_150_ft = fftshift(fft(modulated_if_150));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IF STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filter 100khz + Fif
IF_100 = filter(bpf_if, modulated_if_100);
IF_100_ft = fftshift(fft(IF_100));
%filter 150khz + Fif
IF_150 = filter(bpf_if, modulated_if_150);
IF_150_ft = fftshift(fft(IF_150));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASEBAND DETECTION STAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%F_IF carrier
carrier_if = cos(2*pi*F_IF*n/(fs*10));
carrier_if = carrier_if';
%get 100 khz signal
after_IF_100 = IF_100 .* carrier_if;
after_IF_100_ft = fftshift(fft(after_IF_100));
%get 150 khz signal
after_IF_150 = IF_150 .* carrier_if;
after_IF_150_ft = fftshift(fft(after_IF_150));
%lowpass 100 khz signal
Baseband_100 = filter(lpf, after_IF_100);
Baseband_100_ft = fftshift(fft(Baseband_100));
%lowpass 150 khz signal
Baseband_150 = filter(lpf, after_IF_150);
Baseband_150_ft = fftshift(fft(Baseband_150));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
plot(f_ax, abs(RF_100_ft));
title('The First Signal after RF Stage');
xlabel('Frequency(Hz)');

figure(2);
plot(f_ax, abs(IF_100_ft));
title('The First Signal after IF Stage');
xlabel('Frequency(Hz)');

figure(3);
plot(f_ax, abs(Baseband_100_ft));
title('The First Signal after Baseband Detection Stage');
xlabel('Frequency(Hz)');

figure(4);
plot(f_ax, abs(RF_150_ft));
title('The Second Signal after RF Stage');
xlabel('Frequency(Hz)');

figure(5);
plot(f_ax, abs(IF_150_ft));
title('The Second Signal after IF Stage');
xlabel('Frequency(Hz)');

figure(6);
plot(f_ax, abs(Baseband_150_ft));
title('The Second Signal after Baseband Detection Stage');
xlabel('Frequency(Hz)');

figure(7);
plot(f_ax, abs(fdm_ft));
title('Frequency Division Multeplexing of The Two Signals');
xlabel('Frequency(Hz)');

figure(8);
plot(f_ax, abs(modulated_if_100_ft));
title('The First Signal after Mixer Stage');
xlabel('Frequency(Hz)');

figure(9);
plot(f_ax, abs(after_IF_100_ft));
title('The First Signal after Coherent Detection Stage');
xlabel('Frequency(Hz)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DOWNSAMPLING AND PLAYING THE AUDIO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Baseband_100 = downsample(Baseband_100,10);
Baseband_150 = downsample(Baseband_150,10);
sound(Baseband_150, fs);

