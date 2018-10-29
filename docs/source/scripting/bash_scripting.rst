**************
Bash scripting
**************

Overview
========

We’ve seen already how we can execute single commands in sequence using either the 'run' command or the 'interactive' mode.

Bcome also lets you execute local bash scripts against either individual or groups of your remote servers.

Setup
=====

The base Bcome directory structure looks as follow:

.. code-block:: bash

   > project
     |- bcome
       |- networks.yml

Within the bcome directory, create a new directory called scripts so that your directory structure now looks as follows:

.. code-block:: bash

   > project
     |- bcome
       |- networks.yml
     |- scripts

Hello World
===========

Before we begin
^^^^^^^^^^^^^^^

Let’s assume you have a network configuration setup as follows - three inventories, within one collection, all containing at least 1 server:

.. code-block:: bash

   root (collection)
     |- staging (inventory)
       |- app1 (server)
     |- qa (inventory)
       |- app1 (server)
     |- production (inventory)
       |- app1 (server)
       |- app2 (server)

Create a bash script
^^^^^^^^^^^^^^^^^^^^

Within your scripts directory create the following script hello_world.sh, and into add the following:

.. code-block:: bash

   #!/bin/bash

   echo "Hello world, I am `whoami`"


Executing your script with keyed access
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The quickest & easiest method to execute your script is to use keyed access, where you invoke the execution of your script directly against a known namespace, e.g.

To execute your script on staging, app1:

.. code-block:: bash

  > bcome staging:app1:execute_script hello_world

To execute your script on all production servers:

.. code-block:: bash

   > bcome production:execute_script hello_world

To execute your script on all servers across your entire estate:

.. code-block:: bash

   > bcome execute_script hello_world

Script execution is conducted in parallel across all servers found under your target namespace level.

Executing your script from the shell
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, navigate to your chosen namespace, e.g. for staging, app1

.. code-block:: bash

   > bcome staging:app1

And then execute your script

.. code-block:: bash

   root> staging> app1> execute_script "hello_world"

Or, to execute against all servers in production:

.. code-block:: bash

   > bcome production
   root> production> execute_script "hello_world"

You’ll notice that in shell mode Bcome returns objects representing the result of the executed command. This will be useful for you later should you wish to incorporate the execution of a bash script into a more advanced Bcome orchestration script.
