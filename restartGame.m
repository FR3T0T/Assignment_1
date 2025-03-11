function restartGame(startButton, resultPanel)
% RESTARTGAME - Hjælpefunktion til at fjerne resultatpanelet og starte et nyt spil
% Inputs:
%   startButton - Handle til startknappen
%   resultPanel - Handle til resultatpanelet
    
    delete(resultPanel);
    startGame(startButton, []);
end