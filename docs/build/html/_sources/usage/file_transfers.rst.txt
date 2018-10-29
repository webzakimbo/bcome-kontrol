**************
File transfers
**************

Transferring files to and from remote servers can be handled by Bcome.

get
===
get allows you to download a file (or recursively download a directory) from a remote server.

Use case: download a file from “/remote/path” on production server app2 and save it to “/local/path”

shell usage
^^^^^^^^^^^

.. code-block:: bash

   > bcome production:app2
   root> production> app2> get "/remote/path", "/local/path"


Direct usage
^^^^^^^^^^^^

.. code-block:: bash

   > bcome production:app2:get "/remote/path" "/local/path"


put
===

Put allows you to upload a file (or recursively upload a directory) to a remote server, or to a collection of servers simultaneously

Direct upload to an individual server (keyed access)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome staging:app1:put "/local/path" "/remote/path"

Direct upload to all the servers within a specific inventory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome staging:put "/local/path" "/remote/path"

Direct upload from the shell, to an individual server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome staging:app1
   root> staging> app1> put "/local/path", "remote/path"

Direct upload from the shell to a server selection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   > bcome staging
   root> staging> put "/local/path", "/remote/path"


rsync
=====

Rsync works exactly like put, but uses Rsync for file transfers rather than SCP.

Rsync is useful when transferring a lot of files as it’s quicker.
