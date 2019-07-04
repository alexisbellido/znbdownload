TODO
============================================

Use presigned URLs with PUT to allow uploading files https://docs.aws.amazon.com/AmazonS3/latest/dev/PresignedUrlUploadObject.html and probably keep the bucket private by default.

Presigned URLS to download https://docs.aws.amazon.com/AmazonS3/latest/dev/ShareObjectPreSignedURL.html
-------------

Uploading media works with `django-storages <https://django-storages.readthedocs.io/en/latest/backends/amazon-S3.html>`_ but ZnbDownload extends it to allow private files.


Move docs directory app and create directory structure to upload to PyPi..

An example of upload_to callback.

.. code-block:: bash

  def upload_avatar_to(instance, filename):
      import os
      from django.utils.timezone import now
      filename_base, filename_ext = os.path.splitext(filename)
      return 'profiles/%s%s' % (
          now().strftime("%Y%m%d%H%M%S"),
          filename_ext.lower(),
      )

  class Profile(models.Model):
      # ...
      avatar = models.ImageField(_("Avatar"), upload_to=upload_avatar_to, blank=True)
      # ...
      
  
Settings for private buckets
-----------------------------------------------

create bucket

Permissions > Block all public access Off

I'm keeping the bucket public and setting public or private at the object level via code.

Permissions > CORS

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

Permissions > Bucket policy

.. code-block:: bash

{
    "Version": "2012-10-17",
    "Id": "example-dev-private",
    "Statement": [
        {
            "Sid": "FullControlForBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::132:user/username"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::example-dev-private",
                "arn:aws:s3:::example-dev-private/*"
            ]
        }
    ]
}
