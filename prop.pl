% Définition des opérateurs personnalisés
:- op(900, fy, non).   % Opérateur unaire de négation
:- op(800, xfy, et).    % Opérateur 'et' (conjonction)
:- op(700, xfy, ou).    % Opérateur 'ou' (disjonction)
:- op(600, xfy, =>).    % Opérateur '=>' (implication)

% Prédicat transformer/2 pour transformer une formule en un arbre avec numérotation en profondeur
transformer(F, Arbre) :-
    transformer(F, Arbre, 0, _), % Appelle le prédicat avec un numéro initial de nœud à 0
    write(Arbre).

% Cas de base : F est une proposition atomique
transformer(F, [Numero, F, nil, nil], Numero, Numero) :-
    atomic(F).

% Cas pour l'opérateur unaire non
transformer(non F, ArbreF, NumeroIn, NumeroOut) :-
    NewNumero is NumeroIn + 1,
    transformer(F, ArbreF, NewNumero, NumeroOut).

% Cas pour l'opérateur implication =>
transformer(F1 => F2, [NumeroIn, F1 => F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut) :-
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut).

% Cas pour l'opérateur disjonction ou
transformer(F1 ou F2, [NumeroIn, F1 ou F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut) :-
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut).

% Cas pour l'opérateur conjonction et
transformer(F1 et F2, [NumeroIn, F1 et F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut) :-
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut).