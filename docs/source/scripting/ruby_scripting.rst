********************
Basic ruby scripting
********************

Overview
========

Bcome lets you write pure Ruby scripts that can interact with your installation. Using this you can:

* interact programmatically with your namespaces and their resources
* access all features of Bcome that are otherwise accessible from the shell or by keyed-access

Basic ruby scripts are not integrated directly into your Bcome framework, and are executed as standalone scripts. Within these scripts you expressely define the namespaces with which you wish to interact.

This will allow you also to integrate Bcome functionality into your other Ruby projects.

Basics
======

Network configuration
^^^^^^^^^^^^^^^^^^^^^

Let’s assume that we have the following basic network configuration:

.. code-block:: bash

    root (collection)
      |- staging (inventory)
        |- app1 (server)
        |- app2 (server)

We have a single collection, containing a single inventory, containing two application servers.

Script requirements
^^^^^^^^^^^^^^^^^^^

At the top of your ruby script, you’ll need the following:

.. code-block:: ruby

   require 'bcome'

   ORCH = Bcome::Orchestrator.instance
   # ORCH is an instance of Bcome’s Orchestrator that allows us to retrieve namespaces.

Let’s expand our script to load in the staging inventory:

.. code-block:: ruby

   require 'bcome'
   ORCH = Bcome::Orchestrator.instance

   inventory = ORCH.get("staging")

Note that the root namespace is implicit.

If we wanted to load in app1 we would do the following:

.. code-block:: ruby

   ...
    app1 = ORCH.get("staging:app1")
   ...

Executing a script
==================

Ruby script execution is the same as for any other Ruby script:

.. code-block:: bash

   > ruby path/to/your/script.rb

Methods
=======

Every method available within Bcome for a given namespace is available to the namespaces retrieved within your scripts (see the command list for a full list).

Remember that to list all integrated Bcome functions for a given namespace, you can invoke the menu function, i.e.

.. code-block:: ruby

   require 'bcome'
   ORCH = Bcome::Orchestrator.instance
   inventory = ORCH.get("staging")
   inventory.menu

If you’ve defined your own registry commands, then these will also be available.

You can show your configured registry methods for a given namespace by invoking the registry function, i.e.

.. code-block:: ruby

   ORCH = Bcome::Orchestrator.instance
   inventory = ORCH.get("staging:app1")
   inventory.registry

Accessors
=========

The following accessors are the most useful & commonly used:

For all namespaces
^^^^^^^^^^^^^^^^^^

keyed_namespace - returns a string representing the namespace’s Bcome breadcrumb

identifier - returns a string representing the namespace’s identifier

resources - returns an array of all resources belonging to a namespace, e.g. all the servers belonging to an inventory.

description - the description for the namespace from the network configuration,

type - the namespace type

meta - all configured metadata for this namespace level. See using metadata for more information.

proxy - returns the proxy object associated with a given namespace (if proxied SSH access has been configured)

For sub-selected inventories
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

parent - returns the parent inventory from which the sub-selected inventory is derived.

For servers
^^^^^^^^^^^

public_ip_address - returns the public IP address, if configured

internal_ip_address - returns the internal IP address, if configured.

ssh_driver.proxy - returns a Ruby Net::SSH::Proxy::Command object if your namespace has a proxy connection configured. This is useful should you wish to re-use your proxy settings in an external script, e.g. within a Capistrano deployment.

tags - returns all configured remote tags. See using tags for more information.

for all inventory types
^^^^^^^^^^^^^^^^^^^^^^^

machine_by_identifier(“servername”) - load up a server by name from your inventory. Returns a server node.

Accessing Metadata
==================

The metadata framework makes all metadata available to your ruby scripts.

To list metadata
^^^^^^^^^^^^^^^^

.. code-block:: bash

   ORCH = Bcome::Orchestrator.instance
   inventory = ORCH.get("staging:app1")
   inventory.meta

To retrieve metadata
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash
  
    ORCH = Bcome::Orchestrator.instance
    inventory = ORCH.get("staging:app1")
    value = inventory.metadata.fetch(:key)

See the metadata guide for more information on configuring and using metadata: :doc:`../orchestration/metadata_framework`

