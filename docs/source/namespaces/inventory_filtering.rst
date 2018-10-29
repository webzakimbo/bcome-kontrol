*******************
Inventory filtering
*******************

EC2 filter lookups
==================

AWS EC2’s full list of lookup-filtering options. may be integrated into your project.

Consider the following simple inventory setup:

.. code-block:: yaml

   ---
   "inventory"
     :description: "My test inventory"
     :type: inventory

     :network:
       :type: ec2
       :credentials_key: "awsreferencekey"
       :provisioning_region: us-east-1


Let’s add a filter to retrieve just the running instances:

.. code-block:: yaml

   ---
   "inventory"
     :description: "My test inventory"
     :type: inventory

     :network:
       :type: ec2
       :credentials_key: "awsreferencekey"
       :provisioning_region: us-east-1

     :ec2_filters:
       :instance-state-name: running

You may add any number of valid EC2 filters to the ec2_filters block in your networks.yml.

This leads to a lot of possibilities as to how you can filter your inventories:

* by VPC
* by architecture
* by instance state
* or by any other or any combination of any allowed filter

Note that if you’ve cached your server list and you make a subsequent change to your filters, you’ll need to reload and then re-save any affected inventory or you won’t be able to see your changes.

Tag-based filtering
===================

Tag-based filtering allows you to apply much more fine-tuning to your inventory manifests than with ec2-filtering alone. This is because tags allow you to apply and then filter on your own domain-specific contexts.

For example, if you were to tag your machines by their function, you would then be able to create inventory manifests by function, and so on.

We cannot express enough how useful tags are in AWS, and highly recommend that you tag your instances.

Visualising your tags within Bcome
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bcome allows you view all the tags added to any given instance.

The 'tags' command when invoked in a server namespace will list out all configured EC2 tags.

.. code-block:: bash

   > bcome collection:inventory:myserver:tags

Note also that as for all bcome commands, you may enter the shell and view the tags from there:

.. code-block:: bash

   > bcome collection:inventory:server
   > tags

Applying tag filters to your network.yml namespaces
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Consider a collection containing two inventories, both inventories containing servers from the same ec2 provisioning region as follows:


.. code-block:: yaml

   ---
   :my_application:
     :description: Parent Collection
     :type: collection
  
     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

     :ec2_filters:
       :instance-state: running

   :my_application:staging:
      :description: My staging servers
      :type: inventory

   :my_application:production:
      :description: My production servers
      :type: inventory


The above could represent two different application environments, hosted in the same provisioning regions.

Imagine you have your production servers tagged with a tag named “stage” and a value of “production” in your production environment, and “staging” in your staging environment.

Applying tag-based filters to represent the above scenario would require a configuration as follows:


.. code-block:: yaml

   ---
   :my_app:
     :description: Parent collection
     :type: collection

     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

     :ec2_filters:
       :instance-state-name: running

   :my_app:staging:
     :description: my staging servers
     :type: inventory
     :ec2_filters:
       :tag:stage: staging

   :my_app:production:
     :description: my production servers
     :type: inventory
     :ec2_filters:
       :tag:stage: production

Note how tags are just just another type of ec2_filter - the key name being :tag:[your tag name]

Note also how :instance-state-name: running is inherited from the parent collection, and is also applied to the inventories below.

The example configuration above would give you two inventories, one returning your production machines, the other your staging machines.
