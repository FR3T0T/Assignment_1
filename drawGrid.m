function drawGrid(ax)
% DRAWGRID - Tegn et tomt 10x10 grid
% Inputs:
%   ax - Axes object to draw the grid on
    
    cla(ax);
    hold(ax, 'on');
    
    % Sæt akseegenskaber
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
    
    hold(ax, 'off');
end