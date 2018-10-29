*********
Overview
*********

To configure Bcome you must define namespaces that represent how you want to group the machines within your estate.

You may have a single platform, representing multiple application environments, or perhaps a large estate comprising multiple application platforms and application environments. You may also want to group machines within your estate by some specific attribute, allowing you to work on only those machines collectively.

Grouping in this way provides you with a means of navigating your estate either within the Bcome shell or by allowing you to key in to specific namespaces - directly from the terminal - in order to directly execute Bcome functions, or any other actions you have defined yourself.

Namespace types
===============

Collections
^^^^^^^^^^^

A collection may contain other collections, or one or more inventories. A collection could represent a platform, comprising multiple environments, or a collection of platforms.

for example:

* a collection representing a platform, comprising multiple application environments.
* a collection representing an estate, comprising multiple platforms.

It's up to you though what use you make of your collections: they're useful as a namespace to house other things.

Inventories
^^^^^^^^^^^

An inventory contains servers. It could represent all the machines belonging to a specific platform or environment, or a filtered list of machines belonging to a collection

for example:

* an inventory representing a specific application environment, comprising multiple servers.
* an inventory representing all the machines in an given EC2 availability zone, matching certain filters.

Inventories may not contain collections, or other inventories.

Consider an inventory as a collection of servers that you've defined yourself, that you've grouped together because of some shared function. 

Sub-selected Inventories
^^^^^^^^^^^^^^^^^^^^^^^^

A sub-selected inventory is an inventory that has been further filtered down by specific attributes.

For example:

* a sub-selected inventory comprising only the application servers of a specific type, selected from its the parent inventory.

Servers
^^^^^^^

A representation of a physical machine, i.e. a server in EC2 or a statically defined server onto which actions may be performed.
