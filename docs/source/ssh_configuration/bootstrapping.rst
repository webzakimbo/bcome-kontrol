*************
Bootstrapping
*************

A common requirement is the need to manage machines that have not yet had their configuration applied, i.e. machines that require bootstrapping.

Bcome comes with a bootstrap mode that allows you to define alternative SSH connection configurations.

Consider a simple inventory, as follows, and note the bootstrap_settings block:

.. code-block:: yaml

   ---
   "myinventory":
     :description: "A basic inventory"
     :type: inventory

     :network:
       :type: ec2
       :credentials_key: awsreferencekey
       :provisioning_region: us-east-1

       :ssh_settings:
         :ssh_keys:
           - "~/.ssh/id_rsa"
         :timeout_in_seconds: 10

       :bootstrap_settings:
         :ssh_key_path: path/to/your/private/key.pem"
         :user: username
         :bastion_host_user: ubuntu # optional

By default all SSH connectivity would be determined by the ssh_settings block, whilst in bootstrapping mode, SSH connectivity would be determined by the bootstrap_settings block.

See here for how to use bootstrapping from your Bcome shell: :doc:`../usage/bootstrapping_mode`
