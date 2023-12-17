clear all; close all; clc;

% Load the data from the .mat file
A = load('projectdata_time_series.mat');

% Extract specific columns from the data
dataTable = A.dataTable;
returns = table2array(dataTable(1:14200, 2:50));  % Adjusted as per your data

% Number of portfolios
numPortfolios = size(returns, 2);

% 1. Correlation Matrix and 1-Adjacency Matrix (C matrix)
corrMatrix = corr(returns, 'Rows', 'pairwise');
thresholdCorr = 0.55;  % Correlation threshold
C = corrMatrix > thresholdCorr;  % 1-Adjacency Matrix

% 2. Euclidean Distance Matrix (E matrix) and Graph Creation
distanceMatrix = zeros(numPortfolios, numPortfolios);
for i = 1:numPortfolios
    for j = 1:numPortfolios
        diff = returns(:, i) - returns(:, j);
        sqDiff = diff .^ 2;
        sqDiff(isnan(sqDiff)) = 0;  % Set NaN differences to 0
        distanceMatrix(i, j) = sqrt(sum(sqDiff));
    end
end
G2 = graph(distanceMatrix, 'upper');  % Weighted graph for Euclidean distance matrix

% 3. Statistical Significance and 3-Adjacency Matrix (S matrix)
alpha = 0.05;  % Significance level
S = zeros(numPortfolios, numPortfolios);
for i = 1:numPortfolios
    for j = i+1:numPortfolios  % Only need to do one half of matrix due to symmetry
        [~, pValue] = ttest2(returns(:, i), returns(:, j), 'Vartype', 'unequal');
        if pValue < alpha
            S(i, j) = 1;
            S(j, i) = 1;  % Symmetric
        end
    end
end
G3 = graph(S);  % Graph for Statistical significance-based adjacency matrix

% Create graph for C matrix
G1 = graph(C);  % Graph for Correlation-based adjacency matrix

% Visualize Graph G-1 (Correlation-based) in a separate figure
figure;
plot(G1);
title('Graph-1 (Corr-based)');

% Visualize Graph G-2 (Euclidean Distance-based) in a separate figure
figure;
plot(G2, 'EdgeCData', G2.Edges.Weight);
title('G-2 (E-based)');
colormap(jet);
colorbar;

% Visualize Graph G-3 (Statistical Significance-based) in a separate figure
figure;
plot(G3);
title('G-3 (SS-based)');


%% Part-2

% Calculate centralities for G1 (Correlation-based graph)
degreeCentralityG1 = centrality(G1, 'degree');
eigenvectorCentralityG1 = centrality(G1, 'eigenvector');
pageRankCentralityG1 = centrality(G1, 'pagerank');

% For G2 (Euclidean Distance-based graph), apply your custom threshold
% Convert the distance matrix to a binary adjacency matrix
customThreshold = 1.5;  % Set your custom threshold value here
binaryAdjMatrixG2 = distanceMatrix < customThreshold;
G2 = graph(binaryAdjMatrixG2);

% Calculate centralities for the thresholded G2
degreeCentralityG2 = centrality(G2, 'degree');
eigenvectorCentralityG2 = centrality(G2, 'eigenvector');
pageRankCentralityG2 = centrality(G2, 'pagerank');

% Calculate centralities for G3 (Statistical Significance-based graph)
degreeCentralityG3 = centrality(G3, 'degree');
eigenvectorCentralityG3 = centrality(G3, 'eigenvector');
pageRankCentralityG3 = centrality(G3, 'pagerank');


%% Part-3

% Visualize Degree Centrality for G-1
figure;
bar(degreeCentralityG1);
title('Degree Centrality of G-1, threshold = 0.55');
xlabel('Portfolio index')
ylabel('Frequency')
% Visualize Degree Centrality for G-2
figure;
bar(degreeCentralityG2);
title('Degree Centrality of G-2');
xlabel('Portfolio index')
ylabel('Frequency')
% Visualize Degree Centrality for G-3
figure;
bar(degreeCentralityG3);
title('Degree Centrality of G-3, alpha = 0.05');
xlabel('Portfolio index')
ylabel('Frequency')
% Visualize Eigenvector Centrality for G-1
figure;
bar(eigenvectorCentralityG1);
title('Eigenvector Centrality of G-1, threshold = 0.55');
xlabel('Portfolio index')
ylabel('Eigenvector Centrality Score')
% Visualize Eigenvector Centrality for G-2
figure;
bar(eigenvectorCentralityG2);
title('Eigenvector Centrality of G-2');
xlabel('Portfolio index')
ylabel('Eigenvector Centrality Score')
% Visualize Eigenvector Centrality for G-3
figure;
bar(eigenvectorCentralityG3);
title('Eigenvector Centrality of G-3, alpha = 0.05');
xlabel('Portfolio index')
ylabel('Eigenvector Centrality Score')
% Visualize PageRank Centrality for G-1
figure;
bar(pageRankCentralityG1);
title('PageRank Centrality G-1, threshold = 0.55');
xlabel('Portfolio index')
ylabel('PageRank Centrality Score')
% Visualize PageRank Centrality for G-2
figure;
bar(pageRankCentralityG2);
title('PageRank Centrality G-2');
xlabel('Portfolio index')
ylabel('PageRank Centrality Score')
% Visualize PageRank Centrality for G-3
figure;
bar(pageRankCentralityG3);
title('PageRank centrality G-3, alpha = 0.05');
xlabel('Portfolio index')
ylabel('PageRank Centrality Score')

