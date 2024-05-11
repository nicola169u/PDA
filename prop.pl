% Définition des opérateurs personnalisés
:- op(900, fy, non).   % Opérateur unaire de négation
:- op(800, xfy, et).    % Opérateur 'et' (conjonction)
:- op(700, xfy, ou).    % Opérateur 'ou' (disjonction)
:- op(600, xfy, =>).    % Opérateur '=>' (implication)

% Prédicat principal du programme
estValide(F) :-
    transformer(F, Arbre),  % On transforme la formule F en un arbre Arbre
    (
        chemins(Arbre)  % On génère les chemins à partir de l'arbre
        ->  % Si les chemins sont valides
        writeln("\n\nLa formule est valide")
        ;   % Sinon, les chemins ne sont pas valides
        writeln("\n\nLa formule n est pas valide"),
        false
    ).

% Prédicat transformer/1 pour transformer une formule en un arbre avec numérotation en profondeur
transformer(F, Arbre) :-
    transformer(F, Arbre, 0, _, 0, '_'),
    writeln("Arbre obtenu :"),
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

estAtomique([_, _, _, _, _, nil, nil]).




% chemins(Arbre, CheminsAtomiques) :-
%     chemins([0], Arbre, [], ResultatsNonFiltres),
%     exclureNonAtomiques(ResultatsNonFiltres, CheminsAtomiques),
%     verifierCheminsAtomiques(CheminsAtomiques).

% Prédicat pour générer et afficher l'arbre des chemins
chemins(Arbre) :-
    chemins([0], Arbre, _).
    

% Cas de base : feuille de l'arbre (proposition atomique)
chemins(_, [_, _, _, _, _, nil, nil], _).

chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Final):-
    (Numero == 0 
        -> del(Numero, Noeud, PNoeud)
        ;  del([Numero, alpha, _, _, _, Fils1, Fils2], Noeud, PNoeud)
    ),
    append(PNoeud, [Fils1, Fils2], NewNoeud),
    (
        tousLesElementsAtomiques(NewNoeud)
        ->  % Si tous les éléments de NewNoeud sont atomiques
            write("Chemin atomique => "),
            writeln(NewNoeud),
            (
                \+verifierConnexion(NewNoeud)
                -> writeln("Connexion réussie pour ce noeud")
                ; true
            )
        ;   % Sinon, au moins un élément n'est pas atomique
            member(Elem, NewNoeud),  % Prendre un élément non atomique
            \+ estAtomique(Elem),     % Vérifier s'il n'est pas atomique
            chemins(NewNoeud, Elem, Final)  % Appeler récursivement pour cet élément
    ).

chemins(Noeud, [Numero, beta, _, _, _, Fils1, Fils2], Final):-
    del([Numero, beta, _, _, _, Fils1, Fils2], Noeud, PNoeud),
    append(PNoeud, [Fils1], NewNoeud1),
    append(PNoeud, [Fils2], NewNoeud2),
    (
        estAtomique(Fils1), estAtomique(Fils2)
        ->  % Si Fils1 et Fils2 sont atomiques
            (
                \+ estAtomique(NewNoeud1)   % Vérifier si NewNoeud1 n'est pas atomique
                ->
                (
                    nth0(0, NewNoeud1, Elem1),
                    nth0(1, NewNoeud1, Elem2),
                    chemins(NewNoeud1, Elem1, Final),
                    chemins(NewNoeud1, Elem2, Final)
                )
                ;
                true
            ),
            (
                \+ estAtomique(NewNoeud2)   % Vérifier si NewNoeud2 n'est pas atomique
                ->
                (
                    nth0(0, NewNoeud2, Elem3),
                    nth0(1, NewNoeud2, Elem4),
                    chemins(NewNoeud2, Elem3, Final),
                    chemins(NewNoeud2, Elem4, Final)
                )
                ;
                true
            )
        ;   % Sinon, au moins l'un des Fils n'est pas atomique
            (
                \+ estAtomique(Fils1)
                ->  chemins(NewNoeud1, Fils1, Final)
                ;   chemins(NewNoeud2, Fils2, Final)
            )
    ).




