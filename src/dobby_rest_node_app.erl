-module(dobby_rest_node_app).

-behaviour(application).
-behaviour(supervisor).

%% Application callbacks
-export([start/2, stop/1]).

%% Supervisor callbacks
-export([init/1]).

-define(DEFAULT_DOBBY_NODE, 'dobby@127.0.0.1').

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    try
        connect_to_dobby()
    catch
        throw:Reason ->
            {error, Reason}
    end,
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

stop(_State) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================

init([]) ->
    {ok, {{one_for_one, 5, 10}, []}}.

connect_to_dobby() ->
    DobbyNode = application:get_env(dobby_rest_node, dobby_node,
                                    ?DEFAULT_DOBBY_NODE),
    case net_adm:ping(DobbyNode) of
        pong ->
            lager:info("Connected to dobby node: ~p", [DobbyNode]);
        pang ->
            lager:error("Failed to connect to dobby node: ~p", [DobbyNode]),
            throw({connecting_to_dobby_failed, DobbyNode})
    end.
