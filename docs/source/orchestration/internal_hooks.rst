**************
Internal Hooks
**************

Introduction
============

If you haven’t already, read up on how the registry allows you to reference your own Ruby extensions to your Bcome framework installation, in the form of internal scripts.

This section deals with how you write these scripts.

The orchestration directory
===========================

Within your bcome project directory, create a directory named orchestration as follows:

.. code-block:: bash

   > project
      |- bcome
        |- networks.yml
        |- registry.yml
      |- orchestration

Bcome will expect to find all referenced orchestration scripts within this directory.

A simple orchestration example
==============================

Setup
^^^^^

Let’s say you have the following declaration within your registry.yml:

.. code-block:: yaml

   ---
   "foo:bar":
     - type: internal
       description: "synchronize puppet manifests"
       console_command: sync
       group: puppet
       orch_klass: PuppetSync

When you invoke foo:bar:sync, Bcome will expect to find a ruby file named puppet_sync.rb within /path/to/your/project/bcome/orchestration/

The puppet_sync.rb needs to look as follows:

.. code-block:: ruby

   Module Bcome::Orchestration
     class PuppetSync < Bcome::Orchestration::Base

       def execute
        ... your orchestration code
       end

     end
   end

Note that your orchestration script file must inherit from Bcome::Orchestration::Base

Accessing your namespace
^^^^^^^^^^^^^^^^^^^^^^^^

Within your script, Bcome makes an instance variable named '@node' available to you. This is an instance of your Bcome namespace.

For example, if you invoked the sync command from namespace foo:bar, where 'bar' is an inventory within collection 'foo', then @node will represent your 'foo' inventory.

You can then work with @node to implement your orchestration.

.. code-block:: ruby

   Module Bcome::Orchestration
     class PuppetSync < Bcome::Orchestration::Base

       def execute
         # @node = your namespace object
       end

     end
   end

What can you do with @node?
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Every method available within Bcome for a given namespace is available to the @node instance. See the command list for a full list.

A number of accessors are also available to you.

Passing Parameters
==================

Internal orchestration scripts can also take parameters. This is in the form of a hash, keyed on a variable called defaults, as follows:

.. code-block:: yaml

   ---
   "foo:bar":
     - type: internal
       description: "synchronize puppet manifests"
       console_command: sync
       group: puppet
       orch_klass: PuppetSync
       defaults:
         value1: "foo"
         value2: "bar"    

From your orchestration scripts, these defaults are accessible from an instance variable named @arguments. For example:

.. code-block:: ruby

   Module Bcome::Orchestration
     class PuppetSync < Bcome::Orchestration::Base

       def execute
         # @node = your namespace object
         # @arguments = { :value1 => "foo", :value2 => "bar" }
       end
     end
   end

As the naming suggests, these parameters are default parameters, and you can override them to pass in different values.

For example, to invoke the above using keyed access from your terminal, and defaulting to the default parameters you would:

.. code-block:: bash

   > bcome foo:bar:sync

And to override any of the parameters:

.. code-block:: bash

   > bcome foo:bar:sync value1=your-value 
   > bcome foo:bar:sync value2=your-value  
   > bcome foo:bar:sync value1=your-value value2=your-value

Remember that if you’re ever unsure as to how to invoke your orchestration klass, call up the 'registry' function for your namespace, and your commands and their usage will be shown:

.. code-block:: bash

   > bcome foo:bar:registry

Remember also that registry commands may also be triggered from the Bcome shell.

Invoking an orchestration klass from within another
===================================================

It is easy to invoke orchestration script from within another.

.. code-block:: ruby

   orchestrator = ::Bcome::Orchestration::MyOrchClass.new(node, arguments) 
   orchestrator.do_execute 

Traversing contexts
===================

Although internal scripts are called within the context of a specific namespace available from the @node instance variable, you are not restricted to working solely with this namespace.

For example: you may load in servers from inventory namespaces, or inventories from collection namespace. You may also directly load in unrelated namespaces using the Bcome::Orchestrator class.

See the basic ruby script usage for more information: :doc:`../scripting/ruby_scripting`
