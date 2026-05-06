
parent(alice, charlie).
parent(alice, diane).

parent(bob, charlie).
parent(bob, diane).

parent(emily, gregory).
parent(emily, harry).

parent(fred, gregory).
parent(fred, harry).
parent(fred, oscar).

parent(diane, ian).
parent(diane, jack).
parent(diane, kevin).

parent(gregory, ian).
parent(gregory, jack).
parent(gregory, kevin).

parent(kevin, michael).
parent(kevin, norman).

parent(linda, michael).
parent(linda, norman).

woman(alice).
woman(diane).
woman(emily).
woman(linda).

man(bob).
man(charlie).
man(fred).
man(gregory).
man(harry).
man(oscar).
man(ian).
man(jack).
man(kevin).
man(michael).
man(norman).


% Правило для поиска тёти и племянницы
aunt_niece(Aunt, Niece) :-
    woman(Aunt),
    woman(Niece),
    parent(Parent, Niece),
    parent(Grandparent, Parent),
    parent(Grandparent, Aunt),
    Aunt \= Parent.


% Предикат main собирает все пары и выводит их на экран
main :-
    % setof собирает все уникальные пары (Aunt, Niece) в список Pairs
    (   setof((Aunt, Niece), aunt_niece(Aunt, Niece), Pairs)
    ->  write('Найденные пары "Тетя - Племянница":'), nl,
        print_pairs(Pairs)
    ;   write('В данной базе пар "Тетя - Племянница" не найдено.'), nl
    ).
% печать
print_pairs([]).
print_pairs([(Aunt, Niece) | Tail]) :-
    format('- Тетя: ~w, Племянница: ~w~n', [Aunt, Niece]),
    print_pairs(Tail). % Рекурсивный вызов для оставшейся части списка

% Команда автоматического запуска (для SWI-Prolog)
:- initialization(main).
