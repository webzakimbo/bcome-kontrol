****
Tags
****

Your Tags are the EC2 tags assigned to your instances within AWS EC2 (so unlike metadata, they are available only at server namespaces).

Listing tags
^^^^^^^^^^^^

Let’s say you have the following reference network configuration and you wish to view the tags for staging:app1. From your terminal, you would enter:

.. code-block:: bash

   > bcome staging:app1:tags

Or from the Bcome shell, you would:


.. code-block:: bash

   > bcome staging:app1


  root> staging> app1> tags

Using Tags inside Bcome scripts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Retrieving tags within your scripts is simple.

Let’s assume that your staging:app1 is represented in your scripts by the instance variable @node, and you wish to retrieve a tag named “mytag”.

Here’s how:

.. code-block:: ruby

   tag_value = @node.cloud_tags.fetch(:mytag)

