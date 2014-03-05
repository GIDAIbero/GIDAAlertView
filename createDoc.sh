#!/bin/sh


if [ $# -lt 1 ]
then
	ACTION="--h"
else
	ACTION=$1
fi
if [ $# -eq 2 ]
then
	ACTION=$2
	case "$1" in
		'-u') OPTION='--keep-undocumented-objects --keep-undocumented-members --search-undocumented-doc'
			;;
		'-d') OPTION=''
			;;
		*) ACTION="--h"
			;;
	esac
else
	OPTION='--keep-undocumented-objects --keep-undocumented-members --search-undocumented-doc'
fi
echo $2 $1 $# $ACTION $OPTION
case "$ACTION" in
'Apple') echo "Apple Documentation, saved to Xcode"
	appledoc --project-name GIDAAlertView --project-company "GIDAIbero" --company-id mx.uia.ie $OPTION --exit-threshold 2 --no-repeat-first-par GIDAAlertView.h
	;;
'HTML')	echo "HTML"
	appledoc --project-name GIDAAlertView --project-company "GIDAIbero" --company-id mx.uia.ie $OPTION --exit-threshold 2 --no-create-docset --no-repeat-first-par GIDAAlertView.h
	;;
'--h') echo "Usage: $0 <Option> [Apple|HTML]\nOption:\n\t-u Include undocumented methods/properties\n\t-d Do not include undocumented methods/properties"
	;;
*) echo "Other"
	;;
esac
