************************
Sub-selected inventories
************************

A sub-selected inventory is a filtered view o another inventory.

Let’s take the following simple networks.yml configuration representing a single inventory:

.. code-block:: yaml

   ---
   :myinventory:
     :description: A full list of my servers
     :type: inventory

     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

     :ec2_filters:
       :instance-state-name: running

We’ll expand the example to create a second inventory, sub-selected from the first, where we filter on our EC2 instance tags.

In our example we’ll expect a tag called 'function' and we’ll supply the filter with an array of values as follows: 'app_server', 'proxy_server':

.. code-block:: yaml

   ---
   :mycollection:
     :description: Collection containing two inventories
     :type: collection
     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1
     :ec2_filters:
       :instance-state-name: running

   :mycollection:myinventory:
     :description: A full list of my servers
     :type: inventory

   :mycollection:mysubselect:
     :description: A sub-selected inventory
     :type: inventory-subselect
     :subselect_from: myinventory
     :filters:
       :by_tag:
         :function:
         - app_server
         - proxy_server

The above configuration will create a inventory called mysubselect, listing only those servers tagged with a key called 'function', with values of app_server or proxy_server.

Note that when referencing any other namespace in bcome e.g.

.. code-block:: yaml

   ...
   :subselect_from: myinventory
   ...

that the base namespace key (in this case 'my_collection'), is implicit.

Note also that you may subselect from any other namespace, irrespective of where it resides in your overall Bcome namespace scheme.
