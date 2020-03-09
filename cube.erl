-module(cube).

-export([start/0]).

start() ->
    spawn(fun() -> init() end).

init() ->
    G = gs:start(),
    Window = gs:create(window, G, [{width, 600},
                                {height, 400},
                                {title, "Cube drawer"}]),
    create_canvas(Window),
    gs:create(entry, dimensions, Window, [{x, 10}, {y, 10}, {width, 50}, {text, "3"}]),
    Coords = create_coords(Window, 9),
    gs:create(button, draw_button, Window, [{x, 10}, {y, 300}, {label, {text, "Draw"}}]),
    gs:config(Window, {map, true}),
    loop(Window, Coords).

loop(Window, Coords) ->
    receive
        {gs, _, destroy, _, _} ->
            bye;
        {gs, draw_button, click, _, _} ->
            draw(Window, Coords),
            loop(Window, Coords)
    end.

draw(Window, Coords) ->
    gs:destroy(cube_canvas),
    create_canvas(Window),
    Dim = list_to_integer(gs:read(dimensions, text)),
    lines(Coords, Dim, 0, [], []).

lines(Coords, N, N, From, To) ->
    no_line;
lines(Coords, Dim, N, From, To) ->
    lines(Coords, Dim, N + 1, [0 | From], [0 | To]),
    lines1(Coords, Dim, N + 1, [0 | From], [1 | To]),
    lines(Coords, Dim, N + 1, [1 | From], [1 | To]).

lines1(Coords, N, N, From, To) ->
    line(Coords, From, To);
lines1(Coords, Dim, N, From, To) ->
    lines1(Coords, Dim, N + 1, [0 | From], [0 | To]),
    lines1(Coords, Dim, N + 1, [1 | From], [1 | To]).

line(Coords, L1, L2) ->
    {X1, Y1} = get_2d_coord(Coords, L1, 1, 0, 0),
    {X2, Y2} = get_2d_coord(Coords, L2, 1, 0, 0),
    gs:create(line, cube_canvas, [{coords, [{X1, Y1}, {X2, Y2}]}]).

get_2d_coord(Coords, [C | Cs], N, X, Y) ->
    X1 = X + C * get_coords(Coords, x, N),
    Y1 = Y + C * get_coords(Coords, y, N),
    get_2d_coord(Coords, Cs, N + 1, X1, Y1);
get_2d_coord(_Coords, [], _N, X, Y) ->
    {X, Y}.

create_canvas(Window) ->
    gs:create(canvas, cube_canvas, Window, [{x, 200},
                                            {y, 0},
                                            {width, 400},
                                            {height, 400},
                                            {bg, white}]).

create_coords(Window, MaxDim) ->
    lists:map(fun (N) ->
                      Y = 10 + 30 * N,
                      gs:create(label, Window, [{x, 10}, {y, Y}, {label, {text, "X:"}}, {width, 20}]),
                      IdX = gs:create(entry, Window, [{x, 30},
                                                     {y, Y},
                                                     {width, 50},
                                                     {text, "0"}]),
                      gs:create(label, Window, [{x, 110}, {y, Y}, {label, {text, "Y:"}}, {width, 20}]),
                      IdY = gs:create(entry, Window, [{x, 130},
                                                     {y, Y},
                                                     {width, 50},
                                                     {text, "0"}]),
                      {IdX, IdY}
             end,
              lists:seq(1, MaxDim)).

get_coords(Coords, x, N) ->
    {IdX, _} = lists:nth(N, Coords),
    list_to_integer(gs:read(IdX, text));
get_coords(Coords, y, N) ->
    {_, IdY} = lists:nth(N, Coords),
    list_to_integer(gs:read(IdY, text)).
