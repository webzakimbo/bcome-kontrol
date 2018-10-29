*****************
Connecting clouds
*****************

Connecting your cloud account
=============================

How would you add connection details to your cloud provider so that bcome can populate your inventory with servers?

First of all, before starting this section make sure that you’ve configured your Bcome project for AWS: :doc:`../starting/installation`

Let’s now assume that our networks.yml configuration is incredibly simple and contains only a single inventory, as follows:

.. code-block:: yaml

   ---
   "inventory1":
     :description: "My inventory"
     :type: inventory

We’ll now add an EC2 network driver to the inventory.

Let’s assume that the credentials for your AWS accounts are keyed on a key called “awsreferencekey”, and that you want to retrieve machines from the us-east-1 provisioning region.

Here’s what the networks.yml would look like:

.. code-block:: yaml

   ---
   "inventory1":
     :description: "My inventory"
     :type: inventory
     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

If you’ve correctly configured your AWS credentials, and have machines in the provisioning region listed, you’ll be able to view a list of your servers in that region through bcome:

.. code-block:: bash

   ~> bcome ls


Let’s add another inventory so that we have two inventories, each referencing different EC2 regions.


.. code-block:: yaml

   ---
   estate:
     :type: collection
     :description: "My estate"

     :network:
       :type: ec2
       :credentials_key: awsreferencekey

   :estate:inventory1:
     :type: inventory
     :description: "Region 1: us-east" 
     :network:
       :provisioning_region: us-east-1

   :estate:inventory2:
     :type: inventory
     :description: "Region 2: eu-west"
     :network:
       :provisioning_region: eu-west-1


Try and retrieve a machine list for either inventory using bcome:

.. code-block:: bash

   ~> bcome inventory2:ls
   ~> bcome inventory1:ls

Note how the network parameters on the collection are inherited in the inventories below, which are then free to override or define as new the provisioning region (or any other key).

All Bcome configuration works in this way: allowing configuration inheritance down your defined namespaces.

