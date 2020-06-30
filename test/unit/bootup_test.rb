

load "#{File.dirname(__FILE__)}/../base.rb"
load "#{File.dirname(__FILE__)}/bootup_helper.rb"

class BootupTest < ActiveSupport::TestCase
  include UnitTestHelper

  setup do
    Bcome::Bootup.instance.send(:teardown!)
  end

  teardown do
    Bcome::Bootup.instance.send(:teardown!)
  end

  def test_should_initialize_a_bootup
    # Given
    breadcrumbs = 'foo:bar'
    argument = given_a_random_string_of_length(5)

    # When
    ::Bcome::Bootup.instance.set({ breadcrumbs: breadcrumbs, arguments: argument })
    bootup = ::Bcome::Bootup.instance

    # Then
    assert bootup.breadcrumbs == breadcrumbs
    assert bootup.arguments == argument
    assert bootup.crumbs == %w[foo bar]
  end

  def test_should_parse_breadcrmbs
    # Given
    crumb1 = given_a_random_string_of_length(5)
    crumb2 = given_a_random_string_of_length(5)

    breadcrumbs = "#{crumb1}:#{crumb2}"

    # When
    ::Bcome::Bootup.instance.set(breadcrumbs: breadcrumbs)

    # Then
    assert ::Bcome::Bootup.instance.crumbs == [crumb1, crumb2]
  end

  def xtest_should_initialize_estate_tree_to_get_estate
    # Given
    ::Bcome::Bootup.instance.set(breadcrumbs: nil)
    bootup = ::Bcome::Bootup.instance

    estate = Bcome::Node::Collection.new(given_estate_setup_params)
    factory = ::Bcome::Node::Factory.send(:new)
    factory.expects(:init_tree).returns(estate)

    Bcome::Node::Factory.expects(:instance).returns(factory)

    # When/then
    bootup_estate = bootup.estate

    # Then
    assert estate == bootup_estate
  end

  def test_should_set_context_if_no_crumbs
    # Given
    spawn_into_context = true
    ::Bcome::Bootup.instance.set({ breadcrumbs: nil }, spawn_into_context)
    bootup = ::Bcome::Bootup.instance

    estate = Bcome::Node::Collection.new(given_estate_setup_params)
    bootup.expects(:estate).returns(estate)
    workspace_instance = ::Bcome::Workspace.send(:new) 
    workspace_instance.expects(:set).with(context: estate, :show_welcome => true).returns(nil)

    Bcome::Workspace.expects(:instance).returns(workspace_instance)

    # When/then
    bootup.do
  end

  def test_should_traverse_tree_if_crumbs
    # Given
    ::Bcome::Bootup.instance.set(breadcrumbs: 'foo:bar')
    bootup = ::Bcome::Bootup.instance

    assert bootup.crumbs.size == 2

    estate = Bcome::Node::Collection.new(given_estate_setup_params)
    bootup.expects(:estate).returns(estate)
    bootup.expects(:traverse).with(estate)

    # When/then
    bootup.do
  end
  
  def test_should_traverse_dummy_tree
    # Given
    estate = given_a_dummy_estate

    breadcrumbs = 'one:two:three:four'
    views = given_basic_dummy_views
    factory = ::Bcome::Node::Factory.send(:new)
    factory.create_tree(estate, views)
    ::Bcome::Node::Factory.expects(:instance).returns(factory) 

    found_context = test_traverse_tree(estate, %w[one two three four])

    factory.expects(:init_tree).returns(estate)

    # We expect to have traversed to our found context, at which point we enter a console session, thus:
    ::Bcome::Workspace.instance.expects(:set).with(context: found_context, :show_welcome => true)

    # When/then
    ::Bcome::Bootup.set_and_do(breadcrumbs: breadcrumbs)
  end

  def xtest_should_invoke_crumb_as_method_on_context
    # Given
    estate = given_a_dummy_estate
    breadcrumbs = 'one:two:three:four:five'
    views = given_basic_dummy_views
    ::Bcome::Node::Factory.send(:new).create_tree(estate, views)

    found_context = test_traverse_tree(estate, %w[one two three four])

    factory = ::Bcome::Node::Factory.send(:new)
    factory.expects(:init_tree).returns(estate)

    # We expect to have not found a context for "five", and so we'll invoke "five" on "four"
    found_context.expects(:invoke).with('five', nil)

    ::Bcome::Node::Factory.expects(:instance).returns(factory)

    # When/then
    ::Bcome::Bootup.set_and_do(breadcrumbs: breadcrumbs)
  end

  def xtest_should_invoke_crumb_as_method_on_context_passing_in_an_argument
    # Given
    estate = given_a_dummy_estate
    breadcrumbs = 'one:two:three:four:five'
    argument = 'an argument'

    views = given_basic_dummy_views

    fac = ::Bcome::Node::Factory.send(:new).create_tree(estate, views)
    ::Bcome::Node::Factory.expects(:instance).returns(fac)

    found_context = test_traverse_tree(estate, %w[one two three four])

    fac.expects(:init_tree).returns(estate)

    # We expect to have not found a context for "five", and so we'll invoke "five" on "four" passing in our argument "argument"
    found_context.expects(:invoke).with('five', argument)

    # When/then
    ::Bcome::Bootup.set_and_do(breadcrumbs: breadcrumbs, arguments: argument)
  end

  def test_should_be_able_to_pass_an_argument_to_an_invoked_method_on_a_context
    # Given
    identifier = given_a_random_string_of_length(4)
    method_name = :methodthattakesinoneargument
    arguments = ['args']

    config = {
      'toplevel': {
        description: 'top level node',
        type: 'collection',
      },
      "toplevel:#{identifier}": {
        type: 'collection', 
        description: "the node we'll execute our method on" 
      }  
    }  

    YAML.expects(:load_file).returns(config).at_least_once
    factory = Bcome::Node::Factory.send(:new)
    factory.init_tree

    Bcome::Node::Factory.expects(:instance).returns(factory)

    # When/then
    ::Bcome::Bootup.set_and_do(breadcrumbs: "#{identifier}:#{method_name}", arguments: arguments)

    # And all our expectations are met
  end

  def test_should_be_able_to_invoke_a_method_on_a_context
    # Given
    identifier = given_a_random_string_of_length(4)
    method_name = :methodthatdoesnotrequirearguments # Method added in our bootup helper

    config = {
      'toplevel': {
        description: 'top level node',
        type: 'collection',
      },  
      "toplevel:#{identifier}": {
        type: 'collection',
        description: "the node we'll execute our method on"
      }
    }

    YAML.expects(:load_file).returns(config).at_least_once
    factory = Bcome::Node::Factory.send(:new)
    factory.init_tree

    Bcome::Node::Factory.expects(:instance).returns(factory)

    # When/then
    ::Bcome::Bootup.set_and_do(breadcrumbs: "#{identifier}:#{method_name}", arguments: nil)

    # And all our expectations are met
  end

  def test_should_raise_when_invoking_a_method_on_a_context_without_arguments_when_one_is_required
    # Given
    identifier = given_a_random_string_of_length(4)
    method_name = :methodthattakesinoneargument

    config = {
      'toplevel': {
        description: 'top level node',
        type: 'collection',
      },
      "toplevel:#{identifier}": {
        type: 'collection',
        description: "the node we'll execute our method on"
      }
    }
    
    # we create an estate first
    YAML.expects(:load_file).returns(config).at_least_once
    estate_instance = Bcome::Node::Factory.send(:new)

    Bcome::Node::Factory.expects(:instance).returns(estate_instance)

    spawn_into_context = true
    ::Bcome::Bootup.instance.set( {breadcrumbs: "#{identifier}:#{method_name}", arguments: nil}, spawn_into_context)

    # When/then
    assert_raise Bcome::Exception::ArgumentErrorInvokingMethodFromCommmandLine do
      ::Bcome::Bootup.instance.do
    end
    # And all our expectations are met
  end

  def test_should_raise_when_invoking_a_method_on_a_context_with_arguments_when_none_are_required
    # Given
    identifier = given_a_random_string_of_length(4)
    method_name = :methodthattakesinoneargument # Method added in our bootup helper

    config = {
      "toplevel": {
        description: 'top level node',
        type: 'collection',
      },
      "toplevel:#{identifier}": {
        type: 'collection', 
        description: "the node we'll execute our method on"
      },
    }
   
    YAML.expects(:load_file).returns(config).at_least_once
    estate_instance = Bcome::Node::Factory.send(:new)

    Bcome::Node::Factory.expects(:instance).returns(estate_instance)
 
    spawn_into_context = true
    ::Bcome::Bootup.instance.set({ breadcrumbs: "#{identifier}:#{method_name}", arguments: nil }, spawn_into_context)

    # When/then
    assert_raise Bcome::Exception::ArgumentErrorInvokingMethodFromCommmandLine do
      ::Bcome::Bootup.instance.do
    end
    # and also that all our expectations are met
  end

  def test_should_raise_when_penultimate_crumb_references_neither_node_nor_invokable_method_nor_user_registry_method
    # Given
    method_name = :i_dont_exist
    spawn_into_context = true

    config = {
      "toplevel": {
        description: 'top level node',
        type: 'collection',
      }
    }

    YAML.expects(:load_file).returns(config).at_least_once
    estate_instance = Bcome::Node::Factory.send(:new)
    Bcome::Node::Factory.expects(:instance).returns(estate_instance)

    ::Bcome::Bootup.instance.set({ breadcrumbs: method_name, arguments: nil}, spawn_into_context)

    # When/then
    assert_raise Bcome::Exception::InvalidBreadcrumb do
      ::Bcome::Bootup.instance.do
    end
  end
end
