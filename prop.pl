% Définition des opérateurs personnalisés
:- op(900, fy, non).   % Opérateur unaire de négation
:- op(800, xfy, et).    % Opérateur 'et' (conjonction)
:- op(700, xfy, ou).    % Opérateur 'ou' (disjonction)
:- op(600, xfy, =>).    % Opérateur '=>' (implication)

% Prédicat transformer/2 pour transformer une formule en un arbre
transformer(F, F) :-
    atomic(F). % Cas de base : F est une proposition atomique

transformer(non F, ArbreF) :-
    transformer(F, ArbreF). % Transforme F en sous-arbre ArbreF

transformer(F1 => F2, [F1 => F2, ArbreF1, ArbreF2]) :-
    transformer(F1, ArbreF1),
    transformer(F2, ArbreF2).

transformer(F1 ou F2, [F1 ou F2, ArbreF1, ArbreF2]) :-
    transformer(F1, ArbreF1),
    transformer(F2, ArbreF2).

transformer(F1 et F2, [F1 et F2, ArbreF1, ArbreF2]) :-
    transformer(F1, ArbreF1),
    transformer(F2, ArbreF2).
