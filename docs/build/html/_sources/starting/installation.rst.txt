************
Installation
************

Project structure
=================

First off, you'll need to create your project directory structure

You require a Linux or Unix system with Ruby installed, following which from your command line

Create a directory for your project -

.. code-block:: bash

   mkdir project

Within your project directory install the Bcome gem -

.. code-block:: bash

   cd project
   project> gem install bcome

or add gem ‘bcome’ to your Gemfile and then -

.. code-block:: bash

   project> bundle install

and now create a directory for your Bcome configuration -

.. code-block:: bash

   project> mkdir bcome

Within your project directory create an empty yaml file within which your network configuration will live -

.. code-block:: bash

   project> cd bcome
   bcome> touch networks.yml

Your project directory should look as follows:

.. code-block:: bash

   ~> project
     - bcome
       - networks.yml


Cloud integration
=================

Currently Bcome works with a single cloud provider: AWS.

AWS configuration is achieved by linking an AWS IAM user with your local instance of the Bcome client.

Generate an AWS access key and secret access key
------------------------------------------------

Within your AWS account, generate a secret key & secret access key for the IAM user you wish to link to Bcome.

This IAM user should have:

* Programmatic access to the AWS API
* The minimum policy of: AmazonEC2ReadOnlyAccess

Have a look here_ for an AWS guide on how to do this.

.. _here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

The Bcome framework will use this key & secret in order to conduct queries against Amazon's EC2 API.  This allows Bcome to populate your instance with resources from your account.

Note that if you add custom orchestration to Bcome that requires access to features other than EC2, you will of course need to augment the permissions available to your IAM user.

Add your AWS keys to your bcome project
---------------------------------------

You will need to create a file named .fog in your user’s home directory -

.. code-block:: bash

   ~/.fog

Within this fog file, create a key to reference your AWS account e.g. awsreferencekey

And then within your .fog add in the following yaml:

.. code-block:: yaml

   ---
   awsreferencekey:
      aws_access_key_id: [your access key]
      aws_secret_access_key: [your secret access key]

Configuring multiple AWS accounts
---------------------------------

Bcome doesn’t just work with single AWS accounts - you may configure as many as you like. This allows you to work with machines from disparate accounts from the same project.

This is simple to setup. Given a second AWS account referenced by the key secondawsreferencekey, your .fog file would look as follows:

.. code-block:: yaml

   ---
   awsreferencekey:
     aws_access_key_id: [your access key]
     aws_secret_access_key: [your secret access key]
   secondawsreferencekey:
     aws_access_key_id: [second access key]
     aws_secret_access_key: [second secret access key]

