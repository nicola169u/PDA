% Définition des opérateurs personnalisés
:- op(900, fy, non).   % Opérateur unaire de négation
:- op(800, xfy, et).    % Opérateur 'et' (conjonction)
:- op(700, xfy, ou).    % Opérateur 'ou' (disjonction)
:- op(600, xfy, =>).    % Opérateur '=>' (implication)

% Prédicat transformer/2 pour transformer une formule en un arbre avec numérotation en profondeur
transformer(F, Arbre) :-
    transformer(F, Arbre, 0, _, 0), % Appelle le prédicat avec un numéro initial de nœud à 0
    write(Arbre).

% Cas de base : F est une proposition atomique
transformer(F, [Numero, Polarite, F, nil, nil], Numero, Numero, Polarite) :-
    atomic(F).

% Cas pour l'opérateur unaire 'non'
transformer(non F, ArbreF, NumeroIn, NumeroOut, Polarite) :-
    InversePolarite is 1 - Polarite,
    transformer(F, ArbreF, NumeroIn, NumeroOut, InversePolarite).

% Cas pour l'opérateur implication '=>'
transformer(F1 => F2, [NumeroIn, Polarite, F1 => F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite) :-
    NewNumero1 is NumeroIn + 1,
    InversePolarite is 1 - Polarite,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, InversePolarite),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite).

% Cas pour l'opérateur disjonction 'ou' (pas de changement de polarite)
transformer(F1 ou F2, [NumeroIn, Polarite, F1 ou F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite) :-
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, Polarite),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite).

% Cas pour l'opérateur conjonction 'et' (pas de changement de polarite)
transformer(F1 et F2, [NumeroIn, Polarite, F1 et F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite) :-
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, Polarite),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite).