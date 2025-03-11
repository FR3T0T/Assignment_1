function closeGame(src, ~)
% CLOSEGAME - Håndterer lukning af spillet med bekræftelsesdialog
% Inputs:
%   src - Source handle for callback
    
    % Bekræft afslutning af spil
    choice = questdlg('Er du sikker på, at du vil afslutte spillet?', ...
        'Afslut Battleship', 'Ja', 'Nej', 'Nej');
    
    if strcmp(choice, 'Ja')
        delete(src);
    end
end