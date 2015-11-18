#!/bin/sh

LANG=en_US.utf8
crslogname="$CRS_ORA_HOME/log/`hostname`/crsd/crsd.log"

if [ -f $crslogname ];then
	cat $v_logname|grep -wE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' |egrep -v -i " connect failed, rc"> $log_dir/error.log;
			if [ `cat $log_dir/error.log|wc -l` -gt 0 ];then

					cat $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
				fi
fi
