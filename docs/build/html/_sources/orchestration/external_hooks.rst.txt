**************
External Hooks
**************

If you haven’t already, read up on how the registry allows you to reference external ruby scripts, and execute them by passing them a Bcome namespace context.

This section will detail with how you write these scripts.

Setup
=====

The first step is to determine which namespace context you wish to pass to your script.

Let’s say that you have a Capistrano deployment script that you normally invoke as follows:

.. code-block:: bash

   > cap myapp deploy 

And let’s say that this you want to apply it to Bcome namespace staging, so that you may invoke your script as follows:

.. code-block:: bash

   > bcome staging:deploy

Your registry declaration would look as follows:

.. code-block:: yaml

   ---
   "staging":
     - type: external
       description: "Deploy my application"
       console_command: deploy
       group: deployment
       local_command: cap myapp deploy build=%foo%

When you invoke bcome staging:deploy, Bcome will now invoke the following under the hood:

.. code-block:: bash

   > cap myapp deploy

Within your myapp Capistrano script, you need to have the following:

.. code-block:: ruby

   require 'bcome'
   orchestrator = Bcome::Orchestrator.instance
   @node = orchestrator.get(ENV["bcome_context"])

You script will load in your staging namespace into the @node instance variable, and you may then use Bcome for network discovery i.e. You can setup your target machines by querying Bcome.

You may also make use of Bcome’s metadata framework for additional control.

Enabling a call to a script in this way means that:

* your scripts are directly callable from whichever namespace you desire
* you can re-use the same script within another namespace (e.g. for the example given above, you can now re-use the same deployment script in another environment e.g. for a production deploy)
* you can make use of Bcome’s metadata framework within your scripts: your scripts may become dynamic according to the namespace from which you have invoked them

Note that every method available within Bcome for your given namespace is available to the @node instance. See the command list for a full list, and also have a look at the accessors.

Passing parameters to your script and setting defaults
======================================================

Bcome will also allow you to configure default values to pass to your external script.

Let’s expand on the registry configuration we saw earlier:


.. code-block:: yaml

   ---
   "staging":
     - type: external
       description: "Deploy my application"
       console_command: deploy
       group: deployment
       local_command: cap myapp deploy build=%foo%
       defaults:
         build: "master"

Now, when you invoke bcome staging:deploy, Bcome will call the following under the hood:

.. code-block:: bash

   > bcome staging:deploy build=master

From the command line, you may override any default values as follows:

.. code-block:: bash

   > bcome staging:deploy build=anotherbuild

Or from the shell:

.. code-block:: bash

  > bcome staging
  staging> deploy "anotherbuild"

Any parameters not provided will default to the defaults provided. Note that default values must be provided for all parameters specified.
