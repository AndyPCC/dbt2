#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002 Mark Wong & Open Source Development Lab, Inc.
#

DIR=`dirname $0`
. ${DIR}/pgsql_profile || exit 1

USE_TABLESPACES=0
while getopts "t" OPT; do
	case ${OPT} in
	t)
		USE_TABLESPACES=1
		;;
	esac
done

if [ ${USE_TABLESPACES} -eq 1 ]; then
	TS_PK_WAREHOUSE_DIR="${TSDIR}/pk_warehouse/ts"
	TS_PK_DISTRICT_DIR="${TSDIR}/pk_district/ts"
	TS_PK_CUSTOMER_DIR="${TSDIR}/pk_customer/ts"
	TS_PK_NEW_ORDER_DIR="${TSDIR}/pk_new_order/ts"
	TS_PK_ORDERS_DIR="${TSDIR}/pk_orders/ts"
	TS_PK_ORDER_LINE_DIR="${TSDIR}/pk_order_line/ts"
	TS_PK_ITEM_DIR="${TSDIR}/pk_item/ts"
	TS_PK_STOCK_DIR="${TSDIR}/pk_stock/ts"
	TS_INDEX1_DIR="${TSDIR}/index1/ts"
	TS_INDEX2_DIR="${TSDIR}/index2/ts"

	#
	# Creating 'ts' subdirectories because PostgreSQL doesn't like that
	# 'lost+found' directory if a device was mounted at
	# '${TSDIR}/warehouse'.
	#
	mkdir -p ${TS_PK_WAREHOUSE_DIR} || exit 1
	mkdir -p ${TS_PK_DISTRICT_DIR} || exit 1
	mkdir -p ${TS_PK_CUSTOMER_DIR} || exit 1
	mkdir -p ${TS_PK_NEW_ORDER_DIR} || exit 1
	mkdir -p ${TS_PK_ORDERS_DIR} || exit 1
	mkdir -p ${TS_PK_ORDER_LINE_DIR} || exit 1
	mkdir -p ${TS_PK_ITEM_DIR} || exit 1
	mkdir -p ${TS_PK_STOCK_DIR} || exit 1
	mkdir -p ${TS_INDEX1_DIR} || exit 1
	mkdir -p ${TS_INDEX2_DIR} || exit 1

	TS_PK_WAREHOUSE="TABLESPACE dbt2_pk_warehouse"
	TS_PK_DISTRICT="TABLESPACE dbt2_pk_district"
	TS_PK_CUSTOMER="TABLESPACE dbt2_pk_customer"
	TS_PK_NEW_ORDER="TABLESPACE dbt2_pk_new_order"
	TS_PK_ORDERS="TABLESPACE dbt2_pk_orders"
	TS_PK_ORDER_LINE="TABLESPACE dbt2_pk_order_line"
	TS_PK_ITEM="TABLESPACE dbt2_pk_item"
	TS_PK_STOCK="TABLESPACE dbt2_pk_stock"
	TS_INDEX1="TABLESPACE dbt2_index1"
	TS_INDEX2="TABLESPACE dbt2_index2"

	#
	# Don't need to '|| exit 1' in case the tablespaces already exist.
	#
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_WAREHOUSE} LOCATION '${TS_PK_WAREHOUSE_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_DISTRICT} LOCATION '${TS_PK_DISTRICT_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_CUSTOMER} LOCATION '${TS_PK_CUSTOMER_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_NEW_ORDER} LOCATION '${TS_PK_NEW_ORDER_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_ORDERS} LOCATION '${TS_PK_ORDERS_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_ORDER_LINE} LOCATION '${TS_PK_ORDER_LINE_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_ITEM} LOCATION '${TS_PK_ITEM_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_PK_STOCK} LOCATION '${TS_PK_STOCK_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_INDEX1} LOCATION '${TS_INDEX1_DIR}';"
	${PSQL} -e -d ${DBNAME} -c "CREATE ${TS_INDEX2} LOCATION '${TS_INDEX2_DIR}';"

	#
	# Rewrite these variables for the actualy index creaxtion.
	#
	TS_PK_WAREHOUSE="USING INDEX ${TS_PK_WAREHOUSE}"
	TS_PK_DISTRICT="USING INDEX ${TS_PK_DISTRICT}"
	TS_PK_CUSTOMER="USING INDEX ${TS_PK_CUSTOMER}"
	TS_PK_NEW_ORDER="USING INDEX ${TS_PK_NEW_ORDER}"
	TS_PK_ORDERS="USING INDEX ${TS_PK_ORDERS}"
	TS_PK_ORDER_LINE="USING INDEX ${TS_PK_ORDER_LINE}"
	TS_PK_ITEM="USING INDEX ${TS_PK_ITEM}"
	TS_PK_STOCK="USING INDEX ${TS_PK_STOCK}"
fi

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE warehouse
ADD CONSTRAINT pk_warehouse PRIMARY KEY (w_id) ${TS_PK_WAREHOUSE};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE district
ADD CONSTRAINT pk_district PRIMARY KEY (d_w_id, d_id) ${TS_PK_DISTRICT};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE customer
ADD CONSTRAINT pk_customer PRIMARY KEY (c_w_id, c_d_id, c_id) ${TS_PK_CUSTOMER};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE new_order
ADD CONSTRAINT pk_new_order PRIMARY KEY (no_w_id, no_d_id, no_o_id) ${TS_PK_NEW_ORDER};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE orders
ADD CONSTRAINT pk_orders PRIMARY KEY (o_w_id, o_d_id, o_id) ${TS_PK_ORDERS};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE order_line
ADD CONSTRAINT pk_order_line PRIMARY KEY (ol_w_id, ol_d_id, ol_o_id, ol_number) ${TS_PK_ORDER_LINE};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE item
ADD CONSTRAINT pk_item PRIMARY KEY (i_id) ${TS_PK_ITEM};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
ALTER TABLE stock
ADD CONSTRAINT pk_stock PRIMARY KEY (s_w_id, s_i_id, s_quantity) ${TS_PK_STOCK};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
CREATE INDEX i_orders ON orders (o_w_id, o_d_id, o_c_id) ${TS_INDEX1};
" || exit 1 &

${PSQL} -e -d ${DBNAME} -c "
CREATE INDEX i_customer ON customer (c_w_id, c_d_id, c_last, c_first, c_id) ${TS_INDEX2};
" || exit 1 &

wait

exit 0