% % Cas de base : feuille de l'arbre (proposition atomique)
% chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Final) :-
%     (Numero == 0 
%         -> del(Numero, Noeud, PNoeud)
%         ; del([Numero, alpha, _, _, _, Fils1, Fils2], Noeud, PNoeud)
%     ),
%     append(PNoeud, [Fils1, Fils2], NewNoeud),
%     taille(NewNoeud, Taille),
%     tousLesElementsAtomiques(NewNoeud),  % Vérifie que tous les éléments de NewNoeud sont atomiques
%     writeln("Chemin atomique => "),
%     writeln(NewNoeud),
%     ( \+verifierConnexion(NewNoeud)
%       -> writeln("Connexion réussie pour ce nœud")
%       ; true
%     ).

% % Cas récursif : au moins un élément de NewNoeud n'est pas atomique
% chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Final) :-
%     (Numero == 0 
%         -> del(Numero, Noeud, PNoeud)
%         ; del([Numero, alpha, _, _, _, Fils1, Fils2], Noeud, PNoeud)
%     ),
%     append(PNoeud, [Fils1, Fils2], NewNoeud),
%     taille(NewNoeud, Taille),
%     \+ tousLesElementsAtomiques(NewNoeud),  % Vérifie qu'au moins un élément de NewNoeud n'est pas atomique
%     traiterElementsNonAtomiques(NewNoeud, Final).  % Traiter les éléments non atomiques de NewNoeud récursivement
    


% % Cas de base : feuille de l'arbre (proposition atomique)
% chemins(Noeud, [Numero, beta, _, _, _, Fils1, Fils2], Final) :-
%     del([Numero, beta, _, _, _, Fils1, Fils2], Noeud, PNoeud),
%     append(PNoeud, [Fils1], NewNoeud1),
%     append(PNoeud, [Fils2], NewNoeud2),
%     nth0(0, NewNoeud1, Elem1),
%     nth0(1, NewNoeud1, Elem2),
%     nth0(0, NewNoeud2, Elem3),
%     nth0(1, NewNoeud2, Elem4),
%     (   estAtomique(Fils1), estAtomique(Fils2)
%     ->  (   \+ estAtomique(Elem1), \+ estAtomique(Elem3)
%         ->  chemins(NewNoeud1, Elem1, Final),
%             chemins(NewNoeud2, Elem3, Final)
%         ;   chemins(NewNoeud1, Elem2, Final),
%             chemins(NewNoeud2, Elem4, Final)
%         )
%     ;   traiterElementsNonAtomiques([Elem1, Elem2, Elem3, Elem4], Final)
%     ).

% % Prédicat pour traiter les éléments non atomiques dans un nœud beta
% traiterElementsNonAtomiques([], _).
% traiterElementsNonAtomiques([Elem|Reste], Final) :-
%     (   \+ estAtomique(Elem)  % Vérifie si l'élément n'est pas atomique
%     ->  chemins(NewNoeud, Elem, Final)  % Appel récursif pour traiter cet élément
%     ;   traiterElementsNonAtomiques(Reste, Final)  % Sinon, passe à l'élément suivant
%     ).

    

% Prédicat pour calculer la taille d'une liste
taille([], 0). % Cas de base : la taille d'une liste vide est 0.
taille([_|Reste], Taille) :- taille(Reste, TailleReste), Taille is TailleReste + 1.

tousLesElementsAtomiques([Elem|Reste]):-
    estAtomique(Elem),
    tousLesElementsAtomiques(Reste).

tousLesElementsAtomiques([]).

verifierConnexion([]).
verifierConnexion([SousEnsemble|Reste]):-
    compareNoeudAvecSousEnsemble(SousEnsemble, Reste, ConnexionFormee),
    verifierConnexion(Reste),
    
    ( \+ ConnexionFormee ->
        writeln("formule invalide."),
        false % Si une connexion n'est pas formée dans un sous-ensemble, retourne false
        ;
        writeln("FORMULE VALIDE EH OH")
    ).

compareNoeudAvecSousEnsemble(_, [], false).
compareNoeudAvecSousEnsemble(Noeud, [Noeud2|Reste], ConnexionFormee):-
    ( formentConnexion(Noeud, Noeud2) ->
        write('Connexion : '), writeln([Noeud, Noeud2]),
        compareNoeudAvecSousEnsemble(Noeud, Reste, true)
    ;
        compareNoeudAvecSousEnsemble(Noeud, Reste, ConnexionFormee)
    ).


% Vérifie si deux nœuds forment une connexion
formentConnexion([_, _, _, Polarite1, ValeurNoeud1, _, _], [_, _, _, Polarite2, ValeurNoeud2, _, _]) :-
    Polarite1 \= Polarite2,
    ValeurNoeud1 == ValeurNoeud2.