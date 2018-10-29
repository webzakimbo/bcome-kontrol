***************
Port Forwarding
***************

Bcome allows you to setup local port forwarding with ease - either in bootstrapping mode or otherwise, or for those machines behind a proxy or otherwise.

Let’s say you want to forward local port 5901 to destination port 5901 for server namespace :inventory:server

From the console
^^^^^^^^^^^^^^^^

.. code-block:: bash
 
   > bcome inventory:server

   # Open a tunnel
   estate> inventory> server> tunnel = local_port_forward(5901, 5901)

   # Close the tunnel
   estate> dev> servera> tunnel.close!

From an orchestration script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Where @node represents your server

.. code-block:: ruby

   # Open a tunnel
   tunnel = @node.local_port_forward(5901, 5901)

   # Close the tunnel
   tunnel.close!

