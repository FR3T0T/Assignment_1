function updateGridDisplay(ax, shipGrid, shotGrid, showShips)
% UPDATEGRID - Opdater gridvisningen baseret på spillets tilstand
% Inputs:
%   ax - Axes object to update
%   shipGrid - 10x10 matrix with ship placements
%   shotGrid - 10x10 matrix with shot information
%   showShips - Boolean, whether to display ships or not
    
    cla(ax);
    hold(ax, 'on');
    
    % Tegn grundlæggende grid
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Tegn gridlinjer
    for i = 0:10
        line(ax, [i i], [0 10], 'Color', 'k');
        line(ax, [0 10], [i i], 'Color', 'k');
    end
    
    % Tilføj labels
    for i = 1:10
        text(ax, i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center');
        text(ax, -0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center');
    end
    
    % Fjern standard akseticks
    set(ax, 'XTick', [], 'YTick', []);
    
    % Visualiser skibe, hits og misses
    for i = 1:10
        for j = 1:10
            if shotGrid(i, j) == 2
                % Hit
                rectangle(ax, 'Position', [j-1, i-1, 1, 1], 'FaceColor', 'red');
                plot(ax, j-0.5, i-0.5, 'kx', 'LineWidth', 2, 'MarkerSize', 15);
            elseif shotGrid(i, j) == 1
                % Miss
                plot(ax, j-0.5, i-0.5, 'ko', 'MarkerSize', 10, 'LineWidth', 1.5);
            elseif showShips && shipGrid(i, j) > 0
                % Ship
                rectangle(ax, 'Position', [j-1, i-1, 1, 1], 'FaceColor', [0.3 0.5 0.8]);
            end
        end
    end
    
    hold(ax, 'off');
end