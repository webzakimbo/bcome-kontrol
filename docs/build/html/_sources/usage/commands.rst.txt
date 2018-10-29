********
Commands
********

Command list
============

Slightly different lists of commands are available at collection, inventory and server namespaces.

You may enter Bcome at any namespace and hit menu to view the available command list and usage.

Commands may be grouped into the following:

* Navigation
* Selections
* Server interactions
* Orchestration
* Caching
* Registry

Navigation commands
^^^^^^^^^^^^^^^^^^^

ls
""
List all resources available at your current namespace.

cd
""
Navigate into the namespace of a resource listed within your current namespace.

back
""""
Navigate back to your the namespace.

tree
""""
Print to screen a tree view of all resources below your current namespace.


Selection commands
^^^^^^^^^^^^^^^^^^

Bcome allows you to work on selections of resources within any namespace. For example, if your inventory returns 10 servers, and you only want to work with a particular few, you can select these servers only.

You may only work with selections at collection and inventory namespace levels.

workon
""""""
Select one or more resources within your current namespace, so that all subsequent commands interact with these selections only.

enable
""""""
Add an unselected resource into your current selection.

disable
"""""""
Remove a selected resource from your current selection.

enable!
"""""""
All all available resources into your current selection.

disable!
""""""""
Remove all available resources from your current selection.

lsa
"""
List all resources within your current selection.


Server interaction commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^

run
"""
Run allows you to pass a command directly to all servers contained within your current selection. This command will be executed on all servers at all levels including and below your current selection.

For example:

* run within a collection namespace will execute your command on all servers found at all namespace levels below the current collection
* run within an inventory namespace will execute your command on all selected servers (and node: by default, the entire manifest is selected).
* run within a server namespace will execute your command on the server only.

put
"""
Upload a file using SCP to all servers at all levels including and below your current selection.

rsync
"""""
Upload a file using Rsync to all servers at all levels including and below your current selection.

interactive
"""""""""""
Enter an interactive SSH command session for all servers at all levels including and below your current selection.

ping
""""
Ping all servers to test SSH connectivity.

ssh
"""
SSH directly into a server

inventory and server level only

get
"""
Download a file from a remote server.

inventory level only


Orchestration commands
^^^^^^^^^^^^^^^^^^^^^^

meta
""""
Output all the metadata configured as part of your orchestration setup for the current namespace. These are made available to your orchestration scripts. See the advanced orchestration section for more information on configuring metadata.

metadata.fetch(:key_name, default)

tags
""""
Output all remote tags configured against a server, e.g. all the EC2 tags. These are made available to your orchestration scripts.

server level only

registry
""""""""
Show a command list of all user-configured orchestration commands applicable to the current namespace. See the registry section for more information.

Caching commands
^^^^^^^^^^^^^^^^

save
""""
Cache an inventory locally for faster lookup

inventory level only

reload
""""""
Reload an inventory from remote

inventory level only and not available to sub-inventories

Registry commands
^^^^^^^^^^^^^^^^^

The command registry allows you to create your own commands, that will invoke your own custom Ruby orchestration code, executed in the scope of whichever namespace you're currently in.

See our Registry guide on how to create these commands: :doc:`../orchestration/registry`

Registry commands can either be invoked by keyed access from the terminal

.. code-block:: bash
   
   > bcome your:namespace:yourcommand


Or, they may be invoked from the bcome shell

.. code-block:: bash

   > bcome your:namespace
   > yourcommand

