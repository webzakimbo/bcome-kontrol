load "#{File.dirname(__FILE__)}/../base.rb"

class BootupTest < ActiveSupport::TestCase

  def test_should_initialize_a_bootup
    # Given
    breadcrumbs = "foo:bar"
    command = given_a_random_string_of_length(5)

    # When
    bootup = ::Bcome::Bootup.new({
      :breadcrumbs => breadcrumbs,
      :command => command
    })

    # Then
    assert bootup.breadcrumbs == breadcrumbs
    assert bootup.command == command
  end

  def test_should_parse_breadcrmbs
    # Given
    crumb1 = given_a_random_string_of_length(5)
    crumb2 = given_a_random_string_of_length(5)

    breadcrumbs = "#{crumb1}:#{crumb2}"

    # When
    bootup = ::Bcome::Bootup.new({
      :breadcrumbs => breadcrumbs
    })

    # Then 
    assert bootup.crumbs == [crumb1, crumb2]
  end

  def test_should_initialize_estate_tree_to_get_estate
    # Given
    bootup = ::Bcome::Bootup.new({
     :breadcrumbs => nil
    })

    estate = Bcome::Node::Base.new(given_estate_setup_params) 
    ::Bcome::Node::Estate.expects(:init_tree).returns(estate)

    # When/then
    bootup_estate = bootup.estate

    # Then
    assert estate == bootup_estate
  end

  def test_should_set_context_if_no_crumbs
    # Given
    bootup = ::Bcome::Bootup.new({
      :breadcrumbs => nil
    })

    estate = Bcome::Node::Base.new(given_estate_setup_params)
    bootup.expects(:estate).returns(estate)
    ::Bcome::Workspace.instance.expects(:set).with(:context => estate).returns(nil)

    # When/then
    bootup.do
  end

  def test_should_traverse_tree_if_crumbs
    # Given
    bootup = ::Bcome::Bootup.new({
     :breadcrumbs => "foo:bar"
    })

    assert bootup.crumbs.size == 2

    estate = Bcome::Node::Base.new(given_estate_setup_params)
    bootup.expects(:estate).returns(estate)
    bootup.expects(:traverse).with(estate) 

    # When/then
    bootup.do  
  end

  def test_should_traverse_dummy_tree
    # Given
    estate = given_a_dummy_estate
    
    breadcrumbs = "one:two:three:four"
    view_data = given_dummy_view_data 
    estate.create_tree(view_data)

    found_context = test_traverse_tree(estate, ["one", "two", "three", "four"])

    ::Bcome::Node::Estate.expects(:init_tree).returns(estate)
 
    # We expect to have traversed to our found context, at which point we enter a console session, thus:
    ::Bcome::Workspace.instance.expects(:set).with({ :context => found_context })

    # When/then
    ::Bcome::Bootup.do({:breadcrumbs => breadcrumbs})
  end

  def test_should_invoke_crumb_as_method_on_context
    # Given
    estate = given_a_dummy_estate
    breadcrumbs = "one:two:three:four:five"
    view_data = given_dummy_view_data 
    estate.create_tree(view_data)
    
    found_context = test_traverse_tree(estate, ["one", "two", "three", "four"])

    ::Bcome::Node::Estate.expects(:init_tree).returns(estate)

    # We expect to have not found a context for "five", and so we'll invoke "five" on "four"
    # TODO - here we are
 
    # When/then
    ::Bcome::Bootup.do({:breadcrumbs => breadcrumbs })
  end

end
