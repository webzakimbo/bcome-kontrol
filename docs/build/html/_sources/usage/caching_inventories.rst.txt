*******************
Caching Inventories
*******************

Overview
========

You’ll notice a slight delay (varying depending on your internet connection) when loading into a Bcome inventory for the first time. This is because Bcome is making a call across the wire to EC2 to retrieve the server manifests matching your particular network configuration and filters.

You may cache these manifests for a speedier loading time.

Caching may only be applied to an inventory namespace, and can not be applied to a collection namespace. This will allow you to leave dynamic inventories (e.g. representing an auto-scaling group or some other scheme where your manifest is subject to regular change) uncached.

Note that examples in this section will utilise the reference network configuration detailed here.

How to cache
============

To enable caching, enter the namepace for a given inventory in shell mode and hit save.

e.g. to cache your staging inventory:

.. code-block:: bash

   > bcome staging
   root> staging> save

You will be prompted to confirm.

Should your server manifest change, you may reload the manifest from remote, and the re-cache as follows:

.. code-block:: bash

   > bcome staging
   root> staging> reload
   root> staging> save

Again, you will be prompted to confirm that you want to proceed

Caching sub-selected inventories
================================

A sub-selected inventory cannot be directly cached as it is generated as a sub-selection from a parent inventory. You must apply caching to the parent inventory to effect caching on a sub-selection namespace (and in the same vein, all re-caching must be applied to the parent).

Disabling a cache
=================

When a manifest is cached the following key is added to your network configuration file against the cached manifest:

.. code-block:: yaml

   ...
     :load_machines_from_cache: true
   ...

To disable a cache, remove this key-value pair entirely or set its value to false, and then re-save your networks.yml network configuration file. You’ll need to exit & re-enter any affected Bcome shells you may have open.
