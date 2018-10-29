*******************
Proxied connections
*******************

Proxied connections are where you connect to you instances via some kind of SSH proxy, i.e. through a jump box.

Your normal means of initiating an SSH connection could look something like this:

.. code-block:: bash

   > ssh -o "ProxyCommand ssh -W %h:%p user@jumpboxhost" user@internalhost

by hostname or ip
^^^^^^^^^^^^^^^^^

Let’s assume you have a single inventory setup specify your proxy by its hostname or ipaddress:

Your networks.yml would look something like this:

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
       :proxy:
         :host_lookup: by_host_or_ip
         :host_id: "xx.xxx.xxx.xxx"
       :ssh_keys:
         - "~/.ssh/id_rsa"
       :timeout_in_seconds: 10

To initiate connections using a different jump box user, you would modify your ssh_settings block as follows:

.. code-block:: yaml

   ...
   :ssh_settings:
     :proxy:
       :host_lookup: by_host_or_ip
       :host_id: "xx.xxx.xxx.xxx"
       :bastion_host_user: "someotherusername" 
    :ssh_keys:
      - "~/.ssh/id_rsa"
    :timeout_in_seconds: 10
    ...

You may also specify a different username for the internal host as follows:

.. code-block:: yaml

   ...
   :ssh_settings:
    :user: "someotherusername"
    :proxy:
      :host_lookup: by_host_or_ip
      :host_id: "xx.xxx.xxx.xxx"
      :bastion_host_user: "someotherusername"
   :ssh_keys:
      - "~/.ssh/id_rsa"
    :timeout_in_seconds: 10

by reference to a bcome instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can also proxy your SSH connections by reference to another Bcome instance, for example:

.. code-block:: yaml

   ...
   :ssh_settings:
    :proxy:
      :host_lookup: by_bcome_namespace
      :namespace: "inventory:servername"
   :ssh_keys:
      - "~/.ssh/id_rsa"
    :timeout_in_seconds: 10
   ...

Note that when specifying a reference Bcome namespace, the highest-level namespace is implicit in the host_lookup declaration.
