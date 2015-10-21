%% -------------------------------------------------------------------
%%
%% riakc_ts_put_operator.erl: helper functions for query requests to Riak TS
%%
%% Copyright (c) 2015 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc Helper functions for query requests to Riak TS

-module(riakc_ts_query_operator).

-include_lib("riak_pb/include/riak_pb.hrl").
-include_lib("riak_pb/include/riak_kv_pb.hrl").

-export([serialize/2,
         deserialize/1]).

serialize(QueryText, Interpolations) ->
    Content = #tsinterpolation{
                 base = QueryText,
                 interpolations = serialize_interpolations(Interpolations)},
    #tsqueryreq{query = Content}.

serialize_interpolations(Interpolations) ->
    serialize_interpolations(Interpolations, []).

serialize_interpolations([], SerializedInterps) ->
    SerializedInterps;
serialize_interpolations([{Key, Value} | RemainingInterps],
                         SerializedInterps) ->
    UpdatedInterps = [#rpbpair{key=Key, value=Value} | SerializedInterps],
    serialize_interpolations(RemainingInterps, UpdatedInterps).

deserialize({error, Message}) -> {error, Message};

deserialize(#tsqueryresp{columns = Columns_, rows = Rows_}) ->
    Columns = [C || #tscolumndescription{name = C} <- Columns_],
    Rows = riak_pb_ts_codec:decode_rows(Rows_),
    {Columns, Rows}.