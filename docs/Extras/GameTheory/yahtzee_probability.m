% n dice
% m faces
% r rolls
[n, m, r] = deal(8, 8, 8);
file_name = sprintf('yahtzee_prob_%d_%d_%d.txt', n, m, r);
fileID = fopen(file_name, "w");

fprintf(fileID, 'For %d %d-sided dice and %d rolls\n', n, m, r);

[up_unique_patterns, up_counts, up_total_outcomes, up_prob] = dice_prob_by_pattern(n, m);

% Display the up_unique_patterns and their probabilities
fprintf(fileID, 'Frequency Pattern  Probability\n');
fprintf(fileID, '-------------------------------\n');
for i = 1:size(up_unique_patterns, 1)
    fprintf(fileID, '%s      %d / %d = %.4f\n', mat2str(up_unique_patterns(i, :)), up_counts(i), up_total_outcomes, up_prob(i));
end

[md_num_matching_dice, md_counts, md_total_outcomes, md_prob] = num_matching_dice_from_pattern(up_unique_patterns, up_counts, up_total_outcomes);

% Display the md_num_matching_dice and their probabilities
fprintf(fileID, 'Matching Dice Initial Starting Probabilities\n');
fprintf(fileID, '-------------------------------\n');
for i = 1:n
    fprintf(fileID, '%d : %d / %d = %.4f\n', i, md_counts(i), md_total_outcomes, md_prob(i));
end

[tm_matrix_counts, tm_total_outcomes, tm_matrix_prob] = transition_matrix(n, m);
final_probabilities = md_prob' * tm_matrix_prob^(r-1);

% Display the transition matrix
fprintf(fileID, 'Transition Matrix\n');
fprintf(fileID, '-------------------------------\n');
for i = 1:n
    fprintf(fileID, '%s :/%d\n', mat2str(tm_matrix_counts(i, :)), tm_total_outcomes(i));
end
fprintf(fileID, '-------------------------------\n');
% Loop through the matrix rows and columns
for i = 1:size(tm_matrix_prob, 1)
    for j = 1:size(tm_matrix_prob, 2)
        fprintf(fileID, '%.4f\t', tm_matrix_prob(i, j));
    end
    fprintf(fileID, '\n');
end

% Display the final probabilities
fprintf(fileID, 'Final Probabilities after 1 roll and %d rerolls\n', (r-1));
fprintf(fileID, '-------------------------------\n');
for i = 1:n
    fprintf(fileID, '%d-pair : %.6f\n', i, final_probabilities(i));
end
fprintf(fileID, 'Sum of probabilities : %.10f\n', sum(final_probabilities));

fclose(fileID);
fprintf('Data written to file %s\n', file_name);

function [matrix_counts, total_outcomes, matrix_prob] = transition_matrix(n, m)
    matrix_counts = zeros(n);
    total_outcomes = zeros(n, 1);
    matrix_prob = zeros(n);

    matrix_counts(n, n) = 1;
    total_outcomes(n, 1) = 1;

    % For every row of the transition matrix
    for k = 1:n-1
        % Generate unique patterns for dice being rerolled
        [up_unique_patterns, up_counts, up_total_outcomes, ~] = dice_prob_by_pattern(n-k, m);
        total_outcomes(k) = up_total_outcomes;

        % For every unique pattern
        for i = 1:size(up_unique_patterns, 1)
            % There is a 1/m chance the current largest group matches the face
            count_per_face = up_counts(i) / m;

            % For every element of the unique pattern
            for j = 1:size(up_unique_patterns, 2)
                % Calculate the current largest group
                largest_matching_set = max(k + up_unique_patterns(i, j), up_unique_patterns(i, 1));
                % Add the count to the respective transition
                matrix_counts(k, largest_matching_set) = matrix_counts(k, largest_matching_set) + count_per_face;
            end
        end
        
        % Calculate matrix with probabilities
        for i = 1:n
            for j = 1:n
                matrix_prob(i, j) = matrix_counts(i, j) / total_outcomes(i);
            end
        end

    end
    
end

function [num_matching_dice, counts, total_outcomes, prob] = num_matching_dice_from_pattern(unique_patterns, pattern_counts, total_outcomes)
    n = sum(unique_patterns(1,:));
    num_matching_dice = (1:n)';
    counts = zeros(n, 1);
    
    % Add up unique patterns by largest single group
    for i = 1:size(unique_patterns, 1)
        counts(unique_patterns(i, 1)) = counts(unique_patterns(i, 1)) + pattern_counts(i);
    end

    % Compute probabilities
    prob = counts / total_outcomes;
end

function [unique_patterns, counts, total_outcomes, prob] = dice_prob_by_pattern(n, m)
    % Calculate total number of outcomes
    total_outcomes = m^n;

    % Generate all combinations of dice rolls
    outcomes = generate_combinations(n, m);
    assert(total_outcomes == size(outcomes, 1));
    
    % Convert each combination into its frequency pattern (ignore actual values)
    patterns = cell(total_outcomes, 1);
    for i = 1:total_outcomes
        patterns{i} = sort(histcounts(outcomes(i, :), 1:m+1), 'descend');
    end
    
    % Find unique patterns
    [unique_patterns, ~, idx] = unique(cell2mat(patterns), 'rows');
    
    % Count the frequency of each pattern
    counts = histc(idx, unique(idx));

    % Compute probabilities
    prob = counts / total_outcomes;
end

function outcomes = generate_combinations(n, m)
    % Generate all combinations of n dice with m faces
    faces = 1:m;
    [outcomes{1:n}] = ndgrid(faces);
    outcomes = cellfun(@(x) x(:), outcomes, 'UniformOutput', false);
    outcomes = [outcomes{:}];
end
