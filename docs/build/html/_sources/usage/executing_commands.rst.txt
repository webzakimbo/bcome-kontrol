***************************
Executing commands with run
***************************

The 'run' command allows you to execute commands on your servers over SSH. You can target either individual, or groups of servers (where you execute the same command on multiple machines in parallel).


The examples in this section will reference the following pseudo network configuration:

.. code-block:: bash

   root (collection)
     |- staging (inventory)
       |- app1 (server)
     |- qa (inventory)
       |- app1 (server)
     |- production (inventory)
       |- app1 (server)
       |- app2 (server)

Consider the following use case: You want to view the free memory usage on your servers, and want to use the command “free -m”.

Using keyed access
==================

Execute your command on just app1 within the production namespace:

.. code-block:: bash

   > bcome production:app1:run "free -m"

Execute your command on both app1 and app2 within the production namespace:

.. code-block:: bash

   > bcome production:run "free -m"


From the shell
==============

Enter the namespace within which you want to run your command and then enter

.. code-block:: bash

   > run "free -m"

If you enter a server namespace, the command will be executed on just that server.

If you enter an inventory namespace, the command will be executed on all selected servers within that inventory.

If you enter a collection namespace, the command will be executed on all servers belonging to all selected inventories & collections within that namespace.


On a sub-selection of machines
==============================

Imagine you want to execute a command on all machines with qa & staging namespaces only, you would:

.. code-block:: bash

   > bcome
   > workon qa, staging
   > run "command"

Or, just 'app1' within the production namespace, you would:

.. code-block:: bash

   > bcome production
   > workon app1
   > run "command"

See the commands 'workon', 'enable', and 'disable' from the commands list for further information on how to filter selections: :doc:`commands`
