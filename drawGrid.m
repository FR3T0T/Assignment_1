function drawGrid(ax)
% DRAWGRID - Draw an empty 10x10 grid
% Inputs:
%   ax - Axes object to draw the grid on
    
    cla(ax);
    hold(ax, 'on');
    
    % Set axis properties
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Draw grid lines
    for i = 0:10
        line(ax, [i i], [0 10], 'Color', 'k');
        line(ax, [0 10], [i i], 'Color', 'k');
    end
    
    % Add labels
    for i = 1:10
        text(ax, i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center');
        text(ax, -0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center');
    end
    
    % Remove standard axis ticks
    set(ax, 'XTick', [], 'YTick', []);
    
    hold(ax, 'off');
end