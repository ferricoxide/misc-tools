#!/usr/bin/env python

import boto3

s3 = boto3.client('s3')

# Bucket name
b_name = '< bucket name >'

# Args for list
l_args = {'Bucket': b_name}

while True:
    # Get List response
    response = s3.list_objects_v2(**l_args)

    try:
        contents = response['Contents']
    except KeyError:
        break
    # Check for STANDARD_IA class and print if matches    
    for obj in contents:
        #print("Object key : %s" % obj['Key'])
        #print("Object StorageClass  : %s" % obj['StorageClass'])
        if obj['StorageClass'] == 'STANDARD_IA':
            print("Object data : \n %s" % obj)

    # Set token for while to continue as API call to list gets only 1k results        
    try:        
        l_args['ContinuationToken'] = response['NextContinuationToken']
    except KeyError:
        break
    #print(l_args['ContinuationToken'])
