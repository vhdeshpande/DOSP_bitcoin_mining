%%% Bitcoin Mining Server
%%% Authors: 
%%% Vaibhavi Deshpande
%%% Ishan Kunkolikar
%%% September 2022

-module ( bitcoinMiningServer ).

-import ( string, [ concat/2, left/2, equal/2 ] ).
-import ( lists, [ duplicate/2, append/2 ] ).

-export( [ bitcoin_mining_server_start/1, get_bitcoin_str/0, bitcoin_mining_server_stop/0 ] ).

% NumOfZeros - number of preceding zeroes to be found in hash value
bitcoin_mining_server_start( NumOfZeroes ) ->
    WorkUnit = 10000,
    register( bitcoinMiningServer, spawn( fun() -> manange_client( NumOfZeroes, [], WorkUnit ) end  ) ),
    NumberOfLogProc = erlang:system_info( logical_processors_available ),
    ProcCount = 0,
    statistics( runtime ),
    statistics( wall_clock ),
    mine_with_distributed_sys( NumberOfLogProc*50, ProcCount, NumOfZeroes, WorkUnit ).

bitcoin_mining_server_stop() ->
    { _, Time1 } = statistics( runtime ),
    {_, Time2} = statistics(wall_clock),
    io:fwrite(  "CPU Runtime:" ),
    io:fwrite(  "~w",[ Time1 ] ),
    io:fwrite( "\t" ),
    io:fwrite(  "Real Time:" ),
    io:fwrite(  "~w",[ Time2 ] ),
    io:fwrite( "\n" ),
    unregister( bitcoinMiningServer ),
    exit( self(), ok ).

manange_client( NumOfZeroes, ClientList, WorkUnit ) ->
    receive
        { From, logon } ->
            NewClientList = append( ClientList,[ From ] ),
            From ! {NumOfZeroes, WorkUnit};
         { bitcoin, BitcoinStr, BitcoinHashVal } ->
            NewClientList = ClientList,
            print_bitcoin_output( BitcoinStr, BitcoinHashVal )
    end,
    manange_client( NumOfZeroes, NewClientList, WorkUnit ). 

% NumberOfLogProc - number of logical processors available
% ProcCount - process count
% NumOfZeros - number of preceding zeroes to be found in hash value
% WorkUnit - size of the work unit
 mine_with_distributed_sys( NumberOfLogProc, ProcCount, NumOfZeroes, WorkUnit ) ->
    if 
        ProcCount < NumberOfLogProc -> 
            ProcID = spawn( fun() -> mine( NumOfZeroes, WorkUnit ) end ),
            mine_with_distributed_sys( NumberOfLogProc, ProcCount+1, NumOfZeroes, WorkUnit);
        true ->
            continue
    end.    

% NumberOfCores - number of logical processors available
mine( NumOfZeroes, WorkUnit ) ->
    % Bitcoin hash value
    BitcoinStr =  get_bitcoin_str(),
    BitcoinHashVal = io_lib:format( "~64.16.0b", [ binary:decode_unsigned( crypto:hash( sha256, BitcoinStr ) ) ]),
    PreceedingChar = left( BitcoinHashVal,NumOfZeroes ),
    NumOfZeroesStr = lists:concat( lists:duplicate( NumOfZeroes, 0 ) ),
    HasPreceedingChar = equal( PreceedingChar, NumOfZeroesStr ),
    if 
        HasPreceedingChar -> 
            print_bitcoin_output( BitcoinStr, BitcoinHashVal );
        true ->
            continue
    end,
    mine( NumOfZeroes, WorkUnit-1 ).

% get bitcoin string prefixed with gatorlink ID
get_bitcoin_str() ->
    % String concatenate with gatorlink ID
    BitcoinStr =  concat( "deshpande.v;", base64:encode_to_string( crypto:strong_rand_bytes( 10 ) ) ),
    left( BitcoinStr,22 ).

% BitcoinStr - bitcoin string
% BitcoinHashVal - bitcoin hash value
print_bitcoin_output( BitcoinStr, BitcoinHashVal ) ->
    BitcoinStrOut =  concat( BitcoinStr, "          " ),
    Output =  concat( BitcoinStrOut, BitcoinHashVal ),
    io:fwrite( "~s~n", [ Output ] ).
