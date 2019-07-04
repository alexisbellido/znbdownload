znbdownload
=====================================================

Upload media files to S3 and add support for private files.

Features
------------------------------------------------------------------------------

-

Installing and Uninstalling Packages
------------------------------------------------------------------------------

Installing in editable mode from local directory.

.. code-block:: bash

  $ pip install -e /path/to/znbdownload/

You can remove the -e to install the package in the corresponding Python path, for example: /env/lib/python3.7/site-packages/znbdownload.

List installed packages and uninstall.

.. code-block:: bash

  $ pip list
  $ pip uninstall znbdownload

Installing from git using https.

.. code-block:: bash

  $ pip install git+https://github.com/requests/requests.git#egg=requests
  $ pip install git+https://github.com/alexisbellido/znbdownload.git#egg=znbdownload

This package could be added to a pip requirements.txt file from its git repository or source directory.

.. code-block:: bash

  git+https://github.com/alexisbellido/znbdownload.git#egg=znbdownload
  -e /path-to/znbdownload/

or from PyPi, in this case passing a specific version.

.. code-block:: bash

  znbdownload==0.2

ZnbDownload will require, and install if necessary, Django, boto3 and django-storages.

Updating Django Settings
---------------------------------------------------------------------------------------

Add the following to INSTALLED_APPS

.. code-block:: bash

  'znbdownload.apps.ZnbDownloadConfig'

Make sure these two are also installed.

.. code-block:: bash

  'storages'
  'django.contrib.staticfiles'


Amazon S3
-----------------------------------------------

Some notes to use S3 for storing Django files.

Cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain.

More on `S3 access permissions <https://docs.aws.amazon.com/AmazonS3/latest/dev/s3-access-control.html>`_.

Option 1 (preferred): Resource-based policy.

A bucket configured to be allow publc read access and full control by a IAM user that will be used from Django.

Create a IAM user. Write down the arn and user credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY).

Don't worry about adding a user policy as you will be using a bucket policy to refer to this user by its arn.

Create an S3 bucket at url-of-s3-bucket.

Assign it the following CORS configuration in the permissions tab.

.. code-block:: bash

  <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>Authorization</AllowedHeader>
    </CORSRule>
  </CORSConfiguration>

Go to permissions, public access settings for the bucket and set these options to false or you won't be able to use * as Principal in the bucket policy:

.. code-block:: bash

 Block new public ACLs and uploading public objects (Recommended)
 Remove public access granted through public ACLs (Recommended)
 Block new public bucket policies (Recommended)
 Block public and cross-account access if bucket has public policies (Recommended)


and the following bucket policy (use the corresponding arn for the bucket and for the IAM user that will have full control).

.. code-block:: bash

  {
      "Version": "2012-10-17",
      "Id": "name-of-bucket",
      "Statement": [
          {
              "Sid": "PublicReadForGetBucketObjects",
              "Effect": "Allow",
              "Principal": "*",
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::name-of-bucket/*"
          },
          {
              "Sid": "FullControlForBucketObjects",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::364908532015:user/name-of-user"
              },
              "Action": "s3:*",
              "Resource": [
                  "arn:aws:s3:::name-of-bucket",
                  "arn:aws:s3:::name-of-bucket/*"
              ]
          }
      ]
  }


Option 2: user policy.

A user configured to control an specific bucket.

Create an S3 bucket at url-of-s3-bucket.

Assign it the following CORS configuration in the permissions tab.

.. code-block:: bash

  <?xml version="1.0" encoding="UTF-8"?>
  <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
      <AllowedOrigin>*</AllowedOrigin>
      <AllowedMethod>GET</AllowedMethod>
      <MaxAgeSeconds>3000</MaxAgeSeconds>
      <AllowedHeader>Authorization</AllowedHeader>
  </CORSRule>
  </CORSConfiguration>

Create a user in IAM and assign it to this policy.

.. code-block:: bash

  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "Stmt1394043345000",
              "Effect": "Allow",
              "Action": [
                  "s3:*"
              ],
              "Resource": [
                  "arn:aws:s3:::url-of-s3-bucket/*"
              ]
          }
      ]
  }

Then create the user credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) to connect from Django.
