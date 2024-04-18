%%% Bitcoin Mining Server
%%% Authors: 
%%% Vaibhavi Deshpande
%%% Ishan Kunkolikar
%%% September 2022

-module ( bitcoinMiningClient ).
-import ( string,[ concat/2, left/2, equal/2 ] ).
-export( [ bitcoin_mining_client_start/1, bitcoin_mining_client_stop/0 ] ).

% ServerAddresss - server address
bitcoin_mining_client_start( ServerAddress ) ->
    { bitcoinMiningServer, ServerAddress } ! { self(), logon },
    receive
        { NumOfZeroes, WorkUnit } ->
            NumberOfLogProc = erlang:system_info( logical_processors_available ),
            ProcCount = 0,
            statistics( runtime ),
            statistics( wall_clock ),
            mine_with_distributed_sys( NumberOfLogProc*50, ProcCount, NumOfZeroes, WorkUnit, ServerAddress )
    end.

bitcoin_mining_client_stop() ->
    % CPU Time
    { _, Time1 } = statistics( runtime ),
    %  Actual Runntime
    {_, Time2} = statistics(wall_clock),
    io:fwrite(  "~w",[ Time1 ] ),
    io:fwrite( "\t" ),
    io:fwrite(  "~w",[ Time2 ] ),
    io:fwrite( "\n" ),
    exit( self(), ok ).

% NumberOfLogProc - number of logical processors available
% ProcCount - process count
% NumOfZeros - number of preceding zeroes to be found in hash value
% WorkUnit - size of the work unit
% ServerAddresss - server address
mine_with_distributed_sys( NumberOfLogProc, ProcCount, NumOfZeroes, WorkUnit, ServerAddress ) ->
    if 
        ProcCount < NumberOfLogProc -> 
            ProcID = spawn( fun() -> mine( NumOfZeroes, WorkUnit, ServerAddress ) end ),
            io:fwrite( "~p~n", [ ProcID ] ),
            mine_with_distributed_sys( NumberOfLogProc, ProcCount+1, NumOfZeroes, WorkUnit, ServerAddress);
        true ->
            continue
    end.    

% NumberOfCores - number of logical processors available
% WorkUnit - size of the work unit
% ServerAddresss - server address
mine( NumOfZeroes, WorkUnit, ServerAddress ) ->
    % Bitcoin hash value
    BitcoinStr =  get_bitcoin_str(),
    BitcoinHashVal = io_lib:format( "~64.16.0b", [ binary:decode_unsigned( crypto:hash( sha256, BitcoinStr ) ) ]),
    PreceedingChar = left( BitcoinHashVal,NumOfZeroes ),
    NumOfZeroesStr = lists:concat( lists:duplicate( NumOfZeroes, 0 ) ),
    HasPreceedingChar = equal( PreceedingChar, NumOfZeroesStr ),
    if 
        HasPreceedingChar -> 
           { bitcoinMiningServer, ServerAddress }  ! { bitcoin, BitcoinStr, BitcoinHashVal };
        true ->
            continue
    end,
    mine( NumOfZeroes, WorkUnit-1, ServerAddress ).

% get bitcoin string prefixed with gatorlink ID
get_bitcoin_str() ->
    % String concatenate with gatorlink ID
    BitcoinStr =  concat( "deshpande.v;", base64:encode_to_string( crypto:strong_rand_bytes( 10 ) ) ),
    left( BitcoinStr,22 ).
