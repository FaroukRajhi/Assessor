#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   07/01/22   Check user dot files permissions (mode)
# E. Pinnell   01/19/23   Modified to improve test and output

l_output="" l_output2=""
perm_mask="$XCCDF_VALUE_REGEX"
maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

while l_out="" read -r l_user l_home; do
	if [ -d "$l_home" ]; then
		while l_file="" read -r l_dfile; do
			mode=$( stat -L -c '%#a' "$l_dfile" )
			if [ $(( "$mode" & "$perm_mask" )) -gt 0 ]; then
				l_output2="$l_output2\n- User \"$l_user\" file: \"$l_dfile\" is too permissive: \"$mode\" (should be: \"$maxperm\" or more restrictive)\n"
			fi
		done <<< "$(find "$l_home" -type f -name '.*')"
	else
		l_output="$l_output\n- User \"$l_user\" home directory doesn't exist in \"/etc/passwd\"\n"
	fi
done <<< "$(awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"

# Report results. If no failures output in l_output2, we pass
if [ -z "$l_output2" ]; then
   echo -e "\n- Audit Result:\n  ** PASS **\n\nAll user dot files are \"$maxperm\" or more restrictive\n"
	[ -n "$l_output" ] && echo -e "\n ** WARNING **\n$l_output\n"
   exit "${XCCDF_RESULT_PASS:-101}"
else
   echo -e "\n- Audit Result:\n  ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
   [ -n "$l_output" ] && echo -e "\n ** WARNING **\n$l_output\n"
   exit "${XCCDF_RESULT_FAIL:-102}"
fi