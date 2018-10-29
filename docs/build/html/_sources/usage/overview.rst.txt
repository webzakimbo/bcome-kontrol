********
Overview
********

All examples within Usage will reference the following pseudo network configuration:

.. code-block:: bash

   root (collection)
     |- staging (inventory)
       |- app1 (server)
     |- qa (inventory)
       |- app1 (server)
     |- production (inventory)
       |- app1 (server)
       |- app2 (server)

In the above example we have one root collection named “root”, containing three inventories - staging, qa and production. Staging and qa contain one server each, both named “app1”, whilst the production inventory contains two servers, app1 and app2.

The above example is a common and simple pattern, but there are almost unlimited ways in which you can organise your network. Have a look at the namespace configuration for more information: :doc:`../namespaces/overview`
