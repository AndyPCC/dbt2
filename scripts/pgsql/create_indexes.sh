#!/bin/sh

DIR=`dirname $0`
. ${DIR}/init_env.sh || exit 1

$PSQL -d dbt2 -c "create index i_orders on orders (o_w_id, o_d_id, o_c_id);" || exit 1
$PSQL -d dbt2 -c "create index i_customer on customer (c_w_id, c_d_id, c_last, c_first, c_id);" || exit 1

