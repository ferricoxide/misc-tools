# getglacierobjects

This script is designed primarily for ad hoc reporting purposes. It is intended to provide insight into an S3 bucket that has had a Glacier-enabled storage-lifecycle policy attached.

## Why this script

Even when configured with storage lifecycle policies, S3 buckets are not frequently configured with analytics or inventory jobs attached. Even when such jobs _are_ attached to an S3 bucket: 1) they can take anywhere from 24 hours to over a month to produce data within the AWS web UI; 2) even once set up and appearing within the AWS web UI, the data may be hours to days "stale". This tool allows a storage administrator to perform on-demand or ad hoc queries resulting in up to date data - whether the bucket has analytics enabled or not.

## Usage

This script currently written to pull run-time options from the shell environment. It so-configurable by way of the following env-settings:

* `REGION` (Optional): The AWS region in which to locate the target bucket. If not set, defaults to `us-east-1`.
* `PROFILE` (Optional): For use by storage administrators that manage multiple accounts/profiles. If not set, defaults to `default`. See AWS documentation for more information on AWS profiles.
* `PAGESZ` (Optional): Number of objects returned in a given "page" of returned query-data. If not set, defaults to `10000`. Note: it is not recommended to set the value higher than this as query-timeout likelihood increases markedly
* `MAXITM` (Optional): Number of objects requested in a given query. If not set, defaults to `100000`. Note: it is not recommended to set the value higher than this as query-timeout likelihood increases markedly.
* `QUERYBUCKET` (*Mandatory*): This is the name of the bucket to be queried. Do not include any URL notation (no `s3://` or `https://`). if not set, the program will exit.

The default values were selected as suitable compromises when dealing with high object-count buckets in fast AWS regions. Override via the above envs as specific bucket- and region-needs require.

Note: The above will be exposed as flag-options in future updates to this script.

To perform a query against a bucket named 'my-very-large-bucket' with default parameters, do:

~~~~
export QUERYBUCKET=my-very-large-bucket
/PATH/TO/getglacierobjects
~~~~

Output will be similar to the following:

~~~~
Chunking at 100000 objects per query
Chunk #1:          475091407888
Chunk #2:          475091407888 +    452005795003 =    927097202891 (863GiB)
Chunk #3:          927097202891 +    434300938987 =   1361398141878 (1267GiB)
Chunk #4:         1361398141878 +    467368241595 =   1828766383473 (1703GiB)
Chunk #5:         1828766383473 +    450511719731 =   2279278103204 (2122GiB)
Chunk #6:         2279278103204 +    433473901069 =   2712752004273 (2526GiB)
Chunk #7:         2712752004273 +    465946529414 =   3178698533687 (2960GiB)
Chunk #8:         3178698533687 +    449566519740 =   3628265053427 (3379GiB)
Chunk #9:         3628265053427 +    428518061489 =   4056783114916 (3778GiB)
Chunk #10:        4056783114916 +    473511050192 =   4530294165108 (4219GiB)
Chunk #11:        4530294165108 +    428944650453 =   4959238815561 (4618GiB)
Chunk #12:        4959238815561 +    477949524049 =   5437188339610 (5063GiB)
Chunk #13:        5437188339610 +    418912869754 =   5856101209364 (5453GiB)
Chunk #14:        5856101209364 +    487128889595 =   6343230098959 (5907GiB)
Chunk #15:        6343230098959 +    355190229936 =   6698420328895 (6238GiB)
Chunk #16:        6698420328895 +               0 =   6698420328895 (6238GiB)
All bucket-objects queried.
~~~~

Once the `All bucket-objects queried` line appears, take the last line of output: that is the size of the objects that have been lifecycled to Glacier.

### Caveats

This utility only has very loose error-handling. Use at your own risk.

### Additional

One can interrogate an S3 bucket for presence of lifecycle policies by executing a comand similar to:

~~~~
aws --profile dev --region us-east-1 s3api get-bucket-lifecycle-configuration --bucket artifactory-backups
~~~~

If a lifecycle has been attached to the bucket, output will be similar to the following where enabled.

~~~~
{
    "Rules": [
        {
            "Filter": {
                "Prefix": "Backups"
            },
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 14,
                    "StorageClass": "GLACIER"
                }
            ],
            "ID": "Altes-Zeug",
            "AbortIncompleteMultipartUpload": {
                "DaysAfterInitiation": 3
            }
        }
    ]
}
~~~~

If no lifecycle has been attached to the bucket, output similar to the following will occur:

~~~~
An error occurred (NoSuchLifecycleConfiguration) when calling the GetBucketLifecycleConfiguration operation: The lifecycle configuration does not exist
~~~~
