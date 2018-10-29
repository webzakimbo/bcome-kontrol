**********************
The metadata framework
**********************

When scripting or otherwise interacting with the Bcome shell the framework lets you access user-defined metadata. This is useful when writing orchestration scripts.

Defining Metadata
=================

To get started, create a directory called metadata within your project as follows:

.. code-block:: bash

   >project
     |- bcome
       |- metadata/

Within the metadata directory, create a yaml file. It doesn’t matter what this is called - within the metadata directory Bcome will load up any .yml file it finds, and load them all into memory.

Let’s say you have the following reference network configuration:

.. code-block:: bash

   root (collection)
     |- staging (inventory)
       |- app1 (server)
     |- qa (inventory)
       |- app1 (server)
     |- production (inventory)
       |- app1 (server)
       |- app2 (server)


And let's say you have a  metadata file called mydata.yml. You can begin to add metadata into this file as follows:

.. code-block:: yaml

   ---
   :root:
     value1: some value available to 'root'
     value2: some other value available to 'root'

   :root:staging:
     value1: a value available to 'staging' within 'root'

   :root:staging:app1:     
     value1: a value available to 'app1' within 'staging' within 'root'

Above, we have defined metadata for ‘root’, ‘root:staging’ and ‘root:staging:app1’.

Note that any metadata defined for ‘root’ will also be made available to all lower namespaces: e.g. ‘:root:staging’ has access to what has been defined in ‘root’, as does ‘root:staging:app1’: metadata is inherited down namespaces, and can be overriden.

Using metadata in scripts
=========================

Any Ruby script incorporating Bcome functionality e.g. a basic ruby script, internal or external script, may access Bcome’s metadata framework.

Given a Ruby object representing a Bcome namespace, @node, a fetcher is provided:

.. code-block:: ruby

    metadata_value = @node.metadata.fetch(:metadata_key)
    # OR - you may supply a default value, should the key you request not be defined
    metadata_value = @node.metadata.fetch(:metadata_key, {:some => :default }

To view what metadata is configured for a given Bcome namespace node, you may instruct Bcome to output the metadata. For example, given namespace foo:bar:


Using keyed access:

.. code-block:: bash

   > bcome foo:bar:meta

From the shell

.. code-block:: bash

   > bcome foo:bar
   >foo> bar> meta

Or within your script, where @node is an instance variable holding a given namespace:

.. code-block:: ruby

   puts @node.meta

To return an object containing all configured metadata available for a given namespace:

From the shell:

.. code-block:: bash

   > bcome foo:bar
   foo> bar> metadata

From a script:

.. code-block:: ruby

   @node.metadata # for the object wrapper
   @node.metadata.data # for a raw hash

Encrypting Metadata
===================

Any metadata files included within your metadata directory may be encrypted with a single key. This allows you to exclude raw metadata files that may contain sensitive information from your source control, and push up encrypted versions instead. The framework will always utilise your encrypted files during its runtime, and will prompt you for your encryption key the first time your encrypted files are required.

Encryption
^^^^^^^^^^^

.. code-block:: bash

   > bcome pack_metadata

You’ll be prompted for an encryption key. Note that if you re-encrypt your files (e.g. after you’ve modified your data), your encryption key must match the initial key used to encrypt your files.

Once your metadata is encrypted, Bcome will make us of your encrypted metadata files during its runtime, prompting you for the key the initial time it decrypts your data for use.

Decryption
^^^^^^^^^^

When you need to work on your metadata files, you may unpack them as follows:

.. code-block:: bash

   > bcome unpack_metadata

You’ll be prompted for an encryption key.
