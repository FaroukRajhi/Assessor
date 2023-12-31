#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         09/21/20   Disable DVD or CD Sharing
# Edward Byrd         02/25/21   Updated with new commands
# Edward Byrd		  11/02/22	 Updated name of the script to conform to other sce
# 

dvdshare=$(
launchctl print-disabled system  | grep -c '"com.apple.ODSAgent" => disabled'
)

if [ $dvdshare -eq 1 ] ; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
