%%
%% This function uses the residuals after the second order polynomial step
%% and calculate the containing frequencies and creates a plot
%%
function [spike_array,spike_array_counter]= fast_fourier_analysis( use_mask,residuals,tr,dim4,remove_time_series,phantom_name,fft_probability_limit )
    
        residuals_fft = fft(residuals);

        % 1 / 1 sekunde = 1 Hz 
        % 1 / Intervall zwischen Anregung und Messung des Signals
        % Frequenz der Zeitserie
        frequenz_sekunde = 1/tr;

        % (#Frequenzanteile/2) +1
        % Ab der Hälfte ist das Spektrum gespiegelt daher nur die Hälfte aller
        % Zeitpunkte.
        anzahl_frequnezen = ((dim4-remove_time_series)/2)+1;
        anzahl_frequnezen2 = (dim4-remove_time_series);
        

        % Frequenzen werden berechnet
        % Frequenzverschiebung 
        % 1/2 * Wert von 1 ... anzahl frequenzen
        % den Wert dann mit der Frequenz pro Sekunde multiplizieren
        % und dan durch die Anzahl der Frequenzen teilen.
        % Bereich 0-1 auf der X achse
        %frequency = (1:anzahl_frequnezen)/anzahl_frequnezen;
        % Bereich 0-1 auf X Achse (Frequenz von 1) mit der tatsächlichen
        % Frequenz multiplizieren
        %frequency = (1:anzahl_frequnezen)*frequenz_sekunde/anzahl_frequnezen;
        % Da nur die Hälfte aller Zeitpunkte betrachtet werden müssen wir noch
        % den Faktor 0,5 hinzufügen.
        frequency = 0.5*(1:anzahl_frequnezen)*frequenz_sekunde/anzahl_frequnezen;
        frequency2 = (1:anzahl_frequnezen2)*frequenz_sekunde/anzahl_frequnezen2;

        frequency_value = abs(residuals_fft(1:anzahl_frequnezen));
        frequency_value2 = abs(residuals_fft(1:anzahl_frequnezen2));
        frequency_mean = mean(frequency_value);
        frequency_std = std(frequency_value);

        frequency_3std = (frequency_mean)+(frequency_std*3);
        frequency_35std = (frequency_mean)+(frequency_std*3.5);
        frequency_4std = (frequency_mean)+(frequency_std*4);
        frequency_45std = (frequency_mean)+(frequency_std*4.5);
        frequency_5std = (frequency_mean)+(frequency_std*5);

        f = figure();
        set(f, 'Position', [300,150 , 640, 600])
        set(gcf,'PaperUnits','centimeters','PaperPosition',[3 3 10.4 10])
        name = strcat('Fast_Fourier_Transformation_', phantom_name);
        set(f,'Name',name);
        plot(frequency,frequency_value,'-k',[0,frequency(end)],[frequency_mean,frequency_mean],'-b', [0,frequency(end)],[frequency_3std,frequency_3std],'-b',[0,frequency(end)],[frequency_35std,frequency_35std],'-b',[0,frequency(end)],[frequency_4std,frequency_4std],'-b',[0,frequency(end)],[frequency_45std,frequency_45std],'-b',[0,frequency(end)],[frequency_5std,frequency_5std],'-b')
        ylim([0 100])
        ylabel('magnitude');
        xlabel('fequency (Hz)');
        print(f,name,'-dpng'); 
        
	pause(5);

         f = figure();
        set(f, 'Position', [300,150 , 640, 600])
        set(gcf,'PaperUnits','centimeters','PaperPosition',[3 3 10.4 10])
        name = strcat('Fast_Fourier_Transformation2_', phantom_name);
        set(f,'Name',name);
        plot(frequency2,frequency_value2,'-k')
        ylim([0 100])
        ylabel('magnitude');
        xlabel('fequency (Hz)');
        print(f,name,'-dpng'); 
        
        
        % Spike Array
        % 1. Propability
        % 2. Frequence
        % 3. Magnitude
        spike_array_counter = 1;
        spike_array = zeros(1,3);
        
       
        for i = 2:length(frequency_value)-1
           signal_noise =  frequency_value(i)/((frequency_value(i-1)+frequency_value(i+1))/2);
           p_help = 2+(signal_noise^2);
           probability = (2+4*(1/p_help))/(4+signal_noise^2)-(sqrt(2)*signal_noise^2*atan(sqrt(2/p_help)))/p_help^(3/2);
           
           if probability < fft_probability_limit
              spike_array(spike_array_counter,1)= probability;
              spike_array(spike_array_counter,2)= frequency(i);
              spike_array(spike_array_counter,3)= frequency_value(i);
              
              spike_array_counter = spike_array_counter +1;
           end
           
        end
        
        name = strcat('spikes_',phantom_name);
        fullname = strcat(name,'.txt');
        fid = fopen(fullname, 'w');
        for i = 1:spike_array_counter-1
            fprintf(fid, '%.4f\t%.4f\t%.4f\n',spike_array(i,1),spike_array(i,2),spike_array(i,3));
        end
   
        fclose(fid);


end

