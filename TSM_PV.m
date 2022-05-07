function y_final = TSM_PV(signal_in, alpha)
% TSM_PV(signal_in, alpha) stretches a signal 'signal in' by a factor of
% alpha. This method is based on the PV-TSM method presented in 'A Review
% of Time-Scale Modification of Music Signals' by Jonathan Dreidger

%Fs for the drum file is 44100


% 
% f=50
% Amp=1
% ts=1/8000;
% T=1;
% t=0:ts:T;
% ysin=sin(2*pi*f*t);
% ysin = ysin.';


N = 2000;
Hs = N/2;
Ha= Hs/alpha;

[row,col] = size(signal_in);
omega = 2*pi*Ha*[0:N - 1]'/N;
phase_init= zeros(N,1);
phase_mod = zeros(N,1);

shift_matrix = zeros(N,row);

for m = 0:((row-N)/Ha)-1
    %separate into analysis frames
    xm = signal_in((m*Ha)+1:N+(m*Ha),:);
    X = fft(xm);
    Xmag = abs(X);
    Xphase = angle(X);
    %calculate instantaneous frequency estimate
    FIF = omega + ((Xphase-phase_init-omega)-(2*pi*round(Xphase-phase_init-omega/(2*pi))));
    phase_init = Xphase;
    phase_mod = phase_mod+FIF*alpha;
    %calculate modified FFT
    Xmod = (Xmag.*exp(2*pi*i*phase_mod));
    xMod = real(ifft(Xmod));
    %window
    w = hann(N);
    xMod = xMod.*w;
    %shift frame based on Hs
    shift_matrix(m+1,m*Hs+1:(m*Hs)+N) = xMod;
end 

y_final = sum(shift_matrix,1);
