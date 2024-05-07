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




% chemins(Arbre, CheminsAtomiques) :-
%     chemins([0], Arbre, [], ResultatsNonFiltres),
%     exclureNonAtomiques(ResultatsNonFiltres, CheminsAtomiques),
%     verifierCheminsAtomiques(CheminsAtomiques).

% Prédicat pour générer et afficher l'arbre des chemins
chemins(Arbre) :-
    chemins([0], Arbre, Final).
    

% Cas de base : feuille de l'arbre (proposition atomique)
chemins(Noeud, [Numero, _, _, _, _, nil, nil], Final).

% Cas pour les nœuds de type alpha
chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Final) :-
    writeln(Numero),
    writeln(Noeud),
    getNumero(Fils1, Num1),
    getNumero(Fils2, Num2),
    del(Numero, Noeud, PNoeud),
    append(PNoeud, [Num1, Num2], NewNoeud),
    write(NewNoeud),
    write(" sous-ensemble obtenu à partir de "),
    write(Numero),
    nl,
    (
        futurFilsAtomique(Fils1)
        -> 
        chemins(NewNoeud, Fils2, Final1)
    ),
    (
    futurFilsAtomique(Fils2)
    -> 
    chemins(NewNoeud, Fils1, Final1)
    ).

    % ici aussi choisir quel fils mettre en fonction de s'il est atomique ou non car avec le type alpha on développe qu'une branche
    % donc pas nécessaire d'appeler deux fois chemins (après c'est ce que je pense, je peux me tromper)
    % (estAtomique(Fils1) ->
    %     (
    %         estAtomique(Fils2) ->
    %         Final = NewNoeud
    %         ;
    %         chemins(NewNoeud, Fils2, Final1)
    %     )
    %     ;
    %     chemins(NewNoeud, Fils1, Final1)
    % ).



% Cas pour les nœuds de type beta
chemins(Noeud, [Numero, beta, _, _, _, Fils1, Fils2], Final) :-
    write("Je suis beta et le numero "),
    write(Numero),
    write(" et je recois "),
    writeln(Noeud),
    getNumero(Fils1, Num1),
    getNumero(Fils2, Num2),
    del(Numero, Noeud, PNoeud),
    append(PNoeud, [Num1], NewNoeud1),
    append(PNoeud, [Num2], NewNoeud2),
    write(NewNoeud1),
    write("   Nouvelle branche à partir de "),
    write(" "),
    write(Numero),
    nl,
    write(NewNoeud2),
    write("   Nouvelle branche à partir de "),
    write(" "),
    write(Numero),
    nl,
    writeln(Fils1),
    writeln(Fils2),
    ( estAtomique(Fils1)
    ->
        write("il est atomique le "), 
        writeln(Num1),
        ( estAtomique(Fils2) -> 
        write("il est atomique le "), 
        writeln(Num2)
        ;
        write("il est pas atomique le "), 
        writeln(Num2),
        chemins(NewNoeud2, Fils2, Final2)
        )
    ;
        write("il est pas atomique le "), 
        writeln(Num1),
        chemins(NewNoeud1, Fils1, Final1)
    ).
    % chemins(NewNoeud1, Fils1, Final1),
    % chemins(NewNoeud2, Fils2, Final2).


estAtomique([_,_, _, _, _, nil,nil]).

futurFilsAtomique([Numero, _, _, _, _, Fils1, Fils2]) :- 
    estAtomique(Fils1),
    estAtomique(Fils2).

% % Cas pour les nœuds de type alpha
% chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Acc, Resultats) :-
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     del(Numero, Noeud, PNoeud),
%     append(PNoeud, [Num1, Num2], NewNoeud),
%     write(NewNoeud),
%     write(" sous-ensemble obtenu à partir de "),
%     write(Numero),
%     nl,
%     chemins(NewNoeud, Fils1, Acc, Acc1),
%     chemins(NewNoeud, Fils2, Acc1, Resultats).

% % Cas pour les nœuds de type beta
% chemins(Noeud, [Numero, beta, _, _, _, Fils1, Fils2], Acc, Resultats) :-
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     del(Numero, Noeud, PNoeud),
%     append(PNoeud, [Num1], NewNoeud1),
%     append(PNoeud, [Num2], NewNoeud2),
%     write(NewNoeud1),
%     write("   Nouvelle branche à partir de "),
%     write(Numero),
%     nl,
%     write(NewNoeud2),
%     write("   Nouvelle branche à partir de "),
%     write(Numero),
%     nl,
%     chemins(NewNoeud1, Fils1, Acc, Acc1),
%     chemins(NewNoeud2, Fils2, Acc1, Resultats).







