%100KHz Bandpass filter RF STAGE
A_stop1 = 100;		% Attenuation in the first stopband = 100 dB
F_stop1 = 76950;	% Edge of the stopband = 76950 Hz
F_pass1 = 77950;	% Edge of the passband = 77950 Hz
F_pass2 = 122050;	% Closing edge of the passband = 122050 Hz
F_stop2 = 123050;	% Edge of the second stopband = 123050 Hz
A_stop2 = 100;		% Attenuation in the second stopband = 100 dB
A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
bpf_100_specs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 441000);
bpf_100 = design(bpf_100_specs, 'equiripple');

%150KHz Bandpass filter RF STAGE
A_stop1 = 100;		% Attenuation in the first stopband = 100 dB
F_stop1 = 120000;	% Edge of the stopband = 120000 Hz
F_pass1 = 130850;	% Edge of the passband = 130850 Hz
F_pass2 = 169200;	% Closing edge of the passband = 169200 Hz
F_stop2 = 175000;	% Edge of the second stopband = 175000 Hz
A_stop2 = 100;		% Attenuation in the second stopband = 100 dB
A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
bpf_150_specs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 441000);
bpf_150 = design(bpf_150_specs, 'equiripple');

%F_IF Bandpass filter IF STAGE
A_stop1 = 100;		% Attenuation in the first stopband = 100 dB
F_stop1 = 8000;		% Edge of the stopband = 8000 Hz
F_pass1 = 9000; 	% Edge of the passband = 9000 Hz
F_pass2 = 38000;	% Closing edge of the passband = 38000 Hz
F_stop2 = 39000;	% Edge of the second stopband = 39000 Hz
A_stop2 = 100;		% Attenuation in the second stopband = 100 dB
A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
bpf_if_specs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 290000);
bpf_if = design(bpf_if_specs, 'equiripple');

%Lowpass Filter 
Fs = 441000;
Fpass = 19200;
Fstop = 20000;
Apass = 1;
Astop = 100;
lpf_specs = fdesign.lowpass('Fp,Fst,Ap,Ast',Fpass,Fstop,Apass,Astop,Fs);
lpf = design(lpf_specs,'equiripple');

