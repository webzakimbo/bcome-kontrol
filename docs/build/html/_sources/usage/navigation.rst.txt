**********
Navigation
**********

Basic Navigation
================

Bcome exposes two methods for navigating through your namespaces:

* direct access via a shell
* keyed accessed to your namespaces directly from the terminal


This section will illustrate the usage of just some of the commands available within the Bcome framework - just enough to get an understanding of how you would invoke them.

To view a list of all commands available within any namespace invoke either 'menu', for in-built Bcome framework commands, or 'registry', for commands you have defined yourself using Bcome’s orchestration framework.  You can invoke 'menu' or 'registry' for any Bcome breadcrumb (either inside or from outside the shell), e.g.

.. code-block:: bash

   > bcome foo:bar:menu

   > bcome foo:bar:registry


See the command list section for a full list of available in-built commands.


Shell access
============

Bcome exposes a REPL shell, built on top of Ruby’s IRB.

From your project directory, you may access it as follows:

.. code-block:: bash

   > bcome

This will take you into your root namespace.

To view a tree structure of your namespaces:

.. code-block:: bash

   root> tree

List your namespaces:

.. code-block:: bash

    root> ls

Enter the context of a second level namespace:

.. code-block:: bash

   root> cd staging
   root> staging> ...

List the servers present in your staging inventory:

.. code-block:: bash

   root> staging> ls

Navigate back up a namespace:

.. code-block:: bash

   root> staging> back

Exit out of the shell

.. code-block:: bash

   root> exit!

Keyed access
============

When you already know the Bcome breadcrumb, keyed access provides a useful shortcut for accessing either common commands, or entering directly into the Bcome shell at a particular namespace.

Keyed access to namespaces
^^^^^^^^^^^^^^^^^^^^^^^^^^

To access the staging namespace directly:

.. code-block:: bash

   > bcome staging

Or, given a server named app1 within the production namespace, you’d access it as follows:

.. code-block:: bash

   > bcome production:app1

Once within a namespace, invoke either the menu command (for in-built Bcome methods), or the registry command (for user-defined orchestration methods) to find out what you can do next.

Keyed access to commands
^^^^^^^^^^^^^^^^^^^^^^^^

Keyed access provides useful shortcuts for common commands.

Any Bcome command, either provided by the framework, or written by you and added to the command registry is available directly from the shell.

For example, to list all the servers in the qa namespace:

.. code-block:: bash

   > bcome qa:ls

Or to show all the menu options available for the production namespace

.. code-block:: bash

   > bcome production:menu

Or to SSH directly into app1 within the production namespace:

.. code-block:: bash

   > bcome production:app1:ssh

Or to access a method you’ve defined yourself and added to the command registry (in this case a method name foo, available within the context of inventory namespace qa):

.. code-block:: bash

   > bcome qa:foo
