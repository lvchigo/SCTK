#!/bin/sh

usage="$0 <ctm validation script location> [-v]"

if [ $# -lt 1 ]; then
    echo $usage
    exit 1
fi

ctm=$1
exec=`file -L $ctm | perl -pe 's/.*?executable.*/1/'`
if [ "$exec" != '1' ]; then
    echo $usage
    exit 1
fi

if [ "$2" = '-v' ] ; then 
    verbose=true
else
    verbose=false
fi

for file in test*.ctm ; do
    echo "Testing $file..."
    base=`echo $file | perl -pe 's/.ctm//'`
    log="$base.log.saved"
    tmp="$base.log.tmp"
    
    if [ ! -f "$log" ] ; then
		perl $ctm -i $file > $log
    fi

    perl $ctm -i $file > $tmp
    diff_status=`diff $log $tmp | wc -l`

    if [ $diff_status -ne 0 ] ; then
		echo "   Output log differs from saved log"
		
		if [ $verbose = true ] ; then
			diff $log $tmp | sed 's/^/   /'
		fi
	else
		rm $tmp
    fi
done