% Prédicat pour éliminer les doublons d'une liste
eliminerDoublons(Liste, ListeSansDoublons) :-
    eliminerDoublons(Liste, [], ListeSansDoublons).

eliminerDoublons([], Acc, Acc).
eliminerDoublons([X|Reste], Acc, ListeSansDoublons) :-
    member(X, Acc),
    !,
    eliminerDoublons(Reste, Acc, ListeSansDoublons).
eliminerDoublons([X|Reste], Acc, ListeSansDoublons) :-
    eliminerDoublons(Reste, [X|Acc], ListeSansDoublons).






% Vérifie si deux nœuds forment une connexion
formentConnexion([_, _, _, Polarite1, ValeurNoeud1, _, _], [_, _, _, Polarite2, ValeurNoeud2, _, _]) :-
    Polarite1 \= Polarite2,
    ValeurNoeud1 == ValeurNoeud2.

% Vérifie chaque paire de nœuds dans un sous-ensemble
verifierConnexions([], _).
verifierConnexions([Noeud1|Reste], SousEnsemble) :-
    writeln(Noeud1),
    comparerNoeudAvecSousEnsemble(Noeud1, SousEnsemble),
    verifierConnexions(Reste, SousEnsemble).

% Comparer un nœud avec chaque nœud dans un sous-ensemble
comparerNoeudAvecSousEnsemble(_, [], false).
comparerNoeudAvecSousEnsemble(Noeud, [Noeud2|Reste], ConnexionFormee) :-
    ( formentConnexion(Noeud, Noeud2) ->
        writeln('Connexion : '), writeln([Noeud, Noeud2]),
        comparerNoeudAvecSousEnsemble(Noeud, Reste, true)
    ;
        comparerNoeudAvecSousEnsemble(Noeud, Reste, ConnexionFormee)
    ).

% Vérifie chaque sous-ensemble de CheminsAtomiques
verifierCheminsAtomiques([]).
verifierCheminsAtomiques([SousEnsemble|Reste]) :-
    comparerNoeudAvecSousEnsemble(_, SousEnsemble, ConnexionFormee),
    ( ConnexionFormee ->
        verifierCheminsAtomiques(Reste)
    ;
        writeln('formule invalide.'),
        false % Si une connexion n'est pas formée dans un sous-ensemble, retourne false
    ).





% % Prédicat pour générer et afficher l'arbre des chemins
% chemins(Arbre, Resultats) :-
%     chemins([0], Arbre, Resultats).
    

% % Cas de base : feuille de l'arbre (proposition atomique)
% chemins(Noeud, [Numero, _, _, _, _, nil, nil], [Noeud]).

% % Cas pour les nœuds de type alpha
% chemins(Noeud, [Numero, alpha, _, _, _, Fils1, Fils2], Resultats) :-
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     del(Numero, Noeud, PNoeud),
%     append(PNoeud, [Num1, Num2], NewNoeud),
%     write(NewNoeud),
%     write(" sous-ensemble obtenu à partir de "),
%     write(Numero),
%     nl,
%     chemins(NewNoeud, Fils1, Resultat1),
%     chemins(NewNoeud, Fils2, Resultat2), 
%     append(Resultats1, Resultats2, ResultatsAlpha),
%     append([Noeud], ResultatsAlpha, Resultats).

% % Cas pour les nœuds de type beta
% chemins(Noeud, [Numero, beta, _, _, _, Fils1, Fils2], Resultats) :-
%     write(Noeud),
%     nl,
%     getNumero(Fils1, Num1),
%     getNumero(Fils2, Num2),
%     del(Numero, Noeud, PNoeud),
%     append(PNoeud, [Num1], NewNoeud1),
%     append(PNoeud, [Num2], NewNoeud2),
%     write(NewNoeud1),
%     write("   Nouvelle branche à partir de "),
%     write(Numero),
%     nl,
%     write(NewNoeud2),
%     write("   Nouvelle branche à partir de "),
%     write(Numero),
%     nl,
%     chemins(NewNoeud1, Fils1, Resultats1),
%     chemins(NewNoeud2, Fils2, Resultats2),
%     append(Resultats1, Resultats2, ResultatsBeta),
%     append([Noeud], ResultatsBeta, Resultats).





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