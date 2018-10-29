*******************
Basic configuration
*******************

The network.yml configuration file
==================================

Namespaces are defined within the network.yml file in the bcome configuration directory

Navigate to your project directory, and then within the bcome directory, create a networks.yml file

For reference, have a look at what your project structure should look like: :doc:`../starting/installation`.

And take a look at what Bcome namespaces are: :doc:`overview`.

Defining namespaces
===================

Consider the following simple network namespace defined in your networks.yml file:

.. code-block:: yaml

   ---
   "collection1":
     :description: "description of collection 1"
     :type: collection

   "collection1:collection2":
     :description: "description of collection 2"
     :type: collection

   "collection1:collection2:inventory1":
     :description: "description of inventory"
     :type: inventory


This will set up three namespaces

* collection1
* collection1:collection2
* collection1:collection2:inventory1

collection1 contains one collection, collection2, which contains a single inventory, inventory1.

In bcome, the namespacing relationship is defined by a breadcrumb key e.g a:b:c

If we were to add an additional inventory as follows:


.. code-block:: yaml

   ---
   "collection1":
     :description: "description of collection 1"
     :type: collection

   "collection1:collection2":
     :description: "description of collection 2"
     :type: collection

   "collection1:collection2:inventory1":
     :description: "description of inventory 1"
     :type: inventory

  "collection1:collection2:inventory2":
     :description: "description of inventory 2"
     :type: inventory

Now collection2 contains two inventories.

Confused? Take a look at the following Asciicast and see how simple it actually is.  Note the use of the commands "cd" (change namespace), "ls" (list namespaces), and "tree" (prints a tree view).  Note also how bcome can be navigated either via its shell, or by keying directly into your desired namespace.

.. raw:: html

  <a target="_blank" href="https://asciinema.org/a/Rw42ebjqn9zVmr30KymLPE2pN?autoplay=1&speed=2"><img src="https://asciinema.org/a/Rw42ebjqn9zVmr30KymLPE2pN.png" width="836" /></a>

