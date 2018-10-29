*************************
Configuration Inheritance
*************************

How inheritance works
^^^^^^^^^^^^^^^^^^^^^

Just like the network namespace configuration, SSH configuration is inherited down your namespaces. Lower namespaces are then free to override or define as new the configuration you require.

Take two inventories, the first representing your production servers, and the second, staging. You could define the common aspects of your ssh configuration on the parent collection, which is then inherited by both inventories, and then define different proxy rules on each inventory.

For example:


.. code-block:: yaml

   ---
   :estate:
     :description: Top level collection
     :type: collection

    :network:
      :type: ec2
      :credentials_key: awsreferencekey
      :provisioning_region: us-east-1

      :ssh_settings:
        :ssh_keys:
         - "~/.ssh/id_rsa"
        :timeout_in_seconds: 10

   :estate:staging:
     :description: My staging inventory
     :type: inventory
  
     :ec2_filters:
       :tag:stage: staging

     :ssh_settings:
       :proxy:
         :host_lookup: by_host_or_ip
         :host_id: "111.111.111.11"

   :estate:production:
     :description: My production inventory
     :type: inventory

     :ec2_filters:
       :tag:stage: production

     :ssh_settings:
       :proxy:
         :host_lookup: by_host_or_ip
         :host_id: "222.222.222.22"

You’re free to override the ssh_settings as you see fit to support whichever connection scheme you have setup. For example, you may mix and match Direct Connections or Proxied Connections.

Let’s consider a second use case: Two inventories, production and staging, where only production requires proxied access to your hosts:

.. code-block:: yaml

   ---
   :estate:
     :description: Top level collection
     :type: collection

    :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

     :ssh_settings:
       :ssh_keys:
         - "~/.ssh/id_rsa"
         :timeout_in_seconds: 10

   :estate:staging:
     :description: My staging inventory
     :type: inventory
     
     :ec2_filters:
       :tag:stage: staging


   :estate:production:
     :description: My production inventory
     :type: inventory

     :ec2_filters:
       :tag:stage: production

     :ssh_settings:
       :proxy:
         :host_lookup: by_host_or_ip
         :host_id: "xx.xxx.xxx.xxx"

Overriding configuration settings on a per server basis
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While by default all your servers will inherit any configuration specified by their parent namespace (as defined in your networks.yml configuration file), it’s sometimes useful to override configuration on a per-server basis.

For example, you may have a server deployed within your network that requires different SSH connection parameters. Let’s assume that your networks.yml configuration defines your bootstrap SSH user as ‘ubuntu’ whilst for the server in question, the boostrap ssh user needs to be ‘admin’. How would we achieve this?

Let’s assume your server is identified by namespace :estate:production:debianserver

The machine-data.yml
""""""""""""""""""""

Within your bcome config directory, create a file as follows:

.. code-block:: bash

   bcome/machines-data.yml

Within your machines-data config, add the following:


.. code-block:: yaml

   ---
   :estate:production:debianserver:
     :ssh_settings:
       :bootstrap_settings:
         :user: admin

The bootstrapped SSH user for estate:production:debianserver is now overriden.

You may override any configuration for your servers (or indeed, set any new configuration) using this method.
