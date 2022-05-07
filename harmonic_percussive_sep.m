function harmonic_percussive_sep(signal_in, fs)
% harmonic_percussive_sep(signal_in, fs) performs harmonic-percussive
% separation using the method presented in the paper 'A Review
% of Time-Scale Modification of Music Signals' by Jonathan Dreidger

%%%%%% To run demo:
%%%%%% 1. load mixed_audio.wav unsing the import wizard
%%%%%% 2. call harmonic_percussive_sep(data,fs) from command line.

    %UNCOMMENT BELOW to play original signal
    %soundsc(signal_in, fs);
    %define parameters from paper
    K = 2048;
    N = K*2;
    overlap = K/2;
    %take short time fourier transform 
    X = stft(signal_in, "Window", sqrt(hann(K,"periodic")), "OverlapLength", overlap, "FFTLength", N, FrequencyRange="onesided");
    signal_size = size(X);
    %only look at half of the STFT
    X = X(1:signal_size/2, :);
    % median filter parameters
    time_filt = 0.4;
    freq_filt = 300;
    %do median filtering
    time_filt_samp = time_filt/((N - overlap)/fs); 
    freq_filt_samp = freq_filt/(fs/N); 
    Xmag = abs(X);
    Percussive = movmedian(Xmag, freq_filt_samp, 1);
    Harmonic = movmedian(Xmag, time_filt_samp, 2);
    %make the binary masks, tried several values of B but 4 worked well
    B = 4;
    Mp = (Percussive./(Harmonic)) >= B;
    Mh = (Harmonic./(Percussive)) > B;
    %apply the masks to the signal to find enhanced spectrograms
    Percussive = X.*Mp;
    Harmonic = X.*Mh;
    %get rest of the signal back
    Harmonic_flipped = flipud(conj(Harmonic));
    Percussive_flipped = flipud(conj(Percussive));
    Harmonic = cat(1, Harmonic, Harmonic_flipped);
    Percussive = cat(1, Percussive, Percussive_flipped);
    %take inverse stft to get separated audio
    harmonic = istft(Harmonic, "Window", sqrt(hann(K,"periodic")), "OverlapLength", overlap, "FFTLength", N, "ConjugateSymmetric", true);
    percussive = istft(Percussive, "Window", sqrt(hann(K,"periodic")), "OverlapLength", overlap, "FFTLength", N, "ConjugateSymmetric", true);
    % do TSM on the separated signals
    p_fast = TSM(percussive,0.5);
    %UNCOMMENT BELOW to play sped up percussive
    %soundsc(p_fast,fs);
    h_fast = TSM_PV(harmonic,0.5);
    %UNCOMMENT BELOW toplay sped up harmonic
    %soundsc(h_fast,fs);
    %make sure resulting signals are the same size
    if length(p_fast) < length(h_fast)
        diff = length(h_fast)-length(p_fast);
        p_fast = [p_fast,zeros(1,diff)];
    else
        diff = length(p_fast)-length(h_fast);
        h_fast = [h_fast,zeros(1,diff)];
    end 
    resynthesized_signal = h_fast + p_fast;
    %play final signal
    soundsc(resynthesized_signal,fs);
end
