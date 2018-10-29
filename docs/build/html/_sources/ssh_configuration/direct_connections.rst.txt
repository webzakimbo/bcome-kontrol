******************
Direct connections
******************

Direct connections are when your SSH connections are direct to your instances without going through any interemediary proxy.

You normal means of initiating an SSH connection would look something like this:

.. code-block:: bash

   > ssh user@hostnameorip.com

Let’s assume you have a single inventory setup, a little like this:

.. code-block:: yaml

   ---
   :myinventory:
     :description: My inventory
     :type: inventory
     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1
 
     :ec2_filters:
       :instance-state-name: running

Now let’s add a basic Direct SSH connection that assumes the following:

* Your SSH user is your local terminal user
* You have ssh keys setup
* Your networks.yml config could look something like this:

.. code-block:: yaml

   ---
   :myinventory:
     :description: My inventory
     :type: inventory
     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1
 
     :ec2_filters:
       :instance-state-name: running

    :ssh_settings:
       :ssh_keys:
         - "~/.ssh/id_rsa"
       :timeout_in_seconds: 10

To connect as a different user, you can specify the username in the ssh_settings block:

.. code-block:: yaml

   ---
   :ssh_settings:
     :user: "someoneelse"
     :ssh_keys:
       - "~/.ssh/id_rsa"
     :timeout_in_seconds: 10

Note the 'timeout_in_seconds' value. This is an integer value representing the time in seconds after which point command execution within Bcome will timeout if a connection cannot be made.




