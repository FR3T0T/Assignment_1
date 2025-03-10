function varargout = battleshipGrid(command, varargin)
% BATTLESHIPGRID - Grid og display funktioner til Battleship-spillet
%
% Kommandoer:
%   'drawGrid'      - Tegner et tomt 10x10 grid
%   'updateDisplay' - Opdaterer gridvisningen baseret på spillets tilstand
%
% Se hver specifik funktion for flere detaljer om input parametre.

    switch command
        case 'drawGrid'
            drawGrid(varargin{:});
        case 'updateDisplay'
            updateGridDisplay(varargin{:});
        otherwise
            error('Ugyldig kommando: %s', command);
    end
end

function drawGrid(ax)
    % Tegn et tomt 10x10 grid med forbedret stil
    cla(ax);
    hold(ax, 'on');
    
    % Tilføj en klikbar baggrund
    rectangle('Parent', ax, 'Position', [0 0 10 10], 'FaceColor', 'none', 'EdgeColor', 'none', 'PickableParts', 'all');
    
    % Sæt akseegenskaber
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Farvelæg baggrunden for bedre kontrast
    fill(ax, [0 10 10 0], [0 0 10 10], [0.96 0.98 1], 'EdgeColor', 'none');
    
    % Tegn gridlinjer med lidt skygge
    for i = 0:10
        line(ax, [i i], [0 10], 'Color', [0.7 0.7 0.8]);
        line(ax, [0 10], [i i], 'Color', [0.7 0.7 0.8]);
    end
    
    % Tilføj labels med bedre formattering
    for i = 1:10
        text(ax, i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(ax, -0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Fjern standard akseticks
    set(ax, 'XTick', [], 'YTick', []);
    
    hold(ax, 'off');
end

function updateGridDisplay(ax, shipGrid, shotGrid, showShips)
    % Opdater gridvisningen baseret på spillets tilstand
    cla(ax);
    hold(ax, 'on');
    
    % Tilføj en klikbar baggrund
    rectangle('Parent', ax, 'Position', [0 0 10 10], 'FaceColor', 'none', 'EdgeColor', 'none', 'PickableParts', 'all');
    
    % Tegn grundlæggende grid
    axis(ax, [0 10 0 10]);
    axis(ax, 'square');
    
    % Farvelæg baggrunden for bedre kontrast
    fill([0 10 10 0], [0 0 10 10], [0.96 0.98 1], 'EdgeColor', 'none');
    
    % Tegn gridlinjer med lidt skygge
    for i = 0:10
        line([i i], [0 10], 'Color', [0.7 0.7 0.8]);
        line([0 10], [i i], 'Color', [0.7 0.7 0.8]);
    end
    
    % Tilføj labels med bedre formattering
    for i = 1:10
        text(i-0.5, -0.3, num2str(i), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(-0.3, i-0.5, char('A'+i-1), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Fjern standard akseticks
    set(ax, 'XTick', [], 'YTick', []);
    
    % Visualiser skibe, hits og misses med forbedret udseende
    for i = 1:10
        for j = 1:10
            if shotGrid(i, j) == 2
                % Hit
                rectangle('Position', [j-1, i-1, 1, 1], 'FaceColor', [0.9 0.3 0.3], 'EdgeColor', [0.7 0 0]);
                plot(j-0.5, i-0.5, 'kx', 'LineWidth', 2, 'MarkerSize', 15);
            elseif shotGrid(i, j) == 1
                % Miss
                plot(j-0.5, i-0.5, 'ko', 'MarkerSize', 10, 'LineWidth', 1.5, 'MarkerFaceColor', [0.5 0.5 0.5]);
            elseif showShips && shipGrid(i, j) > 0
                % Ship - mere visuelt attraktiv repræsentation
                shipType = shipGrid(i, j);
                shipColors = {[0.2 0.4 0.8], [0.3 0.5 0.8], [0.4 0.6 0.9]}; % Forskellige nuancer til forskellige skibe
                rectangle('Position', [j-1, i-1, 1, 1], 'FaceColor', shipColors{shipType}, ...
                         'EdgeColor', [0.1 0.2 0.5], 'LineWidth', 1);
            end
        end
    end
    
    hold(ax, 'off');
end