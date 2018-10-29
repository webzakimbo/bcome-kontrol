******************
Bootstrapping mode
******************

Overview
========

In our configuration section we showed that it’s possible to use alternative SSH schemes..

This is known as bootstrapping mode.

It derives from the following common use case: prior to a server being configured, it may be necessary to connect to it using different SSH credentials.

This section details how to use bootstrapping.

See our configuration section for how to configure it: :doc:`../ssh_configuration/bootstrapping`

Enabling bootstrapping
======================

To enable or disable bootstrapping from the Bcome shell for a given server, enter the namespace for the server in question and enter toggle_bootstrap, e.g. for app1 within inventory namespace qa:

.. code-block:: bash

   > bcome qa:app1
   >root> qa> app1> toggle_bootstrap

To enable to disable bootstrapping form the Bcome shell for all servers selected witin a namespace:

.. code-block:: bash

   > bcome qa
   >root> qa> toggle_bootstrap

Bootstrapping mode is also available in your custom orchestration. Given a Bcome namespace held in instance variable @node, you can toggle bootstrapping as follows:

.. code-block:: ruby

   @node.toggle_bootstrap

All SSH related commands (e.g. SSH’ing to the server, executing run, put, get, rsync, or interactive mode), will use the bootstrapping SSH config when bootstrap mode is enabled.

Note that when interacting with more than one server, one may be running in a bootstrapped context, while the other does not.
