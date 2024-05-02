% Définition des opérateurs personnalisés
:- op(900, fy, non).   % Opérateur unaire de négation
:- op(800, xfy, et).    % Opérateur 'et' (conjonction)
:- op(700, xfy, ou).    % Opérateur 'ou' (disjonction)
:- op(600, xfy, =>).    % Opérateur '=>' (implication)

% Prédicat transformer/1 pour transformer une formule en un arbre avec numérotation en profondeur
transformer(F) :-
    transformer(F, Arbre, 0, _, 0, '_'),
    write(Arbre).

% Cas de base : F est une proposition atomique
transformer(F, [Numero, '_', TypeSec, Polarite, F, nil, nil], Numero, Numero, Polarite, TypeSec) :-
    atomic(F).

% Cas pour l'opérateur unaire 'non'
transformer(non F, ArbreF, NumeroIn, NumeroOut, Polarite, _) :-
    InversePolarite is 1 - Polarite,
    transformer(F, ArbreF, NumeroIn, NumeroOut, InversePolarite, 'alpha1'). 

% Cas pour l'opérateur implication '=>'
transformer(F1 => F2, [NumeroIn, Type, TypeSec, Polarite, F1 => F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite, TypeSec) :-
    ( Polarite =:= 0
    ->
        Type = alpha,
        TypeSec1 = alpha1,
        TypeSec2 = alpha2
    ;
        Type = beta,
        TypeSec1 = beta1,
        TypeSec2 = beta2
    ),
    NewNumero1 is NumeroIn + 1,
    InversePolarite is 1 - Polarite,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, InversePolarite, TypeSec1),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite, TypeSec2).

% Cas pour l'opérateur disjonction 'ou' (pas de changement de polarite)
transformer(F1 ou F2, [NumeroIn, Type, TypeSec, Polarite, F1 ou F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite, TypeSec) :-
    ( Polarite =:= 0
    ->
        Type = alpha,
        TypeSec1 = alpha1,
        TypeSec2 = alpha2
    ;
        Type = beta,
        TypeSec1 = beta1,
        TypeSec2 = beta2
    ),
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, Polarite, TypeSec1),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite, TypeSec2).

% Cas pour l'opérateur conjonction 'et' (pas de changement de polarite)
transformer(F1 et F2, [NumeroIn, Type, TypeSec, Polarite, F1 et F2, ArbreF1, ArbreF2], NumeroIn, NumeroOut, Polarite, TypeSec) :-
    ( Polarite =:= 1
    ->
        Type = alpha,
        TypeSec1 = alpha1,
        TypeSec2 = alpha2
    ;
        Type = beta,
        TypeSec1 = beta1,
        TypeSec2 = beta2
    ),
    NewNumero1 is NumeroIn + 1,
    transformer(F1, ArbreF1, NewNumero1, NumeroInter, Polarite, TypeSec1),
    NewNumero2 is NumeroInter + 1,
    transformer(F2, ArbreF2, NewNumero2, NumeroOut, Polarite, TypeSec2).


% Prédicat pour supprimer un element d'une liste, auteur : Developerorium
del(X, [X|Tail], Tail).
del(X, [Head|Tail], [Head|NewTail]) :-
    del(X, Tail, NewTail).


getNumero([Numero, _, _, _, _, _, _], Numero).

% Prédicat pour générer et afficher l'arbre des chemins
chemins(Arbre) :-
    chemins(Arbre, Chemins, [0]),
    write(Chemins).

% Cas de base : feuille de l'arbre (proposition atomique)
chemins([Numero, _, _, _, _, nil, nil], Numero, _).

% Cas pour les nœuds de type alpha
chemins([Numero, alpha, _, _, _, Fils1, Fils2], [Noeud | CheminsFils], Noeud) :-
    del(Numero, Noeud, PNoeud),
    getNumero(Fils1, Num1),
    getNumero(Fils2, Num2),
    chemins(Fils1, CheminsF1, [Num1|PNoeud]),
    chemins(Fils2, CheminsF2, [Num2|PNoeud]),
    CheminsFils = [[CheminsF1, CheminsF2]].

% Cas pour les nœuds de type beta
chemins([Numero, beta, _, _, _, Fils1, Fils2], [Noeud | CheminsFils], Noeud) :-
    del(Numero, Noeud, PNoeud),
    getNumero(Fils1, Num1),
    getNumero(Fils2, Num2),
    chemins(Fils1, CheminsF1, [Num1|PNoeud]),
    chemins(Fils2, CheminsF2, [Num2|PNoeud]),
    CheminsFils = [[CheminsF1], [CheminsF2]].



% % Cas pour les nœuds de type alpha
% chemins([Numero, alpha, _, _, _, Fils1, Fils2], Chemins, Noeud) :-
%     del(Numero, Noeud, PNoeud),
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     chemins(Fils1, CheminsF1, [Num1|PNoeud]),
%     chemins(Fils2, CheminsF2, [Num2|PNoeud]),
%     write(CheminsF1),
%     write(CheminsF2).
%     % append([CheminsF1|CheminsF2], Noeud, Chemins).

% % Cas pour les nœuds de type beta
% chemins([Numero, beta, _, _, _, Fils1, Fils2], Chemins, Noeud) :-
%     del(Numero, Noeud, PNoeud),
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     chemins(Fils1, CheminsF1, [Num1|PNoeud]),
%     chemins(Fils2, CheminsF2, [Num2|PNoeud]),
%     write(CheminsF1),
%     write(CheminsF2).
%     % append([CheminsF1], Noeud, Chemins),
%     % append([CheminsF2], Noeud, Chemins).