#!/bin/sh

DIR=`dirname $0`
. ${DIR}/init_env.sh || exit

while getopts "i:o:s:" opt; do
	case $opt in
	i)
		ITERATIONS=$OPTARG
		;;
	o)
		OUTPUT_DIR=$OPTARG
		;;
	s)
		SAMPLE_LENGTH=$OPTARG
		;;
	esac
done

# Get database version.
$PSQL --version >> $OUTPUT_DIR/readme.txt

# Get database parameters.
$PSQL -d dbt2 -c "show all"  > $OUTPUT_DIR/param.out

# Get indexes.
$PSQL -d dbt2 -c "select * from pg_stat_user_indexes;" -o $OUTPUT_DIR/indexes.out

# Get the plans before the test.
bash @abs_top_srcdir@/scripts/pgsql/db_plans.sh -o $OUTPUT_DIR/plan0.out

COUNTER=0

while [ $COUNTER -lt $ITERATIONS ]; do
	$PSQL -d dbt2 -c "SELECT relname,pid, mode, granted FROM pg_locks, pg_class WHERE relfilenode = relation;" >> $OUTPUT_DIR/lockstats.out
	$PSQL -d dbt2 -c "SELECT * FROM pg_locks WHERE transaction IS NOT NULL;" >> $OUTPUT_DIR/tran_lock.out
	$PSQL -d dbt2 -c "SELECT * FROM pg_stat_activity;" >> $OUTPUT_DIR/db_activity.out
	$PSQL -d dbt2 -c "SELECT * FROM pg_stat_database WHERE datname ='dbt2';" >> $OUTPUT_DIR/db_load.out
	$PSQL -d dbt2 -c "SELECT relid, relname, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit FROM pg_statio_user_tables;" >> $OUTPUT_DIR/table_info.out
	$PSQL -d dbt2 -c "SELECT relid, indexrelid, relname, indexrelname, idx_blks_read, idx_blks_hit FROM pg_statio_user_indexes;" >> $OUTPUT_DIR/index_info.out
	$PSQL -d dbt2 -c "SELECT * FROM pg_stat_user_tables;" >> $OUTPUT_DIR/table_scan.out
	$PSQL -d dbt2 -c "SELECT * FROM pg_stat_user_indexes;" >> $OUTPUT_DIR/indexes_scan.out

	COUNTER=$(( $COUNTER+1 ))
	sleep $SAMPLE_LENGTH
done

# Get the plans after the test.
bash db_plans.sh -o $OUTPUT_DIR/plan1.out
