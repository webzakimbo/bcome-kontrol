**********
Pseudo tty
**********
 
Bcome's pseudo-tty mode allows you to access a pseudo terminal, and is accessible from all server namespaces. 

This is useful if you wish to do something like the following:

* Tail a remote log file from your local server
* Open up a remote console, e.g. a MySQL console, Rails console, MongoDb etc

Bcome makes this easy as the SSH connection to your remote machine is already taken care of - you just need to figure out which command you wish to run remotely.

How to use pseudo-tty within Bcome
==================================

Use case 1: tail a remote file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You wish to tail a remote log file, and you usually SSH in to your server and type in the following:

.. code-block:: bash

   > tail -f /path/to/your/file.log

Given a server namespace named app1 within a collection namespace of production, you would instead:

.. code-block:: bash

   > bcome production:app1:pseudo_tty "tail -f /path/to/your/file.log"

Use case 2: open a mysql console
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You wish to open up a Mysql console, and you’d usually SSH in to your server and type in the the following:

.. code-block:: bash

   > mysql -u user -p password -h hostname database

Given a server namespace named app1 within a collection namespace of production, you would instead:

.. code-block:: bash

   > bcome production:app1:pseudo_tty "mysql -u user -p password -h hostname database"

Access from the shell
=====================

The pseudo_tty function is also accessible directly from the shell.

.. code-block:: bash

   > bcome namespace
   > cd server
   > pseudo_tty "your command"


Incorporating Pseudo-tty sessions directly into Bcome
=====================================================

The pseudo_tty method is available to all server namespaces within your orchestration scripts too.

This means you can embedd a call to such a function directly into your Bcome installation. For example, I may wish to be able to access a database console directly from Bcome as follows:

.. code-block:: bash

   > bcome staging:app1:db

The 'db' invocation would be a a Bcome registry hook, referencing an internal script, within which you can declare the pseudo-tty function as follows:

.. code-block:: ruby
  
   def execute
     @node.pseudo_tty("mysql -u user -p password -h host")
   end
  
An example of this in action can be seen below:

.. raw:: html

   <a target="_blank" href="https://asciinema.org/a/151692?autoplay=1&speed=1"><img src="https://asciinema.org/a/151692.png" width="836"/></a>

To implement something like this for yourself see the following two guides: :doc:`../orchestration/registry` / :doc:`../orchestration/internal_hooks`
