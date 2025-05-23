%% Z-profile analysis
% 
%Example code to plot z-profiles of 3 x 3 Brillouin scans through the
%monolayers. The code then looks for a peak - if it is detected, a Gaussian
%fit over the peak is applied and the corresponding amplitude is returned.
%If there is no peak, the code looks for the onset of a downward slope in
%the z-profile, corresponding to gel-cells transition. 
% Example data from Experiment 3, 19-03-2025, code developed and annotated
% with assistance from AI tool (ChatGPT v4).
clear all, close all

%% Load data for control samples

%Folder containing the data from individual z-scan ROIs in subfolders. 
%Each subfolder e.g., 'zscan3' has time-stamped folders (corresponding to z-steps) 
%with a file called 'ShiftMap.csv'. There, a 3 x 3 matrix of Brillouin shift values 
%(fitted in LightMachinery's LabView SciScan software) from a given depth is stored.
%The code forms a 3x3x41 matrix to represent each of the z-scan ROIs, which
%is stored in control_zscan struct.

current_dir = pwd;
path_control = fullfile(current_dir, 'Control', 'zscans');
control_zscan = create_struct_from_shift_maps(path_control);
disp(control_zscan);

plot_shift_maps(control_zscan, path_control, 'Control z-scans E3');
%% Load data for aged samples

%Folder containing the data from individual z-scan ROIs:
current_dir = pwd;
path_aged = fullfile(current_dir, 'Aged', 'zscans');
aged_zscan = create_struct_from_shift_maps(path_aged);
disp(aged_zscan);

plot_shift_maps(aged_zscan, path_aged, 'Aged z-scans E3');

%% Plot representative z-scans:
data_aged = control_zscan.z_scan1;  % Selected control example from Experiment 3
data_control = aged_zscan.z_scan1b2;  % Selected aged example from Experiment 3

curves_aged = reshape(data_aged, 9, []);  % reshape to 9 x 41
curves_control = reshape(data_control, 9, []);  % reshape to 9 x 41

% Compute average profile for the the 9 curves for aged and control
avg_curve_aged = mean(curves_aged, 1); 
avg_curve_control = mean(curves_control, 1); 

z = 0:2:80;
z2 = 0:2:78;

figure; 

% AGED:
subplot(1, 2, 1); hold on
ylim([6.25,6.5])
light_blue = [0.9, 0.9, 1];  
dark_blue = [0.3, 0.3, 1];    

blue_vals = zeros(9, 3);  
for i = 1:9
    blue_vals(i, :) = (1 - (i - 1) / 8) * light_blue + ((i - 1) / 8) * dark_blue;
end

for i = 1:9
    h1 = plot(z, curves_aged(i, :), 'Color', blue_vals(i, :), 'LineWidth', 1.5);
    if i == 1
        h1.Annotation.LegendInformation.IconDisplayStyle = 'on';  
    else
        h1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
    end
end
h2 = plot(z, avg_curve_aged, 'Color', [0 0 1], 'LineWidth', 4);
xlabel('Z-position (\mu{m})', 'FontSize', 14)
ylabel('Brillouin Shift (GHz)', 'FontSize', 14)
legend([h1, h2], {'Line profiles', 'Average'}, 'FontSize', 12, 'Location', 'best')

% Mark approximate range of basal region:
x_start = 31; 
x_end   = 41; 
y_limits = ylim;     

fill([x_start x_end x_end x_start], ...
     [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
     [0.7 0.7 1], ...         
     'FaceAlpha', 0.3, ...   
     'EdgeColor', 'none', 'HandleVisibility', 'off');  

% Mark approximate range of apical region:
x_start = 45; 
x_end   = 55;  
y_limits = ylim;      

fill([x_start x_end x_end x_start], ...
     [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
     [1 0.7 0.7], ...         
     'FaceAlpha', 0.3, ...    
     'EdgeColor', 'none', 'HandleVisibility', 'off');   

grid on
set(gca, 'FontSize', 14)

% CONTROL:
subplot(1, 2, 2); hold on
light_red = [1, 0.9, 0.9];  
dark_red = [1, 0.3, 0.3];   

red_vals = zeros(9, 3);  
for i = 1:9
    red_vals(i, :) = (1 - (i - 1) / 8) * light_red + ((i - 1) / 8) * dark_red;
end

for i = 1:9
    h1 = plot(z2, curves_control(i, :), 'Color', red_vals(i, :), 'LineWidth', 1.5);
    if i == 1
        h1.Annotation.LegendInformation.IconDisplayStyle = 'on';  
    else
        h1.Annotation.LegendInformation.IconDisplayStyle = 'off'; 
    end
end
h2 = plot(z2, avg_curve_control, 'Color', [1 0 0], 'LineWidth', 4);  
xlabel('Z-position (\mu{m})', 'FontSize', 14)
ylabel('Brillouin Shift (GHz)', 'FontSize', 14)
legend([h1, h2], {'Line profiles', 'Average'}, 'FontSize', 12, 'Location', 'best')

ylim([6.25,6.5])
grid on
set(gca, 'FontSize', 14)

% Mark approximate basal range:
x_start = 21; 
x_end   = 31; 
y_limits = ylim;     

fill([x_start x_end x_end x_start], ...
     [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
     [0.7 0.7 1], ...         
     'FaceAlpha', 0.3, ...    
     'EdgeColor', 'none', 'HandleVisibility', 'off');  

% Mark approximate apical range:
x_start = 33; 
x_end   = 43;  
y_limits = ylim;      

fill([x_start x_end x_end x_start], ...
     [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
     [1 0.7 0.7], ...         
     'FaceAlpha', 0.3, ...    
     'EdgeColor', 'none', 'HandleVisibility', 'off');   


% Figure size and positioning:
set(gcf, 'Position', [100, 100, 1000, 500])  

%% Testing fitting for invididual profiles for validation / data exclusion:
z_scan_to_test = control_zscan.z_scan1 % choose ROI (3 x 3 x 41 matrix with a z-scan)
i = 1; % row index (select one of the 9 z-profiles from z_scan_to_test)
j = 1; % column index (select one of the 9 z-profiles from z_scan_to_test)

order = 3; % Savitzky-Golay filter parameters
framelen = 7; % Savitzky-Golay filter parameters
min_width = 5; % Minimum peak width when looking for initial peak in the data
k = 10; % Adjusts range over which the Gaussian peak is fitted

[fit_peak_pos, fit_peak_val] = analyze_peak_and_derivative2(z_scan_to_test, i, j, order, framelen, min_width, k, true);

%% Batch peak fitting of all aged and control data:
order = 3; % Savitzky-Golay filter parameters
framelen = 7; % Savitzky-Golay filter parameters
min_width = 5; % Minimum peak width when looking for initial peak in the data
k = 10; % Adjusts range over which the Gaussian peak is fitted

%The structs below contain fitted peak values and peak positions, as well
%as 'non-peak', plateau values:
control_zscan_fit = batch_fit_zscans2(control_zscan, order, framelen, min_width, k);
aged_zscan_fit = batch_fit_zscans2(aged_zscan, order, framelen, min_width, k);


% Note that outlier values should be individually checked, as in the rare
% cases the fitting is inaccurate. Code below plots peak position vs fitted 
% peak amplitude (blue), or position and value of the 'plateau' (red), where
% no peak was identified. This may be helpful to identify the few outliers.
plot_peak_positions_vs_values2(control_zscan_fit);
plot_peak_positions_vs_values2(aged_zscan_fit);

% Files with fitting data are saved in the folder that is currently open.
%% FUNCTIONS
function [fit_peak_pos, fit_peak_val, nan_pos, nan_val] = analyze_peak_and_derivative2(data, i, j, order, framelen, min_width, k, do_plot)
% For a single z-scan, the function fits Gaussians on original and filtered data between the min/max of the
% derivative of the filtered profile. If no peaks are identified, a plateau
% value is found by looking for the onset of the gel-medium slope in the
% z-profile.
% 
% Parameters:
%   - data: 3D matrix
%   - i, j: position in data
%   - order, framelen: Savitzky-Golay filter params
%   - min_width: minimum peak width for findpeaks
%   - k: window half-width around detected peak
%   - do_plot: set to true to visualize result
%
% Returns:
%   - fit_peak_pos: peak position from Gaussian fit on filtered signal
%   - fit_peak_val: peak amplitude from Gaussian fit on filtered signal
%   - nan_pos: position of detected change point (if applicable)
%   - nan_val: value of detected change point (if applicable)

    % Initialize outputs
    fit_peak_pos = NaN;
    fit_peak_val = NaN;
    nan_pos = NaN;
    nan_val = NaN;

    % Extract signal and define x-axis
    signal = squeeze(data(i,j,:));
    n = numel(signal);
    x = 0:2:(2*(n-1));  % Proper x-axis with step size 2

    % Apply Savitzky-Golay filtering
    filt_signal = sgolayfilt(signal, order, framelen);

    % Compute derivative using correct x spacing
    df = gradient(filt_signal, x);

    % Find peaks in the filtered signal
    [A, locs, w, ~] = findpeaks(filt_signal, 'MinPeakWidth', min_width, 'MinPeakProminence',0.03);

    % Initialize peak indices
    peak_idx = NaN;
    max_df_idx = NaN;
    min_df_idx = NaN;

    if ~isempty(locs)
        peak_idx = locs(1);  % Take first peak

        % Define safe search range around peak
        search_start = max(1, peak_idx - k);
        search_end   = min(n, peak_idx + k);
        search_range = search_start : search_end;

        % Find max and min derivative within range
        [~, local_max_idx] = max(df(search_range));
        [~, local_min_idx] = min(df(search_range));

        max_df_idx = search_range(local_max_idx);
        min_df_idx = search_range(local_min_idx);

        % Fit between dF min and max, clipped to bounds
        fit_start = max(1, min(max_df_idx, min_df_idx));
        fit_end   = min(n, max(max_df_idx, min_df_idx));

        % Prepare data for fitting
        xfit = x(fit_start:fit_end).';
        y_filtered = filt_signal(fit_start:fit_end);
        y_original = signal(fit_start:fit_end);

        % Fit Gaussians
        g_fit_filt = fit(xfit, y_filtered, 'gauss1');
        g_fit_orig = fit(xfit, y_original, 'gauss1');

        % Extract fitted values
        fit_peak_val = g_fit_filt.a1
        fit_peak_pos = g_fit_filt.b1

        % --- Optional Plot ---
        if do_plot
            figure('Position', [100, 100, 1400, 500]);

            % Subplot 1: Signals + fits
            subplot(1,2,1); hold on;
            plot(x, signal, 'k', 'LineWidth', 1, 'DisplayName', 'Original');
            plot(x, filt_signal, 'r', 'LineWidth', 1, 'DisplayName', 'Filtered');
            xline(x(max_df_idx), 'k--', 'HandleVisibility','off');
            xline(x(min_df_idx), 'k--', 'HandleVisibility','off');
            plot(x(peak_idx), filt_signal(peak_idx), 'b^', 'MarkerSize', 10, ...
                'MarkerFaceColor', 'b', 'DisplayName', 'FindPeaks');
            x_range = x(fit_start:fit_end);
            plot(x_range, g_fit_filt(x_range), 'g', 'LineWidth', 2, ...
                'DisplayName', sprintf('Fit Filtered: %.3f @ %.3f', g_fit_filt.a1, g_fit_filt.b1));
            plot(x_range, g_fit_orig(x_range), 'm', 'LineWidth', 2, ...
                'DisplayName', sprintf('Fit Original: %.3f @ %.3f', g_fit_orig.a1, g_fit_orig.b1));
            plot(g_fit_filt.b1, g_fit_filt(g_fit_filt.b1), 'g.', 'MarkerSize', 25);
            plot(g_fit_orig.b1, g_fit_orig(g_fit_orig.b1), 'm.', 'MarkerSize', 25);
            legend('show', 'Location', 'northeast');
            title(sprintf('Signal & Gaussian Fits at (%d,%d)', i, j));
            xlabel('z (um)'); ylabel('Brillouin Shift (GHz)');
            ylim([6.24, 6.45]); xlim([x(1), x(end)]);
            set(gca, 'FontSize', 13); grid on;

            % Subplot 2: Derivative
            subplot(1,2,2); hold on;
            plot(x, df, 'k-', 'LineWidth', 1.5);
            xline(x(max_df_idx), 'k--', 'DisplayName', 'Min, Max dF');
            xline(x(min_df_idx), 'k--', 'HandleVisibility','off');
            xline(x(peak_idx), 'b--', 'DisplayName', 'FindPeaks');
            legend('show', 'Location', 'northeast');
            title('Derivative of Filtered Signal');
            xlabel('z (um)'); ylabel('dF/dx');
            set(gca, 'FontSize', 13); grid on;
            xlim([x(1), x(end)]);
        end

    else
        % Overfilter the signal by setting framelen = 17
        overfilt_signal = sgolayfilt(signal, order, 17);

        % Compute the derivative of the overfiltered signal
        overfilt_df = gradient(overfilt_signal, x);

        % Restrict the range for change point detection to [20, 60]
        idx_range = (x >= 20 & x <= 60);
        overfilt_df_range = overfilt_df(idx_range);
        x_range = x(idx_range);

        % Initialize flag for detection
        trend_found = false;
        idx = NaN;

        % Try to find the change point using the derivative within the restricted range
        window_size = 5;
        threshold_slope = -0.0002;  % More relaxed slope threshold
        
        % Loop through derivative values
        for onset_idx_rel = 1:(length(overfilt_df_range) - window_size + 1)
            window = overfilt_df_range(onset_idx_rel : onset_idx_rel + window_size - 1);
            p = polyfit(1:window_size, window, 1);  % Fit a line

            if p(1) < threshold_slope
                idx = onset_idx_rel + find(idx_range, 1, 'first') - 1;
                nan_pos = x(idx);
                nan_val = overfilt_signal(idx);
                trend_found = true;
                break;
            end
        end

        if ~trend_found
            disp('No consistent downward trend detected.');
        end

        % Plotting:
        if do_plot
            figure('Position', [100, 100, 1400, 500]);

            % Subplot 1: Signals and Derivative of Overfiltered Signal
            subplot(1,2,1); hold on;
            plot(x, signal, 'k-', 'LineWidth', 1, 'DisplayName', 'Original Signal');
            plot(x, overfilt_signal, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Overfiltered Signal');
            if trend_found
                plot(x(idx), overfilt_signal(idx), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', 'Change Point');
            end
            legend('show', 'Location', 'best');
            title('Overfiltered Signal with (Optional) Change Point');
            xlabel('z (um)'); ylabel('Brillouin Shift (GHz)');
            ylim([6.24, 6.45]); xlim([x(1), x(end)]);
            set(gca, 'FontSize', 13); grid on;

            % Subplot 2: Derivative of Overfiltered Signal
            subplot(1,2,2); hold on;
            plot(x, overfilt_df, 'k-', 'LineWidth', 1.5, 'DisplayName', 'dF/dx');
            if trend_found
                xline(x(idx), 'g--', 'DisplayName', 'Change Point');
            end
            legend('show', 'Location', 'best');
            title('Derivative of Overfiltered Signal');
            xlabel('z (um)'); ylabel('dF/dx');
            set(gca, 'FontSize', 13); grid on;
            xlim([x(1), x(end)]);
        end
    end
end



function fit_struct = batch_fit_zscans2(zscan_struct, order, framelen, min_width, k)
    %Facilitates peak identification and fitting for all 3x3x41 z-scans in the
    %control / aged struct containing the data. 

    fields = fieldnames(zscan_struct);
    fit_struct = struct();

    for f = 1:numel(fields)
        fname = fields{f};
        data = zscan_struct.(fname);
        [nrows, ncols, ~] = size(data);

        peak_vals = NaN(nrows, ncols);
        peak_pos  = NaN(nrows, ncols);
        nan_vals = NaN(nrows, ncols);  % Store NaN values from overfiltered signals
        nan_idx  = NaN(nrows, ncols);  % Store indices where NaN occurs

        for i = 1:nrows
            for j = 1:ncols
                [pos, val, nan_pos, nan_val] = analyze_peak_and_derivative2(data, i, j, order, framelen, min_width, k, false);
                
                % If peak value is within range [6, 7], assign it
                if ~isnan(val) && val >= 6 && val <= 7
                    peak_vals(i,j) = val;
                    peak_pos(i,j)  = pos;
                else
                    % Only set NaN if no valid peak was found
                    peak_vals(i,j) = NaN;
                    peak_pos(i,j)  = NaN;
                end

                % Handle NaN values for change points (no valid peak found)
                if isnan(nan_val)
                    nan_vals(i,j) = NaN;
                    nan_idx(i,j)  = NaN;
                else
                    nan_vals(i,j) = nan_val;
                    nan_idx(i,j)  = nan_pos;
                end
            end
        end

        % Store in output struct with "_fit" suffix
        fit_field = [fname '_fit'];
        fit_struct.(fit_field).peak_val = peak_vals(:);  % 9x1 vector
        fit_struct.(fit_field).peak_pos = peak_pos(:);
        
        % Add NaN-related information to the output struct
        fit_struct.(fit_field).nan_vals = nan_vals(:);  % 9x1 vector for NaN values
        fit_struct.(fit_field).nan_idx = nan_idx(:);    % 9x1 vector for NaN indices
    end
end

function plot_peak_positions_vs_values2(data_fit)
    %Plots the fitted peak positions vs amplitudes (blue) as well as the
    %onset-slope values and positions (red) where no peak was identified.
    %The 0 position value is the mean position of all peaks in z-scan.
    %The function also saves the data for fitted peak and plateau values in
    %a .csv file.

    % Get the fields dynamically from the struct
    fields = fieldnames(data_fit);
    
    % Initialize cell arrays to store the data for each category
    adjusted_peak_pos_cell = {};
    peak_val_cell = {};
    adjusted_nan_pos_cell = {};
    nan_val_cell = {};
    
    % Initialize arrays to hold all peak positions and values for consistent axes limits
    all_peak_pos = [];
    all_peak_val = [];

    % Loop over each field to collect all peak positions and values
    for i = 1:numel(fields)
        field = fields{i};
        
        % Extract peak positions, values, nan_vals, and nan_idx
        peak_pos = data_fit.(field).peak_pos;
        peak_val = data_fit.(field).peak_val;
        nan_vals = data_fit.(field).nan_vals;
        nan_idx = data_fit.(field).nan_idx;
        
        % Adjust x-values by subtracting the mean
        mean_x = nanmean([peak_pos]);
        adjusted_peak_pos = peak_pos - mean_x;  % Subtract mean from peak positions

        % Adjust nan x-values by subtracting the mean
        mean_xn = nanmean(nan_idx);
        adjusted_peak_posn = nan_idx - mean_xn;  % Subtract mean from peak positions
        
        % Extract valid data and NaN data (ignoring NaNs)
        valid_peak_pos = adjusted_peak_pos(~isnan(peak_pos));
        valid_peak_val = peak_val(~isnan(peak_val));
        valid_nan_pos = adjusted_peak_posn(~isnan(nan_idx));
        valid_nan_val = nan_vals(~isnan(nan_vals));
        
        % If any array is empty, replace with 'NA'
        if isempty(valid_peak_pos)
            adjusted_peak_pos_cell{i} = 'NA';
        else
            adjusted_peak_pos_cell{i} = strjoin(arrayfun(@num2str, valid_peak_pos, 'UniformOutput', false), ' ');
        end
        
        if isempty(valid_peak_val)
            peak_val_cell{i} = 'NA';
        else
            peak_val_cell{i} = strjoin(arrayfun(@num2str, valid_peak_val, 'UniformOutput', false), ' ');
        end
        
        if isempty(valid_nan_pos)
            adjusted_nan_pos_cell{i} = 'NA';
        else
            adjusted_nan_pos_cell{i} = strjoin(arrayfun(@num2str, valid_nan_pos, 'UniformOutput', false), ' ');
        end
        
        if isempty(valid_nan_val)
            nan_val_cell{i} = 'NA';
        else
            nan_val_cell{i} = strjoin(arrayfun(@num2str, valid_nan_val, 'UniformOutput', false), ' ');
        end
        
        % Append to arrays (ignoring NaNs) for plotting later
        all_peak_pos = [all_peak_pos; valid_peak_pos];  % Remove NaNs for x
        all_peak_val = [all_peak_val; valid_peak_val];  % Remove NaNs for y
    end
    
    % Create a table where the rows correspond to categories and columns correspond to fields
    result_table = table(adjusted_peak_pos_cell', peak_val_cell', adjusted_nan_pos_cell', nan_val_cell', ...
                         'VariableNames', {'AdjustedPeakPos', 'PeakVal', 'AdjustedNanPos', 'NanVal'}, ...
                         'RowNames', fields);
    
    % Save the table as an Excel file in the current directory, overwrite if exists
    writetable(result_table, 'peak_positions_vs_values.xlsx', 'WriteRowNames', true, 'WriteVariableNames', true);
    
    % Now create the plots
    % Initialize the figure with a new size
    figure('Position', [0, 0, 1100, 600]);  % Updated figure size
    
    % Get the global min and max values for peak value
    global_ymin = min(all_peak_val);
    global_ymax = max(all_peak_val);

    % Loop again to plot each field with consistent axis limits
    for i = 1:numel(fields)
        field = fields{i};
        
        % Extract peak positions and values
        peak_pos = data_fit.(field).peak_pos;
        peak_val = data_fit.(field).peak_val;
        nan_vals = data_fit.(field).nan_vals;
        nan_idx = data_fit.(field).nan_idx;
        
        % Adjust x-values by subtracting the mean
        mean_x = nanmean(peak_pos);
        adjusted_peak_pos = peak_pos - mean_x;  % Subtract mean from peak positions
        
        % Adjust nan x-values by subtracting the mean
        mean_xn = nanmean(nan_idx);
        adjusted_peak_posn = nan_idx - mean_xn;  % Subtract mean from peak positions
        
        % Calculate the mean peak value
        mean_peak_val = nanmean(peak_val);  % Mean of peak values
        
        % Count NaNs
        nan_count = sum(isnan(peak_pos) | isnan(peak_val));

        % Calculate the standard deviation (ignoring NaNs)
        stdev_peak_pos = std(peak_pos, 'omitnan');
        stdev_peak_val = std(peak_val, 'omitnan');

        % Create a subplot for each field
        subplot(2, 3, i);
        
        % Plot valid data points in blue
        scatter(adjusted_peak_pos, peak_val, 'ko', 'MarkerFaceColor', 'b');  % Scatter plot for valid data
        
        % Plot NaN data points in red
        hold on;
        scatter(adjusted_peak_posn, nan_vals, 'ro', 'MarkerFaceColor', 'r');  % Scatter plot for NaN data in red
        hold off;
        
        grid on;
        
        % Set axis labels and title (without NaN count)
        xlabel('Peak Position (relative)');
        ylabel('Peak Value');
        
        % Clean up title (remove subscripts)
        title_str = strrep(field, '_', ' ');
        title(title_str);  % No NaN count in title

        % Display text with NaN count, stdev of peak positions, and peak values in the corner
        text(0.05, 0.95, sprintf('NaNs: %d\nStdev (z): %.3f\nStdev (BS): %.3f', ...
            nan_count, stdev_peak_pos, stdev_peak_val), 'Units', 'normalized', 'FontSize', 12);

        % Set consistent x and y limits across all subplots
        xlim([-15, 15]);  % Fixed x-axis range from -15 to 15
        ylim([6.3, 6.47]);  % Fixed y-axis range from 6.25 to 6.47
        
        % Add a horizontal line at the mean peak value
        yline(mean_peak_val, '--r', sprintf('mean: %.3f', mean_peak_val), 'LabelHorizontalAlignment', 'left');
    end
end


function plot_shift_maps(zscan_data, save_path, figure_title)
    %Function to plot all z-profiles from individual ROIs in control or
    %aged. zscan_data: struct containing multiple 3 x 3 x 41 zscan ROI
    %matrices.

    % Get the field names of the structure (which represent different z-scans)
    zscan_fields = fieldnames(zscan_data);
    num_subplots = length(zscan_fields);  % Number of z_scan fields

    % Create a wider figure for the plots
    figure('Position', [100, 100, 1500, 300]);  
    
    % Define the x-axis values (0 to 80 microns with steps of 2)
    x_vals_41 = 0:2:80;  % 41 points from 0 to 80 microns (step of 2)
    x_vals_40 = 0:2:78;  % 40 points from 0 to 78 microns (step of 2)
    
    % Initialize an array to store the data for global y-limit calculation
    all_data = NaN(9, 41, num_subplots);  % 9 elements in the 3x3 matrix, 41 time points, num_subplots z-scans
    
    % Loop through each z_scan field to store data and calculate the global y-limits
    for i = 1:num_subplots
        % Get the current z_scan matrix (3x3x41 or 3x3x40) using the field name
        zscan_matrix = zscan_data.(zscan_fields{i});
        
        % Adjust the x-values and matrix size if the third dimension is 40
        if size(zscan_matrix, 3) == 40
            x_vals = x_vals_40;  % Use 40 points for the x-axis
        else
            x_vals = x_vals_41;  % Use 41 points for the x-axis
        end
        
        % Loop over each element in the 3x3 matrix and store data
        for row = 1:3
            for col = 1:3
                % Extract the time series for the current position in the 3x3 matrix
                data = squeeze(zscan_matrix(row, col, :));
                
                % Store the data for averaging
                all_data((row - 1) * 3 + col, 1:length(data), i) = data;
            end
        end
    end
    
    % Find global y-limits across all subplots (find minimum and maximum of all data)
    global_min = min(all_data(:));
    global_max = max(all_data(:));
    y_limits = [global_min, global_max];  % Set y-limits based on global data
    
    % Create the subplots
    for i = 1:num_subplots
        subplot(1, num_subplots, i);  % Create a subplot for each z_scan matrix
        
        % Loop over each element in the 3x3 matrix and plot
        for row = 1:3
            for col = 1:3
                % Extract the data for the current position in the 3x3 matrix
                data = squeeze(all_data((row - 1) * 3 + col, :, i));
                
                % Plot the data as a line (one line for each matrix element)
                plot(x_vals, data, 'LineWidth', 1.5);
                hold on;  % Keep all lines in the same subplot
            end
        end
        
        % Calculate and plot the average line profile in black
        avg_data = nanmean(all_data(:, :, i), 1);  % Average across the 9 lines
        plot(x_vals, avg_data, 'k', 'LineWidth', 3);  % Plot in black, thicker line
        
        % Set consistent y-axis limits for all subplots
        %ylim(y_limits)
        ylim([6.221, 6.488])
        disp(['y limits here: ', num2str(y_limits)]);
        
        % Add title and labels for the subplot
        title(zscan_fields{i}, 'FontSize', 12, 'Interpreter', 'latex');  % Subscript formatting
        xlabel('z (microns)', 'FontSize', 12);  % Updated x-label
        set(gca, 'XTick', x_vals(1:5:end), 'XTickLabel', x_vals(1:5:end), 'FontSize', 12);  % Updated x-ticks
        set(gca, 'FontSize', 12);  % Set font size for axes
        xlim([0 80]);  % Set x-axis limits to [0, 80]
        grid on;
        hold off;
    end
    
    % Add a figure-wide title (custom title passed as an argument)
    try
        sgtitle(figure_title);  % Use sgtitle for newer MATLAB versions
    catch
        % Fallback for older versions using annotation
        annotation('textbox', [0.5, 0.95, 0, 0], 'String', figure_title, 'EdgeColor', 'none', ...
                   'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 14);
    end

    % Save the figure to the root folder
    saveas(gcf, fullfile(save_path, 'z_profiles.png'));  % Save the figure as PNG
    disp('Figure saved as z_profiles.png');
end


function aged_zscan = create_struct_from_shift_maps(rootDir)
    % Function to read z-scan data and return it in a struct.

    % Initialize the struct to store the data
    aged_zscan = struct();

    % Get a list of folders at the first level (arbitrary folders inside the root)
    topLevelFolders = dir(rootDir);
    topLevelFolders = topLevelFolders([topLevelFolders.isdir] & ~ismember({topLevelFolders.name}, {'.', '..'}));

    % Loop through each top-level folder
    for i = 1:length(topLevelFolders)
        titleFolder = topLevelFolders(i).name;
        
        % Get a list of time-stamped folders in the current top-level folder
        timeStampedFolders = dir(fullfile(rootDir, titleFolder));
        timeStampedFolders = timeStampedFolders([timeStampedFolders.isdir] & ~ismember({timeStampedFolders.name}, {'.', '..'}));

        % Initialize a matrix to store the shift maps for the current title folder
        shiftMapsMatrix = [];

        % Loop through each time-stamped folder and load the Shift_Map.csv
        for j = 1:length(timeStampedFolders)
            timeStampFolder = timeStampedFolders(j).name;

            % Construct the path to the Shift_Map.csv file
            shiftMapPath = fullfile(rootDir, titleFolder, timeStampFolder, 'Shift_Map.csv');

            % Check if the Shift_Map.csv exists
            if exist(shiftMapPath, 'file')
                % Read the CSV file into a matrix
                shiftMap = csvread(shiftMapPath);

                % Append this shift map to the matrix for this title
                shiftMapsMatrix(:, :, j) = shiftMap;
            else
                warning('Shift_Map.csv not found in %s', shiftMapPath);
            end
        end
        
        % Store the 3x3x42 matrix in the struct
        if ~isempty(shiftMapsMatrix)
            aged_zscan.(titleFolder) = shiftMapsMatrix;
        end
    end
end
