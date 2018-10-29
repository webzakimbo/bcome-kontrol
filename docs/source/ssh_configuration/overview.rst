********
Overview
********

All interactions with servers in the Bcome ecosystem are over SSH.

It’s a very good idea to have SSH keys in place on the servers with which you’re going to interact.

Bcome wil let you -

* execute arbitrary commands on servers or groups of servers (either via the Bcome shell, or directly from your terminal).
* enter an interactive REPL style mode for command execution against individual or groups of servers
* write orchestration scripts
* SSH directly into your servers.
* add in many different sets of SSH credentials, allowing you to apply different connection mechanisms to different namespaces
* work with servers with different connection credentials all at the same time
* work with servers hosted in different cloud accounts, all at the same time
* re-use Bcome's SSH layer for integration with other frameworks

To enable all this you must first configure Bcome for SSH.

Before you begin
^^^^^^^^^^^^^^^^

Make sure you understand how namespacing works in Bcome and have tried a few examples: :doc:`../namespaces/overview`

It’s also worth taking a look at how to use ping so that you can understand how to verify your configuration: :doc:`../usage/testing_connections`