%% Part-4

% Rank portfolios based on PageRank centrality for G-1 and plot
[~, sortedIndicesG1] = sort(pageRankCentralityG1, 'descend');
figure;
bar(pageRankCentralityG1(sortedIndicesG1));
title('Ranking via PageRank centrality (G-1), threshold = 0.55');
xlabel('Portfolio Index');
ylabel('PageRank Centrality Score');
xticks(1:length(sortedIndicesG1));
xticklabels(arrayfun(@num2str, sortedIndicesG1, 'UniformOutput', false));

% Rank portfolios based on PageRank centrality for G-2 and plot
[~, sortedIndicesG2] = sort(pageRankCentralityG2, 'descend');
figure;
bar(pageRankCentralityG2(sortedIndicesG2));
title('Ranking via Pagerank centrality (G-2)');
xlabel('Portfolio Index');
ylabel('PageRank Centrality Score');
xticks(1:length(sortedIndicesG2));
xticklabels(arrayfun(@num2str, sortedIndicesG2, 'UniformOutput', false));

% Rank portfolios based on PageRank centrality for G-3 and plot
[~, sortedIndicesG3] = sort(pageRankCentralityG3, 'descend');
figure;
bar(pageRankCentralityG3(sortedIndicesG3));
title('Ranking via Pagerank centrality (G-3), alpha = 0.05');
xlabel('Portfolio Index');
ylabel('PageRank Centrality Score');
xticks(1:length(sortedIndicesG3));
xticklabels(arrayfun(@num2str, sortedIndicesG3, 'UniformOutput', false));





% Rank portfolios based on Degree Centrality for G-1 and plot
[~, sortedIndicesDegG1] = sort(degreeCentralityG1, 'descend');
figure;
bar(degreeCentralityG1(sortedIndicesDegG1));
title('Ranking via Degree centrality (G-1), threshold = 0.55');
xlabel('Portfolio Index');
ylabel('Degree Centrality Score');
xticks(1:length(sortedIndicesDegG1));
xticklabels(arrayfun(@num2str, sortedIndicesDegG1, 'UniformOutput', false));

% Rank portfolios based on Degree Centrality for G-2 and plot
[~, sortedIndicesDegG2] = sort(degreeCentralityG2, 'descend');
figure;
bar(degreeCentralityG2(sortedIndicesDegG2));
title('Ranking via Degree centrality (G-2)');
xlabel('Portfolio Index');
ylabel('Degree Centrality Score');
xticks(1:length(sortedIndicesDegG2));
xticklabels(arrayfun(@num2str, sortedIndicesDegG2, 'UniformOutput', false));

% Rank portfolios based on Degree Centrality for G-3 and plot
[~, sortedIndicesDegG3] = sort(degreeCentralityG3, 'descend');
figure;
bar(degreeCentralityG3(sortedIndicesDegG3));
title('Ranking via Degree centrality (G-3), alpha = 0.05 ');
xlabel('Portfolio Index');
ylabel('Degree Centrality Score');
xticks(1:length(sortedIndicesDegG3));
xticklabels(arrayfun(@num2str, sortedIndicesDegG3, 'UniformOutput', false));


% Rank portfolios based on Eigenvector Centrality for G-1 and plot
[~, sortedIndicesEigenG1] = sort(eigenvectorCentralityG1, 'descend');
figure;
bar(eigenvectorCentralityG1(sortedIndicesEigenG1));
title('Ranking via Eigenvector centrality (G-1), threshold = 0.55');
xlabel('Portfolio Index');
ylabel('Eigenvector Centrality Score');
xticks(1:length(sortedIndicesEigenG1));
xticklabels(arrayfun(@num2str, sortedIndicesEigenG1, 'UniformOutput', false));

% Rank portfolios based on Eigenvector Centrality for G-2 and plot
[~, sortedIndicesEigenG2] = sort(eigenvectorCentralityG2, 'descend');
figure;
bar(eigenvectorCentralityG2(sortedIndicesEigenG2));
title('Ranking via Eigenvector centrality (G-2)');
xlabel('Portfolio Index');
ylabel('Eigenvector Centrality Score');
xticks(1:length(sortedIndicesEigenG2));
xticklabels(arrayfun(@num2str, sortedIndicesEigenG2, 'UniformOutput', false));


% Rank portfolios based on Eigenvector Centrality for G-3 and plot
[~, sortedIndicesEigenG3] = sort(eigenvectorCentralityG3, 'descend');
figure;
bar(eigenvectorCentralityG3(sortedIndicesEigenG3));
title('Ranking via Eigenvector centrality (G-3), alpha = 0.05');
xlabel('Portfolio Index');
ylabel('Eigenvector Centrality Score');
xticks(1:length(sortedIndicesEigenG3));
xticklabels(arrayfun(@num2str, sortedIndicesEigenG3, 'UniformOutput', false));








