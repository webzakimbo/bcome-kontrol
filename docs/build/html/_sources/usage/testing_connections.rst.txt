*******************
Testing connections
*******************

SSH Connections may be tested with Bcome's 'ping' command.  This can be done either at the level of an individual machine, or groups of machines.

Note that examples in this section will utilise the reference network configuration detailed here.

Ping all machines in an estate
==============================

.. code-block:: bash

   > bcome ping

Ping all machines within a given namespace
==========================================

.. code-block:: bash

   > bcome namespace:ping

or

.. code-block:: bash

   > namespace:secondary_namespace:ping

Ping an individual machine
==========================

.. code-block:: bash

   > bcome namespace:server:ping

Ping from the Bcome shell
=========================

Ping may also be invoked directly from the bcome shell, e.g.

.. code-block:: bash

   > bcome namespace
   > cd secondarynamespace
   > ping

