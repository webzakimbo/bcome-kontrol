****************
Interactive Mode
****************

Overview
========

Interactive mode allows you to enter repeated commands in a transparent context to either single, or multiple servers without having to enter repeated 'run' commands.

Interactive mode loads a secondary interactive shell, having established an SSH connection to all selected servers, following which any commands you enter will be executed on every server in the selection.

.. raw:: html

   <a target="_blank" href="https://asciinema.org/a/4eLVldl3G6WwwV8IvfWGllMpx?autoplay=1&speed=2"><img src="https://asciinema.org/a/4eLVldl3G6WwwV8IvfWGllMpx.png" width="836"/></a>

The function is useful when managing groups of servers in a real-time scenario, e.g. applying security patches, testing if servers have a given vulnerability, running updates and the like.

It is expected that those using interactive mode have enough knowledge of the servers under their control, and the repercussions of the commands that they might enter, as all commands entered will be executed in parallel on every server in the selection at once.

Note that the examples in this section will utilise the following reference network configuration:

.. code-block:: bash

   root (collection)
     |- staging (inventory)
       |- app1 (server)
     |- qa (inventory)
       |- app1 (server)
     |- production (inventory)
       |- app1 (server)
       |- app2 (server)


Using interactive mode
======================

Enter the production inventory namespace, and access interactive mode:

.. code-block:: bash

   > bcome production
   root> production> interactive

You can also access interactive mode directly from your terminal, using keyed access, as follows:

.. code-block:: bash

   > bcome production:interactive

You may also want to enter interactive mode for every single server in your estate (something I’ve done a couple of times when testing for a newly highlighted vulnerability):

.. code-block:: bash

   > bcome interactive

Working with selections of servers
==================================

Bcome allows you to work with selections of servers in a given inventory.

Applying this pattern to an interactive session can be very useful should you wish to issue commands to specific groups of servers within a given namespace e.g. “All my application servers within inventory X”.

See the Command list of a guide on working with selections: :doc:`../usage/commands`

