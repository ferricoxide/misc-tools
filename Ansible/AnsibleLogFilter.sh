#!/bin/bash
#
# Copyright (C) 2020 Thomas H Jones II (github@xanthia.com)
# Permission to copy and modify is granted under the Apache 2.0 license
# Last revised 2020-10-27
#
# AnsibleLogFilter.sh
#   A simple script to filter the output of Ansible log files into
#   something more-readable
#
# Usage:
#   AnsibleLogFilter.sh /log/file/location
#
###########################################################################
OUTFILE="${1:-/tmp/Ansible.log}"

# Read failures from log-file to bash array
mapfile -t ERROUT < <(
   grep ^failed: "${OUTFILE}"
)

# Make sure we got a mount-string
if [[ ${#ERROUT[@]} -lt 1 ]]
then
   echo "No failure-messages found in ${OUTFILE}"
fi

# Iterate over error-string
ITER=0
while [[ ${ITER} -lt ${#ERROUT[@]} ]]
do
   # Print out a header with the name of the failed item
   printf '##########\n## %s\n##########\n' "$(
      echo "${ERROUT[${ITER}]}" | sed 's/^failed:.* => //' | 
      python3 -c "import sys, json; print(json.load(sys.stdin)['item'])"
   )"
   
   # Use python to extract embedded JSON from the Ansible play's 'stderr' output
   echo "${ERROUT[${ITER}]}" | sed 's/^failed:.* => //' | \
     python3 -c "import sys, json; print(json.load(sys.stdin)['stderr'])" | \
     sed 's/^/    /'
     
   # Add a separator in case more than one failure is logged
   printf '####################\n\n\n'
   ITER=$(( ITER + 1 ))
done
