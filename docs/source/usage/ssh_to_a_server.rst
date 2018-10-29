***
SSH
***

You may SSH to a server either using keyed-access, or directly from the Bcome shell.

Using keyed-access
==================

.. code-block:: bash

   > bcome inventory:server:ssh

From the shell
==============

from an inventory namespace
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome inventory
   > ssh servername


from a server namespace
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome inventory
   > cd servername
   > ssh

See how easy it is
==================

The example below illustrates how Bcome enables SSH to a server behind a proxy.

.. raw:: html

  <a target="_blank" href="https://asciinema.org/a/151692?autoplay=1&speed=2"><img src="https://asciinema.org/a/151692.png" width="836"/></a>
