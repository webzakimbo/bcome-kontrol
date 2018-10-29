**********************
Caching server lookups
**********************

There are two schemes for loading machines into the console: they may be cached, or loaded dynamically each time from the cloud. Although a dynamic load is useful for inventories representing short-lived or often-updated manifests (such as an auto-scaling group), in most cases, caching is preferable.

To cache the servers in a given inventory, enter the console and navigate to your desired namespace, and then hit save. To reload (should you wish to update your manifest), hit reload, and then save again.

.. code-block:: bash

   # caching
   > bcome path:to:your:inventory
   > save

   # reloading
   > bcome path:to:your:inventory
   > reload
   > save

When an inventory is cached it will populate a separate config file, machines-cache.yml in your Bcome configuration directory.

Note that you can only cache nodes within an inventory, and not within sub-selected inventories.

Cached inventories will cause a small change to your networks.yml file - your cached inventory will have been marked with the 'load_machines_from_cache' flag, as illustrated in the following example:

.. code-block:: yaml

   ---
   :collection:
     :description: Parent Collection
     :type: collection
     :network:
       :type: ec2
       :credentials_key: youraccount

   :collection:useast1:
     :description: Us East 1
     :type: inventory
     :network:
       :provisioning_region: us-east-1
     :load_machines_from_cache: true

   :collection:euwest1:
     :description: US East 2
     :type: inventory
     :network:
       :provisioning_region: us-west-1

Set this value to false or remove the key to unset caching.

