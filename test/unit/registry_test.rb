load "#{File.dirname(__FILE__)}/../base.rb"

class RegistryTest < ActiveSupport::TestCase
  include UnitTestHelper

    def given_mocked_context_command_data_from_registry(group_name = given_a_random_string_of_length(4))
      {
        :type => "external",
        :description => given_a_random_string_of_length(4),
        :console_command => given_a_random_string_of_length(4),
        :group => group_name,
        :local_command => given_a_random_string_of_length(3)
      }
    end

    def test_should_create_a_command_group_with_a_single_group_containing_a_few_commands
      # Given

      # an abitrary namespace
      namespace = given_a_random_string_of_length(3)
      node = mock("A mocked node")
      node.expects(:namespace).returns(namespace)

      # and a setup containing an arbitrary number of commands for that namespace
      group_name = given_a_random_string_of_length(5)
      number_commands = rand(1..7)
      mocked_command_data = number_commands.times.collect{|index| given_mocked_context_command_data_from_registry(group_name) }

      registry_data = {
        namespace => 
          mocked_command_data
      }

      ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

      # When
      command_group = ::Bcome::Registry::Loader.instance.command_group_for_node(node)

      # Then
      # We've got a group, keyed on the correct group name, containing the correct number of commands
      assert command_group.is_a?(::Bcome::Registry::Command::Group)
      assert command_group.has_commands?
      assert command_group.all_commands.size == 1   ## Keyed on the group name
      assert command_group.all_commands.has_key?(group_name)
      assert command_group.all_commands[group_name].size == number_commands

      # And that our commands have all been initialized correctly
      commands_from_group = command_group.all_commands[group_name]  
      commands_from_group.each_with_index do |command_from_group, index|
        assert command_from_group.is_a?(::Bcome::Registry::Command::External)
        assert command_from_group.description == mocked_command_data[index][:description]
        assert command_from_group.console_command == mocked_command_data[index][:console_command]
        assert command_from_group.group == mocked_command_data[index][:group]
        assert command_from_group.local_command == mocked_command_data[index][:local_command]
      end
    end

    def test_should_key_commands_on_group_names_correctly
      # Given

      # an arbitray namespace
      namespace = given_a_random_string_of_length(3)
      node = mock("A mocked node")
      node.expects(:namespace).returns(namespace)
   
      # and a 3 groups
      group_name_1 = given_a_random_string_of_length(5)
      group_name_2 = given_a_random_string_of_length(5)
      group_name_3 = given_a_random_string_of_length(5)

      number_commands_group_1 = rand(1..7)
      mocked_command_data_group_1 = number_commands_group_1.times.collect{|index| given_mocked_context_command_data_from_registry(group_name_1) }

      number_commands_group_2 = rand(1..7)
      mocked_command_data_group_2 = number_commands_group_2.times.collect{|index| given_mocked_context_command_data_from_registry(group_name_2) }

      number_commands_group_3 = rand(1..7)
      mocked_command_data_group_3 = number_commands_group_3.times.collect{|index| given_mocked_context_command_data_from_registry(group_name_3) }

      all_mocked_command_data = mocked_command_data_group_1 + mocked_command_data_group_2 + mocked_command_data_group_3

      registry_data = {
        namespace => 
          all_mocked_command_data
      }

      ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

      # When
      command_group = ::Bcome::Registry::Loader.instance.command_group_for_node(node)

      assert command_group.is_a?(::Bcome::Registry::Command::Group)
      assert command_group.has_commands?
      assert command_group.all_commands.size == 3   ## Keyed on the group name
      assert command_group.all_commands.has_key?(group_name_1)
      assert command_group.all_commands.has_key?(group_name_2)
      assert command_group.all_commands.has_key?(group_name_3)

      assert command_group.all_commands[group_name_1].size == number_commands_group_1
      assert command_group.all_commands[group_name_2].size == number_commands_group_2
      assert command_group.all_commands[group_name_3].size == number_commands_group_3
    end 

    def test_should_catch_invalid_regex_in_registry
      # Given
      # an abitrary namespace
      namespace = given_a_random_string_of_length(3)
      node = mock("A mocked node")

      registry_data = {
        "i:am:invalid(" =>
          [
            given_mocked_context_command_data_from_registry
          ]
      }

      ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

      # When/then
      assert_raise Bcome::Exception::InvalidRegexpMatcherInRegistry do
        ::Bcome::Registry::Loader.instance.command_group_for_node(node)       
      end
    end

    def test_should_verify_we_can_match_namespace_on_regex_correctly
      # Given
      namespace = "foo:bar:whatever"

      node = mock("A mocked node")

      keys_we_expect_to_match = [
        "foo:bar:whatever",
        "foo:bar:.+",
        "foo:bar:(whatever|somethingelse)",
        "foo:(bar|moo):whatever", 
        "foo:(bar|moo):.+"
      ]
 
      keys_we_dont_expect_to_match = [
        "should:not:match",
        "unknownprefix:foo:bar:whatever",
        "foo:bar:whatever:unknownsuffix",
      ]


     all_keys = keys_we_expect_to_match + keys_we_dont_expect_to_match

     node.expects(:namespace).returns(namespace).times(all_keys.size)

     registry_data = {}
     all_keys.each {|key|
       registry_data[key] = [
         # We'll just add a single command to each one, as we don't care how many we have, just that we have some
         # but, so we can identify them in our assertions shortly, we'll set the group name to the registry regex matcher
         given_mocked_context_command_data_from_registry(key)
       ]
     }
 
     ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

     # When
     command_group = ::Bcome::Registry::Loader.instance.command_group_for_node(node)
 
     # Then
     # We expect to have matched all our keys
     keys_we_expect_to_match.each {|key_we_expect_to_match|
       assert command_group.all_commands.has_key?(key_we_expect_to_match)
     }   
  end

  def test_should_honour_node_restrictions_when_command_is_server_node_level_only
    # Given
    namespace = "foo:bar"

    node = mock("A mocked node")
    node.expects(:namespace).returns(namespace)

    node.expects(:is_a?).with(::Bcome::Node::Server::Base).returns(true)

    group_name = given_a_random_string_of_length(3)

    mocked_data_server_only = given_mocked_context_command_data_from_registry(group_name).merge({ :restrict_to_node => "server" })
    mocked_data_no_restrictions = given_mocked_context_command_data_from_registry(group_name)


    registry_data = {
      "foo:bar" => [
        mocked_data_server_only,
        mocked_data_no_restrictions
      ]
    }

    ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

    # When 
    command_group = ::Bcome::Registry::Loader.instance.command_group_for_node(node)

    # Then both our commands should be present, keyed on the group name
    commands = command_group.all_commands[group_name]
    assert commands.size == 2
  end

  def test_should_honour_node_restrictions_when_command_is_server_node_level_only_and_node_something_else
    # Given
    namespace = "foo:bar"

    node = mock("A mocked node")
    node.expects(:namespace).returns(namespace)

    node.expects(:is_a?).with(::Bcome::Node::Server::Base).returns(false)
    
    group_name = given_a_random_string_of_length(3)

    mocked_data_server_only = given_mocked_context_command_data_from_registry(group_name).merge({ :restrict_to_node => "server" })
    mocked_data_no_restrictions = given_mocked_context_command_data_from_registry(group_name)

    registry_data = {
      "foo:bar" => [
        mocked_data_server_only,
        mocked_data_no_restrictions
      ]
    }

    ::Bcome::Registry::Loader.instance.expects(:data).returns(registry_data)

    # When 
    command_group = ::Bcome::Registry::Loader.instance.command_group_for_node(node)

    # Then both our commands should be present, keyed on the group name
    commands = command_group.all_commands[group_name]
    assert commands.size == 1
  end

  def test_should_restrict_config_to_inventory
    # Given
    node_inventory = mock("A mocked node")
    node_inventory.stubs(:is_a?).with(::Bcome::Node::Inventory).returns(true)

    config = {
      :restrict_to_node => "inventory"
    }

    # When/then
    assert Bcome::Registry::Loader.instance.restrict_config?(node_inventory, config) == false

    node_not_an_inventory = mock("A mocked node")
    node_not_an_inventory.stubs(:is_a?).with(::Bcome::Node::Inventory).returns(false)

    # When/then
    assert Bcome::Registry::Loader.instance.restrict_config?(node_not_an_inventory, config) == true
  end

  def test_should_restrict_config_to_collection
    # Given
    node_collection = mock("A mocked node")
    node_collection.stubs(:is_a?).with(::Bcome::Node::Collection).returns(true)

    config = {
      :restrict_to_node => "collection"
    }

    # When/then
    assert Bcome::Registry::Loader.instance.restrict_config?(node_collection, config) == false

    node_not_a_collection = mock("A mocked node")
    node_not_a_collection.stubs(:is_a?).with(::Bcome::Node::Collection).returns(false)

    # When/then
    assert Bcome::Registry::Loader.instance.restrict_config?(node_not_a_collection, config) == true
  end

  def test_should_raise_when_provided_with_invalid_restriction_key
    # Given
    node = mock("Whatever")
    config = {
      :restrict_to_node => "i_dont_exist"
    }

    # When/then
    assert_raise Bcome::Exception::InvalidRestrictionKeyInRegistry do 
      Bcome::Registry::Loader.instance.restrict_config?(node, config)
    end
  end

end
