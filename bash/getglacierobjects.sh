#!/bin/bash
#
# shellcheck disable=SC2016,SC2003
#
# Really ugly script to perform ad hoc storage-reporting against
# S3 buckets with lifecycle storage policies attached
#
#################################################################
REGION=${REGION:-us-east-1}
PROFILE=${PROFILE:-default}
PAGESZ=${PAGESZ:-10000}
MAXITM=${MAXITM:-100000}
BUCKET=${QUERYBUCKET:-UNDEF}
COUNT=0

GlacierCompute() {
   COUNT=$(( COUNT + 1))

   if [ "${1}" = "" ]
   then
      NXTOKN=$(
         aws --profile "${PROFILE}" --region "${REGION}" s3api list-objects-v2 \
	   --page-size "${PAGESZ}" --max-items "${MAXITM}" --bucket "${BUCKET}" \
	   --query 'NextToken' | sed 's/"//g'
      )
      SIZE=$(
         aws --profile "${PROFILE}" --region "${REGION}" s3api list-objects-v2 \
           --page-size "${PAGESZ}" --max-items "${MAXITM}" \
	   --bucket "${BUCKET}" \
	   --query 'Contents[?StorageClass==`GLACIER`].Size' |
           sed -e 's/,//' -e '/[][]/d' -e 's/^[  ][      ]//' -e '/^$/d' |
           awk '{ sum += $1 } END { print sum }'
      )

      printf "Chunk #%s: \t%15s\n" "${COUNT}" "${SIZE}"

      GlacierCompute "${NXTOKN}" "${SIZE}"
    else
      SIZE=$(
         aws --profile "${PROFILE}" --region "${REGION}" s3api list-objects-v2 \
           --starting-token "${NXTOKN}" \
           --page-size "${PAGESZ}" --max-items "${MAXITM}" \
	   --bucket "${BUCKET}" \
           --query 'Contents[?StorageClass==`GLACIER`].Size' |
           sed -e 's/,//' -e '/[][]/d' -e 's/^[  ][      ]//' -e '/^$/d' |
           awk '{ sum += $1 } END { print sum }'
      )
      NXTOKN=$(
         aws --profile "${PROFILE}" --region "${REGION}" s3api list-objects-v2 \
           --starting-token "${NXTOKN}" --page-size "${PAGESZ}" \
	   --max-items "${MAXITM}" --bucket "${BUCKET}" \
           --query 'NextToken' | sed 's/"//g'
      )
      if [ "${SIZE}" = "" ]
      then
         SIZE=0
      fi

      TOTSIZE=$(( $2 + SIZE ))
      TOTSIZEINK=$( expr "${TOTSIZE}" / 1024 )
      TOTSIZEINM=$( expr "${TOTSIZEINK}" / 1024 )
      TOTSIZEING=$( expr "${TOTSIZEINM}" / 1024 )
      printf "Chunk #%s: \t" "${COUNT}"
      printf "%15s + %15s + %15s (%sGiB)\n" "$2" "${SIZE}" "${TOTSIZE}" "${TOTSIZEING}"


      if [[ ${SIZE} -eq 0 ]]
      then
         echo "All bucket-objects queried."
      else
         GlacierCompute "${NXTOKN}" "${TOTSIZE}"
      fi
   fi
}


#######
## Main
#######

if [[ ${BUCKET} = UNDEF ]]
then
   echo "Please set the QUERYBUCKET environmental to proceed. Exiting."
fi

echo "Chunking at ${MAXITM} objects per query"
GlacierCompute ""
