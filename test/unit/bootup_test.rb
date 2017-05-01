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

end
