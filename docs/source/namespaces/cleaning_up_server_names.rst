************************
Cleaning up server names
************************

You might well be pre-pending your EC2 instance names with a prefix that specifies their context e.g. you may have machines named like this: “Productionapp1”

That’s all well and good, but when browsing in Bcome, the context for your servers should be apparent from how you’ve defined their groupings in your configuration.

You can add the following key at inventory level to your config file:

.. code-block:: yaml

   :override_identifier: Production(.+)

The override_identifier key takes a regular expression used to clean up your instance names.

The above example would change “Productionapp1” to “app1” within bcome.

See an example of this in the configuration below, where 'inventory1' rewrites its servers' names:

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
     :override_identifier: Production(.+)

   :estate:inventory2:
     :type: inventory
     :description: "Region 2: eu-west"
     :network:
       :provisioning_region: eu-west-1

The utility of this will become apparent later when you start looking at how to interact with machines.

