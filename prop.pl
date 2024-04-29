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

% Prédicat pour générer et afficher l'arbre des chemins
generate_paths_tree(Arbre) :-
    generate_paths_tree(Arbre, [], Chemins),
    write_paths_tree(Chemins).

% Cas de base : si l'arbre est une feuille, on renvoie une liste contenant une seule feuille
generate_paths_tree([Numero, _, _, _, _, nil, nil], Chemins, [Chemins]) :-
    atomic(Numero).

% Cas pour les nœuds de type alpha : on ajoute le numéro du nœud à la liste de chemins
generate_paths_tree([Numero, alpha, _, _, _, ArbreF1, ArbreF2], Chemins, Paths) :-
    generate_paths_tree(ArbreF1, [Numero | Chemins], Paths1),
    generate_paths_tree(ArbreF2, [Numero | Chemins], Paths2),
    append(Paths1, Paths2, Paths).

% Cas pour les nœuds de type beta : on explore les deux fils séparément
generate_paths_tree([_, beta, _, _, _, ArbreF1, ArbreF2], Chemins, Paths) :-
    generate_paths_tree(ArbreF1, Chemins, Paths1),
    generate_paths_tree(ArbreF2, Chemins, Paths2),
    append(Paths1, Paths2, Paths).

% Prédicat pour afficher l'arbre des chemins
write_paths_tree([]).
write_paths_tree([Chemin | Chemins]) :-
    write_path(Chemin),
    nl,
    write_paths_tree(Chemins).

write_path([]) :- write('').
write_path([Chemin | Chemin]) :-
    write(Chemin),
    write(' -> '),
    write_path(Chemin).



% afficher_arbre_chemins(Arbre) :-
%     afficher_arbre_chemins(Arbre, [], Chemins),
%     afficher_chemins(Chemins).

% afficher_arbre_chemins([], _, []).
% afficher_arbre_chemins([Index, beta, _, _, _, Fils1, Fils2], Chemins, [Index|NouveauxChemins]) :-
%     !,
%     afficher_arbre_chemins(Fils1, [Index|Chemins], Chemins1),
%     afficher_arbre_chemins(Fils2, [Index|Chemins], Chemins2),
%     append(Chemins1, Chemins2, NouveauxChemins).

% afficher_arbre_chemins([Index, alpha, _, _, _, Fils1, Fils2], Chemins, [Index|NouveauxChemins]) :-
%     !,
%     append(Chemins, [Index], NouveauxChemins),
%     afficher_arbre_chemins(Fils1, [Index|Chemins], Chemins1),
%     afficher_arbre_chemins(Fils2, [Index|Chemins], Chemins2).

% afficher_arbre_chemins([_, _, _, _, _, Fils1, Fils2], Chemins, NouveauxChemins) :-
%     !,
%     afficher_arbre_chemins(Fils1, Chemins, Chemins1),
%     afficher_arbre_chemins(Fils2, Chemins, Chemins2),
%     append(Chemins1, Chemins2, NouveauxChemins).

% afficher_chemins(Chemins) :-
%     afficher_chemins(Chemins, 0).

% afficher_chemins([], _).
% afficher_chemins([Index|Chemins], Profondeur) :-
%     afficher_indentation(Profondeur),
%     write('a'),
%     write(Index),
%     nl,
%     succ(Profondeur, NouvelleProfondeur),
%     afficher_chemins(Chemins, NouvelleProfondeur).

% afficher_indentation(0) :- !.
% afficher_indentation(Profondeur) :-
%     write('| '),
%     succ(NouvelleProfondeur, Profondeur),
%     afficher_indentation(NouvelleProfondeur).

